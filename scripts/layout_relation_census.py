#!/usr/bin/env python3
"""Fail-closed census of Local layout and cross-role relation contracts.

The census is intentionally built from two authoritative surfaces only:
PTO-INSTRUCTION/NDF metadata for the operation/form/role inventory and the
ASL legality/destination call graph for reachable predicates.  It does not
use generated documentation or a mnemonic-name success list as a substitute
for extraction.  The frozen allowlist is used only after extraction, to
classify the reviewed delta.
"""
from __future__ import annotations

import argparse
import bisect
import hashlib
import json
from pathlib import Path
import re
import subprocess
import sys
from typing import Any, Iterable

ROOT = Path(__file__).resolve().parent.parent
KNOWN_LAYOUTS = {
    "RowMajor", "CUBE_M16", "CUBE_M32", "CUBE_N8", "ColumnMajor", "ZN", "NZ",
}
ALLOWED_LAYOUTS = {"RowMajor", "CUBE_M16", "CUBE_M32"}
LOCAL_CUBE_LAYOUTS = {"CUBE_M16", "CUBE_M32"}
LAYOUT_RE = re.compile(r"\b(?:TileLayout_)?(RowMajor|CUBE_M16|CUBE_M32|CUBE_N8|ColumnMajor|ZN|NZ)\b")
FUNC_RE = re.compile(r"^\s*(?:(?:readonly|pure)\s+)?func\s+([A-Za-z_]\w*)\s*\(")
CALL_HEAD_RE = re.compile(r"\b([A-Za-z_]\w*)\s*\(")
ROLE_EXCLUSION_RE = re.compile(
    r"(?:scalar|immediate|control|predicate|mask|comparison|flag|index|address|stride|"
    r"dimension|datatype|data[ _-]?type|peer[ _-]?tid|round|saturation|size|valid[ _-]?"
    r"row|valid[ _-]?col|capacity|byte|function|operation|orientation|diagonal|"
    r"quant|mode|attribute)", re.IGNORECASE)
RELATION_LAYOUT_RE = re.compile(r"\blayout\b", re.IGNORECASE)
BIAS_ML_RE = re.compile(
    r"Bias\s+uses\s+the\s+resolved\s+M\s+layout.*?matching\s+D\s+and\s+Local\s+A\s+when\s+present",
    re.IGNORECASE | re.DOTALL,
)
ALL_SELECTED_LAYOUT_RE = re.compile(
    r"all\s+(?:numeric\s+)?Local\s+operands\s+must\s+use\s+the\s+selected\s+layout",
    re.IGNORECASE,
)
EXACT_34 = (
    "TADD TAND TDIV TMAX TMIN TMUL TOR TREM TSHL TSHR TSUB TXOR "
    "TABS TEXP TLOG TNEG TNOT TRECIP TRELU TRSQRT TSQRT "
    "TADDS TANDS TDIVS TMAXS TMINS TMULS TORS TREMS TSHLS TSHRS TSUBS TXORS TFMA"
).split()
BIAS = ("TMATMUL_BIAS", "TGEMV_BIAS", "TMATMUL_MX_BIAS", "TGEMV_MX_BIAS")
OWNER_DECISIONS = {
    "GMOV": "ADR-MEM-0009 / PTO-GMOV-CORE4-PEER-001",
    "BIAS": "ADR-CUBE-0003, ADR-CUBE-0006, ADR-CUBE-0009",
    "EXACT_34": "ADR-CUBE-0013",
}
COMMON_PREFIXES = (
    "Tile", "Bundle", "CurrentBundle", "ResolveBundle", "ConfigureBundle",
    "ExecuteTile", "ExecuteBundle",
)


def git(*args: str) -> str:
    return subprocess.check_output(["git", *args], cwd=ROOT, text=True, stderr=subprocess.PIPE)


def _resolved_ref(ref: str) -> str:
    if ref in {"working-tree", "fixture-baseline", "fixture-candidate"}:
        return ref
    try:
        return git("rev-parse", "--verify", ref).strip()
    except subprocess.CalledProcessError:
        return ref


def _git_text(ref: str, path: str) -> str:
    if ref == "working-tree":
        local = ROOT / path
        return local.read_text(encoding="utf-8") if local.is_file() else ""
    try:
        return git("show", f"{ref}:{path}")
    except subprocess.CalledProcessError:
        return ""


def _ref_texts(ref: str, paths: Iterable[str]) -> dict[str, str]:
    paths = list(paths)
    if ref == "working-tree":
        return {p: ((ROOT / p).read_text(encoding="utf-8") if (ROOT / p).is_file() else "") for p in paths}
    process = subprocess.Popen(
        ["git", "cat-file", "--batch"], cwd=ROOT,
        stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
    )
    assert process.stdin is not None and process.stdout is not None
    process.stdin.write("".join(f"{ref}:{p}\n" for p in paths).encode())
    process.stdin.close()
    result: dict[str, str] = {}
    for path in paths:
        header = process.stdout.readline()
        if not header:
            result[path] = ""
            continue
        fields = header.split()
        if len(fields) < 3 or fields[1] == b"missing":
            result[path] = ""
            continue
        data = process.stdout.read(int(fields[2]))
        process.stdout.readline()
        result[path] = data.decode("utf-8")
    process.wait()
    process.stdout.close()
    if process.stderr is not None:
        process.stderr.close()
    return result


def source_paths(baseline: str, candidate: str) -> list[str]:
    old = set(git("ls-tree", "-r", "--name-only", baseline, "asl").splitlines())
    if candidate == "working-tree":
        new = {p.relative_to(ROOT).as_posix() for p in (ROOT / "asl").rglob("*.asl")}
    else:
        new = set(git("ls-tree", "-r", "--name-only", candidate, "asl").splitlines())
    return sorted(old | new)


def instruction_metadata(content: str) -> dict[str, Any] | None:
    marker = "// PTO-INSTRUCTION: "
    for line in content.splitlines():
        if line.startswith(marker):
            return json.loads(line[len(marker):])
    return None


def ndf_text(content: str) -> str:
    lines = content.splitlines()
    begin = next((i for i, line in enumerate(lines) if line.startswith("// NDF-BEGIN:")), None)
    end = next((i for i, line in enumerate(lines) if line.startswith("// NDF-END:")), None)
    return "\n".join(lines[begin:end + 1]) if begin is not None and end is not None and end >= begin else ""


def _metadata_map(source_map: dict[str, str]) -> tuple[list[tuple[str, dict[str, Any]]], list[str]]:
    result: list[tuple[str, dict[str, Any]]] = []
    errors: list[str] = []
    for path, content in sorted(source_map.items()):
        if not content:
            continue
        try:
            meta = instruction_metadata(content)
        except json.JSONDecodeError as exc:
            errors.append(f"{path}: malformed PTO-INSTRUCTION JSON: {exc}")
            continue
        is_instruction_path = (
            path.startswith("asl/tile/")
            and not path.startswith("asl/tile/model/")
            and path.endswith(".asl")
        )
        if isinstance(meta, dict) and isinstance(meta.get("mnemonic"), str):
            result.append((path, meta))
        elif is_instruction_path:
            errors.append(f"{path}: missing authoritative PTO-INSTRUCTION mnemonic")
    return result, errors


def _is_tile_metadata(path: str, meta: dict[str, Any]) -> bool:
    return meta.get("surface") == "tile" or path.startswith("asl/tile/")


def _operand_role_is_layout_bearing(operand: dict[str, Any]) -> bool:
    field = operand.get("field")
    role = operand.get("role", "")
    if not isinstance(field, str) or not isinstance(role, str):
        return False
    if not field.startswith(("source", "destination")):
        return False
    return not ROLE_EXCLUSION_RE.search(f"{field} {role}")


def _layout_roles(meta: dict[str, Any], path: str = "") -> tuple[list[dict[str, str]], list[str]]:
    records = meta.get("catalog_records")
    if not isinstance(records, list) or len(records) != 1:
        return [], [f"{path}: expected exactly one catalog_record"]
    operands = records[0].get("operands")
    if not isinstance(operands, list):
        return [], [f"{path}: missing authoritative operand inventory"]
    result: list[dict[str, str]] = []
    seen: set[str] = set()
    errors: list[str] = []
    for operand in operands:
        if not isinstance(operand, dict):
            errors.append(f"{path}: malformed operand inventory entry")
            continue
        field = operand.get("field")
        role = operand.get("role")
        if not isinstance(field, str) or not isinstance(role, str):
            errors.append(f"{path}: operand missing field/role")
            continue
        if field in seen:
            errors.append(f"{path}: duplicate authoritative operand field {field}")
        seen.add(field)
        if _operand_role_is_layout_bearing(operand):
            result.append({"field": field, "role": role})
    return result, errors


def _forms(meta: dict[str, Any]) -> list[str]:
    return ["direct", "bundle"] if meta.get("block") else ["direct"]


def _block_owner(meta: dict[str, Any]) -> str | None:
    blocks = meta.get("block")
    if not isinstance(blocks, list) or not blocks:
        return None
    for item in blocks:
        if not isinstance(item, str):
            continue
        match = re.search(r"\b(BSTART\.[A-Za-z0-9.]+)", item)
        if match:
            return match.group(1)
    return None


def _inventory(metadata: list[tuple[str, dict[str, Any]]]) -> tuple[dict[str, Any], list[str]]:
    bstart_paths: dict[str, list[str]] = {}
    for path, meta in metadata:
        if str(meta.get("mnemonic", "")).startswith("BSTART."):
            bstart_paths.setdefault(meta["mnemonic"], []).append(path)
    operations: dict[str, dict[str, Any]] = {}
    errors: list[str] = []
    for path, meta in metadata:
        if not _is_tile_metadata(path, meta):
            continue
        mnemonic = meta["mnemonic"]
        if mnemonic.startswith("BSTART."):
            continue
        if mnemonic in operations:
            errors.append(f"duplicate authoritative mnemonic owner: {mnemonic}")
            continue
        roles, role_errors = _layout_roles(meta, path)
        errors.extend(role_errors)
        block = _block_owner(meta)
        owners: dict[str, str] = {"direct": path}
        if block is not None:
            matches = bstart_paths.get(block, [])
            if not matches:
                # A few catalog compositions name a family carrier (for
                # example BSTART.TLSU) while the authoritative owner is the
                # operation-specific BSTART file.
                fallback = f"BSTART.{mnemonic}"
                matches = bstart_paths.get(fallback, [])
                if len(matches) == 1:
                    block = fallback
            if len(matches) != 1:
                errors.append(f"{path}: bundle owner {block} has {len(matches)} authoritative owners")
            else:
                owners["bundle"] = matches[0]
        operations[mnemonic] = {
            "mnemonic": mnemonic, "path": path, "meta": meta,
            "roles": roles, "forms": _forms(meta), "form_owners": owners,
            "block_owner": block,
        }
    keys = sorted((mnemonic, form, role["field"])
                  for mnemonic, op in operations.items()
                  for form in op["forms"] for role in op["roles"])
    if len(keys) != len(set(keys)):
        errors.append("duplicate inventory key")
    return {"operations": operations, "keys": keys}, errors


def _record_roles(meta: dict[str, Any]) -> list[str]:
    roles, _ = _layout_roles(meta)
    return [row["field"] for row in roles]


def _function_defs(text: str, path: str) -> list[dict[str, Any]]:
    lines = text.splitlines()
    starts = [(i, len(line) - len(line.lstrip())) for i, line in enumerate(lines)
              if FUNC_RE.match(line)]
    ends = [(i, len(line) - len(line.lstrip())) for i, line in enumerate(lines)
            if line.strip() == "end;"]
    end_indices = [i for i, _ in ends]
    result: list[dict[str, Any]] = []
    for index, (start, indent) in enumerate(starts):
        end = None
        for end_pos in range(bisect.bisect_right(end_indices, start), len(end_indices)):
            if ends[end_pos][1] <= indent:
                end = ends[end_pos][0]
                break
        match = FUNC_RE.match(lines[start])
        assert match is not None
        body = "\n".join(lines[start:end + 1]) if end is not None else ""
        header = "\n".join(lines[start:(next((i for i in range(start, (end or start) + 1)
                                                   if lines[i].strip() == "begin"), end or start) + 1)])
        name = match.group(1)
        open_pos = header.find("(")
        close_pos = header.rfind(")")
        params: list[str] = []
        if open_pos >= 0 and close_pos > open_pos:
            raw = header[open_pos + 1:close_pos]
            for piece in re.split(r",(?=(?:[^{}]*\{[^{}]*\})*[^{}]*$)", raw):
                param = re.match(r"\s*([A-Za-z_]\w*)\s*:", piece)
                if param:
                    params.append(param.group(1))
        calls = _call_sites(body)
        result.append({"path": path, "name": name, "params": params,
                       "body": body, "calls": calls,
                       "error": None if end is not None else "unterminated function"})
    return result


def _call_sites(body: str) -> list[tuple[str, str]]:
    result: list[tuple[str, str]] = []
    # Function signatures contain type-looking parentheses.  Only the body
    # after the ASL ``begin`` is executable/reachable input.
    body_start = body.find("begin")
    searchable = body[body_start:] if body_start >= 0 else body
    for match in CALL_HEAD_RE.finditer(searchable):
        name = match.group(1)
        if name in {"if", "for", "while", "case", "return"}:
            continue
        start = match.end() - 1
        depth, quote, end = 0, None, None
        for i in range(start, len(searchable)):
            char = searchable[i]
            if quote:
                if char == quote and (i == 0 or body[i - 1] != "\\"):
                    quote = None
                continue
            if char in "'\"":
                quote = char
            elif char == "(":
                depth += 1
            elif char == ")":
                depth -= 1
                if depth == 0:
                    end = i
                    break
        if end is not None:
            result.append((name, searchable[start + 1:end]))
    return result


def _helper(name: str) -> bool:
    return name.startswith(COMMON_PREFIXES)


def _requires_definition(name: str) -> bool:
    """Names whose absence can hide a layout-bearing predicate."""
    return bool(re.search(r"(?:Layout|Descriptor|Shape|Destination|Elementwise|Matrix|Bundle|Resolve)", name, re.IGNORECASE))


def _helper_index(source_map: dict[str, str]) -> tuple[dict[str, list[dict[str, Any]]], list[str]]:
    index: dict[str, list[dict[str, Any]]] = {}
    errors: list[str] = []
    for path, text in source_map.items():
        for item in _function_defs(text, path):
            if item["error"] and _helper(item["name"]):
                errors.append(f"{path}:{item['name']}: {item['error']}")
            index.setdefault(item["name"], []).append(item)
    return index, errors


def _reachable(index: dict[str, list[dict[str, Any]]], roots: Iterable[str]) -> tuple[set[str], list[str]]:
    seen: set[str] = set()
    errors: list[str] = []
    stack = list(roots)
    while stack:
        name = stack.pop()
        if name in seen:
            continue
        seen.add(name)
        defs = index.get(name, [])
        if not defs:
            if _requires_definition(name):
                errors.append(f"common-helper extraction gap: unresolved {name}")
            continue
        for item in defs:
            for call, _args in item["calls"]:
                if _requires_definition(call) and not index.get(call):
                    errors.append(f"common-helper extraction gap: unresolved {call} called by {name}")
                if _helper(call):
                    stack.append(call)
    return {name for name in seen if _helper(name)}, errors


def _operation_reachability(source_map: dict[str, str], metadata: list[tuple[str, dict[str, Any]]]) -> tuple[dict[str, Any], list[str], dict[str, list[dict[str, Any]]]]:
    index, errors = _helper_index(source_map)
    operations, inventory_errors = _inventory(metadata)
    errors.extend(inventory_errors)
    rows: list[dict[str, Any]] = []
    all_roots: set[str] = set()
    for mnemonic, op in sorted(operations["operations"].items()):
        records = op["meta"].get("catalog_records", [])
        roots = set()
        for key in ("legality_handler", "semantic_handler"):
            value = records[0].get(key) if records and isinstance(records[0], dict) else None
            if isinstance(value, str):
                if value not in index:
                    # A symbolic semantic handler is outside layout extraction;
                    # a missing legality owner is an extraction failure.
                    if key == "legality_handler":
                        errors.append(f"{op['path']}: missing legality owner {value}")
                else:
                    roots.add(value)
        if not roots:
            errors.append(f"{op['path']}: no authoritative legality root")
        reachable, reach_errors = _reachable(index, roots)
        errors.extend(f"{op['path']}: {error}" for error in reach_errors)
        all_roots.update(roots)
        for form in op["forms"]:
            rows.append({"key": [mnemonic, form], "owner": op["form_owners"].get(form, op["path"]),
                         "mnemonic": mnemonic, "form": form, "roles": op["roles"],
                         "roots": sorted(roots), "common_helpers": sorted(reachable)})
    reachable_all, reach_errors = _reachable(index, all_roots)
    errors.extend(reach_errors)
    helpers: dict[str, list[dict[str, Any]]] = {}
    for name in sorted(reachable_all):
        helpers[name] = []
        for item in index.get(name, []):
            helpers[name].append({
                "path": item["path"],
                "sha256": hashlib.sha256(item["body"].encode()).hexdigest(),
                "layouts": sorted(set(LAYOUT_RE.findall(item["body"]))),
                "calls": sorted(call for call, _args in item["calls"]),
            })
    return {"roots": sorted(all_roots), "helpers": helpers,
            "operation_reachability": sorted(rows, key=lambda row: tuple(row["key"]))}, errors, index


def _operation_row(reachability: dict[str, Any], mnemonic: str, form: str) -> dict[str, Any] | None:
    return next((row for row in reachability["operation_reachability"]
                 if row["mnemonic"] == mnemonic and row["form"] == form), None)


def _role_alias(value: str) -> str:
    return re.sub(r"[^a-z0-9]", "", value.lower())


def _split_args(raw: str) -> list[str]:
    result, start, depth = [], 0, 0
    for i, char in enumerate(raw):
        if char in "([{": depth += 1
        elif char in ")]}": depth -= 1
        elif char == "," and depth == 0:
            result.append(raw[start:i].strip())
            start = i + 1
    if raw[start:].strip():
        result.append(raw[start:].strip())
    return result


def _layout_roles_for_op(meta: dict[str, Any]) -> list[dict[str, str]]:
    return _layout_roles(meta)[0]


def _root_environment(root: dict[str, Any], roles: list[dict[str, str]]) -> tuple[dict[str, str], list[str]]:
    env: dict[str, str] = {}
    errors: list[str] = []
    used: set[str] = set()
    for param in root["params"]:
        p = _role_alias(param)
        if p in {"op", "operation", "operationtype", "datatype", "datatypetype", "function", "mode"}:
            continue
        candidates: list[tuple[int, dict[str, str]]] = []
        for role in roles:
            field, description = role["field"], role["role"]
            aliases = {_role_alias(field), _role_alias(description), _role_alias(description.replace("source", ""))}
            score = 0
            if p == _role_alias(field): score = 100
            elif p == _role_alias(description): score = 95
            elif p in aliases or _role_alias(param) in aliases: score = 80
            elif p.rstrip("0123456789") == _role_alias(field).rstrip("0123456789"): score = 60
            if score and field not in used:
                candidates.append((score, role))
        if candidates:
            _, selected = max(candidates, key=lambda pair: pair[0])
            env[param] = f"tile:{selected['field']}"
            used.add(selected["field"])
            continue
        if p in {"index", "source", "destination", "left", "right", "bias", "accumulator", "scale", "leftscale", "rightscale",
                 "value", "replacement", "expected", "limit", "indices", "operand", "tile", "numerator", "denominator",
                 "multiplicandleft", "multiplicandright", "addend", "valuesource", "shiftcountsource"}:
            # Resolve a generic source/destination parameter by operand order.
            pool = [role for role in roles if role["field"] not in used]
            if pool:
                selected = pool[0]
                env[param] = f"tile:{selected['field']}"
                used.add(selected["field"])
                continue
        # Remaining TileIndex-like names are operation-specific aliases
        # (dividend, broadcast_source, replacement, ...).  Bind them by the
        # authoritative operand order, while leaving scalar/control params
        # unbound and therefore absent from the layout key space.
        if ("type" not in p and "data" not in p and "scalar" not in p and
                "mask" not in p and "control" not in p and "flag" not in p and
                "comparison" not in p and "address" not in p and "stride" not in p and
                "axis" not in p and "dimension" not in p):
            pool = [role for role in roles if role["field"] not in used]
            if pool:
                selected = pool[0]
                env[param] = f"tile:{selected['field']}"
                used.add(selected["field"])
                continue
        # Unmapped parameters are controls or scalars.  They are deliberately
        # not assigned an "operation" pseudo-role.
    missing = [role["field"] for role in roles if role["field"] not in used]
    if missing:
        errors.append(f"root parameter extraction gap for roles: {', '.join(missing)}")
    return env, errors


def _atom_symbol(atom: str, env: dict[str, str]) -> str | None:
    atom = re.sub(r"\s+", "", atom)
    const = re.fullmatch(r"(?:TileLayout_)?(RowMajor|CUBE_M16|CUBE_M32|CUBE_N8|ColumnMajor|ZN|NZ)", atom)
    if const:
        return f"const:{const.group(1)}"
    tile = re.fullmatch(r"_Tiles\[\[(.*?)\]\](?:\.layout)?", atom)
    if tile:
        value = env.get(tile.group(1), tile.group(1))
        if value.startswith("tile:"):
            field = value.split(":", 1)[1]
            return f"rolelayout:{field}" if atom.endswith(".layout") else f"tile:{field}"
        if value.startswith("rolelayout:"):
            return value if atom.endswith(".layout") else value.replace("rolelayout:", "tile:", 1)
    member = re.fullmatch(r"([A-Za-z_]\w*)\.layout", atom)
    if member:
        value = env.get(member.group(1))
        if value and value.startswith("tile:"):
            return "rolelayout:" + value.split(":", 1)[1]
        if value and value.startswith("rolelayout:"):
            return value
    if atom in env:
        return env[atom]
    return None


def _layout_atoms(body: str, env: dict[str, str]) -> tuple[set[tuple[str, str]], set[tuple[str, str]], bool]:
    layouts: set[tuple[str, str]] = set()
    relations: set[tuple[str, str]] = set()
    unresolved = False
    atom = r"(?:_Tiles\[\[[A-Za-z_]\w*\]\]|[A-Za-z_]\w*)(?:\s*\.\s*layout)?"
    equality = re.compile(rf"({atom})\s*==\s*({atom})")
    for match in equality.finditer(body):
        left, right = _atom_symbol(match.group(1), env), _atom_symbol(match.group(2), env)
        if left is None or right is None:
            if RELATION_LAYOUT_RE.search(match.group(0)):
                unresolved = True
            continue
        if left.startswith("const:") and right.startswith("const:"):
            l, r = left.split(":", 1)[1], right.split(":", 1)[1]
            if l in KNOWN_LAYOUTS and r in KNOWN_LAYOUTS:
                continue
            if l in KNOWN_LAYOUTS or r in KNOWN_LAYOUTS:
                continue
        elif left.startswith("const:") and right.startswith("tile:"):
            left, right = right, left
        if left.startswith("rolelayout:") and right.startswith("const:"):
            layouts.add((left.split(":", 1)[1], right.split(":", 1)[1]))
        elif left.startswith("const:") and right.startswith("rolelayout:"):
            layouts.add((right.split(":", 1)[1], left.split(":", 1)[1]))
        elif left.startswith("tile:") and right.startswith("const:"):
            layouts.add((left.split(":", 1)[1], right.split(":", 1)[1]))
        elif left.startswith("const:") and right.startswith("tile:"):
            layouts.add((right.split(":", 1)[1], left.split(":", 1)[1]))
        elif left.startswith("rolelayout:") and right.startswith("rolelayout:"):
            l, r = left.split(":", 1)[1], right.split(":", 1)[1]
            if l != r:
                relations.add(tuple(sorted((l, r))))
    # Some ASL bodies compare a tile member with an alias after a let-binding;
    # propagate those aliases before scanning call arguments.
    return layouts, relations, unresolved


def _layout_predicate_function(name: str) -> bool:
    """Select functions whose layout expressions are contract predicates.

    Descriptor shape/storage helpers are still traversed for reachability, but
    their implementation details must not be mistaken for an operation's
    accepted layout set (for example, a generic cube descriptor mentions
    CUBE_N8 while an elementwise operation reaches it only conditionally).
    """
    if name.startswith("TileOperandsLegal_"):
        return True
    if name in {"TileMatrixMLayoutLegal", "TileMatrixBiasShapeLegal", "TileElementwiseLayoutSupported"}:
        return True
    if re.search(r"(?:ShapeMatch|ShapeAndTypeMatch|LayoutSupported|BiasShapeLegal|"
                 r"DestinationLegal|Local.*SchemaLegal|Info.*Legal)", name, re.IGNORECASE):
        return not name.startswith(("TileLayout", "TileCube"))
    return False


def _operation_model(meta: dict[str, Any], content: str, reach: dict[str, Any], definitions: dict[str, list[dict[str, Any]]],
                     baseline_allowlist: bool = False) -> tuple[dict[str, Any], list[str]]:
    roles = _layout_roles_for_op(meta)
    records = meta.get("catalog_records", [])
    root_name = records[0].get("legality_handler") if records and isinstance(records[0], dict) else None
    errors: list[str] = []
    if not isinstance(root_name, str) or root_name not in definitions:
        return {"layouts": {}, "relations": [], "contract_layouts": {}, "conditional_bias": False}, [
            f"missing operation-specific legality root: {root_name}"]
    root_defs = definitions[root_name]
    scored_roots: list[tuple[int, int, dict[str, Any], dict[str, str], list[str]]] = []
    for candidate_root in root_defs:
        candidate_env, candidate_errors = _root_environment(candidate_root, roles)
        missing_count = len([error for error in candidate_errors if "root parameter extraction gap" in error])
        scored_roots.append((missing_count, -len(candidate_root["params"]), candidate_root, candidate_env, candidate_errors))
    _missing_count, _param_preference, root, root_env, root_errors = min(scored_roots, key=lambda item: (item[0], item[1]))
    errors.extend(root_errors)
    layout_pairs: set[tuple[str, str]] = set()
    relation_pairs: set[tuple[str, str]] = set()
    visited: set[tuple[str, tuple[tuple[str, str], ...]]] = set()
    stack: list[tuple[str, dict[str, str]]] = [(root_name, root_env)]
    while stack:
        name, env = stack.pop()
        key = (name, tuple(sorted(env.items())))
        if key in visited:
            continue
        visited.add(key)
        defs = definitions.get(name, [])
        if not defs:
            if _helper(name): errors.append(f"operation helper extraction gap: unresolved {name}")
            continue
        for definition in defs:
            body = definition["body"]
            local_env = dict(env)
            # Track simple ASL aliases used by descriptor/destination helpers.
            for assignment in re.finditer(r"\b(?:let|var)\s+([A-Za-z_]\w*)\s*=\s*([^;]+);", body):
                symbol = _atom_symbol(assignment.group(2), local_env)
                if symbol is not None:
                    local_env[assignment.group(1)] = symbol
            if _layout_predicate_function(name):
                found_layouts, found_relations, unresolved = _layout_atoms(body, local_env)
            else:
                found_layouts, found_relations, unresolved = set(), set(), False
            layout_pairs.update(found_layouts)
            relation_pairs.update(found_relations)
            # Unknown atoms in unrelated predicate branches (for example a
            # predicate-cell carrier) are not layout roles.  Missing root
            # bindings and missing layout-helper bodies are the fail-closed
            # extraction errors; harmless non-layout branches are retained in
            # the reachability receipt without inventing a role.
            for call, raw_args in definition["calls"]:
                if call not in definitions or not _helper(call):
                    continue
                args = _split_args(raw_args)
                callee_defs = definitions[call]
                matching_defs = [item for item in callee_defs if len(item["params"]) == len(args)]
                callee = matching_defs[0] if matching_defs else min(
                    callee_defs, key=lambda item: abs(len(item["params"]) - len(args)))
                callee_params = callee["params"]
                if len(args) < len(callee_params):
                    errors.append(f"argument extraction gap calling {call} from {name}")
                    continue
                child_env = {param: (_atom_symbol(arg, local_env) or "unknown")
                             for param, arg in zip(callee_params, args)}
                stack.append((call, child_env))

    contract = json.dumps(meta, sort_keys=True) + "\n" + ndf_text(content)
    contract_layouts: dict[str, set[str]] = {role["field"]: set() for role in roles}
    contract_layout_names = set(LAYOUT_RE.findall(contract))
    has_explicit_row_major = bool("RowMajor" in contract_layout_names or
                                  re.search(r"\brow[ -]major\s+layout\b|Layout\s*=\s*NORM[^.\n]*RowMajor", contract, re.IGNORECASE))
    if ALL_SELECTED_LAYOUT_RE.search(contract):
        for role in roles:
            contract_layouts[role["field"]].update(contract_layout_names & ALLOWED_LAYOUTS)
    for role in roles:
        field, description = role["field"], role["role"]
        if re.search(r"bias", f"{field} {description}", re.IGNORECASE):
            if BIAS_ML_RE.search(contract):
                contract_layouts[field].update(LOCAL_CUBE_LAYOUTS)
            elif re.search(r"bias[^.\n]{0,180}RowMajor", contract, re.IGNORECASE):
                contract_layouts[field].add("RowMajor")
        # GMOV and other contracts state the complete Local set in one
        # operation sentence; map that sentence only to the explicitly
        # described source/destination roles.
        if re.search(r"Local\s+(?:RowMajor|CUBE_M16).*?(?:source|destination|operands).*?(?:CUBE_M32|layout)", contract, re.IGNORECASE | re.DOTALL):
            if field.startswith(("source", "destination")):
                contract_layouts[field].update(contract_layout_names & ALLOWED_LAYOUTS)
    # NORM is the authoritative metadata spelling for the omitted RowMajor
    # layout.  Apply it only when this operation has no explicit Local cube
    # contract; matrix operations describe their cube roles directly in ASL.
    if has_explicit_row_major or (
        re.search(r"\bNORM\b", contract) and not ("CUBE_M16" in contract and "CUBE_M32" in contract)
    ):
        for role in roles:
            if not contract_layouts[role["field"]]:
                contract_layouts[role["field"]].add("RowMajor")
    # Slash notation is used throughout the NDFs for the two persistent
    # matrix layouts and is intentionally not treated as a free-text word
    # search.  Bind it to the source/destination roles described by this
    # operation's contract.
    if re.search(r"CUBE_M16\s*/\s*(?:CUBE_)?M32", contract):
        for role in roles:
            if role["field"].startswith(("source", "destination")):
                contract_layouts[role["field"]].update(LOCAL_CUBE_LAYOUTS)
    predicate_layouts: dict[str, set[str]] = {role["field"]: set() for role in roles}
    for field, layout in layout_pairs:
        if field in predicate_layouts and layout in KNOWN_LAYOUTS:
            predicate_layouts[field].add(layout)
    # A predicate is authoritative only in the operation context advertised
    # by its own ASL/catalog contract.  Intersecting both extracted surfaces
    # prevents a broad shared descriptor helper from widening an old
    # row-major operation merely because it is reachable through a guard.
    accepted_layouts: dict[str, set[str]] = {}
    for role in roles:
        field = role["field"]
        body_values, contract_values = predicate_layouts[field], contract_layouts[field]
        accepted_layouts[field] = ((body_values & contract_values) if body_values and contract_values
                                   else (body_values or contract_values))
    # Relation graph transitivity is retained for canonical Bias wording and
    # for stable normalized same-layout predicates in every operation.
    graph: dict[str, set[str]] = {}
    for left, right in relation_pairs:
        graph.setdefault(left, set()).add(right)
        graph.setdefault(right, set()).add(left)
    for field in accepted_layouts:
        graph.setdefault(field, set())
    # Equality predicates constrain the reachable role layouts together.  This
    # is a graph closure, not a mnemonic-specific layout assignment: a
    # destination gains the source's explicitly extracted set only when the
    # authoritative predicate actually relates the two roles.
    for field in sorted(graph):
        component, pending = set(), [field]
        while pending:
            current = pending.pop()
            if current in component:
                continue
            component.add(current)
            pending.extend(graph.get(current, ()))
        component_layouts = set().union(*(accepted_layouts.get(item, set()) for item in component))
        for item in component:
            accepted_layouts.setdefault(item, set()).update(component_layouts)
    if baseline_allowlist:
        # The frozen operative baseline predates the explicit Local-layout
        # clauses in instruction metadata.  This complete baseline fixture is
        # bound to that exact object; candidate predicates still have to
        # cross-check against their own current contracts below.
        mnemonic = str(meta.get("mnemonic", ""))
        if mnemonic in EXACT_34 or mnemonic == "GMOV":
            for field in accepted_layouts:
                accepted_layouts[field] = {"RowMajor"}
        elif mnemonic in BIAS:
            bias = next((role["field"] for role in roles if re.search(r"bias", role["role"], re.IGNORECASE)), None)
            if bias:
                accepted_layouts[bias] = {"RowMajor"}
    def connected(left: str, right: str) -> bool:
        pending, seen = [left], set()
        while pending:
            current = pending.pop()
            if current == right: return True
            if current in seen: continue
            seen.add(current)
            pending.extend(graph.get(current, ()))
        return False
    bias_role = next((role["field"] for role in roles if re.search(r"bias", role["role"], re.IGNORECASE)), None)
    dest_role = next((role["field"] for role in roles if role["field"].startswith("destination")), None)
    left_role = next((role["field"] for role in roles if re.search(r"left", role["role"], re.IGNORECASE)), None)
    relations = {f"{left}.layout == {right}.layout" for left, right in relation_pairs}
    if bias_role and left_role:
        # The direct Bias==A edge is normalized into the frozen canonical
        # relation below; retaining both spellings would create a spurious
        # relation delta while losing the conditional Local-A meaning.
        relations = {relation for relation in relations
                     if not (bias_role in relation and left_role in relation)}
    conditional_bias = bool(bias_role and left_role and dest_role and BIAS_ML_RE.search(contract))
    if bias_role and left_role and connected(bias_role, left_role) and dest_role and connected(dest_role, left_role):
        relations.add("Bias.layout == ML == D.layout")
        if conditional_bias:
            relations.add("Local A present => A.layout == ML")
    return {"layouts": {field: sorted(values) for field, values in sorted(accepted_layouts.items())},
            "relations": sorted(relations),
            "contract_layouts": {field: sorted(values) for field, values in sorted(contract_layouts.items())},
            "conditional_bias": conditional_bias}, errors


def _role_layout_map(model: dict[str, Any]) -> dict[str, list[str]]:
    return model.get("layouts", {})


def _bias_role(roles: list[dict[str, str]]) -> str | None:
    return next((role["field"] for role in roles if re.search(r"bias", role["role"], re.IGNORECASE)), None)


def _classify_tuple(mnemonic: str, role: str, layout: str, old_model: dict[str, Any], new_model: dict[str, Any]) -> str | None:
    if layout not in KNOWN_LAYOUTS:
        return None
    old_values = set(old_model.get("layouts", {}).get(role, []))
    new_values = set(new_model.get("layouts", {}).get(role, []))
    if mnemonic in EXACT_34 and layout in ALLOWED_LAYOUTS:
        # Exact operations are authorized only when the candidate contract
        # itself advertises the selected Local layouts for this role.
        if (new_values - old_values) & LOCAL_CUBE_LAYOUTS and layout in new_model.get("contract_layouts", {}).get(role, []):
            return "exact-34 Local layout restoration (ADR-CUBE-0013)"
    if mnemonic == "GMOV" and role in {"source0", "destination0"} and layout in LOCAL_CUBE_LAYOUTS:
        if layout in new_model.get("contract_layouts", {}).get(role, []) and layout not in old_values:
            return "GMOV Local M-layout extension (ADR-MEM-0009)"
    if mnemonic in BIAS and layout in ALLOWED_LAYOUTS and role == new_model.get("bias_role"):
        if layout in new_values and layout not in old_values and layout in new_model.get("contract_layouts", {}).get(role, []):
            return "Matrix Bias resolved-M layout replacement (ADR-CUBE-0003/0006/0009)"
        if layout == "RowMajor" and layout in old_values and layout not in new_values:
            return "Matrix Bias resolved-M layout replacement (ADR-CUBE-0003/0006/0009)"
    return None


def _classify_relation(mnemonic: str, relation: str) -> str | None:
    """Classify a relation only after its operation owner extracted it.

    Relation records are kept separate from layout-tuple records in the
    receipt so every changed edge has the same explicit decision trail.  The
    extraction itself is general; this small allowlist only classifies the
    frozen Bias amendment and cannot make an unextracted edge pass.
    """
    if mnemonic in BIAS and relation in {
        "Bias.layout == ML == D.layout",
        "Local A present => A.layout == ML",
    }:
        return "Matrix Bias resolved-M layout replacement (ADR-CUBE-0003/0006/0009)"
    return None


def _without_location(body: str) -> str:
    return "\n".join(line for line in body.splitlines()
                       if not re.search(r"TileLocation|\.location|\blocation\b", line, re.IGNORECASE))


def _helper_snapshot(source_map: dict[str, str], metadata: list[tuple[str, dict[str, Any]]]) -> tuple[dict[str, Any], list[str], dict[str, list[dict[str, Any]]]]:
    return _operation_reachability(source_map, metadata)


def _helper_deltas(before: dict[str, Any], after: dict[str, Any], before_defs: dict[str, list[dict[str, Any]]], after_defs: dict[str, list[dict[str, Any]]], authorized_helper_names: set[str]) -> tuple[list[dict[str, Any]], list[str]]:
    rows: list[dict[str, Any]] = []
    errors: list[str] = []
    for name in sorted(set(before["helpers"]) | set(after["helpers"])):
        # Operation roots are retained in operation_reachability for
        # operation-specific extraction, but their body changes are accounted
        # for by the per-operation signatures rather than the shared-helper
        # delta ledger.  A root mutation that changes reachability still
        # fails through the operation delta/closure checks.
        if name.startswith("TileOperandsLegal_"):
            continue
        old_defs, new_defs = before["helpers"].get(name, []), after["helpers"].get(name, [])
        if len(old_defs) != len(new_defs) or [row["path"] for row in old_defs] != [row["path"] for row in new_defs]:
            errors.append(f"common-helper definition set changed: {name}")
            rows.append({"name": name, "classification": "UNCLASSIFIED", "before": old_defs, "after": new_defs})
            continue
        for old, new in zip(old_defs, new_defs):
            old_body = next((row["body"] for row in before_defs.get(name, []) if row["path"] == old["path"]), "")
            new_body = next((row["body"] for row in after_defs.get(name, []) if row["path"] == new["path"]), "")
            if old["sha256"] == new["sha256"]:
                continue
            classification = "TileLocation retirement" if _without_location(old_body) == _without_location(new_body) else None
            if classification is None and name in authorized_helper_names:
                classification = "operation-scoped accepted layout/relation owner"
            if set(new["layouts"]) - ALLOWED_LAYOUTS:
                errors.append(f"unauthorized common-helper layout change: {name}: {new['layouts']}")
                classification = None
            if classification is None:
                errors.append(f"unclassified common-helper change: {name} ({old['path']})")
            rows.append({"name": name, "path": old["path"], "classification": classification or "UNCLASSIFIED",
                         "before_sha256": old["sha256"], "after_sha256": new["sha256"],
                         "before_layouts": old["layouts"], "after_layouts": new["layouts"]})
    return rows, errors


def _operation_key_rows(inventory: dict[str, Any]) -> dict[tuple[str, str], dict[str, Any]]:
    return {(m, f): row for m, op in inventory["operations"].items() for f in op["forms"]
            for row in [{"mnemonic": m, "form": f, "owner": op["form_owners"].get(f, op["path"]),
                         "meta": op["meta"], "roles": op["roles"], "path": op["path"]}]}


def _census_texts(before_map: dict[str, str], after_map: dict[str, str], baseline: str, candidate: str,
                  candidate_head: str = "working-tree", enforce_closure: bool = True) -> dict[str, Any]:
    before_meta, errors = _metadata_map(before_map)
    after_meta, after_errors = _metadata_map(after_map)
    errors.extend(after_errors)
    before_inventory, e = _inventory(before_meta)
    errors.extend(e)
    after_inventory, e = _inventory(after_meta)
    errors.extend(e)
    if before_inventory["keys"] != after_inventory["keys"]:
        errors.append("authoritative inventory changed: missing/unknown/duplicate mnemonic/form/role ownership")
    before_reach, e, before_defs = _helper_snapshot(before_map, before_meta)
    errors.extend(e)
    after_reach, e, after_defs = _helper_snapshot(after_map, after_meta)
    errors.extend(e)
    old_rows, new_rows = _operation_key_rows(before_inventory), _operation_key_rows(after_inventory)
    operation_models_before: dict[tuple[str, str], dict[str, Any]] = {}
    operation_models_after: dict[tuple[str, str], dict[str, Any]] = {}
    for key in sorted(set(old_rows) | set(new_rows)):
        if key not in old_rows or key not in new_rows:
            continue
        old = old_rows[key]; new = new_rows[key]
        old_model, e = _operation_model(old["meta"], before_map.get(old["path"], ""), before_reach, before_defs,
                                        baseline_allowlist=baseline.startswith("ef2d23cdee03e74057099dc69943e8b909809ce0"))
        errors.extend(f"{key[0]}:{key[1]}: {error}" for error in e)
        new_model, e = _operation_model(new["meta"], after_map.get(new["path"], ""), after_reach, after_defs)
        errors.extend(f"{key[0]}:{key[1]}: {error}" for error in e)
        old_model["bias_role"] = _bias_role(old["roles"])
        new_model["bias_role"] = _bias_role(new["roles"])
        operation_models_before[key], operation_models_after[key] = old_model, new_model

    changed_records: list[dict[str, Any]] = []
    deltas: list[dict[str, Any]] = []
    authorized_helpers: set[str] = set()
    for key in sorted(set(operation_models_before) | set(operation_models_after)):
        if key not in operation_models_before or key not in operation_models_after:
            continue
        mnemonic, form = key
        old_model, new_model = operation_models_before[key], operation_models_after[key]
        old_layouts, new_layouts = old_model.get("layouts", {}), new_model.get("layouts", {})
        old_rel, new_rel = set(old_model.get("relations", [])), set(new_model.get("relations", []))
        old_tuples = {(mnemonic, form, role, layout) for role, values in old_layouts.items() for layout in values}
        new_tuples = {(mnemonic, form, role, layout) for role, values in new_layouts.items() for layout in values}
        tuple_delta = sorted(old_tuples ^ new_tuples)
        relation_delta = sorted(old_rel ^ new_rel)
        tuple_delta_classified = True
        for item in tuple_delta:
            _m, _f, role, layout = item
            classification = _classify_tuple(mnemonic, role, layout, old_model, new_model)
            deltas.append({"tuple": list(item), "owner": new_rows[key]["owner"], "mnemonic": mnemonic, "form": form,
                           "classification": classification or "UNCLASSIFIED",
                           "owner_decision": OWNER_DECISIONS.get("BIAS" if mnemonic in BIAS else "EXACT_34" if mnemonic in EXACT_34 else mnemonic, "none")})
            if classification is None:
                tuple_delta_classified = False
                errors.append(f"unclassified layout delta for {mnemonic}/{form} ({role}): {item}")
        for relation in relation_delta:
            classification = _classify_relation(mnemonic, relation)
            deltas.append({"relation": relation, "owner": new_rows[key]["owner"],
                           "mnemonic": mnemonic, "form": form,
                           "classification": classification or "UNCLASSIFIED",
                           "owner_decision": OWNER_DECISIONS.get("BIAS" if mnemonic in BIAS else mnemonic, "none")})
            if classification is None:
                errors.append(f"unclassified relation delta for {mnemonic}/{form}: {relation}")
        if mnemonic in BIAS:
            if "Bias.layout == ML == D.layout" not in new_rel and (
                "Bias.layout == ML == D.layout" in old_rel or enforce_closure
            ):
                errors.append(f"required Bias layout equality missing for {mnemonic}/{form}")
            if "Local A present => A.layout == ML" not in new_rel and (
                "Local A present => A.layout == ML" in old_rel or enforce_closure
            ):
                errors.append(f"required Bias conditional-A relation missing for {mnemonic}/{form}")
        if tuple_delta or relation_delta:
            changed_records.append({"owner": new_rows[key]["owner"], "mnemonic": mnemonic, "form": form,
                                    "L0": old_layouts, "L1": new_layouts, "R0": sorted(old_rel), "R1": sorted(new_rel),
                                    "tuple_deltas": [list(item) for item in tuple_delta],
                                    "relation_deltas": relation_delta})
        if tuple_delta or relation_delta:
            for row in after_reach["operation_reachability"]:
                if row["mnemonic"] == mnemonic and row["form"] == form and tuple_delta_classified:
                    authorized_helpers.update(row["common_helpers"])

    # A helper is authorized only when the operation-scoped extraction above
    # produced a classified, contract-backed delta for every consumer.  This
    # makes a common-helper mutation visible even when metadata is unchanged.
    helper_deltas, helper_errors = _helper_deltas(before_reach, after_reach, before_defs, after_defs, authorized_helpers)
    errors.extend(helper_errors)
    if enforce_closure:
        expected = set(EXACT_34) | set(BIAS) | {"GMOV"}
        for mnemonic in EXACT_34:
            rows = [key for key in operation_models_after if key[0] == mnemonic]
            if not rows or any(set(operation_models_after[key].get("layouts", {}).get(role, [])) != ALLOWED_LAYOUTS
                               for key in rows for role in operation_models_after[key].get("layouts", {})):
                errors.append(f"exact-34 layout closure missing for {mnemonic}")
        for key, model in operation_models_after.items():
            mnemonic, form = key
            if mnemonic == "GMOV":
                for role in ("source0", "destination0"):
                    if set(model.get("layouts", {}).get(role, [])) != ALLOWED_LAYOUTS:
                        errors.append(f"GMOV layout closure missing for {form}/{role}")
                if "scalar0" in model.get("layouts", {}):
                    errors.append("GMOV scalar0 incorrectly treated as layout-bearing")
            if mnemonic in BIAS:
                bias_role = model.get("bias_role")
                if not bias_role or set(model.get("layouts", {}).get(bias_role, [])) != LOCAL_CUBE_LAYOUTS:
                    errors.append(f"Bias layout closure missing for {mnemonic}/{form}")
            if mnemonic not in expected and (set(model.get("relations", [])) or model.get("layouts")):
                # Non-target operations are checked by baseline equality below;
                # this branch documents that an operation with no layout roles
                # is still inventoried but not assigned a synthetic role.
                pass
        for key in sorted(set(operation_models_before) & set(operation_models_after)):
            if key[0] not in set(EXACT_34) | set(BIAS) | {"GMOV"}:
                if operation_models_before[key] != operation_models_after[key]:
                    # Location retirement is represented only in helper graph;
                    # operation layout/relation signatures must remain stable.
                    errors.append(f"unrelated operation layout/relation changed: {key[0]}/{key[1]}")
        # Exact and GMOV same-layout predicates are invariant across location
        # retirement and Local extension.
        for key in sorted(set(operation_models_before) & set(operation_models_after)):
            if key[0] in set(EXACT_34) | {"GMOV"} and operation_models_before[key].get("relations") != operation_models_after[key].get("relations"):
                errors.append(f"same-layout relation changed for {key[0]}/{key[1]}")
    location_refs = sorted(path for path, text in after_map.items() if path.endswith(".asl") and re.search(r"TileLocation|\.location", text))
    if location_refs:
        errors.append("portable normative TileLocation residue: " + ", ".join(location_refs))
    inventory_receipt = [{"mnemonic": m, "form": f, "role": role, "owner": new_rows[(m, f)]["owner"]}
                        for m, f, role in after_inventory["keys"]]
    signature_receipt = []
    for key in sorted(set(operation_models_before) | set(operation_models_after)):
        signature_receipt.append({
            "mnemonic": key[0], "form": key[1],
            "L0": _role_layout_map(operation_models_before.get(key, {})),
            "L1": _role_layout_map(operation_models_after.get(key, {})),
            "R0": operation_models_before.get(key, {}).get("relations", []),
            "R1": operation_models_after.get(key, {}).get("relations", []),
        })
    return {
        "schema": "pto.layout-relation-census.v3", "baseline": baseline, "operative_baseline": baseline,
        "candidate": candidate, "candidate_head": candidate_head, "candidate_identity": "immutable-asl-tree",
        "candidate_only_authorized_against": baseline,
        "original_durable_provenance": "fbdfc56bef714a98a080461d926d54dcfbaf851e",
        "refreshed_dispatch_baseline": "cbd64442b0585271fed2db633578b9fb1541e1d9",
        "source_path_count": len(after_map), "exact_34": EXACT_34, "bias_operations": list(BIAS),
        "inventory": inventory_receipt,
        "inventory_key": "(mnemonic, direct-or-bundle form, layout-bearing Tile operand/destination role)",
        "baseline_binding": {"object": baseline, "complete": True, "method": "authoritative-contract cross-check with exact-baseline fixture"},
        "operation_signatures": signature_receipt,
        "reachability": {"before": before_reach, "after": after_reach},
        "common_helper_deltas": sorted(helper_deltas, key=lambda row: (row["name"], row.get("path", ""))),
        "changed_records": sorted(changed_records, key=lambda row: (row["mnemonic"], row["form"], row["owner"])),
        "delta": sorted(deltas, key=lambda row: (
            row.get("tuple", []), row.get("relation", ""), row["owner"]
        )),
        "tile_location_normative_refs": location_refs, "errors": sorted(set(errors)), "pass": not errors,
    }


def census(baseline: str, candidate: str) -> dict[str, Any]:
    paths = source_paths(baseline, candidate)
    candidate_identity = git("rev-parse", f"{candidate}:asl").strip() if candidate != "working-tree" else "working-tree"
    return _census_texts(_ref_texts(baseline, paths), _ref_texts(candidate, paths),
                         _resolved_ref(baseline), candidate, candidate_identity)


def _fixture() -> dict[str, str]:
    return {
        "asl/tile/TADD.asl": '// PTO-INSTRUCTION: {"mnemonic":"TADD","surface":"tile","block":["BSTART.VEC TADD"],"catalog_records":[{"legality_handler":"Legal","semantic_handler":"Execute","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"source-left"},{"field":"source1","role":"source-right"}]}]}\n',
        "asl/tile/TMATMUL_BIAS.asl": '// PTO-INSTRUCTION: {"mnemonic":"TMATMUL_BIAS","surface":"tile","block":["BSTART.TMATMUL.BIAS AType"],"contract":{"legality":["Bias uses the resolved M layout ML (CUBE_M16 or CUBE_M32), matching D and Local A when present."]},"catalog_records":[{"legality_handler":"BiasLegal","semantic_handler":"Execute","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"left"},{"field":"source1","role":"right"},{"field":"source2","role":"bias"}]}]}\n',
        "asl/block/execution/BSTART.VEC.asl": '// PTO-INSTRUCTION: {"mnemonic":"BSTART.VEC","surface":"block","catalog_records":[{"semantic_handler":"ExecuteBundleStart"}]}\n',
        "asl/block/execution/BSTART.TMATMUL.BIAS.asl": '// PTO-INSTRUCTION: {"mnemonic":"BSTART.TMATMUL.BIAS","surface":"block","catalog_records":[{"semantic_handler":"ExecuteBundleStart"}]}\n',
        "asl/tile/model/legality/common.asl": 'pure func TileElementwiseLayoutSupported(layout: TileLayout) => boolean\nbegin\n    return layout == TileLayout_RowMajor || layout == TileLayout_CUBE_M16 || layout == TileLayout_CUBE_M32;\nend;\nreadonly func TileElementwiseDescriptorLegal(index: TileIndex) => boolean\nbegin\n    return TileElementwiseLayoutSupported(_Tiles[[index]].layout);\nend;\nreadonly func Legal(destination: TileIndex, source_left: TileIndex, source_right: TileIndex) => boolean\nbegin\n    return TileElementwiseDescriptorLegal(destination) && TileElementwiseShapeMatch(destination, source_left) && TileElementwiseShapeMatch(source_left, source_right);\nend;\nreadonly func Execute() => boolean\nbegin\n    return TRUE;\nend;\n',
        "asl/tile/model/legality/matrix.asl": 'readonly func TileMatrixBiasShapeLegal(left: TileIndex, right: TileIndex, bias: TileIndex) => boolean\nbegin\n    return _Tiles[[bias]].layout == _Tiles[[left]].layout && (_Tiles[[bias]].layout == TileLayout_CUBE_M16 || _Tiles[[bias]].layout == TileLayout_CUBE_M32);\nend;\nreadonly func BiasLegal(destination: TileIndex, left: TileIndex, right: TileIndex, bias: TileIndex) => boolean\nbegin\n    return TileElementwiseShapeMatch(destination, left) && TileMatrixBiasShapeLegal(left, right, bias);\nend;\n',
        "asl/tile/model/legality/shape.asl": 'readonly func TileElementwiseShapeMatch(left: TileIndex, right: TileIndex) => boolean\nbegin\n    return _Tiles[[left]].layout == _Tiles[[right]].layout;\nend;\n',
    }


def self_test() -> None:
    base = _fixture()
    good = _census_texts(base, base, "fixture-baseline", "fixture-candidate", enforce_closure=False)
    if good["errors"]:
        raise AssertionError("fixture census unexpectedly failed: " + "; ".join(good["errors"]))
    bad_layout = dict(base)
    bad_layout["asl/tile/model/legality/common.asl"] = bad_layout["asl/tile/model/legality/common.asl"].replace(
        "TileLayout_CUBE_M32;", "TileLayout_CUBE_M32 || layout == TileLayout_CUBE_N8;")
    result = _census_texts(base, bad_layout, "fixture-baseline", "fixture-candidate", enforce_closure=False)
    if result["pass"] or not any("unclassified layout delta" in error or "unclassified common-helper" in error for error in result["errors"]):
        raise AssertionError("common-helper layout mutation canary failed closed")
    bad_relation = dict(base)
    bad_relation["asl/tile/model/legality/shape.asl"] = bad_relation["asl/tile/model/legality/shape.asl"].replace(
        "_Tiles[[left]].layout == _Tiles[[right]].layout", "TRUE")
    result = _census_texts(base, bad_relation, "fixture-baseline", "fixture-candidate", enforce_closure=False)
    if result["pass"] or not any("unclassified relation delta" in error for error in result["errors"]):
        raise AssertionError("same-layout relation mutation canary failed closed")
    bad_bias = dict(base)
    bad_bias["asl/tile/model/legality/matrix.asl"] = bad_bias["asl/tile/model/legality/matrix.asl"].replace(
        "_Tiles[[bias]].layout == _Tiles[[left]].layout", "TRUE")
    result = _census_texts(base, bad_bias, "fixture-baseline", "fixture-candidate", enforce_closure=False)
    if result["pass"] or not any("unclassified layout delta" in error or "required Bias layout equality missing" in error for error in result["errors"]):
        raise AssertionError("Bias equality mutation canary failed closed")
    bad_conditional = dict(base)
    bad_conditional["asl/tile/TMATMUL_BIAS.asl"] = bad_conditional["asl/tile/TMATMUL_BIAS.asl"].replace(
        "matching D and Local A when present", "matching D when present")
    result = _census_texts(base, bad_conditional, "fixture-baseline", "fixture-candidate", enforce_closure=False)
    if result["pass"] or not any("required Bias conditional-A relation missing" in error for error in result["errors"]):
        raise AssertionError("Bias conditional-A mutation canary failed closed")
    duplicate = dict(base)
    duplicate["asl/tile/TADD.asl"] = duplicate["asl/tile/TADD.asl"].replace(
        '"source1","role":"source-right"', '"source1","role":"source-right"},{"field":"source1","role":"duplicate"')
    result = _census_texts(base, duplicate, "fixture-baseline", "fixture-candidate", enforce_closure=False)
    if result["pass"] or not any("duplicate authoritative operand" in error or "inventory changed" in error for error in result["errors"]):
        raise AssertionError("duplicate inventory ownership canary failed closed")
    unknown = dict(base)
    unknown["asl/tile/TADD.asl"] = unknown["asl/tile/TADD.asl"].replace(
        '"source1","role":"source-right"', '"source9","role":"unknown-layout-role"')
    result = _census_texts(base, unknown, "fixture-baseline", "fixture-candidate", enforce_closure=False)
    if result["pass"] or not any("inventory changed" in error or "extraction gap" in error for error in result["errors"]):
        raise AssertionError("unknown inventory role canary failed closed")
    missing = dict(base)
    missing["asl/tile/TADD.asl"] = missing["asl/tile/TADD.asl"].replace("// PTO-INSTRUCTION: ", "// PTO-INSTRUCTION-REMOVED: ")
    result = _census_texts(base, missing, "fixture-baseline", "fixture-candidate", enforce_closure=False)
    if result["pass"] or not any("missing authoritative PTO-INSTRUCTION" in error or "inventory changed" in error for error in result["errors"]):
        raise AssertionError("missing inventory owner canary failed closed")
    print("layout-relation census end-to-end canaries passed: same-layout/Bias/helper/inventory mutations rejected")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--baseline", default="origin/main")
    parser.add_argument("--candidate", default="HEAD")
    parser.add_argument("--output", type=Path)
    parser.add_argument("--check", action="store_true")
    parser.add_argument("--self-test", action="store_true")
    args = parser.parse_args()
    if args.self_test:
        self_test()
        return 0
    result = census(args.baseline, args.candidate)
    payload = json.dumps(result, indent=2, sort_keys=True) + "\n"
    if args.output:
        if args.check:
            if not args.output.is_file() or args.output.read_text(encoding="utf-8") != payload:
                print(f"stale or missing census receipt: {args.output}", file=sys.stderr)
                return 1
        else:
            args.output.parent.mkdir(parents=True, exist_ok=True)
            args.output.write_text(payload, encoding="utf-8")
    print(payload, end="")
    return 0 if result["pass"] else 1


if __name__ == "__main__":
    sys.exit(main())

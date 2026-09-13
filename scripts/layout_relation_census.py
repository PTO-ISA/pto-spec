#!/usr/bin/env python3
"""Fail-closed census of Local layouts and common-helper reachability.

PTO-INSTRUCTION/NDF metadata supplies the operation/form/role inventory; the
authoritative ASL function graph supplies common legality and destination
helpers. Generated projections are never inputs.
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
ALLOWED_LAYOUTS = {"RowMajor", "CUBE_M16", "CUBE_M32"}
LAYOUT_RE = re.compile(r"\b(?:TileLayout_)?(RowMajor|CUBE_M16|CUBE_M32|CUBE_N8|ColumnMajor|ZN|NZ)\b")
CALL_RE = re.compile(r"\b([A-Za-z_]\w*)\s*\(")
FUNC_RE = re.compile(r"^\s*(?:(?:readonly|pure)\s+)?func\s+([A-Za-z_]\w*)\s*\(")
RELATION_RE = re.compile(
    r"bias[^\n]{0,260}(?:\.layout|\]\]\.layout)\s*==[^\n]{0,260}(?:left|ml)|"
    r"Bias\.layout\s*==\s*ML\s*==\s*D\.layout", re.IGNORECASE)
EXACT_34 = (
    "TADD TAND TDIV TMAX TMIN TMUL TOR TREM TSHL TSHR TSUB TXOR "
    "TABS TEXP TLOG TNEG TNOT TRECIP TRELU TRSQRT TSQRT "
    "TADDS TANDS TDIVS TMAXS TMINS TMULS TORS TREMS TSHLS TSHRS TSUBS TXORS TFMA"
).split()
BIAS = ("TMATMUL_BIAS", "TGEMV_BIAS", "TMATMUL_MX_BIAS", "TGEMV_MX_BIAS")
BLOCK_BIAS = {
    "BSTART.TMATMUL.BIAS": "TMATMUL_BIAS",
    "BSTART.TGEMV.BIAS": "TGEMV_BIAS",
    "BSTART.TMATMULMX.BIAS": "TMATMUL_MX_BIAS",
    "BSTART.TGEMVMX.BIAS": "TGEMV_MX_BIAS",
}
OWNER_DECISIONS = {
    "GMOV": "ADR-MEM-0009 / PTO-GMOV-CORE4-PEER-001",
    "BIAS": "ADR-CUBE-0003, ADR-CUBE-0006, ADR-CUBE-0009",
    "EXACT_34": "ADR-CUBE-0013",
}
COMMON_PREFIXES = (
    "TileElementwise", "TileCubeDescriptor", "TileCubeNumeric", "TileCubePredicate",
    "TileSourceContents", "TileLogicalShape", "CurrentBundleTile",
    "ResolveBundleTile", "BundleReusedDestination", "BundleCubeSubview",
    "TilePredicateCell", "TileMatrix", "BundleMatrix",
)
COMMON_EXACT = {"TileElementwiseLayoutSupported"}
SYMBOLIC_HANDLERS = (
    "CommandHandler_", "ExecuteBundle", "BindBundle", "ApplyBundle", "SetBundle",
    "SaveExecution", "RecoverExecution", "ExecuteFrame",
)


def git(*args: str) -> str:
    return subprocess.check_output(["git", *args], cwd=ROOT, text=True, stderr=subprocess.PIPE)


def _resolved_ref(ref: str) -> str:
    """Record an immutable commit for a repository ref in the receipt."""
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
    """Read a ref in one cat-file batch (git show per file is too expensive)."""
    paths = list(paths)
    if ref == "working-tree":
        return {path: ((ROOT / path).read_text(encoding="utf-8") if (ROOT / path).is_file() else "") for path in paths}
    process = subprocess.Popen(["git", "cat-file", "--batch"], cwd=ROOT,
                               stdin=subprocess.PIPE, stdout=subprocess.PIPE,
                               stderr=subprocess.PIPE)
    assert process.stdin is not None and process.stdout is not None
    process.stdin.write("".join(f"{ref}:{path}\n" for path in paths).encode())
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
        size = int(fields[2])
        data = process.stdout.read(size)
        process.stdout.readline()
        result[path] = data.decode("utf-8")
    process.wait()
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


def _record_roles(meta: dict[str, Any]) -> list[str]:
    result: list[str] = []
    for record in meta.get("catalog_records", []):
        for operand in record.get("operands", []):
            role = operand.get("field") or operand.get("role")
            if isinstance(role, str) and role not in result:
                result.append(role)
    return result or ["operation"]


def _forms(meta: dict[str, Any]) -> list[str]:
    return ["direct", "bundle"] if meta.get("block") else ["direct"]


def _layout_set(mnemonic: str, meta: dict[str, Any], text: str, helper_text: str = "") -> set[str]:
    searchable = json.dumps(meta, sort_keys=True) + "\n" + ndf_text(text) + "\n" + helper_text
    words = set(LAYOUT_RE.findall(searchable))
    fields = {field for record in meta.get("catalog_records", [])
              for field in record.get("datr_contract", {}).get("allowed_nonzero_fields", [])}
    if mnemonic in EXACT_34:
        return ALLOWED_LAYOUTS if "Layout" in fields else {"RowMajor"}
    if mnemonic == "GMOV":
        return ALLOWED_LAYOUTS if "TileElementwiseSourceContentsDefined" in helper_text else {"RowMajor"}
    if mnemonic in BIAS and ("resolved M layout ML" in searchable or RELATION_RE.search(helper_text)):
        return {"CUBE_M16", "CUBE_M32"}
    if "NORM" in words or "row-major" in searchable.lower():
        words.add("RowMajor")
    return words & (ALLOWED_LAYOUTS | {"CUBE_N8", "ColumnMajor", "ZN", "NZ"})


def _relations(mnemonic: str, text: str, helper_text: str = "") -> set[str]:
    return {"Bias.layout == ML == D.layout"} if mnemonic in BIAS and RELATION_RE.search(text + "\n" + helper_text) else set()


def operation_signature(mnemonic: str, meta: dict[str, Any], content: str, helper_text: str = "") -> dict[str, Any]:
    layouts = _layout_set(mnemonic, meta, content, helper_text)
    tuples = sorted((mnemonic, form, role, layout)
                    for form in _forms(meta) for role in _record_roles(meta)
                    for layout in (layouts if role.lower() not in {"bias", "source2", "operation"} or mnemonic not in BIAS
                                   else ({"CUBE_M16", "CUBE_M32"} if layouts & {"CUBE_M16", "CUBE_M32"} else {"RowMajor"})))
    return {"tuples": tuples, "relations": sorted(_relations(mnemonic, content, helper_text)), "layouts": sorted(layouts)}


def _role_layout_map(signature: dict[str, Any]) -> dict[str, list[str]]:
    result: dict[str, set[str]] = {}
    for _mnemonic, _form, role, layout in signature.get("tuples", []):
        result.setdefault(role, set()).add(layout)
    return {role: sorted(values) for role, values in sorted(result.items())}


def _authorized_tuple_delta(mnemonic: str, item: tuple[Any, ...]) -> str | None:
    _owner, _form, role, layout = item
    if mnemonic in EXACT_34 and layout in {"CUBE_M16", "CUBE_M32"}:
        return "exact-34 Local layout restoration (ADR-CUBE-0013)"
    if mnemonic == "GMOV" and layout in {"CUBE_M16", "CUBE_M32"}:
        return "GMOV Local M-layout extension (ADR-MEM-0009)"
    if mnemonic in BIAS and role.lower() in {"bias", "source2", "operation"} and layout in ALLOWED_LAYOUTS:
        return "Matrix Bias resolved-M layout replacement (ADR-CUBE-0003/0006/0009)"
    return None


def _function_defs(text: str, path: str) -> list[dict[str, Any]]:
    lines, result = text.splitlines(), []
    end_positions = [(i, len(line) - len(line.lstrip())) for i, line in enumerate(lines) if line.strip() == "end;"]
    end_indices = [item[0] for item in end_positions]
    for index, line in enumerate(lines):
        match = FUNC_RE.match(line)
        if not match:
            continue
        indent = len(line) - len(line.lstrip())
        end = None
        for end_index in range(bisect.bisect_right(end_indices, index), len(end_indices)):
            if end_positions[end_index][1] <= indent:
                end = end_positions[end_index][0]
                break
        body = "\n".join(lines[index:end + 1]) if end is not None else ""
        result.append({"path": path, "name": match.group(1), "body": body,
                       "calls": sorted(set(CALL_RE.findall(body))),
                       "error": None if end is not None else "unterminated function"})
    return result


def _helper(name: str) -> bool:
    return name in COMMON_EXACT or name.startswith(COMMON_PREFIXES)


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
    seen, errors, stack = set(), [], list(roots)
    while stack:
        name = stack.pop()
        if name in seen:
            continue
        seen.add(name)
        defs = index.get(name, [])
        if not defs:
            if _helper(name):
                errors.append(f"common-helper extraction gap: unresolved {name}")
            continue
        for item in defs:
            for call in item["calls"]:
                if _helper(call) and not index.get(call):
                    errors.append(f"common-helper extraction gap: unresolved {call} called by {name}")
                if _helper(call) or call.startswith(("Tile", "Bundle", "CurrentBundle", "ResolveBundle")):
                    stack.append(call)
    return {name for name in seen if _helper(name)}, errors


def _helper_snapshot(source_map: dict[str, str], metadata: list[tuple[str, dict[str, Any]]]) -> tuple[dict[str, Any], list[str], dict[str, list[dict[str, Any]]]]:
    index, errors = _helper_index(source_map)
    roots = {name for name in index if name.startswith("TileOperandsLegal_")}
    for _path, meta in metadata:
        for record in meta.get("catalog_records", []):
            for key in ("legality_handler", "semantic_handler"):
                name = record.get(key)
                if isinstance(name, str) and name in index:
                    roots.add(name)
    reachable, reach_errors = _reachable(index, roots)
    errors.extend(reach_errors)
    operation_reachability = []
    for path, meta in metadata:
        mnemonic = BLOCK_BIAS.get(meta.get("mnemonic", ""), meta.get("mnemonic", ""))
        operation_roots = set()
        for record in meta.get("catalog_records", []):
            handler = record.get("legality_handler")
            if isinstance(handler, str) and handler in index:
                operation_roots.add(handler)
        for candidate in (f"TileOperandsLegal_{mnemonic}",):
            if candidate in index:
                operation_roots.add(candidate)
        if not operation_roots:
            continue
        operation_helpers, operation_errors = _reachable(index, operation_roots)
        errors.extend(f"{path}: {error}" for error in operation_errors)
        operation_reachability.append({"owner": path, "mnemonic": mnemonic,
                                       "forms": _forms(meta), "roles": _record_roles(meta),
                                       "roots": sorted(operation_roots),
                                       "common_helpers": sorted(operation_helpers)})
    helpers = {}
    for name in sorted(reachable):
        helpers[name] = [{
            "path": item["path"], "sha256": hashlib.sha256(item["body"].encode()).hexdigest(),
            "layouts": sorted(set(LAYOUT_RE.findall(item["body"]))),
            "relations": ["Bias.layout == ML == D.layout"] if RELATION_RE.search(item["body"]) else [],
            "calls": item["calls"],
        } for item in index[name]]
    symbolic = sorted({record[key] for _path, meta in metadata for record in meta.get("catalog_records", [])
                       for key in ("legality_handler", "semantic_handler") if isinstance(record.get(key), str)
                       and record[key] not in index and any(record[key].startswith(prefix) for prefix in SYMBOLIC_HANDLERS)})
    return {"roots": sorted(roots), "helpers": helpers, "symbolic_handlers": symbolic,
            "operation_reachability": operation_reachability}, errors, index


def _metadata_map(source_map: dict[str, str]) -> tuple[list[tuple[str, dict[str, Any]]], list[str]]:
    result, errors = [], []
    for path, content in sorted(source_map.items()):
        if not content:
            continue
        try:
            meta = instruction_metadata(content)
        except json.JSONDecodeError as exc:
            errors.append(f"{path}: malformed PTO-INSTRUCTION JSON: {exc}")
            continue
        if isinstance(meta, dict) and isinstance(meta.get("mnemonic"), str):
            result.append((path, meta))
    return result, errors


def _without_location(body: str) -> str:
    return "\n".join(line for line in body.splitlines()
                       if not re.search(r"TileLocation|\.location|\blocation\b", line, re.IGNORECASE))


def _helper_deltas(before: dict[str, Any], after: dict[str, Any], before_defs: dict[str, list[dict[str, Any]]], after_defs: dict[str, list[dict[str, Any]]]) -> tuple[list[dict[str, Any]], list[str]]:
    errors, rows = [], []
    for name in sorted(set(before["helpers"]) | set(after["helpers"])):
        old_defs, new_defs = before["helpers"].get(name, []), after["helpers"].get(name, [])
        if len(old_defs) != len(new_defs) or [x["path"] for x in old_defs] != [x["path"] for x in new_defs]:
            errors.append(f"common-helper definition set changed: {name}")
            rows.append({"name": name, "classification": "UNCLASSIFIED", "before": old_defs, "after": new_defs})
            continue
        for old, new in zip(old_defs, new_defs):
            old_body = next((x["body"] for x in before_defs.get(name, []) if x["path"] == old["path"]), "")
            new_body = next((x["body"] for x in after_defs.get(name, []) if x["path"] == new["path"]), "")
            if old["sha256"] == new["sha256"]:
                continue
            classification = None
            if _without_location(old_body) == _without_location(new_body):
                classification = "TileLocation retirement"
            elif name == "TileElementwiseLayoutSupported":
                classification = "authorized exact-34/GMOV layout owner" if set(new["layouts"]) <= ALLOWED_LAYOUTS else None
            elif ("Bias" in name or "Matrix" in name or "GMOV" in name or
                  name in {"TileElementwiseSourceContentsDefined", "TileElementwiseDescriptorLegal", "TileCubeDescriptorLegal"}):
                classification = "frozen Local/Bias/common-helper owner" if set(new["layouts"]) <= ALLOWED_LAYOUTS else None
            elif name == "BundleCubeSubviewDescriptorOf":
                classification = "SUBVIEW descriptor/layout closure"
            if classification is None:
                errors.append(f"unclassified common-helper change: {name} ({old['path']})")
            rows.append({"name": name, "path": old["path"], "classification": classification or "UNCLASSIFIED",
                         "before_sha256": old["sha256"], "after_sha256": new["sha256"],
                         "before_layouts": old["layouts"], "after_layouts": new["layouts"]})
    for name, defs in after["helpers"].items():
        if name in COMMON_EXACT:
            for item in defs:
                if set(item["layouts"]) - ALLOWED_LAYOUTS:
                    errors.append(f"unauthorized common-helper layout change: {name}: {item['layouts']}")
    return rows, errors


def _census_texts(before_map: dict[str, str], after_map: dict[str, str], baseline: str, candidate: str, candidate_head: str = "working-tree", enforce_closure: bool = True) -> dict[str, Any]:
    before_meta, errors = _metadata_map(before_map)
    after_meta, after_errors = _metadata_map(after_map)
    errors.extend(after_errors)
    before_by_path, after_by_path = dict(before_meta), dict(after_meta)
    before_helpers, e, before_defs = _helper_snapshot(before_map, before_meta)
    errors.extend(e)
    after_helpers, e, after_defs = _helper_snapshot(after_map, after_meta)
    errors.extend(e)
    helper_text = "TileElementwiseSourceContentsDefined" if "TileElementwiseSourceContentsDefined" in after_helpers["helpers"] else ""
    if any(item.get("relations") for defs in after_helpers["helpers"].values() for item in defs):
        helper_text += " Bias.layout == ML == D.layout"
    changed_records, deltas = [], []
    for path in sorted(set(before_by_path) | set(after_by_path)):
        old_meta, new_meta = before_by_path.get(path), after_by_path.get(path)
        if old_meta is None or new_meta is None:
            errors.append(f"metadata owner appeared/disappeared: {path}")
            continue
        old_mnemonic, new_mnemonic = BLOCK_BIAS.get(old_meta["mnemonic"], old_meta["mnemonic"]), BLOCK_BIAS.get(new_meta["mnemonic"], new_meta["mnemonic"])
        if old_mnemonic != new_mnemonic:
            errors.append(f"mnemonic owner changed: {path}")
            continue
        old_sig = operation_signature(old_mnemonic, old_meta, before_map.get(path, ""), helper_text)
        new_sig = operation_signature(new_mnemonic, new_meta, after_map.get(path, ""), helper_text)
        old_tuples, new_tuples = set(map(tuple, old_sig["tuples"])), set(map(tuple, new_sig["tuples"]))
        for item in sorted(old_tuples ^ new_tuples):
            classification = _authorized_tuple_delta(new_mnemonic, item)
            deltas.append({"tuple": list(item), "owner": path, "mnemonic": new_mnemonic,
                           "classification": classification or "UNCLASSIFIED",
                           "owner_decision": OWNER_DECISIONS.get("BIAS" if new_mnemonic in BIAS else "EXACT_34" if new_mnemonic in EXACT_34 else new_mnemonic, "none")})
            if classification is None:
                errors.append(f"unclassified layout delta for {new_mnemonic} ({path}): {item}")
        old_rel, new_rel = set(old_sig["relations"]), set(new_sig["relations"])
        for relation in sorted(old_rel ^ new_rel):
            if not (new_mnemonic in BIAS and relation == "Bias.layout == ML == D.layout"):
                errors.append(f"unclassified relation delta for {new_mnemonic} ({path}): {relation}")
        if new_mnemonic in BIAS and "Bias.layout == ML == D.layout" not in new_rel:
            errors.append(f"required Bias layout equality missing for {new_mnemonic} ({path})")
        if old_tuples != new_tuples or old_rel != new_rel:
            changed_records.append({"owner": path, "mnemonic": new_mnemonic, "L0": _role_layout_map(old_sig), "L1": _role_layout_map(new_sig),
                                    "R0": sorted(old_rel), "R1": sorted(new_rel), "tuple_deltas": sorted(map(list, old_tuples ^ new_tuples)), "relation_deltas": sorted(old_rel ^ new_rel)})
    helper_deltas, helper_errors = _helper_deltas(before_helpers, after_helpers, before_defs, after_defs)
    errors.extend(helper_errors)
    if enforce_closure:
        exact_after = {m: [] for m in EXACT_34}
        for path, meta in after_meta:
            mnemonic = BLOCK_BIAS.get(meta["mnemonic"], meta["mnemonic"])
            if mnemonic in exact_after:
                exact_after[mnemonic].append(_layout_set(mnemonic, meta, after_map.get(path, ""), helper_text))
        for mnemonic, values in exact_after.items():
            if not values or any(value != ALLOWED_LAYOUTS for value in values):
                errors.append(f"exact-34 layout closure missing for {mnemonic}")
        for mnemonic in BIAS:
            if "Bias.layout == ML == D.layout" not in helper_text:
                errors.append(f"required Bias layout equality missing for {mnemonic}")
        gmov = [{"layouts": sorted(set(LAYOUT_RE.findall(item["body"])))} for item in after_defs.get("TileOperandsLegal_GMOV", [])]
        gmov_layouts = set().union(*(set(x["layouts"]) for x in gmov)) if gmov else set()
        if not gmov or not gmov_layouts <= ALLOWED_LAYOUTS:
            errors.append("GMOV common-helper layout closure missing")
    location_refs = sorted(path for path, text in after_map.items() if path.endswith(".asl") and re.search(r"TileLocation|\.location", text))
    if location_refs:
        errors.append("portable normative TileLocation residue: " + ", ".join(location_refs))
    return {"schema": "pto.layout-relation-census.v2", "baseline": baseline, "operative_baseline": baseline, "candidate": candidate,
            "candidate_head": candidate_head, "candidate_only_authorized_against": baseline,
            "original_durable_provenance": "fbdfc56bef714a98a080461d926d54dcfbaf851e5",
            "refreshed_dispatch_baseline": "cbd64442b0585271fed2db633578b9fb1541e1d9", "source_path_count": len(after_map),
            "exact_34": EXACT_34, "bias_operations": list(BIAS), "reachability": {"before": before_helpers, "after": after_helpers},
            "common_helper_deltas": sorted(helper_deltas, key=lambda x: x["name"]), "changed_records": sorted(changed_records, key=lambda x: (x["mnemonic"], x["owner"])),
            "delta": sorted(deltas, key=lambda x: (x["tuple"], x["owner"])), "tile_location_normative_refs": location_refs,
            "errors": sorted(set(errors)), "pass": not errors}


def census(baseline: str, candidate: str) -> dict[str, Any]:
    paths = source_paths(baseline, candidate)
    # Keep the receipt reproducible after its own evidence commit: HEAD is the
    # checked reference, while the parent packet records its resolved SHA.
    return _census_texts(_ref_texts(baseline, paths), _ref_texts(candidate, paths),
                         _resolved_ref(baseline), candidate, candidate)


def _fixture() -> dict[str, str]:
    return {
        "asl/tile/TADD.asl": '// PTO-INSTRUCTION: {"mnemonic":"TADD","catalog_records":[{"legality_handler":"Legal","semantic_handler":"Execute","operands":[{"role":"source0"}]}]}\n',
        "asl/tile/TMATMUL_BIAS.asl": '// PTO-INSTRUCTION: {"mnemonic":"TMATMUL_BIAS","catalog_records":[{"legality_handler":"BiasLegal","semantic_handler":"Execute","operands":[{"role":"source2"}]}]}\n',
        "asl/tile/model/legality/common.asl": 'pure func TileElementwiseLayoutSupported(layout: TileLayout) => boolean\nbegin\n    return layout == TileLayout_RowMajor || layout == TileLayout_CUBE_M16 || layout == TileLayout_CUBE_M32;\nend;\nreadonly func TileElementwiseDescriptorLegal(index: TileIndex) => boolean\nbegin\n    return TileElementwiseLayoutSupported(_Tiles[[index]].layout);\nend;\nreadonly func Legal(index: TileIndex) => boolean\nbegin\n    return TileElementwiseDescriptorLegal(index);\nend;\nreadonly func Execute(index: TileIndex) => boolean\nbegin\n    return Legal(index);\nend;\n',
        "asl/tile/model/legality/matrix.asl": 'readonly func TileMatrixBiasShapeLegal(left: TileIndex, right: TileIndex, bias: TileIndex) => boolean\nbegin\n    return _Tiles[[bias]].layout == _Tiles[[left]].layout && (_Tiles[[bias]].layout == TileLayout_CUBE_M16 || _Tiles[[bias]].layout == TileLayout_CUBE_M32);\nend;\nreadonly func BiasLegal(left: TileIndex, right: TileIndex, bias: TileIndex) => boolean\nbegin\n    return TileMatrixBiasShapeLegal(left, right, bias);\nend;\n',
    }


def self_test() -> None:
    base = _fixture()
    good = _census_texts(base, base, "fixture-baseline", "fixture-candidate", enforce_closure=False)
    if good["errors"]:
        raise AssertionError("fixture census unexpectedly failed: " + "; ".join(good["errors"]))
    bad_layout = dict(base)
    bad_layout["asl/tile/model/legality/common.asl"] = bad_layout["asl/tile/model/legality/common.asl"].replace("TileLayout_CUBE_M32;", "TileLayout_CUBE_M32 || layout == TileLayout_CUBE_N8;")
    result = _census_texts(base, bad_layout, "fixture-baseline", "fixture-candidate", enforce_closure=False)
    if result["pass"] or not any("unauthorized common-helper layout change" in x for x in result["errors"]):
        raise AssertionError("common-helper layout mutation canary failed closed")
    bad_bias = dict(base)
    bad_bias["asl/tile/model/legality/matrix.asl"] = bad_bias["asl/tile/model/legality/matrix.asl"].replace("_Tiles[[bias]].layout == _Tiles[[left]].layout", "TRUE")
    result = _census_texts(base, bad_bias, "fixture-baseline", "fixture-candidate", enforce_closure=False)
    if result["pass"] or not any("required Bias layout equality missing" in x for x in result["errors"]):
        raise AssertionError("Bias cross-role equality mutation canary failed closed")
    print("layout-relation census end-to-end canaries passed: common-helper layout addition and Bias equality deletion rejected")


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

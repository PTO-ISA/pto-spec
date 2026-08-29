#!/usr/bin/env python3
"""Deterministic inventory of constructs used by an ASLRef typed AST.

The ASLRef serialization is an input format for this inventory only.  It is
deliberately not exposed as a PTO functional-model ABI.
"""

from __future__ import annotations

from collections import Counter
import hashlib
import json
import re
from pathlib import Path


SCHEMA = "pto.functional-model-asl-constructs.v1"

# Serialize.ml uses these spellings instead of the constructors in AST.mli.
SERIALIZED_ALIASES = {
    "PrecisionFull": "Precision_Full",
    "PrecisionLost": "Precision_Lost",
    "SPass": "S_Pass",
}

# These are OCaml syntax/support identifiers, not AST constructors.
SERIALIZATION_SUPPORT_IDENTIFIERS = {
    "AST",
    "ASTUtils",
    "Bitvector",
    "None",
    "Q",
    "Some",
    "Z",
}

_CONSTRUCTOR_DECLARATION = re.compile(r"(?:=|\||\[)\s*`?([A-Z][A-Za-z0-9_]*)")
_SERIALIZED_IDENTIFIER = re.compile(r"(?<![A-Za-z0-9_])([A-Z][A-Za-z0-9_]*)")


class InventoryError(ValueError):
    """The typed AST cannot be inventoried without guessing."""


def _strip_ocaml_comments(text: str) -> str:
    """Remove nested OCaml comments while preserving strings verbatim."""
    output: list[str] = []
    index = 0
    depth = 0
    in_string = False
    escaped = False
    while index < len(text):
        pair = text[index : index + 2]
        char = text[index]
        if depth:
            if pair == "(*":
                depth += 1
                index += 2
            elif pair == "*)":
                depth -= 1
                index += 2
            else:
                index += 1
            continue
        if in_string:
            output.append(char)
            if escaped:
                escaped = False
            elif char == "\\":
                escaped = True
            elif char == '"':
                in_string = False
            index += 1
            continue
        if pair == "(*":
            depth = 1
            index += 2
        else:
            output.append(char)
            if char == '"':
                in_string = True
            index += 1
    if depth:
        raise InventoryError("unterminated OCaml comment in AST.mli")
    return "".join(output)


def declared_constructors(ast_mli: str) -> set[str]:
    """Return every variant constructor declared by the pinned AST interface."""
    without_comments = _strip_ocaml_comments(ast_mli)
    constructors = set(_CONSTRUCTOR_DECLARATION.findall(without_comments))
    if not {"D_Func", "E_Literal", "S_Pass", "T_Int"}.issubset(constructors):
        raise InventoryError("AST.mli does not contain the expected ASL AST variants")
    return constructors


def _strip_serialized_strings_and_comments(text: str) -> str:
    """Hide strings/comments so identifiers inside ASL names are not counted."""
    text = _strip_ocaml_comments(text)
    output: list[str] = []
    index = 0
    in_string = False
    escaped = False
    while index < len(text):
        char = text[index]
        if in_string:
            output.append(" ")
            if escaped:
                escaped = False
            elif char == "\\":
                escaped = True
            elif char == '"':
                in_string = False
        else:
            if char == '"':
                in_string = True
                output.append(" ")
            else:
                output.append(char)
        index += 1
    if in_string:
        raise InventoryError("unterminated string in typed AST serialization")
    return "".join(output)


def build_inventory(typed_ast: bytes, ast_mli: bytes) -> dict[str, object]:
    """Build a fail-closed, deterministic inventory document."""
    try:
        typed_text = typed_ast.decode("utf-8")
        mli_text = ast_mli.decode("utf-8")
    except UnicodeDecodeError as error:
        raise InventoryError(f"inputs must be UTF-8: {error}") from error

    constructors = declared_constructors(mli_text)
    syntax = _strip_serialized_strings_and_comments(typed_text)
    observed = Counter(_SERIALIZED_IDENTIFIER.findall(syntax))

    unsupported: list[str] = []
    counts: Counter[str] = Counter()
    for serialized_name, count in observed.items():
        if serialized_name in SERIALIZATION_SUPPORT_IDENTIFIERS:
            continue
        canonical_name = SERIALIZED_ALIASES.get(serialized_name, serialized_name)
        if canonical_name not in constructors:
            unsupported.append(serialized_name)
            continue
        counts[canonical_name] += count

    unsupported.sort()
    if unsupported:
        raise InventoryError(
            "typed AST contains constructors absent from pinned AST.mli: "
            + ", ".join(unsupported)
        )

    declaration_counts = {
        name: counts[name] for name in sorted(counts) if name.startswith("D_")
    }
    declaration_count = sum(declaration_counts.values())
    if declaration_count == 0:
        raise InventoryError("typed AST serialization contains no declarations")

    return {
        "schema": SCHEMA,
        "input": {
            "sha256": hashlib.sha256(typed_ast).hexdigest(),
            "size_bytes": len(typed_ast),
        },
        "ast_interface": {
            "sha256": hashlib.sha256(ast_mli).hexdigest(),
            "size_bytes": len(ast_mli),
            "declared_constructor_count": len(constructors),
        },
        "declaration_count": declaration_count,
        "declaration_counts": declaration_counts,
        "constructor_count": sum(counts.values()),
        "constructor_inventory": [
            {"constructor": name, "count": counts[name]} for name in sorted(counts)
        ],
        "unsupported": [],
    }


def render_inventory(document: dict[str, object]) -> str:
    return json.dumps(document, indent=2, sort_keys=True) + "\n"


def inventory_files(typed_ast_path: Path, ast_mli_path: Path) -> str:
    return render_inventory(
        build_inventory(typed_ast_path.read_bytes(), ast_mli_path.read_bytes())
    )

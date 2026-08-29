"""Fail-closed normalizer from pinned ASLRef serialization to PTO MIR v1."""

from __future__ import annotations

from collections import Counter
from dataclasses import dataclass
import hashlib
import json
import re
import sys
from typing import Iterator


MIR_SCHEMA = "pto-mir-v1"
MIR_SCHEMA_VERSION = 1
MIR_SCHEMA_ID = "https://pto-isa.org/schemas/pto-mir-v1.schema.json"

SERIALIZED_ALIASES = {
    "PrecisionFull": "Precision_Full",
    "PrecisionLost": "Precision_Lost",
    "SPass": "S_Pass",
}

SUPPORTED_EXTERNAL_HELPERS = {
    "Bitvector.mask_of_string": "bitmask",
    "Bitvector.of_string": "bitvector",
    "Q.of_string": "rational",
    "Z.of_string": "integer",
}

SUPPORTED_PRIMITIVES = {
    "FloorLog2",
    "RoundDown",
    "RoundTowardsZero",
    "RoundUp",
    "SInt",
    "UInt",
}

SUPPORTED_IMPDEF_BINDINGS = {
    "AtomicAddress",
    "DataAccessPermitted",
    "ExtensionFirstUseEnabled",
    "FloatingExponential",
    "FloatingRoundNearest",
    "InstructionAccessPermitted",
    "RaiseExtensionFirstUse",
    "ReadMonotonicTime",
    "ReadPhysicalMemoryByte",
    "RecoverTrapContext",
    "ResetPhysicalMemory",
    "ResetProfileState",
    "SaveTrapContext",
    "ScalarFPBinaryProfile",
    "ScalarFPConvertProfile",
    "ScalarFPFusedProfile",
    "ScalarFPToIntegerProfile",
    "ScalarFPUnaryProfile",
    "ScalarIntegerToFPProfile",
    "SelectIndexedMemoryLanePosition",
    "SystemRegisterAccessPermitted",
    "TileExponential",
    "TileLogarithm",
    "TileProfileConvert",
    "TileProfileDequantize",
    "TileProfileExpand",
    "TileProfileFloatingCompare",
    "TileProfileFloatingModulo",
    "TileProfileFloatingModuloFlags",
    "TileProfileFusedInvalidResult",
    "TileProfileFusedMultiplyAdd",
    "TileProfileMatrixAccumulate",
    "TileProfileMatrixBias",
    "TileProfileMatrixCScale",
    "TileProfileMatrixPostProcess",
    "TileProfileMatrixPostProcessWithFlags",
    "TileProfileMatrixReductionStep",
    "TileProfileMatrixReductionStepWithFlags",
    "TileProfileMatrixScaledAccumulate",
    "TileProfileMixedExpdifFP32",
    "TileProfileOrderLeft",
    "TileProfileQuantize",
    "TileProfileReductionInitial",
    "TileProfileReductionStep",
    "TileProfileUnary",
    "TileProfileValueIsNaN",
    "TileReciprocal",
    "TileReciprocalSquareRoot",
    "TileSquareRoot",
    "TranslateDataAddress",
    "TranslateInstructionAddress",
    "TrapContextRecoverable",
    "WritePhysicalMemoryByte",
}

_CONSTRUCTOR_DECLARATION = re.compile(r"(?:=|\||\[)\s*`?([A-Z][A-Za-z0-9_]*)")
_GENERATED_IMPDEF = re.compile(r"__impdef_([A-Za-z_][A-Za-z0-9_]*)-[0-9]+\Z")


class ModelgenError(ValueError):
    """The input cannot be normalized without guessing."""


@dataclass(frozen=True)
class Token:
    kind: str
    value: str
    offset: int


def _strip_ocaml_comments(text: str) -> str:
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
        raise ModelgenError("unterminated OCaml comment in AST.mli")
    return "".join(output)


def declared_constructors(ast_mli: str) -> set[str]:
    constructors = set(
        _CONSTRUCTOR_DECLARATION.findall(_strip_ocaml_comments(ast_mli))
    )
    required = {"D_Func", "E_Literal", "S_Pass", "T_Int"}
    if not required.issubset(constructors):
        raise ModelgenError("AST.mli does not contain the expected ASL AST variants")
    return constructors


def validate_schema_contract(schema_bytes: bytes) -> None:
    try:
        schema = json.loads(schema_bytes)
    except (UnicodeDecodeError, json.JSONDecodeError) as error:
        raise ModelgenError(f"invalid PTO MIR schema: {error}") from error
    if schema.get("$id") != MIR_SCHEMA_ID:
        raise ModelgenError("PTO MIR schema $id mismatch")
    if schema.get("x-pto-schema-version") != MIR_SCHEMA_VERSION:
        raise ModelgenError("PTO MIR schema version mismatch")
    try:
        schema_const = schema["properties"]["schema"]["const"]
        version_const = schema["properties"]["schema_version"]["const"]
    except (KeyError, TypeError) as error:
        raise ModelgenError("PTO MIR schema is missing root constants") from error
    if schema_const != MIR_SCHEMA or version_const != MIR_SCHEMA_VERSION:
        raise ModelgenError("PTO MIR schema root contract mismatch")


class Lexer:
    def __init__(self, text: str):
        self.text = text
        self.offset = 0

    def _skip_space_and_comments(self) -> None:
        while self.offset < len(self.text):
            if self.text[self.offset].isspace():
                self.offset += 1
                continue
            if self.text.startswith("(*", self.offset):
                start = self.offset
                self.offset += 2
                depth = 1
                while self.offset < len(self.text) and depth:
                    if self.text.startswith("(*", self.offset):
                        depth += 1
                        self.offset += 2
                    elif self.text.startswith("*)", self.offset):
                        depth -= 1
                        self.offset += 2
                    else:
                        self.offset += 1
                if depth:
                    raise ModelgenError(
                        f"unterminated OCaml comment at offset {start}"
                    )
                continue
            break

    def _string(self) -> Token:
        start = self.offset
        self.offset += 1
        chars: list[str] = []
        simple = {
            "\\": "\\",
            '"': '"',
            "n": "\n",
            "r": "\r",
            "t": "\t",
            "b": "\b",
            " ": " ",
        }
        while self.offset < len(self.text):
            char = self.text[self.offset]
            self.offset += 1
            if char == '"':
                return Token("string", "".join(chars), start)
            if char != "\\":
                chars.append(char)
                continue
            if self.offset >= len(self.text):
                break
            escape = self.text[self.offset]
            self.offset += 1
            if escape in simple:
                chars.append(simple[escape])
            elif escape == "x":
                digits = self.text[self.offset : self.offset + 2]
                if len(digits) != 2 or not all(c in "0123456789abcdefABCDEF" for c in digits):
                    raise ModelgenError(f"invalid hexadecimal escape at offset {start}")
                chars.append(chr(int(digits, 16)))
                self.offset += 2
            elif escape.isdigit():
                digits = escape + self.text[self.offset : self.offset + 2]
                if len(digits) != 3 or not digits.isdigit():
                    raise ModelgenError(f"invalid decimal escape at offset {start}")
                chars.append(chr(int(digits, 10)))
                self.offset += 2
            elif escape == "\n":
                while self.offset < len(self.text) and self.text[self.offset] in " \t":
                    self.offset += 1
            else:
                raise ModelgenError(
                    f"unsupported OCaml string escape \\{escape} at offset {start}"
                )
        raise ModelgenError(f"unterminated string at offset {start}")

    def tokens(self) -> Iterator[Token]:
        punctuation = "[]{}();,="
        while True:
            self._skip_space_and_comments()
            if self.offset >= len(self.text):
                yield Token("eof", "", self.offset)
                return
            start = self.offset
            char = self.text[self.offset]
            if char == '"':
                yield self._string()
                continue
            if char in punctuation:
                self.offset += 1
                yield Token(char, char, start)
                continue
            if char == "-" or char.isdigit():
                if char == "-":
                    self.offset += 1
                    if self.offset >= len(self.text) or not self.text[self.offset].isdigit():
                        raise ModelgenError(f"unexpected '-' at offset {start}")
                while self.offset < len(self.text) and self.text[self.offset].isdigit():
                    self.offset += 1
                yield Token("integer", self.text[start : self.offset], start)
                continue
            if char.isalpha() or char == "_":
                self.offset += 1
                while self.offset < len(self.text) and (
                    self.text[self.offset].isalnum()
                    or self.text[self.offset] in "_."
                ):
                    self.offset += 1
                yield Token("identifier", self.text[start : self.offset], start)
                continue
            raise ModelgenError(f"unexpected character {char!r} at offset {start}")


class Parser:
    def __init__(self, text: str, constructors: set[str]):
        self._tokens = iter(Lexer(text).tokens())
        self.current = next(self._tokens)
        self.constructors = constructors
        self.nodes: list[dict[str, object]] = []
        self.constructor_counts: Counter[str] = Counter()

    def _advance(self) -> Token:
        previous = self.current
        self.current = next(self._tokens)
        return previous

    def _expect(self, kind: str, value: str | None = None) -> Token:
        token = self.current
        if token.kind != kind or (value is not None and token.value != value):
            expected = value if value is not None else kind
            raise ModelgenError(
                f"expected {expected!r} at offset {token.offset}, got {token.value!r}"
            )
        self._advance()
        return token

    def _node(self, node: dict[str, object]) -> int:
        identifier = len(self.nodes)
        self.nodes.append(node)
        return identifier

    def _atom(self, atom_kind: str, value: object) -> int:
        return self._node({"kind": "atom", "atom_kind": atom_kind, "value": value})

    def parse(self) -> dict[str, object]:
        for word in ("let", "open", "AST", "in", "let", "annot"):
            self._expect("identifier", word)
        self._expect("=")
        self._expect("identifier", "ASTUtils.add_dummy_pos")
        self._expect("identifier", "in")
        root = self._value()
        if self.current.kind != "eof":
            raise ModelgenError(
                f"trailing syntax at offset {self.current.offset}: {self.current.value!r}"
            )
        if self.nodes[root].get("kind") != "list":
            raise ModelgenError("typed AST root must be a declaration list")
        return {"root": root, "nodes": self.nodes}

    def _value_starts(self) -> bool:
        return self.current.kind in {
            "identifier",
            "string",
            "integer",
            "[",
            "{",
            "(",
        }

    def _value(self) -> int:
        token = self.current
        if token.kind == "string":
            self._advance()
            return self._atom("string", token.value)
        if token.kind == "integer":
            self._advance()
            return self._atom("integer", token.value)
        if token.kind == "[":
            return self._list()
        if token.kind == "{":
            return self._record()
        if token.kind == "(":
            return self._parenthesized_or_tuple()
        if token.kind != "identifier":
            raise ModelgenError(
                f"expected value at offset {token.offset}, got {token.value!r}"
            )
        name = self._advance().value
        if name == "true":
            return self._atom("boolean", True)
        if name == "false":
            return self._atom("boolean", False)
        if name == "annot":
            self._expect("(")
            value = self._value()
            self._expect(")")
            return value
        if name == "None":
            return self._node({"kind": "option", "value": None})
        if name == "Some":
            self._expect("(")
            value = self._value()
            self._expect(")")
            return self._node({"kind": "option", "value": value})
        if name in SUPPORTED_EXTERNAL_HELPERS:
            parenthesized = self.current.kind == "("
            if parenthesized:
                self._advance()
            value = self._expect("string").value
            if parenthesized:
                self._expect(")")
            return self._atom(SUPPORTED_EXTERNAL_HELPERS[name], value)
        if "." in name or not name[0].isupper():
            raise ModelgenError(
                f"unsupported external helper {name!r} at offset {token.offset}"
            )
        canonical = SERIALIZED_ALIASES.get(name, name)
        if canonical not in self.constructors:
            raise ModelgenError(
                f"constructor {name!r} is absent from pinned AST.mli"
            )
        arguments: list[int] = []
        if self._value_starts():
            arguments.append(self._value())
        self.constructor_counts[canonical] += 1
        return self._node(
            {"kind": "constructor", "name": canonical, "arguments": arguments}
        )

    def _list(self) -> int:
        self._expect("[")
        items: list[int] = []
        if self.current.kind != "]":
            while True:
                items.append(self._value())
                if self.current.kind != ";":
                    break
                self._advance()
                if self.current.kind == "]":
                    break
        self._expect("]")
        return self._node({"kind": "list", "items": items})

    def _record(self) -> int:
        self._expect("{")
        fields: list[dict[str, object]] = []
        names: set[str] = set()
        if self.current.kind != "}":
            while True:
                name = self._expect("identifier").value
                if "." in name or name in names:
                    raise ModelgenError(f"invalid or duplicate record field {name!r}")
                names.add(name)
                self._expect("=")
                fields.append({"name": name, "value": self._value()})
                if self.current.kind != ";":
                    break
                self._advance()
                if self.current.kind == "}":
                    break
        self._expect("}")
        return self._node({"kind": "record", "fields": fields})

    def _parenthesized_or_tuple(self) -> int:
        self._expect("(")
        first = self._value()
        if self.current.kind != ",":
            self._expect(")")
            return first
        items = [first]
        while self.current.kind == ",":
            self._advance()
            items.append(self._value())
        self._expect(")")
        return self._node({"kind": "tuple", "items": items})


def _references(node: dict[str, object]) -> Iterator[int]:
    kind = node["kind"]
    if kind == "constructor":
        yield from node["arguments"]  # type: ignore[misc]
    elif kind in {"list", "tuple"}:
        yield from node["items"]  # type: ignore[misc]
    elif kind == "record":
        for field in node["fields"]:  # type: ignore[misc]
            yield field["value"]
    elif kind == "option" and node["value"] is not None:
        yield node["value"]  # type: ignore[misc]


def _record_fields(nodes: list[dict[str, object]], identifier: int) -> dict[str, int]:
    node = nodes[identifier]
    if node["kind"] != "record":
        raise ModelgenError("constructor argument must be a record")
    return {field["name"]: field["value"] for field in node["fields"]}  # type: ignore[misc]


def _constructor(
    nodes: list[dict[str, object]], identifier: int, expected: str | None = None
) -> dict[str, object]:
    node = nodes[identifier]
    if node["kind"] != "constructor":
        raise ModelgenError("expected constructor node")
    if expected is not None and node["name"] != expected:
        raise ModelgenError(f"expected constructor {expected}, got {node['name']}")
    return node


def _string_atom(nodes: list[dict[str, object]], identifier: int) -> str:
    node = nodes[identifier]
    if node.get("kind") != "atom" or node.get("atom_kind") != "string":
        raise ModelgenError("expected string atom")
    return str(node["value"])


def _option_value(nodes: list[dict[str, object]], identifier: int) -> int | None:
    node = nodes[identifier]
    if node["kind"] != "option":
        raise ModelgenError("expected option node")
    value = node["value"]
    return None if value is None else int(value)


def _descendants(nodes: list[dict[str, object]], root: int) -> Iterator[int]:
    stack = [root]
    while stack:
        identifier = stack.pop()
        yield identifier
        stack.extend(_references(nodes[identifier]))


def _impdef_binding_name(name: str) -> str:
    generated = _GENERATED_IMPDEF.fullmatch(name)
    return generated.group(1) if generated else name


def _call_graph_stats(graph: dict[str, set[str]]) -> dict[str, int]:
    names = sorted(graph)
    known = set(names)
    graph = {name: {callee for callee in graph[name] if callee in known} for name in names}
    reverse = {name: set() for name in names}
    for caller, callees in graph.items():
        for callee in callees:
            reverse[callee].add(caller)

    visited: set[str] = set()
    order: list[str] = []
    for start in names:
        if start in visited:
            continue
        stack: list[tuple[str, bool]] = [(start, False)]
        while stack:
            node, finished = stack.pop()
            if finished:
                order.append(node)
                continue
            if node in visited:
                continue
            visited.add(node)
            stack.append((node, True))
            stack.extend((child, False) for child in sorted(graph[node], reverse=True))

    visited.clear()
    recursive_names: set[str] = set()
    recursive_components = 0
    for start in reversed(order):
        if start in visited:
            continue
        component: set[str] = set()
        stack = [start]
        visited.add(start)
        while stack:
            node = stack.pop()
            component.add(node)
            for child in reverse[node]:
                if child not in visited:
                    visited.add(child)
                    stack.append(child)
        if len(component) > 1 or any(name in graph[name] for name in component):
            recursive_components += 1
            recursive_names.update(component)

    return {
        "call_graph_node_count": len(names),
        "call_graph_edge_count": sum(len(callees) for callees in graph.values()),
        "recursive_component_count": recursive_components,
        "recursive_subprogram_count": len(recursive_names),
    }


def analyze_mir(mir: dict[str, object]) -> dict[str, object]:
    nodes: list[dict[str, object]] = mir["nodes"]  # type: ignore[assignment]
    root = nodes[int(mir["root"])]
    if root["kind"] != "list":
        raise ModelgenError("MIR root is not a declaration list")
    declarations: list[int] = root["items"]  # type: ignore[assignment]

    constructor_counts: Counter[str] = Counter(
        str(node["name"]) for node in nodes if node["kind"] == "constructor"
    )
    declaration_counts = {
        name: constructor_counts[name]
        for name in sorted(constructor_counts)
        if name.startswith("D_")
    }
    functions: dict[str, set[str]] = {}
    primitive_names: list[str] = []
    impdef_names: list[str] = []

    for declaration in declarations:
        node = _constructor(nodes, declaration)
        if not str(node["name"]).startswith("D_"):
            raise ModelgenError("MIR root contains a non-declaration constructor")
        if node["name"] != "D_Func":
            continue
        arguments: list[int] = node["arguments"]  # type: ignore[assignment]
        if len(arguments) != 1:
            raise ModelgenError("D_Func must have one record argument")
        fields = _record_fields(nodes, arguments[0])
        name = _string_atom(nodes, fields["name"])
        body = _constructor(nodes, fields["body"])
        if body["name"] == "SB_Primitive":
            primitive_names.append(name)
            if name not in SUPPORTED_PRIMITIVES:
                raise ModelgenError(f"unsupported primitive binding {name!r}")

        override = _option_value(nodes, fields["override"])
        if override is not None:
            override_node = _constructor(nodes, override)
            if override_node["name"] == "Impdef":
                binding = _impdef_binding_name(name)
                impdef_names.append(binding)
                if binding not in SUPPORTED_IMPDEF_BINDINGS:
                    raise ModelgenError(f"uncovered impdef binding {binding!r}")

        calls: set[str] = set()
        for identifier in _descendants(nodes, fields["body"]):
            candidate = nodes[identifier]
            if candidate.get("kind") != "constructor" or candidate.get("name") not in {
                "E_Call",
                "S_Call",
            }:
                continue
            call_arguments: list[int] = candidate["arguments"]  # type: ignore[assignment]
            if len(call_arguments) != 1:
                raise ModelgenError("call constructor must have one record argument")
            call_fields = _record_fields(nodes, call_arguments[0])
            calls.add(_string_atom(nodes, call_fields["name"]))
        functions.setdefault(name, set()).update(calls)

    stats: dict[str, object] = {
        "node_count": len(nodes),
        "constructor_node_count": sum(constructor_counts.values()),
        "constructor_kind_count": len(constructor_counts),
        "declaration_count": len(declarations),
        "declaration_counts": declaration_counts,
        "loop_node_count": sum(
            constructor_counts[name] for name in ("S_For", "S_Repeat", "S_While")
        ),
        "side_effect_statement_count": sum(
            constructor_counts[name]
            for name in ("S_Assign", "S_Call", "S_Print", "S_Throw")
        ),
        "primitive_count": len(primitive_names),
        "primitive_bindings": sorted(set(primitive_names)),
        "impdef_count": len(impdef_names),
        "impdef_bindings": sorted(set(impdef_names)),
        "constructor_inventory": [
            {"constructor": name, "count": constructor_counts[name]}
            for name in sorted(constructor_counts)
        ],
        "unsupported": [],
    }
    stats.update(_call_graph_stats(functions))
    return stats


def validate_mir(mir: dict[str, object]) -> None:
    if set(mir) != {"schema", "schema_version", "source", "root", "nodes"}:
        raise ModelgenError("PTO MIR root does not match the v1 schema")
    if mir["schema"] != MIR_SCHEMA or mir["schema_version"] != MIR_SCHEMA_VERSION:
        raise ModelgenError("PTO MIR root schema mismatch")
    source = mir["source"]
    if not isinstance(source, dict) or set(source) != {
        "ast_interface_sha256",
        "typed_ast_sha256",
    }:
        raise ModelgenError("PTO MIR source descriptor is malformed")
    for digest in source.values():
        if not isinstance(digest, str) or re.fullmatch(r"[0-9a-f]{64}", digest) is None:
            raise ModelgenError("PTO MIR source digest is malformed")
    nodes = mir["nodes"]
    root = mir["root"]
    if not isinstance(nodes, list) or not isinstance(root, int):
        raise ModelgenError("PTO MIR node arena is malformed")

    def reference(value: object, owner: int) -> None:
        if not isinstance(value, int) or value < 0 or value >= owner:
            raise ModelgenError(f"PTO MIR node {owner} has an invalid reference")

    atom_kinds = {"bitmask", "bitvector", "boolean", "integer", "rational", "string"}
    for identifier, node in enumerate(nodes):
        if not isinstance(node, dict) or not isinstance(node.get("kind"), str):
            raise ModelgenError(f"PTO MIR node {identifier} is malformed")
        kind = node["kind"]
        if kind == "atom":
            if set(node) != {"kind", "atom_kind", "value"}:
                raise ModelgenError(f"PTO MIR atom {identifier} is malformed")
            atom_kind = node["atom_kind"]
            value = node["value"]
            if atom_kind not in atom_kinds:
                raise ModelgenError(f"PTO MIR atom {identifier} has unknown kind")
            if atom_kind == "boolean":
                valid_value = isinstance(value, bool)
            else:
                valid_value = isinstance(value, str)
            if not valid_value:
                raise ModelgenError(f"PTO MIR atom {identifier} has invalid value")
        elif kind == "constructor":
            if set(node) != {"kind", "name", "arguments"}:
                raise ModelgenError(f"PTO MIR constructor {identifier} is malformed")
            name = node["name"]
            arguments = node["arguments"]
            if not isinstance(name, str) or re.fullmatch(
                r"[A-Z][A-Za-z0-9_]*", name
            ) is None:
                raise ModelgenError(f"PTO MIR constructor {identifier} has invalid name")
            if not isinstance(arguments, list) or len(arguments) > 1:
                raise ModelgenError(
                    f"PTO MIR constructor {identifier} has invalid arguments"
                )
            for child in arguments:
                reference(child, identifier)
        elif kind in {"list", "tuple"}:
            if set(node) != {"kind", "items"} or not isinstance(node["items"], list):
                raise ModelgenError(f"PTO MIR sequence {identifier} is malformed")
            for child in node["items"]:
                reference(child, identifier)
        elif kind == "record":
            if set(node) != {"kind", "fields"} or not isinstance(
                node["fields"], list
            ):
                raise ModelgenError(f"PTO MIR record {identifier} is malformed")
            names: set[str] = set()
            for field in node["fields"]:
                if not isinstance(field, dict) or set(field) != {"name", "value"}:
                    raise ModelgenError(f"PTO MIR record {identifier} has invalid field")
                name = field["name"]
                if (
                    not isinstance(name, str)
                    or re.fullmatch(r"[A-Za-z_][A-Za-z0-9_]*", name) is None
                    or name in names
                ):
                    raise ModelgenError(f"PTO MIR record {identifier} has invalid field")
                names.add(name)
                reference(field["value"], identifier)
        elif kind == "option":
            if set(node) != {"kind", "value"}:
                raise ModelgenError(f"PTO MIR option {identifier} is malformed")
            if node["value"] is not None:
                reference(node["value"], identifier)
        else:
            raise ModelgenError(f"PTO MIR node {identifier} has unknown kind {kind!r}")
    if root < 0 or root >= len(nodes):
        raise ModelgenError("PTO MIR root reference is invalid")


def build_mir(
    typed_ast: bytes, ast_mli: bytes, schema_bytes: bytes
) -> tuple[dict[str, object], dict[str, object]]:
    validate_schema_contract(schema_bytes)
    try:
        typed_text = typed_ast.decode("utf-8")
        mli_text = ast_mli.decode("utf-8")
    except UnicodeDecodeError as error:
        raise ModelgenError(f"inputs must be UTF-8: {error}") from error
    parser = Parser(typed_text, declared_constructors(mli_text))
    parsed = parser.parse()
    mir: dict[str, object] = {
        "schema": MIR_SCHEMA,
        "schema_version": MIR_SCHEMA_VERSION,
        "source": {
            "typed_ast_sha256": hashlib.sha256(typed_ast).hexdigest(),
            "ast_interface_sha256": hashlib.sha256(ast_mli).hexdigest(),
        },
        "root": parsed["root"],
        "nodes": parsed["nodes"],
    }
    validate_mir(mir)
    return mir, analyze_mir(mir)


def render_mir(mir: dict[str, object]) -> bytes:
    return (json.dumps(mir, sort_keys=True, separators=(",", ":")) + "\n").encode(
        "utf-8"
    )


def build_readiness(
    *,
    typed_ast: bytes,
    ast_mli: bytes,
    schema_bytes: bytes,
    mir_bytes: bytes,
    stats: dict[str, object],
) -> dict[str, object]:
    return {
        "schema": "pto.functional-model-mir-readiness.v1",
        "typed_ast": {
            "sha256": hashlib.sha256(typed_ast).hexdigest(),
            "size_bytes": len(typed_ast),
        },
        "ast_interface": {
            "sha256": hashlib.sha256(ast_mli).hexdigest(),
            "size_bytes": len(ast_mli),
        },
        "mir_schema": {
            "id": MIR_SCHEMA_ID,
            "sha256": hashlib.sha256(schema_bytes).hexdigest(),
            "version": MIR_SCHEMA_VERSION,
        },
        "mir": {
            "sha256": hashlib.sha256(mir_bytes).hexdigest(),
            "size_bytes": len(mir_bytes),
        },
        "statistics": stats,
        "unsupported": [],
    }


def render_readiness(readiness: dict[str, object]) -> str:
    return json.dumps(readiness, indent=2, sort_keys=True) + "\n"


# Large generated decoders can contain deeply nested constructor applications.
sys.setrecursionlimit(max(sys.getrecursionlimit(), 100_000))

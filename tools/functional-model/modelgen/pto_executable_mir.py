"""Lower PTO MIR v1 into a linked, immutable executable-module image."""

from __future__ import annotations

from collections import Counter
import hashlib
import json
import re
from typing import Iterable, Iterator

from pto_mir import (
    MIR_SCHEMA,
    ModelgenError,
    SUPPORTED_EXTERNAL_HELPERS,
    SUPPORTED_IMPDEF_BINDINGS,
    SUPPORTED_PRIMITIVES,
    validate_mir,
)


EXECUTABLE_SCHEMA = "pto-executable-mir-v1"
EXECUTABLE_SCHEMA_VERSION = 1
EXECUTABLE_SCHEMA_ID = (
    "https://pto-isa.org/schemas/pto-executable-mir-v1.schema.json"
)

DEFAULT_ENTRYPOINTS = (
    "CompleteFunctionalModelHostRequest",
    "DeterminePTOInstructionLength",
    "ExecuteOnePTOStep",
    "ExecutePTOInstruction",
    "FetchPTOInstruction",
    "InitializeFunctionalModel",
)

EXTERNAL_IMPDEF_BINDINGS = {
    "ExtensionFirstUseEnabled",
    "RaiseExtensionFirstUse",
    "TileProfileFloatingModuloFlags",
}

NODE_KINDS = ("atom", "constructor", "list", "option", "record", "tuple")


def validate_executable_schema_contract(schema_bytes: bytes) -> None:
    try:
        schema = json.loads(schema_bytes)
    except (UnicodeDecodeError, json.JSONDecodeError) as error:
        raise ModelgenError(f"invalid executable MIR schema: {error}") from error
    if schema.get("$id") != EXECUTABLE_SCHEMA_ID:
        raise ModelgenError("executable MIR schema $id mismatch")
    if schema.get("x-pto-schema-version") != EXECUTABLE_SCHEMA_VERSION:
        raise ModelgenError("executable MIR schema version mismatch")
    try:
        schema_const = schema["properties"]["schema"]["const"]
        version_const = schema["properties"]["schema_version"]["const"]
    except (KeyError, TypeError) as error:
        raise ModelgenError("executable MIR schema is missing root constants") from error
    if (
        schema_const != EXECUTABLE_SCHEMA
        or version_const != EXECUTABLE_SCHEMA_VERSION
    ):
        raise ModelgenError("executable MIR schema root contract mismatch")


class Arena:
    def __init__(self, mir: dict[str, object]):
        self.mir = mir
        self.nodes: list[dict[str, object]] = mir["nodes"]  # type: ignore[assignment]

    def record(self, identifier: int) -> dict[str, int]:
        node = self.nodes[identifier]
        if node["kind"] != "record":
            raise ModelgenError(f"node {identifier} must be a record")
        return {field["name"]: field["value"] for field in node["fields"]}  # type: ignore[misc]

    def constructor(
        self, identifier: int, expected: str | None = None
    ) -> dict[str, object]:
        node = self.nodes[identifier]
        if node["kind"] != "constructor":
            raise ModelgenError(f"node {identifier} must be a constructor")
        if expected is not None and node["name"] != expected:
            raise ModelgenError(
                f"node {identifier} must be {expected}, got {node['name']}"
            )
        return node

    def atom(self, identifier: int, kind: str | None = None) -> object:
        node = self.nodes[identifier]
        if node["kind"] != "atom":
            raise ModelgenError(f"node {identifier} must be an atom")
        if kind is not None and node["atom_kind"] != kind:
            raise ModelgenError(f"node {identifier} must be a {kind} atom")
        return node["value"]

    def string(self, identifier: int) -> str:
        return str(self.atom(identifier, "string"))

    def option(self, identifier: int) -> int | None:
        node = self.nodes[identifier]
        if node["kind"] != "option":
            raise ModelgenError(f"node {identifier} must be an option")
        value = node["value"]
        return None if value is None else int(value)

    def sequence(self, identifier: int, kind: str | None = None) -> list[int]:
        node = self.nodes[identifier]
        if node["kind"] not in {"list", "tuple"}:
            raise ModelgenError(f"node {identifier} must be a sequence")
        if kind is not None and node["kind"] != kind:
            raise ModelgenError(f"node {identifier} must be a {kind}")
        return list(node["items"])  # type: ignore[arg-type]

    def constructor_argument(self, identifier: int, expected: str) -> int | None:
        node = self.constructor(identifier, expected)
        arguments: list[int] = node["arguments"]  # type: ignore[assignment]
        if len(arguments) > 1:
            raise ModelgenError(f"constructor {expected} has too many arguments")
        return arguments[0] if arguments else None

    def references(self, identifier: int) -> Iterator[int]:
        node = self.nodes[identifier]
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

    def descendants(self, root: int) -> Iterator[int]:
        stack = [root]
        while stack:
            identifier = stack.pop()
            yield identifier
            stack.extend(self.references(identifier))


def _table(names: Iterable[str]) -> tuple[list[dict[str, object]], dict[str, int]]:
    ordered = sorted(set(names))
    return (
        [{"id": identifier, "name": name} for identifier, name in enumerate(ordered)],
        {name: identifier for identifier, name in enumerate(ordered)},
    )


def _impdef_binding_name(name: str) -> str:
    match = re.fullmatch(r"__impdef_([A-Za-z_][A-Za-z0-9_]*)-[0-9]+", name)
    return match.group(1) if match else name


def _override(arena: Arena, fields: dict[str, int]) -> str | None:
    value = arena.option(fields["override"])
    if value is None:
        return None
    return str(arena.constructor(value)["name"])


def _type_reference(arena: Arena, identifier: int | None) -> int | None:
    if identifier is None:
        return None
    node = arena.constructor(identifier)
    if not str(node["name"]).startswith("T_"):
        raise ModelgenError(f"node {identifier} is not an ASL type")
    return identifier


def _typed_identifier(
    arena: Arena, identifier: int, argument_id: int, string_ids: dict[str, int]
) -> dict[str, object]:
    pair = arena.sequence(identifier, "tuple")
    if len(pair) != 2:
        raise ModelgenError("typed identifier must contain name and type")
    return {
        "id": argument_id,
        "name_symbol_id": string_ids[arena.string(pair[0])],
        "type_node": _type_reference(arena, pair[1]),
    }


def _parameter(
    arena: Arena, identifier: int, parameter_id: int, string_ids: dict[str, int]
) -> dict[str, object]:
    pair = arena.sequence(identifier, "tuple")
    if len(pair) != 2:
        raise ModelgenError("parameter must contain name and optional type")
    return {
        "id": parameter_id,
        "name_symbol_id": string_ids[arena.string(pair[0])],
        "type_node": _type_reference(arena, arena.option(pair[1])),
    }


def _recursive_components(graph: dict[int, set[int]]) -> list[set[int]]:
    reverse = {node: set() for node in graph}
    for caller, callees in graph.items():
        for callee in callees:
            reverse[callee].add(caller)
    visited: set[int] = set()
    order: list[int] = []
    for start in sorted(graph):
        if start in visited:
            continue
        stack: list[tuple[int, bool]] = [(start, False)]
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
    recursive: list[set[int]] = []
    for start in reversed(order):
        if start in visited:
            continue
        component: set[int] = set()
        stack = [start]
        visited.add(start)
        while stack:
            node = stack.pop()
            component.add(node)
            for child in reverse[node]:
                if child not in visited:
                    visited.add(child)
                    stack.append(child)
        if len(component) > 1 or any(node in graph[node] for node in component):
            recursive.append(component)
    return recursive


def _loop_limit_closure(arena: Arena) -> None:
    for identifier, node in enumerate(arena.nodes):
        name = node.get("name")
        if name == "S_While":
            argument = arena.constructor_argument(identifier, "S_While")
            values = arena.sequence(int(argument), "tuple")
            if arena.option(values[1]) is None:
                raise ModelgenError(f"unbounded S_While loop at node {identifier}")
        elif name == "S_Repeat":
            argument = arena.constructor_argument(identifier, "S_Repeat")
            values = arena.sequence(int(argument), "tuple")
            if arena.option(values[2]) is None:
                raise ModelgenError(f"unbounded S_Repeat loop at node {identifier}")


def _local_names(arena: Arena, function_fields: dict[str, int]) -> set[str]:
    names: set[str] = set()
    for item in arena.sequence(function_fields["args"], "list"):
        names.add(arena.string(arena.sequence(item, "tuple")[0]))
    for item in arena.sequence(function_fields["parameters"], "list"):
        names.add(arena.string(arena.sequence(item, "tuple")[0]))
    for identifier in arena.descendants(function_fields["body"]):
        node = arena.nodes[identifier]
        if node.get("name") == "S_Decl":
            values = arena.sequence(int(arena.constructor_argument(identifier, "S_Decl")), "tuple")
            declaration = arena.constructor(values[1])
            argument = arena.constructor_argument(values[1], str(declaration["name"]))
            if declaration["name"] == "LDI_Var":
                names.add(arena.string(int(argument)))
            elif declaration["name"] == "LDI_Tuple":
                names.update(
                    arena.string(item)
                    for item in arena.sequence(int(argument), "list")
                )
        elif node.get("name") == "S_For":
            record = arena.record(int(arena.constructor_argument(identifier, "S_For")))
            names.add(arena.string(record["index_name"]))
    return names


def _compact_nodes(
    arena: Arena,
    constructor_ids: dict[str, int],
    field_ids: dict[str, int],
    atom_kind_ids: dict[str, int],
    string_ids: dict[str, int],
    node_kind_ids: dict[str, int],
) -> list[list[object]]:
    compact: list[list[object]] = []
    for node in arena.nodes:
        kind = str(node["kind"])
        kind_id = node_kind_ids[kind]
        if kind == "atom":
            atom_kind = str(node["atom_kind"])
            value = node["value"]
            if atom_kind == "string":
                value = string_ids[str(value)]
            compact.append([kind_id, atom_kind_ids[atom_kind], value])
        elif kind == "constructor":
            compact.append(
                [kind_id, constructor_ids[str(node["name"])], node["arguments"]]
            )
        elif kind in {"list", "tuple"}:
            compact.append([kind_id, node["items"]])
        elif kind == "record":
            compact.append(
                [
                    kind_id,
                    [
                        [field_ids[str(field["name"])], field["value"]]
                        for field in node["fields"]  # type: ignore[misc]
                    ],
                ]
            )
        elif kind == "option":
            compact.append([kind_id, node["value"]])
        else:
            raise ModelgenError(f"unknown PTO MIR node kind {kind!r}")
    return compact


def lower_executable_module(
    mir: dict[str, object],
    *,
    mir_bytes: bytes,
    schema_bytes: bytes,
    required_entrypoints: Iterable[str] = DEFAULT_ENTRYPOINTS,
) -> dict[str, object]:
    validate_mir(mir)
    if mir.get("schema") != MIR_SCHEMA:
        raise ModelgenError("input is not PTO MIR v1")
    validate_executable_schema_contract(schema_bytes)
    arena = Arena(mir)
    _loop_limit_closure(arena)

    constructor_names = [
        str(node["name"]) for node in arena.nodes if node["kind"] == "constructor"
    ]
    field_names = [
        str(field["name"])
        for node in arena.nodes
        if node["kind"] == "record"
        for field in node["fields"]  # type: ignore[misc]
    ]
    atom_kinds = [
        str(node["atom_kind"]) for node in arena.nodes if node["kind"] == "atom"
    ]
    strings = [
        str(node["value"])
        for node in arena.nodes
        if node["kind"] == "atom" and node["atom_kind"] == "string"
    ]
    strings.extend(SUPPORTED_EXTERNAL_HELPERS)
    strings.extend(SUPPORTED_PRIMITIVES)
    strings.extend(SUPPORTED_IMPDEF_BINDINGS)
    strings.extend(required_entrypoints)
    constructor_table, constructor_ids = _table(constructor_names)
    field_table, field_ids = _table(field_names)
    atom_kind_table, atom_kind_ids = _table(atom_kinds)
    string_table, string_ids = _table(strings)
    node_kind_table, node_kind_ids = _table(NODE_KINDS)

    root = arena.nodes[int(mir["root"])]
    declarations: list[int] = root["items"]  # type: ignore[assignment]
    type_rows: list[dict[str, object]] = []
    global_rows: list[dict[str, object]] = []
    function_rows: list[dict[str, object]] = []
    function_fields_by_name: dict[str, dict[str, int]] = {}
    global_kind_names: set[str] = set()

    for declaration_node in declarations:
        declaration = arena.constructor(declaration_node)
        arguments: list[int] = declaration["arguments"]  # type: ignore[assignment]
        if len(arguments) != 1:
            raise ModelgenError("declaration constructor must have one argument")
        if declaration["name"] == "D_TypeDecl":
            pair = arena.sequence(arguments[0], "tuple")
            if len(pair) != 2:
                raise ModelgenError("D_TypeDecl must contain name and type")
            type_rows.append(
                {
                    "name": arena.string(pair[0]),
                    "declaration_node": declaration_node,
                    "definition_node": _type_reference(arena, pair[1]),
                }
            )
        elif declaration["name"] == "D_GlobalStorage":
            fields = arena.record(arguments[0])
            keyword = str(arena.constructor(fields["keyword"])["name"])
            global_kind_names.add(keyword)
            global_rows.append(
                {
                    "name": arena.string(fields["name"]),
                    "declaration_node": declaration_node,
                    "global_kind": keyword,
                    "type_node": _type_reference(arena, arena.option(fields["ty"])),
                    "initializer_node": arena.option(fields["initial_value"]),
                }
            )
        elif declaration["name"] == "D_Func":
            fields = arena.record(arguments[0])
            name = arena.string(fields["name"])
            if name in function_fields_by_name:
                raise ModelgenError(f"duplicate function name {name!r}")
            function_fields_by_name[name] = fields
            function_rows.append(
                {
                    "name": name,
                    "declaration_node": declaration_node,
                    "fields": fields,
                }
            )
        else:
            raise ModelgenError(
                f"unsupported top-level declaration {declaration['name']!r}"
            )

    def unique(rows: list[dict[str, object]], category: str) -> None:
        names = [str(row["name"]) for row in rows]
        duplicates = sorted(name for name, count in Counter(names).items() if count > 1)
        if duplicates:
            raise ModelgenError(f"duplicate {category} names: {', '.join(duplicates)}")

    unique(type_rows, "type")
    unique(global_rows, "global")
    type_rows.sort(key=lambda row: str(row["name"]))
    global_rows.sort(key=lambda row: str(row["name"]))
    function_rows.sort(key=lambda row: str(row["name"]))
    global_kind_table, global_kind_ids = _table(global_kind_names)

    types = [
        {
            "id": identifier,
            "name_symbol_id": string_ids[str(row["name"])],
            "declaration_node": row["declaration_node"],
            "definition_node": row["definition_node"],
        }
        for identifier, row in enumerate(type_rows)
    ]
    globals_ = [
        {
            "id": identifier,
            "name_symbol_id": string_ids[str(row["name"])],
            "declaration_node": row["declaration_node"],
            "global_kind_id": global_kind_ids[str(row["global_kind"])],
            "type_node": row["type_node"],
            "initializer_node": row["initializer_node"],
        }
        for identifier, row in enumerate(global_rows)
    ]
    function_ids = {
        str(row["name"]): identifier for identifier, row in enumerate(function_rows)
    }
    global_ids = {
        str(row["name"]): identifier for identifier, row in enumerate(global_rows)
    }

    state_names = sorted(
        str(row["name"])
        for row in global_rows
        if row["global_kind"] == "GDK_Var"
    )
    state_fields = [
        {
            "id": identifier,
            "name_symbol_id": string_ids[name],
            "global_id": global_ids[name],
        }
        for identifier, name in enumerate(state_names)
    ]
    state_ids = {name: identifier for identifier, name in enumerate(state_names)}
    for row in function_rows:
        collisions = sorted(
            _local_names(arena, row["fields"]) & set(state_names)  # type: ignore[arg-type]
        )
        if collisions:
            raise ModelgenError(
                f"local names shadow state fields in {row['name']}: {', '.join(collisions)}"
            )

    implementation_ids: dict[str, int] = {}
    impdef_declarations: list[tuple[str, int]] = []
    primitive_functions: list[tuple[str, int]] = []
    for function_id, row in enumerate(function_rows):
        fields: dict[str, int] = row["fields"]  # type: ignore[assignment]
        name = str(row["name"])
        override = _override(arena, fields)
        if override == "Implementation":
            implementation_ids[name] = function_id
        elif override == "Impdef":
            binding = _impdef_binding_name(name)
            if binding not in SUPPORTED_IMPDEF_BINDINGS:
                raise ModelgenError(f"unknown impdef binding {binding!r}")
            impdef_declarations.append((binding, function_id))
        body = arena.constructor(fields["body"])
        if body["name"] == "SB_Primitive":
            if name not in SUPPORTED_PRIMITIVES:
                raise ModelgenError(f"unknown primitive binding {name!r}")
            primitive_functions.append((name, function_id))

    binding_keys = [
        ("literal_helper", name) for name in SUPPORTED_EXTERNAL_HELPERS
    ] + [("primitive", name) for name, _ in primitive_functions] + [
        ("impdef", name) for name, _ in impdef_declarations
    ]
    binding_keys = sorted(set(binding_keys))
    bindings = [
        {
            "id": identifier,
            "kind": kind,
            "name_symbol_id": string_ids[name],
        }
        for identifier, (kind, name) in enumerate(binding_keys)
    ]
    binding_ids = {key: identifier for identifier, key in enumerate(binding_keys)}

    extern_rows: list[dict[str, object]] = []
    for name, function_id in primitive_functions:
        extern_rows.append(
            {
                "kind": "primitive",
                "name": name,
                "binding_id": binding_ids[("primitive", name)],
                "declaration_function_id": function_id,
                "implementation_function_id": None,
            }
        )
    for binding, function_id in impdef_declarations:
        implementation = implementation_ids.get(binding)
        if implementation is None and binding not in EXTERNAL_IMPDEF_BINDINGS:
            raise ModelgenError(f"unresolved impdef implementation {binding!r}")
        extern_rows.append(
            {
                "kind": "impdef",
                "name": binding,
                "binding_id": binding_ids[("impdef", binding)],
                "declaration_function_id": function_id,
                "implementation_function_id": implementation,
            }
        )
    extern_rows.sort(key=lambda row: (str(row["kind"]), str(row["name"])))
    externs = [
        {
            "id": identifier,
            "kind": row["kind"],
            "name_symbol_id": string_ids[str(row["name"])],
            "binding_id": row["binding_id"],
            "declaration_function_id": row["declaration_function_id"],
            "implementation_function_id": row["implementation_function_id"],
        }
        for identifier, row in enumerate(extern_rows)
    ]
    extern_by_function = {
        int(row["declaration_function_id"]): int(row["id"]) for row in externs
    }

    functions: list[dict[str, object]] = []
    for function_id, row in enumerate(function_rows):
        fields: dict[str, int] = row["fields"]  # type: ignore[assignment]
        args = [
            _typed_identifier(arena, item, identifier, string_ids)
            for identifier, item in enumerate(arena.sequence(fields["args"], "list"))
        ]
        parameters = [
            _parameter(arena, item, identifier, string_ids)
            for identifier, item in enumerate(
                arena.sequence(fields["parameters"], "list")
            )
        ]
        functions.append(
            {
                "id": function_id,
                "name_symbol_id": string_ids[str(row["name"])],
                "declaration_node": row["declaration_node"],
                "arguments": args,
                "parameters": parameters,
                "return_type_node": _type_reference(
                    arena, arena.option(fields["return_type"])
                ),
                "body_node": fields["body"],
                "subprogram_type_node": fields["subprogram_type"],
                "recurse_limit_node": arena.option(fields["recurse_limit"]),
                "extern_id": extern_by_function.get(function_id),
            }
        )

    call_sites: list[dict[str, int]] = []
    graph = {identifier: set() for identifier in range(len(functions))}
    declaration_owner: dict[int, int] = {}
    for function_id, row in enumerate(function_rows):
        fields: dict[str, int] = row["fields"]  # type: ignore[assignment]
        for identifier in arena.descendants(fields["body"]):
            declaration_owner[identifier] = function_id
    for node_id, node in enumerate(arena.nodes):
        if node.get("name") not in {"E_Call", "S_Call"}:
            continue
        argument = arena.constructor_argument(node_id, str(node["name"]))
        fields = arena.record(int(argument))
        target_name = arena.string(fields["name"])
        if target_name not in function_ids:
            raise ModelgenError(f"unresolved call target {target_name!r}")
        target_id = function_ids[target_name]
        owner = declaration_owner.get(node_id)
        if owner is None:
            raise ModelgenError(f"call node {node_id} is outside a function body")
        graph[owner].add(target_id)
        call_sites.append(
            {"node_id": node_id, "caller_function_id": owner, "target_function_id": target_id}
        )
    call_sites.sort(key=lambda row: int(row["node_id"]))

    call_graph = [
        {"id": function_id, "callee_function_ids": sorted(graph[function_id])}
        for function_id in sorted(graph)
    ]

    for component in _recursive_components(graph):
        unbounded = sorted(
            function_id
            for function_id in component
            if functions[function_id]["recurse_limit_node"] is None
        )
        if unbounded:
            names = [str(function_rows[identifier]["name"]) for identifier in unbounded]
            raise ModelgenError(f"unbounded recursion: {', '.join(names)}")

    required = sorted(set(required_entrypoints))
    missing = [name for name in required if name not in function_ids]
    if missing:
        raise ModelgenError(f"missing executable entrypoints: {', '.join(missing)}")
    entrypoints = [
        {"id": identifier, "name_symbol_id": string_ids[name], "function_id": function_ids[name]}
        for identifier, name in enumerate(required)
    ]

    state_access_sites: list[dict[str, int]] = []
    for node_id, node in enumerate(arena.nodes):
        if node.get("name") not in {"E_Var", "LE_Var"}:
            continue
        argument = arena.constructor_argument(node_id, str(node["name"]))
        name = arena.string(int(argument))
        if name in state_ids:
            state_access_sites.append(
                {"node_id": node_id, "state_field_id": state_ids[name]}
            )

    unhandled_constructs = sorted(set(constructor_names))
    capabilities = {
        "lowering_complete": True,
        "link_closure_verified": True,
        "execution_ready": False,
        "runtime_handler_constructor_count": 0,
        "required_constructor_count": len(unhandled_constructs),
        "runtime_handler_primitive_count": 0,
        "required_primitive_count": len(primitive_functions),
        "arbitrary_choice_policy": "unsupported-fail-closed",
        "unhandled_runtime_constructs": unhandled_constructs,
        "unhandled_runtime_primitives": sorted(name for name, _ in primitive_functions),
    }

    image: dict[str, object] = {
        "schema": EXECUTABLE_SCHEMA,
        "schema_version": EXECUTABLE_SCHEMA_VERSION,
        "source": {
            "pto_mir_sha256": hashlib.sha256(mir_bytes).hexdigest(),
            "pto_mir_schema": MIR_SCHEMA,
        },
        "tables": {
            "node_kinds": node_kind_table,
            "constructors": constructor_table,
            "fields": field_table,
            "atom_kinds": atom_kind_table,
            "strings": string_table,
            "global_kinds": global_kind_table,
            "bindings": bindings,
            "types": types,
            "globals": globals_,
            "functions": functions,
            "externs": externs,
            "entrypoints": entrypoints,
            "state_fields": state_fields,
            "call_sites": call_sites,
            "call_graph": call_graph,
            "state_access_sites": state_access_sites,
        },
        "nodes": _compact_nodes(
            arena,
            constructor_ids,
            field_ids,
            atom_kind_ids,
            string_ids,
            node_kind_ids,
        ),
        "capabilities": capabilities,
    }
    verify_executable_module(image, required_entrypoints=required)
    return image


def _verify_sequential_ids(rows: object, category: str) -> list[dict[str, object]]:
    if not isinstance(rows, list):
        raise ModelgenError(f"executable {category} table must be a list")
    if any(not isinstance(row, dict) for row in rows):
        raise ModelgenError(f"executable {category} table contains a malformed row")
    identifiers = [row.get("id") for row in rows]
    if identifiers != list(range(len(rows))):
        raise ModelgenError(f"duplicate or non-sequential {category} ID")
    return rows  # type: ignore[return-value]


def verify_executable_module(
    image: dict[str, object], *, required_entrypoints: Iterable[str] = DEFAULT_ENTRYPOINTS
) -> None:
    if set(image) != {
        "schema",
        "schema_version",
        "source",
        "tables",
        "nodes",
        "capabilities",
    }:
        raise ModelgenError("executable module root is malformed")
    if (
        image["schema"] != EXECUTABLE_SCHEMA
        or image["schema_version"] != EXECUTABLE_SCHEMA_VERSION
    ):
        raise ModelgenError("executable module schema mismatch")
    tables = image["tables"]
    if not isinstance(tables, dict):
        raise ModelgenError("executable module tables are malformed")
    required_tables = {
        "node_kinds",
        "constructors",
        "fields",
        "atom_kinds",
        "strings",
        "global_kinds",
        "bindings",
        "types",
        "globals",
        "functions",
        "externs",
        "entrypoints",
        "state_fields",
        "call_sites",
        "call_graph",
        "state_access_sites",
    }
    if set(tables) != required_tables:
        raise ModelgenError("executable module table set is incomplete")

    indexed = {
        name: _verify_sequential_ids(tables[name], name)
        for name in (
            "node_kinds",
            "constructors",
            "fields",
            "atom_kinds",
            "strings",
            "global_kinds",
            "bindings",
            "types",
            "globals",
            "functions",
            "externs",
            "entrypoints",
            "state_fields",
            "call_graph",
        )
    }
    for name in ("node_kinds", "constructors", "fields", "atom_kinds", "strings"):
        values = [row.get("name") for row in indexed[name]]
        if len(values) != len(set(values)):
            raise ModelgenError(f"duplicate executable {name} name")

    nodes = image["nodes"]
    if not isinstance(nodes, list):
        raise ModelgenError("executable node image must be a list")
    node_kind_names = {row["id"]: row["name"] for row in indexed["node_kinds"]}
    constructor_names = {row["id"]: row["name"] for row in indexed["constructors"]}
    field_ids = {int(row["id"]) for row in indexed["fields"]}
    atom_kind_ids = {int(row["id"]) for row in indexed["atom_kinds"]}
    string_ids = {int(row["id"]) for row in indexed["strings"]}

    def reference(value: object) -> None:
        if not isinstance(value, int) or value < 0 or value >= len(nodes):
            raise ModelgenError("dangling executable node reference")

    call_node_ids: set[int] = set()
    state_node_ids: set[int] = set()
    type_node_ids: set[int] = set()
    for node_id, node in enumerate(nodes):
        if not isinstance(node, list) or not node or node[0] not in node_kind_names:
            raise ModelgenError(f"executable node {node_id} is malformed")
        kind = node_kind_names[node[0]]
        if kind == "atom":
            if len(node) != 3 or node[1] not in atom_kind_ids:
                raise ModelgenError(f"executable atom {node_id} is malformed")
            atom_kind = indexed["atom_kinds"][node[1]]["name"]
            if atom_kind == "string" and node[2] not in string_ids:
                raise ModelgenError(f"executable atom {node_id} has invalid string ID")
        elif kind == "constructor":
            if (
                len(node) != 3
                or node[1] not in constructor_names
                or not isinstance(node[2], list)
            ):
                raise ModelgenError(f"executable constructor {node_id} is malformed")
            for child in node[2]:
                reference(child)
            name = constructor_names[node[1]]
            if name in {"E_Call", "S_Call"}:
                call_node_ids.add(node_id)
            if name in {"E_Var", "LE_Var"}:
                state_node_ids.add(node_id)
            if str(name).startswith("T_"):
                type_node_ids.add(node_id)
        elif kind in {"list", "tuple"}:
            if len(node) != 2 or not isinstance(node[1], list):
                raise ModelgenError(f"executable sequence {node_id} is malformed")
            for child in node[1]:
                reference(child)
        elif kind == "record":
            if len(node) != 2 or not isinstance(node[1], list):
                raise ModelgenError(f"executable record {node_id} is malformed")
            for field in node[1]:
                if (
                    not isinstance(field, list)
                    or len(field) != 2
                    or field[0] not in field_ids
                ):
                    raise ModelgenError(f"executable record {node_id} has invalid field")
                reference(field[1])
        elif kind == "option":
            if len(node) != 2:
                raise ModelgenError(f"executable option {node_id} is malformed")
            if node[1] is not None:
                reference(node[1])
        else:
            raise ModelgenError(f"unknown executable node kind {kind!r}")

    functions = indexed["functions"]
    function_ids = {int(row["id"]) for row in functions}
    extern_ids = {int(row["id"]) for row in indexed["externs"]}
    for function in functions:
        for key in ("declaration_node", "body_node", "subprogram_type_node"):
            reference(function.get(key))
        for key in ("return_type_node", "recurse_limit_node"):
            if function.get(key) is not None:
                reference(function[key])
        if function.get("return_type_node") is not None and function["return_type_node"] not in type_node_ids:
            raise ModelgenError("function return type is not a type node")
        if function.get("extern_id") is not None and function["extern_id"] not in extern_ids:
            raise ModelgenError("function references an unknown extern")
        for category in ("arguments", "parameters"):
            rows = function.get(category)
            if not isinstance(rows, list) or [row.get("id") for row in rows] != list(
                range(len(rows))
            ):
                raise ModelgenError(f"function {category} IDs are malformed")
            for row in rows:
                if row.get("name_symbol_id") not in string_ids:
                    raise ModelgenError(f"function {category} has invalid name symbol")
                if row.get("type_node") is not None and row["type_node"] not in type_node_ids:
                    raise ModelgenError(f"function {category} has invalid type")

    binding_ids = {int(row["id"]) for row in indexed["bindings"]}
    for binding in indexed["bindings"]:
        if binding.get("name_symbol_id") not in string_ids:
            raise ModelgenError("binding has invalid name symbol")
        if binding.get("kind") not in {"impdef", "literal_helper", "primitive"}:
            raise ModelgenError("binding has unknown kind")
    for extern in indexed["externs"]:
        if extern.get("binding_id") not in binding_ids:
            raise ModelgenError("extern references an unknown binding")
        if extern.get("declaration_function_id") not in function_ids:
            raise ModelgenError("extern declaration function is unresolved")
        implementation = extern.get("implementation_function_id")
        if implementation is not None and implementation not in function_ids:
            raise ModelgenError("extern implementation function is unresolved")
        if extern.get("kind") == "impdef" and implementation is None:
            name_symbol = extern.get("name_symbol_id")
            if name_symbol not in string_ids:
                raise ModelgenError("extern has invalid name symbol")
            name = indexed["strings"][name_symbol]["name"]
            if name not in EXTERNAL_IMPDEF_BINDINGS:
                raise ModelgenError("unresolved impdef extern")

    call_sites = tables["call_sites"]
    if not isinstance(call_sites, list):
        raise ModelgenError("call-site table is malformed")
    seen_calls: set[int] = set()
    for call in call_sites:
        if not isinstance(call, dict):
            raise ModelgenError("call-site row is malformed")
        node_id = call.get("node_id")
        if node_id in seen_calls or node_id not in call_node_ids:
            raise ModelgenError("duplicate or invalid call-site node")
        seen_calls.add(node_id)
        if call.get("caller_function_id") not in function_ids:
            raise ModelgenError("call site has invalid caller")
        if call.get("target_function_id") not in function_ids:
            raise ModelgenError("call site has unresolved target")
    if seen_calls != call_node_ids:
        raise ModelgenError("call-site closure is incomplete")

    graph_from_sites = {function_id: set() for function_id in function_ids}
    for call in call_sites:
        graph_from_sites[int(call["caller_function_id"])].add(
            int(call["target_function_id"])
        )
    for row in indexed["call_graph"]:
        function_id = int(row["id"])
        callees = row.get("callee_function_ids")
        if not isinstance(callees, list) or any(
            callee not in function_ids for callee in callees
        ):
            raise ModelgenError("call graph has unresolved target")
        if callees != sorted(set(callees)):
            raise ModelgenError("call graph is not canonical")
        if set(callees) != graph_from_sites[function_id]:
            raise ModelgenError("call-graph closure is incomplete")

    global_ids = {int(row["id"]) for row in indexed["globals"]}
    global_kind_ids = {int(row["id"]) for row in indexed["global_kinds"]}
    for row in indexed["types"]:
        if row.get("name_symbol_id") not in string_ids:
            raise ModelgenError("type has invalid name symbol")
        reference(row.get("declaration_node"))
        definition = row.get("definition_node")
        reference(definition)
        if definition not in type_node_ids:
            raise ModelgenError("type definition is not a type node")
    for row in indexed["globals"]:
        if row.get("name_symbol_id") not in string_ids:
            raise ModelgenError("global has invalid name symbol")
        reference(row.get("declaration_node"))
        if row.get("global_kind_id") not in global_kind_ids:
            raise ModelgenError("global has invalid storage kind")
        type_node = row.get("type_node")
        if type_node is not None and type_node not in type_node_ids:
            raise ModelgenError("global has invalid type")
        initializer = row.get("initializer_node")
        if initializer is not None:
            reference(initializer)
    state_ids = {int(row["id"]) for row in indexed["state_fields"]}
    for state in indexed["state_fields"]:
        if state.get("global_id") not in global_ids:
            raise ModelgenError("state field has unresolved global")
    seen_state_sites: set[int] = set()
    for site in tables["state_access_sites"]:
        if not isinstance(site, dict):
            raise ModelgenError("state-access row is malformed")
        node_id = site.get("node_id")
        if node_id in seen_state_sites or node_id not in state_node_ids:
            raise ModelgenError("duplicate or invalid state-access node")
        seen_state_sites.add(node_id)
        if site.get("state_field_id") not in state_ids:
            raise ModelgenError("state access has unresolved state field")

    entrypoint_names: set[str] = set()
    for entrypoint in indexed["entrypoints"]:
        if entrypoint.get("function_id") not in function_ids:
            raise ModelgenError("entrypoint has unresolved function")
        name_symbol = entrypoint.get("name_symbol_id")
        if name_symbol not in string_ids:
            raise ModelgenError("entrypoint has invalid name symbol")
        entrypoint_names.add(str(indexed["strings"][name_symbol]["name"]))
    missing = sorted(set(required_entrypoints) - entrypoint_names)
    if missing:
        raise ModelgenError(f"entrypoint closure is incomplete: {', '.join(missing)}")

    capabilities = image["capabilities"]
    if not isinstance(capabilities, dict):
        raise ModelgenError("executable capabilities are malformed")
    if capabilities.get("execution_ready") is not False:
        raise ModelgenError("G3a executable module must not claim execution readiness")
    unhandled = capabilities.get("unhandled_runtime_constructs")
    if not isinstance(unhandled, list):
        raise ModelgenError("unhandled runtime construct inventory is missing")
    if "E_Arbitrary" in set(constructor_names.values()) and "E_Arbitrary" not in unhandled:
        raise ModelgenError("E_Arbitrary must remain fail-closed in G3a")


def render_executable_module(image: dict[str, object]) -> bytes:
    return (json.dumps(image, sort_keys=True, separators=(",", ":")) + "\n").encode(
        "utf-8"
    )


def build_executable_readiness(
    *,
    mir_bytes: bytes,
    schema_bytes: bytes,
    image_bytes: bytes,
    image: dict[str, object],
) -> dict[str, object]:
    tables: dict[str, list[object]] = image["tables"]  # type: ignore[assignment]
    return {
        "schema": "pto.functional-model-executable-mir-readiness.v1",
        "input_mir": {
            "sha256": hashlib.sha256(mir_bytes).hexdigest(),
            "size_bytes": len(mir_bytes),
        },
        "executable_schema": {
            "id": EXECUTABLE_SCHEMA_ID,
            "sha256": hashlib.sha256(schema_bytes).hexdigest(),
            "version": EXECUTABLE_SCHEMA_VERSION,
        },
        "model_image": {
            "sha256": hashlib.sha256(image_bytes).hexdigest(),
            "size_bytes": len(image_bytes),
        },
        "table_counts": {name: len(rows) for name, rows in sorted(tables.items())},
        "node_count": len(image["nodes"]),  # type: ignore[arg-type]
        "capabilities": image["capabilities"],
        "verified_closure": {
            "node_references": True,
            "types": True,
            "calls": True,
            "externs": True,
            "entrypoints": True,
            "state_fields": True,
            "loop_limits": True,
            "recursion_limits": True,
        },
        "unhandled_runtime_constructs": image["capabilities"][  # type: ignore[index]
            "unhandled_runtime_constructs"
        ],
    }


def render_executable_readiness(readiness: dict[str, object]) -> str:
    return json.dumps(readiness, indent=2, sort_keys=True) + "\n"

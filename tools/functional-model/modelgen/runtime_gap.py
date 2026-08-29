"""Exact static runtime-gap inventory over linked executable PTO MIR."""

from __future__ import annotations

from collections import Counter, deque
import hashlib
import json
from typing import Iterable, Iterator

from pto_executable_mir import ModelgenError, verify_executable_module


GAP_SCHEMA = "pto-functional-model-step-runtime-gap-v1"
CAPABILITY_SCHEMA = "pto-functional-model-runtime-capabilities-v1"
ROOT_ENTRYPOINTS = (
    "InitializeFunctionalModel",
    "ExecuteOnePTOStep",
    "CompleteFunctionalModelHostRequest",
)
SCALAR_ELF_MNEMONICS = ("C.MOVI", "ADD", "HL.XORI", "L.BSTOP")


class ExecutableArena:
    def __init__(self, image: dict[str, object]):
        tables = image["tables"]
        self.nodes: list[list[object]] = image["nodes"]  # type: ignore[assignment]
        self.kinds = [row["name"] for row in tables["node_kinds"]]
        self.constructors = [row["name"] for row in tables["constructors"]]
        self.fields = [row["name"] for row in tables["fields"]]

    def kind(self, identifier: int) -> str:
        self._check(identifier)
        kind_id = self.nodes[identifier][0]
        if not isinstance(kind_id, int) or kind_id < 0 or kind_id >= len(self.kinds):
            raise ModelgenError(f"node {identifier} has unknown node-kind ID")
        return str(self.kinds[kind_id])

    def constructor_name(self, identifier: int) -> str:
        if self.kind(identifier) != "constructor":
            raise ModelgenError(f"node {identifier} is not a constructor")
        constructor_id = self.nodes[identifier][1]
        if (
            not isinstance(constructor_id, int)
            or constructor_id < 0
            or constructor_id >= len(self.constructors)
        ):
            raise ModelgenError(f"node {identifier} has unknown constructor ID")
        return str(self.constructors[constructor_id])

    def references(self, identifier: int) -> Iterator[int]:
        kind = self.kind(identifier)
        node = self.nodes[identifier]
        if kind == "constructor":
            values = node[2]
        elif kind in {"list", "tuple"}:
            values = node[1]
        elif kind == "record":
            values = [field[1] for field in node[1]]  # type: ignore[index]
        elif kind == "option":
            values = [] if node[1] is None else [node[1]]
        else:
            values = []
        if not isinstance(values, list):
            raise ModelgenError(f"node {identifier} has malformed references")
        for value in values:
            if not isinstance(value, int):
                raise ModelgenError(f"node {identifier} has non-numeric reference")
            self._check(value)
            yield value

    def descendants(self, roots: Iterable[int]) -> set[int]:
        reachable: set[int] = set()
        pending = list(roots)
        while pending:
            identifier = pending.pop()
            self._check(identifier)
            if identifier in reachable:
                continue
            reachable.add(identifier)
            pending.extend(self.references(identifier))
        return reachable

    def constructor_argument(self, identifier: int, expected: str) -> int:
        if self.constructor_name(identifier) != expected:
            raise ModelgenError(f"node {identifier} must be {expected}")
        values = list(self.references(identifier))
        if len(values) != 1:
            raise ModelgenError(f"node {identifier} must have one argument")
        return values[0]

    def sequence(self, identifier: int, expected: str) -> list[int]:
        if self.kind(identifier) != expected or expected not in {"list", "tuple"}:
            raise ModelgenError(f"node {identifier} must be a {expected}")
        return list(self.references(identifier))

    def _check(self, identifier: int) -> None:
        if identifier < 0 or identifier >= len(self.nodes):
            raise ModelgenError(f"dangling node reference {identifier}")


def load_runtime_capabilities(content: bytes) -> dict[str, object]:
    try:
        document = json.loads(content)
    except (UnicodeDecodeError, json.JSONDecodeError) as error:
        raise ModelgenError(f"runtime capability manifest is invalid: {error}") from error
    required = {
        "schema",
        "entrypoints",
        "constructors",
        "primitive_bindings",
        "extern_bindings",
        "impdef_bindings",
        "emitter_bytecode_opcodes",
        "interpreter_bytecode_opcodes",
    }
    if document.get("schema") != CAPABILITY_SCHEMA or set(document) != required:
        raise ModelgenError("runtime capability manifest is malformed")
    constructors = document["constructors"]
    categories = {
        "expressions",
        "literals",
        "local_declarations",
        "lvalues",
        "operators",
        "slices",
        "statements",
        "types",
    }
    if not isinstance(constructors, dict) or set(constructors) != categories:
        raise ModelgenError("runtime constructor capability table is malformed")
    lists = [
        document["entrypoints"],
        document["primitive_bindings"],
        document["extern_bindings"],
        document["impdef_bindings"],
        document["emitter_bytecode_opcodes"],
        document["interpreter_bytecode_opcodes"],
        *constructors.values(),
    ]
    for values in lists:
        if (
            not isinstance(values, list)
            or any(not isinstance(value, str) for value in values)
            or values != sorted(set(values))
        ):
            raise ModelgenError("runtime capability rows must be sorted and unique")
    if not set(document["emitter_bytecode_opcodes"]).issubset(
        document["interpreter_bytecode_opcodes"]
    ):
        raise ModelgenError("runtime emitter opcode lacks an interpreter handler")
    return document


def _string_tables(image: dict[str, object]) -> tuple[list[str], dict[str, int]]:
    strings = [str(row["name"]) for row in image["tables"]["strings"]]  # type: ignore[index]
    if len(strings) != len(set(strings)):
        raise ModelgenError("executable string table contains duplicates")
    return strings, {name: identifier for identifier, name in enumerate(strings)}


def _entrypoint_roots(
    image: dict[str, object], strings: list[str]
) -> tuple[list[dict[str, object]], list[int]]:
    entrypoints = image["tables"]["entrypoints"]  # type: ignore[index]
    by_name: dict[str, dict[str, object]] = {}
    for row in entrypoints:
        name = strings[int(row["name_symbol_id"])]
        if name in by_name:
            raise ModelgenError(f"duplicate numeric entrypoint {name!r}")
        by_name[name] = row
    missing = [name for name in ROOT_ENTRYPOINTS if name not in by_name]
    if missing:
        raise ModelgenError(f"missing runtime-gap entrypoints: {', '.join(missing)}")
    rows = [by_name[name] for name in ROOT_ENTRYPOINTS]
    function_ids = [int(row["function_id"]) for row in rows]
    if len(function_ids) != len(set(function_ids)):
        raise ModelgenError("runtime-gap entrypoints do not resolve uniquely")
    return rows, function_ids


def reachable_function_ids(
    call_graph_rows: object, roots: Iterable[int], function_count: int
) -> set[int]:
    if not isinstance(call_graph_rows, list) or len(call_graph_rows) != function_count:
        raise ModelgenError("numeric call graph is incomplete")
    graph: dict[int, list[int]] = {}
    for expected_id, row in enumerate(call_graph_rows):
        if not isinstance(row, dict) or row.get("id") != expected_id:
            raise ModelgenError("numeric call graph has duplicate or missing ID")
        callees = row.get("callee_function_ids")
        if not isinstance(callees, list) or callees != sorted(set(callees)):
            raise ModelgenError("numeric call graph row is not canonical")
        if any(
            not isinstance(callee, int) or callee < 0 or callee >= function_count
            for callee in callees
        ):
            raise ModelgenError("numeric call graph has dangling call target")
        graph[expected_id] = callees
    reachable: set[int] = set()
    pending = deque(roots)
    while pending:
        function_id = pending.popleft()
        if function_id < 0 or function_id >= function_count:
            raise ModelgenError("runtime-gap root has dangling function ID")
        if function_id in reachable:
            continue
        reachable.add(function_id)
        pending.extend(graph[function_id])
    return reachable


def _ranges(values: set[int]) -> list[list[int]]:
    ordered = sorted(values)
    if not ordered:
        return []
    ranges: list[list[int]] = []
    start = previous = ordered[0]
    for value in ordered[1:]:
        if value != previous + 1:
            ranges.append([start, previous])
            start = value
        previous = value
    ranges.append([start, previous])
    return ranges


def _digest_ids(values: set[int]) -> str:
    canonical = ",".join(str(value) for value in sorted(values)).encode("ascii")
    return hashlib.sha256(canonical).hexdigest()


def _inventory(
    names: Iterable[tuple[str, int, int | None]],
) -> list[dict[str, object]]:
    rows: dict[str, dict[str, object]] = {}
    for name, node_id, function_id in names:
        row = rows.setdefault(
            name,
            {
                "name": name,
                "count": 0,
                "sample_node_id": node_id,
                "sample_function_id": function_id,
            },
        )
        row["count"] = int(row["count"]) + 1
        if node_id < int(row["sample_node_id"]):
            row["sample_node_id"] = node_id
            row["sample_function_id"] = function_id
    return [rows[name] for name in sorted(rows)]


def _catalog_rows(
    scalar_catalog: dict[str, object], command_catalog: dict[str, object]
) -> list[dict[str, object]]:
    selected: list[dict[str, object]] = []
    for document in (scalar_catalog, command_catalog):
        forms = document.get("forms")
        if not isinstance(forms, list):
            raise ModelgenError("instruction catalog has no forms list")
        for row in forms:
            if isinstance(row, dict) and row.get("mnemonic") in SCALAR_ELF_MNEMONICS:
                selected.append(row)
    counts = Counter(str(row["mnemonic"]) for row in selected)
    if counts != Counter(SCALAR_ELF_MNEMONICS):
        raise ModelgenError("minimal scalar ELF catalog forms are not unique")
    return sorted(selected, key=lambda row: SCALAR_ELF_MNEMONICS.index(str(row["mnemonic"])))


def build_runtime_gap(
    image: dict[str, object],
    *,
    image_bytes: bytes,
    capability_bytes: bytes,
    scalar_catalog: dict[str, object],
    command_catalog: dict[str, object],
) -> dict[str, object]:
    verify_executable_module(image, required_entrypoints=ROOT_ENTRYPOINTS)
    capabilities = load_runtime_capabilities(capability_bytes)
    tables = image["tables"]
    strings, _ = _string_tables(image)
    arena = ExecutableArena(image)
    constructor_names = set(arena.constructors)

    declared_handlers = {
        name
        for rows in capabilities["constructors"].values()  # type: ignore[union-attr]
        for name in rows
    }
    unknown_handlers = sorted(declared_handlers - constructor_names)
    if unknown_handlers:
        raise ModelgenError(
            f"runtime capability declares unknown handlers: {', '.join(unknown_handlers)}"
        )

    root_rows, root_function_ids = _entrypoint_roots(image, strings)
    functions = tables["functions"]
    reachable_functions = reachable_function_ids(
        tables["call_graph"], root_function_ids, len(functions)
    )

    owner: dict[int, int] = {}
    signature_roots: list[int] = []
    body_roots: list[int] = []
    for function_id in sorted(reachable_functions):
        function = functions[function_id]
        body = int(function["body_node"])
        body_roots.append(body)
        roots = [body, int(function["subprogram_type_node"])]
        for key in ("return_type_node", "recurse_limit_node"):
            value = function[key]
            if value is not None:
                roots.append(int(value))
        roots.extend(
            int(argument["type_node"])
            for argument in function["arguments"]
            if argument["type_node"] is not None
        )
        roots.extend(
            int(parameter["type_node"])
            for parameter in function["parameters"]
            if parameter["type_node"] is not None
        )
        signature_roots.extend(roots[1:])
        for node_id in arena.descendants(roots):
            previous = owner.setdefault(node_id, function_id)
            if previous != function_id:
                raise ModelgenError("executable nodes are shared across function owners")

    reachable_nodes = arena.descendants([*body_roots, *signature_roots])
    constructor_occurrences: list[tuple[str, int, int | None]] = []
    operator_occurrences: list[tuple[str, int, int | None]] = []
    for node_id in sorted(reachable_nodes):
        if arena.kind(node_id) != "constructor":
            continue
        name = arena.constructor_name(node_id)
        constructor_occurrences.append((name, node_id, owner.get(node_id)))
        if name in {"E_Binop", "E_Unop"}:
            argument = arena.constructor_argument(node_id, name)
            values = arena.sequence(argument, "tuple")
            operator_id = values[0]
            operator_occurrences.append(
                (arena.constructor_name(operator_id), operator_id, owner.get(node_id))
            )

    constructor_inventory = _inventory(constructor_occurrences)
    by_name = {str(row["name"]): row for row in constructor_inventory}

    def category(prefixes: tuple[str, ...]) -> list[dict[str, object]]:
        return [
            row
            for row in constructor_inventory
            if str(row["name"]).startswith(prefixes)
        ]

    expression_inventory = category(("E_",))
    statement_inventory = category(("S_", "SB_"))
    lvalue_inventory = category(("LE_",))
    type_inventory = category(("T_",))
    operator_inventory = _inventory(operator_occurrences)

    reachable_extern_ids = sorted(
        {
            int(functions[function_id]["extern_id"])
            for function_id in reachable_functions
            if functions[function_id]["extern_id"] is not None
        }
    )
    extern_rows = [tables["externs"][identifier] for identifier in reachable_extern_ids]
    binding_rows = tables["bindings"]

    def extern_inventory(kind: str) -> list[dict[str, object]]:
        rows = []
        for extern in extern_rows:
            if extern["kind"] != kind:
                continue
            binding = binding_rows[int(extern["binding_id"])]
            rows.append(
                {
                    "extern_id": extern["id"],
                    "binding_id": binding["id"],
                    "name": strings[int(binding["name_symbol_id"])],
                    "declaration_function_id": extern["declaration_function_id"],
                    "implementation_function_id": extern[
                        "implementation_function_id"
                    ],
                }
            )
        return sorted(rows, key=lambda row: (str(row["name"]), int(row["extern_id"])))

    primitives = extern_inventory("primitive")
    impdefs = extern_inventory("impdef")
    state_access_node_ids = reachable_nodes & {
        int(row["node_id"]) for row in tables["state_access_sites"]
    }
    state_field_ids = sorted(
        {
            int(row["state_field_id"])
            for row in tables["state_access_sites"]
            if int(row["node_id"]) in state_access_node_ids
        }
    )
    state_fields = [
        {
            "id": identifier,
            "name": strings[int(tables["state_fields"][identifier]["name_symbol_id"])],
            "global_id": tables["state_fields"][identifier]["global_id"],
            "sample_access_node_id": min(
                int(row["node_id"])
                for row in tables["state_access_sites"]
                if int(row["state_field_id"]) == identifier
                and int(row["node_id"]) in state_access_node_ids
            ),
        }
        for identifier in state_field_ids
    ]

    supported_constructors = declared_handlers
    reachable_constructor_names = set(by_name)
    unhandled_constructors = sorted(reachable_constructor_names - supported_constructors)
    supported_primitive_names = set(capabilities["primitive_bindings"])
    supported_extern_names = set(capabilities["extern_bindings"])
    supported_impdef_names = set(capabilities["impdef_bindings"])

    arbitrary = []
    for name, node_id, function_id in constructor_occurrences:
        if name != "E_Arbitrary":
            continue
        arbitrary.append(
            {
                "node_id": node_id,
                "function_id": function_id,
                "function_name": (
                    strings[int(functions[function_id]["name_symbol_id"])]
                    if function_id is not None
                    else None
                ),
                "static_call_graph_reachable": True,
                "runtime_path_reachability": "not-proven-path-controlled",
                "runtime_policy": "fail-closed",
            }
        )

    catalog_rows = _catalog_rows(scalar_catalog, command_catalog)
    function_name_to_id = {
        strings[int(row["name_symbol_id"])]: int(row["id"]) for row in functions
    }
    string_names = set(strings)

    function_rows = [
        {
            "id": function_id,
            "name": strings[int(functions[function_id]["name_symbol_id"])],
        }
        for function_id in sorted(reachable_functions)
    ]
    return {
        "schema": GAP_SCHEMA,
        "inputs": {
            "executable_mir": {
                "sha256": hashlib.sha256(image_bytes).hexdigest(),
                "size_bytes": len(image_bytes),
            },
            "runtime_capabilities": {
                "sha256": hashlib.sha256(capability_bytes).hexdigest(),
                "schema": CAPABILITY_SCHEMA,
            },
        },
        "roots": [
            {
                "entrypoint_id": row["id"],
                "function_id": row["function_id"],
                "name": name,
            }
            for name, row in zip(ROOT_ENTRYPOINTS, root_rows)
        ],
        "reachable_functions": {
            "count": len(reachable_functions),
            "ids_sha256": _digest_ids(reachable_functions),
            "functions": function_rows,
        },
        "reachable_nodes": {
            "count": len(reachable_nodes),
            "ids_sha256": _digest_ids(reachable_nodes),
            "id_ranges": _ranges(reachable_nodes),
        },
        "reachable_constructs": {
            "constructors": constructor_inventory,
            "statements": statement_inventory,
            "expressions": expression_inventory,
            "lvalues": lvalue_inventory,
            "types": type_inventory,
            "operators": operator_inventory,
            "constructor_kind_count": len(constructor_inventory),
            "constructor_node_count": sum(
                int(row["count"]) for row in constructor_inventory
            ),
        },
        "reachable_bindings": {
            "primitive": primitives,
            "extern": [
                row
                for row in [*primitives, *impdefs]
                if row["implementation_function_id"] is None
            ],
            "impdef": impdefs,
        },
        "reachable_state_fields": {
            "count": len(state_fields),
            "fields": state_fields,
        },
        "runtime_capability": capabilities,
        "unhandled": {
            "constructors": [by_name[name] for name in unhandled_constructors],
            "primitive_bindings": [
                row for row in primitives if row["name"] not in supported_primitive_names
            ],
            "extern_bindings": [
                row
                for row in [*primitives, *impdefs]
                if row["implementation_function_id"] is None
                and row["name"] not in supported_extern_names
            ],
            "impdef_bindings": [
                row for row in impdefs if row["name"] not in supported_impdef_names
            ],
        },
        "arbitrary_choice_sites": arbitrary,
        "minimal_scalar_elf": {
            "mnemonics": list(SCALAR_ELF_MNEMONICS),
            "catalog_forms": [
                {
                    "mnemonic": row["mnemonic"],
                    "form_id": row["form_id"],
                    "length_bits": row["length_bits"],
                    "semantic_handler": row["semantic_handler"],
                    "semantic_handler_function_id": function_name_to_id.get(
                        str(row["semantic_handler"])
                    ),
                    "dispatch_symbol": next(
                        (
                            candidate
                            for candidate in (
                                str(row["semantic_handler"]),
                                "CommandHandler_" + str(row["semantic_handler"]),
                            )
                            if candidate in string_names
                        ),
                        None,
                    ),
                }
                for row in catalog_rows
            ],
            "static_slice_status": "not-safely-statically-sliceable",
            "reason": (
                "The numeric call graph is function-granular. Shared decoder functions "
                "contain all form branches, so catalog-selected handlers are a necessary "
                "lower bound but cannot prove a sufficient path-sensitive subclosure."
            ),
            "claimed_subclosure": None,
        },
    }


def render_runtime_gap(document: dict[str, object]) -> str:
    return json.dumps(document, indent=2, sort_keys=True) + "\n"

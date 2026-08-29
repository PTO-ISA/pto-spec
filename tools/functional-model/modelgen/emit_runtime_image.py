#!/usr/bin/env python3
"""Emit the deterministic G3a runtime subset from executable PTO MIR."""

from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
import sys


MODELGEN = Path(__file__).resolve().parent
if str(MODELGEN) not in sys.path:
    sys.path.insert(0, str(MODELGEN))

from pto_executable_mir import ModelgenError, verify_executable_module  # noqa: E402


ENTRYPOINT = "DeterminePTOInstructionLength"
CASES_SCHEMA = "pto-functional-model-determine-length-cases-v1"
CAPABILITIES_SCHEMA = "pto-functional-model-runtime-capabilities-v1"
CAPABILITIES_PATH = MODELGEN / "runtime-capabilities-v1.json"


def _load_capabilities() -> dict[str, object]:
    document = json.loads(CAPABILITIES_PATH.read_bytes())
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
    if document.get("schema") != CAPABILITIES_SCHEMA or set(document) != required:
        raise ModelgenError("runtime capability manifest is malformed")
    constructors = document["constructors"]
    if not isinstance(constructors, dict) or set(constructors) != {
        "expressions",
        "literals",
        "lvalues",
        "operators",
        "slices",
        "statements",
        "types",
    }:
        raise ModelgenError("runtime constructor capabilities are malformed")
    for values in [
        document["entrypoints"],
        document["primitive_bindings"],
        document["extern_bindings"],
        document["impdef_bindings"],
        document["emitter_bytecode_opcodes"],
        document["interpreter_bytecode_opcodes"],
        *constructors.values(),
    ]:
        if not isinstance(values, list) or values != sorted(set(values)):
            raise ModelgenError("runtime capabilities must be sorted and unique")
    if not set(document["emitter_bytecode_opcodes"]).issubset(
        document["interpreter_bytecode_opcodes"]
    ):
        raise ModelgenError("runtime emitter opcode lacks an interpreter handler")
    return document


CAPABILITIES = _load_capabilities()
CONSTRUCTOR_CAPABILITIES: dict[str, list[str]] = CAPABILITIES[  # type: ignore[assignment]
    "constructors"
]


class CompactArena:
    def __init__(self, image: dict[str, object]):
        tables = image["tables"]
        self.nodes: list[list[object]] = image["nodes"]  # type: ignore[assignment]
        self.kinds = [row["name"] for row in tables["node_kinds"]]
        self.constructors = [row["name"] for row in tables["constructors"]]
        self.fields = [row["name"] for row in tables["fields"]]
        self.atom_kinds = [row["name"] for row in tables["atom_kinds"]]
        self.strings = [row["name"] for row in tables["strings"]]

    def kind(self, identifier: int) -> str:
        return str(self.kinds[int(self.nodes[identifier][0])])

    def constructor(self, identifier: int, expected: str | None = None) -> list[int]:
        node = self.nodes[identifier]
        if self.kind(identifier) != "constructor":
            raise ModelgenError(f"runtime node {identifier} must be a constructor")
        name = str(self.constructors[int(node[1])])
        if expected is not None and name != expected:
            raise ModelgenError(
                f"runtime node {identifier} must be {expected}, got {name}"
            )
        return [int(value) for value in node[2]]  # type: ignore[union-attr]

    def constructor_name(self, identifier: int) -> str:
        node = self.nodes[identifier]
        if self.kind(identifier) != "constructor":
            raise ModelgenError(f"runtime node {identifier} must be a constructor")
        return str(self.constructors[int(node[1])])

    def sequence(self, identifier: int, expected: str | None = None) -> list[int]:
        kind = self.kind(identifier)
        if kind not in {"list", "tuple"} or (expected is not None and kind != expected):
            raise ModelgenError(f"runtime node {identifier} must be {expected or 'sequence'}")
        return [int(value) for value in self.nodes[identifier][1]]  # type: ignore[union-attr]

    def option(self, identifier: int) -> int | None:
        if self.kind(identifier) != "option":
            raise ModelgenError(f"runtime node {identifier} must be an option")
        value = self.nodes[identifier][1]
        return None if value is None else int(value)

    def record(self, identifier: int) -> dict[str, int]:
        if self.kind(identifier) != "record":
            raise ModelgenError(f"runtime node {identifier} must be a record")
        return {
            str(self.fields[int(field_id)]): int(value)
            for field_id, value in self.nodes[identifier][1]
        }

    def atom(self, identifier: int, expected: str) -> object:
        node = self.nodes[identifier]
        if self.kind(identifier) != "atom":
            raise ModelgenError(f"runtime node {identifier} must be an atom")
        atom_kind = str(self.atom_kinds[int(node[1])])
        if atom_kind != expected:
            raise ModelgenError(
                f"runtime atom {identifier} must be {expected}, got {atom_kind}"
            )
        value = node[2]
        return self.strings[int(value)] if expected == "string" else value


class Compiler:
    def __init__(
        self,
        arena: CompactArena,
        argument_names: list[str],
        function_ids: dict[str, int] | None = None,
        global_ids: dict[str, int] | None = None,
        field_ids: dict[str, int] | None = None,
        enum_labels: dict[str, tuple[int, int]] | None = None,
        extern_ids: dict[str, tuple[int, str, int]] | None = None,
    ):
        self.arena = arena
        self.argument_ids = {name: index for index, name in enumerate(argument_names)}
        self.instructions: list[dict[str, int | str]] = []
        self.next_local = 0
        self.function_ids = function_ids or {}
        self.global_ids = global_ids or {}
        self.local_ids: dict[str, int] = {}
        self.field_ids = field_ids or {}
        self.enum_labels = enum_labels or {}
        self.extern_ids = extern_ids or {}

    def local(self) -> int:
        result = self.next_local
        self.next_local += 1
        return result

    def emit(self, opcode: str, **fields: int) -> int:
        if opcode not in CAPABILITIES["emitter_bytecode_opcodes"]:
            raise ModelgenError(f"bytecode opcode {opcode!r} is not declared")
        instruction: dict[str, int | str] = {
            "opcode": opcode,
            "binding": 0,
            "local": 0,
            "immediate": 0,
            "address": 0,
        }
        instruction.update(fields)
        self.instructions.append(instruction)
        return len(self.instructions) - 1

    def single_argument(self, identifier: int, expected: str) -> int:
        values = self.arena.constructor(identifier, expected)
        if len(values) != 1:
            raise ModelgenError(f"runtime {expected} node must have one argument")
        return values[0]

    def literal_integer(self, identifier: int) -> int:
        literal = self.single_argument(identifier, "E_Literal")
        integer = self.single_argument(literal, "L_Int")
        return int(str(self.arena.atom(integer, "integer")), 10)

    def expression(self, identifier: int) -> int:
        name = self.arena.constructor_name(identifier)
        if name not in CONSTRUCTOR_CAPABILITIES["expressions"]:
            raise ModelgenError(
                f"unsupported reachable runtime expression {name} at node {identifier}"
            )
        if name == "E_Var":
            atom = self.single_argument(identifier, "E_Var")
            variable = str(self.arena.atom(atom, "string"))
            target = self.local()
            if variable in self.local_ids:
                self.emit("kCopyValue", local=target, binding=self.local_ids[variable])
                return target
            if variable in self.global_ids:
                self.emit("kLoadGlobal", local=target, binding=self.global_ids[variable])
                return target
            if variable not in self.argument_ids:
                raise ModelgenError(f"unsupported runtime variable {variable!r}")
            self.emit(
                "kLoadArgumentBits",
                local=target,
                binding=self.argument_ids[variable],
                immediate=16,
            )
            return target
        if name == "E_Literal":
            literal = self.single_argument(identifier, "E_Literal")
            literal_name = self.arena.constructor_name(literal)
            if literal_name not in CONSTRUCTOR_CAPABILITIES["literals"]:
                raise ModelgenError(f"unsupported runtime literal {literal_name}")
            target = self.local()
            if literal_name == "L_Int":
                atom = self.single_argument(literal, "L_Int")
                value = int(str(self.arena.atom(atom, "integer")), 10)
                if value < 0 or value > (1 << 64) - 1:
                    raise ModelgenError("runtime integer literal exceeds G3a carrier")
                self.emit("kLoadIntegerImmediate", local=target, immediate=value)
                return target
            if literal_name == "L_BitVector":
                atom = self.single_argument(literal, "L_BitVector")
                spelling = str(self.arena.atom(atom, "bitvector"))
                if len(spelling) < 2 or spelling[0] != "'" or spelling[-1] != "'":
                    raise ModelgenError("runtime bitvector literal is malformed")
                bits = spelling[1:-1]
                if not bits or any(bit not in "01" for bit in bits) or len(bits) > 64:
                    raise ModelgenError("runtime bitvector literal is unsupported")
                self.emit(
                    "kLoadBitsImmediate",
                    local=target,
                    immediate=int(bits, 2),
                    address=len(bits),
                )
                return target
            if literal_name == "L_Bool":
                atom = self.single_argument(literal, "L_Bool")
                value = self.arena.atom(atom, "boolean")
                self.emit("kLoadBool", local=target, immediate=1 if value else 0)
                return target
            if literal_name == "L_Label":
                atom = self.single_argument(literal, "L_Label")
                label = str(self.arena.atom(atom, "string"))
                if label not in self.enum_labels:
                    raise ModelgenError(
                        f"unknown or ambiguous enum label {label!r} at node {identifier}")
                type_id, member_id = self.enum_labels[label]
                self.emit("kLoadEnum", local=target,
                          immediate=type_id, address=member_id)
                return target
            raise ModelgenError(f"unsupported runtime literal {literal_name}")
        if name == "E_Slice":
            pair = self.arena.sequence(
                self.single_argument(identifier, "E_Slice"), "tuple"
            )
            if len(pair) != 2:
                raise ModelgenError("runtime slice must contain value and slices")
            source = self.expression(pair[0])
            slices = self.arena.sequence(pair[1], "list")
            if len(slices) != 1:
                raise ModelgenError("runtime supports exactly one slice")
            values = self.arena.sequence(
                self.single_argument(slices[0], "Slice_Length"), "tuple"
            )
            if len(values) != 2:
                raise ModelgenError("runtime slice length must contain start and width")
            start = self.expression(values[0])
            width = self.expression(values[1])
            target = self.local()
            self.emit(
                "kDynamicSlice",
                local=target,
                binding=source,
                immediate=start,
                address=width,
            )
            return target
        if name == "E_Binop":
            values = self.arena.sequence(
                self.single_argument(identifier, "E_Binop"), "tuple"
            )
            if len(values) != 3:
                raise ModelgenError("runtime binary expression is malformed")
            operator = self.arena.constructor_name(values[0])
            if operator not in CONSTRUCTOR_CAPABILITIES["operators"]:
                raise ModelgenError(f"unsupported runtime binary operator {operator}")
            left = self.expression(values[1])
            right = self.expression(values[2])
            target = self.local()
            opcode = {
                "EQ": "kEqual", "NE": "kNotEqual",
                "ADD": "kIntegerAdd", "SUB": "kIntegerSubtract",
                "MUL": "kIntegerMultiply",
            }[operator]
            self.emit(
                opcode,
                local=target,
                binding=left,
                address=right,
            )
            return target
        if name == "E_Call":
            fields = self.arena.record(self.single_argument(identifier, "E_Call"))
            target_name = str(self.arena.atom(fields["name"], "string"))
            if target_name not in self.function_ids and target_name not in self.extern_ids:
                raise ModelgenError(
                    f"unresolved runtime call {target_name!r} at node {identifier}"
                )
            values = self.arena.sequence(fields["args"], "list")
            values.extend(self.arena.sequence(fields["params"], "list"))
            for value in values:
                self.emit("kPushArgument", local=self.expression(value))
            result = self.local()
            if target_name in self.extern_ids:
                binding_id, _, arity = self.extern_ids[target_name]
                if arity != len(values):
                    raise ModelgenError(f"extern call arity mismatch for {target_name}")
                self.emit("kCallExtern", local=result, binding=binding_id,
                          immediate=len(values))
            else:
                self.emit("kCallValue", local=result,
                          binding=self.function_ids[target_name],
                          immediate=len(values))
            return result
        if name == "E_GetArray":
            values = self.arena.sequence(
                self.single_argument(identifier, "E_GetArray"), "tuple")
            if len(values) != 2:
                raise ModelgenError(f"malformed E_GetArray at node {identifier}")
            base = self.expression(values[0])
            index = self.expression(values[1])
            result = self.local()
            self.emit("kGetArray", local=result, binding=base, address=index)
            return result
        if name == "E_GetField":
            values = self.arena.sequence(
                self.single_argument(identifier, "E_GetField"), "tuple")
            if len(values) != 2:
                raise ModelgenError(f"malformed E_GetField at node {identifier}")
            field = str(self.arena.atom(values[1], "string"))
            if field not in self.field_ids:
                raise ModelgenError(f"unknown record field {field!r}")
            base = self.expression(values[0])
            result = self.local()
            self.emit("kGetField", local=result, binding=base,
                      immediate=self.field_ids[field])
            return result
        raise ModelgenError(f"unsupported reachable runtime expression {name}")

    def read_lvalue(self, identifier: int) -> int:
        name = self.arena.constructor_name(identifier)
        if name == "LE_Var":
            variable = str(self.arena.atom(
                self.single_argument(identifier, "LE_Var"), "string"))
            target = self.local()
            if variable in self.local_ids:
                self.emit("kCopyValue", local=target,
                          binding=self.local_ids[variable])
            elif variable in self.global_ids:
                self.emit("kLoadGlobal", local=target,
                          binding=self.global_ids[variable])
            else:
                raise ModelgenError(
                    f"unresolved lvalue root {variable!r} at node {identifier}")
            return target
        if name == "LE_SetArray":
            values = self.arena.sequence(
                self.single_argument(identifier, "LE_SetArray"), "tuple")
            base = self.read_lvalue(values[0])
            index = self.expression(values[1])
            target = self.local()
            self.emit("kGetArray", local=target, binding=base, address=index)
            return target
        if name == "LE_SetField":
            values = self.arena.sequence(
                self.single_argument(identifier, "LE_SetField"), "tuple")
            base = self.read_lvalue(values[0])
            field = str(self.arena.atom(values[1], "string"))
            if field not in self.field_ids:
                raise ModelgenError(f"unknown record field {field!r}")
            target = self.local()
            self.emit("kGetField", local=target, binding=base,
                      immediate=self.field_ids[field])
            return target
        raise ModelgenError(f"unsupported runtime lvalue {name} at node {identifier}")

    def assign_lvalue(self, identifier: int, source: int) -> None:
        name = self.arena.constructor_name(identifier)
        if name == "LE_Var":
            variable = str(self.arena.atom(
                self.single_argument(identifier, "LE_Var"), "string"))
            if variable in self.local_ids:
                self.emit("kCopyValue", local=self.local_ids[variable],
                          binding=source)
            elif variable in self.global_ids:
                self.emit("kStoreGlobal", local=source,
                          binding=self.global_ids[variable])
            else:
                raise ModelgenError(
                    f"unresolved assignment root {variable!r} at node {identifier}")
            return
        if name == "LE_Slice":
            values = self.arena.sequence(
                self.single_argument(identifier, "LE_Slice"), "tuple")
            if len(values) != 2:
                raise ModelgenError(f"malformed LE_Slice at node {identifier}")
            ranges = self.arena.sequence(values[1], "list")
            parsed: list[tuple[int, int]] = []
            for item in ranges:
                parts = self.arena.sequence(
                    self.single_argument(item, "Slice_Length"), "tuple")
                parsed.append((self.literal_integer(parts[0]),
                               self.literal_integer(parts[1])))
            total = sum(width for _, width in parsed)
            self.emit("kCheckBitWidth", local=source, immediate=total)
            base = self.read_lvalue(values[0])
            offset = 0
            for start, width in parsed:
                part = source
                if len(parsed) != 1:
                    part = self.local()
                    self.emit("kSliceBits", local=part, binding=source,
                              immediate=offset, address=width)
                self.emit("kSetSlice", local=base, binding=part,
                          immediate=start, address=width)
                offset += width
            self.assign_lvalue(values[0], base)
            return
        if name == "LE_SetArray":
            values = self.arena.sequence(
                self.single_argument(identifier, "LE_SetArray"), "tuple")
            base = self.read_lvalue(values[0])
            index = self.expression(values[1])
            self.emit("kSetArray", local=base, binding=index, address=source)
            self.assign_lvalue(values[0], base)
            return
        if name == "LE_SetField":
            values = self.arena.sequence(
                self.single_argument(identifier, "LE_SetField"), "tuple")
            base = self.read_lvalue(values[0])
            field = str(self.arena.atom(values[1], "string"))
            if field not in self.field_ids:
                raise ModelgenError(f"unknown record field {field!r}")
            self.emit("kSetField", local=base, binding=source,
                      immediate=self.field_ids[field])
            self.assign_lvalue(values[0], base)
            return
        raise ModelgenError(f"unsupported runtime lvalue {name} at node {identifier}")

    def statement(self, identifier: int) -> bool:
        name = self.arena.constructor_name(identifier)
        if name not in CONSTRUCTOR_CAPABILITIES["statements"]:
            raise ModelgenError(
                f"unsupported reachable runtime statement {name} at node {identifier}"
            )
        if name == "SB_ASL":
            return self.statement(self.single_argument(identifier, "SB_ASL"))
        if name == "S_Return":
            value = self.arena.option(self.single_argument(identifier, "S_Return"))
            if value is None:
                raise ModelgenError("runtime function return must carry a value")
            self.emit("kReturnValue", local=self.expression(value))
            return True
        if name == "S_Assert":
            self.emit(
                "kAssertTrue",
                local=self.expression(self.single_argument(identifier, "S_Assert")),
            )
            return False
        if name == "S_Call":
            fields = self.arena.record(self.single_argument(identifier, "S_Call"))
            target_name = str(self.arena.atom(fields["name"], "string"))
            if target_name not in self.function_ids:
                raise ModelgenError(
                    f"unresolved runtime call {target_name!r} at node {identifier}"
                )
            values = self.arena.sequence(fields["args"], "list")
            values.extend(self.arena.sequence(fields["params"], "list"))
            for value in values:
                self.emit("kPushArgument", local=self.expression(value))
            self.emit(
                "kCallProcedure",
                binding=self.function_ids[target_name],
                immediate=len(values),
            )
            return False
        if name == "S_Decl":
            values = self.arena.sequence(
                self.single_argument(identifier, "S_Decl"), "tuple"
            )
            if len(values) != 4:
                raise ModelgenError(f"malformed S_Decl at node {identifier}")
            declaration = self.single_argument(values[1], "LDI_Var")
            variable = str(self.arena.atom(declaration, "string"))
            initializer = self.arena.option(values[3])
            if initializer is None:
                raise ModelgenError(
                    f"typed default S_Decl not yet materialized at node {identifier}"
                )
            self.local_ids[variable] = self.expression(initializer)
            return False
        if name == "S_Assign":
            values = self.arena.sequence(
                self.single_argument(identifier, "S_Assign"), "tuple"
            )
            if len(values) != 2:
                raise ModelgenError(f"malformed S_Assign at node {identifier}")
            source = self.expression(values[1])
            self.assign_lvalue(values[0], source)
            return False
        if name == "S_For":
            fields = self.arena.record(self.single_argument(identifier, "S_For"))
            index_name = str(self.arena.atom(fields["index_name"], "string"))
            start = self.expression(fields["start"])
            end = self.expression(fields["end_"])
            direction = self.arena.constructor_name(fields["dir"])
            if direction not in {"Up", "Down"}:
                raise ModelgenError(f"unsupported loop direction {direction}")
            previous = self.local_ids.get(index_name)
            self.local_ids[index_name] = start
            loop_head = len(self.instructions)
            condition = self.local()
            self.emit(
                "kIntegerLessEqual" if direction == "Up" else "kIntegerGreaterEqual",
                local=condition, binding=start, address=end)
            exit_branch = self.emit("kBranchIfFalse", local=condition)
            self.statement(fields["body"])
            self.emit("kIntegerStep", local=start,
                      immediate=0 if direction == "Up" else 1)
            self.emit("kJump", address=loop_head)
            self.instructions[exit_branch]["address"] = len(self.instructions)
            if previous is None:
                del self.local_ids[index_name]
            else:
                self.local_ids[index_name] = previous
            return False
        if name == "S_Cond":
            values = self.arena.sequence(
                self.single_argument(identifier, "S_Cond"), "tuple"
            )
            if len(values) != 3:
                raise ModelgenError("runtime condition is malformed")
            condition = self.expression(values[0])
            branch = self.emit("kBranchIfFalse", local=condition)
            then_terminal = self.statement(values[1])
            jump = None if then_terminal else self.emit("kJump")
            self.instructions[branch]["address"] = len(self.instructions)
            else_terminal = self.statement(values[2])
            if jump is not None:
                self.instructions[jump]["address"] = len(self.instructions)
            return then_terminal and else_terminal
        if name == "S_Seq":
            terminal = False
            children = self.arena.sequence(
                self.single_argument(identifier, "S_Seq"), "tuple"
            )
            if len(children) != 2:
                raise ModelgenError(
                    f"runtime function sequence at node {identifier} is malformed"
                )
            for child in children:
                if terminal:
                    raise ModelgenError("runtime sequence contains unreachable statement")
                terminal = self.statement(child)
            return terminal
        raise ModelgenError(f"unsupported reachable runtime statement {name}")


def _type_bits_width(arena: CompactArena, identifier: int) -> int:
    if "T_Bits" not in CONSTRUCTOR_CAPABILITIES["types"]:
        raise ModelgenError("runtime T_Bits handler is not declared")
    values = arena.sequence(arena.constructor(identifier, "T_Bits")[0], "tuple")
    if len(values) != 2:
        raise ModelgenError("runtime bits type is malformed")
    compiler = Compiler(arena, [])
    return compiler.literal_integer(values[0])


def _enum_labels(
    arena: CompactArena, types: list[dict[str, object]]
) -> dict[str, tuple[int, int]]:
    labels: dict[str, tuple[int, int]] = {}
    ambiguous: set[str] = set()
    for row in types:
        definition = row["definition_node"]
        if definition is None or arena.constructor_name(int(definition)) != "T_Enum":
            continue
        arguments = arena.constructor(int(definition), "T_Enum")
        if len(arguments) != 1:
            raise ModelgenError("enum type definition is malformed")
        for member_id, atom in enumerate(arena.sequence(arguments[0], "list")):
            label = str(arena.atom(atom, "string"))
            if label in labels:
                ambiguous.add(label)
            labels[label] = (int(row["id"]), member_id)
    for label in ambiguous:
        labels.pop(label, None)
    return labels


def lower(image: dict[str, object]) -> tuple[int, list[dict[str, int | str]]]:
    if ENTRYPOINT not in CAPABILITIES["entrypoints"]:
        raise ModelgenError("runtime entrypoint capability is not declared")
    verify_executable_module(image, required_entrypoints=(ENTRYPOINT,))
    tables = image["tables"]
    strings = [row["name"] for row in tables["strings"]]
    entrypoint = next(
        (
            row
            for row in tables["entrypoints"]
            if strings[row["name_symbol_id"]] == ENTRYPOINT
        ),
        None,
    )
    if entrypoint is None:
        raise ModelgenError(f"missing runtime entrypoint {ENTRYPOINT}")
    function = tables["functions"][entrypoint["function_id"]]
    if function["extern_id"] is not None or function["parameters"]:
        raise ModelgenError("runtime entrypoint must be a concrete non-parameterized function")
    arguments = function["arguments"]
    if len(arguments) != 1:
        raise ModelgenError("runtime entrypoint must have one argument")
    arena = CompactArena(image)
    if _type_bits_width(arena, arguments[0]["type_node"]) != 16:
        raise ModelgenError("runtime entrypoint argument must be bits(16)")
    argument_name = str(strings[arguments[0]["name_symbol_id"]])
    function_ids = {
        str(strings[row["name_symbol_id"]]): int(row["id"])
        for row in tables["functions"]
    }
    global_ids = {
        str(strings[row["name_symbol_id"]]): int(row["id"])
        for row in tables["globals"]
    }
    field_ids = {str(name): identifier for identifier, name in enumerate(strings)}
    compiler = Compiler(
        arena, [argument_name], function_ids, global_ids, field_ids,
        _enum_labels(arena, tables["types"]))
    compiler.statement(function["body_node"])
    if not compiler.instructions or not any(
        row["opcode"] == "kReturnValue" for row in compiler.instructions
    ):
        raise ModelgenError("runtime entrypoint has no reachable value return")
    return int(function["id"]), compiler.instructions


def lower_module(
    image: dict[str, object], entrypoints: tuple[str, ...]
) -> tuple[int, list[dict[str, object]], list[dict[str, object]]]:
    verify_executable_module(image, required_entrypoints=entrypoints)
    tables = image["tables"]
    strings = [row["name"] for row in tables["strings"]]
    functions = tables["functions"]
    function_ids = {
        str(strings[row["name_symbol_id"]]): int(row["id"])
        for row in functions
    }
    global_ids = {
        str(strings[row["name_symbol_id"]]): int(row["id"])
        for row in tables["globals"]
    }
    field_ids = {str(name): identifier for identifier, name in enumerate(strings)}
    enum_labels = _enum_labels(CompactArena(image), tables["types"])
    extern_ids: dict[str, tuple[int, str, int]] = {}
    for row in tables["externs"]:
        name = str(strings[row["name_symbol_id"]])
        function = functions[int(row["declaration_function_id"])]
        arity = len(function["arguments"]) + len(function["parameters"])
        if name in {"UInt", "SInt"}:
            extern_ids[name] = (int(row["binding_id"]), name, arity)
    roots = [function_ids[name] for name in entrypoints]
    graph = {
        int(row["id"]): [int(value) for value in row["callee_function_ids"]]
        for row in tables["call_graph"]
    }
    reachable: set[int] = set()
    pending = list(roots)
    while pending:
        function_id = pending.pop()
        if function_id in reachable:
            continue
        reachable.add(function_id)
        pending.extend(graph[function_id])

    arena = CompactArena(image)
    lowered: list[dict[str, object]] = []
    for function_id in sorted(reachable):
        function = functions[function_id]
        if function["extern_id"] is not None:
            name = str(strings[function["name_symbol_id"]])
            if name not in extern_ids:
                raise ModelgenError(
                    f"runtime function {name} ({function_id}) is an unresolved extern")
            continue
        arguments = [
            str(strings[row["name_symbol_id"]])
            for row in [*function["arguments"], *function["parameters"]]
        ]
        compiler = Compiler(
            arena, arguments, function_ids, global_ids, field_ids, enum_labels,
            extern_ids)
        name = str(strings[function["name_symbol_id"]])
        try:
            compiler.statement(int(function["body_node"]))
        except ModelgenError as error:
            raise ModelgenError(
                f"runtime lowering failed in function {name} ({function_id}): {error}"
            ) from error
        lowered.append(
            {
                "id": function_id,
                "argument_count": len(arguments),
                "instructions": compiler.instructions,
            }
        )
    externs = [
        {"id": binding, "kind": kind, "argument_count": arity}
        for binding, kind, arity in sorted(extern_ids.values())
        if any(functions[fid]["extern_id"] is not None and
               str(strings[functions[fid]["name_symbol_id"]]) == kind
               for fid in reachable)
    ]
    return roots[0], lowered, externs


def _render_header() -> str:
    return """#ifndef PTO_GENERATED_RUNTIME_IMAGE_H
#define PTO_GENERATED_RUNTIME_IMAGE_H

#include \"module.h\"

#include <memory>

namespace pto::model {
std::shared_ptr<const Module> GeneratedDetermineLengthModule();
BindingId GeneratedDetermineLengthBinding();
}  // namespace pto::model

#endif
"""


def _render_source(function_id: int, instructions: list[dict[str, int | str]], digest: str) -> str:
    rows = "\n".join(
        "        {OpCode::%s, %su, %su, UINT64_C(%s), UINT64_C(%s)},"
        % (
            row["opcode"],
            row["binding"],
            row["local"],
            row["immediate"],
            row["address"],
        )
        for row in instructions
    )
    return f"""// Generated from executable PTO MIR sha256:{digest}; do not edit.
#include \"pto_generated_runtime_image.h\"

#include <cassert>
#include <cstdint>
#include <stdexcept>
#include <string>
#include <vector>

namespace pto::model {{

BindingId GeneratedDetermineLengthBinding() {{ return {function_id}u; }}

std::shared_ptr<const Module> GeneratedDetermineLengthModule() {{
    std::vector<Instruction> instructions{{
{rows}
    }};
    std::string error;
    auto module = Module::Create(
        {{Function{{GeneratedDetermineLengthBinding(), std::move(instructions), 1u}}}},
        GeneratedDetermineLengthBinding(),
        &error);
    if (module == nullptr) {{
        throw std::runtime_error(error);
    }}
    return module;
}}

}}  // namespace pto::model
"""


def render_module_source(
    primary_id: int,
    functions: list[dict[str, object]],
    digest: str,
    builder_name: str,
    externs: list[dict[str, object]] | None = None,
) -> str:
    blocks: list[str] = []
    rows: list[str] = []
    for function in functions:
        function_id = int(function["id"])
        instructions = function["instructions"]
        rendered = "\n".join(
            "        {OpCode::%s, %su, %su, UINT64_C(%s), UINT64_C(%s)},"
            % (row["opcode"], row["binding"], row["local"],
               row["immediate"], row["address"])
            for row in instructions
        )
        blocks.append(
            f"    std::vector<Instruction> instructions_{function_id}{{\n"
            f"{rendered}\n    }};"
        )
        rows.append(
            f"        Function{{{function_id}u, std::move(instructions_{function_id}), "
            f"{int(function['argument_count'])}u}},"
        )
    return (
        f"// Generated module sha256:{digest}; do not edit.\n"
        "#include \"module.h\"\n#include <cstdint>\n#include <string>\n"
        "#include <utility>\n#include <vector>\n\nnamespace pto::model {\n"
        f"std::shared_ptr<const Module> {builder_name}() {{\n"
        + "\n".join(blocks)
        + "\n    std::string error;\n    return Module::Create({\n"
        + "\n".join(rows)
        + "\n    }, " + f"{primary_id}u, &error, {{\n"
        + "\n".join(
            f"        ExternDefinition{{{row['id']}u, ExternKind::k{row['kind']}, "
            f"{row['argument_count']}u}}," for row in (externs or []))
        + "\n    });\n}\n}  // namespace pto::model\n"
    )


def _load_cases(path: Path) -> list[dict[str, int]]:
    document = json.loads(path.read_bytes())
    if document.get("schema") != CASES_SCHEMA or set(document) != {
        "schema", "source_test_id", "cases"
    }:
        raise ModelgenError("determine-length cases manifest is malformed")
    cases = document["cases"]
    if not isinstance(cases, list) or len(cases) != 16:
        raise ModelgenError("determine-length cases must contain sixteen rows")
    if [row.get("first_halfword") for row in cases] != list(range(16)):
        raise ModelgenError("determine-length cases must cover low prefixes 0..15")
    for row in cases:
        if set(row) != {"first_halfword", "length_bits"} or row["length_bits"] not in {
            16, 32, 48, 64
        }:
            raise ModelgenError("determine-length case is malformed")
    return cases


def _render_cases_header(cases: list[dict[str, int]]) -> str:
    rows = "\n".join(
        f"    DetermineLengthCase{{{row['first_halfword']}u, {row['length_bits']}u}},"
        for row in cases
    )
    return f"""#ifndef PTO_GENERATED_DETERMINE_LENGTH_CASES_H
#define PTO_GENERATED_DETERMINE_LENGTH_CASES_H

#include <array>
#include <cstdint>

struct DetermineLengthCase {{
    std::uint16_t first_halfword;
    std::uint64_t length_bits;
}};

inline constexpr std::array<DetermineLengthCase, 16> kDetermineLengthCases{{{{
{rows}
}}}};

#endif
"""


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--input", type=Path, required=True)
    parser.add_argument("--header", type=Path, required=True)
    parser.add_argument("--source", type=Path, required=True)
    parser.add_argument("--cases", type=Path, required=True)
    parser.add_argument("--cases-header", type=Path, required=True)
    arguments = parser.parse_args()
    try:
        image_bytes = arguments.input.read_bytes()
        image = json.loads(image_bytes)
        function_id, instructions = lower(image)
        outputs = {
            arguments.header: _render_header(),
            arguments.source: _render_source(
                function_id, instructions, hashlib.sha256(image_bytes).hexdigest()
            ),
            arguments.cases_header: _render_cases_header(_load_cases(arguments.cases)),
        }
        for path, content in outputs.items():
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text(content, encoding="utf-8")
    except (ModelgenError, OSError, ValueError, json.JSONDecodeError) as error:
        print(f"error: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

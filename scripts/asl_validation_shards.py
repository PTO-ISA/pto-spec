"""Partition generated ASL decode logic from executable validation witnesses."""

from __future__ import annotations

import hashlib
import json
import re
from dataclasses import dataclass


VALIDATION_START = re.compile(r"^func (Validate[A-Za-z0-9_]+)\(\)\n", re.MULTILINE)
TOP_LEVEL_END = re.compile(r"^end;\n", re.MULTILINE)
VALIDATION_CALL = re.compile(r"\b(Validate[A-Za-z0-9_]+)\s*\(\s*\)\s*;")
EMPTY_VALIDATION_SHARD = (
    "// Generated validation shard. Do not edit.\n// Entrypoint: none\n"
)


@dataclass(frozen=True)
class ValidationFunction:
    name: str
    text: str
    offset: int
    dependencies: tuple[str, ...]


@dataclass(frozen=True)
class PartitionedGeneratedAsl:
    decoder: str
    validation: tuple[ValidationFunction, ...]

    def by_name(self) -> dict[str, ValidationFunction]:
        return {function.name: function for function in self.validation}


def partition_generated_asl(text: str) -> PartitionedGeneratedAsl:
    functions: list[ValidationFunction] = []
    decoder_parts: list[str] = []
    cursor = 0
    names: set[str] = set()
    for start in VALIDATION_START.finditer(text):
        end = TOP_LEVEL_END.search(text, start.end())
        if end is None:
            raise ValueError(f"unterminated generated validation function {start[1]}")
        chunk_end = end.end()
        if text.startswith("\n", chunk_end):
            chunk_end += 1
        decoder_parts.append(text[cursor : start.start()])
        chunk = text[start.start() : chunk_end]
        name = start[1]
        if name in names:
            raise ValueError(f"duplicate generated validation function {name}")
        names.add(name)
        dependencies = tuple(sorted(set(VALIDATION_CALL.findall(chunk)) - {name}))
        functions.append(
            ValidationFunction(
                name=name,
                text=chunk,
                offset=start.start(),
                dependencies=dependencies,
            )
        )
        cursor = chunk_end
    decoder_parts.append(text[cursor:])
    if not functions:
        raise ValueError("generated ASL contains no validation functions")
    by_name = {function.name: function for function in functions}
    for function in functions:
        unknown = sorted(set(function.dependencies) - set(by_name))
        if unknown:
            raise ValueError(
                f"{function.name} calls unknown generated validation functions: "
                + ", ".join(unknown)
            )
    decoder = "".join(decoder_parts)
    if VALIDATION_START.search(decoder):
        raise ValueError("decoder partition still contains a validation function")
    return PartitionedGeneratedAsl(decoder=decoder, validation=tuple(functions))


def validation_closure(
    partitioned: PartitionedGeneratedAsl, entrypoint: str
) -> tuple[ValidationFunction, ...]:
    by_name = partitioned.by_name()
    if entrypoint not in by_name:
        raise ValueError(f"unknown validation entrypoint {entrypoint}")
    selected: set[str] = set()

    def visit(name: str) -> None:
        if name in selected:
            return
        selected.add(name)
        for dependency in by_name[name].dependencies:
            visit(dependency)

    visit(entrypoint)
    return tuple(
        function for function in partitioned.validation if function.name in selected
    )


def render_validation_shard(
    partitioned: PartitionedGeneratedAsl, entrypoint: str
) -> str:
    functions = validation_closure(partitioned, entrypoint)
    return (
        "// Generated validation shard. Do not edit.\n"
        f"// Entrypoint: {entrypoint}\n\n"
        + "".join(function.text for function in functions)
    )


def validation_index(partitioned: PartitionedGeneratedAsl) -> str:
    entries = [
        {
            "name": function.name,
            "dependencies": list(function.dependencies),
            "line_count": function.text.count("\n"),
            "sha256": hashlib.sha256(function.text.encode()).hexdigest(),
            "closure_sha256": hashlib.sha256(
                render_validation_shard(partitioned, function.name).encode()
            ).hexdigest(),
        }
        for function in partitioned.validation
    ]
    return (
        json.dumps(
            {"schema": 1, "validation": entries},
            indent=2,
            sort_keys=True,
        )
        + "\n"
    )

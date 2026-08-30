#!/usr/bin/env python3
"""Parse non-architectural functional-model and hosted-ABI contracts."""

from __future__ import annotations

import re
from dataclasses import dataclass
from pathlib import Path


CONTRACT_ID = re.compile(r"PTO-[A-Z0-9]+(?:-[A-Z0-9]+)*")
REGION_BEGIN = re.compile(
    r"^// PTO-MODEL-CONTRACT-BEGIN: (PTO-[A-Z0-9]+(?:-[A-Z0-9]+)*)$"
)
REGION_END = re.compile(
    r"^// PTO-MODEL-CONTRACT-END: (PTO-[A-Z0-9]+(?:-[A-Z0-9]+)*)$"
)
METADATA_PREFIX = "// contract: "
LAYERS = {"model", "abi"}
STATUSES = {"open", "accepted"}


@dataclass(frozen=True)
class ModelContract:
    contract_id: str
    layer: str
    status: str
    body: str
    source: Path
    line: int


class ModelContractValidationError(ValueError):
    def __init__(self, errors: list[str]):
        super().__init__("\n".join(errors))
        self.errors = tuple(errors)


def _parse_metadata(raw: str, source: Path, line: int) -> tuple[dict[str, str], list[str]]:
    values: dict[str, str] = {}
    errors: list[str] = []
    for token in raw.split():
        if token.count("=") != 1:
            errors.append(f"{source}:{line}: invalid model-contract metadata token {token}")
            continue
        name, value = token.split("=", 1)
        if name in values:
            errors.append(f"{source}:{line}: duplicate model-contract field {name}")
        values[name] = value
    required = {"layer", "status"}
    for name in sorted(required - values.keys()):
        errors.append(f"{source}:{line}: missing model-contract field {name}")
    for name in sorted(values.keys() - required):
        errors.append(f"{source}:{line}: unknown model-contract field {name}")
    if "layer" in values and values["layer"] not in LAYERS:
        errors.append(f"{source}:{line}: unknown model-contract layer {values['layer']}")
    if "status" in values and values["status"] not in STATUSES:
        errors.append(f"{source}:{line}: unknown model-contract status {values['status']}")
    return values, errors


def parse_model_contracts(text: str, source: Path) -> tuple[ModelContract, ...]:
    """Parse every non-architectural model-contract region in one ASL source."""

    contracts: list[ModelContract] = []
    errors: list[str] = []
    active_id: str | None = None
    active_line = 0
    metadata_line = 0
    metadata_raw: str | None = None
    body_lines: list[str] = []

    for line_number, line in enumerate(text.splitlines(), start=1):
        begin = REGION_BEGIN.fullmatch(line)
        end = REGION_END.fullmatch(line)
        if begin:
            if active_id is not None:
                errors.append(
                    f"{source}:{line_number}: nested model contract {begin.group(1)}"
                )
                continue
            active_id = begin.group(1)
            active_line = line_number
            metadata_line = 0
            metadata_raw = None
            body_lines = []
            continue
        if end:
            if active_id is None:
                errors.append(
                    f"{source}:{line_number}: model-contract end without begin {end.group(1)}"
                )
                continue
            if end.group(1) != active_id:
                errors.append(
                    f"{source}:{line_number}: mismatched model-contract end "
                    f"{end.group(1)} for {active_id}"
                )
            if metadata_raw is None:
                errors.append(
                    f"{source}:{active_line}: model contract {active_id} lacks metadata"
                )
            else:
                values, metadata_errors = _parse_metadata(
                    metadata_raw, source, metadata_line
                )
                errors.extend(metadata_errors)
                body = "\n".join(body_lines).strip()
                if not body:
                    errors.append(
                        f"{source}:{active_line}: model contract {active_id} has no body"
                    )
                if not metadata_errors and body and end.group(1) == active_id:
                    contracts.append(
                        ModelContract(
                            contract_id=active_id,
                            layer=values["layer"],
                            status=values["status"],
                            body=body,
                            source=source,
                            line=active_line,
                        )
                    )
            active_id = None
            metadata_raw = None
            body_lines = []
            continue
        if active_id is None:
            continue
        if line.startswith(METADATA_PREFIX):
            if metadata_raw is not None:
                errors.append(
                    f"{source}:{line_number}: duplicate model-contract metadata"
                )
            metadata_raw = line[len(METADATA_PREFIX) :]
            metadata_line = line_number
        elif line.startswith("// "):
            body_lines.append(line[3:])
        elif line == "//":
            body_lines.append("")
        else:
            errors.append(
                f"{source}:{line_number}: model-contract body must use // comments"
            )

    if active_id is not None:
        errors.append(f"{source}:{active_line}: unclosed model contract {active_id}")
    if errors:
        raise ModelContractValidationError(errors)
    return tuple(contracts)


def check_repository(root: Path) -> list[str]:
    """Validate model-contract syntax and unique ownership across the ASL tree."""

    errors: list[str] = []
    owners: dict[str, list[ModelContract]] = {}
    for path in sorted((root / "asl").rglob("*.asl")):
        source = path.relative_to(root)
        try:
            contracts = parse_model_contracts(path.read_text(encoding="utf-8"), source)
        except ModelContractValidationError as error:
            errors.extend(error.errors)
            continue
        for contract in contracts:
            owners.setdefault(contract.contract_id, []).append(contract)
    for contract_id, contracts in sorted(owners.items()):
        if len(contracts) > 1:
            paths = ", ".join(str(contract.source) for contract in contracts)
            errors.append(f"duplicate model contract {contract_id}: {paths}")
    return errors

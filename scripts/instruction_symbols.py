#!/usr/bin/env python3
"""Canonical readable ASL symbols owned by mnemonic instruction contracts."""

from __future__ import annotations

import re


_PLAIN_OPERATION_ROLES = {
    "AtomicOperation",
    "BinaryOperation",
    "CompareOperation",
    "FusedOperation",
    "MaintenanceOperation",
    "Operation",
    "TileOperation",
    "UnaryOperation",
}

_PLAIN_VALUE_ROLES = {
    "FloatingValue",
    "HighResult",
    "LowResult",
    "Product",
    "Quotient",
    "Remainder",
    "Value",
}

_DECODED_ROLES = {
    "DestinationCarrier": "DestinationCarrier",
    "RightModifier": "RightModifier",
    "SourceCarrier": "SourceCarrier",
}


def instruction_identifier(identifier: str) -> str:
    """Return the ASL-safe exact instruction identity used inside a symbol."""

    if re.fullmatch(r"[A-Z0-9_]+", identifier) is None:
        raise ValueError(f"invalid instruction identifier: {identifier}")
    return identifier.replace("_", "")


def contract_symbol(role: str, identifier: str) -> str:
    """Return the one canonical Arm-style ASL symbol for an instruction role."""

    if re.fullmatch(r"[A-Za-z][A-Za-z0-9]*", role) is None:
        raise ValueError(f"invalid instruction contract role: {role}")
    identity = instruction_identifier(identifier)
    if role == "Handler":
        return f"{identity}Handler"
    if role == "Execute":
        return f"Execute{identity}"
    if role == "Matches":
        return f"{identity}EncodingMatches"
    if role == "PreparedRight":
        return f"{identity}RightOperand"
    if role in _PLAIN_OPERATION_ROLES:
        return f"{identity}{role}"
    if role == "CommitResult":
        return f"Commit{identity}Result"
    if role == "GMAddress":
        return f"{identity}GMAddress"
    if role == "DenseStride":
        return f"{identity}DenseStride"
    if role in {"Offset", "ShiftAmount"}:
        return f"Decode{identity}{role}"
    if role == "Target":
        return f"{identity}Target"
    if role in {"Result", "CompareResult"}:
        return f"{identity}Result"
    if role == "CompareLogicalValue":
        return f"{identity}LogicalValue"
    if role in _PLAIN_VALUE_ROLES:
        return f"{identity}{role}"
    if role == "Condition":
        return f"{identity}Condition"
    if role in _DECODED_ROLES:
        return f"Decode{identity}{_DECODED_ROLES[role]}"
    return f"{identity}{role}"

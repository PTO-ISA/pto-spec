#!/usr/bin/env python3
"""Canonical readable ASL symbols owned by mnemonic instruction contracts."""

from __future__ import annotations

import re


_COMPUTED_ROLES = {
    "CompareLogicalValue": "ComparisonLogicalValue",
    "CompareResult": "ComparisonResult",
    "FloatingValue": "FloatingValue",
    "HighResult": "HighResult",
    "LowResult": "LowResult",
    "Product": "Product",
    "Quotient": "Quotient",
    "Remainder": "Remainder",
    "Result": "Result",
    "Value": "Value",
}

_DECODED_ROLES = {
    "Condition": "Condition",
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
    if role == "Operation":
        return f"Select{identity}Operation"
    if role == "Handler":
        return f"Select{identity}Handler"
    if role == "Execute":
        return f"Execute{identity}"
    if role == "Matches":
        return f"{identity}EncodingMatches"
    if role == "PreparedRight":
        return f"Prepare{identity}RightOperand"
    if role == "FusedOperation":
        return f"Select{identity}FusedOperation"
    if role in {
        "AtomicOperation",
        "BinaryOperation",
        "CompareOperation",
        "MaintenanceOperation",
        "TileOperation",
        "UnaryOperation",
    }:
        return f"Select{identity}{role}"
    if role == "CommitResult":
        return f"Commit{identity}Result"
    if role == "GMAddress":
        return f"Resolve{identity}GlobalAddress"
    if role == "DenseStride":
        return f"Compute{identity}DenseStride"
    if role in {"Offset", "ShiftAmount"}:
        return f"Decode{identity}{role}"
    if role == "Target":
        return f"Resolve{identity}Target"
    if role in _COMPUTED_ROLES:
        return f"Compute{identity}{_COMPUTED_ROLES[role]}"
    if role in _DECODED_ROLES:
        return f"Decode{identity}{_DECODED_ROLES[role]}"
    return f"{identity}{role}"

"""Shared legal and priority-selecting encoded-form witness synthesis."""

from __future__ import annotations


def decode_field(row: dict, field_name: str, instruction: int) -> int:
    field = next(field for field in row["fields"] if field["name"] == field_name)
    value = 0
    for piece in field["pieces"]:
        piece_mask = (1 << piece["width"]) - 1
        value |= ((instruction >> piece["instruction_lsb"]) & piece_mask) << piece[
            "value_lsb"
        ]
    return value


def encode_field(row: dict, field_name: str, instruction: int, value: int) -> int:
    field = next(field for field in row["fields"] if field["name"] == field_name)
    if not 0 <= value < 1 << field["width"]:
        raise ValueError(f"field value exceeds {field_name} in {row['form_id']}")
    for piece in field["pieces"]:
        piece_mask = (1 << piece["width"]) - 1
        instruction &= ~(piece_mask << piece["instruction_lsb"])
        piece_value = (value >> piece["value_lsb"]) & piece_mask
        instruction |= piece_value << piece["instruction_lsb"]
    return instruction


def encoded_form_witness(row: dict) -> int:
    instruction = 0
    for part in row["encoding"]:
        instruction |= int(part["match"], 16) << (part["index"] * 32)
    constraints_by_field: dict[str, list[dict]] = {}
    for constraint in row.get("constraints", []):
        constraints_by_field.setdefault(constraint["field"], []).append(constraint)
    for field_name, constraints in constraints_by_field.items():
        field = next(field for field in row["fields"] if field["name"] == field_name)
        one_of = [
            set(constraint["values"])
            for constraint in constraints
            if constraint["operator"] == "one-of"
        ]
        excluded = {
            constraint["value"]
            for constraint in constraints
            if constraint["operator"] == "not-equal"
        }
        unsupported = [
            constraint
            for constraint in constraints
            if constraint["operator"] not in {"one-of", "not-equal"}
        ]
        if unsupported:
            raise ValueError(f"unsupported encoded-form constraint: {unsupported[0]!r}")
        current = decode_field(row, field_name, instruction)
        if one_of:
            allowed = set.intersection(*one_of) - excluded
            candidates = [current, *sorted(allowed)]
        else:
            candidates = [current, *(value for value in range(len(excluded) + 1))]
        replacement = next(
            (
                value
                for value in candidates
                if 0 <= value < 1 << field["width"]
                and value not in excluded
                and all(value in values for values in one_of)
            ),
            None,
        )
        if replacement is None:
            raise ValueError(
                f"encoded form has unsatisfiable constraints for {field_name}: "
                f"{row['form_id']}"
            )
        instruction = encode_field(row, field_name, instruction, replacement)
    if not form_encoding_matches(row, instruction) or not form_constraints_hold(
        row, instruction
    ):
        raise ValueError(f"encoded form has no legal witness: {row['form_id']}")
    return instruction


def encoding_alternatives(row: dict) -> list[list[dict]]:
    return [
        row["encoding"],
        *[variant["encoding"] for variant in row.get("encoding_variants", [])],
    ]


def _encoding_mask(part: dict) -> int:
    mask = part.get("mask")
    return int(mask, 16) if isinstance(mask, str) else (1 << part["width_bits"]) - 1


def catalog_decode_order(rows: list[dict]) -> list[tuple[int, dict]]:
    return sorted(
        enumerate(rows),
        key=lambda pair: (
            -sum(_encoding_mask(part).bit_count() for part in pair[1]["encoding"]),
            pair[1]["form_id"],
        ),
    )


def form_encoding_matches(row: dict, instruction: int) -> bool:
    for encoding in encoding_alternatives(row):
        for part in encoding:
            low = part["index"] * 32
            width = part["width_bits"]
            word = (instruction >> low) & ((1 << width) - 1)
            if word & _encoding_mask(part) != int(part["match"], 16):
                break
        else:
            return True
    return False


def form_constraints_hold(row: dict, instruction: int) -> bool:
    for constraint in row.get("constraints", []):
        value = decode_field(row, constraint["field"], instruction)
        if constraint["operator"] == "not-equal":
            if value == constraint["value"]:
                return False
        elif constraint["operator"] == "one-of":
            if value not in constraint["values"]:
                return False
        else:
            raise ValueError(f"unsupported encoded-form constraint: {constraint!r}")
    return True


def encoded_catalog_witnesses(rows: list[dict]) -> list[int]:
    """Find legal witnesses that select each row under the priority decoder."""

    ordered = catalog_decode_order(rows)
    witnesses: list[int] = []
    for target, row in enumerate(rows):
        base = encoded_form_witness(row)

        def candidates():
            yield base
            for attempt in range(1, 65536):
                candidate = base
                state = ((target + 1) << 32) ^ attempt ^ 0x9E3779B97F4A7C15
                for field in row["fields"]:
                    state = (state * 6364136223846793005 + 1442695040888963407) & (
                        (1 << 64) - 1
                    )
                    value = (state >> 17) & ((1 << field["width"]) - 1)
                    candidate = encode_field(row, field["name"], candidate, value)
                yield candidate

        for candidate in candidates():
            if not form_constraints_hold(row, candidate):
                continue
            decoded = next(
                (
                    index
                    for index, candidate_row in ordered
                    if candidate_row["length_bits"] == row["length_bits"]
                    and form_encoding_matches(candidate_row, candidate)
                ),
                len(rows),
            )
            if decoded == target:
                witnesses.append(candidate)
                break
        else:
            raise ValueError(
                f"encoded form has no legal priority-decode witness: {row['form_id']}"
            )
    return witnesses

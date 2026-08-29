#!/usr/bin/env python3
"""Embed the canonical model descriptor and its exact SHA-256 in C++."""

from __future__ import annotations

import argparse
import hashlib
from pathlib import Path


def _byte_rows(content: bytes, width: int = 12) -> str:
    rows = []
    for offset in range(0, len(content), width):
        chunk = content[offset : offset + width]
        rows.append("    " + ", ".join(f"0x{value:02x}" for value in chunk) + ",")
    return "\n".join(rows)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--input", type=Path, required=True)
    parser.add_argument("--header", type=Path, required=True)
    parser.add_argument("--source", type=Path, required=True)
    arguments = parser.parse_args()

    descriptor = arguments.input.read_bytes()
    digest = hashlib.sha256(descriptor).digest()
    header = """#ifndef PTO_GENERATED_DESCRIPTOR_H
#define PTO_GENERATED_DESCRIPTOR_H

#include <array>
#include <cstddef>
#include <cstdint>

namespace pto::model {
const std::uint8_t *GeneratedDescriptorData();
std::size_t GeneratedDescriptorSize();
const std::array<std::uint8_t, 32> &GeneratedDescriptorSha256();
}  // namespace pto::model

#endif
"""
    source = f"""// Generated from model-descriptor.json; do not edit.
#include \"pto_generated_descriptor.h\"

namespace pto::model {{
namespace {{
constexpr std::uint8_t kDescriptor[] = {{
{_byte_rows(descriptor)}
}};
constexpr std::array<std::uint8_t, 32> kDescriptorSha256{{
{_byte_rows(digest)}
}};
}}  // namespace

const std::uint8_t *GeneratedDescriptorData() {{ return kDescriptor; }}
std::size_t GeneratedDescriptorSize() {{ return sizeof(kDescriptor); }}
const std::array<std::uint8_t, 32> &GeneratedDescriptorSha256() {{
    return kDescriptorSha256;
}}
}}  // namespace pto::model
"""
    arguments.header.parent.mkdir(parents=True, exist_ok=True)
    arguments.source.parent.mkdir(parents=True, exist_ok=True)
    arguments.header.write_text(header, encoding="utf-8")
    arguments.source.write_text(source, encoding="utf-8")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

---
{
  "schema_version": 1,
  "id": "header.header-bstart.tepl",
  "kind": "header",
  "title": "BSTART.TEPL",
  "status": "active",
  "visibility": "public",
  "profile": "pto-isa-0.58.0",
  "family": "Execution Classes",
  "sources": { "davincioo": "header/BSTART.TEPL.md" }
}
---
# BSTART.TEPL

## Purpose

`BSTART.TEPL` selects one of the 87 accepted Tile Element Processing
operations.  The Mode/Function selector is the canonical direct-operation
identity; `B.DATR`, `B.DIM`, `B.IOT`, and `B.IOR` provide the operation's
declared attributes and operands.

## Encoding

| Bits | Field | Width | Fixed value |
| --- | --- | ---: | --- |
| `[31:27]` | `DataType` | 5 | |
| `[26:25]` | `Mode` | 2 | |
| `[24:20]` | `Function` | 5 | |
| `[19:15]` | block family | 5 | `3` |
| `[14:12]` | `Func` | 3 | `1` |
| `[11:7]` | fixed | 5 | `3` |
| `[6:4]` | `Opc1` | 3 | `0` |
| `[3:1]` | `Opcode` | 3 | `0` |
| `[0]` | `W` | 1 | `1` |

## Accepted selectors

The formal Tile ISA index is the only complete operation list. The
following selector ranges are accepted in PTO ISA 0.58.0:

| Mode | Accepted functions | Family |
| ---: | --- | --- |
| 0 | 0–13, 15–28 | Tile-tile and unary elementwise |
| 1 | 0–13, 26 | Tile-scalar elementwise |
| 2 | 0–13, 16–29 | Axis reduction and expansion |
| 3 | 0, 2–7, 9–20 | Complex Tile operations |

The active non-contiguous selectors are `TFMA` (Mode 0 / Function 28),
`TSELS` (Mode 1 / Function 26), `THISTOGRAM` (Mode 3 / Function 8), and
`TSORT` (Mode 3 / Function 12). Mode 3 / Function 9 is reserved. `TSEL` is
Mode 0 / Function 26.

Every selector outside the accepted rows is reserved or illegal.  Removed
identities are not listed here and do not have public instruction pages; see
[Unsupported ISA](../../../status/public/unsupported-isa.md) for the release
boundary.

## Operand binding

Each operation's Tile operands use the active v5 `B.IOT` contract.  In
particular, `PE_MASK`, `TSize`, and the 2-bit Local destination field are
decoded as v5 fields; source reuse modifiers are not part of this ISA.
`B.IOT` order follows the operation's documented operand roles, and the final
binding carries `last`.

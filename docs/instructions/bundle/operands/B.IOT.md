---
{
  "schema_version": 1,
  "id": "header.header-b.iot",
  "kind": "header",
  "title": "B.IOT",
  "status": "active",
  "visibility": "public",
  "profile": "pto-v0",
  "family": "Operand Bindings",
  "sources": { "asl": "asl/bundle/state.asl" }
}
---
# B.IOT

## Purpose

`B.IOT` binds only Local Tile sources and destinations. It carries the
four-PE predicate, source last-use information, and a per-PE `TSize` for each
encoded Local destination. It never binds or configures a Shared register.

## Canonical assembly

```asm
B.IOT T#1, U#2, mask=1111, last, ->T<512B>
B.IOT T#1, mask=0011, last
B.IOT mask=0101, last, ->U<128B>
```

A destination is present exactly when `TSize=001..111`; the codes represent
128 B through 8 KiB per selected PE. A source-only form encodes
`TSize=DstTile=0`. There is no mask-only source form and no source-only
`TSize` form. `PE_MASK=0000` is a strict no-op.

## Encoding

| Bits | Field | Width | Rule |
| --- | --- | ---: | --- |
| `[31:26]` | `SrcTile1` | 6 | present only in two-source forms |
| `[25:20]` | `SrcTile0` | 6 | present only in source forms |
| `[19]` | `last` | 1 | source last-use |
| `[18:15]` | `PE_MASK` | 4 | any bitmask |
| `[14:12]` | `Func` | 3 | form selector |
| `[11:9]` | `TSize` | 3 | destination `001..111`; otherwise `000` |
| `[8:7]` | `DstTile` | 2 | Local T/U/M/N destination hand |
| `[6:0]` | opcode | 7 | `0010011` |

## Rules

- The final `B.IOT` in the Local operand stream sets `last`.
- One- and two-source forms encode only the sources used by the operation.
- Destination size is written only as `->DstTile<TSize>`.
- Source-only forms obtain size and shape from their existing Local descriptor.
- The consumer reads the renamed Local register; it does not reapply
  `PE_MASK`. The mask controls allocation/participation when the binding is
  created.
- CUBE Shared operands are removed from the Local stream and supplied by
  `B.IOS`; the remaining Local `B.IOT` entries use the same mask.
- `TGEMV` remains completely Local.
- Shared mask, Shared size, and Shared register identity are all owned by
  `B.IOS`.

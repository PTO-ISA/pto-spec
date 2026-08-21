---
{
  "schema_version": 1,
  "id": "header.header-b.ios",
  "kind": "header",
  "title": "B.IOS",
  "status": "active",
  "visibility": "public",
  "profile": "pto-v0",
  "family": "Operand Bindings",
  "sources": { "asl": "asl/bundle/state.asl" }
}
---
# B.IOS

## Purpose

`B.IOS` binds one absolute, core-private Shared register `S0..S255` to the
current Tile block. The register bank is visible to all four PEs in the core.
`B.IOS` owns both the four-PE participation mask and, for a destination, the
per-PE allocation size.

## Canonical assembly

```asm
/* source: descriptor and payload are read, not modified */
B.IOS S17, mask=1111

/* destination: one 128-byte fragment is allocated for each selected PE */
B.IOS mask=0011, ->S17<128B>
```

The source form encodes `TSize=000`. The destination form encodes
`TSize=001..111`, representing 128 B, 256 B, 512 B, 1 KiB, 2 KiB, 4 KiB, or
8 KiB per selected PE. `PE_MASK` is a predicate: multiple bits are legal and
`0000` is a strict no-op. The total physical allocation is the per-PE size
multiplied by the number of selected PEs.

## Encoding

| Bits | Field | Width | Rule |
| --- | --- | ---: | --- |
| `[31:28]` | fixed | 4 | `0000` |
| `[27:20]` | `SharedTID` | 8 | absolute `S0..S255` |
| `[19]` | fixed | 1 | `0` |
| `[18:15]` | `PE_MASK` | 4 | any bitmask |
| `[14:12]` | function | 3 | `001` |
| `[11:9]` | `TSize` | 3 | source `000`; destination `001..111` |
| `[8:0]` | opcode | 9 | `0x013` |

The complete 32-bit form has mask `0xf00871ff` and match `0x00001013`.

## Operation schemas

- Shared `TLOAD` consumes exactly one destination `B.IOS` and one `B.IOR`.
- Shared `TSTORE` consumes exactly one source `B.IOS` and one `B.IOR`.
- Cooperative CUBE operations consume source `B.IOS` binders in their
  operation-defined order. All binders and the Local `B.IOT` stream use the
  same `PE_MASK`.
- `TGEMV` is Local-only and rejects `B.IOS`.
- `B.IOT` is Local-only. It never supplies a Shared mask or Shared size.
- Shared TMOV encodings do not exist in PTO. TLSU Function 8 is
  `MGATHER.CAS`; Functions 9..12 and 14..31 are reserved for Linx-only or
  future definitions.

Shared destination updates are atomic descriptor-plus-payload
read-modify-write operations. Reads do not update the descriptor.
Uninitialized selected data has the same undefined-value behavior as reading
an undefined register.

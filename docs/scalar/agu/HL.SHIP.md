<!-- GENERATED FROM: asl/scalar/agu/HL.SHIP.asl -->
# HL.SHIP

**Normative ASL source:** `asl/scalar/agu/HL.SHIP.asl`

HL.SHIP snapshots its scalar sources, forms its encoded address, and stores two adjacent aligned little-endian 2-byte values.

## Normative identity {#PTO-INST-SCALAR-HL-SHIP}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-ship-purpose role=purpose -->
## What `HL.SHIP` stores

`HL.SHIP` is a standalone `48`-bit scalar AGU instruction that stores two adjacent `2`-byte little-endian units at a `2`-scaled `simm17` displacement from the `SrcR` base.

The canonical assembly is `hl.ship SrcD, SrcD1, [SrcR, simm]`.

Design point: the scale matches the unit size, so the encoded displacement is an index into an array of `2`-byte elements and the pair writes elements at two consecutive indices.

<!-- PTO-READER-BLOCK: scalar-hl-ship-mechanism role=mechanism -->
## How the address is formed

The displacement is the sign-extended `simm17` value multiplied by `2`, and it is added to the `SrcR` snapshot modulo `2^PTO_XLEN`; the second address is that sum plus `2`.

The scale is `1`, so the displacement counts `2`-byte units and every reachable displacement is even; an aligned base therefore keeps both units aligned.

The update mode is none, so both stores use the computed addresses and no register receives a result: this form has no `RegDst` field.

Both addresses are probed before either store, and `SrcD` and `SrcD1` are read only after both probes succeed; success then writes the low address first.

Design point: `-65536..65535` scaled by `2` covers every even byte displacement from `-131072` through `131070`, so the displacement itself can never introduce misalignment; an odd base still makes both units unaligned.

<!-- PTO-READER-BLOCK: scalar-hl-ship-inputs role=inputs-outputs -->
## Operands

- `SrcD`, `SrcD1`, and `SrcR` are `5`-bit Reg5 source selectors: codes `0`..`23` select absolute GPRs, `24`..`27` select `T#1`..`T#4`, and `28`..`31` select `U#1`..`U#4`; a queue entry is read without being consumed, and code `0` reads the architectural zero GPR.

- `simm17` is a `17`-bit signed field that assigns every value from `-65536` through `65535`; the encoded byte displacement is that value multiplied by `2`, and encoded zero is a zero displacement rather than omission.

- This form has no `RegDst` field, so no register receives a result and no updated base is published.

Design point: `SrcD` and `SrcD1` are ordinary Reg5 sources, so a `T` or `U` queue entry can be saved directly without being consumed by the read.

<!-- PTO-READER-BLOCK: scalar-hl-ship-effects role=effects -->
## Effects and ordering

Every source is read before the first store, so each value used is a pre-instruction value; `SrcD` and `SrcD1` are read only after both probes succeed.

A successful execution records two relaxed store events in increasing address order and changes only the `4` bytes of the two units.

A valid reservation is invalidated when either store overlaps the reservation's `64`-byte granule, and only after both probes succeed; a reservation whose granule neither store touches stays valid.

`TPC` advances by `6` bytes after the store completes. A rejected or faulting attempt does not retire.

Design point: two relaxed store events are recorded in increasing address order, so the low unit is the one whose event precedes the high unit.

<!-- PTO-READER-BLOCK: scalar-hl-ship-constraints role=constraints -->
## Alignment, faults, and restart

- Both effective addresses must be a multiple of `2`. The first address is probed first: a misaligned first address raises `Fault_DataAlignment` before translation, and a permission or bounded-memory failure raises `Fault_DataPage` at the original address. The second address repeats both tests.

- A fixed-bit mismatch, or a source selector naming an unavailable `T` or `U` entry, raises `Fault_IllegalInstruction` at `PC` before any instruction effect.

- A fault records no store event: memory and every register keep their pre-instruction values, `TPC` is not advanced, and recovery recomputes both addresses, both probes, and both stores.

Design point: both probes run before the first byte is written, so a `Fault_DataPage` raised for the second address leaves the first `2`-byte unit unwritten.

<!-- PTO-READER-BLOCK: scalar-hl-ship-example role=example -->
## Worked example

This example demonstrates the address calculation only; exact behavior remains in the current ASL and instruction contract.

- `hl.ship 20, 21, [2, 3]` with GPR2 = `0x4000`, GPR20 = `0xbeef`, and GPR21 = `0x1234`.

- The displacement `3` multiplied by `2` is `6`, so the two addresses are `0x4006` and `0x4008`.

- The first store writes `0xef`, `0xbe` at `0x4006` through `0x4007`, and the second writes `0x34`, `0x12` at `0x4008` through `0x4009`, both in increasing address order.

- `SrcD`, `SrcD1`, and `SrcR` keep their pre-instruction values, and `TPC` advances by `6` bytes.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.ship SrcD, SrcD1, [SrcR, simm]
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_ship_48_156afe74f95b | HL48 | 48 | 0x00001059001e / 0x0000707f003f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_ship_48_156afe74f95b | SrcD | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_ship_48_156afe74f95b | SrcD1 | 5 | encoding-defined | [{"instruction_lsb":6,"value_lsb":0,"width":5}] |
| hl_ship_48_156afe74f95b | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |
| hl_ship_48_156afe74f95b | simm17 | 17 | signed | [{"instruction_lsb":41,"value_lsb":0,"width":7},{"instruction_lsb":23,"value_lsb":7,"width":5},{"instruction_lsb":11,"value_lsb":12,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_ship_48_156afe74f95b | SrcD | 5 | 0–31 | none | none | Reg5 first store-data source | Encoded zero reads the architectural zero GPR. |
| hl_ship_48_156afe74f95b | SrcD1 | 5 | 0–31 | none | none | Reg5 second store-data source | Encoded zero reads the architectural zero GPR. |
| hl_ship_48_156afe74f95b | SrcR | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| hl_ship_48_156afe74f95b | simm17 | 17 | 0–131071 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcD | Reg5 first store-data source |
| SrcD1 | Reg5 second store-data source |
| SrcR | Reg5 address-base source |
| simm17 | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.SHIP.asl -->
```asl
readonly func InstructionContractOperation_HL_SHIP() => ScalarOperation
begin
    return ScalarOperation_HL_SHIP;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.SHIP.asl -->
```asl
readonly func InstructionContractHandler_HL_SHIP()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStorePair;
end;

pure func InstructionContractAGUAction_HL_SHIP()
    => ScalarAGUAction
begin
    return ScalarAGU_StorePair;
end;

pure func InstructionContractAGUAddressKind_HL_SHIP()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Immediate;
end;

pure func InstructionContractAGUSizeBytes_HL_SHIP()
    => integer {1,2,4,8}
begin
    return 2;
end;

pure func InstructionContractAGUOffsetScale_HL_SHIP()
    => integer {0..3}
begin
    return 1;
end;

pure func InstructionContractAGUUpdateMode_HL_SHIP()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_HL_SHIP()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_SHIP()
    => boolean
begin
    return FALSE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Every displayed operand field is encoded explicitly; encoded zero is a value and never denotes omission.

## Legality

- Every encoded Reg5 source uses the complete domain: codes 0..23 select absolute GPRs, codes 24..27 select T#1..T#4, and codes 28..31 select U#1..U#4 without consumption.
- simm17 assigns every signed 17-bit value -65536..65535; the encoded byte displacement is that value multiplied by 2.
- Each memory address must be aligned to the 2-byte access size; a 2-byte access is the complete transfer unit.

## State effects

- Sign-extend simm17, multiply it by 2, and add it modulo 2^PTO_XLEN to the SrcR base.
- The pair addresses are address and address plus 2; the instruction performs no base writeback.
- Snapshot every store-data source before any memory effect or destination publication.
- Successful execution advances TPC by 6 bytes; a rejected or faulting attempt does not retire.

## Memory effects and ordering

### Memory effects

- Preflight both adjacent 2-byte addresses before either store; on success record two relaxed store events in address order.
- Successful overlapping stores invalidate an overlapping reservation only after complete pair preflight.

### Ordering

- Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.
- Preflight both addresses, commit the two relaxed 2-byte operations in address order, publish ordered results if any, then advance TPC.

## Exceptions

- A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.
- A misaligned 2-byte address raises Fault_DataAlignment before translation or permission. A later permission or bounded-memory failure raises Fault_DataPage at the original address.
- A fault emits no successful memory event, performs no partial memory or destination effect, preserves pending writeback, and leaves TPC at the faulting instruction.
- Recovery performs a full reissue: every address, source snapshot, preflight, memory operation, and destination is recomputed with no retained progress.

## Examples

- hl.ship SrcD, SrcD1, [SrcR, simm]

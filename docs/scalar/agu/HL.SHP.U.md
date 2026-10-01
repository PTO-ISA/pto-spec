<!-- GENERATED FROM: asl/scalar/agu/HL.SHP.U.asl -->
# HL.SHP.U

**Normative ASL source:** `asl/scalar/agu/HL.SHP.U.asl`

HL.SHP.U snapshots its scalar sources, forms its encoded address, and stores two adjacent aligned little-endian 2-byte values.

## Normative identity {#PTO-INST-SCALAR-HL-SHP-U}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-shp-u-purpose role=purpose -->
## What `HL.SHP.U` stores

`HL.SHP.U` is a standalone `48`-bit scalar AGU instruction that stores two adjacent `2`-byte little-endian units at an unscaled register offset from the `SrcL` base.

The canonical assembly is `hl.shp.u SrcD, SrcD1, [SrcL, SrcR<{.sw,.uw}>]`.

Design point: the offset is a byte count, so a byte cursor can place the pair at any even byte position and the pair still writes two adjacent units.

<!-- PTO-READER-BLOCK: scalar-hl-shp-u-mechanism role=mechanism -->
## How the address is formed

The offset is the `SrcR` snapshot selected by `SrcRType`, used without a shift, then added to the `SrcL` snapshot modulo `2^PTO_XLEN`; the second address is that sum plus `2`.

The scale is `0`, so the offset is the transformed `SrcR` value itself and the two addresses differ by exactly `2`.

The update mode is none, so both stores use the computed addresses and no register receives a result: this form has no `RegDst` field.

Both addresses are probed before either store, and `SrcD` and `SrcD1` are read only after both probes succeed; success then writes the low address first.

Design point: with `SrcRType` `01` a `32`-bit value is sign-extended, so `SrcR` equal to `0xfffffffe` supplies an offset of `-2` and moves both units one unit below the base.

<!-- PTO-READER-BLOCK: scalar-hl-shp-u-inputs role=inputs-outputs -->
## Operands

- `SrcD`, `SrcD1`, `SrcL`, and `SrcR` are `5`-bit Reg5 source selectors: codes `0`..`23` select absolute GPRs, `24`..`27` select `T#1`..`T#4`, and `28`..`31` select `U#1`..`U#4`; a queue entry is read without being consumed, and code `0` reads the architectural zero GPR.

- `SrcRType` is `2` bits applied to `SrcR` before the shift: `00` keeps the whole register value, `01` and `10` replace it with the signed and unsigned readings of its low `32` bits, and `11` is reserved.

- This form has no `RegDst` field, so no register receives a result and no updated base is published.

Design point: the base and the offset come from different registers, so changing `SrcL` moves the pair while leaving the byte cursor available for another base.

<!-- PTO-READER-BLOCK: scalar-hl-shp-u-effects role=effects -->
## Effects and ordering

Every source is read before the first store, so each value used is a pre-instruction value; `SrcD` and `SrcD1` are read only after both probes succeed.

A successful execution records two relaxed store events in increasing address order and changes only the `4` bytes of the two units.

A valid reservation is invalidated when either store overlaps the reservation's `64`-byte granule, and only after both probes succeed; a reservation whose granule neither store touches stays valid.

`TPC` advances by `6` bytes after the store completes. A rejected or faulting attempt does not retire.

Design point: neither source of the pair is modified, so the same two registers can be stored to several addresses by changing only the base or the offset.

<!-- PTO-READER-BLOCK: scalar-hl-shp-u-constraints role=constraints -->
## Alignment, faults, and restart

- Both effective addresses must be a multiple of `2`. The first address is probed first: a misaligned first address raises `Fault_DataAlignment` before translation, and a permission or bounded-memory failure raises `Fault_DataPage` at the original address. The second address repeats both tests.

- A fixed-bit mismatch, or a source selector naming an unavailable `T` or `U` entry, raises `Fault_IllegalInstruction` at `PC` before any instruction effect.

- `SrcRType` raw `11` is reserved: it raises `Fault_IllegalInstruction` at `PC` before any source is read, so the address modifier decode only defines `00`, `01`, and `10`.

- A fault records no store event: memory and every register keep their pre-instruction values, `TPC` is not advanced, and recovery recomputes both addresses, both probes, and both stores.

Design point: because the offset is a byte count, the pair can start on any byte; a pair that starts on an odd address is rejected as a whole, so neither unit is written.

<!-- PTO-READER-BLOCK: scalar-hl-shp-u-example role=example -->
## Worked example

This example demonstrates the address calculation only; exact behavior remains in the current ASL and instruction contract.

- `hl.shp.u 20, 21, [2, 7]` with `SrcRType` `01`, GPR2 = `0x3000`, GPR7 = `0x10`, GPR20 = `0xbeef`, and GPR21 = `0x1234`.

- The index `0x10` is used directly as a byte offset, giving `16`, so the two addresses are `0x3010` and `0x3012`.

- The first store writes `0xef`, `0xbe` at `0x3010` through `0x3011`, and the second writes `0x34`, `0x12` at `0x3012` through `0x3013`, both in increasing address order.

- `SrcD`, `SrcD1`, and `SrcL` keep their pre-instruction values, and `TPC` advances by `6` bytes.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.shp.u SrcD, SrcD1, [SrcL, SrcR<{.sw,.uw}>]
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_shp_u_48_232b2200b7b9 | HL48 | 48 | 0x00005049001e / 0x00007ffff83f | [{"field":"SrcRType","operator":"one-of","values":[0,1,2]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_shp_u_48_232b2200b7b9 | SrcD | 5 | encoding-defined | [{"instruction_lsb":43,"value_lsb":0,"width":5}] |
| hl_shp_u_48_232b2200b7b9 | SrcD1 | 5 | encoding-defined | [{"instruction_lsb":6,"value_lsb":0,"width":5}] |
| hl_shp_u_48_232b2200b7b9 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_shp_u_48_232b2200b7b9 | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |
| hl_shp_u_48_232b2200b7b9 | SrcRType | 2 | encoding-defined | [{"instruction_lsb":41,"value_lsb":0,"width":2}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_shp_u_48_232b2200b7b9 | SrcD | 5 | 0–31 | none | none | Reg5 first store-data source | Encoded zero reads the architectural zero GPR. |
| hl_shp_u_48_232b2200b7b9 | SrcD1 | 5 | 0–31 | none | none | Reg5 second store-data source | Encoded zero reads the architectural zero GPR. |
| hl_shp_u_48_232b2200b7b9 | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| hl_shp_u_48_232b2200b7b9 | SrcR | 5 | 0–31 | none | none | Reg5 register-offset source | Encoded zero reads the architectural zero GPR. |
| hl_shp_u_48_232b2200b7b9 | SrcRType | 2 | 0–2 | none | 3 | register-offset transformation selector | Encoded zero leaves the complete PTO_XLEN register-offset value unchanged. |

- `hl_shp_u_48_232b2200b7b9.SrcRType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcD | Reg5 first store-data source |
| SrcD1 | Reg5 second store-data source |
| SrcL | Reg5 address-base source |
| SrcR | Reg5 register-offset source |
| SrcRType | register-offset transformation selector |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.SHP.U.asl -->
```asl
readonly func InstructionContractOperation_HL_SHP_U() => ScalarOperation
begin
    return ScalarOperation_HL_SHP_U;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.SHP.U.asl -->
```asl
readonly func InstructionContractHandler_HL_SHP_U()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStorePair;
end;

pure func InstructionContractAGUAction_HL_SHP_U()
    => ScalarAGUAction
begin
    return ScalarAGU_StorePair;
end;

pure func InstructionContractAGUAddressKind_HL_SHP_U()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Register;
end;

pure func InstructionContractAGUSizeBytes_HL_SHP_U()
    => integer {1,2,4,8}
begin
    return 2;
end;

pure func InstructionContractAGUOffsetScale_HL_SHP_U()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_HL_SHP_U()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_HL_SHP_U()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_SHP_U()
    => boolean
begin
    return FALSE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Every displayed operand field is encoded explicitly; encoded zero is a value and never denotes omission.
- SrcRType=0 leaves SrcR unchanged, SrcRType=1 sign-extends SrcR[31:0], SrcRType=2 zero-extends SrcR[31:0], and SrcRType=3 is reserved. Encoded shamt zero performs no shift.

## Legality

- Every encoded Reg5 source uses the complete domain: codes 0..23 select absolute GPRs, codes 24..27 select T#1..T#4, and codes 28..31 select U#1..U#4 without consumption.
- SrcRType values 0, 1, and 2 and all shamt values 0..31 are assigned; SrcRType=3 is reserved; apply the modifier before the shift.
- Each memory address must be aligned to the 2-byte access size; a 2-byte access is the complete transfer unit.

## State effects

- Form offset = LSL(Modify(SrcR, SrcRType), 0) and add it modulo 2^PTO_XLEN to the SrcL base.
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

- hl.shp.u SrcD, SrcD1, [SrcL, SrcR<{.sw,.uw}>]

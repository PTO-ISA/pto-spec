<!-- GENERATED FROM: asl/scalar/agu/HL.SD.PCR.asl -->
# HL.SD.PCR

**Normative ASL source:** `asl/scalar/agu/HL.SD.PCR.asl`

HL.SD.PCR snapshots its scalar sources, forms its encoded address, and stores one aligned little-endian 8-byte value.

## Normative identity {#PTO-INST-SCALAR-HL-SD-PCR}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-sd-pcr-purpose role=purpose -->
## What `HL.SD.PCR` does

`HL.SD.PCR` is a standalone `48`-bit scalar AGU instruction that stores `SrcL` to one 8-byte little-endian unit at a PC-relative displacement.

The canonical assembly is `hl.sd.pcr SrcL, [<symbol>]`.

Design point: the base is not a register but the instruction's own aligned address, which is why the assembly names `[<symbol>]`. The store target is therefore fixed at link time and cannot be redirected at run time by changing a pointer register.

<!-- PTO-READER-BLOCK: scalar-hl-sd-pcr-mechanism role=mechanism -->
## How the address and the transfer are formed

The base is the instruction address with bits `1`: `0` cleared, so the displacement is measured from a 4-byte-aligned instruction address rather than from the arbitrary bit pattern of `TPC`.

The displacement is the sign-extended `29`-bit immediate left-shifted by `2`, so the encoded field counts 4-byte units and covers `-268435456`..`268435455` units, which is `-1073741824`..`1073741820` bytes. It is added to the aligned base modulo `2^PTO_XLEN`.

The address is preflighted before the store. On success one 8-byte little-endian store is performed and one relaxed store event is recorded.

Design point: the base is only `4`-byte aligned and the displacement counts `4`-byte units while the transfer is `8` bytes wide, so a `4`-byte-aligned address that is not `8`-byte aligned is reachable. The probe then raises `Fault_DataAlignment`, which is how a symbol the linker placed off an `8`-byte boundary is reported rather than silently rounded.

<!-- PTO-READER-BLOCK: scalar-hl-sd-pcr-inputs role=inputs-outputs -->
## Encoded fields and the effect

- `SrcL` is a `5`-bit Reg5 selector and supplies the store data. Codes `0`..`23` select absolute GPRs, `24`..`27` select `T#1`..`T#4`, and `28`..`31` select `U#1`..`U#4`; a queue entry is read without being consumed.
- `simm` is a signed `29`-bit displacement in 4-byte units, carried in the encoding as three pieces at bits `36`..`47`, bits `23`..`27`, and bits `4`..`15`.
- This form has no `RegDst` field, so no register receives a result and no updated base is published.

Design point: all 8 bytes of the source are the transfer, so the low byte lands at the lowest address and the high byte at the highest. No truncation happens on this form, unlike a narrower store of the same register.

<!-- PTO-READER-BLOCK: scalar-hl-sd-pcr-effects role=effects -->
## Effects, ordering, and completion

`SrcL` is read before any memory effect, so the value stored is the pre-instruction value of that source even if a later instruction overwrites it.

A successful execution writes 8 memory bytes in little-endian order. A valid reservation is invalidated when the stored range overlaps the reservation's `64`-byte granule; a reservation whose granule the store leaves untouched stays valid.

`TPC` advances by `6` bytes after the memory operation completes. A rejected or faulting attempt does not retire.

Design point: only the bytes this store actually covers are affected, so a store to a range that misses the reservation granule leaves the reservation intact. The invalidate test is the overlap of the written range, not of the whole granule.

<!-- PTO-READER-BLOCK: scalar-hl-sd-pcr-constraints role=constraints -->
## Legality, faults, and restart

A fixed-bit mismatch, or a source code selecting an unavailable `T` or `U` slot, raises `Fault_IllegalInstruction` before any instruction effect.

A misaligned 8-byte address raises `Fault_DataAlignment` before translation or permission. A later permission or bounded-memory failure raises `Fault_DataPage` at the original address.

A fault records no store event, leaves memory and destination registers unchanged, and keeps `TPC` on the faulting instruction. Recovery recomputes the snapshot, the base, the displacement, and the probe from the beginning.

Design point: the alignment test runs before the permission test, so a misaligned address is always reported as `Fault_DataAlignment` even when it is also outside the permitted region. A program cannot use the alignment fault to probe which addresses are permitted.

<!-- PTO-READER-BLOCK: scalar-hl-sd-pcr-example role=example -->
## Reading one encoding end to end

This walkthrough explains how to use the page and does not add instruction behavior.

- Suppose the instruction sits at `0x3004`, so the aligned base is `0x3004`, and GPR5 = `0x0807060504030201`.
- Take a displacement of `-1` unit, that is `-4`, so the effective address is `0x3000`.
- `0x3000` is 8-byte aligned, so the probe passes and the 8 bytes `01` `02` `03` `04` `05` `06` `07` `08` are written at `0x3000` in increasing address order.
- No register changes, and `TPC` becomes the instruction address plus `6`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.sd.pcr SrcL, [<symbol>]
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_sd_pcr_48_8ed6bb942a78 | HL48 | 48 | 0x00003069000e / 0x0000707f000f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_sd_pcr_48_8ed6bb942a78 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_sd_pcr_48_8ed6bb942a78 | simm | 29 | signed | [{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":23,"value_lsb":12,"width":5},{"instruction_lsb":4,"value_lsb":17,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_sd_pcr_48_8ed6bb942a78 | SrcL | 5 | 0–31 | none | none | Reg5 store-data source | Encoded zero reads the architectural zero GPR. |
| hl_sd_pcr_48_8ed6bb942a78 | simm | 29 | 0–536870911 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 store-data source |
| simm | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.SD.PCR.asl -->
```asl
readonly func InstructionContractOperation_HL_SD_PCR() => ScalarOperation
begin
    return ScalarOperation_HL_SD_PCR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.SD.PCR.asl -->
```asl
readonly func InstructionContractHandler_HL_SD_PCR()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStore;
end;

pure func InstructionContractAGUAction_HL_SD_PCR()
    => ScalarAGUAction
begin
    return ScalarAGU_Store;
end;

pure func InstructionContractAGUAddressKind_HL_SD_PCR()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_PCRelative;
end;

pure func InstructionContractAGUSizeBytes_HL_SD_PCR()
    => integer {1,2,4,8}
begin
    return 8;
end;

pure func InstructionContractAGUOffsetScale_HL_SD_PCR()
    => integer {0..3}
begin
    return 2;
end;

pure func InstructionContractAGUUpdateMode_HL_SD_PCR()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_HL_SD_PCR()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_SD_PCR()
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
- simm assigns every signed 29-bit value -268435456..268435455; the encoded byte displacement is that value multiplied by 4.
- Each memory address must be aligned to the 8-byte access size; a 8-byte access is the complete transfer unit.

## State effects

- Clear TPC bits 1:0, sign-extend the encoded displacement, multiply it by four, and add it modulo 2^PTO_XLEN.
- Snapshot every store-data source before any memory effect or destination publication.
- Successful execution advances TPC by 6 bytes; a rejected or faulting attempt does not retire.

## Memory effects and ordering

### Memory effects

- After complete preflight, perform one little-endian 8-byte store and record one relaxed store event.
- A successful overlapping store invalidates the overlapping reservation; a nonoverlapping reservation remains valid.

### Ordering

- Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.
- Complete the relaxed 8-byte memory operation, publish any result or writeback, and then advance TPC.

## Exceptions

- A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.
- A misaligned 8-byte address raises Fault_DataAlignment before translation or permission. A later permission or bounded-memory failure raises Fault_DataPage at the original address.
- A fault emits no successful memory event, performs no partial memory or destination effect, preserves pending writeback, and leaves TPC at the faulting instruction.
- Recovery performs a full reissue: every address, source snapshot, preflight, memory operation, and destination is recomputed with no retained progress.

## Examples

- hl.sd.pcr SrcL, [<symbol>]

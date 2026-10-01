<!-- GENERATED FROM: asl/scalar/agu/HL.SDI.UPR.asl -->
# HL.SDI.UPR

**Normative ASL source:** `asl/scalar/agu/HL.SDI.UPR.asl`

HL.SDI.UPR snapshots its scalar sources, forms its encoded address, and stores one aligned little-endian 8-byte value.

## Normative identity {#PTO-INST-SCALAR-HL-SDI-UPR}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-sdi-upr-purpose role=purpose -->
## What `HL.SDI.UPR` does

`HL.SDI.UPR` is a standalone `48`-bit scalar AGU instruction that stores one `8`-byte little-endian unit from `SrcD` at a signed `simm17` displacement from the `SrcR` base.

The canonical assembly is `hl.sdi.upr SrcD, [SrcR, simm], ->{t, u, Rd}`.

Design point: this is the pre-index form of the unscaled `8`-byte store: the access uses the updated base, and the same updated base is published after the store succeeds. The displacement counts bytes.

<!-- PTO-READER-BLOCK: scalar-hl-sdi-upr-mechanism role=mechanism -->
## How the address and the transfer are formed

The displacement is the sign-extended `simm17` value with a shift of `0` and is added to the `SrcR` snapshot modulo `2^PTO_XLEN`. The base is read before any memory effect, so a later write-back of the same register cannot change the address this store uses.

The address is preflighted before the store. On success one `8`-byte little-endian store is performed and one relaxed store event is recorded.

The pre-index address is the base plus the byte displacement, so one sum serves both the access and the published value.

Design point: the accessed address and the published base are the same sum, so `->6` with `SrcR` = GPR6 publishes the address it stored through. A fault leaves the register on its old value, so a retry targets the same address.

<!-- PTO-READER-BLOCK: scalar-hl-sdi-upr-inputs role=inputs-outputs -->
## Encoded fields and the effect

- `SrcD` is a `5`-bit Reg5 selector. Codes `0`..`23` select absolute GPRs, `24`..`27` select `T#1`..`T#4`, and `28`..`31` select `U#1`..`U#4`; a queue entry is read without being consumed.
- `SrcR` is a `5`-bit Reg5 selector. Codes `0`..`23` select absolute GPRs, `24`..`27` select `T#1`..`T#4`, and `28`..`31` select `U#1`..`U#4`; a queue entry is read without being consumed.
- `simm17` is a signed `17`-bit displacement carried in the encoding as three pieces at bits `41`..`47`, bits `23`..`27`, and bits `6`..`10`, covering `-65536`..`65535` bytes.
- `RegDst` is a `5`-bit selector. Codes `1`..`23` write absolute GPRs, code `30` pushes `U`, code `31` pushes `T`, and codes `0` and `24`..`29` discard that one result without suppressing the other effects.
- Design point: `SrcD` may name the same register as `RegDst`. The store data is read before any destination effect, so the memory operation stores the pre-instruction value while the register afterwards holds the updated base.

<!-- PTO-READER-BLOCK: scalar-hl-sdi-upr-effects role=effects -->
## Effects, ordering, and completion

Every scalar source is snapshotted before any memory or destination effect, so a source that a destination also names still contributes the pre-instruction value.

In memory, a successful execution changes only the bytes inside the stored range. The updated base is published to `RegDst` when the store completes without fault. A valid reservation is invalidated when the stored range overlaps the reservation's `64`-byte granule; a reservation whose granule the store leaves untouched stays valid.

`TPC` advances by `6` bytes after the memory operation completes. A rejected or faulting attempt does not retire.

Design point: all `8` bytes of `SrcD` are the transfer, so the low byte lands at the lowest address of the unit. There is no truncation.

<!-- PTO-READER-BLOCK: scalar-hl-sdi-upr-constraints role=constraints -->
## Legality, faults, and restart

- A fixed-bit mismatch, or a source code selecting an unavailable `T` or `U` slot, raises `Fault_IllegalInstruction` before any instruction effect.
- A misaligned `8`-byte address raises `Fault_DataAlignment` before translation or permission. A later permission or bounded-memory failure raises `Fault_DataPage` at the original address.
- A fault records no store event, leaves memory and destination registers unchanged, and keeps `TPC` on the faulting instruction. Recovery recomputes the snapshot, the address, the probe, and the store from the beginning.
- Design point: a byte-granular displacement can move the base off an `8`-byte boundary, and the instruction then reports `Fault_DataAlignment` for that access instead of storing through a rounded address. No register receives the updated base, so the walk does not advance and a retry targets the same address.

<!-- PTO-READER-BLOCK: scalar-hl-sdi-upr-example role=example -->
## Reading one encoding end to end

This walkthrough explains how to use the page and does not add instruction behavior.

- Suppose `hl.sdi.upr 5, [6, -1], ->8` runs with GPR6 = `0x2008` and GPR5 = `0x0807060504030201`.
- The pre-index address is `0x2007`, which is not `8`-byte aligned.
- Preflight therefore raises `Fault_DataAlignment` and no byte is written.
- GPR6 still holds `0x2008`, and `TPC` stays on the faulting instruction.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.sdi.upr SrcD, [SrcR, simm], ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_sdi_upr_48_f8aba43b65d5 | HL48 | 48 | 0x00007059002e / 0x0000707f003f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_sdi_upr_48_f8aba43b65d5 | RegDst | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_sdi_upr_48_f8aba43b65d5 | SrcD | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_sdi_upr_48_f8aba43b65d5 | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |
| hl_sdi_upr_48_f8aba43b65d5 | simm17 | 17 | signed | [{"instruction_lsb":41,"value_lsb":0,"width":7},{"instruction_lsb":23,"value_lsb":7,"width":5},{"instruction_lsb":6,"value_lsb":12,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_sdi_upr_48_f8aba43b65d5 | RegDst | 5 | 0–31 | none | none | Reg5 updated-base destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_sdi_upr_48_f8aba43b65d5 | SrcD | 5 | 0–31 | none | none | Reg5 first store-data source | Encoded zero reads the architectural zero GPR. |
| hl_sdi_upr_48_f8aba43b65d5 | SrcR | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| hl_sdi_upr_48_f8aba43b65d5 | simm17 | 17 | 0–131071 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 updated-base destination or discard |
| SrcD | Reg5 first store-data source |
| SrcR | Reg5 address-base source |
| simm17 | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.SDI.UPR.asl -->
```asl
readonly func InstructionContractOperation_HL_SDI_UPR() => ScalarOperation
begin
    return ScalarOperation_HL_SDI_UPR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.SDI.UPR.asl -->
```asl
readonly func InstructionContractHandler_HL_SDI_UPR()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStore;
end;

pure func InstructionContractAGUAction_HL_SDI_UPR()
    => ScalarAGUAction
begin
    return ScalarAGU_Store;
end;

pure func InstructionContractAGUAddressKind_HL_SDI_UPR()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Immediate;
end;

pure func InstructionContractAGUSizeBytes_HL_SDI_UPR()
    => integer {1,2,4,8}
begin
    return 8;
end;

pure func InstructionContractAGUOffsetScale_HL_SDI_UPR()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_HL_SDI_UPR()
    => AddressUpdateMode
begin
    return AddressUpdate_PreIndex;
end;

pure func InstructionContractAGUSignedLoad_HL_SDI_UPR()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_SDI_UPR()
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
- Every Reg5 destination is assigned: codes 1..23 write GPRs, code 30 pushes U, code 31 pushes T, and codes 0 and 24..29 discard only that result.
- simm17 assigns every signed 17-bit value -65536..65535; the encoded byte displacement is that value multiplied by 1.
- Each memory address must be aligned to the 8-byte access size; a 8-byte access is the complete transfer unit.

## State effects

- Sign-extend simm17, multiply it by 1, and add it modulo 2^PTO_XLEN to the SrcR base.
- Pre-index mode accesses the updated base and publishes that same updated base only after successful memory completion.
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

- hl.sdi.upr SrcD, [SrcR, simm], ->{t, u, Rd}

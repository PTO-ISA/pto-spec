<!-- GENERATED FROM: asl/scalar/agu/HL.SDI.U.asl -->
# HL.SDI.U

**Normative ASL source:** `asl/scalar/agu/HL.SDI.U.asl`

HL.SDI.U snapshots its scalar sources, forms its encoded address, and stores one aligned little-endian 8-byte value.

## Normative identity {#PTO-INST-SCALAR-HL-SDI-U}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-sdi-u-purpose role=purpose -->
## What `HL.SDI.U` does

`HL.SDI.U` is a standalone `48`-bit scalar AGU instruction that stores one `8`-byte little-endian unit from `SrcD` at a signed `simm22` displacement from the `SrcR` base.

The canonical assembly is `hl.sdi.u SrcD, [SrcR, simm]`.

Design point: the `.u` suffix drops the implicit `8`-byte scale that `hl.sdi`, `hl.sdi.po`, and `hl.sdi.pr` carry, so this form counts bytes. The wider `22`-bit field is what pays for the finer step: it still reaches `-2097152`..`2097151` bytes.

<!-- PTO-READER-BLOCK: scalar-hl-sdi-u-mechanism role=mechanism -->
## How the address and the transfer are formed

The displacement is the sign-extended `simm22` value with a shift of `0` and is added to the `SrcR` snapshot modulo `2^PTO_XLEN`. The base is read before any memory effect, so a later write-back of the same register cannot change the address this store uses.

The address is preflighted before the store. On success one `8`-byte little-endian store is performed and one relaxed store event is recorded.

Because the update mode is none, the form has no `RegDst` field and publishes nothing. The base and the value are the only registers it reads.

<!-- PTO-READER-BLOCK: scalar-hl-sdi-u-inputs role=inputs-outputs -->
## Encoded fields and the effect

- `SrcD` is a `5`-bit Reg5 selector. Codes `0`..`23` select absolute GPRs, `24`..`27` select `T#1`..`T#4`, and `28`..`31` select `U#1`..`U#4`; a queue entry is read without being consumed.
- `SrcR` is a `5`-bit Reg5 selector. Codes `0`..`23` select absolute GPRs, `24`..`27` select `T#1`..`T#4`, and `28`..`31` select `U#1`..`U#4`; a queue entry is read without being consumed.
- `simm22` is a signed `22`-bit displacement carried in the encoding as three pieces at bits `41`..`47`, bits `23`..`27`, and bits `6`..`15`, covering `-2097152`..`2097151` bytes.
- This form has no `RegDst` field, so no register receives a result and no updated base is published.
- Design point: the byte-granular displacement reaches any byte offset in the window, so this form can store into a packed structure. The `8`-byte alignment rule still applies to whatever address the sum produces.

<!-- PTO-READER-BLOCK: scalar-hl-sdi-u-effects role=effects -->
## Effects, ordering, and completion

Every scalar source is snapshotted before any memory or destination effect, so a source that a destination also names still contributes the pre-instruction value.

In memory, a successful execution changes only the bytes inside the stored range. A valid reservation is invalidated when the stored range overlaps the reservation's `64`-byte granule; a reservation whose granule the store leaves untouched stays valid.

`TPC` advances by `6` bytes after the memory operation completes. A rejected or faulting attempt does not retire.

Design point: all `8` bytes of `SrcD` are the transfer, so the low byte lands at the lowest address of the unit. There is no truncation.

<!-- PTO-READER-BLOCK: scalar-hl-sdi-u-constraints role=constraints -->
## Legality, faults, and restart

- A fixed-bit mismatch, or a source code selecting an unavailable `T` or `U` slot, raises `Fault_IllegalInstruction` before any instruction effect.
- A misaligned `8`-byte address raises `Fault_DataAlignment` before translation or permission. A later permission or bounded-memory failure raises `Fault_DataPage` at the original address.
- A fault records no store event, leaves memory and destination registers unchanged, and keeps `TPC` on the faulting instruction. Recovery recomputes the snapshot, the address, the probe, and the store from the beginning.
- Design point: an unscaled immediate plus an arbitrary base can land off an `8`-byte boundary, and the instruction reports that as `Fault_DataAlignment` rather than rounding the address. A program that needs a guaranteed-aligned store must keep the base aligned itself.

<!-- PTO-READER-BLOCK: scalar-hl-sdi-u-example role=example -->
## Reading one encoding end to end

This walkthrough explains how to use the page and does not add instruction behavior.

- Suppose `hl.sdi.u 5, [6, -1]` runs with GPR6 = `0x2000` and GPR5 = `0x0807060504030201`.
- The address is `0x1FFF`, which is not `8`-byte aligned.
- Preflight therefore raises `Fault_DataAlignment` and no byte is written.
- No register changes either, and `TPC` stays on the faulting instruction.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.sdi.u SrcD, [SrcR, simm]
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_sdi_u_48_d9597eeba6b4 | HL48 | 48 | 0x00007059000e / 0x0000707f003f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_sdi_u_48_d9597eeba6b4 | SrcD | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_sdi_u_48_d9597eeba6b4 | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |
| hl_sdi_u_48_d9597eeba6b4 | simm22 | 22 | signed | [{"instruction_lsb":41,"value_lsb":0,"width":7},{"instruction_lsb":23,"value_lsb":7,"width":5},{"instruction_lsb":6,"value_lsb":12,"width":10}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_sdi_u_48_d9597eeba6b4 | SrcD | 5 | 0–31 | none | none | Reg5 first store-data source | Encoded zero reads the architectural zero GPR. |
| hl_sdi_u_48_d9597eeba6b4 | SrcR | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| hl_sdi_u_48_d9597eeba6b4 | simm22 | 22 | 0–4194303 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcD | Reg5 first store-data source |
| SrcR | Reg5 address-base source |
| simm22 | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.SDI.U.asl -->
```asl
readonly func InstructionContractOperation_HL_SDI_U() => ScalarOperation
begin
    return ScalarOperation_HL_SDI_U;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.SDI.U.asl -->
```asl
readonly func InstructionContractHandler_HL_SDI_U()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStore;
end;

pure func InstructionContractAGUAction_HL_SDI_U()
    => ScalarAGUAction
begin
    return ScalarAGU_Store;
end;

pure func InstructionContractAGUAddressKind_HL_SDI_U()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Immediate;
end;

pure func InstructionContractAGUSizeBytes_HL_SDI_U()
    => integer {1,2,4,8}
begin
    return 8;
end;

pure func InstructionContractAGUOffsetScale_HL_SDI_U()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_HL_SDI_U()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_HL_SDI_U()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_SDI_U()
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
- simm22 assigns every signed 22-bit value -2097152..2097151; the encoded byte displacement is that value multiplied by 1.
- Each memory address must be aligned to the 8-byte access size; a 8-byte access is the complete transfer unit.

## State effects

- Sign-extend simm22, multiply it by 1, and add it modulo 2^PTO_XLEN to the SrcR base.
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

- hl.sdi.u SrcD, [SrcR, simm]

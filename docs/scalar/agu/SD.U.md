<!-- GENERATED FROM: asl/scalar/agu/SD.U.asl -->
# SD.U

**Normative ASL source:** `asl/scalar/agu/SD.U.asl`

SD.U snapshots its scalar sources, forms its encoded address, and stores one aligned little-endian 8-byte value.

## Normative identity {#PTO-INST-SCALAR-SD-U}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-sd-u-purpose role=purpose -->
## What `SD.U` does

`SD.U` writes the low `8` bytes of `SrcD` to the address formed from the `SrcL` base plus the transformed `SrcR` register offset. Its canonical assembly is `sd.u SrcD, [SrcL, SrcR<{.sw,.uw}>]`.

Design point: the `.u` marker removes the element-size scale. `SD` multiplies the offset by `8`, while `SD.U` adds it unchanged, so one offset register value reaches a location `8` times further from the base under `SD` than under `SD.U`.

<!-- PTO-READER-BLOCK: scalar-sd-u-mechanism role=mechanism -->
## How `SD.U` forms the address and completes the store

`SrcL` supplies the base. `SrcR` is transformed by `SrcRType` — `0` keeps the complete `64`-bit value, `1` sign-extends the low `32` bits, `2` zero-extends them — and the fixed scale of `1` leaves it unshifted. Base and offset are added modulo `2^PTO_XLEN`.

The value written to that address is the low `8` bytes of `SrcD`, least-significant byte at the lowest address. The form has no destination field: nothing in the encoding selects a register or queue slot to write, so a store never publishes a result and never updates a base.

Design point: with an unscaled offset, an offset of `1` is misaligned for an `8`-byte access whenever the base is `8`-byte aligned. In `SD` that same offset of `1` is multiplied by `8` and stays aligned, so the `.u` form moves the alignment burden onto the offset value.

<!-- PTO-READER-BLOCK: scalar-sd-u-inputs role=inputs-outputs -->
## Encoded fields and what the store consumes

- `SrcD`, `SrcL`, and `SrcR` are `5`-bit Reg5 sources. Codes `0`..`23` name absolute GPRs, `24`..`27` name `T#1`..`T#4`, and `28`..`31` name `U#1`..`U#4`. Reading a `T` or `U` slot neither consumes nor reorders it, and code `0` supplies the constant zero GPR.
- `SrcRType` is assigned for `0`, `1`, and `2`; raw `3` is reserved. The form has no `shamt` field, so the scale of the offset is fixed at `1`.
- The form has no destination field: nothing in the encoding selects a register or queue slot to write, so a store never publishes a result and never updates a base.

Design point: the three register fields are all validated before the access, so an offset that names an unavailable `T`/`U` slot is rejected before any address arithmetic, just like an unavailable base or data source.

<!-- PTO-READER-BLOCK: scalar-sd-u-effects role=effects -->
## Effects, ordering, and completion

Both sources are read before the memory effect, so the stored bytes are the pre-instruction value of `SrcD`.

Successful execution performs one relaxed `8`-byte store and records one store event. A store whose byte range overlaps the `64`-byte reservation granule that contains a valid reservation invalidates that reservation; a store outside the granule leaves it valid. `TPC` then advances by `4` bytes.

Design point: nothing in this form can publish an updated address, so software that needs a running pointer must recompute it with a separate instruction. The store itself leaves `SrcL` and `SrcR` untouched.

<!-- PTO-READER-BLOCK: scalar-sd-u-constraints role=constraints -->
## Legality, faults, and restart

Dispatch rejects the instruction with `Fault_IllegalInstruction` before any effect when the fixed bits do not match, when `SrcRType` holds the reserved value `3`, or when a selected `T`/`U` source is unavailable because nothing has been pushed into it.

The preflight tests the low `3` bits of the effective address, because the access is `8` bytes wide. An unaligned value raises `Fault_DataAlignment` before translation; an aligned address that fails a permission or bounded-memory test raises `Fault_DataPage` at the original address.

A fault writes no memory byte, records no store event, and leaves `TPC` on the faulting instruction. Recovery reissues the whole operation: every source read, the address arithmetic, the preflight, and the store.

Design point: because the scale is `1`, both operands decide the alignment: the same offset register that is aligned for one base can be misaligned for another. This form suits a program whose byte offset is already computed.

<!-- PTO-READER-BLOCK: scalar-sd-u-example role=example -->
## Reading one encoding end to end

This example demonstrates the address calculation only; exact behavior remains in the current ASL and instruction contract.

- Take `sd.u 6, [2, 3]` with GPR2 = `0x1000`, GPR3 = `1`, and GPR6 = `0x0123456789ABCDEF`.
- The offset is used as encoded, so the effective address is `0x1001`.
- `0x1001` is not a multiple of `8`, so the preflight raises `Fault_DataAlignment` and no byte is written.
- With the same operands in `sd`, the offset would be `1` times `8` and the address `0x1008`, where the `8` bytes `EF CD AB 89 67 45 23 01` would be written.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
sd.u SrcD, [SrcL, SrcR<{.sw,.uw}>]
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| sd_u_32_1602c58c2031 | L32 | 32 | 0x00007049 / 0x00007fff | [{"field":"SrcRType","operator":"one-of","values":[0,1,2]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| sd_u_32_1602c58c2031 | SrcD | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |
| sd_u_32_1602c58c2031 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| sd_u_32_1602c58c2031 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| sd_u_32_1602c58c2031 | SrcRType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| sd_u_32_1602c58c2031 | SrcD | 5 | 0–31 | none | none | Reg5 first store-data source | Encoded zero reads the architectural zero GPR. |
| sd_u_32_1602c58c2031 | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| sd_u_32_1602c58c2031 | SrcR | 5 | 0–31 | none | none | Reg5 register-offset source | Encoded zero reads the architectural zero GPR. |
| sd_u_32_1602c58c2031 | SrcRType | 2 | 0–2 | none | 3 | register-offset transformation selector | Encoded zero leaves the complete PTO_XLEN register-offset value unchanged. |

- `sd_u_32_1602c58c2031.SrcRType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcD | Reg5 first store-data source |
| SrcL | Reg5 address-base source |
| SrcR | Reg5 register-offset source |
| SrcRType | register-offset transformation selector |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/SD.U.asl -->
```asl
readonly func InstructionContractOperation_SD_U() => ScalarOperation
begin
    return ScalarOperation_SD_U;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/SD.U.asl -->
```asl
readonly func InstructionContractHandler_SD_U()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStore;
end;

pure func InstructionContractAGUAction_SD_U()
    => ScalarAGUAction
begin
    return ScalarAGU_Store;
end;

pure func InstructionContractAGUAddressKind_SD_U()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Register;
end;

pure func InstructionContractAGUSizeBytes_SD_U()
    => integer {1,2,4,8}
begin
    return 8;
end;

pure func InstructionContractAGUOffsetScale_SD_U()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_SD_U()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_SD_U()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_SD_U()
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
- Each memory address must be aligned to the 8-byte access size; a 8-byte access is the complete transfer unit.

## State effects

- Form offset = LSL(Modify(SrcR, SrcRType), 0) and add it modulo 2^PTO_XLEN to the SrcL base.
- Snapshot every store-data source before any memory effect or destination publication.
- Successful execution advances TPC by 4 bytes; a rejected or faulting attempt does not retire.

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

- sd.u SrcD, [SrcL, SrcR<{.sw,.uw}>]

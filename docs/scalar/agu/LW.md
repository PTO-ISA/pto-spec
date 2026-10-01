<!-- GENERATED FROM: asl/scalar/agu/LW.asl -->
# LW

**Normative ASL source:** `asl/scalar/agu/LW.asl`

LW snapshots its scalar sources, forms its encoded address, and loads one aligned little-endian 4-byte value.

## Normative identity {#PTO-INST-SCALAR-LW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-lw-purpose role=purpose -->
## What `LW` does

`LW` loads one `4`-byte little-endian word from a base register plus a transformed and shifted register offset, then sign-extends the loaded `32` bits to `PTO_XLEN` before they reach `RegDst`. Its canonical assembly is `lw [SrcL, SrcR<{.sw,.uw}><<<shamt>], ->{t, u, Rd}`.

Design point: `LW` and `LWU` share one addressing operation and differ only in extension. The bytes `FF FF FF FF` publish `0xFFFFFFFFFFFFFFFF` through `LW` and `0x00000000FFFFFFFF` through `LWU`, so the mnemonic decides what bits `63`:`32` of the destination hold.

<!-- PTO-READER-BLOCK: scalar-lw-mechanism role=mechanism -->
## How `LW` forms the address and completes the access

`SrcL` is read as the base. `SrcR` is transformed by `SrcRType` — `0` keeps the complete `64`-bit value, `1` sign-extends the low `32` bits, `2` zero-extends them — and the result is shifted left by the encoded `shamt`. Base and offset are added modulo `2^PTO_XLEN`.

That sum is used by one little-endian `4`-byte load; there is no base writeback and no second destination. The result is sign-extended and written through `RegDst` only if the load reported no fault.

Design point: the transformation runs before the shift, so a negative word index keeps its sign through the scaling. `SrcRType=1` with `SrcR` = `0xFFFFFFFE` and `shamt=3` gives the offset `-16`. Reversing the steps would scale the zero-extended value.

<!-- PTO-READER-BLOCK: scalar-lw-inputs role=inputs-outputs -->
## Encoded fields and where the value goes

- `SrcL` and `SrcR` are `5`-bit Reg5 sources. Codes `0`..`23` name absolute GPRs, `24`..`27` name `T#1`..`T#4`, and `28`..`31` name `U#1`..`U#4`. Reading a `T` or `U` slot neither consumes nor reorders it, and code `0` supplies the constant zero GPR.
- `SrcRType` is assigned for `0`, `1`, and `2`; raw `3` is reserved. `shamt` is assigned for all `32` values `0`..`31`, and encoded zero leaves the transformed offset unscaled.
- `RegDst` is a `5`-bit destination: codes `1`..`23` write absolute GPRs, code `30` pushes the `U` queue, code `31` pushes the `T` queue, and codes `0` and `24`..`29` discard the loaded value.

Design point: `shamt` occupies the same five encoding bits that `SB`, `SW`, and `SD` use for their `SrcD` store-data field. `LW` can scale an index by any power of two from `1` to `2^31`; a register-offset store must use the fixed scale of its mnemonic.

<!-- PTO-READER-BLOCK: scalar-lw-effects role=effects -->
## Effects, ordering, and completion

Both sources are read before any memory or destination effect, so a destination that aliases the base still uses the pre-instruction value: `lw [1, 2<<<1], ->1` uses the old `1` as its base.

Successful execution performs one relaxed `4`-byte load and records one load event. No memory byte changes and reservation state is preserved. `TPC` then advances by `4` bytes, the length of this encoding.

Design point: codes `30` and `31` publish by pushing a queue entry through the same gated write as a GPR destination. A faulting `LW` therefore pushes nothing and leaves the queue contents and validity flags untouched.

<!-- PTO-READER-BLOCK: scalar-lw-constraints role=constraints -->
## Legality, faults, and restart

Dispatch rejects the instruction with `Fault_IllegalInstruction` before any effect when the fixed encoding bits do not match, when `SrcRType` holds the reserved value `3`, or when a selected `T`/`U` source slot is unavailable because nothing has been pushed into it.

The preflight tests the low `2` bits of the effective address, and a nonzero value raises `Fault_DataAlignment` before translation and before the permission test. An aligned address that fails a permission or bounded-memory test raises `Fault_DataPage` at the original address; PTO v0 translation is the identity function, so there is no separate translation fault.

A fault records no load event, writes no destination, and leaves `TPC` on the faulting instruction. Recovery reissues the whole operation: every source read, the address arithmetic, the preflight, the load, and the publication.

Design point: the alignment test precedes the permission test, so an address that is both misaligned and out of region reports `Fault_DataAlignment`; only an aligned address reaches `Fault_DataPage`.

<!-- PTO-READER-BLOCK: scalar-lw-example role=example -->
## Reading one encoding end to end

This example demonstrates the address calculation only; exact behavior remains in the current ASL and instruction contract.

- Take `lw [2, 3<.sw><<<3], ->4` with GPR2 = `0x2000` and GPR3 = `0xFFFFFFFE`.
- `SrcRType=1` sign-extends the low `32` bits, so the offset source contributes `0xFFFFFFFFFFFFFFFE`, which is `-2`.
- `shamt=3` shifts that value left by `3`, giving `-16`; the effective address is `0x2000` minus `16`, which is `0x1FF0`.
- `0x1FF0` is `4`-byte aligned, so the preflight passes. The instruction reads the `4` bytes at `0x1FF0` through `0x1FF3`, sign-extends them into GPR4, and advances `TPC` by `4` bytes.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
lw [SrcL, SrcR<{.sw,.uw}><<<shamt>], ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| lw_32_3a77ffafcb34 | L32 | 32 | 0x00002009 / 0x0000707f | [{"field":"SrcRType","operator":"one-of","values":[0,1,2]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| lw_32_3a77ffafcb34 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| lw_32_3a77ffafcb34 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| lw_32_3a77ffafcb34 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| lw_32_3a77ffafcb34 | SrcRType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |
| lw_32_3a77ffafcb34 | shamt | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| lw_32_3a77ffafcb34 | RegDst | 5 | 0–31 | none | none | Reg5 loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| lw_32_3a77ffafcb34 | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| lw_32_3a77ffafcb34 | SrcR | 5 | 0–31 | none | none | Reg5 register-offset source | Encoded zero reads the architectural zero GPR. |
| lw_32_3a77ffafcb34 | SrcRType | 2 | 0–2 | none | 3 | register-offset transformation selector | Encoded zero leaves the complete PTO_XLEN register-offset value unchanged. |
| lw_32_3a77ffafcb34 | shamt | 5 | 0–31 | none | none | post-transformation logical-left-shift amount | Encoded zero performs no shift. |

- `lw_32_3a77ffafcb34.SrcRType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 loaded-value destination or discard |
| SrcL | Reg5 address-base source |
| SrcR | Reg5 register-offset source |
| SrcRType | register-offset transformation selector |
| shamt | post-transformation logical-left-shift amount |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/LW.asl -->
```asl
readonly func InstructionContractOperation_LW() => ScalarOperation
begin
    return ScalarOperation_LW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/LW.asl -->
```asl
readonly func InstructionContractHandler_LW()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;

pure func InstructionContractAGUAction_LW()
    => ScalarAGUAction
begin
    return ScalarAGU_Load;
end;

pure func InstructionContractAGUAddressKind_LW()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Register;
end;

pure func InstructionContractAGUSizeBytes_LW()
    => integer {1,2,4,8}
begin
    return 4;
end;

pure func InstructionContractAGUOffsetScale_LW()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_LW()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_LW()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_LW()
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
- Every Reg5 destination is assigned: codes 1..23 write GPRs, code 30 pushes U, code 31 pushes T, and codes 0 and 24..29 discard only that result.
- SrcRType values 0, 1, and 2 and all shamt values 0..31 are assigned; SrcRType=3 is reserved; apply the modifier before the shift.
- Each memory address must be aligned to the 4-byte access size; a 4-byte access is the complete transfer unit.

## State effects

- Form offset = LSL(Modify(SrcR, SrcRType), the encoded shamt) and add it modulo 2^PTO_XLEN to the SrcL base.
- After a successful 4-byte load, sign-extend the loaded value to PTO_XLEN and publish it through the destination.
- Successful execution advances TPC by 4 bytes; a rejected or faulting attempt does not retire.

## Memory effects and ordering

### Memory effects

- After complete preflight, perform one little-endian 4-byte load and record one relaxed load event.
- The load preserves memory and reservation state.

### Ordering

- Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.
- Complete the relaxed 4-byte memory operation, publish any result or writeback, and then advance TPC.

## Exceptions

- A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.
- A misaligned 4-byte address raises Fault_DataAlignment before translation or permission. A later permission or bounded-memory failure raises Fault_DataPage at the original address.
- A fault emits no successful memory event, performs no partial memory or destination effect, preserves pending writeback, and leaves TPC at the faulting instruction.
- Recovery performs a full reissue: every address, source snapshot, preflight, memory operation, and destination is recomputed with no retained progress.

## Examples

- lw [SrcL, SrcR<{.sw,.uw}><<<shamt>], ->{t, u, Rd}

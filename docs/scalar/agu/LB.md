<!-- GENERATED FROM: asl/scalar/agu/LB.asl -->
# LB

**Normative ASL source:** `asl/scalar/agu/LB.asl`

LB snapshots its scalar sources, forms its encoded address, and loads one aligned little-endian 1-byte value.

## Normative identity {#PTO-INST-SCALAR-LB}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-lb-purpose role=purpose -->
## What `LB` does

`LB` is a standalone `32`-bit scalar AGU instruction. It reads a base from `SrcL`, transforms the `SrcR` index according to `SrcRType`, shifts that index left by the encoded `shamt`, and loads one little-endian `1`-byte unit into `RegDst`.

The canonical assembly is `lb [SrcL, SrcR<{.sw,.uw}><<<shamt>], ->{t, u, Rd}`.

Design point: the index scale is programmed, not implied by the access size: `shamt` is a full `5`-bit field, so `shamt` `3` counts `8`-byte units even though the transfer is one byte.

<!-- PTO-READER-BLOCK: scalar-lb-mechanism role=mechanism -->
## How the address and the transfer are formed

The offset is `LSL(Modify(SrcR, SrcRType), shamt)`. `SrcRType` `0` leaves the whole `64`-bit index unchanged, `1` replaces it with the sign-extension of its low `32` bits, and `2` replaces it with a zero-extension of those bits. The offset is added to the `SrcL` snapshot modulo `2^PTO_XLEN`, so the sum wraps at `64` bits instead of trapping.

Preflight runs in three stages on the effective address: the `1`-byte alignment test, then address translation, then the permission and bounded-memory check. Only after the whole address passes does the instruction read `1` byte little-endian and record one relaxed load event.

The byte is sign-extended to `PTO_XLEN` and published to the `RegDst` encoding. No register receives an updated base: this form has no write-back, and the computed address is used only by this load.

Design point: the modifier replaces the whole index register before the shift, so a `32`-bit negative index stays negative under `.sw` while `.uw` turns it into a large positive offset that only the `64`-bit wrap reduces.

<!-- PTO-READER-BLOCK: scalar-lb-inputs role=inputs-outputs -->
## Encoded fields and roles

- `SrcL` is the base selector. Codes `0`..`23` select absolute GPRs, `24`..`27` select `T#1`..`T#4`, and `28`..`31` select `U#1`..`U#4`; queue entries are read without being consumed.
- `SrcR` is the index selector. Codes `0`..`23` select absolute GPRs, `24`..`27` select `T#1`..`T#4`, and `28`..`31` select `U#1`..`U#4`; queue entries are read without being consumed.
- `SrcRType` is a `2`-bit selector: `0` leaves `SrcR` unchanged, `1` selects `.sw`, `2` selects `.uw`, and `3` is reserved. `shamt` is a `5`-bit field covering `0`..`31`.
- `RegDst` is the destination selector. Codes `1`..`23` write GPRs, `30` pushes the `U` queue, `31` pushes the `T` queue, and `0` plus `24`..`29` publish nothing; code `0` is the architectural zero GPR, whose writes are discarded.
- Design point: the base and the index are read before the memory access, so an encoding whose index and destination name the same register still loads from the pre-instruction index value.

<!-- PTO-READER-BLOCK: scalar-lb-effects role=effects -->
## Effects, ordering, and completion

Every scalar source is snapshotted before the memory operation and before any destination publication. The published byte is the sign-extended `0`..`255` value of the loaded byte, or nothing at all when `RegDst` is a discarding code.

A successful load records exactly one relaxed load event, leaves memory unchanged, and leaves reservation state unchanged. `TPC` then advances by `4` bytes.

Design point: a load cannot invalidate a reservation, because no load path writes reservation state. A store clears the reservation only when its stored range overlaps the reservation granule, and an explicit data or instruction fence clears it as well. Even a load of the reserved address itself leaves the reservation valid.

<!-- PTO-READER-BLOCK: scalar-lb-constraints role=constraints -->
## Legality, faults, and restart

- A fixed-bit mismatch, a `SrcRType` of `3`, or a source selector naming an unpushed `T` or `U` queue entry raises `Fault_IllegalInstruction` at the instruction address before any source value is read.
- The alignment test is `1` byte wide, so an aligned address is required before translation or permission is consulted; a later permission or bounded-memory failure raises `Fault_DataPage` at the original effective address.
- A fault records no load event, publishes no destination value, and leaves `TPC` on the faulting instruction. Recovery re-reads the sources and recomputes the address from the beginning.
- Design point: the alignment stage compares the address against `1` byte, and every integer address is a multiple of `1`. `Fault_DataAlignment` is therefore unreachable for `LB`; the only data-side rejection left is `Fault_DataPage`.

<!-- PTO-READER-BLOCK: scalar-lb-example role=example -->
## Reading one encoding end to end

This example demonstrates the address calculation only; exact behavior remains in the current ASL and instruction contract.

- With `SrcL` holding `0x100`, `SrcR` holding `2`, `shamt` `1`, and `SrcRType` `0`, the offset is `4` and the effective address is `0x104`.
- If the byte at `0x104` is `0x80`, `RegDst` receives `0xFFFFFFFFFFFFFF80`, because the loaded byte is sign-extended.
- Changing only `shamt` to `0` moves the same access to `0x102`, because the address follows the encoded shift.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
lb [SrcL, SrcR<{.sw,.uw}><<<shamt>], ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| lb_32_b718aa88e28f | L32 | 32 | 0x00000009 / 0x0000707f | [{"field":"SrcRType","operator":"one-of","values":[0,1,2]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| lb_32_b718aa88e28f | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| lb_32_b718aa88e28f | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| lb_32_b718aa88e28f | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| lb_32_b718aa88e28f | SrcRType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |
| lb_32_b718aa88e28f | shamt | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| lb_32_b718aa88e28f | RegDst | 5 | 0–31 | none | none | Reg5 loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| lb_32_b718aa88e28f | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| lb_32_b718aa88e28f | SrcR | 5 | 0–31 | none | none | Reg5 register-offset source | Encoded zero reads the architectural zero GPR. |
| lb_32_b718aa88e28f | SrcRType | 2 | 0–2 | none | 3 | register-offset transformation selector | Encoded zero leaves the complete PTO_XLEN register-offset value unchanged. |
| lb_32_b718aa88e28f | shamt | 5 | 0–31 | none | none | post-transformation logical-left-shift amount | Encoded zero performs no shift. |

- `lb_32_b718aa88e28f.SrcRType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 loaded-value destination or discard |
| SrcL | Reg5 address-base source |
| SrcR | Reg5 register-offset source |
| SrcRType | register-offset transformation selector |
| shamt | post-transformation logical-left-shift amount |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/LB.asl -->
```asl
readonly func InstructionContractOperation_LB() => ScalarOperation
begin
    return ScalarOperation_LB;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/LB.asl -->
```asl
readonly func InstructionContractHandler_LB()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;

pure func InstructionContractAGUAction_LB()
    => ScalarAGUAction
begin
    return ScalarAGU_Load;
end;

pure func InstructionContractAGUAddressKind_LB()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Register;
end;

pure func InstructionContractAGUSizeBytes_LB()
    => integer {1,2,4,8}
begin
    return 1;
end;

pure func InstructionContractAGUOffsetScale_LB()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_LB()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_LB()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_LB()
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
- Each memory address must be aligned to the 1-byte access size; a 1-byte access is the complete transfer unit.

## State effects

- Form offset = LSL(Modify(SrcR, SrcRType), the encoded shamt) and add it modulo 2^PTO_XLEN to the SrcL base.
- After a successful 1-byte load, sign-extend the loaded value to PTO_XLEN and publish it through the destination.
- Successful execution advances TPC by 4 bytes; a rejected or faulting attempt does not retire.

## Memory effects and ordering

### Memory effects

- After complete preflight, perform one little-endian 1-byte load and record one relaxed load event.
- The load preserves memory and reservation state.

### Ordering

- Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.
- Complete the relaxed 1-byte memory operation, publish any result or writeback, and then advance TPC.

## Exceptions

- A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.
- A misaligned 1-byte address raises Fault_DataAlignment before translation or permission. A later permission or bounded-memory failure raises Fault_DataPage at the original address.
- A fault emits no successful memory event, performs no partial memory or destination effect, preserves pending writeback, and leaves TPC at the faulting instruction.
- Recovery performs a full reissue: every address, source snapshot, preflight, memory operation, and destination is recomputed with no retained progress.

## Examples

- lb [SrcL, SrcR<{.sw,.uw}><<<shamt>], ->{t, u, Rd}

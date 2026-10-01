<!-- GENERATED FROM: asl/scalar/agu/LWI.asl -->
# LWI

**Normative ASL source:** `asl/scalar/agu/LWI.asl`

LWI snapshots its scalar sources, forms its encoded address, and loads one aligned little-endian 4-byte value.

## Normative identity {#PTO-INST-SCALAR-LWI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-lwi-purpose role=purpose -->
## What `LWI` does

`LWI` loads one `4`-byte little-endian word from `SrcL` plus a signed immediate scaled by `4`, then sign-extends the loaded `32` bits to `PTO_XLEN`. Its canonical assembly is `lwi [SrcL, simm], ->{t, u, Rd}`.

Design point: the `simm12` field counts `4`-byte units, so the encodable displacements are `-2048` through `2047` units, which is `-8192` through `8188` bytes. The scale equals the access size, and that is what keeps an aligned base aligned.

<!-- PTO-READER-BLOCK: scalar-lwi-mechanism role=mechanism -->
## How `LWI` forms the address and completes the access

`simm12` is sign-extended from `12` bits to `PTO_XLEN` and then shifted left by `2`, which multiplies it by `4`. The scaled displacement is added to the `SrcL` base modulo `2^PTO_XLEN`.

The sum is used by one little-endian `4`-byte load. There is no base writeback and no second destination. Bits `31`:`0` of the loaded word are sign-extended and written through `RegDst` only if the load reported no fault.

Design point: the shift is applied after the sign extension, so the negative end of the range stays negative. Encoding `-1` produces the displacement `-4`, while an unsigned reading of the same `12` bits would add `16380`.

<!-- PTO-READER-BLOCK: scalar-lwi-inputs role=inputs-outputs -->
## Encoded fields and where the value goes

- `SrcL` is a `5`-bit Reg5 source. Codes `0`..`23` name absolute GPRs, `24`..`27` name `T#1`..`T#4`, and `28`..`31` name `U#1`..`U#4`. Reading a `T` or `U` slot neither consumes nor reorders it, and code `0` supplies the constant zero GPR.
- `simm12` is a signed `12`-bit field, so all `4096` encodings are values, and encoded zero supplies a zero displacement rather than denoting omission.
- `RegDst` is a `5`-bit destination: codes `1`..`23` write absolute GPRs, code `30` pushes the `U` queue, code `31` pushes the `T` queue, and codes `0` and `24`..`29` discard the loaded value.

Design point: the multiplier `4` is fixed by the encoding, and there is no shift field to override it. A byte displacement that is not a multiple of `4` cannot be expressed by this form at all, which is exactly why `LWI.U` exists.

<!-- PTO-READER-BLOCK: scalar-lwi-effects role=effects -->
## Effects, ordering, and completion

`SrcL` is read before any memory or destination effect, so a destination that names the base still uses the pre-instruction value: `lwi [1, 2], ->1` loads from the old `1` plus `8` and only then overwrites `1`.

Successful execution performs one relaxed `4`-byte load and records one load event. No memory byte changes and reservation state is preserved. `TPC` then advances by `4` bytes.

Design point: the load event and the destination write are the only effects, so nothing about the base register, memory contents, or ordering state persists after the instruction retires.

<!-- PTO-READER-BLOCK: scalar-lwi-constraints role=constraints -->
## Legality, faults, and restart

Dispatch rejects the instruction with `Fault_IllegalInstruction` before any effect when the fixed encoding bits do not match, or when a selected `T`/`U` source slot is unavailable because nothing has been pushed into it.

The preflight tests the low `2` bits of the effective address, and a nonzero value raises `Fault_DataAlignment` before translation and before the permission test. An aligned address that fails a permission or bounded-memory test raises `Fault_DataPage` at the original address; PTO v0 translation is the identity function, so there is no separate translation fault.

A fault records no load event, writes no destination, and leaves `TPC` on the faulting instruction. Recovery reissues the whole operation: every source read, the address arithmetic, the preflight, the load, and the publication.

Design point: every displacement this form can produce is a multiple of `4`, so alignment can fail only when `SrcL` itself is not `4`-byte aligned. The alignment outcome is therefore a property of the program's data layout rather than of the encoded immediate.

<!-- PTO-READER-BLOCK: scalar-lwi-example role=example -->
## Reading one encoding end to end

This example demonstrates the address calculation only; exact behavior remains in the current ASL and instruction contract.

- Take `lwi [3, -1], ->5` with GPR3 = `0x1000`.
- `simm12=-1` sign-extends to `-1` and is then multiplied by `4`, so the displacement is `-4`.
- The effective address is `0x1000` minus `4`, which is `0x0FFC`.
- `0x0FFC` is `4`-byte aligned, so the preflight passes; the `4` bytes at `0x0FFC` through `0x0FFF` are sign-extended into GPR5 and `TPC` advances by `4` bytes.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
lwi [SrcL, simm], ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| lwi_32_7085c98058fa | L32 | 32 | 0x00002019 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| lwi_32_7085c98058fa | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| lwi_32_7085c98058fa | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| lwi_32_7085c98058fa | simm12 | 12 | signed | [{"instruction_lsb":20,"value_lsb":0,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| lwi_32_7085c98058fa | RegDst | 5 | 0–31 | none | none | Reg5 loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| lwi_32_7085c98058fa | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| lwi_32_7085c98058fa | simm12 | 12 | 0–4095 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 loaded-value destination or discard |
| SrcL | Reg5 address-base source |
| simm12 | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/LWI.asl -->
```asl
readonly func InstructionContractOperation_LWI() => ScalarOperation
begin
    return ScalarOperation_LWI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/LWI.asl -->
```asl
readonly func InstructionContractHandler_LWI()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;

pure func InstructionContractAGUAction_LWI()
    => ScalarAGUAction
begin
    return ScalarAGU_Load;
end;

pure func InstructionContractAGUAddressKind_LWI()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Immediate;
end;

pure func InstructionContractAGUSizeBytes_LWI()
    => integer {1,2,4,8}
begin
    return 4;
end;

pure func InstructionContractAGUOffsetScale_LWI()
    => integer {0..3}
begin
    return 2;
end;

pure func InstructionContractAGUUpdateMode_LWI()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_LWI()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_LWI()
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
- simm12 assigns every signed 12-bit value -2048..2047; the encoded byte displacement is that value multiplied by 4.
- Each memory address must be aligned to the 4-byte access size; a 4-byte access is the complete transfer unit.

## State effects

- Sign-extend simm12, multiply it by 4, and add it modulo 2^PTO_XLEN to the SrcL base.
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

- lwi [SrcL, simm], ->{t, u, Rd}

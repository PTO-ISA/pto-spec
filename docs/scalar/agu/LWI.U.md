<!-- GENERATED FROM: asl/scalar/agu/LWI.U.asl -->
# LWI.U

**Normative ASL source:** `asl/scalar/agu/LWI.U.asl`

LWI.U snapshots its scalar sources, forms its encoded address, and loads one aligned little-endian 4-byte value.

## Normative identity {#PTO-INST-SCALAR-LWI-U}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-lwi-u-purpose role=purpose -->
## What `LWI.U` does

`LWI.U` loads one `4`-byte little-endian word from `SrcL` plus a signed immediate that is added without any scaling, then sign-extends the loaded `32` bits to `PTO_XLEN`. Its canonical assembly is `lwi.u [SrcL, simm], ->{t, u, Rd}`.

Design point: `LWI.U` and `LWI` read the same `simm12` field and differ only in its scale. `lwi.u` with an encoded `2` addresses the base plus `2`, while `lwi` with the same encoding addresses the base plus `8`, so byte offsets that are not multiples of `4` are expressible only in the `.u` form.

<!-- PTO-READER-BLOCK: scalar-lwi-u-mechanism role=mechanism -->
## How `LWI.U` forms the address and completes the access

`simm12` is sign-extended from its `12` bits to `PTO_XLEN`, so the displacement covers `-2048` through `2047` bytes, and added to the `SrcL` base modulo `2^PTO_XLEN`. No shift is applied to the intermediate value.

The sum is used by one little-endian `4`-byte load. There is no base writeback and no second destination. Bits `31`:`0` of the loaded word are sign-extended and written through `RegDst` only if the load reported no fault.

Design point: sign extension happens before the addition, so the displacement is a signed `PTO_XLEN` value rather than a `12`-bit field that wraps. Encoding `-1` addresses one byte below the base, not `4095` bytes above it.

<!-- PTO-READER-BLOCK: scalar-lwi-u-inputs role=inputs-outputs -->
## Encoded fields and where the value goes

- `SrcL` is a `5`-bit Reg5 source. Codes `0`..`23` name absolute GPRs, `24`..`27` name `T#1`..`T#4`, and `28`..`31` name `U#1`..`U#4`. Reading a `T` or `U` slot neither consumes nor reorders it, and code `0` supplies the constant zero GPR.
- `simm12` is a signed `12`-bit field, so all `4096` encodings are values. Encoded zero supplies a zero displacement rather than denoting omission.
- `RegDst` is a `5`-bit destination: codes `1`..`23` write absolute GPRs, code `30` pushes the `U` queue, code `31` pushes the `T` queue, and codes `0` and `24`..`29` discard the loaded value.

Design point: the form has one address register and no shift field. The whole address is therefore `SrcL` plus a value the program encodes directly, and the scale of `1` is a property of the mnemonic that no operand can change.

<!-- PTO-READER-BLOCK: scalar-lwi-u-effects role=effects -->
## Effects, ordering, and completion

`SrcL` is read before any memory or destination effect, so a destination that names the base still uses the pre-instruction value: `lwi.u [1, 4], ->1` loads from the old `1` plus `4` and only then overwrites `1`.

Successful execution performs one relaxed `4`-byte load and records one load event. No memory byte changes and reservation state is preserved. `TPC` then advances by `4` bytes.

Design point: the destination write and the `TPC` advance are both skipped when the load faults, so a failed attempt retires nothing and leaves no half-completed state behind.

<!-- PTO-READER-BLOCK: scalar-lwi-u-constraints role=constraints -->
## Legality, faults, and restart

Dispatch rejects the instruction with `Fault_IllegalInstruction` before any effect when the fixed encoding bits do not match, or when a selected `T`/`U` source slot is unavailable because nothing has been pushed into it.

The preflight tests the low `2` bits of the effective address, and a nonzero value raises `Fault_DataAlignment` before translation and before the permission test. An aligned address that fails a permission or bounded-memory test raises `Fault_DataPage` at the original address; PTO v0 translation is the identity function, so there is no separate translation fault.

A fault records no load event, writes no destination, and leaves `TPC` on the faulting instruction. Recovery reissues the whole operation: every source read, the address arithmetic, the preflight, the load, and the publication.

Design point: because the displacement is unscaled, `Fault_DataAlignment` is reachable even when `SrcL` itself is `4`-byte aligned. A program that needs every displacement from an aligned base to stay aligned must use `LWI`, whose scale of `4` keeps the address inside the base's aligned group.

<!-- PTO-READER-BLOCK: scalar-lwi-u-example role=example -->
## Reading one encoding end to end

This example demonstrates the address calculation only; exact behavior remains in the current ASL and instruction contract.

- Take `lwi.u [3, 2], ->5` with GPR3 = `0x1000`.
- `simm12=2` is positive, so the displacement is `2` bytes and the effective address is `0x1002`.
- `0x1002` is not `4`-byte aligned, so the preflight raises `Fault_DataAlignment`: no load happens, GPR5 keeps its value, and `TPC` stays at the faulting instruction.
- With `simm12=4` instead, the address is `0x1004`, the `4` bytes at `0x1004` through `0x1007` are sign-extended into GPR5, and `TPC` advances by `4` bytes.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
lwi.u [SrcL, simm], ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| lwi_u_32_4a7426a70f10 | L32 | 32 | 0x00002029 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| lwi_u_32_4a7426a70f10 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| lwi_u_32_4a7426a70f10 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| lwi_u_32_4a7426a70f10 | simm12 | 12 | signed | [{"instruction_lsb":20,"value_lsb":0,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| lwi_u_32_4a7426a70f10 | RegDst | 5 | 0–31 | none | none | Reg5 loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| lwi_u_32_4a7426a70f10 | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| lwi_u_32_4a7426a70f10 | simm12 | 12 | 0–4095 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 loaded-value destination or discard |
| SrcL | Reg5 address-base source |
| simm12 | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/LWI.U.asl -->
```asl
readonly func InstructionContractOperation_LWI_U() => ScalarOperation
begin
    return ScalarOperation_LWI_U;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/LWI.U.asl -->
```asl
readonly func InstructionContractHandler_LWI_U()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;

pure func InstructionContractAGUAction_LWI_U()
    => ScalarAGUAction
begin
    return ScalarAGU_Load;
end;

pure func InstructionContractAGUAddressKind_LWI_U()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Immediate;
end;

pure func InstructionContractAGUSizeBytes_LWI_U()
    => integer {1,2,4,8}
begin
    return 4;
end;

pure func InstructionContractAGUOffsetScale_LWI_U()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_LWI_U()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_LWI_U()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_LWI_U()
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
- simm12 assigns every signed 12-bit value -2048..2047; the encoded byte displacement is that value multiplied by 1.
- Each memory address must be aligned to the 4-byte access size; a 4-byte access is the complete transfer unit.

## State effects

- Sign-extend simm12, multiply it by 1, and add it modulo 2^PTO_XLEN to the SrcL base.
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

- lwi.u [SrcL, simm], ->{t, u, Rd}

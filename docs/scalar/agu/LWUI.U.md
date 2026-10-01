<!-- GENERATED FROM: asl/scalar/agu/LWUI.U.asl -->
# LWUI.U

**Normative ASL source:** `asl/scalar/agu/LWUI.U.asl`

LWUI.U snapshots its scalar sources, forms its encoded address, and loads one aligned little-endian 4-byte value.

## Normative identity {#PTO-INST-SCALAR-LWUI-U}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-lwui-u-purpose role=purpose -->
## What `LWUI.U` does

`LWUI.U` loads one `4`-byte little-endian word from `SrcL` plus a signed immediate that is added without scaling, then zero-extends the loaded `32` bits to `PTO_XLEN`. Its canonical assembly is `lwui.u [SrcL, simm], ->{t, u, Rd}`.

Design point: the mnemonic carries both markers of the family. `LWU` decides how the loaded `4` bytes become a `64`-bit value, and `.u` decides that the immediate counts bytes. `LWUI` uses the same field already multiplied by `4`, so the two forms are not interchangeable for one encoding.

<!-- PTO-READER-BLOCK: scalar-lwui-u-mechanism role=mechanism -->
## How `LWUI.U` forms the address and completes the access

`simm12` is sign-extended from `12` bits to `PTO_XLEN`, giving a displacement in `-2048`..`2047` bytes, and added to the `SrcL` base modulo `2^PTO_XLEN`. No scaling step is applied.

The sum is used by one little-endian `4`-byte load. There is no base writeback and no second destination. Bits `31`:`0` of the loaded word are zero-extended and written through `RegDst` only if the load reported no fault.

Design point: an unscaled displacement can name any byte, so the `4`-byte alignment rule is a real constraint here and three of every four displacements from an aligned base are refused with `Fault_DataAlignment`. The scaled `LWUI` cannot produce such an address.

<!-- PTO-READER-BLOCK: scalar-lwui-u-inputs role=inputs-outputs -->
## Encoded fields and where the value goes

- `SrcL` is a `5`-bit Reg5 source. Codes `0`..`23` name absolute GPRs, `24`..`27` name `T#1`..`T#4`, and `28`..`31` name `U#1`..`U#4`. Reading a `T` or `U` slot neither consumes nor reorders it, and code `0` supplies the constant zero GPR.
- `simm12` is a signed `12`-bit field, so all `4096` encodings are values, and encoded zero supplies a zero displacement rather than denoting omission.
- `RegDst` is a `5`-bit destination: codes `1`..`23` write absolute GPRs, code `30` pushes the `U` queue, code `31` pushes the `T` queue, and codes `0` and `24`..`29` discard the loaded value.

Design point: because the loaded word is zero-extended, `RegDst` never receives a value with bits `63`:`32` set. The bytes `FF FF FF FF` publish `0x00000000FFFFFFFF`, which is `4294967295`, even though the same location read as a signed `32`-bit value would be `-1`.

<!-- PTO-READER-BLOCK: scalar-lwui-u-effects role=effects -->
## Effects, ordering, and completion

`SrcL` is read before any memory or destination effect, so an aliasing destination still sees the pre-instruction base.

Successful execution performs one relaxed `4`-byte load and records one load event. No memory byte changes and reservation state is preserved. `TPC` then advances by `4` bytes.

Design point: publication is a separate step from the access. A destination of code `0` therefore still performs the preflight and the load, which makes `lwui.u` usable as an accessibility test whose result is deliberately dropped.

<!-- PTO-READER-BLOCK: scalar-lwui-u-constraints role=constraints -->
## Legality, faults, and restart

Dispatch rejects the instruction with `Fault_IllegalInstruction` before any effect when the fixed encoding bits do not match, or when a selected `T`/`U` source slot is unavailable because nothing has been pushed into it.

The preflight tests the low `2` bits of the effective address, and a nonzero value raises `Fault_DataAlignment` before translation and before the permission test. An aligned address that fails a permission or bounded-memory test raises `Fault_DataPage` at the original address; PTO v0 translation is the identity function, so there is no separate translation fault.

A fault records no load event, writes no destination, and leaves `TPC` on the faulting instruction. Recovery reissues the whole operation: every source read, the address arithmetic, the preflight, the load, and the publication.

Design point: the fault is recorded at the original address, before any translation step, so a handler that reports the faulting address can compare it directly with the value the instruction computed from `SrcL` and `simm12`.

<!-- PTO-READER-BLOCK: scalar-lwui-u-example role=example -->
## Reading one encoding end to end

This example demonstrates the address calculation only; exact behavior remains in the current ASL and instruction contract.

- Take `lwui.u [3, -2], ->5` with GPR3 = `0x1000`.
- `simm12=-2` sign-extends to `-2` and the displacement is used as encoded, so the effective address is `0x0FFE`.
- `0x0FFE` is not `4`-byte aligned, so the preflight raises `Fault_DataAlignment` before the load and before the permission test.
- With `lwui` instead, the same `simm12=-2` is multiplied by `4`, the address becomes `0x0FF8`, the preflight passes, and the `4` bytes at `0x0FF8` through `0x0FFB` are zero-extended into GPR5.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
lwui.u [SrcL, simm], ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| lwui_u_32_1fcbb98df571 | L32 | 32 | 0x00006029 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| lwui_u_32_1fcbb98df571 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| lwui_u_32_1fcbb98df571 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| lwui_u_32_1fcbb98df571 | simm12 | 12 | signed | [{"instruction_lsb":20,"value_lsb":0,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| lwui_u_32_1fcbb98df571 | RegDst | 5 | 0–31 | none | none | Reg5 loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| lwui_u_32_1fcbb98df571 | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| lwui_u_32_1fcbb98df571 | simm12 | 12 | 0–4095 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 loaded-value destination or discard |
| SrcL | Reg5 address-base source |
| simm12 | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/LWUI.U.asl -->
```asl
readonly func InstructionContractOperation_LWUI_U() => ScalarOperation
begin
    return ScalarOperation_LWUI_U;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/LWUI.U.asl -->
```asl
readonly func InstructionContractHandler_LWUI_U()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;

pure func InstructionContractAGUAction_LWUI_U()
    => ScalarAGUAction
begin
    return ScalarAGU_Load;
end;

pure func InstructionContractAGUAddressKind_LWUI_U()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Immediate;
end;

pure func InstructionContractAGUSizeBytes_LWUI_U()
    => integer {1,2,4,8}
begin
    return 4;
end;

pure func InstructionContractAGUOffsetScale_LWUI_U()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_LWUI_U()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_LWUI_U()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_LWUI_U()
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
- After a successful 4-byte load, zero-extend the loaded value to PTO_XLEN and publish it through the destination.
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

- lwui.u [SrcL, simm], ->{t, u, Rd}

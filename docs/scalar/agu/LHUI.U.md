<!-- GENERATED FROM: asl/scalar/agu/LHUI.U.asl -->
# LHUI.U

**Normative ASL source:** `asl/scalar/agu/LHUI.U.asl`

LHUI.U snapshots its scalar sources, forms its encoded address, and loads one aligned little-endian 2-byte value.

## Normative identity {#PTO-INST-SCALAR-LHUI-U}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-lhui-u-purpose role=purpose -->
## What `LHUI.U` does

`LHUI.U` loads one unsigned `2`-byte halfword at an unscaled immediate distance from a base register. Each encoded unit is one byte of address and the result is zero-extended.

The canonical assembly is `lhui.u [SrcL, simm], ->{t, u, Rd}`.

Design point: the `.u` form is the byte-granular version of `LHUI`: the same `12`-bit field now means `-2048`..`2047` bytes instead of `-4096`..`4094`.

<!-- PTO-READER-BLOCK: scalar-lhui-u-mechanism role=mechanism -->
## How the address and the transfer are formed

The sign-extended `simm12` is added, without a shift, to the `SrcL` snapshot modulo `2^PTO_XLEN`.

Preflight tests `2`-byte alignment, then translation, then permission and bounded memory. On success `2` bytes are read little-endian, one relaxed load event is recorded, and the zero-extended halfword is published.

The base register is read but never written; only `RegDst` changes.

Design point: unscaled displacements can be odd, so this form can reach a halfword at an odd byte offset from an odd base. The sum, not the base alone, decides alignment.

<!-- PTO-READER-BLOCK: scalar-lhui-u-inputs role=inputs-outputs -->
## Encoded fields and roles

- `SrcL` is the base selector. Codes `0`..`23` select absolute GPRs, `24`..`27` select `T#1`..`T#4`, and `28`..`31` select `U#1`..`U#4`; queue entries are read without being consumed.
- `simm12` is signed, covers `-2048`..`2047`, and is used unscaled.
- `RegDst` is the destination selector. Codes `1`..`23` write GPRs, `30` pushes the `U` queue, `31` pushes the `T` queue, and `0` plus `24`..`29` publish nothing; code `0` is the architectural zero GPR, whose writes are discarded.
- Design point: the base is the only register read; every Reg5 source code is accepted and a queue entry used as the base is read without being consumed.

<!-- PTO-READER-BLOCK: scalar-lhui-u-effects role=effects -->
## Effects, ordering, and completion

The base snapshot is taken before the memory operation, so a later write to the same register cannot change this access.

Success records one relaxed load event, changes no memory byte, preserves the reservation, publishes the zero-extended halfword, and advances `TPC` by `4` bytes.

Design point: the result is exactly `0`..`65535`, because the zero-extension clears every bit above `15`.

<!-- PTO-READER-BLOCK: scalar-lhui-u-constraints role=constraints -->
## Legality, faults, and restart

- A fixed-bit mismatch, or a `SrcL` selector naming an unavailable `T`/`U` entry, raises `Fault_IllegalInstruction` before the address is formed.
- An odd sum raises `Fault_DataAlignment` before translation; a later permission or bounded-memory failure raises `Fault_DataPage` at the original effective address.
- A fault records no event, publishes nothing to `RegDst`, and leaves `TPC` on the faulting instruction so the attempt can be reissued.
- Design point: an odd displacement combined with an odd base is still legal, while an odd sum is not; the difference is reported as `Fault_DataAlignment` before translation.

<!-- PTO-READER-BLOCK: scalar-lhui-u-example role=example -->
## Reading one encoding end to end

This example demonstrates the address calculation only; exact behavior remains in the current ASL and instruction contract.

- With `SrcL` = `0x1001` and `simm12` = `1`, the address is `0x1002` and the access is legal.
- With the same base and `simm12` = `0`, the address is `0x1001` and `Fault_DataAlignment` is raised.
- The halfword read on the legal attempt is zero-extended, so it enters `RegDst` in `0`..`65535`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
lhui.u [SrcL, simm], ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| lhui_u_32_748b15cd2ced | L32 | 32 | 0x00005029 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| lhui_u_32_748b15cd2ced | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| lhui_u_32_748b15cd2ced | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| lhui_u_32_748b15cd2ced | simm12 | 12 | signed | [{"instruction_lsb":20,"value_lsb":0,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| lhui_u_32_748b15cd2ced | RegDst | 5 | 0–31 | none | none | Reg5 loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| lhui_u_32_748b15cd2ced | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| lhui_u_32_748b15cd2ced | simm12 | 12 | 0–4095 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 loaded-value destination or discard |
| SrcL | Reg5 address-base source |
| simm12 | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/LHUI.U.asl -->
```asl
readonly func InstructionContractOperation_LHUI_U() => ScalarOperation
begin
    return ScalarOperation_LHUI_U;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/LHUI.U.asl -->
```asl
readonly func InstructionContractHandler_LHUI_U()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;

pure func InstructionContractAGUAction_LHUI_U()
    => ScalarAGUAction
begin
    return ScalarAGU_Load;
end;

pure func InstructionContractAGUAddressKind_LHUI_U()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Immediate;
end;

pure func InstructionContractAGUSizeBytes_LHUI_U()
    => integer {1,2,4,8}
begin
    return 2;
end;

pure func InstructionContractAGUOffsetScale_LHUI_U()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_LHUI_U()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_LHUI_U()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_LHUI_U()
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
- Each memory address must be aligned to the 2-byte access size; a 2-byte access is the complete transfer unit.

## State effects

- Sign-extend simm12, multiply it by 1, and add it modulo 2^PTO_XLEN to the SrcL base.
- After a successful 2-byte load, zero-extend the loaded value to PTO_XLEN and publish it through the destination.
- Successful execution advances TPC by 4 bytes; a rejected or faulting attempt does not retire.

## Memory effects and ordering

### Memory effects

- After complete preflight, perform one little-endian 2-byte load and record one relaxed load event.
- The load preserves memory and reservation state.

### Ordering

- Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.
- Complete the relaxed 2-byte memory operation, publish any result or writeback, and then advance TPC.

## Exceptions

- A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.
- A misaligned 2-byte address raises Fault_DataAlignment before translation or permission. A later permission or bounded-memory failure raises Fault_DataPage at the original address.
- A fault emits no successful memory event, performs no partial memory or destination effect, preserves pending writeback, and leaves TPC at the faulting instruction.
- Recovery performs a full reissue: every address, source snapshot, preflight, memory operation, and destination is recomputed with no retained progress.

## Examples

- lhui.u [SrcL, simm], ->{t, u, Rd}

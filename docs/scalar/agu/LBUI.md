<!-- GENERATED FROM: asl/scalar/agu/LBUI.asl -->
# LBUI

**Normative ASL source:** `asl/scalar/agu/LBUI.asl`

LBUI snapshots its scalar sources, forms its encoded address, and loads one aligned little-endian 1-byte value.

## Normative identity {#PTO-INST-SCALAR-LBUI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-lbui-purpose role=purpose -->
## What `LBUI` does

`LBUI` loads one `1`-byte unit at a signed immediate distance from a base register and zero-extends it. It is the immediate counterpart of `LBU`, with the same byte-granular window as `LBI`.

The canonical assembly is `lbui [SrcL, simm], ->{t, u, Rd}`.

Design point: the immediate is not scaled by the access width, so `simm12` reaches any byte in `-2048`..`2047`, and the result is the raw `0`..`255` byte rather than a signed number.

<!-- PTO-READER-BLOCK: scalar-lbui-mechanism role=mechanism -->
## How the address and the transfer are formed

The displacement is the sign-extended `simm12` added to the `SrcL` snapshot modulo `2^PTO_XLEN`. The base is read before any memory effect, so a later write of the same register cannot move this address.

The address is preflighted, and on success one little-endian byte is read and one relaxed load event is recorded. The byte is zero-extended and published through `RegDst`.

There is no destination for an updated base: the sum is used only as the address of this load.

Design point: the permission check tests `address + 1` against the permitted bound, so the last permitted byte is reachable and the first byte beyond it is not.

<!-- PTO-READER-BLOCK: scalar-lbui-inputs role=inputs-outputs -->
## Encoded fields and roles

- `SrcL` is the base selector. Codes `0`..`23` select absolute GPRs, `24`..`27` select `T#1`..`T#4`, and `28`..`31` select `U#1`..`U#4`; queue entries are read without being consumed.
- `simm12` is signed and covers `-2048`..`2047`. It is the only addressing operand besides `SrcL`; there is no `SrcRType` and no `shamt` in this encoding.
- `RegDst` is the destination selector. Codes `1`..`23` write GPRs, `30` pushes the `U` queue, `31` pushes the `T` queue, and `0` plus `24`..`29` publish nothing; code `0` is the architectural zero GPR, whose writes are discarded.
- Design point: because the base can be any Reg5 source, `LBUI` can read through a queue entry produced earlier in the same instruction stream without a GPR round trip.

<!-- PTO-READER-BLOCK: scalar-lbui-effects role=effects -->
## Effects, ordering, and completion

All sources are snapshotted before the memory operation, so the published byte cannot depend on anything written by this instruction.

Success records one relaxed load event, leaves memory and reservation state unchanged, publishes the zero-extended byte, and advances `TPC` by `4` bytes.

Design point: `RegDst` never carries sign information, so a byte stored as `0xFF` and read back through `LBUI` is the number `255`.

<!-- PTO-READER-BLOCK: scalar-lbui-constraints role=constraints -->
## Legality, faults, and restart

- A fixed-bit mismatch, or a `SrcL` selector naming an unavailable `T`/`U` queue entry, raises `Fault_IllegalInstruction` before any source value is read.
- The `1`-byte alignment stage precedes translation and permission; a permission or bounded-memory failure later raises `Fault_DataPage` at the original effective address.
- A fault records no event, publishes no value, and leaves `TPC` on the faulting instruction so that the complete attempt can be reissued.
- Design point: no encoding of `LBUI` can reach the alignment failure, because a `1`-byte access only requires the address to be a multiple of `1`.

<!-- PTO-READER-BLOCK: scalar-lbui-example role=example -->
## Reading one encoding end to end

This example demonstrates the address calculation only; exact behavior remains in the current ASL and instruction contract.

- With GPR `6` = `0x1000` and `simm12` = `-1`, the address is `0xFFF`.
- A byte `0xFF` there publishes `0xFF`, while the same address through `LBI` would publish `0xFFFFFFFFFFFFFFFF`.
- Because the sum wraps modulo `2^PTO_XLEN`, the negative displacement never underflows the `64`-bit address space.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
lbui [SrcL, simm], ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| lbui_32_c39b9aa11f02 | L32 | 32 | 0x00004019 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| lbui_32_c39b9aa11f02 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| lbui_32_c39b9aa11f02 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| lbui_32_c39b9aa11f02 | simm12 | 12 | signed | [{"instruction_lsb":20,"value_lsb":0,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| lbui_32_c39b9aa11f02 | RegDst | 5 | 0–31 | none | none | Reg5 loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| lbui_32_c39b9aa11f02 | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| lbui_32_c39b9aa11f02 | simm12 | 12 | 0–4095 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 loaded-value destination or discard |
| SrcL | Reg5 address-base source |
| simm12 | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/LBUI.asl -->
```asl
readonly func InstructionContractOperation_LBUI() => ScalarOperation
begin
    return ScalarOperation_LBUI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/LBUI.asl -->
```asl
readonly func InstructionContractHandler_LBUI()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;

pure func InstructionContractAGUAction_LBUI()
    => ScalarAGUAction
begin
    return ScalarAGU_Load;
end;

pure func InstructionContractAGUAddressKind_LBUI()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Immediate;
end;

pure func InstructionContractAGUSizeBytes_LBUI()
    => integer {1,2,4,8}
begin
    return 1;
end;

pure func InstructionContractAGUOffsetScale_LBUI()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_LBUI()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_LBUI()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_LBUI()
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
- Each memory address must be aligned to the 1-byte access size; a 1-byte access is the complete transfer unit.

## State effects

- Sign-extend simm12, multiply it by 1, and add it modulo 2^PTO_XLEN to the SrcL base.
- After a successful 1-byte load, zero-extend the loaded value to PTO_XLEN and publish it through the destination.
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

- lbui [SrcL, simm], ->{t, u, Rd}

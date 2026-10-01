<!-- GENERATED FROM: asl/scalar/agu/HL.LBUI.PR.asl -->
# HL.LBUI.PR

**Normative ASL source:** `asl/scalar/agu/HL.LBUI.PR.asl`

HL.LBUI.PR snapshots its scalar sources, forms its encoded address, and loads one aligned little-endian 1-byte value.

## Normative identity {#PTO-INST-SCALAR-HL-LBUI-PR}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-lbui-pr-purpose role=purpose -->
## What `HL.LBUI.PR` does

`HL.LBUI.PR` is a `48`-bit pre-indexed byte load with a signed `17`-bit immediate displacement and a zero-extended result. It adds the displacement to the `SrcL` base, reads one byte at the sum, clears everything above bit `7` of the result, publishes the byte to `Dst0`, and publishes the same sum to `Dst1`.

The canonical assembly is `hl.lbui.pr [SrcL, simm], ->Dst0, Dst1`.

Design point: the immediate is a field of the encoding, so it is always present. An immediate of `0` is a displacement of zero: the access happens at the base itself and `Dst1` republishes the base unchanged. Nothing in this form lets a program omit the displacement and get a different, register-derived address instead.

<!-- PTO-READER-BLOCK: scalar-hl-lbui-pr-mechanism role=mechanism -->
## How the address and the transfer are formed

The `17`-bit immediate is sign-extended, used with a scale of `1`, and added to the snapshot of `SrcL` modulo `2^PTO_XLEN`. The sum is the effective address and also the value delivered to `Dst1`.

`SrcL` is only read; the base register is never modified by the instruction.

After the encoding checks and the address preflight pass, the handler performs one `1`-byte little-endian load, zero-extends the byte, and publishes `Dst0` then `Dst1`.

Design point: because the displacement is an immediate, two executions of the same encoding always compute the same address from the same base. There is no register that could change between them, and there is no transform field that could make the displacement depend on data.

<!-- PTO-READER-BLOCK: scalar-hl-lbui-pr-inputs role=inputs-outputs -->
## Encoded fields and the two results

- `SrcL` is the base and a `5`-bit Reg5 selector over absolute GPRs, `T#1`..`T#4`, and `U#1`..`U#4`.
- `simm17` is a signed `17`-bit immediate covering `-65536` to `65535` with a scale of `1`, so the reachable window spans `131072` bytes around the base.
- `Dst0` receives the zero-extended byte and `Dst1` the updated base; codes `1`..`23` write GPRs, `30` pushes `U`, `31` pushes `T`, and `0` and `24`..`29` discard that result alone.

Design point: the reachable window is large enough that an immediate-based access can cover a structure without any pointer arithmetic, at the cost of a fixed displacement per encoding. A traversal whose step changes at run time cannot be expressed by this form at all.

<!-- PTO-READER-BLOCK: scalar-hl-lbui-pr-effects role=effects -->
## Effects, ordering, and completion

`SrcL` is read before any memory or destination effect, so a destination naming `SrcL` still contributes the pre-instruction base.

A successful execution records one relaxed `1`-byte load event and leaves memory bytes and reservation state unchanged. `TPC` advances by `6` bytes after both publications; a rejected or faulting attempt does not retire.

Design point: the write order is `Dst0` then `Dst1`, so when both fields name one register the updated base is the surviving value. The loaded byte is not lost from memory, only from that register.

<!-- PTO-READER-BLOCK: scalar-hl-lbui-pr-constraints role=constraints -->
## Legality, faults, and restart

A fixed-bit mismatch raises `Fault_IllegalInstruction` before any effect, and an unavailable `T` or `U` slot named by `SrcL` raises the same fault before execution. This encoding has no reserved field beyond its fixed bits.

The preflight applies the `1`-byte alignment requirement, which every address meets, so no address raises `Fault_DataAlignment` for this form. A permission or bounded-memory failure raises `Fault_DataPage` at the original address.

A fault records no load event, publishes neither result, and leaves `TPC` on the faulting instruction. Recovery sign-extends the immediate again and repeats the sum and the load from the same snapshots.

<!-- PTO-READER-BLOCK: scalar-hl-lbui-pr-example role=example -->
## Reading one encoding end to end

This walkthrough explains how to use the page and does not add instruction behavior.

- Take `hl.lbui.pr [18, 0], ->19, 18` with GPR18 = `0x6100`. The immediate is `0`, so the effective address is `0x6100` itself.
- If the byte at `0x6100` is `01`, GPR19 receives `1`.
- GPR18 receives `0x6100` again, because `Dst1` names the base register and the sum equals the base.
- `TPC` becomes the instruction address plus `6`, and the base register is otherwise untouched.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.lbui.pr [SrcL, simm], ->Dst0, Dst1
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_lbui_pr_48_78a81538a7fa | HL48 | 48 | 0x00004019002e / 0x0000707f003f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_lbui_pr_48_78a81538a7fa | RegDst0 | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_lbui_pr_48_78a81538a7fa | RegDst1 | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_lbui_pr_48_78a81538a7fa | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_lbui_pr_48_78a81538a7fa | simm17 | 17 | signed | [{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":6,"value_lsb":12,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_lbui_pr_48_78a81538a7fa | RegDst0 | 5 | 0–31 | none | none | Reg5 first loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_lbui_pr_48_78a81538a7fa | RegDst1 | 5 | 0–31 | none | none | Reg5 updated-base destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_lbui_pr_48_78a81538a7fa | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| hl_lbui_pr_48_78a81538a7fa | simm17 | 17 | 0–131071 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst0 | Reg5 first loaded-value destination or discard |
| RegDst1 | Reg5 updated-base destination or discard |
| SrcL | Reg5 address-base source |
| simm17 | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.LBUI.PR.asl -->
```asl
readonly func InstructionContractOperation_HL_LBUI_PR() => ScalarOperation
begin
    return ScalarOperation_HL_LBUI_PR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.LBUI.PR.asl -->
```asl
readonly func InstructionContractHandler_HL_LBUI_PR()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;

pure func InstructionContractAGUAction_HL_LBUI_PR()
    => ScalarAGUAction
begin
    return ScalarAGU_Load;
end;

pure func InstructionContractAGUAddressKind_HL_LBUI_PR()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Immediate;
end;

pure func InstructionContractAGUSizeBytes_HL_LBUI_PR()
    => integer {1,2,4,8}
begin
    return 1;
end;

pure func InstructionContractAGUOffsetScale_HL_LBUI_PR()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_HL_LBUI_PR()
    => AddressUpdateMode
begin
    return AddressUpdate_PreIndex;
end;

pure func InstructionContractAGUSignedLoad_HL_LBUI_PR()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_LBUI_PR()
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
- Each memory address must be aligned to the 1-byte access size; a 1-byte access is the complete transfer unit.

## State effects

- Sign-extend simm17, multiply it by 1, and add it modulo 2^PTO_XLEN to the SrcL base.
- Pre-index mode accesses the updated base and publishes that same updated base only after successful memory completion.
- After a successful 1-byte load, zero-extend the loaded value to PTO_XLEN and publish it through the destination.
- Successful execution advances TPC by 6 bytes; a rejected or faulting attempt does not retire.

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

- hl.lbui.pr [SrcL, simm], ->Dst0, Dst1

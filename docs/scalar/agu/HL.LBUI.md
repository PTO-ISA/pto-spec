<!-- GENERATED FROM: asl/scalar/agu/HL.LBUI.asl -->
# HL.LBUI

**Normative ASL source:** `asl/scalar/agu/HL.LBUI.asl`

HL.LBUI snapshots its scalar sources, forms its encoded address, and loads one aligned little-endian 1-byte value.

## Normative identity {#PTO-INST-SCALAR-HL-LBUI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-lbui-purpose role=purpose -->
## What `HL.LBUI` does

`HL.LBUI` is a `48`-bit byte load with a signed `22`-bit immediate displacement and a zero-extended result. It adds the immediate to the `SrcL` base, reads one byte there, clears every result bit above bit `7`, and publishes the byte to `RegDst`.

The canonical assembly is `hl.lbui [SrcL, simm], ->{t, u, Rd}`.

Design point: the address comes from a sign-extended immediate added to `SrcL`, so the address formation is signed even though the result is not. The zero extension is the only step that treats the loaded byte as unsigned: a byte of `80` published here is `128`, and nothing about the address or the access depends on the value read.

<!-- PTO-READER-BLOCK: scalar-hl-lbui-mechanism role=mechanism -->
## How the address and the transfer are formed

The immediate is sign-extended, used with a scale of `1`, and added to the snapshot of `SrcL` modulo `2^PTO_XLEN`. The update mode is none, so the sum is used for the access and then discarded; no base register changes.

Once the encoding checks and the address preflight pass, the handler performs one `1`-byte little-endian load, zero-extends the byte to `PTO_XLEN`, and publishes it to `RegDst`.

Design point: the window spans `-2097152` through `2097151` bytes with no scaling, so the form reaches every byte address in that window. Because a `1`-byte access has no alignment requirement, none of those addresses can be refused by the preflight; the only rejection left at that stage is the permission and bounded-memory test.

<!-- PTO-READER-BLOCK: scalar-hl-lbui-inputs role=inputs-outputs -->
## Encoded fields and the result

- `SrcL` is a `5`-bit Reg5 selector over absolute GPRs, `T#1`..`T#4`, and `U#1`..`U#4`.
- `simm22` is a signed `22`-bit immediate covering `-2097152` to `2097151`, scaled by `1`.
- `RegDst` is a `5`-bit selector: codes `1`..`23` write absolute GPRs, `30` pushes `U`, `31` pushes `T`, and `0` and `24`..`29` discard the value alone.

Design point: because the result is a full-width value, a consumer never has to mask the loaded byte. The `56` bits above the byte are always zero, which makes the published value usable directly as an unsigned index or length.

<!-- PTO-READER-BLOCK: scalar-hl-lbui-effects role=effects -->
## Effects, ordering, and completion

`SrcL` is read before any memory or destination effect, so an alias between the base and the destination uses the pre-instruction value.

A successful execution records one relaxed `1`-byte load event and leaves memory and reservation state unchanged. `TPC` advances by `6` bytes after the publication; a rejected or faulting attempt does not retire.

Design point: the destination is written only when the load reported no fault, so a faulting access leaves a register or queue slot named by `RegDst` exactly as it was. There is no partial state to undo before a retry.

<!-- PTO-READER-BLOCK: scalar-hl-lbui-constraints role=constraints -->
## Legality, faults, and restart

A fixed-bit mismatch raises `Fault_IllegalInstruction` before any effect, and an unavailable `T` or `U` slot named by `SrcL` raises the same fault before execution.

The preflight applies the `1`-byte alignment requirement, which every address satisfies, so no address raises `Fault_DataAlignment` for this form. A permission or bounded-memory failure raises `Fault_DataPage` at the original address.

A fault records no load event, writes no destination, and leaves `TPC` on the faulting instruction. Recovery sign-extends the immediate again and repeats the sum and the load from the same snapshots.

<!-- PTO-READER-BLOCK: scalar-hl-lbui-example role=example -->
## Reading one encoding end to end

This walkthrough explains how to use the page and does not add instruction behavior.

- Take `hl.lbui [4, 1], ->t` with GPR4 = `0xB000`. The immediate is `1`, so the effective address is `0xB001`.
- The instruction reads the byte at `0xB001`. If it is `FF`, the value pushed as the new `T#1` is `255`, with bits `63`:`8` all zero.
- The push also moves the older queue entries one slot along, so the previous `T#1` becomes `T#2`.
- GPR4 still holds `0xB000`, and `TPC` becomes the instruction address plus `6`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.lbui [SrcL, simm], ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_lbui_48_50579e3558f4 | HL48 | 48 | 0x00004019000e / 0x0000707f003f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_lbui_48_50579e3558f4 | RegDst | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_lbui_48_50579e3558f4 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_lbui_48_50579e3558f4 | simm22 | 22 | signed | [{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":6,"value_lsb":12,"width":10}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_lbui_48_50579e3558f4 | RegDst | 5 | 0–31 | none | none | Reg5 loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_lbui_48_50579e3558f4 | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| hl_lbui_48_50579e3558f4 | simm22 | 22 | 0–4194303 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 loaded-value destination or discard |
| SrcL | Reg5 address-base source |
| simm22 | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.LBUI.asl -->
```asl
readonly func InstructionContractOperation_HL_LBUI() => ScalarOperation
begin
    return ScalarOperation_HL_LBUI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.LBUI.asl -->
```asl
readonly func InstructionContractHandler_HL_LBUI()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;

pure func InstructionContractAGUAction_HL_LBUI()
    => ScalarAGUAction
begin
    return ScalarAGU_Load;
end;

pure func InstructionContractAGUAddressKind_HL_LBUI()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Immediate;
end;

pure func InstructionContractAGUSizeBytes_HL_LBUI()
    => integer {1,2,4,8}
begin
    return 1;
end;

pure func InstructionContractAGUOffsetScale_HL_LBUI()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_HL_LBUI()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_HL_LBUI()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_LBUI()
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
- simm22 assigns every signed 22-bit value -2097152..2097151; the encoded byte displacement is that value multiplied by 1.
- Each memory address must be aligned to the 1-byte access size; a 1-byte access is the complete transfer unit.

## State effects

- Sign-extend simm22, multiply it by 1, and add it modulo 2^PTO_XLEN to the SrcL base.
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

- hl.lbui [SrcL, simm], ->{t, u, Rd}

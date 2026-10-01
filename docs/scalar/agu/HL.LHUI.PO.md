<!-- GENERATED FROM: asl/scalar/agu/HL.LHUI.PO.asl -->
# HL.LHUI.PO

**Normative ASL source:** `asl/scalar/agu/HL.LHUI.PO.asl`

HL.LHUI.PO snapshots its scalar sources, forms its encoded address, and loads one aligned little-endian 2-byte value.

## Normative identity {#PTO-INST-SCALAR-HL-LHUI-PO}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-lhui-po-purpose role=purpose -->
## What `HL.LHUI.PO` does

`HL.LHUI.PO` is a standalone 48-bit load that adds an immediate displacement to the `SrcL` base. It loads one 2-byte value into one destination.

<!-- PTO-READER-BLOCK: scalar-hl-lhui-po-mechanism role=mechanism -->
## Address and load mechanism

The decoded `simm17` is sign-extended and shifted left by `1`, so each encoded unit is worth `2` bytes of address.

The scaled displacement is added to the snapshotted `SrcL` value modulo `2^PTO_XLEN`.

Once the `2`-byte address passes the alignment check and then the translation and permission check, the instruction performs one little-endian `2`-byte load and records one relaxed load event.

Post-index mode accesses the original base and publishes base plus offset through `Dst1`.

The byte at the accessed address becomes bits `7:0` of the result and later bytes fill higher bits, so the value is little-endian, and the instruction will zero-extend the loaded value to `PTO_XLEN`, keeping the low `16` bits and setting every higher bit to zero.

**Design point:** storing the displacement divided by `2` lets a 17-bit `simm17` reach far more addresses than an unscaled field of the same width, at the cost of a displacement that is always a multiple of `2`. The shift happens before the modulo `2^PTO_XLEN` addition, so a negative `simm17` still subtracts.

<!-- PTO-READER-BLOCK: scalar-hl-lhui-po-inputs role=inputs-outputs -->
## Inputs and destinations

- `SrcL` is the address base and uses the complete Reg5 source domain, where codes `0..23` name absolute GPRs, codes `24..27` name `T#1..T#4`, and codes `28..31` name `U#1..U#4`.
- Reading a `T` or `U` selector does not consume or shift the queue it names; the queue index `1..4` is used as a source value only.
- `simm17` covers every signed 17-bit value from `-65536` through `65535`, and the encoded byte displacement is that value multiplied by `2`.
- `Dst0` receives the loaded value and `Dst1` the updated base, so `Dst1` receives an address rather than loaded data.
- Both destination fields use the complete Reg5 destination domain: codes `1..23` write absolute GPRs, code `30` pushes U, code `31` pushes T, and codes `0` and `24..29` discard only that result without suppressing the rest of the instruction.
- Every displayed operand field is encoded explicitly, so encoded zero is a value and never denotes omission.

<!-- PTO-READER-BLOCK: scalar-hl-lhui-po-effects role=effects -->
## Effects and ordering

The base register is read before the memory operation and before any destination write.

A successful attempt records one relaxed load event, leaves memory and reservation state unchanged, publishes the loaded value, and advances `TPC` by `6` bytes.

**Design point:** the loaded value is published first, and the update uses the base snapshot rather than the register just written. When `Dst0` and `Dst1` name the same register the update wins; when either names `SrcL` the address still came from the pre-instruction value.

<!-- PTO-READER-BLOCK: scalar-hl-lhui-po-constraints role=constraints -->
## Alignment, faults, and restart

The effective address must be aligned to the `2`-byte transfer size. Misalignment raises `Fault_DataAlignment` before translation; a translation or bounded-memory failure after that raises `Fault_DataPage` at the original address.

A fixed-bit mismatch, a reserved field value, or an unavailable selected `T` or `U` source raises `Fault_IllegalInstruction` before any instruction effect.

A fault emits no load event and writes no destination, and the address it records is the address that failed. Recovery reissues the whole instruction: the address, the source snapshot, every probe, the load, and every destination are recomputed with no retained progress.

**Design point:** the alignment check runs before translation, so an access that is both unaligned and outside the permitted region reports `Fault_DataAlignment`, not `Fault_DataPage`. The fault saves its address as the trap argument and redirects `TPC` to the trap entry, which is what lets a handler reissue the instruction with no retained progress.

<!-- PTO-READER-BLOCK: scalar-hl-lhui-po-example role=example -->
## Non-normative address example

This example illustrates the current address and publication rule and does not replace the normative load contract.

With `SrcL=0x100` and a decoded `simm17` of `1`, the byte displacement is `2`, so the accessed address is `0x102`.

If that address is aligned and permitted, `Dst0` receives the loaded value, `Dst1` receives the updated base `0x102`, and `TPC` advances by `6` bytes.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.lhui.po [SrcL, simm], ->Dst0, Dst1
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_lhui_po_48_16db8d40eee8 | HL48 | 48 | 0x00005019003e / 0x0000707f003f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_lhui_po_48_16db8d40eee8 | RegDst0 | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_lhui_po_48_16db8d40eee8 | RegDst1 | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_lhui_po_48_16db8d40eee8 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_lhui_po_48_16db8d40eee8 | simm17 | 17 | signed | [{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":6,"value_lsb":12,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_lhui_po_48_16db8d40eee8 | RegDst0 | 5 | 0–31 | none | none | Reg5 first loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_lhui_po_48_16db8d40eee8 | RegDst1 | 5 | 0–31 | none | none | Reg5 updated-base destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_lhui_po_48_16db8d40eee8 | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| hl_lhui_po_48_16db8d40eee8 | simm17 | 17 | 0–131071 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst0 | Reg5 first loaded-value destination or discard |
| RegDst1 | Reg5 updated-base destination or discard |
| SrcL | Reg5 address-base source |
| simm17 | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.LHUI.PO.asl -->
```asl
readonly func InstructionContractOperation_HL_LHUI_PO() => ScalarOperation
begin
    return ScalarOperation_HL_LHUI_PO;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.LHUI.PO.asl -->
```asl
readonly func InstructionContractHandler_HL_LHUI_PO()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;

pure func InstructionContractAGUAction_HL_LHUI_PO()
    => ScalarAGUAction
begin
    return ScalarAGU_Load;
end;

pure func InstructionContractAGUAddressKind_HL_LHUI_PO()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Immediate;
end;

pure func InstructionContractAGUSizeBytes_HL_LHUI_PO()
    => integer {1,2,4,8}
begin
    return 2;
end;

pure func InstructionContractAGUOffsetScale_HL_LHUI_PO()
    => integer {0..3}
begin
    return 1;
end;

pure func InstructionContractAGUUpdateMode_HL_LHUI_PO()
    => AddressUpdateMode
begin
    return AddressUpdate_PostIndex;
end;

pure func InstructionContractAGUSignedLoad_HL_LHUI_PO()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_LHUI_PO()
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
- simm17 assigns every signed 17-bit value -65536..65535; the encoded byte displacement is that value multiplied by 2.
- Each memory address must be aligned to the 2-byte access size; a 2-byte access is the complete transfer unit.

## State effects

- Sign-extend simm17, multiply it by 2, and add it modulo 2^PTO_XLEN to the SrcL base.
- Post-index mode accesses the original base and publishes base plus offset only after successful memory completion.
- After a successful 2-byte load, zero-extend the loaded value to PTO_XLEN and publish it through the destination.
- Successful execution advances TPC by 6 bytes; a rejected or faulting attempt does not retire.

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

- hl.lhui.po [SrcL, simm], ->Dst0, Dst1

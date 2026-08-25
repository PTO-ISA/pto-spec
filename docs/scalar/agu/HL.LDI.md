<!-- GENERATED FROM: asl/scalar/agu/HL.LDI.asl -->
# HL.LDI

**Normative ASL source:** `asl/scalar/agu/HL.LDI.asl`

HL.LDI snapshots its scalar sources, forms its encoded address, and loads one aligned little-endian 8-byte value.

## Normative identity {#PTO-INST-SCALAR-HL-LDI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-ldi-purpose role=purpose -->
## What HL.LDI does

`HL.LDI` is a standalone 48-bit load that forms a scaled signed-immediate address and transfers one aligned little-endian 8-byte value to a Reg5 destination.

<!-- PTO-READER-BLOCK: scalar-hl-ldi-mechanism role=mechanism -->
## Address and load mechanism

The instruction sign-extends `simm22`, multiplies it by `8`, and adds the scaled displacement to the snapshotted `SrcL` base modulo `2^PTO_XLEN`.

After complete access preflight, `HL.LDI` performs one little-endian 8-byte load and preserves the complete 64-bit loaded bit pattern for destination publication.

This form performs no base-register update and does not return an address in place of loaded data.

<!-- PTO-READER-BLOCK: scalar-hl-ldi-inputs role=inputs-outputs -->
## Inputs and destination

- `SrcL` accepts the complete Reg5 source domain, including non-consuming `T#1..T#4` and `U#1..U#4` selectors.
- `simm22` covers every signed 22-bit value from `-2097152` through `2097151`; encoded zero means a zero displacement.
- `RegDst` values `1..23` write GPRs, `30` pushes U, `31` pushes T, and `0` plus `24..29` discard only the loaded result.

<!-- PTO-READER-BLOCK: scalar-hl-ldi-effects role=effects -->
## Effects and ordering

All scalar sources are snapshotted before memory or destination effects, so aliases observe pre-instruction values.

A successful attempt emits one relaxed load event, preserves memory and reservation state, publishes or discards the loaded value, and advances `TPC` by `6` bytes.

<!-- PTO-READER-BLOCK: scalar-hl-ldi-constraints role=constraints -->
## Alignment, faults, and restart

The effective address must be aligned to the 8-byte transfer size. Misalignment raises `Fault_DataAlignment` before translation; a later permission or bounded-memory failure raises `Fault_DataPage` at the original address.

A fault emits no successful memory event, performs no partial destination or memory effect, preserves pending writeback, and leaves the faulting `TPC` available for a complete reissue.

A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises `Fault_IllegalInstruction` before instruction effects.

<!-- PTO-READER-BLOCK: scalar-hl-ldi-example role=example -->
## Non-normative address example

This example illustrates the current address rule and does not replace the normative load contract.

With a base of `0x100` and `simm22=2`, the scaled displacement is `16`, so `HL.LDI` accesses `0x110`. If that address is aligned and permitted, it loads the eight bytes beginning there and advances `TPC` by `6` bytes.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.ldi [SrcL, simm], ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_ldi_48_088e69e45b37 | HL48 | 48 | 0x00003019000e / 0x0000707f003f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_ldi_48_088e69e45b37 | RegDst | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_ldi_48_088e69e45b37 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_ldi_48_088e69e45b37 | simm22 | 22 | signed | [{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":6,"value_lsb":12,"width":10}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_ldi_48_088e69e45b37 | RegDst | 5 | 0–31 | none | none | Reg5 loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_ldi_48_088e69e45b37 | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| hl_ldi_48_088e69e45b37 | simm22 | 22 | 0–4194303 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 loaded-value destination or discard |
| SrcL | Reg5 address-base source |
| simm22 | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.LDI.asl -->
```asl
readonly func InstructionContractOperation_HL_LDI() => ScalarOperation
begin
    return ScalarOperation_HL_LDI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.LDI.asl -->
```asl
readonly func InstructionContractHandler_HL_LDI()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;

pure func InstructionContractAGUAction_HL_LDI()
    => ScalarAGUAction
begin
    return ScalarAGU_Load;
end;

pure func InstructionContractAGUAddressKind_HL_LDI()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Immediate;
end;

pure func InstructionContractAGUSizeBytes_HL_LDI()
    => integer {1,2,4,8}
begin
    return 8;
end;

pure func InstructionContractAGUOffsetScale_HL_LDI()
    => integer {0..3}
begin
    return 3;
end;

pure func InstructionContractAGUUpdateMode_HL_LDI()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_HL_LDI()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_LDI()
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
- simm22 assigns every signed 22-bit value -2097152..2097151; the encoded byte displacement is that value multiplied by 8.
- Each memory address must be aligned to the 8-byte access size; a 8-byte access is the complete transfer unit.

## State effects

- Sign-extend simm22, multiply it by 8, and add it modulo 2^PTO_XLEN to the SrcL base.
- After a successful 8-byte load, preserve the complete 64-bit loaded bit pattern and publish it through the destination.
- Successful execution advances TPC by 6 bytes; a rejected or faulting attempt does not retire.

## Memory effects and ordering

### Memory effects

- After complete preflight, perform one little-endian 8-byte load and record one relaxed load event.
- The load preserves memory and reservation state.

### Ordering

- Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.
- Complete the relaxed 8-byte memory operation, publish any result or writeback, and then advance TPC.

## Exceptions

- A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.
- A misaligned 8-byte address raises Fault_DataAlignment before translation or permission. A later permission or bounded-memory failure raises Fault_DataPage at the original address.
- A fault emits no successful memory event, performs no partial memory or destination effect, preserves pending writeback, and leaves TPC at the faulting instruction.
- Recovery performs a full reissue: every address, source snapshot, preflight, memory operation, and destination is recomputed with no retained progress.

## Examples

- hl.ldi [SrcL, simm], ->{t, u, Rd}

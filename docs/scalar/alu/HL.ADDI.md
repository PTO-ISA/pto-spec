<!-- GENERATED FROM: asl/scalar/alu/HL.ADDI.asl -->
# HL.ADDI

**Normative ASL source:** `asl/scalar/alu/HL.ADDI.asl`

HL.ADDI applies XLEN addition to SrcL and a zero-extended 24-bit immediate.

## Normative identity {#PTO-INST-SCALAR-HL-ADDI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-addi-purpose role=purpose -->
## What HL.ADDI does

`HL.ADDI` is the 48-bit form of XLEN addition with a constant. It reads one Reg5 source, zero-extends the encoded `uimm24` immediate to `PTO_XLEN`, adds the two values modulo `2^PTO_XLEN`, and publishes the sum through `RegDst`. The encoding is `48` bits wide, so successful execution advances `TPC` by `6` bytes.

Design point: `uimm24` is unsigned, so this mnemonic can express every addend from `0` through `16777215` and no negative addend. A downward constant is a different mnemonic: `HL.SUBI` reads the same `SrcL` and `uimm24` fields and applies subtraction, so the two forms share one field layout and differ in the operation they apply.

<!-- PTO-READER-BLOCK: scalar-hl-addi-mechanism role=mechanism -->
## How the sum is formed

The encoder carries `uimm24` in two 12-bit pieces. Decode places the first piece in value bits `11:0` and the second in value bits `23:12`, so the reassembled constant is exact and all `16777216` patterns denote distinct addends.

Design point: the immediate pieces occupy instruction bits `4..15` and `36..47`, while `RegDst` occupies instruction bits `23..27`. The fields cannot overlap, so no immediate bit can reselect the destination, and no immediate value has to be reserved for another role.

After reassembly the constant is zero-extended to `PTO_XLEN` and added to the snapshotted source. The addition is fixed width: it wraps and raises no arithmetic exception.

<!-- PTO-READER-BLOCK: scalar-hl-addi-inputs role=inputs-outputs -->
## Inputs and destinations

- `SrcL` reads one Reg5 value: codes `0..23` read absolute GPRs, `24..27` read `T#1..T#4`, and `28..31` read `U#1..U#4`. A relative read never removes the queue entry it names.
- `uimm24` supplies the unsigned addend, `0` through `16777215`.
- `RegDst` receives the `PTO_XLEN` sum: `1..23` write that GPR, `30` pushes `U`, `31` pushes `T`, and `0` together with `24..29` discard it.

Design point: the three encoded zeros are three different things. `SrcL=0` reads GPR zero, which always reads as zero and has no storage; `uimm24=0` is the numeric addend `0`; `RegDst=0` names that same GPR zero, whose writes are dropped. So `hl.addi a0, 0, ->zero` publishes its sum to no register and no queue, and only `TPC` moves.

<!-- PTO-READER-BLOCK: scalar-hl-addi-effects role=effects -->
## Effects and ordering

`SrcL` and `uimm24` are both resolved before the destination is written, so a form that names one register twice, such as `hl.addi a0, 1, ->a0`, adds to the pre-instruction `a0`. A relative source read leaves its queue untouched, and a discard destination leaves every register and queue untouched as well.

Publication is followed by the `TPC` advance of `6` bytes, including when `RegDst` discards the sum. `HL.ADDI` performs no memory access and changes no reservation, descriptor, numeric-status, `Tile`, bundle, privilege or branch-target state.

<!-- PTO-READER-BLOCK: scalar-hl-addi-constraints role=constraints -->
## Legality and fault boundary

Every encoded value is assigned: all `32` `SrcL` codes, all `32` `RegDst` codes, and the complete unsigned `24`-bit addend range.

Three rejections are reachable, in model order. A `48`-bit word whose fixed bits match no form raises `Fault_IllegalInstruction` at `PC`. An instruction that is not applicable to the active bundle raises `Fault_BundleControl` at `TPC`. An unavailable selected `T` or `U` source raises `Fault_IllegalInstruction` at `PC`. Each precedes the destination effect and the `TPC` advance.

Design point: the applicability test runs before the source test, so an encoding that is both inapplicable and carries an unavailable source reports `Fault_BundleControl` at `TPC` rather than the source fault. For an ALU operation the applicability test fails only while a system block has recorded a terminal close request.

`HL.ADDI` adds no arithmetic exception of its own: a sum that overflows `PTO_XLEN` is discarded by wrapping.

<!-- PTO-READER-BLOCK: scalar-hl-addi-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

With `a0` holding `1`, `hl.addi a0, 16777215, ->a0` writes `16777216`. With `a0` holding `18446744073709551615`, the largest `PTO_XLEN` value, `hl.addi a0, 1, ->a0` writes `0`, and `TPC` still advances by `6` bytes.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.addi SrcL, uimm, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_addi_48_9d3818bfbe64 | HL48 | 48 | 0x00000015000e / 0x0000707f000f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_addi_48_9d3818bfbe64 | RegDst | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_addi_48_9d3818bfbe64 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_addi_48_9d3818bfbe64 | uimm24 | 24 | unsigned | [{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":4,"value_lsb":12,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_addi_48_9d3818bfbe64 | RegDst | 5 | 0–31 | none | none | Reg5 scalar destination or discard selector | Encoded zero discards the result and does not modify any GPR or queue. |
| hl_addi_48_9d3818bfbe64 | SrcL | 5 | 0–31 | none | none | Reg5 scalar source | Encoded zero reads architectural GPR zero. |
| hl_addi_48_9d3818bfbe64 | uimm24 | 24 | 0–16777215 | none | none | unsigned split 24-bit immediate | Encoded zero supplies numeric zero. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 scalar destination or discard selector |
| SrcL | Reg5 scalar source |
| uimm24 | unsigned split 24-bit immediate |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/HL.ADDI.asl -->
```asl
readonly func InstructionContractOperation_HL_ADDI() => ScalarOperation
begin
    return ScalarOperation_HL_ADDI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/HL.ADDI.asl -->
```asl
readonly func InstructionContractHandler_HL_ADDI() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinary;
end;

pure func InstructionContractImmediateWidth_HL_ADDI()
    => integer {1..64}
begin
    return 24;
end;

pure func InstructionContractImmediateIsUnsigned_HL_ADDI()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractIsWordOperation_HL_ADDI()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractResult_HL_ADDI(
    left: Word,
    immediate: bits(24))
    => Word
begin
    let right = ZeroExtend{PTO_XLEN}(immediate);
    return ScalarBinary(
        ScalarBinary_ADD,
        left,
        right);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL, uimm24, and RegDst are required encoded fields; no field can be omitted.
- uimm24 has the complete unsigned 24-bit range 0 through 16777215; encoded zero is numeric zero.

## Legality

- All 32 SrcL encodings are assigned: 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consuming a queue entry.
- All 32 RegDst encodings are assigned: codes 0 and 24..29 discard, codes 1..23 write absolute GPRs, code 30 pushes U, and code 31 pushes T.
- Every unsigned 24-bit value is assigned. The two 12-bit pieces reconstruct one exact 24-bit value.

## State effects

- Zero-extend uimm24 to PTO_XLEN, compute addition with the snapshotted SrcL value modulo 2^PTO_XLEN where applicable, and publish the result through RegDst.
- Codes 1..23 write a GPR; codes 0 and 24..29 discard; code 30 pushes U; code 31 pushes T. Relative source reads are non-consuming.
- No memory, reservation, descriptor, Tile, block, privilege, numeric-status, branch-target, or other control state changes. Successful execution advances TPC by six bytes.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot SrcL before the destination effect, including GPR aliases and same-queue read-then-push cases.
- Publish the result through RegDst, then advance TPC by six bytes.

## Exceptions

- HL.ADDI raises no arithmetic exception; fixed-width overflow or underflow is discarded.
- A fixed-bit mismatch or unavailable selected T/U source raises Fault_IllegalInstruction before any destination effect and before TPC advances.

## Examples

- hl.addi a0, 1, ->a0
- hl.addi t#1, 16777215, ->u
- hl.addi zero, 0, ->zero

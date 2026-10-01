<!-- GENERATED FROM: asl/scalar/alu/ADDI.asl -->
# ADDI

**Normative ASL source:** `asl/scalar/alu/ADDI.asl`

ADDI performs unsigned-immediate XLEN addition with Reg5 source and destination selection.

## Normative identity {#PTO-INST-SCALAR-ADDI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-addi-purpose role=purpose -->
## What ADDI does

`ADDI` adds a zero-extended unsigned 12-bit immediate to a Reg5 source and publishes the sum through a Reg5 destination. It is the immediate form of the same XLEN addition that `ADD` performs with a register right source.

Design point: `ADDI` has no `SrcR`, `SrcRType` or `shamt` field, so its 32-bit encoding spends twelve bits on a constant instead of two five-bit register selectors plus a modifier and a shift. The trade is exact: one compact constant, and no right-source transformation.

<!-- PTO-READER-BLOCK: scalar-addi-mechanism role=mechanism -->
## How the result is formed

The immediate is zero-extended to `PTO_XLEN` and added to the snapshotted source value modulo `2^PTO_XLEN`.

Design point: `uimm12` is unsigned and covers `0` through `4095`, so the encoding contains no negative constant. `addi a0, 4095, ->a0` adds `4095`; a mnemonic whose immediate field is signed, such as `ANDI` with its `simm12`, is the way to encode a small negative constant.

Addition is fixed width and total. It wraps and raises no arithmetic exception.

<!-- PTO-READER-BLOCK: scalar-addi-inputs role=inputs-outputs -->
## Inputs and destinations

- `SrcL` is a Reg5 source: `0..23` read absolute GPRs, `24..27` read `T#1..T#4`, and `28..31` read `U#1..U#4`, without consuming a queue entry.
- `uimm12` carries the unsigned addend.
- `RegDst` publishes the result: `1..23` write that GPR, `30` pushes `U`, `31` pushes `T`, and `0` together with `24..29` discard it.

Design point: encoded zero means three different things on this page. `SrcL=0` reads the architectural zero GPR, `uimm12=0` is the numeric addend zero, and `RegDst=0` discards the result instead of writing the zero GPR. All three are values, not omissions, and the encoding has no omitted form.

<!-- PTO-READER-BLOCK: scalar-addi-effects role=effects -->
## Effects and ordering

`SrcL` is read before the destination is written, so a repeated source and destination selector such as `addi a0, 1, ->a0` still reads the pre-instruction `a0`.

The result is published or discarded, and then `TPC` advances by `4` bytes. `ADDI` performs no memory access and changes no reservation, descriptor, numeric-status, trap, bundle, privilege, predicate or control-flow state beyond that advance.

<!-- PTO-READER-BLOCK: scalar-addi-constraints role=constraints -->
## Legality and fault boundary

Every encoded value is assigned: all `32` `SrcL` codes, all `32` `RegDst` codes, and all `4096` immediate values from `0` through `4095`.

An undecodable form raises `Fault_IllegalInstruction` at `PC`; an instruction that is not applicable to the active block raises `Fault_BundleControl` at `TPC`; a fixed-bit mismatch or an unavailable selected T/U source raises `Fault_IllegalInstruction`. Each of these precedes the destination effect and the `TPC` advance. `ADDI` adds no fault of its own.

Design point: because the immediate is unsigned and fully assigned, no constant is illegal and none is reserved. Code that needs a signed 12-bit addend must use a mnemonic whose immediate is signed, or split the constant across two instructions.

<!-- PTO-READER-BLOCK: scalar-addi-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

With `SrcL` holding `10` and `uimm12=4095`, `ADDI` publishes `10 + 4095 = 4105`. With `uimm12=1` and `RegDst` naming the same GPR as `SrcL`, it increments that GPR by `1`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
addi SrcL, uimm, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| addi_32_2decd0a93a0a | L32 | 32 | 0x00000015 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| addi_32_2decd0a93a0a | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| addi_32_2decd0a93a0a | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| addi_32_2decd0a93a0a | uimm12 | 12 | unsigned | [{"instruction_lsb":20,"value_lsb":0,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| addi_32_2decd0a93a0a | RegDst | 5 | 0–31 | none | none | Reg5 scalar destination or discard selector | Encoded zero discards the result and does not modify any GPR or queue. |
| addi_32_2decd0a93a0a | SrcL | 5 | 0–31 | none | none | Reg5 scalar source | Encoded zero reads the architectural zero GPR. |
| addi_32_2decd0a93a0a | uimm12 | 12 | 0–4095 | none | none | unsigned 12-bit immediate | Encoded zero supplies numeric zero. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 scalar destination or discard selector |
| SrcL | Reg5 scalar source |
| uimm12 | unsigned 12-bit immediate |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/ADDI.asl -->
```asl
readonly func InstructionContractOperation_ADDI()
    => ScalarOperation
begin
    return ScalarOperation_ADDI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/ADDI.asl -->
```asl
readonly func InstructionContractHandler_ADDI()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinary;
end;

pure func InstructionContractImmediateWidth_ADDI()
    => integer {1..64}
begin
    return 12;
end;

pure func InstructionContractImmediateIsUnsigned_ADDI()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractIsWordOperation_ADDI()
    => boolean
begin
    return FALSE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL, uimm12, and RegDst are required encoded fields; no field can be omitted.
- uimm12 is an unsigned 12-bit immediate from 0 through 4095. Encoded zero supplies numeric zero.

## Legality

- All 32 SrcL encodings are assigned: 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4.
- All 32 RegDst encodings are assigned: codes 0 and 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write absolute GPRs.
- Every unsigned 12-bit immediate from 0 through 4095 is legal.

## State effects

- Zero-extend uimm12, add it to the snapshotted SrcL value modulo 2^PTO_XLEN, and publish the XLEN result through RegDst.
- Codes 1..23 write a GPR; codes 0 and 24..29 discard; code 30 pushes U; code 31 pushes T. Source queue selections are non-consuming.
- No memory, reservation, descriptor, block, privilege, or control-flow state changes other than TPC advancing by four bytes after success.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot SrcL before the destination effect. Repeated source and destination selectors therefore read the pre-instruction value.
- Successful execution publishes the result and then advances TPC by four bytes.

## Exceptions

- ADDI raises no arithmetic exception: addition wraps modulo 2^PTO_XLEN.
- A fixed-bit mismatch or unavailable selected T/U source raises Fault_IllegalInstruction before the destination effect and before TPC advances.

## Examples

- addi a0, 1, ->a0
- addi t#1, 4095, ->u
- addi zero, 0, ->zero

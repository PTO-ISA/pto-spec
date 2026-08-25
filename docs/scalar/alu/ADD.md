<!-- GENERATED FROM: asl/scalar/alu/ADD.asl -->
# ADD

**Normative ASL source:** `asl/scalar/alu/ADD.asl`

ADD applies the selected right-source transformation before its encoded logical left shift, performs fixed-width addition, and publishes the PTO_XLEN result.

## Normative identity {#PTO-INST-SCALAR-ADD}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-add-purpose role=purpose -->
## What ADD does

`ADD` is a standalone 32-bit scalar instruction that prepares its right source, adds it to the unchanged left source modulo `2^PTO_XLEN`, and publishes one XLEN result.

<!-- PTO-READER-BLOCK: scalar-add-mechanism role=mechanism -->
## How the result is formed

The instruction applies the selected `SrcRType` transformation to `SrcR`, performs the encoded logical left shift on that transformed value, and only then adds the prepared right value to `SrcL`.

- `SrcRType=00` selects signed-word extension, `01` selects unsigned-word extension, `10` selects negation for `ADD`, and `11` leaves the complete right source unchanged.
- `shamt` is a logical left-shift amount from `0` through `31`; `0` leaves the transformed value unshifted.

Negation, shifting, and addition are fixed-width operations. They wrap modulo `2^PTO_XLEN` and do not raise an arithmetic exception.

<!-- PTO-READER-BLOCK: scalar-add-inputs role=inputs-outputs -->
## Inputs and destination

- `SrcL` and `SrcR` use the full Reg5 source domain: `0..23` select GPRs, `24..27` select `T#1..T#4`, and `28..31` select `U#1..U#4`; temporary sources are read without consumption.
- `RegDst` values `1..23` write a GPR, `30` pushes U, `31` pushes T, and `0` plus `24..29` discard the result.

Every displayed field is encoded. An omitted assembly modifier denotes `SrcRType=11`; encoded `shamt=0` means no shift rather than an omitted operation.

<!-- PTO-READER-BLOCK: scalar-add-effects role=effects -->
## Effects and ordering

Both sources are snapshotted before the destination effect, so a destination alias or queue push cannot change either value consumed by the same instruction.

After computing the result, `ADD` publishes or discards it according to `RegDst`, then advances `TPC` by `4` bytes.

`ADD` does not read or write memory and does not change reservation, descriptor, numeric-status, trap, block, privilege, predicate, or control-flow state beyond the successful `TPC` advance.

<!-- PTO-READER-BLOCK: scalar-add-constraints role=constraints -->
## Legality and fault boundary

All four `SrcRType` values and all `32` shift amounts are assigned. A fixed-bit mismatch or an unavailable selected T/U source raises `Fault_IllegalInstruction` before destination publication and before `TPC` advances.

<!-- PTO-READER-BLOCK: scalar-add-example role=example -->
## Non-normative walkthrough

This walkthrough illustrates the current owner; it does not replace the normative operation above.

With `SrcL=10`, `SrcR=3`, `SrcRType=10`, and `shamt=1`, `ADD` negates the right source, shifts the result left once, and computes `10 + (-6) = 4` modulo `2^PTO_XLEN`. If the destination aliases the left GPR, the calculation still uses the original value `10`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
add SrcL, SrcR<{.sw,.uw,.neg}><<<shamt>, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| add_32_d04202886d0a | L32 | 32 | 0x00000005 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| add_32_d04202886d0a | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| add_32_d04202886d0a | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| add_32_d04202886d0a | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| add_32_d04202886d0a | SrcRType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |
| add_32_d04202886d0a | shamt | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| add_32_d04202886d0a | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| add_32_d04202886d0a | SrcL | 5 | 0–31 | none | none | left Reg5 source | Encoded zero reads the architectural zero GPR. |
| add_32_d04202886d0a | SrcR | 5 | 0–31 | none | none | right Reg5 source | Encoded zero reads the architectural zero GPR. |
| add_32_d04202886d0a | SrcRType | 2 | 0–3 | none | none | right-source transformation selector | Encoded zero selects .sw and sign-extends SrcR[31:0]. |
| add_32_d04202886d0a | shamt | 5 | 0–31 | none | none | post-transformation logical-left-shift amount | Encoded zero performs no shift. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | left Reg5 source |
| SrcR | right Reg5 source |
| SrcRType | right-source transformation selector |
| shamt | post-transformation logical-left-shift amount |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/ADD.asl -->
```asl
readonly func InstructionContractOperation_ADD()
    => ScalarOperation
begin
    return ScalarOperation_ADD;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/ADD.asl -->
```asl
readonly func InstructionContractHandler_ADD()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinary;
end;

pure func InstructionContractRightModifier_ADD(encoded: bits(2))
    => ScalarRightModifier
begin
    case encoded of
        when '00' => return ScalarRight_SignedWord;
        when '01' => return ScalarRight_UnsignedWord;
        when '10' => return ScalarRight_NegateOrNot;
        when '11' => return ScalarRight_None;
    end;
end;

pure func InstructionContractPreparedRight_ADD(
    right: Word,
    encoded_modifier: bits(2),
    shift_amount: integer {0..31})
    => Word
begin
    let modifier = InstructionContractRightModifier_ADD(encoded_modifier);
    let transformed = ApplyScalarRightModifier(right, modifier, FALSE);
    let shifted = LSL(transformed, shift_amount);
    return shifted;
end;

pure func InstructionContractResult_ADD(
    left: Word,
    right: Word,
    encoded_modifier: bits(2),
    shift_amount: integer {0..31})
    => Word
begin
    let prepared_right = InstructionContractPreparedRight_ADD(
        right,
        encoded_modifier,
        shift_amount);
    return ScalarBinary(ScalarBinary_ADD, left, prepared_right);
end;

pure func InstructionContractIsLogicalFamily_ADD()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractIsWordOperation_ADD()
    => boolean
begin
    return FALSE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL, SrcR, SrcRType, shamt, and RegDst are required encoded fields; no field can be omitted.
- SrcRType=00 selects .sw, SrcRType=01 selects .uw, SrcRType=10 selects .neg, and SrcRType=11 selects no modifier. An omitted assembly suffix encodes SrcRType=11.
- Encoded shamt zero performs no shift; every value from 0 through 31 is assigned.

## Legality

- SrcL and SrcR codes 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consumption.
- RegDst codes 0 and 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write GPRs.
- All four SrcRType encodings are assigned. The logical family uses .not while the arithmetic family uses .neg; ADD uses .neg.
- Every five-bit shamt value from 0 through 31 is legal.

## State effects

- Transform SrcR, perform the logical left shift, and add the shifted value to SrcL modulo 2^PTO_XLEN.
- Apply the selected SrcRType transformation before the logical left shift. The transformation and shift affect SrcR only; SrcL is unchanged before the final operation.
- Destination codes 0 and 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write GPRs; source queues are non-consuming.
- No memory, reservation, descriptor, numeric-flag, trap, block, privilege, or control-flow state changes except the successful TPC advance.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot both sources before the destination effect so duplicate sources, destination aliases, and queue publication use pre-instruction values.
- Publish the result, then advance TPC by four bytes.

## Exceptions

- ADD raises no arithmetic exception; negation, shifting, and addition wrap modulo 2^PTO_XLEN.
- A fixed-bit mismatch or unavailable selected T/U source raises Fault_IllegalInstruction before the destination effect and before TPC advances.

## Examples

- add a0, a1, ->a2
- add t#1, u#1.neg<<1, ->u
- add zero, a0.sw, ->zero

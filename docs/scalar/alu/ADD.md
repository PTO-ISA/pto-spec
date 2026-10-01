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

`ADD` prepares a right source, adds it to an unchanged left source at `PTO_XLEN` width, and publishes the sum through a Reg5 destination. `PTO_XLEN` is `64`, so the published value is one 64-bit word.

Design point: `ADD` shares its five encoded fields with `AND`, `OR`, `XOR` and with the `W` word forms of those mnemonics. One field layout means one decoder and one operand-legality check serve the whole family, and the mnemonic alone selects both the element operation and, for `SrcRType=10`, whether that modifier means negation or bitwise complement.

<!-- PTO-READER-BLOCK: scalar-add-mechanism role=mechanism -->
## How the result is formed

Execution prepares the right source in two ordered steps, then adds.

- `SrcRType` transforms `SrcR`: `00` sign-extends `SrcR[31:0]`, `01` zero-extends `SrcR[31:0]`, `10` negates the complete value, and `11` leaves it unchanged. An omitted assembly suffix encodes `SrcRType=11`.
- `shamt` then shifts the transformed value logically left by `0` through `31` bits.

The prepared right value is added to the snapshotted `SrcL` modulo `2^PTO_XLEN`, so the sum wraps and no arithmetic exception is raised.

Design point: the shift applies to the right operand, not to the sum. The single encoding `add a0, a1.neg<<3, ->a0` therefore computes `a0 - 8*a1`, and `add a0, a1<<4` adds sixteen times the right source.

Design point: negation is `Zeros - value` at XLEN width, so negating the most negative word returns that same word. The instruction has no overflow or saturation form to select.

<!-- PTO-READER-BLOCK: scalar-add-inputs role=inputs-outputs -->
## Inputs and destination

- `SrcL` and `SrcR` are Reg5 sources: `0..23` read absolute GPRs, `24..27` read `T#1..T#4`, and `28..31` read `U#1..U#4`. Reading a temporary source does not consume it.
- `RegDst` publishes the result: `1..23` write that GPR, `30` pushes `U`, `31` pushes `T`, and `0` together with `24..29` discard it.

Design point: destination code `0` discards rather than writing the zero GPR, and codes `24..29` discard even though `24..27` name T sources. The same five-bit field is therefore not symmetric between reads and writes.

Design point: encoded zero of `SrcL` or `SrcR` reads the architectural zero GPR, so `add zero, a0, ->a1` is an ordinary copy. No field can be omitted from the encoding; the assembly suffix is the only optional spelling.

<!-- PTO-READER-BLOCK: scalar-add-effects role=effects -->
## Effects and ordering

Both sources are read before the destination is written, so `add a0, a0, ->a0` and a destination that aliases a source both use the pre-instruction values.

After the sum is published or discarded, `TPC` advances by `4` bytes. Nothing else changes. `ADD` reads and writes no memory, and it leaves reservation, descriptor, numeric-status, trap, bundle, privilege, predicate and control-flow state untouched apart from the one `T` or `U` push selected by `RegDst`.

<!-- PTO-READER-BLOCK: scalar-add-constraints role=constraints -->
## Legality and fault boundary

Every encoded value is assigned: all four `SrcRType` codes and all `32` `shamt` values from `0` through `31` are legal, so `ADD` has no reserved encoding of its own.

The checks run in a fixed order before any result exists. An undecodable form raises `Fault_IllegalInstruction` at `PC`; an instruction that is not applicable to the active block raises `Fault_BundleControl` at `TPC`; a fixed-bit mismatch or an unavailable selected T/U source raises `Fault_IllegalInstruction`. After any fault the destination is not written and `TPC` stays at the faulting instruction, so a reissue recomputes address, sources and result with no retained progress.

Design point: source availability is checked before the sources are read. That is why `add t#1, a0, ->a0` on an empty T queue faults instead of reading an undefined value: the check turns an uninitialized temporary into a defined trap.

<!-- PTO-READER-BLOCK: scalar-add-example role=example -->
## Non-normative walkthrough

This walkthrough illustrates the current owner; it does not replace the normative operation above.

With `SrcL=10`, `SrcR=3`, `SrcRType=10` and `shamt=1`, `ADD` first negates the right source to `-3`, then shifts it left once to `-6`, and finally computes `10 + (-6) = 4` modulo `2^PTO_XLEN`. The published word is `4`.
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

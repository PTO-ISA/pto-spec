<!-- GENERATED FROM: asl/scalar/alu/XOR.asl -->
# XOR

**Normative ASL source:** `asl/scalar/alu/XOR.asl`

XOR applies the selected right-source transformation before its encoded logical left shift, performs bitwise exclusive OR, and publishes the PTO_XLEN result.

## Normative identity {#PTO-INST-SCALAR-XOR}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-xor-purpose role=purpose -->
## What XOR computes

`XOR` is a 32-bit scalar ALU form. It combines the left source `SrcL` with a prepared copy of the right source `SrcR` using a bitwise exclusive OR, and publishes the result through `RegDst`.

The combination happens at the full `PTO_XLEN` width of 64 bits, and the result is truncated there. `XOR` reads no memory and raises no arithmetic exception, so apart from `RegDst` its only architectural effect is the `TPC` advance of `4` bytes.

Design point: `XOR` is the exclusive-OR member of the register logical family and shares its operand layout with `AND`, `OR` and the other register forms that also carry the `SrcRType` and `shamt` fields; the decoded mnemonic selects the operation, not the operand shape.

<!-- PTO-READER-BLOCK: scalar-xor-mechanism role=mechanism -->
## Preparing the right source, then combining

Execution reads `SrcL` and `SrcR`, transforms `SrcR` according to the 2-bit `SrcRType` field, shifts that value left by the 5-bit `shamt` amount, and only then performs the exclusive OR and writes the destination.

| `SrcRType` | Assembly suffix | Effect on `SrcR` before the shift |
| --- | --- | --- |
| `00` | `.sw` | sign-extend `SrcR[31:0]` to `PTO_XLEN` |
| `01` | `.uw` | zero-extend `SrcR[31:0]` to `PTO_XLEN` |
| `10` | `.not` | complement all `PTO_XLEN` bits |
| `11` | omitted | leave `SrcR` unchanged |

Design point: both steps act on `SrcR` alone and the transformation runs first, so they cannot be exchanged. With `SrcR=0x000000000000000f`, `.not` then a shift of `4` gives `0xffffffffffffff00`; a shift of `4` then `.not` would give `0xffffffffffffff0f`.

Design point: `.not` complements all 64 bits rather than the low word, because the logical family requests the complement reading while the arithmetic family gives the same encoding the negate reading. With `SrcR=0x0000000000000001`, `.not` prepares `0xfffffffffffffffe`, never `0x00000000fffffffe`.

<!-- PTO-READER-BLOCK: scalar-xor-inputs role=inputs-outputs -->
## Encoded operands

- `RegDst` is a 5-bit field at instruction bits `7..11`: codes `1..23` write that absolute GPR, code `0` and codes `24..29` discard, code `30` pushes the U queue and code `31` pushes the T queue.
- `SrcL` is a 5-bit field at bits `15..19` and `SrcR` at bits `20..24`. Codes `0..23` read absolute GPRs, `24..27` read `T#1..T#4` and `28..31` read `U#1..U#4`.
- `SrcRType` is a 2-bit field at bits `25..26`; `shamt` is a 5-bit field at bits `27..31` and encodes the left shift applied after the transformation.

A queue source is read without being consumed, and source code `0` always reads zero. `XOR` touches no memory, so it has no address operand, no ordering bit and no `far` field.

Design point: an omitted `.sw`, `.uw` or `.not` suffix encodes `SrcRType=11`, meaning "leave the source unchanged" rather than the sign-extending `.sw`. A plain `xor a0, a1, ->a2` therefore uses all 64 bits of `a1` exactly as written.

<!-- PTO-READER-BLOCK: scalar-xor-effects role=effects -->
## Destination and ordering

Both sources are read before the destination is written, and the published value is computed from those pre-instruction values.

Design point: because the reads complete first, `xor a0, a1, ->a0` publishes the exclusive OR of the old `a0` and `a1`, and `xor a0, a0, ->a1` publishes zero whatever `a0` held. No destination alias can change which operand values were combined.

A successful execution advances `TPC` by `4` bytes. No memory location, reservation, descriptor, numeric flag, trap, block, privilege or control-flow state is touched by `XOR`.

<!-- PTO-READER-BLOCK: scalar-xor-constraints role=constraints -->
## Legality and the fault boundary

Every `SrcRType` encoding and every `shamt` value from `0` through `31` is assigned, and so is every source and destination code, so `XOR` has no reserved field value. The operands are combined modulo `2^PTO_XLEN`: a carry out of the top bit is discarded and no arithmetic exception is raised.

Before any effect the form is decoded, its encoded fields are checked, and each selected T/U source must hold a valid queue entry. An encoding that belongs to no form, or an unavailable `T#1..T#4` or `U#1..U#4` entry, raises `Fault_IllegalInstruction` before the destination is written and before `TPC` advances.

Design point: `XOR` forms no address, so it can raise neither an alignment fault nor an access fault. After a successful decode, applicability is checked first: while the system-block terminal marker `_SystemBlockTerminalPending` is set, that check rejects any scalar operation with `Fault_BundleControl`. Apart from that, the remaining reason to reject `XOR` is operand availability, and that check happens before the destination write, so an unavailable queue source rejects the instruction instead of reading an undefined value.

<!-- PTO-READER-BLOCK: scalar-xor-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

With `SrcL=0xc`, `SrcR=0xa`, `SrcRType=11` and `shamt=0` the right source is neither transformed nor shifted, so the instruction publishes `0xc XOR 0xa = 0x6`.

A second case shows the order. With `SrcL=0x00000000000000ff`, `SrcR=0x000000000000000f`, `SrcRType=10` (`.not`) and `shamt=4`, the complement of `0x000000000000000f` is `0xfffffffffffffff0`, the left shift gives `0xffffffffffffff00`, and the exclusive OR publishes `0xffffffffffffffff`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
xor SrcL, SrcR<{.sw,.uw,.not}><<<shamt>, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| xor_32_33510860c585 | L32 | 32 | 0x00004005 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| xor_32_33510860c585 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| xor_32_33510860c585 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| xor_32_33510860c585 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| xor_32_33510860c585 | SrcRType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |
| xor_32_33510860c585 | shamt | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| xor_32_33510860c585 | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| xor_32_33510860c585 | SrcL | 5 | 0–31 | none | none | left Reg5 source | Encoded zero reads the architectural zero GPR. |
| xor_32_33510860c585 | SrcR | 5 | 0–31 | none | none | right Reg5 source | Encoded zero reads the architectural zero GPR. |
| xor_32_33510860c585 | SrcRType | 2 | 0–3 | none | none | right-source transformation selector | Encoded zero selects .sw and sign-extends SrcR[31:0]. |
| xor_32_33510860c585 | shamt | 5 | 0–31 | none | none | post-transformation logical-left-shift amount | Encoded zero performs no shift. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | left Reg5 source |
| SrcR | right Reg5 source |
| SrcRType | right-source transformation selector |
| shamt | post-transformation logical-left-shift amount |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/XOR.asl -->
```asl
readonly func InstructionContractOperation_XOR()
    => ScalarOperation
begin
    return ScalarOperation_XOR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/XOR.asl -->
```asl
readonly func InstructionContractHandler_XOR()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinary;
end;

pure func InstructionContractRightModifier_XOR(encoded: bits(2))
    => ScalarRightModifier
begin
    case encoded of
        when '00' => return ScalarRight_SignedWord;
        when '01' => return ScalarRight_UnsignedWord;
        when '10' => return ScalarRight_NegateOrNot;
        when '11' => return ScalarRight_None;
    end;
end;

pure func InstructionContractPreparedRight_XOR(
    right: Word,
    encoded_modifier: bits(2),
    shift_amount: integer {0..31})
    => Word
begin
    let modifier = InstructionContractRightModifier_XOR(encoded_modifier);
    let transformed = ApplyScalarRightModifier(right, modifier, TRUE);
    let shifted = LSL(transformed, shift_amount);
    return shifted;
end;

pure func InstructionContractResult_XOR(
    left: Word,
    right: Word,
    encoded_modifier: bits(2),
    shift_amount: integer {0..31})
    => Word
begin
    let prepared_right = InstructionContractPreparedRight_XOR(
        right,
        encoded_modifier,
        shift_amount);
    return ScalarBinary(ScalarBinary_XOR, left, prepared_right);
end;

pure func InstructionContractIsLogicalFamily_XOR()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractIsWordOperation_XOR()
    => boolean
begin
    return FALSE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL, SrcR, SrcRType, shamt, and RegDst are required encoded fields; no field can be omitted.
- SrcRType=00 selects .sw, SrcRType=01 selects .uw, SrcRType=10 selects .not, and SrcRType=11 selects no modifier. An omitted assembly suffix encodes SrcRType=11.
- Encoded shamt zero performs no shift; every value from 0 through 31 is assigned.

## Legality

- SrcL and SrcR codes 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consumption.
- RegDst codes 0 and 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write GPRs.
- All four SrcRType encodings are assigned. The logical family uses .not while the arithmetic family uses .neg; XOR uses .not.
- Every five-bit shamt value from 0 through 31 is legal.

## State effects

- Transform SrcR, perform the logical left shift, and compute the bitwise exclusive OR with SrcL at PTO_XLEN width modulo 2^PTO_XLEN.
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

- XOR raises no arithmetic exception; transformation, shifting, and the final operation use PTO_XLEN bits modulo 2^PTO_XLEN.
- A fixed-bit mismatch or unavailable selected T/U source raises Fault_IllegalInstruction before the destination effect and before TPC advances.

## Examples

- xor a0, a1, ->a2
- xor t#1, u#1.not<<1, ->u
- xor zero, a0.sw, ->zero

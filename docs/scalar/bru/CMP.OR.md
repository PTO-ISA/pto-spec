<!-- GENERATED FROM: asl/scalar/bru/CMP.OR.asl -->
# CMP.OR

**Normative ASL source:** `asl/scalar/bru/CMP.OR.asl`

CMP.OR - Combine scalar comparison results with the encoded logical operation.

## Normative identity {#PTO-INST-SCALAR-CMP-OR}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-cmp-or-purpose role=purpose -->
## What CMP.OR does

`CMP.OR` combines the two operand values with a bitwise OR and writes the canonical XLEN boolean `1` when the combined value is nonzero and `0` when it is zero.

It is a comparison in result shape only. The value written does not report a relation between the operands; it reports whether the OR of them is all zeros.

<!-- PTO-READER-BLOCK: scalar-cmp-or-mechanism role=mechanism -->
## Mechanism

The contract returns `ScalarHandler_ExecuteCompareLogical` with the operation OR. The model applies the `SrcRType` transformation to the `SrcR` snapshot before the combination. Value `0` leaves the complete value unchanged, `1` substitutes the sign-extended low `32` bits, `2` substitutes the zero-extended low `32` bits, and `3` substitutes the bitwise complement.

The handler then takes the left source and the prepared right value, computes `left OR right`, and writes `Zeros{PTO_XLEN} + 1` when the logical result is nonzero and `Zeros{PTO_XLEN}` when it is zero. No other state is read or written.

Design point: the two operands are combined first and tested second, so the instruction cannot reveal anything about one operand alone. That is why a mask test such as "does this value have any of these bits" needs one instruction instead of a compare followed by a branch on two results.

<!-- PTO-READER-BLOCK: scalar-cmp-or-inputs-outputs role=inputs-outputs -->
## Inputs and output

- `SrcL` supplies the left absolute GPR source and `SrcR` supplies the right absolute GPR source.
- `SrcRType` selects the right-source transformation.

`RegDst` names the destination: codes `1..23` write the named absolute GPR, code `0` and codes `24..29` discard the result, code `30` pushes it to the `U` queue, and code `31` pushes it to the `T` queue.

Encoded zero in `SrcL` names the architectural zero GPR. Sources are read as values and are not consumed.

<!-- PTO-READER-BLOCK: scalar-cmp-or-effects role=effects -->
## Effects and ordering

On success the instruction writes exactly one destination value and advances `TPC` by `4` bytes, the encoded length of the `32`-bit form.

It has no memory effect, no reservation effect, no descriptor effect, and no numeric status flag. It leaves the commit argument, the block argument, and the block condition marker unchanged, because it is not a condition setter.

Design point: `CMP.OR` is not an alias of `OR`. `OR` writes the combined XLEN value, while `CMP.OR` writes the canonical boolean that reports whether that value is nonzero, so the two forms are not interchangeable when the combined bits themselves are needed later.

<!-- PTO-READER-BLOCK: scalar-cmp-or-constraints role=constraints -->
## Legality and fault order

Decode runs first, and a fixed-bit mismatch raises `Fault_IllegalInstruction` at the instruction address before any effect.

All `32` encodings of `SrcL`, `SrcR`, and `RegDst` are assigned, and all four `SrcRType` values decode to a defined transformation, so no register or modifier encoding is reserved.

A selected `T` or `U` source that is not available is rejected during operand legality, before the destination is written. A rejected instruction changes neither the destination nor `TPC`, and trap entry saves the original `TPC` so it can be reissued.

<!-- PTO-READER-BLOCK: scalar-cmp-or-example role=example -->
## Non-normative example

Set GPR1 to `5` and GPR2 to `9`.

`cmp.or 1, 2, ->0` computes `5 OR 9`, which is `13`, so it writes `1` into the destination. With both sources set to `0` the same form writes `0`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
cmp.or SrcL, SrcR<.sw, .uw, .not>, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| cmp_or_32_75e1fa54ba94 | L32 | 32 | 0x00003045 / 0xf800707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| cmp_or_32_75e1fa54ba94 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| cmp_or_32_75e1fa54ba94 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| cmp_or_32_75e1fa54ba94 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| cmp_or_32_75e1fa54ba94 | SrcRType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| cmp_or_32_75e1fa54ba94 | RegDst | 5 | 0–31 | none | none | absolute GPR destination | Encoded zero names the architectural zero GPR. |
| cmp_or_32_75e1fa54ba94 | SrcL | 5 | 0–31 | none | none | left absolute GPR source | Encoded zero names the architectural zero GPR. |
| cmp_or_32_75e1fa54ba94 | SrcR | 5 | 0–31 | none | none | right absolute GPR source | Encoded zero names the architectural zero GPR. |
| cmp_or_32_75e1fa54ba94 | SrcRType | 2 | 0–3 | none | none | right-source modifier selector | Encoded zero selects value zero of the right-source modifier selector. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | absolute GPR destination |
| SrcL | left absolute GPR source |
| SrcR | right absolute GPR source |
| SrcRType | right-source modifier selector |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/bru/CMP.OR.asl -->
```asl
readonly func InstructionContractOperation_CMP_OR() => ScalarOperation
begin
    return ScalarOperation_CMP_OR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/bru/CMP.OR.asl -->
```asl
readonly func InstructionContractHandler_CMP_OR() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteCompareLogical;
end;

pure func InstructionContractCombinesWithOR_CMP_OR()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractCompareLogicalValue_CMP_OR(
    left: Word,
    right: Word)
    => Word
begin
    if InstructionContractCombinesWithOR_CMP_OR() then
        return left OR right;
    end;
    return left AND right;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- The selected assembly form determines which fields are present; every present field carries its encoded value and no encoded zero means omission.

## Legality

- Every value in each unconstrained encoded field is assigned; constrained complements are reserved and reject before effects.

## State effects

- CMP.OR - Combine scalar comparison results with the encoded logical operation.
- After decode and legality checks, execute the normative ExecuteCompareLogical ASL handler; no other architectural state is modified.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- none

## Exceptions

- Reserved field encodings raise Fault_IllegalInstruction before effects; handler-specific arithmetic, memory, control-flow, system-register, and privilege faults follow the embedded normative ASL operation.

## Examples

- cmp.or SrcL, SrcR<.sw, .uw, .not>, ->{t, u, Rd}

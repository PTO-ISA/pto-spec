<!-- GENERATED FROM: asl/scalar/alu/C.OR.asl -->
# C.OR

**Normative ASL source:** `asl/scalar/alu/C.OR.asl`

C.OR snapshots two complete Reg5 sources, computes the bitwise inclusive OR of SrcL and SrcR, and pushes the wrapping XLEN result to T.

## Normative identity {#PTO-INST-SCALAR-C-OR}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
c.or srcL, srcR, ->t
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| c_or_16_90864d13a661 | C16 | 16 | 0x0038 / 0x003f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| c_or_16_90864d13a661 | SrcL | 5 | encoding-defined | [{"instruction_lsb":6,"value_lsb":0,"width":5}] |
| c_or_16_90864d13a661 | SrcR | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| c_or_16_90864d13a661 | SrcL | 5 | 0–31 | none | none | left Reg5 source | Encoded zero reads the architectural zero GPR. |
| c_or_16_90864d13a661 | SrcR | 5 | 0–31 | none | none | right Reg5 source | Encoded zero reads the architectural zero GPR. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | left Reg5 source |
| SrcR | right Reg5 source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/C.OR.asl -->
```asl
readonly func InstructionContractOperation_C_OR() => ScalarOperation
begin
    return ScalarOperation_C_OR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/C.OR.asl -->
```asl
readonly func InstructionContractHandler_C_OR() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinary;
end;

pure func InstructionContractResult_C_OR(
    left: Word,
    right: Word)
    => Word
begin
    return ScalarBinary(
        ScalarBinary_OR,
        left,
        right);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL and SrcR are required encoded fields; neither source can be omitted.
- The destination is not encoded: every successful form pushes exactly one result to T.

## Legality

- Each source code 0..23 selects an absolute GPR, 24..27 selects T#1..T#4, and 28..31 selects U#1..U#4 without consumption.
- Duplicate, absolute-relative, and relative-relative source pairs are legal. Every encoded source value is assigned.

## State effects

- Compute bitwise OR on the two complete XLEN source values.
- Push exactly one XLEN result to T. Existing T entries shift toward older indices, the former T#4 is discarded, and no source is consumed.
- No GPR, U queue, memory, reservation, descriptor, numeric-status, block, privilege, predicate, or other control state changes. Successful execution advances TPC by two bytes.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot both sources before pushing the destination so aliases observe the pre-instruction queue state.
- Push the result as the newest T entry, then advance TPC by two bytes.

## Exceptions

- Bitwise or is a total fixed-width operation and raises no arithmetic exception.
- An unavailable selected T/U source raises Fault_IllegalInstruction before the T push, before TPC advances, and before any other effect.

## Examples

- c.or t#1, u#1, ->t

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->

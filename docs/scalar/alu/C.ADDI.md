<!-- GENERATED FROM: asl/scalar/alu/C.ADDI.asl -->
# C.ADDI

**Normative ASL source:** `asl/scalar/alu/C.ADDI.asl`

C.ADDI snapshots one complete Reg5 source, sign-extends simm5, adds modulo 2^XLEN, and pushes the result to T.

## Normative identity {#PTO-INST-SCALAR-C-ADDI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
c.addi srcL, simm, ->t
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| c_addi_16_3050744f2322 | C16 | 16 | 0x000c / 0x003f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| c_addi_16_3050744f2322 | SrcL | 5 | encoding-defined | [{"instruction_lsb":6,"value_lsb":0,"width":5}] |
| c_addi_16_3050744f2322 | simm5 | 5 | signed | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| c_addi_16_3050744f2322 | SrcL | 5 | 0–31 | none | none | Reg5 addend | Encoded zero reads the architectural zero GPR. |
| c_addi_16_3050744f2322 | simm5 | 5 | 0–31 | none | none | signed five-bit addend | Encoded zero supplies numeric zero. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 addend |
| simm5 | signed five-bit addend |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/C.ADDI.asl -->
```asl
readonly func InstructionContractOperation_C_ADDI() => ScalarOperation
begin
    return ScalarOperation_C_ADDI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/C.ADDI.asl -->
```asl
readonly func InstructionContractHandler_C_ADDI() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinary;
end;

pure func InstructionContractResult_C_ADDI(
    left: Word,
    encoded_immediate: bits(5))
    => Word
begin
    let immediate = SignExtend{PTO_XLEN}(encoded_immediate);
    return ScalarBinary(
        ScalarBinary_ADD,
        left,
        immediate);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL and signed simm5 are required encoded fields; neither can be omitted.
- The destination is not encoded: every successful form pushes exactly one result to T.

## Legality

- SrcL codes 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consumption.
- Every simm5 encoding is assigned and denotes a signed integer from -16 through +15.

## State effects

- Sign-extend simm5 to XLEN and add it to SrcL modulo 2^PTO_XLEN.
- Push exactly one XLEN result to T without consuming the source. Existing T entries shift toward older indices.
- No GPR, U queue, memory, reservation, descriptor, numeric-status, block, privilege, predicate, or other control state changes. Successful execution advances TPC by two bytes.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot SrcL and sign-extend simm5 before pushing the destination.
- Push the result as the newest T entry, then advance TPC by two bytes.

## Exceptions

- Fixed-width addition is total and raises no arithmetic exception.
- An unavailable selected T/U source raises Fault_IllegalInstruction before the T push, before TPC advances, and before any other effect.

## Examples

- c.addi t#1, -1, ->t

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->

<!-- GENERATED FROM: asl/scalar/alu/C.SEXT.W.asl -->
# C.SEXT.W

**Normative ASL source:** `asl/scalar/alu/C.SEXT.W.asl`

C.SEXT.W sign-extends SrcL[31:0] to XLEN and pushes the result to T.

## Normative identity {#PTO-INST-SCALAR-C-SEXT-W}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
c.sext.w srcL, ->t
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| c_sext_w_16_f2bb13f0797b | C16 | 16 | 0x501c / 0xf83f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| c_sext_w_16_f2bb13f0797b | SrcL | 5 | encoding-defined | [{"instruction_lsb":6,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| c_sext_w_16_f2bb13f0797b | SrcL | 5 | 0–31 | none | none | Reg5 source | Encoded zero reads the architectural zero GPR. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/C.SEXT.W.asl -->
```asl
readonly func InstructionContractOperation_C_SEXT_W() => ScalarOperation
begin
    return ScalarOperation_C_SEXT_W;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/C.SEXT.W.asl -->
```asl
readonly func InstructionContractHandler_C_SEXT_W() => ScalarSemanticHandler
begin
    return ScalarHandler_ExtendScalarValue;
end;

pure func InstructionContractResult_C_SEXT_W(value: Word)
    => Word
begin
    return ExtendScalarValue(
        value,
        32,
        TRUE);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Every encoded source, immediate, and explicit destination field is required; no field can be omitted.
- The mnemonic fixes immediate signedness, selected source width, and implicit-versus-explicit destination behavior.

## Legality

- SrcL codes 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consumption.
- The compressed form has no destination field and always pushes exactly one result to T.
- Every encoded operand value is assigned; fixed encoding bits must match the canonical form.

## State effects

- Sign-extend source bit 31 through the XLEN result.
- Push the complete XLEN result to T. The source queue is non-consuming, and no explicit destination encoding exists.
- No memory, reservation, descriptor, numeric-status, block, privilege, branch-target, or other control state changes. Successful execution advances TPC by two bytes.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot any Reg5 source before the destination effect.
- Publish the result, then advance TPC by the encoded instruction length.

## Exceptions

- Materialization, movement, and extension are total fixed-width operations and raise no arithmetic exception.
- An unavailable selected T/U source raises Fault_IllegalInstruction before the destination effect and before TPC advances.

## Examples

- c.sext.w srcl, ->t

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->

<!-- GENERATED FROM: asl/scalar/alu/C.MOVR.asl -->
# C.MOVR

**Normative ASL source:** `asl/scalar/alu/C.MOVR.asl`

C.MOVR snapshots a Reg5 source and publishes the complete XLEN value unchanged through RegDst.

## Normative identity {#PTO-INST-SCALAR-C-MOVR}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
c.movr SrcL, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| c_movr_16_80d2b5f3580b | C16 | 16 | 0x0006 / 0x003f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| c_movr_16_80d2b5f3580b | RegDst | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| c_movr_16_80d2b5f3580b | SrcL | 5 | encoding-defined | [{"instruction_lsb":6,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| c_movr_16_80d2b5f3580b | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| c_movr_16_80d2b5f3580b | SrcL | 5 | 0–31 | none | none | Reg5 source | Encoded zero reads the architectural zero GPR. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | Reg5 source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/C.MOVR.asl -->
```asl
readonly func InstructionContractOperation_C_MOVR() => ScalarOperation
begin
    return ScalarOperation_C_MOVR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/C.MOVR.asl -->
```asl
readonly func InstructionContractHandler_C_MOVR() => ScalarSemanticHandler
begin
    return ScalarHandler_MoveScalarValue;
end;

pure func InstructionContractResult_C_MOVR(value: Word)
    => Word
begin
    return MoveScalarValue(value);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Every encoded source, immediate, and explicit destination field is required; no field can be omitted.
- The mnemonic fixes immediate signedness, selected source width, and implicit-versus-explicit destination behavior.

## Legality

- SrcL codes 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consumption.
- RegDst codes 0 and 24..29 discard, codes 1..23 write GPRs, code 30 pushes U, and code 31 pushes T.
- Every encoded operand value is assigned; fixed encoding bits must match the canonical form.

## State effects

- Return the complete snapshotted SrcL value without conversion.
- Publish the complete XLEN result through the common Reg5 destination map. Relative sources are non-consuming; only a T or U destination push changes a temporary queue.
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

- c.movr srcl, ->{t, u, rd}

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->

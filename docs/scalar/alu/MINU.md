<!-- GENERATED FROM: asl/scalar/alu/MINU.asl -->
# MINU

**Normative ASL source:** `asl/scalar/alu/MINU.asl`

MINU performs an unsigned full-XLEN comparison and publishes the complete bit pattern of the minimum operand.

## Normative identity {#PTO-INST-SCALAR-MINU}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
minu SrcL, SrcR, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| minu_32_9bdb71ef7b19 | L32 | 32 | 0x0800505b / 0xfe00707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| minu_32_9bdb71ef7b19 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| minu_32_9bdb71ef7b19 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| minu_32_9bdb71ef7b19 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| minu_32_9bdb71ef7b19 | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| minu_32_9bdb71ef7b19 | SrcL | 5 | 0–31 | none | none | left Reg5 source | Encoded zero reads the architectural zero GPR. |
| minu_32_9bdb71ef7b19 | SrcR | 5 | 0–31 | none | none | right Reg5 source | Encoded zero reads the architectural zero GPR. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | left Reg5 source |
| SrcR | right Reg5 source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/MINU.asl -->
```asl
readonly func InstructionContractOperation_MINU()
    => ScalarOperation
begin
    return ScalarOperation_MINU;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/MINU.asl -->
```asl
readonly func InstructionContractHandler_MINU()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinary;
end;

pure func InstructionContractResult_MINU(left: Word, right: Word)
    => Word
begin
    if UInt(left) < UInt(right) then
        return left;
    else
        return right;
    end;
end;

pure func InstructionContractUsesSignedComparison_MINU()
    => boolean
begin
    return FALSE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL, SrcR, and RegDst are required fields; no field can be omitted.
- Encoded source zero reads the architectural zero GPR; encoded destination zero discards the result.

## Legality

- SrcL and SrcR codes 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consumption.
- RegDst codes 0 and 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write GPRs.
- The operands use an unsigned full-XLEN comparison; every XLEN bit pattern is legal.

## State effects

- Perform an unsigned full-XLEN comparison and return the complete bit pattern of the minimum operand; equal operands are observationally identical.
- Destination codes 0 and 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write GPRs; source queues are non-consuming.
- No memory, reservation, descriptor, numeric-flag, trap, block, privilege, or control-flow state changes except the successful TPC advance.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot both sources before the destination effect so repeated sources, destination aliases, and queue publication use pre-instruction values.
- Publish the selected operand, then advance TPC by four bytes.

## Exceptions

- MINU raises no arithmetic exception; comparison selects one unchanged operand bit pattern.
- Bits 31:25 are fixed by the accepted form. A mismatch or unavailable T/U source raises Fault_IllegalInstruction before the destination effect and TPC advance.

## Examples

- minu a0, a1, ->a2
- minu t#1, u#1, ->u
- minu zero, zero, ->zero

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->

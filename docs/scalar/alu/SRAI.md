<!-- GENERATED FROM: asl/scalar/alu/SRAI.asl -->
# SRAI

**Normative ASL source:** `asl/scalar/alu/SRAI.asl`

SRAI performs an XLEN arithmetic right shift by a six-bit immediate.

## Normative identity {#PTO-INST-SCALAR-SRAI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
srai SrcL, shamt, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| srai_32_e471ea84d4fd | L32 | 32 | 0x00006015 / 0xfc00707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| srai_32_e471ea84d4fd | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| srai_32_e471ea84d4fd | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| srai_32_e471ea84d4fd | shamt | 6 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":6}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| srai_32_e471ea84d4fd | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| srai_32_e471ea84d4fd | SrcL | 5 | 0–31 | none | none | Reg5 source | Encoded zero reads the architectural zero GPR. |
| srai_32_e471ea84d4fd | shamt | 6 | 0–63 | none | none | six-bit shift amount | Encoded zero performs no shift. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | Reg5 source |
| shamt | six-bit shift amount |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/SRAI.asl -->
```asl
readonly func InstructionContractOperation_SRAI()
    => ScalarOperation
begin
    return ScalarOperation_SRAI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/SRAI.asl -->
```asl
readonly func InstructionContractHandler_SRAI()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinary;
end;

pure func InstructionContractShiftWidth_SRAI()
    => integer {1..64}
begin
    return 6;
end;

pure func InstructionContractIsWordOperation_SRAI()
    => boolean
begin
    return FALSE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL, shamt, and RegDst are required fields; no field can be omitted.
- shamt is a 6-bit shift amount from 0 through 63. Encoded zero performs an identity shift.

## Legality

- SrcL codes 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consumption.
- RegDst codes 0 and 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write GPRs.
- Every 6-bit shift amount from 0 through 63 is legal.

## State effects

- Compute the XLEN arithmetic right shift ASR(SrcL, shamt), inserting copies of the source sign bit at the left.
- Destination codes 0 and 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write GPRs; source queues are non-consuming.
- No memory, reservation, descriptor, flag, block, privilege, or control-flow state changes except the successful TPC advance.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot SrcL before the destination effect so aliases read the pre-instruction value.
- Publish the result, then advance TPC by four bytes.

## Exceptions

- SRAI raises no arithmetic exception; shifted-out bits are discarded and copies of SrcL[PTO_XLEN-1] enter from the left.
- Bits 31:26 are fixed zero. A mismatch or unavailable T/U source raises Fault_IllegalInstruction before the destination effect and TPC advance.

## Examples

- srai a0, 1, ->a0
- srai t#1, 63, ->u
- srai zero, 0, ->zero

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->

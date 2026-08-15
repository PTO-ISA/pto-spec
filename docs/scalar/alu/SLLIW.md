<!-- GENERATED FROM: asl/scalar/alu/SLLIW.asl -->
# SLLIW

**Normative ASL source:** `asl/scalar/alu/SLLIW.asl`

SLLIW performs a word logical left shift and sign-extends the result.

## Normative identity {#PTO-INST-SCALAR-SLLIW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
slliw SrcL, shamt, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| slliw_32_c6bf463b97ae | L32 | 32 | 0x00007035 / 0xfe00707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| slliw_32_c6bf463b97ae | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| slliw_32_c6bf463b97ae | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| slliw_32_c6bf463b97ae | shamt | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| slliw_32_c6bf463b97ae | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| slliw_32_c6bf463b97ae | SrcL | 5 | 0–31 | none | none | Reg5 source; low 32 bits used | Encoded zero reads the architectural zero GPR. |
| slliw_32_c6bf463b97ae | shamt | 5 | 0–31 | none | none | five-bit shift amount | Encoded zero performs no shift. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | Reg5 source; low 32 bits used |
| shamt | five-bit shift amount |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/SLLIW.asl -->
```asl
readonly func InstructionContractOperation_SLLIW()
    => ScalarOperation
begin
    return ScalarOperation_SLLIW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/SLLIW.asl -->
```asl
readonly func InstructionContractHandler_SLLIW()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinaryW;
end;

pure func InstructionContractShiftWidth_SLLIW()
    => integer {1..64}
begin
    return 5;
end;

pure func InstructionContractIsWordOperation_SLLIW()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL, shamt, and RegDst are required fields; no field can be omitted.
- shamt is a 5-bit shift amount from 0 through 31. Encoded zero performs an identity word shift.

## Legality

- SrcL codes 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consumption.
- RegDst codes 0 and 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write GPRs.
- Every 5-bit shift amount from 0 through 31 is legal; source bits above bit 31 do not participate.

## State effects

- Compute the 32-bit logical left shift LSL(SrcL[31:0], shamt), then publish the 32-bit result sign-extended to XLEN.
- Destination codes 0 and 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write GPRs; source queues are non-consuming.
- No memory, reservation, descriptor, flag, block, privilege, or control-flow state changes except the successful TPC advance.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot SrcL before the destination effect so aliases read the pre-instruction value.
- Publish the sign-extended word result, then advance TPC by four bytes.

## Exceptions

- SLLIW raises no arithmetic exception; shifted-out word bits are discarded and the final word is sign-extended to XLEN.
- Bits 31:25 are fixed zero. A mismatch or unavailable T/U source raises Fault_IllegalInstruction before the destination effect and TPC advance.

## Examples

- slliw a0, 1, ->a0
- slliw u#1, 31, ->t
- slliw zero, 0, ->zero

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->

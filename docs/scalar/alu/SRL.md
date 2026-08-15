<!-- GENERATED FROM: asl/scalar/alu/SRL.asl -->
# SRL

**Normative ASL source:** `asl/scalar/alu/SRL.asl`

SRL performs a logical right shift of the PTO_XLEN source by the low six bits of the snapshotted SrcR; the XLEN result is published directly.

## Normative identity {#PTO-INST-SCALAR-SRL}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
srl SrcL, SrcR, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| srl_32_5cfca42c59f3 | L32 | 32 | 0x00005005 / 0xfe00707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| srl_32_5cfca42c59f3 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| srl_32_5cfca42c59f3 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| srl_32_5cfca42c59f3 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| srl_32_5cfca42c59f3 | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| srl_32_5cfca42c59f3 | SrcL | 5 | 0–31 | none | none | Reg5 value source | Encoded zero reads the architectural zero GPR. |
| srl_32_5cfca42c59f3 | SrcR | 5 | 0–31 | none | none | Reg5 shift-count source | Encoded zero reads zero and therefore selects shift amount zero. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | Reg5 value source |
| SrcR | Reg5 shift-count source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/SRL.asl -->
```asl
readonly func InstructionContractOperation_SRL()
    => ScalarOperation
begin
    return ScalarOperation_SRL;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/SRL.asl -->
```asl
readonly func InstructionContractHandler_SRL()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinary;
end;

pure func InstructionContractShiftAmount_SRL(right: Word)
    => integer {0..63}
begin
    return UInt(right[5:0]);
end;

pure func InstructionContractResult_SRL(left: Word, right: Word)
    => Word
begin
    let amount = InstructionContractShiftAmount_SRL(right);
    let shifted = LSR(left, amount);
    return shifted;
end;

pure func InstructionContractIsWordOperation_SRL()
    => boolean
begin
    return FALSE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL, SrcR, and RegDst are required fields; no field can be omitted.
- The low six bits of the snapshotted SrcR select the shift amount 0 through 63; every higher SrcR bit is ignored for the amount.

## Legality

- SrcL and SrcR codes 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consumption.
- RegDst codes 0 and 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write GPRs.
- All SrcR values are legal; only its low six bits contribute to the shift amount.

## State effects

- Compute the logical right shift using the low six bits of the snapshotted SrcR. The PTO_XLEN result is written unchanged.
- Destination codes 0 and 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write GPRs; source queues are non-consuming.
- No memory, reservation, descriptor, flag, block, privilege, or control-flow state changes except the successful TPC advance.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot both sources before the destination effect so aliases and T/U publication use pre-instruction values.
- Publish the result, then advance TPC by four bytes.

## Exceptions

- SRL raises no arithmetic exception; shifted-out bits are discarded.
- An unavailable T/U source raises Fault_IllegalInstruction before the destination effect and successful TPC advance.

## Examples

- srl a0, a1, ->a2
- srl t#1, u#1, ->u
- srl zero, zero, ->zero

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->

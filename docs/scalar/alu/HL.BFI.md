<!-- GENERATED FROM: asl/scalar/alu/HL.BFI.asl -->
# HL.BFI

**Normative ASL source:** `asl/scalar/alu/HL.BFI.asl`

HL.BFI inserts ascending low source bits into an inclusive wrapping destination interval of a snapshotted base value and publishes the XLEN result.

## Normative identity {#PTO-INST-SCALAR-HL-BFI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
hl.bfi SrcL, SrcR, M, N, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_bfi_48_8adfd476aacc | HL48 | 48 | 0x0000204d000e / 0xfe00707f000f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_bfi_48_8adfd476aacc | RegDst | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_bfi_48_8adfd476aacc | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_bfi_48_8adfd476aacc | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |
| hl_bfi_48_8adfd476aacc | immr | 6 | encoding-defined | [{"instruction_lsb":4,"value_lsb":0,"width":6}] |
| hl_bfi_48_8adfd476aacc | imms | 6 | encoding-defined | [{"instruction_lsb":10,"value_lsb":0,"width":6}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_bfi_48_8adfd476aacc | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| hl_bfi_48_8adfd476aacc | SrcL | 5 | 0–31 | none | none | Reg5 base source | Encoded zero reads the architectural zero GPR base. |
| hl_bfi_48_8adfd476aacc | SrcR | 5 | 0–31 | none | none | Reg5 insertion source | Encoded zero reads the architectural zero GPR insertion source. |
| hl_bfi_48_8adfd476aacc | immr | 6 | 0–63 | none | none | first destination bit | Encoded zero begins the destination interval at bit zero. |
| hl_bfi_48_8adfd476aacc | imms | 6 | 0–63 | none | none | last destination bit | Encoded zero ends the destination interval at bit zero. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | Reg5 base source |
| SrcR | Reg5 insertion source |
| immr | first destination bit |
| imms | last destination bit |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/HL.BFI.asl -->
```asl
readonly func InstructionContractOperation_HL_BFI()
    => ScalarOperation
begin
    return ScalarOperation_HL_BFI;
end;

pure func InstructionContractFirstBit_HL_BFI(encoded_immr: bits(6))
    => integer {0..63}
begin
    return UInt(encoded_immr);
end;

pure func InstructionContractLastBit_HL_BFI(encoded_imms: bits(6))
    => integer {0..63}
begin
    return UInt(encoded_imms);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/HL.BFI.asl -->
```asl
readonly func InstructionContractHandler_HL_BFI()
    => ScalarSemanticHandler
begin
    return ScalarHandler_InsertBitfield;
end;

pure func InstructionContractResult_HL_BFI(
    base: Word,
    source: Word,
    first: integer {0..63},
    last: integer {0..63})
    => Word
begin
    return InsertBitfield(
        base,
        source,
        first,
        last);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL, SrcR, immr, imms, and RegDst are required encoded fields; no field can be omitted.
- immr directly encodes the first destination bit from 0 through 63. imms directly encodes the last destination bit from 0 through 63.
- When imms precedes immr, the inclusive destination interval wraps through bit 63 to bit 0. Equal endpoints select one destination bit.

## Legality

- SrcL and SrcR codes 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consumption.
- RegDst codes 0 and 24..29 discard, codes 1..23 write GPRs, code 30 pushes U, and code 31 pushes T.
- Every immr and imms value is assigned. The inclusive wrapping interval has a width from 1 through 64.

## State effects

- Snapshot the base and insertion sources. Starting with source bit zero, replace ascending bits of the inclusive destination interval from immr through imms, wrapping through bit 63 when required; preserve every base bit outside that interval.
- Publish the complete XLEN result through the common Reg5 destination map. Relative sources are non-consuming; only a T or U destination push changes a temporary queue.
- No memory, reservation, descriptor, numeric-status, block, privilege, branch-target, or other control state changes. Successful execution advances TPC by six bytes.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot both sources before any destination effect, including when RegDst aliases SrcL or SrcR.
- Publish the result, then advance TPC by six bytes.

## Exceptions

- An unavailable selected T/U source raises Fault_IllegalInstruction before the destination effect and before TPC advances. Both sources are preflighted even when their encoded values are equal.
- HL.BFI raises no arithmetic, memory, alignment, permission, or control-flow exception.

## Examples

- hl.bfi a0, a1, 8, 15, ->a2
- hl.bfi t#1, u#1, 63, 0, ->t
- hl.bfi a0, zero, 0, 63, ->a0

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->

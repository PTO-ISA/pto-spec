<!-- GENERATED FROM: asl/scalar/alu/HL.ORIW.asl -->
# HL.ORIW

**Normative ASL source:** `asl/scalar/alu/HL.ORIW.asl`

HL.ORIW applies word bitwise inclusive-or to SrcL[31:0] and the low word of a sign-extended 24-bit immediate, then sign-extends the 32-bit result.

## Normative identity {#PTO-INST-SCALAR-HL-ORIW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
hl.oriw SrcL, simm, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_oriw_48_17673d186249 | HL48 | 48 | 0x00003035000e / 0x0000707f000f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_oriw_48_17673d186249 | RegDst | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_oriw_48_17673d186249 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_oriw_48_17673d186249 | simm24 | 24 | signed | [{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":4,"value_lsb":12,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_oriw_48_17673d186249 | RegDst | 5 | 0–31 | none | none | Reg5 scalar destination or discard selector | Encoded zero discards the result and does not modify any GPR or queue. |
| hl_oriw_48_17673d186249 | SrcL | 5 | 0–31 | none | none | Reg5 scalar source; only bits 31:0 participate | Encoded zero reads architectural GPR zero. |
| hl_oriw_48_17673d186249 | simm24 | 24 | 0–16777215 | none | none | signed split 24-bit immediate | Encoded zero supplies numeric zero. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 scalar destination or discard selector |
| SrcL | Reg5 scalar source; only bits 31:0 participate |
| simm24 | signed split 24-bit immediate |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/HL.ORIW.asl -->
```asl
readonly func InstructionContractOperation_HL_ORIW() => ScalarOperation
begin
    return ScalarOperation_HL_ORIW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/HL.ORIW.asl -->
```asl
readonly func InstructionContractHandler_HL_ORIW() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinaryW;
end;

pure func InstructionContractImmediateWidth_HL_ORIW()
    => integer {1..64}
begin
    return 24;
end;

pure func InstructionContractImmediateIsSigned_HL_ORIW()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractIsWordOperation_HL_ORIW()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractResult_HL_ORIW(
    left: Word,
    immediate: bits(24))
    => Word
begin
    let right = SignExtend{PTO_XLEN}(immediate);
    return ScalarBinaryW(
        ScalarBinary_OR,
        left,
        right);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL, simm24, and RegDst are required encoded fields; no field can be omitted.
- simm24 has the complete signed 24-bit range -8388608 through 8388607; encoded zero is numeric zero.

## Legality

- All 32 SrcL encodings are assigned: 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consuming a queue entry.
- All 32 RegDst encodings are assigned: codes 0 and 24..29 discard, codes 1..23 write absolute GPRs, code 30 pushes U, and code 31 pushes T.
- Every signed 24-bit two's-complement value is assigned. The two 12-bit pieces reconstruct one exact 24-bit value.

## State effects

- Take SrcL[31:0] and the low 32 bits of the sign-extended simm24, compute word bitwise inclusive-or modulo 2^32, sign-extend the 32-bit result to PTO_XLEN, and publish it through RegDst.
- Codes 1..23 write a GPR; codes 0 and 24..29 discard; code 30 pushes U; code 31 pushes T. Relative source reads are non-consuming.
- No memory, reservation, descriptor, Tile, block, privilege, numeric-status, branch-target, or other control state changes. Successful execution advances TPC by six bytes.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot SrcL before the destination effect, including GPR aliases and same-queue read-then-push cases.
- Publish the result through RegDst, then advance TPC by six bytes.

## Exceptions

- HL.ORIW raises no arithmetic exception; fixed-width overflow or underflow is discarded.
- A fixed-bit mismatch or unavailable selected T/U source raises Fault_IllegalInstruction before any destination effect and before TPC advances.

## Examples

- hl.oriw a0, -1, ->a0
- hl.oriw t#1, -8388608, ->u
- hl.oriw zero, 8388607, ->zero

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->

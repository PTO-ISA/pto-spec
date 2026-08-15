<!-- GENERATED FROM: asl/scalar/alu/HL.CCATW.asl -->
# HL.CCATW

**Normative ASL source:** `asl/scalar/alu/HL.CCATW.asl`

HL.CCATW logically right-shifts {SrcL[31:0], SrcR[31:0]}, sign-extends the low then high 32-bit results, and writes them in order.

## Normative identity {#PTO-INST-SCALAR-HL-CCATW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
hl.ccatw SrcL, SrcR, shamt, ->Dst0, Dst1
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_ccatw_48_24a85ea4659c | HL48 | 48 | 0x0000205d000e / 0x0000707f07ff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_ccatw_48_24a85ea4659c | RegDst0 | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_ccatw_48_24a85ea4659c | RegDst1 | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_ccatw_48_24a85ea4659c | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_ccatw_48_24a85ea4659c | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |
| hl_ccatw_48_24a85ea4659c | shamt | 7 | encoding-defined | [{"instruction_lsb":41,"value_lsb":0,"width":7}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_ccatw_48_24a85ea4659c | RegDst0 | 5 | 0–31 | none | none | ordered low-result Reg5 destination or discard | Encoded zero discards the low result. |
| hl_ccatw_48_24a85ea4659c | RegDst1 | 5 | 0–31 | none | none | ordered high-result Reg5 destination or discard | Encoded zero discards the high result. |
| hl_ccatw_48_24a85ea4659c | SrcL | 5 | 0–31 | none | none | upper low-word Reg5 source | Encoded zero reads architectural GPR zero. |
| hl_ccatw_48_24a85ea4659c | SrcR | 5 | 0–31 | none | none | lower low-word Reg5 source | Encoded zero reads architectural GPR zero. |
| hl_ccatw_48_24a85ea4659c | shamt | 7 | 0–127 | none | none | unsigned seven-bit logical-right shift amount | Encoded zero performs no shift. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst0 | ordered low-result Reg5 destination or discard |
| RegDst1 | ordered high-result Reg5 destination or discard |
| SrcL | upper low-word Reg5 source |
| SrcR | lower low-word Reg5 source |
| shamt | unsigned seven-bit logical-right shift amount |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/HL.CCATW.asl -->
```asl
readonly func InstructionContractOperation_HL_CCATW() => ScalarOperation
begin
    return ScalarOperation_HL_CCATW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/HL.CCATW.asl -->
```asl
readonly func InstructionContractHandler_HL_CCATW() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteConcatenatePairW;
end;

pure func InstructionContractLowResult_HL_CCATW(
    left: Word,
    right: Word,
    shift_amount: integer {0..127})
    => Word
begin
    if shift_amount < 64 then
        var packed: Word = Zeros{PTO_XLEN};
        packed[31:0] = right[31:0];
        packed[63:32] = left[31:0];
        return SignExtend{PTO_XLEN}(
            LSR(packed, shift_amount)[31:0]);
    else
        return Zeros{PTO_XLEN};
    end;
end;

pure func InstructionContractHighResult_HL_CCATW(
    left: Word,
    right: Word,
    shift_amount: integer {0..127})
    => Word
begin
    if shift_amount < 64 then
        var packed: Word = Zeros{PTO_XLEN};
        packed[31:0] = right[31:0];
        packed[63:32] = left[31:0];
        return SignExtend{PTO_XLEN}(
            LSR(packed, shift_amount)[63:32]);
    else
        return Zeros{PTO_XLEN};
    end;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL, SrcR, shamt, RegDst0, and RegDst1 are required encoded fields; no field can be omitted.
- Encoded shamt zero performs no shift.

## Legality

- SrcL and SrcR independently use the complete Reg5 source map: GPR0..GPR23, T#1..T#4, and U#1..U#4.
- RegDst0 and RegDst1 independently use the common destination map: GPR writes, discard codes, U push, or T push.
- shamt 0..127 is fully assigned; values 64..127 produce two zeros.

## State effects

- Pack SrcL[31:0] above SrcR[31:0]. For shamt 0..63, logically shift the 64-bit value right, sign-extend result bits 31:0 to Dst0 and bits 63:32 to Dst1; for shamt 64..127 both results are zero.
- Apply the complete Reg5 destination map independently in Dst0 then Dst1 order; discard destinations have no effect.
- No memory, reservation, descriptor, Tile, block, privilege, numeric-status, branch-target, or other control state changes. Successful execution advances TPC by six bytes.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot both sources before either destination effect; relative source reads do not consume queue entries.
- Publish Dst0 first and Dst1 second. Equal GPR destinations retain Dst1; equal queue destinations enqueue Dst0 before Dst1.
- After both destination effects, advance TPC by six bytes.

## Exceptions

- The concatenation shift is total for every shamt and raises no arithmetic exception.
- A fixed-bit mismatch or unavailable selected T/U source raises Fault_IllegalInstruction before either destination effect and before TPC advances.

## Examples

- hl.ccatw a0, a1, 0, ->a2, a3
- hl.ccatw t#1, u#1, 64, ->zero, a0
- hl.ccatw a0, a1, 127, ->t, t

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->

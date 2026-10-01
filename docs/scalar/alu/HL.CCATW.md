<!-- GENERATED FROM: asl/scalar/alu/HL.CCATW.asl -->
# HL.CCATW

**Normative ASL source:** `asl/scalar/alu/HL.CCATW.asl`

HL.CCATW logically right-shifts {SrcL[31:0], SrcR[31:0]}, sign-extends the low then high 32-bit results, and writes them in order.

## Normative identity {#PTO-INST-SCALAR-HL-CCATW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-ccatw-purpose role=purpose -->
## What HL.CCATW does

`HL.CCATW` is a 48-bit scalar ALU instruction. It packs the low word of `SrcL` above the low word of `SrcR`, shifts that 64-bit value logically right by `shamt`, sign-extends each 32-bit half to XLEN, and publishes the low half to `Dst0` and the high half to `Dst1`.

Design point: the word form reads bits `31:0` of each source but writes a full XLEN value to each destination. Sign extension fills the upper bits from bit `31` of the shifted half, so each destination receives a defined XLEN value.

<!-- PTO-READER-BLOCK: scalar-hl-ccatw-mechanism role=mechanism -->
## How the result is formed

Both helpers build the same packed value: bits `31:0` hold `SrcR[31:0]` and bits `63:32` hold `SrcL[31:0]` (`asl/scalar/alu/HL.CCATW.asl:26-58`).

- For `shamt` in `0..63` the low result is the sign-extended `LSR(packed, shamt)[31:0]`.
- For `shamt` in `0..63` the high result is the sign-extended `LSR(packed, shamt)[63:32]`.
- For `shamt` in `64..127` both results are zero.

Design point: this helper has no special case at `shamt=0`, so `Dst0` receives the sign-extended `SrcR[31:0]` and `Dst1` the sign-extended `SrcL[31:0]`; each half takes its sign from bit `31` of the shifted result, so the sign follows the data arriving in that half.

<!-- PTO-READER-BLOCK: scalar-hl-ccatw-inputs role=inputs-outputs -->
## Inputs and destinations

- `RegDst0` receives the low word result or discards it.
- `RegDst1` receives the high word result or discards it.
- `SrcL` is the source whose low word becomes bits `63:32` of the packed value.
- `SrcR` is the source whose low word becomes bits `31:0` of the packed value.
- `shamt` is the 7-bit unsigned logical-right shift amount.

Both sources use the full source map: codes `0..23` select absolute GPRs, `24..27` select `T#1..T#4`, `28..31` select `U#1..U#4`, without consuming a queue entry. Both destinations use the common destination map: codes `1..23` write a GPR, codes `0` and `24..29` discard, code `30` pushes `U`, and code `31` pushes `T`.

Design point: only bits `31:0` of each source reach the result, so `hl.ccatw a0, a1, 0, ->a2, a3` ignores bits `63:32` of both `a0` and `a1`; those upper words never enter the published halves.

<!-- PTO-READER-BLOCK: scalar-hl-ccatw-effects role=effects -->
## Effects and ordering

Both results are computed before either write, and the writes follow a fixed order: `Dst0` first with the low word result, then `Dst1` with the high word result.

Design point: the order is observable when both destinations name one place. For one GPR the `Dst1` write is final. For one queue `Dst0` is enqueued first, so the high result becomes the newest entry.

`HL.CCATW` has no memory effect, records no numeric-status flag, and changes no other architectural state; `TPC` advances by `6` bytes after both destination effects.

Design point: for `shamt` in `64..127` both results are zero, yet both destination effects happen: a GPR destination is written with `0`, and a `T` or `U` destination still receives a zero push.

<!-- PTO-READER-BLOCK: scalar-hl-ccatw-constraints role=constraints -->
## Legality and fault boundary

All `128` values of `shamt` are assigned: `0..63` produce two sign-extended word results and `64..127` produce two zeros; every source and destination code is assigned as well.

An encoding whose fixed bits do not match the `HL48` form does not decode, and an encoding that matches no accepted form raises `Fault_IllegalInstruction` at `PC` before any source read. An unavailable selected `T` or `U` source raises `Fault_IllegalInstruction` at `PC` before either destination effect and before `TPC` advances. An instruction not applicable to the active bundle faults with `Fault_BundleControl` at `TPC` (`asl/scalar/model/dispatch/top-level.asl:17-37`, `asl/scalar/model/types/operands.asl:6-19`).

Design point: the helpers assert on no operand value, so every `shamt` and source pair yields a defined XLEN result, and the instruction has no arithmetic fault path.

<!-- PTO-READER-BLOCK: scalar-hl-ccatw-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

With `shamt=0`, `SrcL[31:0]` equal to `0x80000000`, and `SrcR[31:0]` equal to `0x1`, there is no shift: `Dst0` receives the sign-extended `SrcR[31:0]`, which is `1`, and `Dst1` receives the sign-extended `SrcL[31:0]`, which is `0xffffffff80000000`.

With `shamt=64` both published results are zero, so `hl.ccatw a0, a1, 64, ->a2, a3` writes `0` to `a2` and `0` to `a3`. With `shamt=32` the low result is the sign-extended `SrcL[31:0]`, which is again `0xffffffff80000000`.
<!-- SUPPLEMENTARY-END -->

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

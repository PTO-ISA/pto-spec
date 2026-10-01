<!-- GENERATED FROM: asl/scalar/alu/C.MOVI.asl -->
# C.MOVI

**Normative ASL source:** `asl/scalar/alu/C.MOVI.asl`

C.MOVI sign-extends its encoded five-bit immediate to XLEN and publishes it through RegDst.

## Normative identity {#PTO-INST-SCALAR-C-MOVI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-c-movi-purpose role=purpose -->
## What C.MOVI does

`C.MOVI` sign-extends its 5-bit immediate to `PTO_XLEN` and publishes the resulting word through the Reg5 destination. It reads no register at all.

Design point: `C.MOVI` is the only form in this compressed group with an explicit destination field, so it can materialize a constant directly into a GPR instead of pushing it to `T`. That is why it needs a `RegDst` field while `C.ADD`, `C.AND` and `C.OR` do not.

<!-- PTO-READER-BLOCK: scalar-c-movi-mechanism role=mechanism -->
## How the result is formed

`simm5` is sign-extended to `PTO_XLEN`: bit `4` is copied into bits `63..5`. The extended word is then published or discarded according to `RegDst`, with no arithmetic performed on it.

Design point: because the immediate is sign-extended, five bits reach both small positive and small negative constants. `c.movi -1, ->a0` materializes `18446744073709551615`, all `64` bits set, which a zero-extending rule could not express.

Design point: the destination field excludes code `10` by an explicit encoding constraint, because the 16-bit pattern that carries `RegDst=10` is the `C.SETRET` form. The constraint keeps the two compressed forms from overlapping, so a program that wants register `10` written must use a different instruction, such as `c.movr` or a 32-bit form.

<!-- PTO-READER-BLOCK: scalar-c-movi-inputs role=inputs-outputs -->
## Inputs and destinations

- `simm5` is the signed 5-bit immediate, from `-16` through `15`.
- `RegDst` publishes the extended value: `1..23` write that GPR, `30` pushes `U`, `31` pushes `T`, and `0` together with `24..29` discard it.

Design point: encoded zero of `simm5` is numeric zero, so `c.movi 0, ->a0` writes `0` and is the compressed constant-zero materialization. Encoded zero of `RegDst` discards instead of writing the zero GPR, so a discarded `C.MOVI` changes nothing.

Design point: there is no source field, so `C.MOVI` performs no source read and cannot fail a source-availability check.

<!-- PTO-READER-BLOCK: scalar-c-movi-effects role=effects -->
## Effects and ordering

The immediate is extended and then published in one step; ordering against other registers is irrelevant because nothing is read.

After publication or discard, `TPC` advances by `2` bytes. No memory, reservation, descriptor, numeric-status, bundle, privilege, predicate or control-flow state changes, and no queue moves except the single `T` or `U` push selected by `RegDst`.

<!-- PTO-READER-BLOCK: scalar-c-movi-constraints role=constraints -->
## Legality and fault boundary

Every `simm5` value is assigned, and every `RegDst` code is assigned except `10`, which the encoding constraint rejects.

A fixed-bit mismatch, including a `RegDst` value of `10`, raises `Fault_IllegalInstruction` before the destination effect and before `TPC` advances. An undecodable 16-bit form raises `Fault_IllegalInstruction` at `PC`, and an instruction that is not applicable to the active block raises `Fault_BundleControl` at `TPC`.

Design point: materialization is total, so `C.MOVI` never faults on an operand value. Its only rejected operand is the destination code that belongs to another instruction, and that rejection happens before anything is written.

<!-- PTO-READER-BLOCK: scalar-c-movi-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

With `simm5=5` and `RegDst` naming a GPR, `C.MOVI` writes `5` to that GPR. With `simm5=-1`, it writes `18446744073709551615`. With `RegDst=31`, the same extended value is pushed to `T` as the newest entry instead of being written to a register.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
c.movi simm, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| c_movi_16_2c84faf1bc72 | C16 | 16 | 0x0016 / 0x003f | [{"field":"RegDst","operator":"not-equal","value":10}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| c_movi_16_2c84faf1bc72 | RegDst | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| c_movi_16_2c84faf1bc72 | simm5 | 5 | signed | [{"instruction_lsb":6,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| c_movi_16_2c84faf1bc72 | RegDst | 5 | 0–9, 11–31 | none | 10 | Reg5 destination or discard | Encoded zero discards the result. |
| c_movi_16_2c84faf1bc72 | simm5 | 5 | 0–31 | none | none | signed five-bit immediate | Encoded zero materializes numeric zero. |

- `c_movi_16_2c84faf1bc72.RegDst` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| simm5 | signed five-bit immediate |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/C.MOVI.asl -->
```asl
readonly func InstructionContractOperation_C_MOVI() => ScalarOperation
begin
    return ScalarOperation_C_MOVI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/C.MOVI.asl -->
```asl
readonly func InstructionContractHandler_C_MOVI() => ScalarSemanticHandler
begin
    return ScalarHandler_MoveScalarValue;
end;

pure func InstructionContractResult_C_MOVI(
    encoded_immediate: bits(5))
    => Word
begin
    let immediate = SignExtend{PTO_XLEN}(encoded_immediate);
    return MoveScalarValue(immediate);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Every encoded source, immediate, and explicit destination field is required; no field can be omitted.
- The mnemonic fixes immediate signedness, selected source width, and implicit-versus-explicit destination behavior.

## Legality

- RegDst codes 0 and 24..29 discard, codes 1..23 write GPRs, code 30 pushes U, and code 31 pushes T.
- Every encoded operand value is assigned; fixed encoding bits must match the canonical form.

## State effects

- Sign-extend simm5[4] through the complete XLEN result.
- Publish the complete XLEN result through the common Reg5 destination map. Relative sources are non-consuming; only a T or U destination push changes a temporary queue.
- No memory, reservation, descriptor, numeric-status, block, privilege, branch-target, or other control state changes. Successful execution advances TPC by two bytes.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot any Reg5 source before the destination effect.
- Publish the result, then advance TPC by the encoded instruction length.

## Exceptions

- Materialization is a total fixed-width operation and raises no arithmetic exception.
- A fixed-bit mismatch raises Fault_IllegalInstruction before the destination effect and before TPC advances.

## Examples

- c.movi simm, ->{t, u, rd}

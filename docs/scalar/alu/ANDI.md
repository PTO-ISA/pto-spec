<!-- GENERATED FROM: asl/scalar/alu/ANDI.asl -->
# ANDI

**Normative ASL source:** `asl/scalar/alu/ANDI.asl`

ANDI performs XLEN conjunction with a sign-extended signed 12-bit immediate.

## Normative identity {#PTO-INST-SCALAR-ANDI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-andi-purpose role=purpose -->
## What ANDI does

`ANDI` sign-extends a signed 12-bit immediate to `PTO_XLEN`, computes the bit-by-bit conjunction of that value with a Reg5 source, and publishes the result through a Reg5 destination.

Design point: the immediate field is signed here, while `ADDI` spends the same twelve bits on an unsigned value. The two mnemonics share their encoding shape and differ in the interpretation of one field, so the sign rule is part of the mnemonic, not of the field.

<!-- PTO-READER-BLOCK: scalar-andi-mechanism role=mechanism -->
## How the result is formed

`simm12` is sign-extended to `PTO_XLEN` and combined with the source value by a bitwise AND.

Design point: sign extension makes the immediate all ones for every negative value. `andi a0, -1, ->a0` therefore preserves every bit of `a0`: the operation is defined and still advances `TPC`, but no bit of the result differs from the source.

Design point: the usable mask range is `0` through `2047` when the constant must be written directly, because a sign-extended `simm12` sets bits `63..11` for every value above `2047`. Masking a wider field requires a value produced at run time or a different mnemonic.

<!-- PTO-READER-BLOCK: scalar-andi-inputs role=inputs-outputs -->
## Inputs and destinations

- `SrcL` is a Reg5 source: `0..23` read absolute GPRs, `24..27` read `T#1..T#4`, and `28..31` read `U#1..U#4`, without consuming a queue entry.
- `simm12` carries the signed immediate, from `-2048` through `2047`.
- `RegDst` publishes the result: `1..23` write that GPR, `30` pushes `U`, `31` pushes `T`, and `0` together with `24..29` discard it.

Design point: encoded zero is numeric zero for `simm12`, so `andi a0, 0, ->a1` publishes `0` rather than copying the source. Encoded zero of `RegDst` discards, which is again different from writing the zero GPR.

<!-- PTO-READER-BLOCK: scalar-andi-effects role=effects -->
## Effects and ordering

`SrcL` is read before the destination is written, so a selector that is both source and destination keeps the pre-instruction value.

The result is published or discarded, and then `TPC` advances by `4` bytes. `ANDI` accesses no memory and changes no reservation, descriptor, numeric-status, trap, bundle, privilege, predicate or control-flow state beyond that advance.

<!-- PTO-READER-BLOCK: scalar-andi-constraints role=constraints -->
## Legality and fault boundary

Every encoded value is assigned: all `32` `SrcL` codes, all `32` `RegDst` codes, and all `4096` immediate values from `-2048` through `2047`.

An undecodable form raises `Fault_IllegalInstruction` at `PC`; an instruction that is not applicable to the active block raises `Fault_BundleControl` at `TPC`; a fixed-bit mismatch or an unavailable selected T/U source raises `Fault_IllegalInstruction`. Each precedes the destination effect and the `TPC` advance.

Design point: the conjunction is defined for every bit pattern of both operands, so `ANDI` has no value-dependent fault. A mask that clears bits the program still needs is a programming error, not an architectural exception.

<!-- PTO-READER-BLOCK: scalar-andi-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

With `SrcL=4095` and `simm12=2047`, `ANDI` publishes `4095 AND 2047 = 2047`. With `simm12=-1` on the same source, the sign-extended immediate is all ones and the published value is `4095` unchanged.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
andi SrcL, simm, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| andi_32_1d9302e57d30 | L32 | 32 | 0x00002015 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| andi_32_1d9302e57d30 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| andi_32_1d9302e57d30 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| andi_32_1d9302e57d30 | simm12 | 12 | signed | [{"instruction_lsb":20,"value_lsb":0,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| andi_32_1d9302e57d30 | RegDst | 5 | 0–31 | none | none | Reg5 scalar destination or discard selector | Encoded zero discards the result and does not modify any GPR or queue. |
| andi_32_1d9302e57d30 | SrcL | 5 | 0–31 | none | none | Reg5 scalar source | Encoded zero reads the architectural zero GPR. |
| andi_32_1d9302e57d30 | simm12 | 12 | 0–4095 | none | none | signed 12-bit immediate | Encoded zero supplies numeric zero. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 scalar destination or discard selector |
| SrcL | Reg5 scalar source |
| simm12 | signed 12-bit immediate |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/ANDI.asl -->
```asl
readonly func InstructionContractOperation_ANDI()
    => ScalarOperation
begin
    return ScalarOperation_ANDI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/ANDI.asl -->
```asl
readonly func InstructionContractHandler_ANDI()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinary;
end;

pure func InstructionContractImmediateWidth_ANDI()
    => integer {1..64}
begin
    return 12;
end;

pure func InstructionContractImmediateIsSigned_ANDI()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractIsWordOperation_ANDI()
    => boolean
begin
    return FALSE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL, simm12, and RegDst are required encoded fields; no field can be omitted.
- simm12 is a signed 12-bit immediate from -2048 through 2047. Encoded zero supplies numeric zero.

## Legality

- All 32 SrcL encodings are assigned: 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consuming a queue entry.
- All 32 RegDst encodings are assigned: codes 0 and 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write absolute GPRs.
- Every signed 12-bit immediate from -2048 through 2047 is legal and is sign-extended to PTO_XLEN before the conjunction.

## State effects

- Sign-extend simm12 to PTO_XLEN, compute the bitwise conjunction with the snapshotted SrcL value, and publish the complete XLEN result through RegDst.
- Codes 1..23 write a GPR; codes 0 and 24..29 discard; code 30 pushes U; code 31 pushes T. Source queue selections are non-consuming.
- No memory, reservation, descriptor, block, privilege, numeric-flag, or control-flow state changes other than TPC advancing by four bytes after success.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot SrcL before the destination effect. Repeated source and destination selectors therefore read the pre-instruction value.
- Successful execution publishes the result and then advances TPC by four bytes.

## Exceptions

- ANDI raises no arithmetic exception; bitwise conjunction is defined for every source and simm12 bit pattern.
- A fixed-bit mismatch or unavailable selected T/U source raises Fault_IllegalInstruction before the destination effect and before TPC advances.

## Examples

- andi a0, -1, ->a0
- andi t#1, 2047, ->u
- andi zero, -2048, ->zero

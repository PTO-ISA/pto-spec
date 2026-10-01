<!-- GENERATED FROM: asl/scalar/alu/ANDIW.asl -->
# ANDIW

**Normative ASL source:** `asl/scalar/alu/ANDIW.asl`

ANDIW performs word conjunction with a signed 12-bit immediate and sign-extends the result.

## Normative identity {#PTO-INST-SCALAR-ANDIW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-andiw-purpose role=purpose -->
## What ANDIW does

`ANDIW` computes the bit-by-bit conjunction of the low `32` bits of a Reg5 source with the low `32` bits of a sign-extended immediate, and publishes the 32-bit result sign-extended to `PTO_XLEN`.

Design point: `ANDIW` is the word form of `ANDI`, and its only difference is the width at which the conjunction is taken and published. The upper source bits are not masked away and kept, they are excluded from the operation entirely.

<!-- PTO-READER-BLOCK: scalar-andiw-mechanism role=mechanism -->
## How the result is formed

`simm12` is sign-extended to `PTO_XLEN`, its low `32` bits are combined with `SrcL[31:0]` by a bitwise AND, and result bit `31` is then copied into bits `63..32`.

Design point: the published value always has bits `63..32` equal to bit `31`, whether or not the source had them. `andiw a0, -1, ->a0` therefore normalizes `a0` to a well-formed 32-bit value, exactly as `addiw a0, 0, ->a0` does.

Design point: only the low word of the sign-extended immediate is used. For `simm12=-1` that word is all ones, so the conjunction returns `SrcL[31:0]` unchanged and only the extension differs from the source.

<!-- PTO-READER-BLOCK: scalar-andiw-inputs role=inputs-outputs -->
## Inputs and destinations

- `SrcL` is a Reg5 source: `0..23` read absolute GPRs, `24..27` read `T#1..T#4`, and `28..31` read `U#1..U#4`, without consuming a queue entry. Only `SrcL[31:0]` participates.
- `simm12` carries the signed immediate, from `-2048` through `2047`.
- `RegDst` publishes the sign-extended word result: `1..23` write that GPR, `30` pushes `U`, `31` pushes `T`, and `0` together with `24..29` discard it.

Design point: encoded zero of `simm12` is numeric zero, so the conjunction is zero for every source. Encoded zero of `SrcL` reads the architectural zero GPR, and encoded zero of `RegDst` discards rather than writing it.

<!-- PTO-READER-BLOCK: scalar-andiw-effects role=effects -->
## Effects and ordering

`SrcL` is read before the destination is written, so source and destination may name the same register without changing the result.

The word result is published or discarded, and then `TPC` advances by `4` bytes. `ANDIW` accesses no memory and changes no reservation, descriptor, numeric-status, trap, bundle, privilege, predicate or control-flow state beyond that advance.

<!-- PTO-READER-BLOCK: scalar-andiw-constraints role=constraints -->
## Legality and fault boundary

Every encoded value is assigned: all `32` `SrcL` codes, all `32` `RegDst` codes, and all `4096` immediate values from `-2048` through `2047`.

An undecodable form raises `Fault_IllegalInstruction` at `PC`; an instruction that is not applicable to the active block raises `Fault_BundleControl` at `TPC`; a fixed-bit mismatch or an unavailable selected T/U source raises `Fault_IllegalInstruction`. Each precedes the destination effect and the `TPC` advance.

Design point: discarding the upper source word is not a fault condition and is not reported. `ANDIW` has no value-dependent traffic with the trap machinery.

<!-- PTO-READER-BLOCK: scalar-andiw-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

With `SrcL=4294967295` and `simm12=2047`, `ANDIW` publishes `2047`. With `SrcL=4294967295` and `simm12=-1`, the low word of the immediate is all ones, so the conjunction is all ones and the published value is `18446744073709551615`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
andiw SrcL, simm, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| andiw_32_9ec1f7343dbd | L32 | 32 | 0x00002035 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| andiw_32_9ec1f7343dbd | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| andiw_32_9ec1f7343dbd | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| andiw_32_9ec1f7343dbd | simm12 | 12 | signed | [{"instruction_lsb":20,"value_lsb":0,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| andiw_32_9ec1f7343dbd | RegDst | 5 | 0–31 | none | none | Reg5 scalar destination or discard selector | Encoded zero discards the result and does not modify any GPR or queue. |
| andiw_32_9ec1f7343dbd | SrcL | 5 | 0–31 | none | none | Reg5 scalar source; only bits 31:0 participate | Encoded zero reads the architectural zero GPR. |
| andiw_32_9ec1f7343dbd | simm12 | 12 | 0–4095 | none | none | signed 12-bit immediate | Encoded zero supplies numeric zero. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 scalar destination or discard selector |
| SrcL | Reg5 scalar source; only bits 31:0 participate |
| simm12 | signed 12-bit immediate |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/ANDIW.asl -->
```asl
readonly func InstructionContractOperation_ANDIW()
    => ScalarOperation
begin
    return ScalarOperation_ANDIW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/ANDIW.asl -->
```asl
readonly func InstructionContractHandler_ANDIW()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinaryW;
end;

pure func InstructionContractImmediateWidth_ANDIW()
    => integer {1..64}
begin
    return 12;
end;

pure func InstructionContractImmediateIsSigned_ANDIW()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractIsWordOperation_ANDIW()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL, simm12, and RegDst are required encoded fields; no field can be omitted.
- simm12 is a signed 12-bit immediate from -2048 through 2047. Encoded zero supplies numeric zero.

## Legality

- All 32 SrcL encodings are assigned: 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consuming a queue entry.
- All 32 RegDst encodings are assigned: codes 0 and 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write absolute GPRs.
- Every signed 12-bit immediate from -2048 through 2047 is legal. Only the low 32 bits of SrcL and the sign-extended immediate participate.

## State effects

- Sign-extend simm12, AND its low 32 bits with the low 32 bits of SrcL, then produce a 32-bit result sign-extended to XLEN and publish it through RegDst.
- Codes 1..23 write a GPR; codes 0 and 24..29 discard; code 30 pushes U; code 31 pushes T. Source queue selections are non-consuming.
- No memory, reservation, descriptor, block, privilege, numeric-flag, or control-flow state changes other than TPC advancing by four bytes after success.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot SrcL before the destination effect. Repeated source and destination selectors therefore read the pre-instruction value.
- Successful execution publishes the sign-extended word result and then advances TPC by four bytes.

## Exceptions

- ANDIW raises no arithmetic exception; word conjunction and final sign extension are defined for every source and simm12 bit pattern.
- A fixed-bit mismatch or unavailable selected T/U source raises Fault_IllegalInstruction before the destination effect and before TPC advances.

## Examples

- andiw a0, -1, ->a0
- andiw u#1, 2047, ->t
- andiw zero, -2048, ->zero

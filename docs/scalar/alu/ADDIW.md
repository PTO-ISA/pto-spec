<!-- GENERATED FROM: asl/scalar/alu/ADDIW.asl -->
# ADDIW

**Normative ASL source:** `asl/scalar/alu/ADDIW.asl`

ADDIW performs unsigned-immediate word addition and sign-extends the result to XLEN.

## Normative identity {#PTO-INST-SCALAR-ADDIW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-addiw-purpose role=purpose -->
## What ADDIW does

`ADDIW` adds a zero-extended unsigned 12-bit immediate to the low word of a Reg5 source and publishes the 32-bit sum sign-extended to `PTO_XLEN`.

Design point: `ADDIW` reuses both fields and the unsigned immediate rule of `ADDI`, and changes only the width of the addition and of the publication. That is why the two mnemonics have separate opcodes rather than a width field: the width is a property of the mnemonic, so no bit of the encoding is spent on it.

<!-- PTO-READER-BLOCK: scalar-addiw-mechanism role=mechanism -->
## How the result is formed

The immediate is zero-extended to `PTO_XLEN` and added to `SrcL[31:0]` modulo `2^32`. The 32-bit result is then sign-extended: result bit `31` is copied into bits `63..32`.

Design point: source bits `63..32` never participate. `ADDIW` is therefore the normalization step for a value that must be a well-formed 32-bit number in a 64-bit register, because every published result has bits `63..32` equal to bit `31`.

Word addition is fixed width and total: it wraps at `2^32` and raises no arithmetic exception.

<!-- PTO-READER-BLOCK: scalar-addiw-inputs role=inputs-outputs -->
## Inputs and destinations

- `SrcL` is a Reg5 source: `0..23` read absolute GPRs, `24..27` read `T#1..T#4`, and `28..31` read `U#1..U#4`, without consuming a queue entry. Only `SrcL[31:0]` participates.
- `uimm12` carries the unsigned addend, from `0` through `4095`.
- `RegDst` publishes the sign-extended result: `1..23` write that GPR, `30` pushes `U`, `31` pushes `T`, and `0` together with `24..29` discard it.

Design point: encoded zero of `SrcL` reads the architectural zero GPR, and encoded zero of `RegDst` discards. Neither is an omission, and no field of `ADDIW` can be omitted.

<!-- PTO-READER-BLOCK: scalar-addiw-effects role=effects -->
## Effects and ordering

`SrcL` is read before the destination is written, so an alias between the two selectors observes the pre-instruction value.

The word sum is published or discarded, and then `TPC` advances by `4` bytes. `ADDIW` accesses no memory and changes no reservation, descriptor, numeric-status, trap, bundle, privilege, predicate or control-flow state beyond that advance.

<!-- PTO-READER-BLOCK: scalar-addiw-constraints role=constraints -->
## Legality and fault boundary

Every encoded value is assigned: all `32` `SrcL` codes, all `32` `RegDst` codes, and all `4096` immediate values from `0` through `4095`.

An undecodable form raises `Fault_IllegalInstruction` at `PC`; an instruction that is not applicable to the active block raises `Fault_BundleControl` at `TPC`; a fixed-bit mismatch or an unavailable selected T/U source raises `Fault_IllegalInstruction`. Each precedes the destination effect and the `TPC` advance, and none of them depends on the operand values.

Design point: the truncation to `32` bits is not a fault condition. A sum that does not fit in a word silently keeps its low `32` bits and then sign-extends them, so `ADDIW` can never raise an overflow trap.

<!-- PTO-READER-BLOCK: scalar-addiw-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

With `SrcL=4294967295`, `uimm12=1` and `SrcL[31:0]` all ones, the 32-bit sum wraps to `0` and `ADDIW` publishes `0`; the same operands under `ADDI` would publish `4294967296`. With `SrcL=2147483648` and `uimm12=0`, the published value keeps `2147483648`, because sign-extension reproduces the source word.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
addiw SrcL, uimm, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| addiw_32_08cc89cd2689 | L32 | 32 | 0x00000035 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| addiw_32_08cc89cd2689 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| addiw_32_08cc89cd2689 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| addiw_32_08cc89cd2689 | uimm12 | 12 | unsigned | [{"instruction_lsb":20,"value_lsb":0,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| addiw_32_08cc89cd2689 | RegDst | 5 | 0–31 | none | none | Reg5 scalar destination or discard selector | Encoded zero discards the result and does not modify any GPR or queue. |
| addiw_32_08cc89cd2689 | SrcL | 5 | 0–31 | none | none | Reg5 scalar source; only bits 31:0 participate | Encoded zero reads the architectural zero GPR. |
| addiw_32_08cc89cd2689 | uimm12 | 12 | 0–4095 | none | none | unsigned 12-bit immediate | Encoded zero supplies numeric zero. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 scalar destination or discard selector |
| SrcL | Reg5 scalar source; only bits 31:0 participate |
| uimm12 | unsigned 12-bit immediate |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/ADDIW.asl -->
```asl
readonly func InstructionContractOperation_ADDIW()
    => ScalarOperation
begin
    return ScalarOperation_ADDIW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/ADDIW.asl -->
```asl
readonly func InstructionContractHandler_ADDIW()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinaryW;
end;

pure func InstructionContractImmediateWidth_ADDIW()
    => integer {1..64}
begin
    return 12;
end;

pure func InstructionContractImmediateIsUnsigned_ADDIW()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractIsWordOperation_ADDIW()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL, uimm12, and RegDst are required encoded fields; no field can be omitted.
- uimm12 is an unsigned 12-bit immediate from 0 through 4095. Encoded zero supplies numeric zero.

## Legality

- All 32 SrcL encodings are assigned: 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4.
- All 32 RegDst encodings are assigned: codes 0 and 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write absolute GPRs.
- Every unsigned 12-bit immediate from 0 through 4095 is legal; source bits above bit 31 do not affect the result.

## State effects

- Add zero-extended uimm12 to SrcL[31:0] modulo 2^32, then sign-extend the 32-bit result to XLEN and publish it through RegDst.
- Codes 1..23 write a GPR; codes 0 and 24..29 discard; code 30 pushes U; code 31 pushes T. Source queue selections are non-consuming.
- No memory, reservation, descriptor, block, privilege, or control-flow state changes other than TPC advancing by four bytes after success.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot SrcL before the destination effect. Repeated source and destination selectors therefore read the pre-instruction value.
- Successful execution publishes the sign-extended word result and then advances TPC by four bytes.

## Exceptions

- ADDIW raises no arithmetic exception: word addition wraps modulo 2^32 and is sign-extended to XLEN.
- A fixed-bit mismatch or unavailable selected T/U source raises Fault_IllegalInstruction before the destination effect and before TPC advances.

## Examples

- addiw a0, 1, ->a0
- addiw t#1, 4095, ->u
- addiw zero, 0, ->zero

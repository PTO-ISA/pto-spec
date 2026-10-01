<!-- GENERATED FROM: asl/scalar/bru/HL.SETRET.asl -->
# HL.SETRET

**Normative ASL source:** `asl/scalar/bru/HL.SETRET.asl`

HL.SETRET - Write the architectural return address.

## Normative identity {#PTO-INST-SCALAR-HL-SETRET}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-setret-purpose role=purpose -->
## What HL.SETRET does

`HL.SETRET` computes a return address from the current instruction `TPC` plus an unsigned halfword offset and records it in two places: the general-purpose register `R10`, which the assembly names `Ra`, and the bundle-local return address.

Design point: `HL.SETRET` prepares a return but does not take it. The transfer happens later, when a block start whose transfer type is return reads the recorded return address, so the instruction itself leaves execution sequential.

<!-- PTO-READER-BLOCK: scalar-hl-setret-mechanism role=mechanism -->
## How the return address is formed

The `32`-bit `imm32` is zero-extended to `PTO_XLEN` and shifted left by `1`, and the result is added to the current `TPC`. The scale of `2` makes the field count halfwords, and the sum wraps at `2^64`.

Design point: `imm32` is zero-extended rather than sign-extended, so the field spans `0` to `4294967295` halfwords and there is no negative displacement. The sibling `HL.ADDTPC` instead uses a signed immediate with a `12`-bit page scale, so the two forms are not interchangeable.

Both writes use the same computed value and happen in one handler step: `SetReturnAddress` writes GPR `10` first and then the bundle-local return address.

<!-- PTO-READER-BLOCK: scalar-hl-setret-inputs-outputs role=inputs-outputs -->
## Operands and the fixed destination

- `imm32` supplies the unsigned halfword offset. It is assembled from two instruction pieces, `20` bits and `12` bits wide.

- There is no destination selector field: the bits that other `48`-bit forms use for `RegDst` are fixed to the value `10` here, so the target always reaches `R10`.

- There is no source register operand. The base of the computation is the instruction `TPC`.

Design point: because the destination is pinned by the encoding instead of named by a field, `HL.SETRET` cannot be encoded with a discarded or queue destination. Every successful occurrence updates `R10` and the return address together.

<!-- PTO-READER-BLOCK: scalar-hl-setret-effects role=effects -->
## Effects and ordering

`R10` receives the wrapped target and the bundle-local return address receives the same value. `SetReturnAddress` does not write `TPC`, so the dispatch boundary then advances `TPC` by `6` bytes.

No other state changes: no memory location, no reservation, no commit argument, and no `BARG` field is written. The `SetReturnAddress` path raises no fault of its own.

Design point: writing `R10` as well as the bundle-local return address keeps the value visible to ordinary scalar code, which can read, save, or replace it with normal register operations, while the block machinery keeps its own copy for return-type block starts and frame templates.

<!-- PTO-READER-BLOCK: scalar-hl-setret-constraints role=constraints -->
## Legality and fault order

The fixed bits of the form must match, otherwise the pattern does not decode as this instruction and raises `Fault_IllegalInstruction`. Every value of `imm32` is assigned, so no immediate is reserved.

Design point: decoding happens before the `TPC` read and before either write, so a rejected pattern leaves `R10`, the bundle-local return address, and `TPC` unchanged.

<!-- PTO-READER-BLOCK: scalar-hl-setret-example role=example -->
## Non-normative example

This example illustrates the current owner and does not create a second semantic definition.

With `TPC` equal to `0x2000`, `hl.setret 4, ->Ra` writes `0x2008` to `R10` and records `0x2008` as the return address, while execution continues at `0x2006`. `hl.setret 0, ->Ra` records `0x2000`, the address of the instruction itself.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.setret imm, ->Ra
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_setret_48_302bb793a800 | HL48 | 48 | 0x00000507000e / 0x00000fff000f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_setret_48_302bb793a800 | imm32 | 32 | encoding-defined | [{"instruction_lsb":28,"value_lsb":0,"width":20},{"instruction_lsb":4,"value_lsb":20,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_setret_48_302bb793a800 | imm32 | 32 | 0–4294967295 | none | none | 32-bit immediate value | Encoded zero supplies numeric zero for the 32-bit immediate value. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| imm32 | 32-bit immediate value |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/bru/HL.SETRET.asl -->
```asl
readonly func InstructionContractOperation_HL_SETRET() => ScalarOperation
begin
    return ScalarOperation_HL_SETRET;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/bru/HL.SETRET.asl -->
```asl
readonly func InstructionContractHandler_HL_SETRET() => ScalarSemanticHandler
begin
    return ScalarHandler_SetReturnAddress;
end;

pure func InstructionContractUsesTPC_HL_SETRET()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractTarget_HL_SETRET(
    base: Word,
    halfword_offset: Word)
    => Word
begin
    return base + LSL(halfword_offset, 1);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- The selected assembly form determines which fields are present; every present field carries its encoded value and no encoded zero means omission.

## Legality

- Every value in each unconstrained encoded field is assigned; constrained complements are reserved and reject before effects.

## State effects

- HL.SETRET - Write the architectural return address.
- After decode and legality checks, execute the normative SetReturnAddress ASL handler; no other architectural state is modified.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- none

## Exceptions

- Reserved field encodings raise Fault_IllegalInstruction before effects; handler-specific arithmetic, memory, control-flow, system-register, and privilege faults follow the embedded normative ASL operation.

## Examples

- hl.setret imm, ->Ra

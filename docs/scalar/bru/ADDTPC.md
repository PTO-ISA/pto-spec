<!-- GENERATED FROM: asl/scalar/bru/ADDTPC.asl -->
# ADDTPC

**Normative ASL source:** `asl/scalar/bru/ADDTPC.asl`

ADDTPC - Add a signed 4 KiB page displacement to the current TPC.

## Normative identity {#PTO-INST-SCALAR-ADDTPC}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-addtpc-purpose role=purpose -->
## What ADDTPC does

`ADDTPC` adds a signed `4` KiB page displacement to the current instruction `TPC` and writes the resulting address to a destination register.

It is a materializing instruction, not a branch: the computed address becomes data, and execution continues with the instruction that follows.

<!-- PTO-READER-BLOCK: scalar-addtpc-mechanism role=mechanism -->
## Mechanism

The contract returns `ScalarHandler_AddToPC` with `InstructionContractUsesTPC_ADDTPC` true, `InstructionContractImmediateIsSigned_ADDTPC` true, `InstructionContractImmediateWidth_ADDTPC` `20`, and `InstructionContractPageShift_ADDTPC` `12`.

The model adds `SignExtend(imm20)` shifted left by `12` to `TPC` and writes that sum through the destination selector. The addition wraps at XLEN. `TPC` is read once, before the addition, so the sum is relative to the address of `ADDTPC` itself and never to the next instruction.

Design point: encoded immediate zero contributes a zero displacement, so the instruction can copy the current `TPC` into a register without any other setup. That gives software a way to obtain a self-relative base address without a separate constant load.

<!-- PTO-READER-BLOCK: scalar-addtpc-inputs-outputs role=inputs-outputs -->
## Inputs and output

`imm20` supplies the signed `20`-bit page displacement: the encoded value is sign-extended, then scaled by `4096` bytes. Its `20` bits cover a range of plus or minus two gigabytes of pages.

`RegDst` names the destination. Codes `1..23` write the named absolute GPR, code `0` and codes `24..29` discard the result, code `30` pushes it to the `U` queue, and code `31` pushes it to the `T` queue.

Encoded zero in `RegDst` names the architectural zero GPR, so writing there has no architectural effect.

Design point: `RegDst` excludes code `10` because that five-bit value is the encoding of `SETRET`'s implicit return-address destination, and the narrower `SETRET` form occupies exactly that hole in the `ADDTPC` opcode. A `RegDst` of `10` is therefore rejected rather than reinterpreted.

<!-- PTO-READER-BLOCK: scalar-addtpc-effects role=effects -->
## Effects and ordering

`ADDTPC` writes one destination value and nothing else. `InstructionContractWritesTPC_ADDTPC` returns false, and the state contract states that the instruction neither installs a control-flow target nor modifies `TPC` directly.

After the destination effect, scalar dispatch advances `TPC` by `4` bytes, the encoded length of the form, because `ScalarHandlerWritesTPC` is false for `AddToPC`.

There is no memory effect, no reservation effect, and no numeric status flag.

Design point: the address arithmetic and the program counter advance are separate steps. A later branch or indirect transfer can therefore consume the computed address from a register, while the read-only `TPC` register keeps its ordinary sequential meaning until then.

<!-- PTO-READER-BLOCK: scalar-addtpc-constraints role=constraints -->
## Legality and fault order

Decode runs first. A fixed-bit mismatch raises `Fault_IllegalInstruction` at the instruction address before any effect.

The only constrained field is `RegDst`, whose value `10` is reserved and also raises `Fault_IllegalInstruction` before any effect. `imm20` has no reserved values: all `20`-bit patterns are assigned, including the sign bit.

An unavailable selected `T` or `U` source is rejected during the operand-legality step, before the destination is written. A failure leaves the destination register, the queues, and `TPC` unchanged.

<!-- PTO-READER-BLOCK: scalar-addtpc-example role=example -->
## Non-normative example

Let `a0 = 8192` and let the `ADDTPC` instruction itself sit at `TPC = 53248`.

With `imm20 = 1`, the displacement is `1 << 12 = 4096`, so `addtpc simm, ->{t, u, Rd}` writes `53248 + 4096 = 57344` into `a0`.

The next instruction is fetched from `53248 + 4 = 53252`, not from `57344`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
addtpc simm, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| addtpc_32_e5aa0f0abca3 | L32 | 32 | 0x00000007 / 0x0000007f | [{"field":"RegDst","operator":"not-equal","value":10}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| addtpc_32_e5aa0f0abca3 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| addtpc_32_e5aa0f0abca3 | imm20 | 20 | encoding-defined | [{"instruction_lsb":12,"value_lsb":0,"width":20}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| addtpc_32_e5aa0f0abca3 | RegDst | 5 | 0–9, 11–31 | none | 10 | absolute GPR destination | Encoded zero names the architectural zero GPR. |
| addtpc_32_e5aa0f0abca3 | imm20 | 20 | 0–1048575 | none | none | signed 20-bit 4 KiB page displacement | Encoded zero contributes a zero page displacement and produces the current instruction TPC. |

- `addtpc_32_e5aa0f0abca3.RegDst` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | absolute GPR destination |
| imm20 | signed 20-bit 4 KiB page displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/bru/ADDTPC.asl -->
```asl
readonly func InstructionContractOperation_ADDTPC() => ScalarOperation
begin
    return ScalarOperation_ADDTPC;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/bru/ADDTPC.asl -->
```asl
readonly func InstructionContractHandler_ADDTPC() => ScalarSemanticHandler
begin
    return ScalarHandler_AddToPC;
end;

pure func InstructionContractUsesTPC_ADDTPC()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractImmediateWidth_ADDTPC()
    => integer {20}
begin
    return 20;
end;

pure func InstructionContractImmediateIsSigned_ADDTPC()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractPageShift_ADDTPC()
    => integer {12}
begin
    return 12;
end;

pure func InstructionContractWritesTPC_ADDTPC()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractTarget_ADDTPC(
    base: Word,
    page_offset: Word)
    => Word
begin
    return base + LSL(page_offset, 12);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- The imm20 field is sign-extended and scaled by 4096 bytes; encoded zero contributes a zero page displacement and produces the current instruction TPC.
- The selected assembly form determines which fields are present; every present field carries its encoded value and no encoded zero means omission.

## Legality

- addtpc_32_e5aa0f0abca3.RegDst excludes 10; the excluded encoding is reserved.

## State effects

- ADDTPC writes TPC + (SignExtend(imm20) << 12), wrapping at XLEN, through the selected Reg5 destination.
- The instruction does not install a control-flow target and does not directly modify TPC.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Read the current instruction TPC before computing the wrapping XLEN result.
- After the destination effect, the scalar dispatch boundary advances TPC by four bytes.

## Exceptions

- Reserved field encodings raise Fault_IllegalInstruction before effects; handler-specific arithmetic, memory, control-flow, system-register, and privilege faults follow the embedded normative ASL operation.

## Examples

- addtpc simm, ->{t, u, Rd}

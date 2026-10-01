<!-- GENERATED FROM: asl/scalar/bru/HL.ADDTPC.asl -->
# HL.ADDTPC

**Normative ASL source:** `asl/scalar/bru/HL.ADDTPC.asl`

HL.ADDTPC - Add a signed 4 KiB page displacement to the current TPC.

## Normative identity {#PTO-INST-SCALAR-HL-ADDTPC}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-addtpc-purpose role=purpose -->
## What HL.ADDTPC does

`HL.ADDTPC` adds a signed `32`-bit page displacement to the current instruction `TPC` and publishes the sum as data through a destination selector. It transfers no control: after the write, execution continues with the following instruction.

Design point: the result is a computed address, not a branch target. A program can therefore materialize a page-relative base or table address without disturbing where execution continues, and the sequential `6`-byte advance of the `48`-bit form still happens. The sibling form `HL.SETRET` uses the same `48`-bit skeleton to record a return target instead.

<!-- PTO-READER-BLOCK: scalar-hl-addtpc-mechanism role=mechanism -->
## How the page address is formed

The `32`-bit `imm32` is sign-extended to `PTO_XLEN` (`64` bits), shifted left by `12`, and added to the current `TPC`. The addition is `64` bits wide, so the result wraps at `2^64` and a carry out of bit `63` is discarded.

Design point: the shift of `12` makes the immediate count `4096`-byte pages, so the encoded field covers `4` KiB page units. Encoded zero is not a special marker: it contributes a zero page displacement, and the value written is the unchanged `TPC`.

The `TPC` that is read is the address of `HL.ADDTPC` itself, because nothing has advanced it yet. The destination write and the `6`-byte sequential advance are two separate steps, in that order.

<!-- PTO-READER-BLOCK: scalar-hl-addtpc-inputs-outputs role=inputs-outputs -->
## Operands and destination codes

- `imm32` supplies the signed page displacement. It is assembled from two instruction pieces, `20` bits and `12` bits wide.

- `RegDst` selects the destination with the ordinary `Reg5` rules: codes `0` to `23` name absolute GPRs, codes `24` to `29` write nothing, code `30` pushes the U queue, and code `31` pushes the T queue.

- There is no source register operand. The base of the computation is the instruction `TPC`.

Design point: encoded `RegDst` value `10` is reserved, because that value is the destination slot the narrow `hl.setret` form occupies in the same `48`-bit encoding space. An encoding with `RegDst` `10` selects `HL.SETRET`, not `HL.ADDTPC`.

Design point: codes `24` to `29` are non-writing destinations, so an encoded `HL.ADDTPC` that uses one of them advances `TPC` by `6` bytes and leaves every register and every queue entry unchanged.

<!-- PTO-READER-BLOCK: scalar-hl-addtpc-effects role=effects -->
## Effects and ordering

The wrapped sum is written through the selected destination. `AddToPC` does not touch `TPC`, so after the write the dispatch boundary advances `TPC` by `6` bytes, the encoded length of this `48`-bit form.

`HL.ADDTPC` modifies no commit state, no `BARG` field, no memory location, and no reservation, and `AddToPC` raises no fault of its own.

<!-- PTO-READER-BLOCK: scalar-hl-addtpc-constraints role=constraints -->
## Legality and fault order

The fixed bits of the form must match, otherwise the pattern does not decode as this instruction and raises `Fault_IllegalInstruction`. The `RegDst` value `10` is the only reserved field value of the form; all `32` bits of `imm32` are assigned.

Design point: legality is checked before the `TPC` read and before the destination write, so a rejected encoding publishes no value and leaves `TPC` at the instruction for full re-execution after recovery.

<!-- PTO-READER-BLOCK: scalar-hl-addtpc-example role=example -->
## Non-normative example

This example illustrates the current owner and does not create a second semantic definition.

With `TPC` equal to `0x1000`, `hl.addtpc 1, ->a1` writes `0x2000` to `a1` and the next instruction is fetched at `0x1006`. `hl.addtpc -1, ->a2` writes `0x0000`, and `hl.addtpc 0, ->a3` writes the unchanged `0x1000`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.addtpc imm, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_addtpc_48_2e8e692eea09 | HL48 | 48 | 0x00000007000e / 0x0000007f000f | [{"field":"RegDst","operator":"not-equal","value":10}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_addtpc_48_2e8e692eea09 | RegDst | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_addtpc_48_2e8e692eea09 | imm32 | 32 | encoding-defined | [{"instruction_lsb":28,"value_lsb":0,"width":20},{"instruction_lsb":4,"value_lsb":20,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_addtpc_48_2e8e692eea09 | RegDst | 5 | 0–9, 11–31 | none | 10 | absolute GPR destination | Encoded zero names the architectural zero GPR. |
| hl_addtpc_48_2e8e692eea09 | imm32 | 32 | 0–4294967295 | none | none | signed 32-bit 4 KiB page displacement | Encoded zero contributes a zero page displacement and produces the current instruction TPC. |

- `hl_addtpc_48_2e8e692eea09.RegDst` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | absolute GPR destination |
| imm32 | signed 32-bit 4 KiB page displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/bru/HL.ADDTPC.asl -->
```asl
readonly func InstructionContractOperation_HL_ADDTPC() => ScalarOperation
begin
    return ScalarOperation_HL_ADDTPC;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/bru/HL.ADDTPC.asl -->
```asl
readonly func InstructionContractHandler_HL_ADDTPC() => ScalarSemanticHandler
begin
    return ScalarHandler_AddToPC;
end;

pure func InstructionContractUsesTPC_HL_ADDTPC()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractImmediateWidth_HL_ADDTPC()
    => integer {32}
begin
    return 32;
end;

pure func InstructionContractImmediateIsSigned_HL_ADDTPC()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractPageShift_HL_ADDTPC()
    => integer {12}
begin
    return 12;
end;

pure func InstructionContractWritesTPC_HL_ADDTPC()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractTarget_HL_ADDTPC(
    base: Word,
    page_offset: Word)
    => Word
begin
    return base + LSL(page_offset, 12);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- The imm32 field is sign-extended and scaled by 4096 bytes; encoded zero contributes a zero page displacement and produces the current instruction TPC.
- The selected assembly form determines which fields are present; every present field carries its encoded value and no encoded zero means omission.

## Legality

- hl_addtpc_48_2e8e692eea09.RegDst excludes 10; the excluded encoding is reserved.

## State effects

- HL.ADDTPC writes TPC + (SignExtend(imm32) << 12), wrapping at XLEN, through the selected Reg5 destination.
- The instruction does not install a control-flow target and does not directly modify TPC.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Read the current instruction TPC before computing the wrapping XLEN result.
- After the destination effect, the scalar dispatch boundary advances TPC by six bytes.

## Exceptions

- Reserved field encodings raise Fault_IllegalInstruction before effects; handler-specific arithmetic, memory, control-flow, system-register, and privilege faults follow the embedded normative ASL operation.

## Examples

- hl.addtpc imm, ->{t, u, Rd}

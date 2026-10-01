<!-- GENERATED FROM: asl/scalar/agu/LB.PCR.asl -->
# LB.PCR

**Normative ASL source:** `asl/scalar/agu/LB.PCR.asl`

LB.PCR snapshots its scalar sources, forms its encoded address, and loads one aligned little-endian 1-byte value.

## Normative identity {#PTO-INST-SCALAR-LB-PCR}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-lb-pcr-purpose role=purpose -->
## What `LB.PCR` does

`LB.PCR` loads one signed `1`-byte unit from an address relative to the instruction's own aligned address. It reads no base register and no index register.

The canonical assembly is `lb.pcr [symbol], ->{t, u, Rd}`.

Design point: the only addressing input is `simm17`, so the same encoding fetches the same relative byte wherever the instruction is placed in the stream.

<!-- PTO-READER-BLOCK: scalar-lb-pcr-mechanism role=mechanism -->
## How the address and the transfer are formed

The base is `TPC` with bits `1:0` cleared, which is the `4`-byte-aligned address of this instruction. The sign-extended `simm17` is multiplied by `4` and added to that base modulo `2^PTO_XLEN`.

Preflight tests `1`-byte alignment, then translation, then permission and bounded memory. On success `1` byte is read little-endian and one relaxed load event is recorded.

The byte is sign-extended to `PTO_XLEN` and published through `RegDst`; the encoding has no other state effect.

Design point: the displacement scale of `4` is the instruction length, so `simm17` counts instructions and reaches `-262144`..`262140` bytes. Base and displacement are both multiples of `4`, so the sum is too.

<!-- PTO-READER-BLOCK: scalar-lb-pcr-inputs role=inputs-outputs -->
## Encoded fields and roles

- `TPC` is the implicit base and holds the address of the instruction being executed; bits `1:0` are cleared before the addition.
- `simm17` is signed and covers `-65536`..`65535` units of `4` bytes, that is `-262144`..`262140` bytes.
- `RegDst` is the only selector in the encoding. Codes `1`..`23` write GPRs, `30` pushes the `U` queue, `31` pushes the `T` queue, and `0` plus `24`..`29` publish nothing; code `0` is the architectural zero GPR, whose writes are discarded.
- Design point: with no base register to snapshot and no `SrcRType` or `shamt` field, the only legality failure this form can produce is an unmatched fixed-bit pattern.

<!-- PTO-READER-BLOCK: scalar-lb-pcr-effects role=effects -->
## Effects, ordering, and completion

The base is read from `TPC` before the memory operation, so the displacement is measured from this instruction rather than from the advanced program counter.

Success records one relaxed load event, changes no memory byte, preserves the reservation, publishes the sign-extended byte, and advances `TPC` by `4` bytes.

Design point: the loaded byte is sign-extended, so a byte `0xFF` in memory publishes as `0xFFFFFFFFFFFFFFFF`.

<!-- PTO-READER-BLOCK: scalar-lb-pcr-constraints role=constraints -->
## Legality, faults, and restart

- A fixed-bit mismatch raises `Fault_IllegalInstruction` at the instruction address before any memory or destination effect.
- The address must satisfy `1`-byte alignment before translation is consulted; a later permission or bounded-memory failure raises `Fault_DataPage` at the original effective address.
- A fault records no event, publishes nothing, and leaves `TPC` on the faulting instruction so the attempt can be reissued unchanged.
- Design point: since the base bits `1:0` are cleared and the displacement is a multiple of `4`, the effective address is always a multiple of `4`; for a `1`-byte access `Fault_DataAlignment` is unreachable.

<!-- PTO-READER-BLOCK: scalar-lb-pcr-example role=example -->
## Reading one encoding end to end

This example demonstrates the address calculation only; exact behavior remains in the current ASL and instruction contract.

- With `TPC` = `0x108` and `simm17` = `-2`, the byte displacement is `-8` and the address is `0x100`.
- A byte `0xFF` at `0x100` publishes `0xFFFFFFFFFFFFFFFF`, because the load is signed.
- Because the base is aligned down to a `4`-byte boundary, a `TPC` of `0x106` would use the same `0x104` base.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
lb.pcr [symbol], ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| lb_pcr_32_3fa2540b22d0 | L32 | 32 | 0x00000039 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| lb_pcr_32_3fa2540b22d0 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| lb_pcr_32_3fa2540b22d0 | simm17 | 17 | signed | [{"instruction_lsb":15,"value_lsb":0,"width":17}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| lb_pcr_32_3fa2540b22d0 | RegDst | 5 | 0–31 | none | none | Reg5 loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| lb_pcr_32_3fa2540b22d0 | simm17 | 17 | 0–131071 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 loaded-value destination or discard |
| simm17 | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/LB.PCR.asl -->
```asl
readonly func InstructionContractOperation_LB_PCR() => ScalarOperation
begin
    return ScalarOperation_LB_PCR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/LB.PCR.asl -->
```asl
readonly func InstructionContractHandler_LB_PCR()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;

pure func InstructionContractAGUAction_LB_PCR()
    => ScalarAGUAction
begin
    return ScalarAGU_Load;
end;

pure func InstructionContractAGUAddressKind_LB_PCR()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_PCRelative;
end;

pure func InstructionContractAGUSizeBytes_LB_PCR()
    => integer {1,2,4,8}
begin
    return 1;
end;

pure func InstructionContractAGUOffsetScale_LB_PCR()
    => integer {0..3}
begin
    return 2;
end;

pure func InstructionContractAGUUpdateMode_LB_PCR()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_LB_PCR()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_LB_PCR()
    => boolean
begin
    return FALSE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Every displayed operand field is encoded explicitly; encoded zero is a value and never denotes omission.

## Legality

- Every Reg5 destination is assigned: codes 1..23 write GPRs, code 30 pushes U, code 31 pushes T, and codes 0 and 24..29 discard only that result.
- simm17 assigns every signed 17-bit value -65536..65535; the encoded byte displacement is that value multiplied by 4.
- Each memory address must be aligned to the 1-byte access size; a 1-byte access is the complete transfer unit.

## State effects

- Clear TPC bits 1:0, sign-extend the encoded displacement, multiply it by four, and add it modulo 2^PTO_XLEN.
- After a successful 1-byte load, sign-extend the loaded value to PTO_XLEN and publish it through the destination.
- Successful execution advances TPC by 4 bytes; a rejected or faulting attempt does not retire.

## Memory effects and ordering

### Memory effects

- After complete preflight, perform one little-endian 1-byte load and record one relaxed load event.
- The load preserves memory and reservation state.

### Ordering

- Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.
- Complete the relaxed 1-byte memory operation, publish any result or writeback, and then advance TPC.

## Exceptions

- A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.
- A misaligned 1-byte address raises Fault_DataAlignment before translation or permission. A later permission or bounded-memory failure raises Fault_DataPage at the original address.
- A fault emits no successful memory event, performs no partial memory or destination effect, preserves pending writeback, and leaves TPC at the faulting instruction.
- Recovery performs a full reissue: every address, source snapshot, preflight, memory operation, and destination is recomputed with no retained progress.

## Examples

- lb.pcr [symbol], ->{t, u, Rd}

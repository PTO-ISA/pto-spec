<!-- GENERATED FROM: asl/scalar/agu/LDI.asl -->
# LDI

**Normative ASL source:** `asl/scalar/agu/LDI.asl`

LDI snapshots its scalar sources, forms its encoded address, and loads one aligned little-endian 8-byte value.

## Normative identity {#PTO-INST-SCALAR-LDI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-ldi-purpose role=purpose -->
## What `LDI` does

`LDI` loads one `8`-byte little-endian unit at a scaled signed-immediate distance from a base register, so the immediate counts `8`-byte units rather than bytes.

The canonical assembly is `ldi [SrcL, simm], ->{t, u, Rd}`.

Design point: scaling the `12`-bit field by `8` widens the byte window to `-16384`..`16376`, the widest reach available to a `simm12` scalar load, at the price of `8`-byte granularity.

<!-- PTO-READER-BLOCK: scalar-ldi-mechanism role=mechanism -->
## How the address and the transfer are formed

`LDI` sign-extends `simm12` and shifts it left by `3`, which is the multiplication by `8` recorded in the address kind. The result is added to the `SrcL` snapshot modulo `2^PTO_XLEN`.

Preflight tests `8`-byte alignment, then translation, then permission and bounded memory. On success `8` bytes are read little-endian and one relaxed load event is recorded.

The `64` loaded bits are published unchanged; no extension and no base write-back is performed.

Design point: the byte displacement is always a multiple of `8`, so the low three bits of the effective address come only from the base. A base that is not a multiple of `8` makes every encoding of `LDI` misaligned.

<!-- PTO-READER-BLOCK: scalar-ldi-inputs role=inputs-outputs -->
## Encoded fields and roles

- `SrcL` is the base selector. Codes `0`..`23` select absolute GPRs, `24`..`27` select `T#1`..`T#4`, and `28`..`31` select `U#1`..`U#4`; queue entries are read without being consumed.
- `simm12` is signed, covers `-2048`..`2047` units, and is scaled by `8`, so the byte displacement covers `-16384`..`16376`.
- `RegDst` is the destination selector. Codes `1`..`23` write GPRs, `30` pushes the `U` queue, `31` pushes the `T` queue, and `0` plus `24`..`29` publish nothing; code `0` is the architectural zero GPR, whose writes are discarded.
- Design point: there is no `SrcRType` and no `shamt` field; the scale is fixed by the instruction, so no operand selects the reach or the granularity of `LDI`.

<!-- PTO-READER-BLOCK: scalar-ldi-effects role=effects -->
## Effects, ordering, and completion

The base is snapshotted before the memory operation, so a later write to the same register cannot move the address of this load.

Success records one relaxed load event, writes no memory, preserves the reservation, publishes the `64` loaded bits, and advances `TPC` by `4` bytes.

Design point: the same `simm12` value means a different byte distance here than in the unscaled `.u` form, so the two forms are not interchangeable for a given encoded field.

<!-- PTO-READER-BLOCK: scalar-ldi-constraints role=constraints -->
## Legality, faults, and restart

- A fixed-bit mismatch, or a `SrcL` selector naming an unavailable `T`/`U` queue entry, raises `Fault_IllegalInstruction` before the base is read.
- A sum that is not a multiple of `8` raises `Fault_DataAlignment` before translation; a later permission or bounded-memory failure raises `Fault_DataPage` at the original effective address.
- A fault records no event, publishes nothing, and leaves `TPC` on the faulting instruction for a full reissue.
- Design point: because scaling preserves the base's low three bits, the `LDI` alignment check is effectively a property of the base register rather than of the immediate.

<!-- PTO-READER-BLOCK: scalar-ldi-example role=example -->
## Reading one encoding end to end

This example demonstrates the address calculation only; exact behavior remains in the current ASL and instruction contract.

- With `SrcL` = `0x2000` and `simm12` = `-1`, the byte displacement is `-8` and the address is `0x1FF8`, which is `8`-byte aligned.
- With `SrcL` = `0x2004` and the same `simm12`, the address is `0x1FFC`, which is not `8`-byte aligned, so `Fault_DataAlignment` is raised.
- The `8` bytes read on the successful attempt reach `RegDst` unchanged, with the lowest address holding the least significant byte.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
ldi [SrcL, simm], ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| ldi_32_d82a643f7a2b | L32 | 32 | 0x00003019 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| ldi_32_d82a643f7a2b | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| ldi_32_d82a643f7a2b | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| ldi_32_d82a643f7a2b | simm12 | 12 | signed | [{"instruction_lsb":20,"value_lsb":0,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| ldi_32_d82a643f7a2b | RegDst | 5 | 0–31 | none | none | Reg5 loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| ldi_32_d82a643f7a2b | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| ldi_32_d82a643f7a2b | simm12 | 12 | 0–4095 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 loaded-value destination or discard |
| SrcL | Reg5 address-base source |
| simm12 | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/LDI.asl -->
```asl
readonly func InstructionContractOperation_LDI() => ScalarOperation
begin
    return ScalarOperation_LDI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/LDI.asl -->
```asl
readonly func InstructionContractHandler_LDI()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;

pure func InstructionContractAGUAction_LDI()
    => ScalarAGUAction
begin
    return ScalarAGU_Load;
end;

pure func InstructionContractAGUAddressKind_LDI()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Immediate;
end;

pure func InstructionContractAGUSizeBytes_LDI()
    => integer {1,2,4,8}
begin
    return 8;
end;

pure func InstructionContractAGUOffsetScale_LDI()
    => integer {0..3}
begin
    return 3;
end;

pure func InstructionContractAGUUpdateMode_LDI()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_LDI()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_LDI()
    => boolean
begin
    return FALSE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Every displayed operand field is encoded explicitly; encoded zero is a value and never denotes omission.

## Legality

- Every encoded Reg5 source uses the complete domain: codes 0..23 select absolute GPRs, codes 24..27 select T#1..T#4, and codes 28..31 select U#1..U#4 without consumption.
- Every Reg5 destination is assigned: codes 1..23 write GPRs, code 30 pushes U, code 31 pushes T, and codes 0 and 24..29 discard only that result.
- simm12 assigns every signed 12-bit value -2048..2047; the encoded byte displacement is that value multiplied by 8.
- Each memory address must be aligned to the 8-byte access size; a 8-byte access is the complete transfer unit.

## State effects

- Sign-extend simm12, multiply it by 8, and add it modulo 2^PTO_XLEN to the SrcL base.
- After a successful 8-byte load, preserve the complete 64-bit loaded bit pattern and publish it through the destination.
- Successful execution advances TPC by 4 bytes; a rejected or faulting attempt does not retire.

## Memory effects and ordering

### Memory effects

- After complete preflight, perform one little-endian 8-byte load and record one relaxed load event.
- The load preserves memory and reservation state.

### Ordering

- Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.
- Complete the relaxed 8-byte memory operation, publish any result or writeback, and then advance TPC.

## Exceptions

- A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.
- A misaligned 8-byte address raises Fault_DataAlignment before translation or permission. A later permission or bounded-memory failure raises Fault_DataPage at the original address.
- A fault emits no successful memory event, performs no partial memory or destination effect, preserves pending writeback, and leaves TPC at the faulting instruction.
- Recovery performs a full reissue: every address, source snapshot, preflight, memory operation, and destination is recomputed with no retained progress.

## Examples

- ldi [SrcL, simm], ->{t, u, Rd}

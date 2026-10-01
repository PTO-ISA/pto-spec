<!-- GENERATED FROM: asl/scalar/agu/C.LDI.asl -->
# C.LDI

**Normative ASL source:** `asl/scalar/agu/C.LDI.asl`

C.LDI snapshots its scalar sources, forms its encoded address, and loads one aligned little-endian 8-byte value.

## Normative identity {#PTO-INST-SCALAR-C-LDI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-c-ldi-purpose role=purpose -->
## What `C.LDI` does

`C.LDI` is a `16`-bit compressed load. It reads one `8`-byte little-endian value from memory and pushes it as the newest temporary-queue value. The base is the `SrcL` selector, the byte displacement is the sign-extended `simm5` field multiplied by `8`, and the loaded `64`-bit pattern is published without any extension.

The compressed encoding has no destination field at all, so the loaded value always goes to the `T` queue and no encoding of this form discards it.

Design point: publication is a queue push, not a write to a named register. The push makes the new value `T#1` and moves the previous `T#1`, `T#2`, and `T#3` to `T#2`, `T#3`, and `T#4`, dropping the previous `T#4`. One `C.LDI` therefore changes four `T` slots, and a later read of `T#2` sees the value that `T#1` held before this instruction.

<!-- PTO-READER-BLOCK: scalar-c-ldi-mechanism role=mechanism -->
## How the address and the transfer are formed

The address path snapshots `SrcL`, sign-extends `simm5`, shifts it left by `3` bits, and adds the two modulo `2^PTO_XLEN`.

This form records no base writeback. The computed address is used for the access and then discarded, so `SrcL` keeps its pre-instruction value on every path, including the faulting path.

After the encoding checks and the address preflight succeed, the handler performs one aligned `8`-byte little-endian load and keeps the complete `64`-bit pattern. The queue push runs only when the memory operation reported no fault.

Design point: the scale equals the access size, so every encoded displacement is a multiple of `8`; the signed `5`-bit field reaches `-128` to `120` bytes in steps of `8`. With an `8`-byte-aligned `SrcL` the effective address is also `8`-byte aligned, so the displacement alone cannot break the alignment rule.

<!-- PTO-READER-BLOCK: scalar-c-ldi-inputs role=inputs-outputs -->
## Encoded fields and where the value goes

- `SrcL` is a `5`-bit Reg5 selector: codes `0`..`23` name absolute GPRs, codes `24`..`27` name `T#1`..`T#4`, and codes `28`..`31` name `U#1`..`U#4`. Reading a `T` or `U` selector leaves that queue unchanged.
- `simm5` is a signed `5`-bit displacement, scaled by `8`. Every one of its `32` encodings is a value; the encoding carries no way to mark the field as omitted.
- The destination is implicit `T#1`. No field selects it, and no field can suppress it.

Design point: an encoded `SrcL` of `0` names the architectural zero GPR, which reads as zero and ignores writes, so `c.ldi [0, simm], ->t` addresses memory with the displacement alone. An encoded `simm5` of `0` supplies a displacement of zero rather than omission, because a `16`-bit form has no presence bit to distinguish the two.

<!-- PTO-READER-BLOCK: scalar-c-ldi-effects role=effects -->
## Effects, ordering, and completion

The `SrcL` read happens before any memory or queue effect, so a source that aliases the pushed `T` slot still contributes its pre-instruction value.

Successful execution performs one relaxed load and records one load event. Memory bytes and any reservation state are unchanged.

After the push completes, `C.LDI` advances `TPC` by `2` bytes. A rejected or faulting attempt does not retire and leaves `TPC` on the same instruction.

Design point: the push is the handler's last step, so a faulting load leaves the `T` queue as it was; no state shows the new value in `T#1` while the load failed.

<!-- PTO-READER-BLOCK: scalar-c-ldi-constraints role=constraints -->
## Legality, faults, and restart

A fixed-bit mismatch in the `16`-bit encoding raises `Fault_IllegalInstruction` before any effect. An `SrcL` code that selects a `T` or `U` slot whose validity flag is clear raises the same fault at the same point, and no memory access is attempted.

The preflight tests the low `3` bits of the effective address: values other than zero raise `Fault_DataAlignment` before address translation and before any permission check. For an aligned address, a permission or bounded-memory failure raises `Fault_DataPage` at the original address.

A fault records no load event, writes no queue slot, and leaves `TPC` on the faulting instruction. Recovery reissues the whole operation: snapshot, address, preflight, load, and push, with no retained progress.

<!-- PTO-READER-BLOCK: scalar-c-ldi-example role=example -->
## Reading one encoding end to end

This walkthrough explains how to use the page and does not add instruction behavior.

- Take `c.ldi [5, -3], ->t` with GPR5 holding `0x2000`. The signed `simm5` is `-3`, scaled by `8` gives `-24`, so the effective address is `0x2000` minus `24`, which is `0x1FE8`.
- The instruction reads the `8` bytes at `0x1FE8` through `0x1FEF` and publishes the whole `64`-bit pattern as the new `T#1`.
- GPR5 still holds `0x2000`, because this form has no base writeback, and `TPC` becomes the instruction address plus `2`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
c.ldi [srcL, simm], ->t
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| c_ldi_16_973f42d37f29 | C16 | 16 | 0x001a / 0x003f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| c_ldi_16_973f42d37f29 | SrcL | 5 | encoding-defined | [{"instruction_lsb":6,"value_lsb":0,"width":5}] |
| c_ldi_16_973f42d37f29 | simm5 | 5 | signed | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| c_ldi_16_973f42d37f29 | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| c_ldi_16_973f42d37f29 | simm5 | 5 | 0–31 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 address-base source |
| simm5 | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/C.LDI.asl -->
```asl
readonly func InstructionContractOperation_C_LDI() => ScalarOperation
begin
    return ScalarOperation_C_LDI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/C.LDI.asl -->
```asl
readonly func InstructionContractHandler_C_LDI()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;

pure func InstructionContractAGUAction_C_LDI()
    => ScalarAGUAction
begin
    return ScalarAGU_Load;
end;

pure func InstructionContractAGUAddressKind_C_LDI()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Compressed;
end;

pure func InstructionContractAGUSizeBytes_C_LDI()
    => integer {1,2,4,8}
begin
    return 8;
end;

pure func InstructionContractAGUOffsetScale_C_LDI()
    => integer {0..3}
begin
    return 3;
end;

pure func InstructionContractAGUUpdateMode_C_LDI()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_C_LDI()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_C_LDI()
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
- simm5 assigns every signed 5-bit value -16..15; the encoded byte displacement is that value multiplied by 8.
- Each memory address must be aligned to the 8-byte access size; a 8-byte access is the complete transfer unit.

## State effects

- Sign-extend simm5, multiply it by 8, and add it modulo 2^PTO_XLEN to the SrcL base.
- After a successful 8-byte load, preserve the complete 64-bit loaded bit pattern and publish it through the destination.
- Successful execution advances TPC by 2 bytes; a rejected or faulting attempt does not retire.

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

- c.ldi [srcL, simm], ->t

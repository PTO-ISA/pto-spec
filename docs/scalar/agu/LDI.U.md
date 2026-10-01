<!-- GENERATED FROM: asl/scalar/agu/LDI.U.asl -->
# LDI.U

**Normative ASL source:** `asl/scalar/agu/LDI.U.asl`

LDI.U snapshots its scalar sources, forms its encoded address, and loads one aligned little-endian 8-byte value.

## Normative identity {#PTO-INST-SCALAR-LDI-U}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-ldi-u-purpose role=purpose -->
## What `LDI.U` does

`LDI.U` loads one `8`-byte little-endian unit at an unscaled signed-immediate distance from a base register. The immediate counts bytes, so the field can land on any byte offset.

The canonical assembly is `ldi.u [SrcL, simm], ->{t, u, Rd}`.

Design point: the `.u` form keeps the `8`-byte transfer but drops the `8`-byte scale, so `simm12` reaches `-2048`..`2047` bytes and can be any residue modulo `8`.

<!-- PTO-READER-BLOCK: scalar-ldi-u-mechanism role=mechanism -->
## How the address and the transfer are formed

The sign-extended `simm12` is added, unscaled, to the `SrcL` snapshot modulo `2^PTO_XLEN`. Each encoded unit is worth `1` byte of address.

Preflight tests `8`-byte alignment, then translation, then permission and bounded memory. On success `8` bytes are read little-endian, one relaxed load event is recorded, and the `64` bits are published unchanged.

Only the immediate and the base participate in the address; the form has no index register and no destination for an updated base.

Design point: an unscaled immediate can be any residue modulo `8`, so this form can align a base that is otherwise misaligned; the sum, not the base alone, must still be a multiple of `8`.

<!-- PTO-READER-BLOCK: scalar-ldi-u-inputs role=inputs-outputs -->
## Encoded fields and roles

- `SrcL` is the base selector. Codes `0`..`23` select absolute GPRs, `24`..`27` select `T#1`..`T#4`, and `28`..`31` select `U#1`..`U#4`; queue entries are read without being consumed.
- `simm12` is signed, covers `-2048`..`2047`, and is used without scaling, so each unit is one byte.
- `RegDst` is the destination selector. Codes `1`..`23` write GPRs, `30` pushes the `U` queue, `31` pushes the `T` queue, and `0` plus `24`..`29` publish nothing; code `0` is the architectural zero GPR, whose writes are discarded.
- Design point: the byte-granular window is much shorter than the scaled `8`-byte window, so the two forms answer different questions: one trades reach for a finer step.

<!-- PTO-READER-BLOCK: scalar-ldi-u-effects role=effects -->
## Effects, ordering, and completion

All sources are snapshotted before the memory operation and before publication, so the value read never depends on a write performed by this instruction.

Success records one relaxed load event, leaves memory and reservation state unchanged, and advances `TPC` by `4` bytes.

Design point: the full `64`-bit pattern reaches `RegDst`, so this form is the byte-addressed way to fetch a whole-width value.

<!-- PTO-READER-BLOCK: scalar-ldi-u-constraints role=constraints -->
## Legality, faults, and restart

- A fixed-bit mismatch, or a `SrcL` selector naming an unavailable `T`/`U` entry, raises `Fault_IllegalInstruction` before any effect.
- A sum that is not a multiple of `8` raises `Fault_DataAlignment` before translation; a later permission or bounded-memory failure raises `Fault_DataPage` at the original effective address.
- A fault records no event, publishes nothing, and keeps `TPC` on the faulting instruction so the attempt can be reissued.
- Design point: the `.u` suffix changes the scale only; the transfer width and therefore the alignment rule stay at `8` bytes.

<!-- PTO-READER-BLOCK: scalar-ldi-u-example role=example -->
## Reading one encoding end to end

This example demonstrates the address calculation only; exact behavior remains in the current ASL and instruction contract.

- With `SrcL` = `0x2004` and `simm12` = `4`, the address is `0x2008`, which is `8`-byte aligned; the unscaled immediate repaired a misaligned base.
- With `SrcL` = `0x2004` and `simm12` = `1`, the address is `0x2005` and `Fault_DataAlignment` is raised.
- As in `LDI`, the successful case publishes the `8` bytes as one `64`-bit value with no extension.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
ldi.u [SrcL, simm], ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| ldi_u_32_111bb521a439 | L32 | 32 | 0x00003029 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| ldi_u_32_111bb521a439 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| ldi_u_32_111bb521a439 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| ldi_u_32_111bb521a439 | simm12 | 12 | signed | [{"instruction_lsb":20,"value_lsb":0,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| ldi_u_32_111bb521a439 | RegDst | 5 | 0–31 | none | none | Reg5 loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| ldi_u_32_111bb521a439 | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| ldi_u_32_111bb521a439 | simm12 | 12 | 0–4095 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 loaded-value destination or discard |
| SrcL | Reg5 address-base source |
| simm12 | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/LDI.U.asl -->
```asl
readonly func InstructionContractOperation_LDI_U() => ScalarOperation
begin
    return ScalarOperation_LDI_U;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/LDI.U.asl -->
```asl
readonly func InstructionContractHandler_LDI_U()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;

pure func InstructionContractAGUAction_LDI_U()
    => ScalarAGUAction
begin
    return ScalarAGU_Load;
end;

pure func InstructionContractAGUAddressKind_LDI_U()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Immediate;
end;

pure func InstructionContractAGUSizeBytes_LDI_U()
    => integer {1,2,4,8}
begin
    return 8;
end;

pure func InstructionContractAGUOffsetScale_LDI_U()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_LDI_U()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_LDI_U()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_LDI_U()
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
- simm12 assigns every signed 12-bit value -2048..2047; the encoded byte displacement is that value multiplied by 1.
- Each memory address must be aligned to the 8-byte access size; a 8-byte access is the complete transfer unit.

## State effects

- Sign-extend simm12, multiply it by 1, and add it modulo 2^PTO_XLEN to the SrcL base.
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

- ldi.u [SrcL, simm], ->{t, u, Rd}

<!-- GENERATED FROM: asl/scalar/agu/HL.LDI.U.asl -->
# HL.LDI.U

**Normative ASL source:** `asl/scalar/agu/HL.LDI.U.asl`

HL.LDI.U snapshots its scalar sources, forms its encoded address, and loads one aligned little-endian 8-byte value.

## Normative identity {#PTO-INST-SCALAR-HL-LDI-U}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-ldi-u-purpose role=purpose -->
## What `HL.LDI.U` does

`HL.LDI.U` is a `48`-bit load of one `8`-byte little-endian value with an unscaled `22`-bit immediate displacement and no base update. It adds the immediate to the `SrcL` base byte for byte, reads eight bytes at the sum, and publishes the complete `64`-bit pattern to `RegDst`.

The canonical assembly is `hl.ldi.u [SrcL, simm], ->{t, u, Rd}`.

Design point: the immediate is not scaled, so it counts bytes while the access covers eight of them. The alignment preflight requires the sum to be a multiple of `8`, which means that with an `8`-byte-aligned base only the immediates that are themselves multiples of `8` produce a legal access. The form therefore reaches any byte in a `4194304`-byte window, but only one eighth of those addresses can carry an `8`-byte load.

<!-- PTO-READER-BLOCK: scalar-hl-ldi-u-mechanism role=mechanism -->
## How the address and the transfer are formed

The signed `22`-bit immediate is sign-extended and added to the snapshot of `SrcL` modulo `2^PTO_XLEN`. The update mode is none, so the sum is the effective address and nothing is published except the loaded value.

`SrcL` is only read, and the handler computes no updated base for publication at all.

After the encoding checks and the address preflight pass, the handler performs one `8`-byte little-endian load and publishes the bytes unchanged to `RegDst`.

Design point: an immediate load whose scale does not match its access size shifts the burden of alignment onto the encoded field. Because the immediate is a compile-time constant, the subset of values that are multiples of `8` can be chosen when the instruction is assembled, and no run-time check is needed to separate them from the rest.

<!-- PTO-READER-BLOCK: scalar-hl-ldi-u-inputs role=inputs-outputs -->
## Encoded fields and the result

- `SrcL` is a `5`-bit Reg5 selector over absolute GPRs, `T#1`..`T#4`, and `U#1`..`U#4`.
- `simm22` is a signed `22`-bit immediate covering `-2097152` to `2097151` bytes, used without scaling.
- `RegDst` is a `5`-bit selector: codes `1`..`23` write absolute GPRs, `30` pushes `U`, `31` pushes `T`, and `0` and `24`..`29` discard the value alone.

Design point: the loaded `64` bits are published without an extension step, so the destination holds the exact memory image. For this width the recorded signedness has no effect, because the normalization of an `8`-byte value is the identity in both directions.

<!-- PTO-READER-BLOCK: scalar-hl-ldi-u-effects role=effects -->
## Effects, ordering, and completion

`SrcL` is snapshotted before any memory or destination effect, so a destination that names the base still supplies the pre-instruction value to the address.

A successful execution records one relaxed `8`-byte load event and leaves memory bytes and reservation state unchanged. `TPC` advances by `6` bytes after the publication; a rejected or faulting attempt does not retire.

Design point: because a fault publishes nothing and the base is never advanced by the instruction, a retry repeats exactly the same access. There is no state that would have to be rewound, and no chance of skipping a byte between two attempts.

<!-- PTO-READER-BLOCK: scalar-hl-ldi-u-constraints role=constraints -->
## Legality, faults, and restart

A fixed-bit mismatch raises `Fault_IllegalInstruction` before any effect, and an unavailable `T` or `U` slot named by `SrcL` raises the same fault before execution. No transform or shift field exists in this encoding.

The preflight tests the low `3` bits of the effective address and raises `Fault_DataAlignment` before translation and before the permission check, which is the outcome for any immediate that is not a multiple of `8` when the base is `8`-byte aligned. An aligned address that fails the permission or bounded-memory test raises `Fault_DataPage` at the original address.

A fault records no load event, writes no destination, and leaves `TPC` on the faulting instruction. Recovery repeats the sign extension, the sum, and the preflight.

<!-- PTO-READER-BLOCK: scalar-hl-ldi-u-example role=example -->
## Reading one encoding end to end

This walkthrough explains how to use the page and does not add instruction behavior.

- Take `hl.ldi.u [6, 8], ->5` with GPR6 = `0xC000`. The immediate is `8`, which is a multiple of `8`, so the effective address is `0xC008` and it is `8`-byte aligned.
- The instruction reads the `8` bytes at `0xC008` through `0xC00F` and publishes the whole `64`-bit pattern to GPR5.
- With an immediate of `1` instead the address would be `0xC001`, and the instruction would raise `Fault_DataAlignment` before translation.
- GPR6 still holds `0xC000`, and `TPC` becomes the instruction address plus `6`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.ldi.u [SrcL, simm], ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_ldi_u_48_894d02c12dcc | HL48 | 48 | 0x00003029000e / 0x0000707f003f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_ldi_u_48_894d02c12dcc | RegDst | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_ldi_u_48_894d02c12dcc | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_ldi_u_48_894d02c12dcc | simm22 | 22 | signed | [{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":6,"value_lsb":12,"width":10}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_ldi_u_48_894d02c12dcc | RegDst | 5 | 0–31 | none | none | Reg5 loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_ldi_u_48_894d02c12dcc | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| hl_ldi_u_48_894d02c12dcc | simm22 | 22 | 0–4194303 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 loaded-value destination or discard |
| SrcL | Reg5 address-base source |
| simm22 | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.LDI.U.asl -->
```asl
readonly func InstructionContractOperation_HL_LDI_U() => ScalarOperation
begin
    return ScalarOperation_HL_LDI_U;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.LDI.U.asl -->
```asl
readonly func InstructionContractHandler_HL_LDI_U()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;

pure func InstructionContractAGUAction_HL_LDI_U()
    => ScalarAGUAction
begin
    return ScalarAGU_Load;
end;

pure func InstructionContractAGUAddressKind_HL_LDI_U()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Immediate;
end;

pure func InstructionContractAGUSizeBytes_HL_LDI_U()
    => integer {1,2,4,8}
begin
    return 8;
end;

pure func InstructionContractAGUOffsetScale_HL_LDI_U()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_HL_LDI_U()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_HL_LDI_U()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_LDI_U()
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
- simm22 assigns every signed 22-bit value -2097152..2097151; the encoded byte displacement is that value multiplied by 1.
- Each memory address must be aligned to the 8-byte access size; a 8-byte access is the complete transfer unit.

## State effects

- Sign-extend simm22, multiply it by 1, and add it modulo 2^PTO_XLEN to the SrcL base.
- After a successful 8-byte load, preserve the complete 64-bit loaded bit pattern and publish it through the destination.
- Successful execution advances TPC by 6 bytes; a rejected or faulting attempt does not retire.

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

- hl.ldi.u [SrcL, simm], ->{t, u, Rd}

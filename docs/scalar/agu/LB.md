<!-- GENERATED FROM: asl/scalar/agu/LB.asl -->
# LB

**Normative ASL source:** `asl/scalar/agu/LB.asl`

LB snapshots its scalar sources, forms its encoded address, and loads one aligned little-endian 1-byte value.

## Normative identity {#PTO-INST-SCALAR-LB}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-lb-purpose role=purpose -->
## What LB does

`LB` is a standalone `32`-bit AGU instruction that forms a register-offset address and loads one aligned little-endian `1`-byte value.

<!-- PTO-READER-BLOCK: scalar-lb-mechanism role=mechanism -->
## Address and memory mechanism

`LB` transforms `SrcR` according to `SrcRType`, shifts the transformed value left by the encoded `shamt`, and adds it modulo `2^PTO_XLEN` to the snapshotted `SrcL` base.

After complete preflight, the instruction performs one little-endian `1`-byte load and sign-extends the loaded `1`-byte value to `PTO_XLEN` for destination publication.

This form performs no base-register writeback; its effective address is used only by the selected memory operation.

<!-- PTO-READER-BLOCK: scalar-lb-inputs role=inputs-outputs -->
## Inputs and outputs

- `SrcL` supplies the base; `SrcR` supplies the offset; `SrcRType` supplies the offset transformation. Every encoded Reg5 source among `SrcL`, `SrcR` uses codes `0..23` for GPRs, `24..27` for `T#1..T#4`, and `28..31` for `U#1..U#4` without consumption.
- `RegDst` receives the loaded result; destination codes `1..23` write GPRs, `30` pushes U, `31` pushes T, and `0` plus `24..29` discard only that result.
- All `SrcRType` values `0..3` and all `shamt` values `0..31` are assigned; transformation precedes the encoded shift.

<!-- PTO-READER-BLOCK: scalar-lb-effects role=effects -->
## Effects and ordering

All explicit and implicit scalar sources are snapshotted before memory or destination effects, so aliases observe pre-instruction values.

A successful attempt records one relaxed load event, preserves memory and reservation state, publishes or discards the loaded value, and advances `TPC` by `4` bytes.

<!-- PTO-READER-BLOCK: scalar-lb-constraints role=constraints -->
## Alignment, faults, and restart

Each effective address must satisfy `1`-byte alignment. Misalignment raises `Fault_DataAlignment` before translation; a later permission or bounded-memory failure raises `Fault_DataPage` at the original address.

A fault records no successful memory event, performs no partial memory, destination, or writeback effect, preserves pending writeback, and leaves the faulting `TPC` available for full reissue.

A fixed-bit mismatch, reserved field value, or unavailable selected `T`/`U` source raises `Fault_IllegalInstruction` before instruction effects.

<!-- PTO-READER-BLOCK: scalar-lb-example role=example -->
## Non-normative address example

This example demonstrates the address calculation only; exact behavior remains in the current ASL and instruction contract.

With base `0x100`, unchanged offset source `2`, and `shamt=1`, the offset is `4` and base plus offset is `0x104`. The memory access uses `0x104`. If aligned and permitted, the instruction loads `1` byte from that address.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
lb [SrcL, SrcR<{.sw,.uw,.neg}><<<shamt>], ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| lb_32_b718aa88e28f | L32 | 32 | 0x00000009 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| lb_32_b718aa88e28f | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| lb_32_b718aa88e28f | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| lb_32_b718aa88e28f | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| lb_32_b718aa88e28f | SrcRType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |
| lb_32_b718aa88e28f | shamt | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| lb_32_b718aa88e28f | RegDst | 5 | 0–31 | none | none | Reg5 loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| lb_32_b718aa88e28f | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| lb_32_b718aa88e28f | SrcR | 5 | 0–31 | none | none | Reg5 register-offset source | Encoded zero reads the architectural zero GPR. |
| lb_32_b718aa88e28f | SrcRType | 2 | 0–3 | none | none | register-offset transformation selector | Encoded zero sign-extends SrcR[31:0] to PTO_XLEN; it does not mean an omitted modifier. |
| lb_32_b718aa88e28f | shamt | 5 | 0–31 | none | none | post-transformation logical-left-shift amount | Encoded zero performs no shift. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 loaded-value destination or discard |
| SrcL | Reg5 address-base source |
| SrcR | Reg5 register-offset source |
| SrcRType | register-offset transformation selector |
| shamt | post-transformation logical-left-shift amount |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/LB.asl -->
```asl
readonly func InstructionContractOperation_LB() => ScalarOperation
begin
    return ScalarOperation_LB;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/LB.asl -->
```asl
readonly func InstructionContractHandler_LB()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;

pure func InstructionContractAGUAction_LB()
    => ScalarAGUAction
begin
    return ScalarAGU_Load;
end;

pure func InstructionContractAGUAddressKind_LB()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Register;
end;

pure func InstructionContractAGUSizeBytes_LB()
    => integer {1,2,4,8}
begin
    return 1;
end;

pure func InstructionContractAGUOffsetScale_LB()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_LB()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_LB()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_LB()
    => boolean
begin
    return FALSE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Every displayed operand field is encoded explicitly; encoded zero is a value and never denotes omission.
- SrcRType=0 sign-extends SrcR[31:0], SrcRType=1 zero-extends SrcR[31:0], SrcRType=2 negates the full PTO_XLEN value, and SrcRType=3 leaves the complete PTO_XLEN value unchanged. Encoded shamt zero performs no shift.

## Legality

- Every encoded Reg5 source uses the complete domain: codes 0..23 select absolute GPRs, codes 24..27 select T#1..T#4, and codes 28..31 select U#1..U#4 without consumption.
- Every Reg5 destination is assigned: codes 1..23 write GPRs, code 30 pushes U, code 31 pushes T, and codes 0 and 24..29 discard only that result.
- All four SrcRType values and all shamt values 0..31 are assigned; apply the modifier before the shift.
- Each memory address must be aligned to the 1-byte access size; a 1-byte access is the complete transfer unit.

## State effects

- Form offset = LSL(Modify(SrcR, SrcRType), the encoded shamt) and add it modulo 2^PTO_XLEN to the SrcL base.
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

- lb [SrcL, SrcR<{.sw,.uw,.neg}><<<shamt>], ->{t, u, Rd}

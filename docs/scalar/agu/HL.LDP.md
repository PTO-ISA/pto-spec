<!-- GENERATED FROM: asl/scalar/agu/HL.LDP.asl -->
# HL.LDP

**Normative ASL source:** `asl/scalar/agu/HL.LDP.asl`

HL.LDP snapshots its scalar sources, forms its encoded address, and loads two adjacent aligned little-endian 8-byte values.

## Normative identity {#PTO-INST-SCALAR-HL-LDP}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-ldp-purpose role=purpose -->
## What `HL.LDP` does

`HL.LDP` is a standalone 48-bit load. It takes its base from `SrcL` and its offset from `SrcR`, which it transforms and shifts, and it loads two adjacent 8-byte values into two destinations.

<!-- PTO-READER-BLOCK: scalar-hl-ldp-mechanism role=mechanism -->
## Address and load mechanism

`SrcR` is read, transformed by `SrcRType`, and then shifted left by the encoded `shamt`. That result is the offset, and it is byte-granular whenever `shamt` is zero.

The offset is added to the snapshotted `SrcL` value modulo `2^PTO_XLEN`.

Both addresses are preflighted before either load: the second address is the first address plus `8` bytes. Only after both probes pass does the instruction read the two little-endian values and record two relaxed load events in address order.

There is no base writeback: `Dst0` and `Dst1` are both loaded values, and `Dst1` is not an address.

The byte at the accessed address becomes bits `7:0` of the result and later bytes fill higher bits, so the value is little-endian, and the instruction will preserve the complete `64`-bit loaded bit pattern.

**Design point:** `HL.LDP` takes its offset from a register, so the address varies at run time while the encoding stays fixed. `SrcRType` rewrites only bits `31:0` of `SrcR`, so one form serves a full-width, a signed `32`-bit, or an unsigned `32`-bit offset, and `shamt=0` is an ordinary byte-granular offset rather than a reserved encoding.

<!-- PTO-READER-BLOCK: scalar-hl-ldp-inputs role=inputs-outputs -->
## Inputs and destinations

- `SrcL` is the address base and `SrcR` is the register offset; both use the complete Reg5 source domain, where codes `0..23` name absolute GPRs, codes `24..27` name `T#1..T#4`, and codes `28..31` name `U#1..U#4`.
- Reading a `T` or `U` selector does not consume or shift the queue it names; the queue index `1..4` is used as a source value only.
- `SrcRType` selects the transformation: encoded `0` leaves `SrcR` unchanged, encoded `1` sign-extends `SrcR[31:0]`, and encoded `2` zero-extends `SrcR[31:0]`.
- `shamt` assigns every value `0..31` and is a logical left shift applied after the modifier; encoded zero shifts by nothing.
- `Dst0` receives the value loaded from the first address and `Dst1` the value loaded from the second; both are loaded-value destinations, and neither is a base writeback.
- Both destination fields use the complete Reg5 destination domain: codes `1..23` write absolute GPRs, code `30` pushes U, code `31` pushes T, and codes `0` and `24..29` discard only that result without suppressing the rest of the instruction.
- Every displayed operand field is encoded explicitly, so encoded zero is a value and never denotes omission.

<!-- PTO-READER-BLOCK: scalar-hl-ldp-effects role=effects -->
## Effects and ordering

The base and the offset register are both read before the memory operation and before any destination write.

A successful attempt records two relaxed load events in address order, leaves memory and reservation state unchanged, publishes both loaded values, and advances `TPC` by `6` bytes.

**Design point:** `SrcR` is transformed before the destination write, so a destination that names `SrcR` transforms the pre-instruction value, not the value about to be published. The offset for one access is fixed when the instruction starts.

<!-- PTO-READER-BLOCK: scalar-hl-ldp-constraints role=constraints -->
## Alignment, faults, and restart

`SrcRType=3` is reserved and raises `Fault_IllegalInstruction` before any source is read and before any architectural effect.

The effective address must be aligned to the `8`-byte transfer size. Misalignment raises `Fault_DataAlignment` before translation; a translation or bounded-memory failure after that raises `Fault_DataPage` at the original address.

A fixed-bit mismatch, a reserved field value, or an unavailable selected `T` or `U` source raises `Fault_IllegalInstruction` before any instruction effect.

A fault emits no load event and writes no destination, and the address it records is the address that failed. Recovery reissues the whole instruction: the address, the source snapshot, every probe, the load, and every destination are recomputed with no retained progress.

**Design point:** both probes complete before either load is committed, so the pair cannot publish one destination and leave the other holding a pre-instruction value; a fault on the second probe therefore costs the first result as well.

<!-- PTO-READER-BLOCK: scalar-hl-ldp-example role=example -->
## Non-normative address example

This example illustrates the current address and publication rule and does not replace the normative load contract.

With `SrcL=0x2000`, `SrcR=0x10`, `SrcRType=0`, and `shamt=0`, the offset is `0x10`, so the two accesses are at `0x2010` and `0x2018`.

If both addresses are aligned and permitted, `Dst0` receives the value at `0x2010`, `Dst1` receives the value at `0x2018`, and `TPC` advances by `6` bytes.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.ldp [SrcL, SrcR<{.sw,.uw}><<<shamt>], ->Dst0, Dst1
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_ldp_48_a7a45a43dff9 | HL48 | 48 | 0x00003009001e / 0x0000707f07ff | [{"field":"SrcRType","operator":"one-of","values":[0,1,2]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_ldp_48_a7a45a43dff9 | RegDst0 | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_ldp_48_a7a45a43dff9 | RegDst1 | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_ldp_48_a7a45a43dff9 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_ldp_48_a7a45a43dff9 | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |
| hl_ldp_48_a7a45a43dff9 | SrcRType | 2 | encoding-defined | [{"instruction_lsb":41,"value_lsb":0,"width":2}] |
| hl_ldp_48_a7a45a43dff9 | shamt | 5 | encoding-defined | [{"instruction_lsb":43,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_ldp_48_a7a45a43dff9 | RegDst0 | 5 | 0–31 | none | none | Reg5 first loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_ldp_48_a7a45a43dff9 | RegDst1 | 5 | 0–31 | none | none | Reg5 second loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_ldp_48_a7a45a43dff9 | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| hl_ldp_48_a7a45a43dff9 | SrcR | 5 | 0–31 | none | none | Reg5 register-offset source | Encoded zero reads the architectural zero GPR. |
| hl_ldp_48_a7a45a43dff9 | SrcRType | 2 | 0–2 | none | 3 | register-offset transformation selector | Encoded zero leaves the complete PTO_XLEN register-offset value unchanged. |
| hl_ldp_48_a7a45a43dff9 | shamt | 5 | 0–31 | none | none | post-transformation logical-left-shift amount | Encoded zero performs no shift. |

- `hl_ldp_48_a7a45a43dff9.SrcRType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst0 | Reg5 first loaded-value destination or discard |
| RegDst1 | Reg5 second loaded-value destination or discard |
| SrcL | Reg5 address-base source |
| SrcR | Reg5 register-offset source |
| SrcRType | register-offset transformation selector |
| shamt | post-transformation logical-left-shift amount |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.LDP.asl -->
```asl
readonly func InstructionContractOperation_HL_LDP() => ScalarOperation
begin
    return ScalarOperation_HL_LDP;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.LDP.asl -->
```asl
readonly func InstructionContractHandler_HL_LDP()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoadPair;
end;

pure func InstructionContractAGUAction_HL_LDP()
    => ScalarAGUAction
begin
    return ScalarAGU_LoadPair;
end;

pure func InstructionContractAGUAddressKind_HL_LDP()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Register;
end;

pure func InstructionContractAGUSizeBytes_HL_LDP()
    => integer {1,2,4,8}
begin
    return 8;
end;

pure func InstructionContractAGUOffsetScale_HL_LDP()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_HL_LDP()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_HL_LDP()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_LDP()
    => boolean
begin
    return FALSE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Every displayed operand field is encoded explicitly; encoded zero is a value and never denotes omission.
- SrcRType=0 leaves SrcR unchanged, SrcRType=1 sign-extends SrcR[31:0], SrcRType=2 zero-extends SrcR[31:0], and SrcRType=3 is reserved. Encoded shamt zero performs no shift.

## Legality

- Every encoded Reg5 source uses the complete domain: codes 0..23 select absolute GPRs, codes 24..27 select T#1..T#4, and codes 28..31 select U#1..U#4 without consumption.
- Every Reg5 destination is assigned: codes 1..23 write GPRs, code 30 pushes U, code 31 pushes T, and codes 0 and 24..29 discard only that result.
- SrcRType values 0, 1, and 2 and all shamt values 0..31 are assigned; SrcRType=3 is reserved; apply the modifier before the shift.
- Each memory address must be aligned to the 8-byte access size; a 8-byte access is the complete transfer unit.

## State effects

- Form offset = LSL(Modify(SrcR, SrcRType), the encoded shamt) and add it modulo 2^PTO_XLEN to the SrcL base.
- The pair addresses are address and address plus 8; the instruction performs no base writeback.
- After both 8-byte probes succeed, preserve each result at PTO_XLEN and publish first then second.
- Successful execution advances TPC by 6 bytes; a rejected or faulting attempt does not retire.

## Memory effects and ordering

### Memory effects

- Preflight both adjacent 8-byte addresses before either load; on success record two relaxed load events in address order.

### Ordering

- Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.
- Preflight both addresses, commit the two relaxed 8-byte operations in address order, publish ordered results if any, then advance TPC.

## Exceptions

- A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.
- A misaligned 8-byte address raises Fault_DataAlignment before translation or permission. A later permission or bounded-memory failure raises Fault_DataPage at the original address.
- A fault emits no successful memory event, performs no partial memory or destination effect, preserves pending writeback, and leaves TPC at the faulting instruction.
- Recovery performs a full reissue: every address, source snapshot, preflight, memory operation, and destination is recomputed with no retained progress.

## Examples

- hl.ldp [SrcL, SrcR<{.sw,.uw}><<<shamt>], ->Dst0, Dst1

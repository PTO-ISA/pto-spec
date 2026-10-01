<!-- GENERATED FROM: asl/scalar/agu/C.LWI.asl -->
# C.LWI

**Normative ASL source:** `asl/scalar/agu/C.LWI.asl`

C.LWI snapshots its scalar sources, forms its encoded address, and loads one aligned little-endian 4-byte value.

## Normative identity {#PTO-INST-SCALAR-C-LWI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-c-lwi-purpose role=purpose -->
## What `C.LWI` does

`C.LWI` is a `16`-bit compressed load of one `4`-byte little-endian word. The base is the `SrcL` selector, the byte displacement is the sign-extended `simm5` field multiplied by `4`, and the loaded value is sign-extended to the full `PTO_XLEN` width before it becomes the newest temporary-queue value.

The compressed encoding has no destination field, so `C.LWI` always publishes to the `T` queue.

Design point: the extension is applied between the load and the publication, so the queue slot receives the extended `64`-bit value, not the raw `32` bits that the memory system returned. Loading the four bytes `FF FF FF FF` therefore makes `T#1` hold a value whose `64` bits are all ones, and a later consumer that compares `T#1` with `-1` succeeds without any further extension.

<!-- PTO-READER-BLOCK: scalar-c-lwi-mechanism role=mechanism -->
## How the address and the transfer are formed

The address path snapshots `SrcL`, sign-extends `simm5`, shifts it left by `2` bits, and adds the two modulo `2^PTO_XLEN`.

The form has no base writeback, so the computed address is consumed by the access and then discarded; `SrcL` keeps its pre-instruction value whether the access succeeds or faults.

Once the encoding checks and the address preflight pass, the handler performs one aligned `4`-byte little-endian load, sign-extends bit `31` of the result, and pushes the extended value. The push happens only if the load reported no fault.

Design point: the displacement scale equals the access size. Every byte displacement the form can encode is a multiple of `4`, and the signed `5`-bit field covers `-64` to `60` bytes in steps of `4`. A `4`-byte-aligned base therefore always produces a `4`-byte-aligned effective address, which is exactly what the `4`-byte access requires.

<!-- PTO-READER-BLOCK: scalar-c-lwi-inputs role=inputs-outputs -->
## Encoded fields and where the value goes

- `SrcL` is a `5`-bit Reg5 selector: codes `0`..`23` name absolute GPRs, codes `24`..`27` name `T#1`..`T#4`, and codes `28`..`31` name `U#1`..`U#4`. A `T` or `U` source is read without consuming it.
- `simm5` is a signed `5`-bit displacement scaled by `4`. All `32` encodings are values.
- The destination is implicit `T#1`, reached by a queue push that also moves the older entries towards `T#4`.

Design point: the fields that locate the value also decide how much of it is read; the scale factor and the extension rule come from the encoding, not from the data. Because publication is a queue push, the newest queue entry always describes the most recent load.

<!-- PTO-READER-BLOCK: scalar-c-lwi-effects role=effects -->
## Effects, ordering, and completion

The `SrcL` read is taken before any memory or queue effect, so a selector that aliases the pushed `T` slot still supplies its pre-instruction value.

Successful execution performs one relaxed `4`-byte load and records one load event. Memory bytes and any reservation state are unchanged.

After the push, `C.LWI` advances `TPC` by `2` bytes. A rejected or faulting attempt does not retire, so `TPC` stays on the faulting instruction.

Design point: the `4`-byte read and the `64`-bit push are separate steps with the extension between them, so an implementation that reports the fault after the memory stage still leaves the queue untouched: no partially extended value is ever visible.

<!-- PTO-READER-BLOCK: scalar-c-lwi-constraints role=constraints -->
## Legality, faults, and restart

A fixed-bit mismatch in the `16`-bit encoding raises `Fault_IllegalInstruction` before any effect. An `SrcL` code that selects a `T` or `U` slot whose validity flag is clear raises the same fault at the same point and no memory access is attempted.

The preflight tests the low `2` bits of the effective address. A nonzero value raises `Fault_DataAlignment` before address translation and before the permission check; an aligned address that fails a permission or bounded-memory test raises `Fault_DataPage` at the original address.

A fault records no load event, writes no queue slot, and leaves `TPC` on the faulting instruction. Recovery reissues the whole operation: `SrcL` snapshot, address formation, preflight, `4`-byte load, extension, and push.

<!-- PTO-READER-BLOCK: scalar-c-lwi-example role=example -->
## Reading one encoding end to end

This walkthrough explains how to use the page and does not add instruction behavior.

- Take `c.lwi [7, 5], ->t` with GPR7 holding `0x3004`. The signed `simm5` is `5`, scaled by `4` gives `20`, so the effective address is `0x3004` plus `20`, which is `0x3018`.
- The instruction reads the `4` bytes at `0x3018` through `0x301B` in little-endian order.
- If those bytes are `00 00 00 80`, bit `31` is set, so the pushed `T#1` holds `0xFFFFFFFF80000000`.
- GPR7 still holds `0x3004`, and `TPC` becomes the instruction address plus `2`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
c.lwi [srcL, simm], ->t
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| c_lwi_16_b224525971da | C16 | 16 | 0x000a / 0x003f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| c_lwi_16_b224525971da | SrcL | 5 | encoding-defined | [{"instruction_lsb":6,"value_lsb":0,"width":5}] |
| c_lwi_16_b224525971da | simm5 | 5 | signed | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| c_lwi_16_b224525971da | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| c_lwi_16_b224525971da | simm5 | 5 | 0–31 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 address-base source |
| simm5 | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/C.LWI.asl -->
```asl
readonly func InstructionContractOperation_C_LWI() => ScalarOperation
begin
    return ScalarOperation_C_LWI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/C.LWI.asl -->
```asl
readonly func InstructionContractHandler_C_LWI()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;

pure func InstructionContractAGUAction_C_LWI()
    => ScalarAGUAction
begin
    return ScalarAGU_Load;
end;

pure func InstructionContractAGUAddressKind_C_LWI()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Compressed;
end;

pure func InstructionContractAGUSizeBytes_C_LWI()
    => integer {1,2,4,8}
begin
    return 4;
end;

pure func InstructionContractAGUOffsetScale_C_LWI()
    => integer {0..3}
begin
    return 2;
end;

pure func InstructionContractAGUUpdateMode_C_LWI()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_C_LWI()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_C_LWI()
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
- simm5 assigns every signed 5-bit value -16..15; the encoded byte displacement is that value multiplied by 4.
- Each memory address must be aligned to the 4-byte access size; a 4-byte access is the complete transfer unit.

## State effects

- Sign-extend simm5, multiply it by 4, and add it modulo 2^PTO_XLEN to the SrcL base.
- After a successful 4-byte load, sign-extend the loaded value to PTO_XLEN and publish it through the destination.
- Successful execution advances TPC by 2 bytes; a rejected or faulting attempt does not retire.

## Memory effects and ordering

### Memory effects

- After complete preflight, perform one little-endian 4-byte load and record one relaxed load event.
- The load preserves memory and reservation state.

### Ordering

- Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.
- Complete the relaxed 4-byte memory operation, publish any result or writeback, and then advance TPC.

## Exceptions

- A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.
- A misaligned 4-byte address raises Fault_DataAlignment before translation or permission. A later permission or bounded-memory failure raises Fault_DataPage at the original address.
- A fault emits no successful memory event, performs no partial memory or destination effect, preserves pending writeback, and leaves TPC at the faulting instruction.
- Recovery performs a full reissue: every address, source snapshot, preflight, memory operation, and destination is recomputed with no retained progress.

## Examples

- c.lwi [srcL, simm], ->t

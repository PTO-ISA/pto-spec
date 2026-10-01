<!-- GENERATED FROM: asl/block/lifecycle/MSET.asl -->
# MSET

**Normative ASL source:** `asl/block/lifecycle/MSET.asl`

Fills an arbitrary complete-XLEN byte range from three absolute GPR operands after complete access preflight.

## Normative identity {#PTO-INST-BLOCK-MSET}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-mset-purpose role=purpose -->
## What MSET does

`MSET` fills a byte range with one byte value in one command. It checks the whole destination range before it writes anything, so it either fills the complete range or, on a fault, leaves memory unchanged.

<!-- PTO-READER-BLOCK: block-mset-mechanism role=mechanism -->
## Placement and execution mechanism

`MSET` is a standalone 32-bit command. It does not open or commit a block and does not write `BARG`.

Execution follows a fixed order:

1. Read the destination, fill value, and length from the three GPRs.
2. Reject a nonzero range that wraps past the top of the address space.
3. For a nonzero length, probe the complete destination range for write access.
4. Write the low byte of the fill value to every byte, in increasing address order.
5. Record the last memory command and advance `TPC` by 4.

Design point: the complete range is probed before the first store. Unlike [MCOPY](MCOPY.md), `MSET` keeps no progress state. A faulting `MSET` has written nothing, so executing it again performs the whole fill.

<!-- PTO-READER-BLOCK: block-mset-inputs role=inputs-outputs -->
## Carrier, bindings, and inputs

- `RegSrc0`, bits `19:15`, names the GPR that holds the destination byte address.
- `RegSrc1`, bits `24:20`, names the GPR whose low eight bits are the fill byte. The higher bits are ignored.
- `RegSrc2`, bits `31:27`, names the GPR that holds the byte count, a complete unsigned XLEN value.

Bits `14:0` are `0x1031`, and bits `26:25` are zero. Each selector accepts only the absolute GPRs `0..23`; codes `24..31` are reserved.

Design point: all three fields are required, and encoded zero reads the architectural zero register. `MSET [zero, zero, zero]` is therefore a legal zero-length command: it performs no memory access but still records destination 0 and size 0 as the last memory command.

<!-- PTO-READER-BLOCK: block-mset-effects role=effects -->
## State effects and ordering

A successful nonzero fill writes every byte of the range and invalidates the local load reservation if the range overlaps its granule. A zero length performs no memory or reservation access.

After any successful completion, `_LastMemoryCommandAddress` receives the destination and `_LastMemoryCommandSize` the length.

Memory is byte-addressed here: the write probe uses one-byte alignment, so the destination may have any alignment.

<!-- PTO-READER-BLOCK: block-mset-constraints role=constraints -->
## Legality, faults, and atomicity

- A selector code in `24..31` raises `Fault_IllegalInstruction` before any register, memory, reservation, last-command, or `TPC` effect.
- A nonzero destination range that wraps raises `Fault_IllegalInstruction` before any memory or last-command effect.
- In the executable ASL, a length above 262144 bytes, or above the modeled memory size, raises `Fault_DataPage` at the destination address before any store.
- A write access fault in the probe is reported before the first store.

Every fault leaves memory, the reservation, the last-command state, and `TPC` unchanged. The generated legality and exception sections below are authoritative.

<!-- PTO-READER-BLOCK: block-mset-example role=example -->
## Non-normative worked example

This example demonstrates placement and carrier flow only; exact behavior remains in the current ASL and instruction contract.

```asm
MSET [a0, a1, a2]
```

Suppose `a0` holds `0x9001`, `a1` holds `0x1234`, and `a2` holds 5. The probe covers `0x9001` to `0x9005`. If it passes, the five bytes receive `0x34`, the low byte of `a1`, and the last memory command becomes address `0x9001`, size 5. If the probe fails on any of the five bytes, none of them is written.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
MSET [Destination, FillByte, LengthBytes]
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| mset_32_0b932f291932 | L32 | 32 | 0x00001031 / 0x06007fff | [{"field":"RegSrc0","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23]},{"field":"RegSrc1","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23]},{"field":"RegSrc2","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| mset_32_0b932f291932 | RegSrc0 | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| mset_32_0b932f291932 | RegSrc1 | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| mset_32_0b932f291932 | RegSrc2 | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| mset_32_0b932f291932 | RegSrc0 | 5 | 0–23 | none | 24–31 | absolute GPR containing destination byte address | Encoded zero supplies destination address zero. |
| mset_32_0b932f291932 | RegSrc1 | 5 | 0–23 | none | 24–31 | absolute GPR whose low eight bits are replicated | Encoded zero supplies fill byte zero. |
| mset_32_0b932f291932 | RegSrc2 | 5 | 0–23 | none | 24–31 | absolute GPR containing complete unsigned byte length | Encoded zero supplies zero length. |

- `mset_32_0b932f291932.RegSrc0` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.
- `mset_32_0b932f291932.RegSrc1` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.
- `mset_32_0b932f291932.RegSrc2` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegSrc0 | absolute GPR containing destination byte address |
| RegSrc1 | absolute GPR whose low eight bits are replicated |
| RegSrc2 | absolute GPR containing complete unsigned byte length |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/lifecycle/MSET.asl -->
```asl
readonly func InstructionContractMatches_MSET(operation: CommandOperation)
    => boolean
begin
    return operation == CommandOperation_mset_32_0b932f291932;
end;

pure func InstructionContractAbsoluteGPRSelectorLegal_MSET(
    selector: Reg5Selector) => boolean
begin
    return selector <= 23;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
MSET is a standalone template instruction and does not consume a BSTART/BSTOP body.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/lifecycle/MSET.asl -->
```asl
readonly func InstructionContractHandler_MSET() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteMemorySet;
end;

pure func InstructionContractMemoryStepRestartable_MSET()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractAcceptsCompleteXLENLength_MSET()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractWritesMemory_MSET()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- All three absolute GPR fields are encoded and required; encoded zero reads the architectural zero GPR.
- LengthBytes is the complete unsigned XLEN value. Zero is a successful zero-length command; every nonzero value names that many bytes and no fixed instruction-length ceiling applies.

## Legality

- RegSrc0, RegSrc1, and RegSrc2 each accept only absolute GPR codes 0 through 23; 24 through 31 are reserved.
- The complete unsigned LengthBytes value is assigned and is never truncated to a smaller surrogate; every nonzero destination interval must be non-wrapping.
- Every byte address is naturally aligned and the full destination range must pass write access preflight before effects.

## State effects

- After successful zero or nonzero completion, set _LastMemoryCommandAddress to Destination and _LastMemoryCommandSize to LengthBytes.
- On every fault, preserve memory, reservation state, last-command state, and TPC.

## Memory effects and ordering

### Memory effects

- For nonzero length, probe the complete destination byte range before the first store, then write FillByte[7:0] to every byte in increasing address order.
- A successful nonzero fill invalidates an overlapping local load-reservation granule; zero length performs no memory or reservation access.

### Ordering

- Snapshot all three GPR values before access validation and memory effects.
- Successful completion records the command state and then advances TPC by four bytes.

## Exceptions

- Selectors 24 through 31 in any source field raise Fault_IllegalInstruction before register, memory, reservation, last-command, or TPC effects.
- A nonzero destination interval that wraps modulo 2^PTO_XLEN raises Fault_IllegalInstruction before memory or last-command effects.
- A destination access fault is reported before the first store and leaves the complete range unchanged.

## Examples

- MSET [a0, a1, a2]
- MSET [zero, zero, zero]

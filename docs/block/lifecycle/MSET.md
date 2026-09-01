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

`MSET` is a standalone all-or-nothing memory command: it preflights the complete destination range before filling, and any fault requires a full reissue with no retained partial progress.

<!-- PTO-READER-BLOCK: block-mset-mechanism role=mechanism -->
## Placement and execution mechanism

`MSET` executes as a standalone `32`-bit command and does not require placement inside a `BSTART`/`BSTOP` body.

The accepted carrier uses the `L32` encoding class and resolves every displayed field before the command reads bindings or changes state.

The command snapshots destination, fill byte, and the complete unsigned XLEN
length, then preflights the complete destination range before the first store.

<!-- PTO-READER-BLOCK: block-mset-inputs role=inputs-outputs -->
## Carrier, bindings, and inputs

- Encoded operands: `RegSrc0` — absolute GPR containing destination byte address; `RegSrc1` — absolute GPR whose low eight bits are replicated; `RegSrc2` — absolute GPR containing complete unsigned byte length.
- All operands are resolved from the accepted carrier or named architectural state; no body-local hidden operand stream is created.
- Encoded zero remains an assigned value or a specifically documented rejection; it never silently means an omitted operand.

<!-- PTO-READER-BLOCK: block-mset-effects role=effects -->
## State effects and ordering

All three GPR values are snapshotted before range validation or memory effects.

After full-range preflight, bytes fill in increasing address order; success invalidates an overlapping reservation, records command state, and retires once without saved progress.

<!-- PTO-READER-BLOCK: block-mset-constraints role=constraints -->
## Legality, faults, and atomicity

Fixed bits, reserved values, selector domains, and required Block placement are checked before architectural effects.

The current owner reports invalid schema, state, address, or continuation conditions through `Fault_IllegalInstruction`; no prose on this page creates an additional fault rule.

A `Fault_DataPage` during preflight leaves the complete range, reservation, last-command state, and `TPC` unchanged; recovery performs a full reissue.

<!-- PTO-READER-BLOCK: block-mset-example role=example -->
## Non-normative worked example

This example demonstrates placement and carrier flow only; exact behavior remains in the current ASL and instruction contract.

```asm
MSET [a0, a1, a2]
```

The shown accepted spelling resolves its fields from the current carrier, snapshots required sources, and then follows the owner-defined state and ordering transition.
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

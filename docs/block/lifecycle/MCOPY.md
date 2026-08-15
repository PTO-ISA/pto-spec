<!-- GENERATED FROM: asl/block/lifecycle/MCOPY.asl -->
# MCOPY

**Normative ASL source:** `asl/block/lifecycle/MCOPY.asl`

Copies a non-overlapping byte range in restartable forward memory steps.

## Normative identity {#PTO-INST-BLOCK-MCOPY}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
MCOPY [RegSrc0, RegSrc1, RegSrc2]
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| mcopy_32_4fc4a803e995 | L32 | 32 | 0x00000031 / 0x06007fff | [{"field":"RegSrc0","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23]},{"field":"RegSrc1","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23]},{"field":"RegSrc2","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| mcopy_32_4fc4a803e995 | RegSrc0 | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| mcopy_32_4fc4a803e995 | RegSrc1 | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| mcopy_32_4fc4a803e995 | RegSrc2 | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| mcopy_32_4fc4a803e995 | RegSrc0 | 5 | 0–23 | none | 24–31 | absolute GPR containing destination byte address | Encoded zero reads destination byte address zero. |
| mcopy_32_4fc4a803e995 | RegSrc1 | 5 | 0–23 | none | 24–31 | absolute GPR containing source byte address | Encoded zero reads source byte address zero. |
| mcopy_32_4fc4a803e995 | RegSrc2 | 5 | 0–23 | none | 24–31 | absolute GPR containing complete unsigned XLEN byte count | Encoded zero reads length zero and selects the legal memory-free no-op. |

- `mcopy_32_4fc4a803e995.RegSrc0` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.
- `mcopy_32_4fc4a803e995.RegSrc1` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.
- `mcopy_32_4fc4a803e995.RegSrc2` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegSrc0 | absolute GPR containing destination byte address |
| RegSrc1 | absolute GPR containing source byte address |
| RegSrc2 | absolute GPR containing complete unsigned XLEN byte count |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/lifecycle/MCOPY.asl -->
```asl
readonly func InstructionContractMatches_MCOPY(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_mcopy_32_4fc4a803e995);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
MCOPY is one standalone template block. It retires only after the complete byte range has copied or after a legal zero-length no-op.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/lifecycle/MCOPY.asl -->
```asl
readonly func InstructionContractHandler_MCOPY() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteMemoryCopy;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- No operand is omitted. RegSrc0, RegSrc1, and RegSrc2 are absolute GPR selectors 0..23; selector zero reads architectural zero.
- RegSrc2 supplies the complete unsigned XLEN byte count. Zero length is legal and performs no memory access.

## Legality

- Each RegSrc field accepts exactly absolute GPR selectors 0..23. Relative T/U selector codes 24..31 are reserved for MCOPY.
- For nonzero length, both half-open intervals must be non-wrapping and disjoint.

## State effects

- At accepted start, snapshot destination, source, length, instruction PC, and zero progress into trap-preserved MemoryCopyTemplateState.
- After the final step, clear active progress, record the original destination and full length as the last memory command, and retire exactly once.

## Memory effects and ordering

### Memory effects

- Copy forward from source to destination in 8-, 4-, 2-, or 1-byte steps. Each step probes source and destination before reading, then records the source load and destination store in program order.
- The step write invalidates an overlapping local reservation. A successful zero-length command performs no access and does not change reservation state.

### Ordering

- Each source read precedes its corresponding destination write. The write and progress advance commit together at one restart boundary.
- On recovery the template resumes from its saved operand snapshot and first uncommitted byte without rereading GPRs or repeating earlier memory events.

## Exceptions

- Selector codes 24..31, a wrapping source or destination interval, or overlapping nonempty intervals raise Fault_IllegalInstruction before register-dependent memory, event, reservation, progress, last-command, or TPC effects.
- A source or destination access fault is precise to the current memory step. Earlier completed steps remain visible; the rejected step has no read, write, event, reservation, or progress effect.

## Examples

- MCOPY [a0, a1, a2]

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->

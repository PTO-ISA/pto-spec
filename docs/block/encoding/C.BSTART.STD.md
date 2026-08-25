<!-- GENERATED FROM: asl/block/encoding/C.BSTART.STD.asl -->
# C.BSTART.STD

**Normative ASL source:** `asl/block/encoding/C.BSTART.STD.asl`

Starts a compressed STD block with fallthrough, indirect, or return transfer; every other BrType rejects before effects.

## Normative identity {#PTO-INST-BLOCK-C-BSTART-STD}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-c-bstart-std-purpose role=purpose -->
## What C.BSTART.STD does

`C.BSTART.STD` opens an active Block descriptor; the body supplies the attributes and bindings required before completion.

<!-- PTO-READER-BLOCK: block-c-bstart-std-mechanism role=mechanism -->
## Placement and execution mechanism

`C.BSTART.STD` must appear as the starter of its Block. Later attributes, dimensions, and bindings accumulate in the active descriptor until `BSTOP` or the next accepted `BSTART` completion boundary.

The accepted carrier uses the `C16` encoding class and resolves every displayed field before the command reads bindings or changes state.

At completion, the descriptor runs its selected Block operation only after all schema and state preflight succeeds.

<!-- PTO-READER-BLOCK: block-c-bstart-std-inputs role=inputs-outputs -->
## Carrier, bindings, and inputs

- Encoded operands: `BrType` — encoded transfer kind: FALL, IND, or RET.
- After predecessor retirement, this carrier opens one Standard Block; FALL and RET may start without a predecessor, while IND requires an active retiring Standard or Floating BARG.
- Encoded zero remains an assigned value or a specifically documented rejection; it never silently means an omitted operand.

<!-- PTO-READER-BLOCK: block-c-bstart-std-effects role=effects -->
## State effects and ordering

Starting the Block records the selected carrier and leaves operation execution deferred until the completion boundary.

After complete preflight and computation, every enabled output publishes as the owner-defined atomic group; successful mathematical sources remain available unless the contract explicitly consumes them.

<!-- PTO-READER-BLOCK: block-c-bstart-std-constraints role=constraints -->
## Legality, faults, and atomicity

Fixed bits, reserved values, selector domains, and required Block placement are checked before architectural effects.

The current owner reports invalid schema, state, address, or continuation conditions through `Fault_BundleControl`, `Fault_IllegalInstruction`, `Fault_InstructionPC`; no prose on this page creates an additional fault rule.

Complete schema, binding, readiness, alias, capacity, and allocation preflight precedes source snapshots and every destination publication.

<!-- PTO-READER-BLOCK: block-c-bstart-std-example role=example -->
## Non-normative worked example

This example demonstrates placement and carrier flow only; exact behavior remains in the current ASL and instruction contract.

```asm
C.BSTART.STD FALL
```

The starter establishes the descriptor first; the following carriers fill its declared schema, and the final completion boundary triggers validation and operation execution.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
C.BSTART.STD FALL
C.BSTART.STD IND
C.BSTART.STD RET
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| c_bstart_std_16_8b40f078c14a | C16 | 16 | 0x0000 / 0xc7ff | [{"field":"BrType","operator":"one-of","values":[1,5,7]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| c_bstart_std_16_8b40f078c14a | BrType | 3 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":3}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| c_bstart_std_16_8b40f078c14a | BrType | 3 | 1, 5, 7 | 0 (C.BSTOP) | 2–4, 6 | encoded transfer kind: FALL, IND, or RET | Encoded zero is owned by C.BSTOP, not C.BSTART.STD. |

- `c_bstart_std_16_8b40f078c14a.BrType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| BrType | encoded transfer kind: FALL, IND, or RET |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/encoding/C.BSTART.STD.asl -->
```asl
readonly func InstructionContractMatches_C_BSTART_STD(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_c_bstart_std_16_8b40f078c14a);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
After any active predecessor block commits successfully, C.BSTART.STD opens one Standard block. FALL and RET may start without a predecessor; IND requires an active retiring Standard or Floating BARG.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/encoding/C.BSTART.STD.asl -->
```asl
pure func InstructionContractBranchTypeLegal_C_BSTART_STD(
    branch_type: bits(3))
    => boolean
begin
    return branch_type == '001' ||
           branch_type == '101' ||
           branch_type == '111';
end;

pure func InstructionContractTransfer_C_BSTART_STD(
    branch_type: bits(3))
    => BundleTransfer
begin
    assert InstructionContractBranchTypeLegal_C_BSTART_STD(branch_type);
    if branch_type == '001' then
        return BundleTransfer_Fallthrough;
    elsif branch_type == '101' then
        return BundleTransfer_Indirect;
    else
        return BundleTransfer_Return;
    end;
end;

readonly func InstructionContractHandler_C_BSTART_STD() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- BrType is always encoded; it has no omitted or default form.

## Legality

- c_bstart_std_16_8b40f078c14a.BrType accepts exactly 1 (FALL), 5 (IND), or 7 (RET). Code 0 decodes as C.BSTOP, while codes 2, 3, 4, and 6 do not decode as standalone C.BSTART.STD; code 6 is used only inside fused BSTART.ICALL.

## State effects

- FALL installs a non-selecting sequential Standard BARG. IND installs the snapshotted retiring BARG.BPCN; RET installs the snapshotted architectural return address.
- The installed candidate continuation remains pending until BSTOP or the next BSTART commits the new block.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Decode and transfer legality precede source selection. IND snapshots retiring BARG.BPCN and RET snapshots architectural ra before predecessor retirement.
- Target alignment is checked before retirement; the new Standard BARG is installed only after successful retirement.

## Exceptions

- BrType code 0 is C.BSTOP. Codes 2, 3, 4, and 6 do not decode as standalone C.BSTART.STD and raise Fault_IllegalInstruction before effects.
- IND without an active retiring Standard or Floating BARG raises Fault_BundleControl before effects. An odd snapshotted BARG.BPCN or return address raises Fault_InstructionPC before predecessor retirement.
- If predecessor commit fails, the retiring block remains authoritative and no Standard BARG is installed.

## Examples

- C.BSTART.STD FALL
- C.BSTART.STD IND
- C.BSTART.STD RET

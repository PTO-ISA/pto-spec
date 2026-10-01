<!-- GENERATED FROM: asl/scalar/sys/ACRE.asl -->
# ACRE

**Normative ASL source:** `asl/scalar/sys/ACRE.asl`

ACRE atomically commits the active SYS block and recovers one validated architecture context.

## Normative identity {#PTO-INST-SCALAR-ACRE}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-acre-purpose role=purpose -->
## What ACRE does

`ACRE` is the context-enter request. It ends the active SYS block by committing it and restores one previously saved architecture context, carrying a 4-bit return-address record type.

It is both the terminating scalar operation and the implicit stop of its block, so it does not need a separate stop instruction to close the block.

<!-- PTO-READER-BLOCK: scalar-acre-mechanism role=mechanism -->
## How the instruction is placed and executed

This instruction is one scalar operation of an active SYS block. The scalar dispatcher first checks that a bundle is active and that its body is active with block kind System; a SYS form outside such a block is rejected with `Fault_BundleControl`, before any encoded-field check and before any architectural effect.

Encoded legality and source availability are then checked, and only then does the handler run.

`RRA_Type` is a 4-bit field. Only values `0` and `1` are accepted, and the architecture treats them as exact aliases: they select the same saved snapshot and the same complete restore. Values `2` through `15` are reserved and are rejected with `Fault_IllegalInstruction` before any recovery effect.

An accepted request then runs three ordered steps. First the saved context of the current ring is validated without changing anything. If it is not recoverable, the handler raises `Fault_ExecutionStateCheck` and writes the saved context back unchanged, so nothing is consumed. If it is recoverable, the block is committed; when that commit fails, the saved context is again left untouched and the block is not retired. Only when both steps succeed is the saved context restored, marked no longer valid, and the request type recorded.

The restored state includes the program counters, the core-state word, the bundle and commit arguments, the `T` and `U` queue contents and their validity, the predicate registers, and the current ring taken from the restored core state.

<!-- PTO-READER-BLOCK: scalar-acre-inputs-outputs role=inputs-outputs -->
## Inputs and outputs

- `RRA_Type` is the only encoded operand: a 4-bit return-address record type. Encoded zero is an assigned value and selects one of the two accepted aliases; it is never an omission.
- Values `0` and `1` are the assigned encodings; `2` through `15` are reserved.
- There is no destination field and no source field, so the instruction neither reads nor writes a scalar register or queue entry of its own.

<!-- PTO-READER-BLOCK: scalar-acre-effects role=effects -->
## Architectural effects

On success the block is retired, the saved context is restored, its stored validity is consumed, the request type is recorded, and the architecture-request epoch advances by one. `TPC` takes the value stored in the recovered context rather than advancing by `4` bytes.

The block does not commit unless the stored context is marked valid, its recovered bundle control word is marked present and legal, the recovered ring field matches the recovered core state, and both recovered program counters have a clear low bit. A failure at either the validation step or the commit step preserves the saved context and performs no partial recovery, so a failed `ACRE` is repeatable.

The request type is recorded from the encoded field, not from the two aliases, so the recorded value distinguishes `0` from `1` even though the restore they select is identical.

<!-- PTO-READER-BLOCK: scalar-acre-constraints role=constraints -->
## Placement and rejection

Invalid block placement is rejected first, with `Fault_BundleControl`, before the encoded field is even considered.

A reserved `RRA_Type` raises `Fault_IllegalInstruction` before recovery effects. An unrecoverable saved context raises `Fault_ExecutionStateCheck` and preserves that context. A commit that fails leaves the context preserved as well.

The term "alias" is exact here: the two accepted request types restore the same visible snapshot. A profile that wants different recovery behavior for them must give them distinct architectural identities first, because the current rule cannot distinguish them.

<!-- PTO-READER-BLOCK: scalar-acre-example role=example -->
## Non-normative example

`acre rra_type` with `RRA_Type=0` commits the block and restores the saved context of the current ring in one step, recording `0` as the request type. With `RRA_Type=2` the instruction is rejected with `Fault_IllegalInstruction` and the saved context is left exactly as it was.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
acre rra_type
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| acre_32_54b80944d32d | L32 | 32 | 0x0100302b / 0xff0fffff | [{"field":"RRA_Type","operator":"one-of","values":[0,1]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| acre_32_54b80944d32d | RRA_Type | 4 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":4}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| acre_32_54b80944d32d | RRA_Type | 4 | 0–1 | none | 2–15 | return-address record type | Encoded zero selects value zero of the return-address record type. |

- `acre_32_54b80944d32d.RRA_Type` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| RRA_Type | return-address record type |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/ACRE.asl -->
```asl
readonly func InstructionContractOperation_ACRE()
    => ScalarOperation
begin
    return ScalarOperation_ACRE;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
ACRE executes as one scalar operation in the body of an active SYS block.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/ACRE.asl -->
```asl
readonly func InstructionContractHandler_ACRE()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ArchitectureEnterRequest;
end;

pure func InstructionContractRequiresSystemBlock_ACRE()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractRequestTypeLegal_ACRE(
    request_type: bits(4)) => boolean
begin
    return request_type == '0000' || request_type == '0001';
end;

pure func InstructionContractIsImplicitBlockStop_ACRE()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Every displayed operand is encoded explicitly. Encoded zero is an assigned value and never denotes omission.

## Legality

- Request values 0 and 1 are exact aliases; values 2 through 15 are reserved.
- ACRE is the implicit stop and terminating scalar instruction of the active SYS block.

## State effects

- On success, retire the SYS block, restore the complete validated context, consume its validity, record the request type, and increment the request epoch.
- Failed validation or commit preserves the saved context and performs no partial recovery.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Validate the complete recovery context without mutation before committing the current SYS block.
- Commit the block successfully, then consume and restore the saved context atomically.

## Exceptions

- Invalid block placement raises Illegal Block Exception before encoded-field legality or effects.
- A reserved encoding or rejected access raises Illegal Instruction before destination, queue, system-state, or TPC effects.

## Examples

- acre rra_type

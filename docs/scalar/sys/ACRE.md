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

`ACRE` commits the active SYS block and atomically restores one validated architecture context.

<!-- PTO-READER-BLOCK: scalar-acre-mechanism role=mechanism -->
## System mechanism

The ASL DOC region selects `ScalarHandler_ArchitectureEnterRequest`. Placement and encoded legality are checked before sources or system state can change.

The instruction occupies one scalar operation position in the body of an active SYS block.

<!-- PTO-READER-BLOCK: scalar-acre-inputs-outputs role=inputs-outputs -->
## Inputs and outputs

`RRA_Type` carries the return-address record type.

Encoded zero is an assigned field value, never an omitted operand.

<!-- PTO-READER-BLOCK: scalar-acre-effects role=effects -->
## Architectural effects

The complete saved context is validated without mutation, the active SYS block commits, and then recovery consumes and restores that context atomically.

A failed validation or block commit leaves the saved context valid and exposes no partial recovery.

<!-- PTO-READER-BLOCK: scalar-acre-constraints role=constraints -->
## Placement and rejection

Request values `0` and `1` are aliases; values `2` through `15` are reserved.

Invalid SYS-block placement is rejected before field checks. Reserved encodings or denied access produce no destination, queue, system-state, or `TPC` effect beyond the ordinary trap envelope.

<!-- PTO-READER-BLOCK: scalar-acre-example role=example -->
## Non-normative example

This spelling example is illustrative; exact legality and effects remain in the generated contract below.

Start with `acre rra_type` and trace its encoded fields through preflight before following the selected system effect.
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

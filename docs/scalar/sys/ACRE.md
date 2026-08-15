<!-- GENERATED FROM: asl/scalar/sys/ACRE.asl -->
# ACRE

**Normative ASL source:** `asl/scalar/sys/ACRE.asl`

ACRE atomically commits the active SYS block and recovers one validated architecture context.

## Normative identity {#PTO-INST-SCALAR-ACRE}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

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

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->

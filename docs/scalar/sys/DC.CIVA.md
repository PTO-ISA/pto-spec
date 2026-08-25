<!-- GENERATED FROM: asl/scalar/sys/DC.CIVA.asl -->
# DC.CIVA

**Normative ASL source:** `asl/scalar/sys/DC.CIVA.asl`

DC.CIVA completes the data-cache clean-and-invalidate scope token maintenance operation synchronously.

## Normative identity {#PTO-INST-SCALAR-DC-CIVA}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-dc-civa-purpose role=purpose -->
## What DC.CIVA does

`DC.CIVA` completes its assigned synchronous cache or translation-maintenance request and records the exact operation token.

<!-- PTO-READER-BLOCK: scalar-dc-civa-mechanism role=mechanism -->
## System mechanism

The ASL DOC region selects `ScalarHandler_ExecuteMaintenance`. Placement and encoded legality are checked before sources or system state can change.

The instruction occupies one scalar operation position in the body of an active SYS block.

<!-- PTO-READER-BLOCK: scalar-dc-civa-inputs-outputs role=inputs-outputs -->
## Inputs and outputs

`SrcL` carries the Reg5 source: R0..R23, T#1..T#4, or U#1..U#4.

Encoded zero is an assigned field value, never an omitted operand.

<!-- PTO-READER-BLOCK: scalar-dc-civa-effects role=effects -->
## Architectural effects

On success, the maintenance record receives `Maintenance_DC_CIVA` and the exact captured operand token.

Exactly one selected cache or TLB epoch advances before `TPC`; the operation is a synchronous local hint completion.

<!-- PTO-READER-BLOCK: scalar-dc-civa-constraints role=constraints -->
## Placement and rejection

Cache maintenance is a synchronous local hint at every ACR and does not define additional implementation cache contents.

Invalid SYS-block placement is rejected before field checks. Reserved encodings or denied access produce no destination, queue, system-state, or `TPC` effect beyond the ordinary trap envelope.

<!-- PTO-READER-BLOCK: scalar-dc-civa-example role=example -->
## Non-normative example

This spelling example is illustrative; exact legality and effects remain in the generated contract below.

Start with `dc.civa SrcL` and trace its encoded fields through preflight before following the selected system effect.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
dc.civa SrcL
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| dc_civa_32_265d686549c8 | L32 | 32 | 0x0030602b / 0xfff07fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| dc_civa_32_265d686549c8 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| dc_civa_32_265d686549c8 | SrcL | 5 | 0–31 | none | none | Reg5 source: R0..R23, T#1..T#4, or U#1..U#4 | Encoded zero names the architectural zero GPR. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 source: R0..R23, T#1..T#4, or U#1..U#4 |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/DC.CIVA.asl -->
```asl
readonly func InstructionContractOperation_DC_CIVA()
    => ScalarOperation
begin
    return ScalarOperation_DC_CIVA;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
DC.CIVA executes as one scalar operation in the body of an active SYS block.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/DC.CIVA.asl -->
```asl
readonly func InstructionContractHandler_DC_CIVA()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteMaintenance;
end;

pure func InstructionContractRequiresSystemBlock_DC_CIVA()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractMaintenanceOperation_DC_CIVA()
    => MaintenanceOperation
begin
    return Maintenance_DC_CIVA;
end;

pure func InstructionContractMaintenanceUsesOperand_DC_CIVA()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractMaintenanceRequiresRootRing_DC_CIVA()
    => boolean
begin
    return FALSE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Every displayed operand is encoded explicitly. Encoded zero is an assigned value and never denotes omission.

## Legality

- Every fixed bit and explicit field constraint is checked before operation semantics.
- Cache maintenance is a local synchronous hint completion at every ACR.

## State effects

- Success records Maintenance_DC_CIVA and its exact operand token.
- Success advances exactly one data-cache, instruction-cache, bundle-cache, or TLB epoch and then advances TPC.

## Memory effects and ordering

### Memory effects

- No ordinary scalar memory access is performed; success records the operation and operand and advances the selected maintenance epoch.

### Ordering

- Check block placement and encoded legality before source reads or architectural effects.
- Snapshot every scalar source before the selected system effect, then advance TPC only after success.

## Exceptions

- Invalid block placement raises Illegal Block Exception before encoded-field legality or effects.
- A reserved encoding or rejected access raises Illegal Instruction before destination, queue, system-state, or TPC effects.

## Examples

- dc.civa SrcL

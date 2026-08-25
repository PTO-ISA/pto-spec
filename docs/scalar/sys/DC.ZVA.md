<!-- GENERATED FROM: asl/scalar/sys/DC.ZVA.asl -->
# DC.ZVA

**Normative ASL source:** `asl/scalar/sys/DC.ZVA.asl`

DC.ZVA completes the data-cache zero-by-address scope token maintenance operation synchronously.

## Normative identity {#PTO-INST-SCALAR-DC-ZVA}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-dc-zva-purpose role=purpose -->
## What DC.ZVA does

`DC.ZVA` completes its assigned synchronous cache or translation-maintenance request and records the exact operation token.

<!-- PTO-READER-BLOCK: scalar-dc-zva-mechanism role=mechanism -->
## System mechanism

The ASL DOC region selects `ScalarHandler_ExecuteMaintenance`. Placement and encoded legality are checked before sources or system state can change.

The instruction occupies one scalar operation position in the body of an active SYS block.

<!-- PTO-READER-BLOCK: scalar-dc-zva-inputs-outputs role=inputs-outputs -->
## Inputs and outputs

`SrcL` carries the Reg5 source: R0..R23, T#1..T#4, or U#1..U#4.

Encoded zero is an assigned field value, never an omitted operand.

<!-- PTO-READER-BLOCK: scalar-dc-zva-effects role=effects -->
## Architectural effects

On success, the maintenance record receives `Maintenance_DC_ZVA` and the exact captured operand token.

Exactly one selected cache or TLB epoch advances before `TPC`; the operation is a synchronous local hint completion.

<!-- PTO-READER-BLOCK: scalar-dc-zva-constraints role=constraints -->
## Placement and rejection

Cache maintenance is a synchronous local hint at every ACR and does not define additional implementation cache contents.

Invalid SYS-block placement is rejected before field checks. Reserved encodings or denied access produce no destination, queue, system-state, or `TPC` effect beyond the ordinary trap envelope.

<!-- PTO-READER-BLOCK: scalar-dc-zva-example role=example -->
## Non-normative example

This spelling example is illustrative; exact legality and effects remain in the generated contract below.

Start with `dc.zva SrcL` and trace its encoded fields through preflight before following the selected system effect.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
dc.zva SrcL
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| dc_zva_32_0859a1d7aa5b | L32 | 32 | 0x0070602b / 0xfff07fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| dc_zva_32_0859a1d7aa5b | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| dc_zva_32_0859a1d7aa5b | SrcL | 5 | 0–31 | none | none | Reg5 source: R0..R23, T#1..T#4, or U#1..U#4 | Encoded zero names the architectural zero GPR. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 source: R0..R23, T#1..T#4, or U#1..U#4 |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/DC.ZVA.asl -->
```asl
readonly func InstructionContractOperation_DC_ZVA()
    => ScalarOperation
begin
    return ScalarOperation_DC_ZVA;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
DC.ZVA executes as one scalar operation in the body of an active SYS block.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/DC.ZVA.asl -->
```asl
readonly func InstructionContractHandler_DC_ZVA()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteMaintenance;
end;

pure func InstructionContractRequiresSystemBlock_DC_ZVA()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractMaintenanceOperation_DC_ZVA()
    => MaintenanceOperation
begin
    return Maintenance_DC_ZVA;
end;

pure func InstructionContractMaintenanceUsesOperand_DC_ZVA()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractMaintenanceRequiresRootRing_DC_ZVA()
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

- Success records Maintenance_DC_ZVA and its exact operand token.
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

- dc.zva SrcL

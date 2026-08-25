<!-- GENERATED FROM: asl/scalar/sys/TLB.IALL.asl -->
# TLB.IALL

**Normative ASL source:** `asl/scalar/sys/TLB.IALL.asl`

TLB.IALL completes the all translation entries maintenance operation synchronously.

## Normative identity {#PTO-INST-SCALAR-TLB-IALL}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-tlb-iall-purpose role=purpose -->
## What TLB.IALL does

`TLB.IALL` completes its assigned synchronous cache or translation-maintenance request and records the exact operation token.

<!-- PTO-READER-BLOCK: scalar-tlb-iall-mechanism role=mechanism -->
## System mechanism

The ASL DOC region selects `ScalarHandler_ExecuteMaintenance`. Placement and encoded legality are checked before sources or system state can change.

The instruction occupies one scalar operation position in the body of an active SYS block.

<!-- PTO-READER-BLOCK: scalar-tlb-iall-inputs-outputs role=inputs-outputs -->
## Inputs and outputs

The encoding has no explicit operand field; the operation is selected entirely by its fixed instruction bits.

<!-- PTO-READER-BLOCK: scalar-tlb-iall-effects role=effects -->
## Architectural effects

On success, the maintenance record receives `Maintenance_TLB_IALL` and the exact captured operand token.

Exactly one selected cache or TLB epoch advances before `TPC`; the operation is a synchronous local hint completion.

<!-- PTO-READER-BLOCK: scalar-tlb-iall-constraints role=constraints -->
## Placement and rejection

TLB maintenance is accepted only at `ACR0`; ring permission is checked before operand validation. This form has no operand token.

Invalid SYS-block placement is rejected before field checks. Reserved encodings or denied access produce no destination, queue, system-state, or `TPC` effect beyond the ordinary trap envelope.

<!-- PTO-READER-BLOCK: scalar-tlb-iall-example role=example -->
## Non-normative example

This spelling example is illustrative; exact legality and effects remain in the generated contract below.

Start with `tlb.iall` and trace its encoded fields through preflight before following the selected system effect.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
tlb.iall
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| tlb_iall_32_0fb421b85c88 | L32 | 32 | 0x0030702b / 0xffffffff | [] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Operands and results

This instruction has no explicit operand fields.

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/TLB.IALL.asl -->
```asl
readonly func InstructionContractOperation_TLB_IALL()
    => ScalarOperation
begin
    return ScalarOperation_TLB_IALL;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
TLB.IALL executes as one scalar operation in the body of an active SYS block.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/TLB.IALL.asl -->
```asl
readonly func InstructionContractHandler_TLB_IALL()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteMaintenance;
end;

pure func InstructionContractRequiresSystemBlock_TLB_IALL()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractMaintenanceOperation_TLB_IALL()
    => MaintenanceOperation
begin
    return Maintenance_TLB_IALL;
end;

pure func InstructionContractMaintenanceUsesOperand_TLB_IALL()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractMaintenanceRequiresRootRing_TLB_IALL()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- This form has no operand; the semantic operand is the all-zero XLEN value.

## Legality

- Every fixed bit and explicit field constraint is checked before operation semantics.
- TLB maintenance is assigned only at ACR0 and rejects at every other ring before operand validation.

## State effects

- Success records Maintenance_TLB_IALL and its exact operand token.
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

- tlb.iall

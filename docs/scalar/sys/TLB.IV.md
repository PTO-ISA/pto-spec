<!-- GENERATED FROM: asl/scalar/sys/TLB.IV.asl -->
# TLB.IV

**Normative ASL source:** `asl/scalar/sys/TLB.IV.asl`

TLB.IV completes the canonical 48-bit virtual address maintenance operation synchronously.

## Normative identity {#PTO-INST-SCALAR-TLB-IV}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
tlb.iv SrcL
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| tlb_iv_32_bf0a5d1ea211 | L32 | 32 | 0x0010702b / 0xfff07fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| tlb_iv_32_bf0a5d1ea211 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| tlb_iv_32_bf0a5d1ea211 | SrcL | 5 | 0–31 | none | none | Reg5 source: R0..R23, T#1..T#4, or U#1..U#4 | Encoded zero names the architectural zero GPR. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 source: R0..R23, T#1..T#4, or U#1..U#4 |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/TLB.IV.asl -->
```asl
readonly func InstructionContractOperation_TLB_IV()
    => ScalarOperation
begin
    return ScalarOperation_TLB_IV;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
TLB.IV executes as one scalar operation in the body of an active SYS block.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/TLB.IV.asl -->
```asl
readonly func InstructionContractHandler_TLB_IV()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteMaintenance;
end;

pure func InstructionContractRequiresSystemBlock_TLB_IV()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractMaintenanceOperation_TLB_IV()
    => MaintenanceOperation
begin
    return Maintenance_TLB_IV;
end;

pure func InstructionContractMaintenanceUsesOperand_TLB_IV()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractMaintenanceRequiresRootRing_TLB_IV()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Every displayed operand is encoded explicitly. Encoded zero is an assigned value and never denotes omission.

## Legality

- Every fixed bit and explicit field constraint is checked before operation semantics.
- TLB maintenance is assigned only at ACR0 and rejects at every other ring before operand validation.
- The operand must be a canonical 48-bit virtual address.

## State effects

- Success records Maintenance_TLB_IV and its exact operand token.
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

- tlb.iv SrcL

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->

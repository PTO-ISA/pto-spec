<!-- GENERATED FROM: asl/scalar/sys/BC.IVA.asl -->
# BC.IVA

**Normative ASL source:** `asl/scalar/sys/BC.IVA.asl`

BC.IVA completes the bundle-cache virtual-address scope token maintenance operation synchronously.

## Normative identity {#PTO-INST-SCALAR-BC-IVA}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
bc.iva SrcL
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| bc_iva_32_c166de534c98 | L32 | 32 | 0x0000402b / 0xfff07fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| bc_iva_32_c166de534c98 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| bc_iva_32_c166de534c98 | SrcL | 5 | 0–31 | none | none | Reg5 source: R0..R23, T#1..T#4, or U#1..U#4 | Encoded zero names the architectural zero GPR. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 source: R0..R23, T#1..T#4, or U#1..U#4 |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/BC.IVA.asl -->
```asl
readonly func InstructionContractOperation_BC_IVA()
    => ScalarOperation
begin
    return ScalarOperation_BC_IVA;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BC.IVA executes as one scalar operation in the body of an active SYS block.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/BC.IVA.asl -->
```asl
readonly func InstructionContractHandler_BC_IVA()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteMaintenance;
end;

pure func InstructionContractRequiresSystemBlock_BC_IVA()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractMaintenanceOperation_BC_IVA()
    => MaintenanceOperation
begin
    return Maintenance_BC_IVA;
end;

pure func InstructionContractMaintenanceUsesOperand_BC_IVA()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractMaintenanceRequiresRootRing_BC_IVA()
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

- Success records Maintenance_BC_IVA and its exact operand token.
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

- bc.iva SrcL

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->

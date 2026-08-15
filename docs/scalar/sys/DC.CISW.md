<!-- GENERATED FROM: asl/scalar/sys/DC.CISW.asl -->
# DC.CISW

**Normative ASL source:** `asl/scalar/sys/DC.CISW.asl`

DC.CISW completes the data-cache clean-and-invalidate set/way token maintenance operation synchronously.

## Normative identity {#PTO-INST-SCALAR-DC-CISW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
dc.cisw SrcL
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| dc_cisw_32_166b7135e3c1 | L32 | 32 | 0x0060602b / 0xfff07fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| dc_cisw_32_166b7135e3c1 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| dc_cisw_32_166b7135e3c1 | SrcL | 5 | 0–31 | none | none | Reg5 source: R0..R23, T#1..T#4, or U#1..U#4 | Encoded zero names the architectural zero GPR. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 source: R0..R23, T#1..T#4, or U#1..U#4 |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/DC.CISW.asl -->
```asl
readonly func InstructionContractOperation_DC_CISW()
    => ScalarOperation
begin
    return ScalarOperation_DC_CISW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
DC.CISW executes as one scalar operation in the body of an active SYS block.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/DC.CISW.asl -->
```asl
readonly func InstructionContractHandler_DC_CISW()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteMaintenance;
end;

pure func InstructionContractRequiresSystemBlock_DC_CISW()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractMaintenanceOperation_DC_CISW()
    => MaintenanceOperation
begin
    return Maintenance_DC_CISW;
end;

pure func InstructionContractMaintenanceUsesOperand_DC_CISW()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractMaintenanceRequiresRootRing_DC_CISW()
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

- Success records Maintenance_DC_CISW and its exact operand token.
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

- dc.cisw SrcL

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->

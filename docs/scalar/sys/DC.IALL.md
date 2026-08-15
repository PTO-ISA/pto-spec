<!-- GENERATED FROM: asl/scalar/sys/DC.IALL.asl -->
# DC.IALL

**Normative ASL source:** `asl/scalar/sys/DC.IALL.asl`

DC.IALL completes the data-cache all-entry scope maintenance operation synchronously.

## Normative identity {#PTO-INST-SCALAR-DC-IALL}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
dc.iall
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| dc_iall_32_3d61563dd077 | L32 | 32 | 0x0010602b / 0xffffffff | [] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Operands and results

This instruction has no explicit operand fields.

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/DC.IALL.asl -->
```asl
readonly func InstructionContractOperation_DC_IALL()
    => ScalarOperation
begin
    return ScalarOperation_DC_IALL;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
DC.IALL executes as one scalar operation in the body of an active SYS block.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/DC.IALL.asl -->
```asl
readonly func InstructionContractHandler_DC_IALL()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteMaintenance;
end;

pure func InstructionContractRequiresSystemBlock_DC_IALL()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractMaintenanceOperation_DC_IALL()
    => MaintenanceOperation
begin
    return Maintenance_DC_IALL;
end;

pure func InstructionContractMaintenanceUsesOperand_DC_IALL()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractMaintenanceRequiresRootRing_DC_IALL()
    => boolean
begin
    return FALSE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Every displayed operand is encoded explicitly. Encoded zero is an assigned value and never denotes omission.
- This form has no operand; the semantic operand is the all-zero XLEN value.

## Legality

- Every fixed bit and explicit field constraint is checked before operation semantics.
- Cache maintenance is a local synchronous hint completion at every ACR.

## State effects

- Success records Maintenance_DC_IALL and its exact operand token.
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

- dc.iall

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->

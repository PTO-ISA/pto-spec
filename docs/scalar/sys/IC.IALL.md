<!-- GENERATED FROM: asl/scalar/sys/IC.IALL.asl -->
# IC.IALL

**Normative ASL source:** `asl/scalar/sys/IC.IALL.asl`

IC.IALL completes the instruction-cache all-entry scope maintenance operation synchronously.

## Normative identity {#PTO-INST-SCALAR-IC-IALL}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
ic.iall
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| ic_iall_32_854f0d4d906a | L32 | 32 | 0x0010502b / 0xffffffff | [] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Operands and results

This instruction has no explicit operand fields.

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/IC.IALL.asl -->
```asl
readonly func InstructionContractOperation_IC_IALL()
    => ScalarOperation
begin
    return ScalarOperation_IC_IALL;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
IC.IALL executes as one scalar operation in the body of an active SYS block.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/IC.IALL.asl -->
```asl
readonly func InstructionContractHandler_IC_IALL()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteMaintenance;
end;

pure func InstructionContractRequiresSystemBlock_IC_IALL()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractMaintenanceOperation_IC_IALL()
    => MaintenanceOperation
begin
    return Maintenance_IC_IALL;
end;

pure func InstructionContractMaintenanceUsesOperand_IC_IALL()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractMaintenanceRequiresRootRing_IC_IALL()
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

- Success records Maintenance_IC_IALL and its exact operand token.
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

- ic.iall

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->

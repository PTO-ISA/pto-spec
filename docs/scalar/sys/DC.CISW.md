<!-- GENERATED FROM: asl/scalar/sys/DC.CISW.asl -->
# DC.CISW

**Normative ASL source:** `asl/scalar/sys/DC.CISW.asl`

DC.CISW completes the data-cache clean-and-invalidate set/way token maintenance operation synchronously.

## Normative identity {#PTO-INST-SCALAR-DC-CISW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-dc-cisw-purpose role=purpose -->
## What DC.CISW does

`DC.CISW` completes the data-cache clean-and-invalidate set/way maintenance operation synchronously. The instruction carries one operand, `SrcL` (`asl/scalar/sys/DC.CISW.asl:29`), which supplies the scope token that the maintenance record captures.

<!-- PTO-READER-BLOCK: scalar-dc-cisw-mechanism role=mechanism -->
## System mechanism

`InstructionContractHandler_DC_CISW` selects `ScalarHandler_ExecuteMaintenance` (`asl/scalar/sys/DC.CISW.asl:11`), and `InstructionContractMaintenanceOperation_DC_CISW` fixes the operation to `Maintenance_DC_CISW` (`asl/scalar/sys/DC.CISW.asl:23`). That handler is shared with every other cache, bundle-cache, and TLB maintenance instruction, so the difference between them is only the operation token and the operand rule.

The instruction occupies one scalar operation position in the body of an active SYS block (`asl/scalar/model/sys/semantics.asl:322`). Every fixed bit and operand constraint is checked during the legality pass, before the handler runs.

<!-- PTO-READER-BLOCK: scalar-dc-cisw-inputs-outputs role=inputs-outputs -->
## Inputs and outputs

`SrcL` is a Reg5 source: R0..R23, T#1..T#4, or U#1..U#4. The dispatcher reads it through `ReadDecodedScalarRegister` and passes the value to the executor as the operand (`asl/scalar/model/dispatch/sys.asl:42`). Encoded zero names the architectural zero GPR, so it is an assigned value and never an omitted operand.

`DC.CISW` produces no scalar destination. The only output is the maintenance record.

<!-- PTO-READER-BLOCK: scalar-dc-cisw-effects role=effects -->
## Architectural effects

On success the maintenance record receives `Maintenance_DC_CISW` and the exact operand token (`asl/scalar/model/sys/semantics.asl:159`), and the data-cache epoch advances by one (`asl/scalar/model/sys/semantics.asl:137`). `TPC` then advances by the instruction length, because the dispatcher advances `TPC` only after the execution reports success (`asl/scalar/model/dispatch/top-level.asl:55`).

Design point: the operand is snapshotted before the epoch changes, so the recorded token is the value the source held when the instruction read it. Later writes to that source cannot rewrite what the log says this instruction requested.

No ordinary scalar memory access is performed, so data memory is unchanged.

<!-- PTO-READER-BLOCK: scalar-dc-cisw-constraints role=constraints -->
## Placement and rejection

Placement is checked first. If the bundle is not active, or its body is not a System block, the attempt raises `Fault_BundleControl` before any legality check, so the record and the data-cache epoch keep their previous values.

Cache maintenance is permitted at every access ring; only the TLB operations are restricted to ring 0. `DC.CISW` therefore has no privilege gate, and an implementation's own cache contents are not defined by this instruction.

Design point: the operation publishes an operation token and an epoch instead of naming cache lines, so the scope token in `SrcL` is recorded as evidence rather than interpreted as a set/way index by the portable model.

<!-- PTO-READER-BLOCK: scalar-dc-cisw-example role=example -->
## Non-normative example

This spelling example is illustrative; exact legality and effects remain in the generated contract below.

Run `dc.cisw SrcL` inside a SYS block body. If the source register holds 10, the attempt first passes placement and encoding checks, then reads that register into the operand, then advances the data-cache epoch, and finally records `Maintenance_DC_CISW` with operand 10.
<!-- SUPPLEMENTARY-END -->

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

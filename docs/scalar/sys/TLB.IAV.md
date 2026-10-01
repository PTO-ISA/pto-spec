<!-- GENERATED FROM: asl/scalar/sys/TLB.IAV.asl -->
# TLB.IAV

**Normative ASL source:** `asl/scalar/sys/TLB.IAV.asl`

TLB.IAV completes the canonical 48-bit virtual address with ASID scope maintenance operation synchronously.

## Normative identity {#PTO-INST-SCALAR-TLB-IAV}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-tlb-iav-purpose role=purpose -->
## What TLB.IAV does

`TLB.IAV` completes the canonical 48-bit virtual address with address-space-identifier scope translation-maintenance operation. The encoded operand is the same kind of 48-bit address that `TLB.IV` takes; the difference is the scope the maintenance request is issued for, which the operation token `Maintenance_TLB_IAV` names.

<!-- PTO-READER-BLOCK: scalar-tlb-iav-mechanism role=mechanism -->
## System mechanism

`InstructionContractHandler_TLB_IAV` returns the shared maintenance handler (`asl/scalar/sys/TLB.IAV.asl:18`), and the token `Maintenance_TLB_IAV` is grouped with `Maintenance_TLB_IV` in the executor's address case (`asl/scalar/model/sys/semantics.asl:142`). Both share the canonical-address test and the same privilege rule.

`InstructionContractMaintenanceRequiresRootRing_TLB_IAV` returns `TRUE` (`asl/scalar/sys/TLB.IAV.asl:42`), so the operation rejects any ring other than ACR0 before the operand is examined by the executor.

<!-- PTO-READER-BLOCK: scalar-tlb-iav-inputs-outputs role=inputs-outputs -->
## Inputs and outputs

`SrcL` is the single encoded operand, a Reg5 source from R0..R23, T#1..T#4, or U#1..U#4. This form has no separate identifier field, so the encoded operand is only the address; the address-space scope the operation names is not carried in the instruction (`asl/scalar/sys/TLB.IAV.asl:1`).

No destination is written. On success the operand appears in the maintenance record; on rejection nothing is published.

<!-- PTO-READER-BLOCK: scalar-tlb-iav-effects role=effects -->
## Architectural effects

On success the TLB epoch increases by one and `Maintenance_TLB_IAV` plus the captured address enter the maintenance record (`asl/scalar/model/sys/semantics.asl:146`). `TPC` advances afterwards, from the dispatcher's success path.

Design point: the record keeps the operation token, so a reader can distinguish this address-space-scoped request from the plain `TLB.IV` request even though the two advance the same counter.

No ordinary scalar memory access occurs, and no register, temporary queue, or system register is written.

<!-- PTO-READER-BLOCK: scalar-tlb-iav-constraints role=constraints -->
## Placement and rejection

As with every SYS-block instruction, an attempt outside an active SYS block body raises `Fault_BundleControl` before legality or effects. Encoded legality then covers the fixed bits and the `SrcL` selector.

At the executor, a non-root ring raises `Fault_IllegalInstruction` first. Only an ACR0 attempt reaches the canonical-address check, and a non-canonical value there raises `Fault_DataPage` with the operand as the trap argument, leaving the TLB epoch unchanged (`asl/scalar/model/sys/semantics.asl:143`).

<!-- PTO-READER-BLOCK: scalar-tlb-iav-example role=example -->
## Non-normative example

This spelling example is illustrative; exact legality and effects remain in the generated contract below.

At ACR0 with the source register holding 0x1234, `tlb.iav SrcL` advances the TLB epoch by one and records `Maintenance_TLB_IAV` with operand 0x1234. If the register instead holds a value whose bits 63:48 are not the sign extension of bit 47, the attempt raises `Fault_DataPage` and the TLB epoch stays where it was.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
tlb.iav SrcL
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| tlb_iav_32_95f4937d2917 | L32 | 32 | 0x0020702b / 0xfff07fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| tlb_iav_32_95f4937d2917 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| tlb_iav_32_95f4937d2917 | SrcL | 5 | 0–31 | none | none | Reg5 source: R0..R23, T#1..T#4, or U#1..U#4 | Encoded zero names the architectural zero GPR. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 source: R0..R23, T#1..T#4, or U#1..U#4 |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/TLB.IAV.asl -->
```asl
readonly func InstructionContractOperation_TLB_IAV()
    => ScalarOperation
begin
    return ScalarOperation_TLB_IAV;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
TLB.IAV executes as one scalar operation in the body of an active SYS block.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/TLB.IAV.asl -->
```asl
readonly func InstructionContractHandler_TLB_IAV()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteMaintenance;
end;

pure func InstructionContractRequiresSystemBlock_TLB_IAV()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractMaintenanceOperation_TLB_IAV()
    => MaintenanceOperation
begin
    return Maintenance_TLB_IAV;
end;

pure func InstructionContractMaintenanceUsesOperand_TLB_IAV()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractMaintenanceRequiresRootRing_TLB_IAV()
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

- Success records Maintenance_TLB_IAV and its exact operand token.
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

- tlb.iav SrcL

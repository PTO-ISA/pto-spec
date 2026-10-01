<!-- GENERATED FROM: asl/scalar/sys/TLB.IA.asl -->
# TLB.IA

**Normative ASL source:** `asl/scalar/sys/TLB.IA.asl`

TLB.IA completes the 16-bit ASID token in bits 15:0 maintenance operation synchronously.

## Normative identity {#PTO-INST-SCALAR-TLB-IA}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-tlb-ia-purpose role=purpose -->
## What TLB.IA does

`TLB.IA` completes the 16-bit ASID translation-maintenance operation synchronously. Its operand is not an address but an address-space identifier: bits 15:0 of `SrcL` carry the token, and bits 63:16 must be zero for the attempt to be accepted.

<!-- PTO-READER-BLOCK: scalar-tlb-ia-mechanism role=mechanism -->
## System mechanism

The instruction selects the shared maintenance handler (`asl/scalar/sys/TLB.IA.asl:18`) and the token `Maintenance_TLB_IA` (`asl/scalar/sys/TLB.IA.asl:30`). That token has its own case in the executor, separate from the two address cases, because its operand test is a bit-range test rather than a canonicality test (`asl/scalar/model/sys/semantics.asl:148`).

`InstructionContractMaintenanceRequiresRootRing_TLB_IA` returns `TRUE` (`asl/scalar/sys/TLB.IA.asl:42`), which places the operation in the ACR0-only group of `MaintenanceAccessPermitted`.

<!-- PTO-READER-BLOCK: scalar-tlb-ia-inputs-outputs role=inputs-outputs -->
## Inputs and outputs

`SrcL` is a Reg5 source: R0..R23, T#1..T#4, or U#1..U#4. The instruction interprets it as a packed token, so a value with any nonzero bit above bit 15 is not a valid operand of this form.

There is no destination operand and no second field. On success the token is recorded in the maintenance record; on any rejection nothing is published.

<!-- PTO-READER-BLOCK: scalar-tlb-ia-effects role=effects -->
## Architectural effects

A successful attempt advances the TLB epoch by one and stores `Maintenance_TLB_IA` with the operand in the maintenance record (`asl/scalar/model/sys/semantics.asl:148`). `TPC` advances by the instruction length once the attempt reports success.

Design point: the operand check is a range test rather than a mask, so an operand with stray high bits is rejected instead of being silently truncated to its low 16 bits. Software that packs an identifier into the register must therefore zero the upper bits.

The instruction performs no ordinary scalar memory access and writes no register, queue, or system register.

<!-- PTO-READER-BLOCK: scalar-tlb-ia-constraints role=constraints -->
## Placement and rejection

Three rejections belong to the maintenance path, and they come in this order. Outside an active SYS block body the dispatcher raises `Fault_BundleControl` before the executor. A ring other than ACR0 raises `Fault_IllegalInstruction`. At ACR0, an operand whose bits 63:16 are not all zero raises `Fault_IllegalInstruction`, and the TLB epoch is left unchanged (`asl/scalar/model/sys/semantics.asl:149`). One rejection happens between placement and the executor: the shared operand-legality pass rejects a `SrcL` selector that names an unavailable temporary-queue entry (`asl/scalar/model/types/operands.asl:6`).

Design point: the privilege test runs before the operand test. A non-root attempt therefore takes the privilege rejection even when its operand is also malformed, and it never reaches the epoch step.

<!-- PTO-READER-BLOCK: scalar-tlb-ia-example role=example -->
## Non-normative example

This spelling example is illustrative; exact legality and effects remain in the generated contract below.

At ACR0 with the source register holding 3, `tlb.ia SrcL` passes the ASID bit test, advances the TLB epoch by one, and records `Maintenance_TLB_IA` with operand 3. If an upper bit is set, for example 0x10000, the same instruction raises `Fault_IllegalInstruction` at ACR0 and the TLB epoch does not move.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
tlb.ia SrcL
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| tlb_ia_32_e794d6bf347e | L32 | 32 | 0x0000702b / 0xfff07fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| tlb_ia_32_e794d6bf347e | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| tlb_ia_32_e794d6bf347e | SrcL | 5 | 0–31 | none | none | Reg5 source: R0..R23, T#1..T#4, or U#1..U#4 | Encoded zero names the architectural zero GPR. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 source: R0..R23, T#1..T#4, or U#1..U#4 |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/TLB.IA.asl -->
```asl
readonly func InstructionContractOperation_TLB_IA()
    => ScalarOperation
begin
    return ScalarOperation_TLB_IA;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
TLB.IA executes as one scalar operation in the body of an active SYS block.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/TLB.IA.asl -->
```asl
readonly func InstructionContractHandler_TLB_IA()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteMaintenance;
end;

pure func InstructionContractRequiresSystemBlock_TLB_IA()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractMaintenanceOperation_TLB_IA()
    => MaintenanceOperation
begin
    return Maintenance_TLB_IA;
end;

pure func InstructionContractMaintenanceUsesOperand_TLB_IA()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractMaintenanceRequiresRootRing_TLB_IA()
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
- Operand bits 63:16 must be zero; bits 15:0 are the ASID token.

## State effects

- Success records Maintenance_TLB_IA and its exact operand token.
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

- tlb.ia SrcL

<!-- GENERATED FROM: asl/scalar/sys/HL.SSRSET.asl -->
# HL.SSRSET

**Normative ASL source:** `asl/scalar/sys/HL.SSRSET.asl`

HL.SSRSET writes the complete encoded system-register address.

## Normative identity {#PTO-INST-SCALAR-HL-SSRSET}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
hl.ssrset SrcL, SSR_ID
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_ssrset_48_dd25753307c2 | HL48 | 48 | 0x0000103b000e / 0x00007fff000f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_ssrset_48_dd25753307c2 | SSR_ID | 24 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":4,"value_lsb":12,"width":12}] |
| hl_ssrset_48_dd25753307c2 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_ssrset_48_dd25753307c2 | SSR_ID | 24 | 0–16777215 | none | none | system-register identifier | Encoded zero selects value zero of the system-register identifier. |
| hl_ssrset_48_dd25753307c2 | SrcL | 5 | 0–31 | none | none | Reg5 source: R0..R23, T#1..T#4, or U#1..U#4 | Encoded zero names the architectural zero GPR. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SSR_ID | system-register identifier |
| SrcL | Reg5 source: R0..R23, T#1..T#4, or U#1..U#4 |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/HL.SSRSET.asl -->
```asl
readonly func InstructionContractOperation_HL_SSRSET()
    => ScalarOperation
begin
    return ScalarOperation_HL_SSRSET;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
HL.SSRSET executes as one scalar operation in the body of an active SYS block.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/HL.SSRSET.asl -->
```asl
readonly func InstructionContractHandler_HL_SSRSET()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteSystemRegisterSet;
end;

pure func InstructionContractRequiresSystemBlock_HL_SSRSET()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractSystemTransferKind_HL_SSRSET()
    => bits(2)
begin
    return '01';
end;

pure func InstructionContractSystemAddressWidth_HL_SSRSET()
    => integer {5,12,24}
begin
    return 24;
end;

pure func InstructionContractPushesTemporaryT_HL_SSRSET()
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
- The complete encoded address is checked against its RO, WO, RW, unknown-address, and current-ACR access rules before effects.

## State effects

- Write the complete XLEN source to the selected writable system register.
- A rejected write preserves the source and target register except for ordinary trap entry.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Preflight the complete address, current-ACR permission, and writable access class before reading SrcL.
- Snapshot SrcL, perform the register write, and then advance TPC.

## Exceptions

- Invalid block placement raises Illegal Block Exception before encoded-field legality or effects.
- A reserved encoding or rejected access raises Illegal Instruction before destination, queue, system-state, or TPC effects.

## Examples

- hl.ssrset SrcL, SSR_ID

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->

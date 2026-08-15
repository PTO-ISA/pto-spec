<!-- GENERATED FROM: asl/block/encoding/C.BSTART.FP.asl -->
# C.BSTART.FP

**Normative ASL source:** `asl/block/encoding/C.BSTART.FP.asl`

Starts a compressed FP block with fallthrough, indirect, or return transfer; every other BrType rejects before effects.

## Normative identity {#PTO-INST-BLOCK-C-BSTART-FP}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
C.BSTART.FP FALL
C.BSTART.FP IND
C.BSTART.FP RET
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| c_bstart_fp_16_9dcef7e3a85b | C16 | 16 | 0x0080 / 0xc7ff | [{"field":"BrType","operator":"one-of","values":[1,5,7]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| c_bstart_fp_16_9dcef7e3a85b | BrType | 3 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":3}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| c_bstart_fp_16_9dcef7e3a85b | BrType | 3 | 1, 5, 7 | none | 0, 2–4, 6 | encoded transfer kind: FALL, IND, or RET | Encoded zero is reserved and rejected. |

- `c_bstart_fp_16_9dcef7e3a85b.BrType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| BrType | encoded transfer kind: FALL, IND, or RET |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/encoding/C.BSTART.FP.asl -->
```asl
readonly func InstructionContractMatches_C_BSTART_FP(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_c_bstart_fp_16_9dcef7e3a85b);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
After any active predecessor block commits successfully, C.BSTART.FP opens one Floating block. FALL and RET may start without a predecessor; IND requires an active retiring Standard or Floating BARG.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/encoding/C.BSTART.FP.asl -->
```asl
pure func InstructionContractBranchTypeLegal_C_BSTART_FP(
    branch_type: bits(3))
    => boolean
begin
    return branch_type == '001' ||
           branch_type == '101' ||
           branch_type == '111';
end;

pure func InstructionContractTransfer_C_BSTART_FP(
    branch_type: bits(3))
    => BundleTransfer
begin
    assert InstructionContractBranchTypeLegal_C_BSTART_FP(branch_type);
    if branch_type == '001' then
        return BundleTransfer_Fallthrough;
    elsif branch_type == '101' then
        return BundleTransfer_Indirect;
    else
        return BundleTransfer_Return;
    end;
end;

readonly func InstructionContractHandler_C_BSTART_FP() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- BrType is always encoded; it has no omitted or default form.

## Legality

- c_bstart_fp_16_9dcef7e3a85b.BrType accepts exactly 1 (FALL), 5 (IND), or 7 (RET); code 6 is only the embedded low halfword of fused BSTART.ICALL and is illegal as a standalone 16-bit instruction.

## State effects

- FALL installs a non-selecting sequential Floating BARG. IND installs the snapshotted retiring BARG.BPCN; RET installs the snapshotted architectural return address.
- The installed candidate continuation remains pending until BSTOP or the next BSTART commits the new block.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Decode and transfer legality precede source selection. IND snapshots retiring BARG.BPCN and RET snapshots architectural ra before predecessor retirement.
- Target alignment is checked before retirement; the new Floating BARG is installed only after successful retirement.

## Exceptions

- BrType codes 0, 2, 3, 4, and 6 do not decode as standalone C.BSTART.FP and raise Fault_IllegalInstruction before effects.
- IND without an active retiring Standard or Floating BARG raises Fault_BundleControl before effects. An odd snapshotted BARG.BPCN or return address raises Fault_InstructionPC before predecessor retirement.
- If predecessor commit fails, the retiring block remains authoritative and no Floating BARG is installed.

## Examples

- C.BSTART.FP FALL
- C.BSTART.FP IND
- C.BSTART.FP RET

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->

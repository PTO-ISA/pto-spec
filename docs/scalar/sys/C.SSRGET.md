<!-- GENERATED FROM: asl/scalar/sys/C.SSRGET.asl -->
# C.SSRGET

**Normative ASL source:** `asl/scalar/sys/C.SSRGET.asl`

C.SSRGET reads the complete encoded system-register address.

## Normative identity {#PTO-INST-SCALAR-C-SSRGET}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
c.ssrget SSR-ID, ->t
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| c_ssrget_16_9d83a6f2749a | C16 | 16 | 0x802c / 0xf83f | [{"field":"SSRID","operator":"one-of","values":[0,1,16]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| c_ssrget_16_9d83a6f2749a | SSRID | 5 | encoding-defined | [{"instruction_lsb":6,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| c_ssrget_16_9d83a6f2749a | SSRID | 5 | 0–1, 16 | none | 2–15, 17–31 | short system-register identifier | Encoded zero selects value zero of the short system-register identifier. |

- `c_ssrget_16_9d83a6f2749a.SSRID` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| SSRID | short system-register identifier |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/C.SSRGET.asl -->
```asl
readonly func InstructionContractOperation_C_SSRGET()
    => ScalarOperation
begin
    return ScalarOperation_C_SSRGET;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
C.SSRGET executes as one scalar operation in the body of an active SYS block.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/C.SSRGET.asl -->
```asl
readonly func InstructionContractHandler_C_SSRGET()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteCompressedSystemRegisterGet;
end;

pure func InstructionContractRequiresSystemBlock_C_SSRGET()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractSystemTransferKind_C_SSRGET()
    => bits(2)
begin
    return '00';
end;

pure func InstructionContractSystemAddressWidth_C_SSRGET()
    => integer {5,12,24}
begin
    return 5;
end;

pure func InstructionContractPushesTemporaryT_C_SSRGET()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractDirectSystemIDLegal_C_SSRGET(
    identifier: bits(5)) => boolean
begin
    return identifier == '00000' ||
           identifier == '00001' ||
           identifier == '10000';
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Every displayed operand is encoded explicitly. Encoded zero is an assigned value and never denotes omission.

## Legality

- Every fixed bit and explicit field constraint is checked before operation semantics.
- The complete encoded address is checked against its RO, WO, RW, unknown-address, and current-ACR access rules before effects.
- Only direct IDs 0, 1, and 16 are assigned; every other five-bit ID is reserved.

## State effects

- Read THREAD_PTR, GLOBAL_PTR, or TIME for direct IDs 0, 1, or 16 and push the complete XLEN value to T.
- A rejected access preserves T queue order and contents except for ordinary trap entry.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Check block placement and encoded legality before source reads or architectural effects.
- Snapshot every scalar source before the selected system effect, then advance TPC only after success.

## Exceptions

- Invalid block placement raises Illegal Block Exception before encoded-field legality or effects.
- A reserved encoding or rejected access raises Illegal Instruction before destination, queue, system-state, or TPC effects.

## Examples

- c.ssrget SSR-ID, ->t

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->

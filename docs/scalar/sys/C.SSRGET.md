<!-- GENERATED FROM: asl/scalar/sys/C.SSRGET.asl -->
# C.SSRGET

**Normative ASL source:** `asl/scalar/sys/C.SSRGET.asl`

C.SSRGET reads the complete encoded system-register address.

## Normative identity {#PTO-INST-SCALAR-C-SSRGET}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-c-ssrget-purpose role=purpose -->
## What C.SSRGET does

`C.SSRGET` reads one system register and pushes the value it read onto the `T` queue. It is the compressed system-register read form: the destination is implicit and the register is named by a short identifier.

Only three identifiers are assigned, so the instruction reaches exactly three registers: `THREAD_PTR`, `GLOBAL_PTR` and `TIME`.

<!-- PTO-READER-BLOCK: scalar-c-ssrget-mechanism role=mechanism -->
## How the instruction is placed and executed

This instruction is one scalar operation of an active SYS block. The scalar dispatcher first checks that a bundle is active and that its body is active with block kind System; a SYS form outside such a block is rejected with `Fault_BundleControl`, before any encoded-field check and before any architectural effect.

Encoded legality and source availability are then checked, and only then does the handler run.

The 5-bit identifier is treated as the low bits of a system-register address, so identifiers `0`, `1` and `16` name addresses `0x0000`, `0x0001` and `0x0010`. Those are the addresses of `THREAD_PTR`, `GLOBAL_PTR` and `TIME`. Every other five-bit identifier is reserved.

The read then goes through the common system-register read rule, which applies two checks in order. The first is the ring check: an address whose low twelve bits are below `0x0f00` is readable from every ring, and any other address requires the root ring. All three assigned addresses are in the below-`0x0f00` group, so none of them needs the root ring. The second check rejects an address whose access class is unknown or write-only; all three assigned addresses are readable, so none of them is rejected here either.

If both checks pass, the read value is pushed onto the `T` queue as a complete XLEN word. If either check fails, the handler raises `Fault_IllegalInstruction` and does not push, so the `T` queue keeps its order and contents.

Design point: the destination is the `T` queue and not a GPR selector. That is what lets the compressed form drop its destination field, and it also means a rejected read can be made side-effect-free on the queue simply by testing before the push instead of after it.

<!-- PTO-READER-BLOCK: scalar-c-ssrget-inputs-outputs role=inputs-outputs -->
## Inputs and outputs

- `SSRID` is the only encoded operand: a 5-bit short system-register identifier. Assigned values are `0`, `1` and `16`; every other value is reserved. Encoded zero is an assigned value and names `THREAD_PTR`, not an omitted operand.
- The destination is implicit: the complete XLEN value is pushed onto the `T` queue, becoming the newest entry and discarding the oldest entry when the queue is full.
- No GPR and no `U` queue entry is written, and no scalar register is read.

<!-- PTO-READER-BLOCK: scalar-c-ssrget-effects role=effects -->
## Architectural effects

On success one `T` push happens and `TPC` advances by `2` bytes. The queue push shifts the existing entries by one position, so a program that keeps earlier results in `T#1`..`T#4` must account for the shift.

The read itself has no memory effect and takes no reservation. `TIME` returns the architectural time value, which the model advances once per decoded execution attempt, so a `TIME` read observes the attempt count at the point the source was read.

<!-- PTO-READER-BLOCK: scalar-c-ssrget-constraints role=constraints -->
## Placement and rejection

Invalid block placement is rejected first, with `Fault_BundleControl`, before the encoded field is even considered.

A reserved identifier raises `Fault_IllegalInstruction` before the implicit `T` destination effect, so a rejected `C.SSRGET` leaves the `T` queue order and contents untouched apart from ordinary trap entry. The same rejection covers a read that the access rules refuse.

The complete encoded address is what the access rules see, not just the five-bit identifier, so the ring check and the access-class check both apply to the address the identifier names.

<!-- PTO-READER-BLOCK: scalar-c-ssrget-example role=example -->
## Non-normative example

`c.ssrget SSR-ID, ->t` with `SSRID=16` reads `TIME` and pushes the complete XLEN time value onto the `T` queue. With `SSRID=2` the identifier is reserved: the instruction raises `Fault_IllegalInstruction`, no value is pushed, and the existing `T` entries keep their positions.
<!-- SUPPLEMENTARY-END -->

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

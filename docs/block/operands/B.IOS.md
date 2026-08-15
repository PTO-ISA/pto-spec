<!-- GENERATED FROM: asl/block/operands/B.IOS.asl -->
# B.IOS

**Normative ASL source:** `asl/block/operands/B.IOS.asl`

Binds one ordered absolute Core-private Shared register S0..S255 as a source or destination with a common four-PE participation mask.

## Normative identity {#PTO-INST-BLOCK-B-IOS}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
B.IOS S<SharedTID>, mask=<PE_MASK> | B.IOS mask=<PE_MASK>, ->S<SharedTID><TSize>
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| b_ios_32_4ba5ef98fdaa | L32 | 32 | 0x00001013 / 0xf00871ff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| b_ios_32_4ba5ef98fdaa | SharedTID | 8 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":8}] |
| b_ios_32_4ba5ef98fdaa | PE_MASK | 4 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":4}] |
| b_ios_32_4ba5ef98fdaa | TSize | 3 | encoding-defined | [{"instruction_lsb":9,"value_lsb":0,"width":3}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| b_ios_32_4ba5ef98fdaa | SharedTID | 8 | 0–255 | none | none | absolute Core-private Shared register S0 through S255, visible to all four PEs of that core | Encoded zero names S0; it does not mean absence. |
| b_ios_32_4ba5ef98fdaa | PE_MASK | 4 | 0–15 | none | none | four-PE predicate common to every effective Local and Shared binding in the block | Encoded zero selects no participating PE and makes B.IOS a strict no-op. |
| b_ios_32_4ba5ef98fdaa | TSize | 3 | 0–7 | none | none | role and capacity: 0 source; 1..7 destination with 128 B..8 KiB per participating PE | Encoded zero selects a Shared source; codes 1..7 select a Shared destination and its per-PE capacity. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SharedTID | absolute Core-private Shared register S0 through S255, visible to all four PEs of that core |
| PE_MASK | four-PE predicate common to every effective Local and Shared binding in the block |
| TSize | role and capacity: 0 source; 1..7 destination with 128 B..8 KiB per participating PE |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/operands/B.IOS.asl -->
```asl
readonly func InstructionContractMatches_B_IOS(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_b_ios_32_4ba5ef98fdaa);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
Header command after BSTART and before the first body instruction. A block may contain zero to four effective B.IOS instructions, ordered according to the selected operation schema.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/operands/B.IOS.asl -->
```asl
pure func InstructionContractSharedIsSource_B_IOS(
    size_code: integer {0..7}) => boolean
begin
    return size_code == 0;
end;

pure func InstructionContractPerPECapacity_B_IOS(
    size_code: integer {1..7}) => integer
begin
    return TileSizeCodeBytes(size_code);
end;

pure func InstructionContractCoreCapacity_B_IOS(
    size_code: integer {1..7}, pe_mask: bits(4)) => integer
begin
    return TileCoreAllocationBytes(pe_mask,
        InstructionContractPerPECapacity_B_IOS(size_code));
end;

readonly func InstructionContractHandler_B_IOS() => CommandSemanticHandler
begin
    return CommandHandler_BindBundleSharedIO;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- S0 is an ordinary absolute Shared-register name. TSize=0 selects the source form; TSize=1..7 selects a destination capacity of 128 B..8 KiB per participating PE.
- PE_MASK=0000 is a strict no-op before placement, duplicate, schema, allocation, descriptor, memory, and downstream fault checks.

## Legality

- All SharedTID codes 0..255 are assigned absolute Core-private Shared-register names S0..S255.
- TSize code 0 is the source role; destination codes 1..7 encode 128 B, 256 B, 512 B, 1 KiB, 2 KiB, 4 KiB, and 8 KiB per participating PE.
- PE_MASK is a four-PE predicate and multiple bits are legal. Every effective Shared and Local binding in the block uses the same nonzero mask unless the selected operation is stricter.
- A participating B.IOS is legal only after BSTART and before the block body. At most four effective Shared bindings are accepted in encoded order.
- Two effective bindings in one block may not name the same Sx. The selected operation schema determines each ordered Shared operand role and must agree with TSize source/destination encoding.

## State effects

- Binds one ordered absolute Core-private Shared register S0..S255 as a source or destination with a common four-PE participation mask.
- A source binding is read-only and never changes its Shared descriptor, allocation mask, initialized mask, or payload. An uninitialized source supplies undefined-register values through a temporary operation-derived descriptor without allocating Sx.
- A successful destination atomically updates selected payload quarters and a compatible persistent descriptor; the selected operation defines whether the aggregate Shared value is published. Its first write fixes the allocation mask; later writes may update only a subset with a compatible descriptor and cannot expand the mask.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Effective B.IOS bindings form one encoded-order stream of at most four operands. The selected operation consumes the stream in schema order.
- The architecture imposes no ordering between conflicting PE accesses to Shared payload offsets; software avoids conflicts or establishes separate synchronization.

## Exceptions

- Reserved instruction bits raise Fault_IllegalInstruction before architectural effects.
- A participating B.IOS outside an active header, a duplicate SharedTID, or a fifth effective binding raises Illegal Block Exception before changing the stream.
- A mismatched effective PE_MASK, incompatible destination descriptor, mask expansion, or operation-schema role mismatch raises Fault_TileLegality before Shared state changes.
- PE_MASK zero is a strict no-op and cannot raise a downstream schema, duplicate, allocation, descriptor, or memory fault.

## Examples

- B.IOS S1, mask=0011
- B.IOS mask=1111, ->S255<001>

<!-- SUPPLEMENTARY-BEGIN -->
TSize zero identifies the Shared source form. A Shared destination uses TSize
1 through 7 as the same per-PE capacity classes as B.IOT; PE_MASK determines
how many equal per-PE allocations the core must reserve. Shared physical rows
and columns obey the same derivation and power-of-two constraints as Local
Tile descriptors.
<!-- SUPPLEMENTARY-END -->

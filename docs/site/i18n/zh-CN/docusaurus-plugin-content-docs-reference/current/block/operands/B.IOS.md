<!-- GENERATED FROM: asl/block/operands/B.IOS.asl -->
# B.IOS

**Normative ASL source:** `asl/block/operands/B.IOS.asl`

Binds one ordered absolute Core-private Shared register S0..S63 as a source or destination with a common four-PE participation mode decoded to a fixed mask.

## Normative identity {#PTO-INST-BLOCK-B-IOS}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-b-ios-purpose role=purpose -->
## B.IOS 的作用

`B.IOS` 是一条 32 位 Block header 命令，用来记录有序的 Core 范围 Shared Tile 源和目的位置。它修改待处理 Block 元数据，不会立即执行 Tile body 操作。

<!-- PTO-READER-BLOCK: block-b-ios-mechanism role=mechanism -->
## 位置与机制

该命令位于有效 header 中，并且在第一条 body 指令之前。它的有效顺序和数量由完成后的操作 schema 检查，而不是由本命令单独推断。

公共 PE-mode 解码器只形成一次 4-PE mask。零 mask 是严格 no-op；有效的 Shared 源保持只读，有效目的位置则在完整验证后等待原子发布。

<!-- PTO-READER-BLOCK: block-b-ios-inputs role=inputs-outputs -->
## 操作数与 header 角色

- `SharedTileID` 选择绝对 Shared 寄存器；其确切分配域仍以下方生成契约为准。
- `SizeCode` 选择只读源或目的容量；其确切分配域仍以下方生成契约为准。
- `PEMode` 编码参与 PE 模式；其确切分配域仍以下方生成契约为准。

<!-- PTO-READER-BLOCK: block-b-ios-effects role=effects -->
## 待处理状态与完成

被接受的 header 命令只改变自己的待处理记录或 carrier。除非本所有者明确指出即时 header 状态更新，否则架构 Tile、Shared、GPR、内存和完成影响都推迟到完整 Block。

<!-- PTO-READER-BLOCK: block-b-ios-constraints role=constraints -->
## 合法性与故障边界

契约区分原始解码失败、header 流错误和 Tile 合法性失败。零 mask 绑定是严格 no-op，会跳过后续 schema、重复、分配、描述符和内存检查。

<!-- PTO-READER-BLOCK: block-b-ios-example role=example -->
## 非规范示例

以下为非规范示例，仅用于说明当前所有者，不替代其定义。

```asm
B.IOS S<SharedTileID>, mask=<PE_MASK> | B.IOS mask=<PE_MASK>, ->S<SharedTileID><SizeCode>
```

假设当前存在兼容的有效 header，并且之前没有冲突的 `B.IOS` 命令。把 `B.IOS S<SharedTileID>, mask=<PE_MASK> | B.IOS mask=<PE_MASK>, ->S<SharedTileID><SizeCode>` 放在下一个 header 槽，会记录该命令的待处理字段；它本身不会执行最终的 body 操作。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
B.IOS S<SharedTileID>, mask=<PE_MASK> | B.IOS mask=<PE_MASK>, ->S<SharedTileID><SizeCode>
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| b_ios_32_4ba5ef98fdaa | L32 | 32 | 0x00001013 / 0xfc0871ff | [{"field":"SizeCode","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12]},{"field":"PEMode","operator":"one-of","values":[0,1,2,3,4,5,6,7]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| b_ios_32_4ba5ef98fdaa | SharedTileID | 6 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":6}] |
| b_ios_32_4ba5ef98fdaa | SizeCode | 4 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":4}] |
| b_ios_32_4ba5ef98fdaa | PEMode | 3 | encoding-defined | [{"instruction_lsb":9,"value_lsb":0,"width":3}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| b_ios_32_4ba5ef98fdaa | SharedTileID | 6 | 0–63 | none | none | absolute Core-private Shared register S0 through S63, visible to all four PEs of that core | Encoded zero names S0; it does not mean absence. |
| b_ios_32_4ba5ef98fdaa | SizeCode | 4 | 0–12 | none | 13–15 | role and capacity: 0 source; 1..12 destination with 128 B..256 KiB for the complete Core-wide Shared object | Encoded zero selects a Shared source and never allocates. |
| b_ios_32_4ba5ef98fdaa | PEMode | 3 | 0–7 | none | none | three-bit encoded participation mode expanded by the common decoder to a four-PE semantic mask | Encoded zero decodes to mask 0000 and makes B.IOS a strict no-op. |

- `b_ios_32_4ba5ef98fdaa.SizeCode` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| SharedTileID | absolute Core-private Shared register S0 through S63, visible to all four PEs of that core |
| SizeCode | role and capacity: 0 source; 1..12 destination with 128 B..256 KiB for the complete Core-wide Shared object |
| PEMode | three-bit encoded participation mode expanded by the common decoder to a four-PE semantic mask |

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
    size_code: integer {0..12}) => boolean
begin
    return size_code == 0;
end;

pure func InstructionContractSharedCapacity_B_IOS(
    size_code: integer {1..12}) => integer
begin
    return TileSizeCodeBytes(size_code);
end;

pure func InstructionContractCoreCapacity_B_IOS(
    size_code: integer {1..12}, pe_mask: bits(4)) => integer
begin
    return InstructionContractSharedCapacity_B_IOS(size_code);
end;

readonly func InstructionContractHandler_B_IOS() => CommandSemanticHandler
begin
    return CommandHandler_BindBundleSharedIO;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- S0 is an ordinary absolute Shared-register name. SizeCode=0 selects the source form; SizeCode=1..12 selects a destination capacity of 128 B, 256 B, 512 B, 1 KiB, 2 KiB, 4 KiB, 8 KiB, 16 KiB, 32 KiB, 64 KiB, 128 KiB, or 256 KiB for the complete Core-wide Shared object. Codes 13..15 are reserved.
- PEMode is a three-bit encoding expanded by the common profile decoder to the fixed four-PE semantic mask: 000 none, 001 PE0, 010 PE1, 011 PE2, 100 PE3, 101 PE0+PE1, 110 PE0+PE1+PE2, and 111 all four PEs.
- PEMode=000 decodes to no participating PE and is a strict no-op before placement, duplicate, schema, allocation, descriptor, memory, and downstream fault checks.

## Legality

- All SharedTileID codes 0..63 are assigned absolute Core-private Shared-register names S0..S63.
- SizeCode code 0 is the source role; destination codes 1..12 encode 128 B, 256 B, 512 B, 1 KiB, 2 KiB, 4 KiB, 8 KiB, 16 KiB, 32 KiB, 64 KiB, 128 KiB, and 256 KiB for the complete Core-wide Shared object. Codes 13..15 are reserved.
- The three-bit PEMode field accepts all eight encodings and the common profile decoder expands them exactly to the fixed four-PE semantic mask table. PEMode=000 is the strict no-effect source-bearing encoding.
- A participating B.IOS is legal only after BSTART and before the block body. At most four effective Shared bindings are accepted in encoded order.
- Two effective bindings in one block may not name the same Sx. The selected operation schema determines each ordered Shared operand role and must agree with SizeCode source/destination encoding.

## State effects

- The common PE-mode decoder expands PEMode once to the semantic four-PE mask used by every effective Shared binding.
- A zero decoded mask is a strict no-op. A source binding is read-only and never changes its Shared descriptor, allocation mask, initialized mask, or payload.
- A successful destination atomically updates selected payload quarters and a compatible persistent descriptor; its first write fixes the allocation mask and later writes cannot expand it.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Effective B.IOS bindings form one encoded-order stream of at most four operands. The selected operation consumes the stream in schema order.
- The architecture imposes no ordering between conflicting PE accesses to Shared payload offsets; software avoids conflicts or establishes separate synchronization.

## Exceptions

- Reserved instruction bits, SizeCode 13..15, and malformed field combinations raise Fault_IllegalInstruction before architectural effects.
- A participating B.IOS outside an active header, a duplicate SharedTileID, or a fifth effective binding raises Illegal Block Exception before changing the stream.
- A mismatched effective decoded PE mask, incompatible destination descriptor, mask expansion, or operation-schema role mismatch raises Fault_TileLegality before Shared state changes.
- PEMode=000 is a strict no-op and cannot raise a downstream schema, duplicate, allocation, descriptor, or memory fault.

## Examples

- B.IOS S1, mask=0011
- B.IOS mask=1111, ->S63<0001>

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

`B.IOS` 是一条 32 位块头部命令，把一个 Shared Tile 绑定到当前块的操作。Shared Tile 是 64 个 Core 私有寄存器 `S0` 至 `S63` 之一，Core 的四个 PE 都能看到它。一条 `B.IOS` 指定寄存器，说明它是源还是新目标，并给出 PE 参与模式。

`B.IOS` 本身不执行任何操作。它向块的 Shared 绑定追加一条记录，所选操作在块提交时消费这些记录。参见 [Shared 绑定](../model/operands/shared-bindings.md)。

<!-- PTO-READER-BLOCK: block-b-ios-mechanism role=mechanism -->
## 放置与机制

参与的 `B.IOS` 必须出现在活动块的头部、第一条主体指令之前。一个块最多保存四条 Shared 绑定，按编码顺序排列，操作按其模式顺序消费它们。

处理程序依次检查：SizeCode 编码、零参与、放置，然后调用 `BindBundleSharedIO`。该函数要求掩码非零且与已记录的每条 Tile 绑定和 Shared 绑定的掩码相同，拒绝已被绑定的 Shared Tile ID，并填入第一个空闲条目。下一条非修饰符头部命令会关闭随后 `B.SUBVIEW` 或 `B.ASSEMBLE` 可修饰的范围组。

设计要点：每个块中一个 Shared Tile ID 只能出现一次。因此每个已记录条目都指向不同的 Shared Tile，任何块都不能把同一个 `Sx` 同时绑定为源和目标。

<!-- PTO-READER-BLOCK: block-b-ios-inputs role=inputs-outputs -->
## 字段与编码值

- `SharedTileID`（位 25:20）直接指定 `S0` 至 `S63`。编码零指 `S0`，不表示缺失。
- `SizeCode`（位 18:15）为 0 时表示源。编码 1 至 12 表示目标，容量为 128 B、256 B、512 B、1 KiB、2 KiB、4 KiB、8 KiB、16 KiB、32 KiB、64 KiB、128 KiB 或 256 KiB。编码 13 至 15 保留。
- `PEMode`（位 11:9）使用与 `B.IOT` 相同的表：`000` 无，`001` PE0，`010` PE1，`011` PE2，`100` PE3，`101` PE0 与 PE1，`110` PE0 至 PE2，`111` 全部四个。
- 位 31:26 与位 19 固定为零。

设计要点：Shared 容量是 256 KiB Shared 池中一个完整的 Core 范围对象的大小。与 `B.IOT` 不同，它不乘以参与 PE 的数量。`PEMode` 选择哪些 PE 发出或消费该绑定；它不为这些 PE 分配载荷四分之一区域或偏移。

<!-- PTO-READER-BLOCK: block-b-ios-effects role=effects -->
## 挂起状态与发布

被接受的 `B.IOS` 只改变挂起的 Shared 绑定。源绑定是只读的：它从不改变 Shared 描述符、分配掩码、初始化掩码或载荷。

由单个 PE 写入的目标在操作成功时发布完整的 Shared 对象。有多个参与 PE 的目标必须带有 `B.ASSEMBLE` 修饰符，其中每个写入者指定一个明确且互不重叠的范围，并由 LAST 发布对象。

设计要点：`PEMode = 000` 在 `SizeCode` 编码检查之后才是严格无操作；编码 13 至 15 仍会引发 `Fault_IllegalInstruction`。在头部内，它记录零参与并打开零模式范围组；随后跳过放置、重复、模式、分配与描述符检查，并推进 `TPC`。不会追加记录。

<!-- PTO-READER-BLOCK: block-b-ios-constraints role=constraints -->
## 合法性与故障边界

- `SizeCode` 为 13 至 15，或固定位非零时，引发 `Fault_IllegalInstruction`。
- 参与的 `B.IOS` 位于活动头部之外时，引发 `Fault_BundleControl`。
- 掩码与块中较早的 Tile 或 Shared 绑定不同时，引发 `Fault_TileLegality`。
- Shared Tile ID 重复，或出现第五条 Shared 绑定时，引发 `Fault_BundleControl`。
- 没有 `B.ASSEMBLE` 的多 PE 目标在描述符、载荷、内存或发布效果之前引发 `Fault_TileLegality`。

架构不为冲突的 PE 对同一 Shared 载荷偏移的访问规定顺序。软件应避免此类冲突，或自行添加同步。

<!-- PTO-READER-BLOCK: block-b-ios-example role=example -->
## 非规范示例

以下为非规范示例，仅用于说明当前所有者，不替代其定义。

```asm
B.IOS S2, mask=1000
B.IOS mask=1000, ->S5<4KB>
```

两条记录都使用 `PEMode = 001`，因此只有 PE0 参与，掩码一致。第一条以 `SizeCode = 0` 把 `S2` 绑定为源，编码为 `0x00201213`。第二条以 `SizeCode = 6` 把 `S5` 设为 4 KiB 目标，编码为 `0x00531213`。该目标只有一个写入者，因此不需要 `B.ASSEMBLE`。第三条记录 `B.IOS S2, mask=1000` 会引发 `Fault_BundleControl`，因为 `S2` 已被绑定。
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
- A successful singleton destination publishes the complete Shared parent; a multi-PE destination uses B.ASSEMBLE with explicit non-overlapping ranges and atomic LAST publication.

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

<!-- GENERATED FROM: asl/block/operands/B.IOT.asl -->
# B.IOT

**Normative ASL source:** `asl/block/operands/B.IOT.asl`

Bind ordered relative Local Tile sources and renamed destinations; each T/U/M/N #1 source names the newest published generation of that hand.

## Normative identity {#PTO-INST-BLOCK-B-IOT}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-b-iot-purpose role=purpose -->
## B.IOT 的作用

`B.IOT` 是一条 32 位块头部命令，把 Local Tile 绑定到当前块的操作。一条 `B.IOT` 可指定最多两个源 Tile、一个可选的新目标、一种 PE 参与模式，以及结束绑定序列的 `L` 标志。Local Tile 是每个 PE 私有的 Tile 寄存器。

`B.IOT` 本身不执行任何操作。它向块的 Tile 绑定追加一条记录，所选操作在块提交时读取完整集合。参见 [Tile 绑定](../model/operands/tile-bindings.md)。

<!-- PTO-READER-BLOCK: block-b-iot-mechanism role=mechanism -->
## 放置与机制

参与的 `B.IOT` 必须出现在活动块的头部，位于块启动之后、第一条主体指令之前。记录按编码顺序保存。`L = 1` 的记录关闭序列，之后参与的 `B.IOT` 会引发 `Fault_BundleControl`。

处理程序先检查 SizeCode 编码，然后检查零参与，然后检查放置，然后检查 PE 掩码，最后追加记录。TGPR2T 块还要求在任何参与的 `B.IOT` 之前已有它的两条 `B.IOR` 记录。每个编码源都保存为相对选择器；下一条非修饰符头部命令会关闭随后 `B.SUBVIEW` 或 `B.ASSEMBLE` 可修饰的范围组。

设计要点：源在之后解析，而不是由 `B.IOT` 解析。`ResolveBundleRelativeTileSources` 在阶段 2 准备期间、分配任何目标之前，把每个选择器映射到物理 Tile。因此即使同一块中较早的绑定在同一手中有目标，所有源命名的仍是操作之前相对队列中的 Tile。

<!-- PTO-READER-BLOCK: block-b-iot-inputs role=inputs-outputs -->
## 字段与编码值

- `SrcTile0`（位 25:20）与 `SrcTile1`（位 31:26）是 6 位相对选择器。位 5:4 选择手 T、U、M 或 N，位 3:0 选择距离。距离 0 是该手最新发布的 Tile，写作 `T#1`；距离 1 写作 `T#2`。因此编码零指 `T#1`，而不是缺失的源。
- `L`（位 19）在本记录之后结束绑定序列。它不结束任何源的生命周期。
- `SizeCode`（位 18:15）在仅源形式中为 0。目标形式使用 1 至 10，表示每个参与 PE 128 B、256 B、512 B、1 KiB、2 KiB、4 KiB、8 KiB、16 KiB、32 KiB 或 64 KiB。
- `PEMode`（位 11:9）展开为四 PE 掩码：`000` 无，`001` PE0，`010` PE1，`011` PE2，`100` PE3，`101` PE0 与 PE1，`110` PE0 至 PE2，`111` 全部四个。
- `DstTile`（位 8:7）选择目标手：0 为 T，1 为 U，2 为 M，3 为 N。

设计要点：目标只指定手，从不指定寄存器。分配器选择物理 Tile，发布使其成为该手的 `#1`。容量按每个被选中的 PE 分别计入，因此 Core 范围的总量是每 PE 大小乘以参与 PE 的数量。

<!-- PTO-READER-BLOCK: block-b-iot-effects role=effects -->
## 挂起状态与发布

被接受的 `B.IOT` 只改变挂起的绑定记录。它不读取 Tile，也不分配任何内容。

块的操作成功后，块在没有 `B.ASSEMBLE` 修饰符的情况下分配的每个目标，都发布为其手的新 `#1`。该手中较旧的存活 Tile 各向更旧的方向移动一个距离（朝向 `#16`），并保留其描述符与载荷。源 Tile 保持已分配，因为 `B.IOT` 从不释放源。

设计要点：只要 SizeCode 编码有效，`PEMode = 000` 就是严格无操作。在头部内，它记录零参与并打开零模式范围组；随后跳过放置、流、模式、分配与描述符检查，并推进 `TPC`。不会追加记录。

<!-- PTO-READER-BLOCK: block-b-iot-constraints role=constraints -->
## 合法性与故障边界

- 仅源形式的 `SizeCode` 非零，或目标形式的 `SizeCode` 为 0 或 11 至 15 时，引发 `Fault_IllegalInstruction`。
- 参与的 `B.IOT` 位于活动头部之外，或出现在序列关闭之后，引发 `Fault_BundleControl`。
- 掩码与同一块中较早 Tile 绑定不同时引发 `Fault_TileLegality`。Tile 绑定表容纳 16 条记录；向已满的表追加也引发 `Fault_TileLegality`。
- 相对源未指向存活的已分配 Tile 时，在阶段 2 准备期间、源读取、分配或操作效果之前引发 `Fault_TileLegality`。

操作模式决定它接受多少条记录以及各记录承担的角色。不匹配时，在提交时、任何目标效果之前引发该操作的合法性故障。

<!-- PTO-READER-BLOCK: block-b-iot-example role=example -->
## 非规范示例

以下为非规范示例，仅用于说明当前所有者，不替代其定义。

```asm
B.IOT T#1, T#2, mask=1111, <last>, ->T<2KB>
```

这条记录把最新的 T Tile 绑定为左源，把次新的 T Tile 绑定为右源，四个 PE 全部参与，并在手 T 中为每个 PE 分配 2 KiB 目标。其字段为 `SrcTile0 = 0`、`SrcTile1 = 1`、`L = 1`、`SizeCode = 5`、`PEMode = 111`、`DstTile = 0`，编码为 `0x040ace13`。Core 范围的分配量为 4 x 2 KiB = 8 KiB。操作成功后，目标成为 `T#1`，原 `T#1` 成为 `T#2`，原 `T#2` 成为 `T#3`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
B.IOT SrcTile0, mask=PE_MASK, <last>, ->DstTile<SizeCode>
B.IOT SrcTile0, SrcTile1, mask=PE_MASK, <last>
B.IOT SrcTile0, SrcTile1, mask=PE_MASK, <last>, ->DstTile<SizeCode>
B.IOT SrcTile0, mask=PE_MASK, <last>
B.IOT mask=PE_MASK, <last>, ->DstTile<SizeCode>
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| b_iot_32_10db6db84f5d | L32 | 32 | 0x00005013 / 0xfc00707f | [{"field":"SizeCode","operator":"one-of","values":[1,2,3,4,5,6,7,8,9,10]},{"field":"PEMode","operator":"one-of","values":[0,1,2,3,4,5,6,7]},{"field":"DstTile","operator":"one-of","values":[0,1,2,3]}] |
| b_iot_32_2c07e7177fad | L32 | 32 | 0x00004013 / 0x0007f1ff | [{"field":"PEMode","operator":"one-of","values":[0,1,2,3,4,5,6,7]}] |
| b_iot_32_8b8bce6bffe8 | L32 | 32 | 0x00004013 / 0x0000707f | [{"field":"SizeCode","operator":"one-of","values":[1,2,3,4,5,6,7,8,9,10]},{"field":"PEMode","operator":"one-of","values":[0,1,2,3,4,5,6,7]},{"field":"DstTile","operator":"one-of","values":[0,1,2,3]}] |
| b_iot_32_c11eb189dd83 | L32 | 32 | 0x00005013 / 0xfc07f1ff | [{"field":"PEMode","operator":"one-of","values":[0,1,2,3,4,5,6,7]}] |
| b_iot_32_efa0fe3fe49a | L32 | 32 | 0x00006013 / 0xfff0707f | [{"field":"SizeCode","operator":"one-of","values":[1,2,3,4,5,6,7,8,9,10]},{"field":"PEMode","operator":"one-of","values":[0,1,2,3,4,5,6,7]},{"field":"DstTile","operator":"one-of","values":[0,1,2,3]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| b_iot_32_10db6db84f5d | SrcTile0 | 6 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":6}] |
| b_iot_32_10db6db84f5d | L | 1 | encoding-defined | [{"instruction_lsb":19,"value_lsb":0,"width":1}] |
| b_iot_32_10db6db84f5d | SizeCode | 4 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":4}] |
| b_iot_32_10db6db84f5d | PEMode | 3 | encoding-defined | [{"instruction_lsb":9,"value_lsb":0,"width":3}] |
| b_iot_32_10db6db84f5d | DstTile | 2 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":2}] |
| b_iot_32_2c07e7177fad | SrcTile1 | 6 | encoding-defined | [{"instruction_lsb":26,"value_lsb":0,"width":6}] |
| b_iot_32_2c07e7177fad | SrcTile0 | 6 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":6}] |
| b_iot_32_2c07e7177fad | L | 1 | encoding-defined | [{"instruction_lsb":19,"value_lsb":0,"width":1}] |
| b_iot_32_2c07e7177fad | PEMode | 3 | encoding-defined | [{"instruction_lsb":9,"value_lsb":0,"width":3}] |
| b_iot_32_8b8bce6bffe8 | SrcTile1 | 6 | encoding-defined | [{"instruction_lsb":26,"value_lsb":0,"width":6}] |
| b_iot_32_8b8bce6bffe8 | SrcTile0 | 6 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":6}] |
| b_iot_32_8b8bce6bffe8 | L | 1 | encoding-defined | [{"instruction_lsb":19,"value_lsb":0,"width":1}] |
| b_iot_32_8b8bce6bffe8 | SizeCode | 4 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":4}] |
| b_iot_32_8b8bce6bffe8 | PEMode | 3 | encoding-defined | [{"instruction_lsb":9,"value_lsb":0,"width":3}] |
| b_iot_32_8b8bce6bffe8 | DstTile | 2 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":2}] |
| b_iot_32_c11eb189dd83 | SrcTile0 | 6 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":6}] |
| b_iot_32_c11eb189dd83 | L | 1 | encoding-defined | [{"instruction_lsb":19,"value_lsb":0,"width":1}] |
| b_iot_32_c11eb189dd83 | PEMode | 3 | encoding-defined | [{"instruction_lsb":9,"value_lsb":0,"width":3}] |
| b_iot_32_efa0fe3fe49a | L | 1 | encoding-defined | [{"instruction_lsb":19,"value_lsb":0,"width":1}] |
| b_iot_32_efa0fe3fe49a | SizeCode | 4 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":4}] |
| b_iot_32_efa0fe3fe49a | PEMode | 3 | encoding-defined | [{"instruction_lsb":9,"value_lsb":0,"width":3}] |
| b_iot_32_efa0fe3fe49a | DstTile | 2 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":2}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| b_iot_32_10db6db84f5d | SrcTile0 | 6 | 0–63 | none | none | first relative Local source, newest-first within its encoded hand | Code zero names T#1, the newest published T-hand generation. |
| b_iot_32_10db6db84f5d | L | 1 | 0–1 | none | none | effective-binding sequence terminator; not a source-lifetime marker | Encoded zero leaves the B.IOT sequence open; encoded one closes the sequence after this effective binding and does not end any source lifetime. |
| b_iot_32_10db6db84f5d | SizeCode | 4 | 1–10 | none | 0, 11–15 | source-only zero or destination capacity code 1..10: 128 B..64 KiB per participating PE | Encoded zero selects the source-only form and never allocates; it is reserved in destination forms. |
| b_iot_32_10db6db84f5d | PEMode | 3 | 0–7 | none | none | three-bit encoded participation mode expanded by the common decoder to a four-PE semantic mask | Encoded zero decodes to mask 0000 and makes B.IOT a strict no-op. |
| b_iot_32_10db6db84f5d | DstTile | 2 | 0–3 | none | none | destination hand selector whose publication pushes a new #1 generation | Code zero selects the T destination hand; successful publication pushes the new generation to T#1. |
| b_iot_32_2c07e7177fad | SrcTile1 | 6 | 0–63 | none | none | second relative Local source, newest-first within its encoded hand | Code zero names T#1, the newest published T-hand generation. |
| b_iot_32_2c07e7177fad | SrcTile0 | 6 | 0–63 | none | none | first relative Local source, newest-first within its encoded hand | Code zero names T#1, the newest published T-hand generation. |
| b_iot_32_2c07e7177fad | L | 1 | 0–1 | none | none | effective-binding sequence terminator; not a source-lifetime marker | Encoded zero leaves the B.IOT sequence open; encoded one closes the sequence after this effective binding and does not end any source lifetime. |
| b_iot_32_2c07e7177fad | PEMode | 3 | 0–7 | none | none | three-bit encoded participation mode expanded by the common decoder to a four-PE semantic mask | Encoded zero decodes to mask 0000 and makes B.IOT a strict no-op. |
| b_iot_32_8b8bce6bffe8 | SrcTile1 | 6 | 0–63 | none | none | second relative Local source, newest-first within its encoded hand | Code zero names T#1, the newest published T-hand generation. |
| b_iot_32_8b8bce6bffe8 | SrcTile0 | 6 | 0–63 | none | none | first relative Local source, newest-first within its encoded hand | Code zero names T#1, the newest published T-hand generation. |
| b_iot_32_8b8bce6bffe8 | L | 1 | 0–1 | none | none | effective-binding sequence terminator; not a source-lifetime marker | Encoded zero leaves the B.IOT sequence open; encoded one closes the sequence after this effective binding and does not end any source lifetime. |
| b_iot_32_8b8bce6bffe8 | SizeCode | 4 | 1–10 | none | 0, 11–15 | source-only zero or destination capacity code 1..10: 128 B..64 KiB per participating PE | Encoded zero selects the source-only form and never allocates; it is reserved in destination forms. |
| b_iot_32_8b8bce6bffe8 | PEMode | 3 | 0–7 | none | none | three-bit encoded participation mode expanded by the common decoder to a four-PE semantic mask | Encoded zero decodes to mask 0000 and makes B.IOT a strict no-op. |
| b_iot_32_8b8bce6bffe8 | DstTile | 2 | 0–3 | none | none | destination hand selector whose publication pushes a new #1 generation | Code zero selects the T destination hand; successful publication pushes the new generation to T#1. |
| b_iot_32_c11eb189dd83 | SrcTile0 | 6 | 0–63 | none | none | first relative Local source, newest-first within its encoded hand | Code zero names T#1, the newest published T-hand generation. |
| b_iot_32_c11eb189dd83 | L | 1 | 0–1 | none | none | effective-binding sequence terminator; not a source-lifetime marker | Encoded zero leaves the B.IOT sequence open; encoded one closes the sequence after this effective binding and does not end any source lifetime. |
| b_iot_32_c11eb189dd83 | PEMode | 3 | 0–7 | none | none | three-bit encoded participation mode expanded by the common decoder to a four-PE semantic mask | Encoded zero decodes to mask 0000 and makes B.IOT a strict no-op. |
| b_iot_32_efa0fe3fe49a | L | 1 | 0–1 | none | none | effective-binding sequence terminator; not a source-lifetime marker | Encoded zero leaves the B.IOT sequence open; encoded one closes the sequence after this effective binding and does not end any source lifetime. |
| b_iot_32_efa0fe3fe49a | SizeCode | 4 | 1–10 | none | 0, 11–15 | source-only zero or destination capacity code 1..10: 128 B..64 KiB per participating PE | Encoded zero selects the source-only form and never allocates; it is reserved in destination forms. |
| b_iot_32_efa0fe3fe49a | PEMode | 3 | 0–7 | none | none | three-bit encoded participation mode expanded by the common decoder to a four-PE semantic mask | Encoded zero decodes to mask 0000 and makes B.IOT a strict no-op. |
| b_iot_32_efa0fe3fe49a | DstTile | 2 | 0–3 | none | none | destination hand selector whose publication pushes a new #1 generation | Code zero selects the T destination hand; successful publication pushes the new generation to T#1. |

- `b_iot_32_10db6db84f5d.SizeCode` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.
- `b_iot_32_8b8bce6bffe8.SizeCode` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.
- `b_iot_32_efa0fe3fe49a.SizeCode` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcTile0 | first relative Local source, newest-first within its encoded hand |
| SrcTile1 | second relative Local source, newest-first within its encoded hand |
| L | effective-binding sequence terminator; not a source-lifetime marker |
| SizeCode | source-only zero or destination capacity code 1..10: 128 B..64 KiB per participating PE |
| PEMode | three-bit encoded participation mode expanded by the common decoder to a four-PE semantic mask |
| DstTile | destination hand selector whose publication pushes a new #1 generation |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/operands/B.IOT.asl -->
```asl
readonly func InstructionContractMatches_B_IOT(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_b_iot_32_10db6db84f5d) ||
           (operation == CommandOperation_b_iot_32_2c07e7177fad) ||
           (operation == CommandOperation_b_iot_32_8b8bce6bffe8) ||
           (operation == CommandOperation_b_iot_32_c11eb189dd83) ||
           (operation == CommandOperation_b_iot_32_efa0fe3fe49a);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
Header command after BSTART and before the first body instruction. One or more effective B.IOT instructions form an ordered sequence whose final effective instruction has L=1.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/operands/B.IOT.asl -->
```asl
// Complete-bundle matrix consumers use the compact Local stream documented by
// PTO-BLOCK-MODEL-DISPATCH-TILE-SCHEMA and
// spec/evidence/bundle-command-totality.json: existing mathematical sources,
// optional RowMaxIn, vector QuantParam, vector PReLUParam, then D followed by
// optional RowMaxOut and GroupMaxOut.  The carrier is bounded at eight source
// and three destination ordinals; static operation catalogs remain unchanged.
pure func InstructionContractCompleteBundleLocalSourceCapacity_B_IOT() => integer
begin
    return 8;
end;

pure func InstructionContractCompleteBundleLocalDestinationCapacity_B_IOT() => integer
begin
    return 3;
end;

pure func InstructionContractZeroMaskIsNoOp_B_IOT(
    pe_mask: bits(4)) => boolean
begin
    return pe_mask == Zeros{4};
end;

pure func InstructionContractHasMaskOnlySharedCompanion_B_IOT() => boolean
begin
    return FALSE;
end;

pure func InstructionContractPerPECapacity_B_IOT(
    size_code: integer {1..10}) => integer
begin
    return TileSizeCodeBytes(size_code);
end;

pure func InstructionContractCoreCapacity_B_IOT(
    size_code: integer {1..10}, pe_mask: bits(4)) => integer
begin
    return TileCoreAllocationBytes(pe_mask,
        InstructionContractPerPECapacity_B_IOT(size_code));
end;

readonly func InstructionContractHandler_B_IOT() => CommandSemanticHandler
begin
    return CommandHandler_BindBundleTileIO;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- PEMode is a three-bit encoding expanded by the common profile decoder to the fixed four-PE semantic mask: 000 none, 001 PE0, 010 PE1, 011 PE2, 100 PE3, 101 PE0+PE1, 110 PE0+PE1+PE2, and 111 all four PEs.
- SizeCode=0 is the source-only encoding and never allocates; destination forms require SizeCode=1..10 for 128 B, 256 B, 512 B, 1 KiB, 2 KiB, 4 KiB, 8 KiB, 16 KiB, 32 KiB, and 64 KiB per participating PE.
- PEMode=000 decodes to no participating PE and is a strict no-op before placement, duplicate, schema, allocation, descriptor, memory, and downstream fault checks.
- T#1, U#1, M#1, and N#1 name the newest published generation in their hand; increasing indices select progressively older live generations. Direct model TileIndex values are resolved physical identities and are not encoded relative selectors.

## Legality

- The three-bit PEMode field accepts all eight encodings and the common profile decoder expands them exactly to the fixed four-PE semantic mask table.
- Source-only forms require SizeCode=0 and fix instruction bits 7..8 to zero; a non-zero value in those bits is reserved. Destination forms require SizeCode=1..10; codes 11..15 are reserved for Local B.IOT.
- PEMode=000 is accepted as the strict no-effect source-bearing encoding; a nonzero decoded mask is a four-PE predicate shared by every effective binding in the block.
- A participating B.IOT is legal only after BSTART and before the block body. At most four effective Local bindings are accepted in encoded order.
- The selected operation schema determines ordered Local source and destination roles and must agree with the form fields and SizeCode role.
- Every encoded Local source is resolved against the published pre-operation relative map. An unavailable relative generation raises Fault_TileLegality before source reads, allocation, or operation effects.

## State effects

- The common PE-mode decoder expands PEMode once to the semantic four-PE mask used by every effective Local binding.
- A zero decoded mask is a strict no-op. A successful source binding is read-only; a successful destination atomically updates selected payload quarters and a compatible persistent descriptor.
- The selected operation defines publication and ordering. Its first write fixes the allocation mask; later writes may update only a subset with a compatible descriptor and cannot expand the mask.
- Successful destination publication pushes a new generation at #1 of the selected T/U/M/N hand and shifts older live generations toward #16 without modifying their descriptor or payload.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Resolve all relative sources against the published pre-operation hand order before allocating or publishing any destination. Successful destinations publish in B.IOT order; each later same-hand destination becomes the newer #1 generation.
- B.IOT bindings are consumed in encoded order. L=1 closes the sequence after the current effective binding; a later effective B.IOT raises Illegal Block Exception before effects.

## Exceptions

- Reserved instruction bits and malformed field combinations raise Fault_IllegalInstruction before architectural effects.
- A participating B.IOT outside an active header, a duplicate binding, a fifth effective binding, a role mismatch, or an unsupported SizeCode raises the applicable fault before changing the stream.
- A mismatched effective decoded PE mask, incompatible destination descriptor, mask expansion, or operation-schema mismatch raises Fault_TileLegality before tile state changes.
- PEMode=000 is a strict no-op and cannot raise a downstream schema, duplicate, allocation, descriptor, or memory fault.

## Examples

- B.IOT SrcTile0, mask=PE_MASK, <last>, ->DstTile<SizeCode>

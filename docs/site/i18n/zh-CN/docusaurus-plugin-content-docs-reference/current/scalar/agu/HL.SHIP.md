<!-- GENERATED FROM: asl/scalar/agu/HL.SHIP.asl -->
# HL.SHIP

**Normative ASL source:** `asl/scalar/agu/HL.SHIP.asl`

HL.SHIP snapshots its scalar sources, forms its encoded address, and stores two adjacent aligned little-endian 2-byte values.

## Normative identity {#PTO-INST-SCALAR-HL-SHIP}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-ship-purpose role=purpose -->
## `HL.SHIP` 存储什么

`HL.SHIP` 是一条独立的 `48` 位标量 AGU 指令，在距 `SrcR` 基址按 `2` 缩放的 `simm17` 位移处存储两个相邻的小端 `2` 字节单元。

规范汇编是 `hl.ship SrcD, SrcD1, [SrcR, simm]`。

设计要点：标度与单元大小一致，因此编码位移是 `2` 字节元素数组的下标，这一对写入两个相邻下标处的元素。

<!-- PTO-READER-BLOCK: scalar-hl-ship-mechanism role=mechanism -->
## 地址如何形成

位移是符号扩展后的 `simm17` 值乘以 `2`，再按 `2^PTO_XLEN` 取模加到 `SrcR` 快照上；第二个地址是该和加上 `2`。

标度为 `1`，因此位移以 `2` 字节单元计数，每个可达位移都是偶数；因此对齐的基址会让两个单元都保持对齐。

更新模式为 none，因此两次存储都使用计算出的地址，且没有寄存器接收结果：此形式没有 `RegDst` 字段。

两次预检都在任何存储之前完成，`SrcD` 与 `SrcD1` 只在两次预检都成功后读取；成功时先写低地址。

设计要点：`-65536..65535` 乘以 `2` 覆盖从 `-131072` 到 `131070` 的所有偶数字节位移，因此位移本身绝不会引入未对齐；奇数基址仍会让两个单元都未对齐。

<!-- PTO-READER-BLOCK: scalar-hl-ship-inputs role=inputs-outputs -->
## 操作数

- `SrcD`、`SrcD1` 与 `SrcR` 是 `5` 位 Reg5 源选择子：编码 `0`..`23` 选择绝对 GPR，`24`..`27` 选择 `T#1`..`T#4`，`28`..`31` 选择 `U#1`..`U#4`；队列条目被读取时不会被消耗，编码 `0` 读取架构零 GPR。

- `simm17` 是 `17` 位有符号字段，分配从 `-65536` 到 `65535` 的全部值；编码字节位移是该值乘以 `2`，编码零表示零位移而不是省略。

- 此形式没有 `RegDst` 字段，因此没有寄存器接收结果，也不会发布更新后的基址。

设计要点：`SrcD` 与 `SrcD1` 是普通 Reg5 源，因此 `T` 或 `U` 队列条目可以直接被保存，读取不会消耗它。

<!-- PTO-READER-BLOCK: scalar-hl-ship-effects role=effects -->
## 影响与顺序

所有源都在第一次存储之前读取，因此所用到的每个值都是指令执行前的值；`SrcD` 与 `SrcD1` 只在两次预检都成功之后读取。

执行成功时按地址递增顺序记录两个 relaxed 存储事件，只改变两个单元的 `4` 字节。

当两次存储中任一次与有效保留的 `64` 字节粒度块重叠时，该保留在两次预检都成功之后才被作废；保留所在的粒度块未被这两次存储触及的，仍然有效。

存储完成之后 `TPC` 前进 `6` 字节。被拒绝或发生故障的尝试不会退休。

设计要点：按地址递增顺序记录两个 relaxed 存储事件，因此低地址单元的事件先于高地址单元的事件。

<!-- PTO-READER-BLOCK: scalar-hl-ship-constraints role=constraints -->
## 对齐、故障与重启

- 两个有效地址都必须是 `2` 的倍数。先预检第一个地址：未对齐的第一个地址在地址转换之前引发 `Fault_DataAlignment`，权限或有界内存失败则在原始地址引发 `Fault_DataPage`。第二个地址重复这两项测试。

- 固定位不匹配，或源选择子指向不可用的 `T` 或 `U` 条目，会在任何指令影响之前于 `PC` 处引发 `Fault_IllegalInstruction`。

- 发生故障时不记录存储事件：内存与所有寄存器保持指令执行前的值，`TPC` 不前进，恢复时重新计算两个地址、两次预检与两次存储。

设计要点：两次预检都在写出第一个字节之前完成，因此针对第二个地址引发的 `Fault_DataPage` 会让第一个 `2` 字节单元也未被写入。

<!-- PTO-READER-BLOCK: scalar-hl-ship-example role=example -->
## 示例

该示例只演示地址计算；精确行为仍由当前 ASL 与指令契约定义。

- `hl.ship 20, 21, [2, 3]`，其中 GPR2 = `0x4000`，GPR20 = `0xbeef` 与 GPR21 = `0x1234`。

- 位移 `3` 乘以 `2` 得到 `6`，因此两个地址是 `0x4006` 与 `0x4008`。

- 第一次存储把 `0xef`、`0xbe` 写到 `0x4006` 到 `0x4007`，第二次把 `0x34`、`0x12` 写到 `0x4008` 到 `0x4009`，两者都按地址递增顺序进行。

- `SrcD`、`SrcD1` 与 `SrcR` 都保持指令执行前的值，`TPC` 前进 `6` 字节。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.ship SrcD, SrcD1, [SrcR, simm]
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_ship_48_156afe74f95b | HL48 | 48 | 0x00001059001e / 0x0000707f003f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_ship_48_156afe74f95b | SrcD | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_ship_48_156afe74f95b | SrcD1 | 5 | encoding-defined | [{"instruction_lsb":6,"value_lsb":0,"width":5}] |
| hl_ship_48_156afe74f95b | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |
| hl_ship_48_156afe74f95b | simm17 | 17 | signed | [{"instruction_lsb":41,"value_lsb":0,"width":7},{"instruction_lsb":23,"value_lsb":7,"width":5},{"instruction_lsb":11,"value_lsb":12,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_ship_48_156afe74f95b | SrcD | 5 | 0–31 | none | none | Reg5 first store-data source | Encoded zero reads the architectural zero GPR. |
| hl_ship_48_156afe74f95b | SrcD1 | 5 | 0–31 | none | none | Reg5 second store-data source | Encoded zero reads the architectural zero GPR. |
| hl_ship_48_156afe74f95b | SrcR | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| hl_ship_48_156afe74f95b | simm17 | 17 | 0–131071 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcD | Reg5 first store-data source |
| SrcD1 | Reg5 second store-data source |
| SrcR | Reg5 address-base source |
| simm17 | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.SHIP.asl -->
```asl
readonly func InstructionContractOperation_HL_SHIP() => ScalarOperation
begin
    return ScalarOperation_HL_SHIP;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.SHIP.asl -->
```asl
readonly func InstructionContractHandler_HL_SHIP()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStorePair;
end;

pure func InstructionContractAGUAction_HL_SHIP()
    => ScalarAGUAction
begin
    return ScalarAGU_StorePair;
end;

pure func InstructionContractAGUAddressKind_HL_SHIP()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Immediate;
end;

pure func InstructionContractAGUSizeBytes_HL_SHIP()
    => integer {1,2,4,8}
begin
    return 2;
end;

pure func InstructionContractAGUOffsetScale_HL_SHIP()
    => integer {0..3}
begin
    return 1;
end;

pure func InstructionContractAGUUpdateMode_HL_SHIP()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_HL_SHIP()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_SHIP()
    => boolean
begin
    return FALSE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Every displayed operand field is encoded explicitly; encoded zero is a value and never denotes omission.

## Legality

- Every encoded Reg5 source uses the complete domain: codes 0..23 select absolute GPRs, codes 24..27 select T#1..T#4, and codes 28..31 select U#1..U#4 without consumption.
- simm17 assigns every signed 17-bit value -65536..65535; the encoded byte displacement is that value multiplied by 2.
- Each memory address must be aligned to the 2-byte access size; a 2-byte access is the complete transfer unit.

## State effects

- Sign-extend simm17, multiply it by 2, and add it modulo 2^PTO_XLEN to the SrcR base.
- The pair addresses are address and address plus 2; the instruction performs no base writeback.
- Snapshot every store-data source before any memory effect or destination publication.
- Successful execution advances TPC by 6 bytes; a rejected or faulting attempt does not retire.

## Memory effects and ordering

### Memory effects

- Preflight both adjacent 2-byte addresses before either store; on success record two relaxed store events in address order.
- Successful overlapping stores invalidate an overlapping reservation only after complete pair preflight.

### Ordering

- Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.
- Preflight both addresses, commit the two relaxed 2-byte operations in address order, publish ordered results if any, then advance TPC.

## Exceptions

- A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.
- A misaligned 2-byte address raises Fault_DataAlignment before translation or permission. A later permission or bounded-memory failure raises Fault_DataPage at the original address.
- A fault emits no successful memory event, performs no partial memory or destination effect, preserves pending writeback, and leaves TPC at the faulting instruction.
- Recovery performs a full reissue: every address, source snapshot, preflight, memory operation, and destination is recomputed with no retained progress.

## Examples

- hl.ship SrcD, SrcD1, [SrcR, simm]

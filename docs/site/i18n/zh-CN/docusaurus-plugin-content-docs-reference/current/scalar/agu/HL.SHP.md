<!-- GENERATED FROM: asl/scalar/agu/HL.SHP.asl -->
# HL.SHP

**Normative ASL source:** `asl/scalar/agu/HL.SHP.asl`

HL.SHP snapshots its scalar sources, forms its encoded address, and stores two adjacent aligned little-endian 2-byte values.

## Normative identity {#PTO-INST-SCALAR-HL-SHP}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-shp-purpose role=purpose -->
## `HL.SHP` 存储什么

`HL.SHP` 是一条独立的 `48` 位标量 AGU 指令，在距 `SrcL` 基址按 `2` 缩放的寄存器位移处存储两个相邻的小端 `2` 字节单元。

规范汇编是 `hl.shp SrcD, SrcD1, [SrcL, SrcR<{.sw,.uw}><<1]`。

设计要点：标度与单元大小一致，因此索引寄存器可以遍历 `2` 字节元素数组，每步 `1` 恰好让这一对移动一个元素。

<!-- PTO-READER-BLOCK: scalar-hl-shp-mechanism role=mechanism -->
## 地址如何形成

位移是经 `SrcRType` 选择后的 `SrcR` 快照，左移 `1` 位，再按 `2^PTO_XLEN` 取模加到 `SrcL` 快照上；第二个地址是该和加上 `2`。

标度为 `1`，因此位移是经变换的 `SrcR` 值左移一位，位移的最低位始终为零。

更新模式为 none，因此两次存储都使用计算出的地址，且没有寄存器接收结果：此形式没有 `RegDst` 字段。

两次预检都在任何存储之前完成，`SrcD` 与 `SrcD1` 只在两次预检都成功后读取；成功时先写低地址。

设计要点：由于位移始终为偶数，只要基址对齐，这一对的两个单元就一起满足 `2` 字节对齐，修好基址即可同时修好两者。

<!-- PTO-READER-BLOCK: scalar-hl-shp-inputs role=inputs-outputs -->
## 操作数

- `SrcD`、`SrcD1`、`SrcL` 与 `SrcR` 是 `5` 位 Reg5 源选择子：编码 `0`..`23` 选择绝对 GPR，`24`..`27` 选择 `T#1`..`T#4`，`28`..`31` 选择 `U#1`..`U#4`；队列条目被读取时不会被消耗，编码 `0` 读取架构零 GPR。

- `SrcRType` 是 `2` 位，在移位之前作用于 `SrcR`：`00` 保持整个寄存器值，`01` 与 `10` 分别用其低 `32` 位的有符号与无符号读法替换它，`11` 为保留值。

- 此形式没有 `RegDst` 字段，因此没有寄存器接收结果，也不会发布更新后的基址。

设计要点：`SrcRType` 在完整的 `64` 位索引与其低 `32` 位的有符号或无符号读法之间选择，移位在该选择之后进行。

<!-- PTO-READER-BLOCK: scalar-hl-shp-effects role=effects -->
## 影响与顺序

所有源都在第一次存储之前读取，因此所用到的每个值都是指令执行前的值；`SrcD` 与 `SrcD1` 只在两次预检都成功之后读取。

执行成功时按地址递增顺序记录两个 relaxed 存储事件，只改变两个单元的 `4` 字节。

当两次存储中任一次与有效保留的 `64` 字节粒度块重叠时，该保留在两次预检都成功之后才被作废；保留所在的粒度块未被这两次存储触及的，仍然有效。

存储完成之后 `TPC` 前进 `6` 字节。被拒绝或发生故障的尝试不会退休。

设计要点：两个单元分别接收各自源的低 `2` 字节，因此这一对可以用一条指令保存两个不同的半字。

<!-- PTO-READER-BLOCK: scalar-hl-shp-constraints role=constraints -->
## 对齐、故障与重启

- 两个有效地址都必须是 `2` 的倍数。先预检第一个地址：未对齐的第一个地址在地址转换之前引发 `Fault_DataAlignment`，权限或有界内存失败则在原始地址引发 `Fault_DataPage`。第二个地址重复这两项测试。

- 固定位不匹配，或源选择子指向不可用的 `T` 或 `U` 条目，会在任何指令影响之前于 `PC` 处引发 `Fault_IllegalInstruction`。

- `SrcRType` 的原始值 `11` 为保留值：它会在读取任何源之前于 `PC` 处引发 `Fault_IllegalInstruction`，因此地址修饰符解码只定义 `00`、`01` 与 `10`。

- 发生故障时不记录存储事件：内存与所有寄存器保持指令执行前的值，`TPC` 不前进，恢复时重新计算两个地址、两次预检与两次存储。

设计要点：任一次预检失败都会在任何存储之前中止这一对，因此这一对覆盖的 `4` 字节是全有或全无的。

<!-- PTO-READER-BLOCK: scalar-hl-shp-example role=example -->
## 示例

该示例只演示地址计算；精确行为仍由当前 ASL 与指令契约定义。

- `hl.shp 20, 21, [2, 7<<1]`，其中 `SrcRType` 为 `01`，GPR2 = `0x3000`，GPR7 = `0x8`，GPR20 = `0xbeef` 与 GPR21 = `0x1234`。

- 索引 `0x8` 左移 `1` 位得到位移 `16`，因此两个地址是 `0x3010` 与 `0x3012`。

- 第一次存储把 `0xef`、`0xbe` 写到 `0x3010` 到 `0x3011`，第二次把 `0x34`、`0x12` 写到 `0x3012` 到 `0x3013`，两者都按地址递增顺序进行。

- `SrcD`、`SrcD1` 与 `SrcL` 都保持指令执行前的值，`TPC` 前进 `6` 字节。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.shp SrcD, SrcD1, [SrcL, SrcR<{.sw,.uw}><<1]
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_shp_48_ccc507e71a27 | HL48 | 48 | 0x00001049001e / 0x00007ffff83f | [{"field":"SrcRType","operator":"one-of","values":[0,1,2]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_shp_48_ccc507e71a27 | SrcD | 5 | encoding-defined | [{"instruction_lsb":43,"value_lsb":0,"width":5}] |
| hl_shp_48_ccc507e71a27 | SrcD1 | 5 | encoding-defined | [{"instruction_lsb":6,"value_lsb":0,"width":5}] |
| hl_shp_48_ccc507e71a27 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_shp_48_ccc507e71a27 | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |
| hl_shp_48_ccc507e71a27 | SrcRType | 2 | encoding-defined | [{"instruction_lsb":41,"value_lsb":0,"width":2}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_shp_48_ccc507e71a27 | SrcD | 5 | 0–31 | none | none | Reg5 first store-data source | Encoded zero reads the architectural zero GPR. |
| hl_shp_48_ccc507e71a27 | SrcD1 | 5 | 0–31 | none | none | Reg5 second store-data source | Encoded zero reads the architectural zero GPR. |
| hl_shp_48_ccc507e71a27 | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| hl_shp_48_ccc507e71a27 | SrcR | 5 | 0–31 | none | none | Reg5 register-offset source | Encoded zero reads the architectural zero GPR. |
| hl_shp_48_ccc507e71a27 | SrcRType | 2 | 0–2 | none | 3 | register-offset transformation selector | Encoded zero leaves the complete PTO_XLEN register-offset value unchanged. |

- `hl_shp_48_ccc507e71a27.SrcRType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcD | Reg5 first store-data source |
| SrcD1 | Reg5 second store-data source |
| SrcL | Reg5 address-base source |
| SrcR | Reg5 register-offset source |
| SrcRType | register-offset transformation selector |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.SHP.asl -->
```asl
readonly func InstructionContractOperation_HL_SHP() => ScalarOperation
begin
    return ScalarOperation_HL_SHP;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.SHP.asl -->
```asl
readonly func InstructionContractHandler_HL_SHP()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStorePair;
end;

pure func InstructionContractAGUAction_HL_SHP()
    => ScalarAGUAction
begin
    return ScalarAGU_StorePair;
end;

pure func InstructionContractAGUAddressKind_HL_SHP()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Register;
end;

pure func InstructionContractAGUSizeBytes_HL_SHP()
    => integer {1,2,4,8}
begin
    return 2;
end;

pure func InstructionContractAGUOffsetScale_HL_SHP()
    => integer {0..3}
begin
    return 1;
end;

pure func InstructionContractAGUUpdateMode_HL_SHP()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_HL_SHP()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_SHP()
    => boolean
begin
    return FALSE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Every displayed operand field is encoded explicitly; encoded zero is a value and never denotes omission.
- SrcRType=0 leaves SrcR unchanged, SrcRType=1 sign-extends SrcR[31:0], SrcRType=2 zero-extends SrcR[31:0], and SrcRType=3 is reserved. Encoded shamt zero performs no shift.

## Legality

- Every encoded Reg5 source uses the complete domain: codes 0..23 select absolute GPRs, codes 24..27 select T#1..T#4, and codes 28..31 select U#1..U#4 without consumption.
- SrcRType values 0, 1, and 2 and all shamt values 0..31 are assigned; SrcRType=3 is reserved; apply the modifier before the shift.
- Each memory address must be aligned to the 2-byte access size; a 2-byte access is the complete transfer unit.

## State effects

- Form offset = LSL(Modify(SrcR, SrcRType), 1) and add it modulo 2^PTO_XLEN to the SrcL base.
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

- hl.shp SrcD, SrcD1, [SrcL, SrcR<{.sw,.uw}><<1]

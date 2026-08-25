<!-- GENERATED FROM: asl/scalar/agu/HL.SHIP.U.asl -->
# HL.SHIP.U

**Normative ASL source:** `asl/scalar/agu/HL.SHIP.U.asl`

HL.SHIP.U snapshots its scalar sources, forms its encoded address, and stores two adjacent aligned little-endian 2-byte values.

## Normative identity {#PTO-INST-SCALAR-HL-SHIP-U}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-ship-u-purpose role=purpose -->
## HL.SHIP.U 的作用

`HL.SHIP.U` 是一条独立的 `48` 位 AGU 指令；它形成有符号立即数地址，并存储两个相邻且对齐的小端 `2` 字节值。

<!-- PTO-READER-BLOCK: scalar-hl-ship-u-mechanism role=mechanism -->
## 地址与内存机制

`HL.SHIP.U` 将完整 `-65536..65535` 取值域中的 `simm17` 符号扩展，随后不再缩放，并将位移按 `2^PTO_XLEN` 取模后加到快照中的 `SrcR` 基址。

该指令先预检两个相邻的 `2` 字节地址，再按地址递增顺序存储两个已快照的数据值。

此形式不回写基址寄存器；有效地址只供所选内存操作使用。

<!-- PTO-READER-BLOCK: scalar-hl-ship-u-inputs role=inputs-outputs -->
## 输入与输出

- `SrcR` 提供基址；`simm17` 提供有符号位移。其中的 Reg5 源 `SrcD`、`SrcD1`、`SrcR` 使用完整编码域：`0..23` 选择 GPR，`24..27` 选择 `T#1..T#4`，`28..31` 选择 `U#1..U#4`，且读取不会消费队列项。
- `SrcD` 提供第一个存储值；`SrcD1` 提供第二个存储值。
- `simm17` 分配从 `-65536` 到 `65535` 的全部有符号值；编码零表示零位移，而不是省略该操作数。

<!-- PTO-READER-BLOCK: scalar-hl-ship-u-effects role=effects -->
## 效果与顺序

所有显式和隐式标量源都在内存或目的端效果之前完成快照，因此别名观察到的是指令执行前的值。

两个地址全部通过预检后，成功执行按地址顺序记录两个 relaxed 存储事件，只在完整预检后更新重叠保留状态，并将 `TPC` 前移 `6` 字节。

<!-- PTO-READER-BLOCK: scalar-hl-ship-u-constraints role=constraints -->
## 对齐、故障与重启

每个有效地址都必须满足 `2` 字节对齐。未对齐会在地址转换前引发 `Fault_DataAlignment`；之后的权限或有界内存失败会在原始地址引发 `Fault_DataPage`。

发生故障时不会记录成功的内存事件，也不会产生部分内存、目的端或回写效果；待处理回写保持不变，故障 `TPC` 保留以供完整重发。

固定比特不匹配、字段取保留值或所选 `T`/`U` 源不可用，都会在指令效果之前引发 `Fault_IllegalInstruction`。

<!-- PTO-READER-BLOCK: scalar-hl-ship-u-example role=example -->
## 非规范地址示例

该示例只演示地址计算；精确行为仍由当前 ASL 与指令契约定义。

若基址为 `0x100`、有符号立即数为 `2`，位移就是 `2`，基址加位移为 `0x102`。内存访问使用 `0x102`。两个地址全部通过预检后，第二个 `2` 字节存储使用 `0x104`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.ship.u SrcD, SrcD1, [SrcR, simm]
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_ship_u_48_fa5e1d981a8a | HL48 | 48 | 0x00005059001e / 0x0000707f003f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_ship_u_48_fa5e1d981a8a | SrcD | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_ship_u_48_fa5e1d981a8a | SrcD1 | 5 | encoding-defined | [{"instruction_lsb":6,"value_lsb":0,"width":5}] |
| hl_ship_u_48_fa5e1d981a8a | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |
| hl_ship_u_48_fa5e1d981a8a | simm17 | 17 | signed | [{"instruction_lsb":41,"value_lsb":0,"width":7},{"instruction_lsb":23,"value_lsb":7,"width":5},{"instruction_lsb":11,"value_lsb":12,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_ship_u_48_fa5e1d981a8a | SrcD | 5 | 0–31 | none | none | Reg5 first store-data source | Encoded zero reads the architectural zero GPR. |
| hl_ship_u_48_fa5e1d981a8a | SrcD1 | 5 | 0–31 | none | none | Reg5 second store-data source | Encoded zero reads the architectural zero GPR. |
| hl_ship_u_48_fa5e1d981a8a | SrcR | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| hl_ship_u_48_fa5e1d981a8a | simm17 | 17 | 0–131071 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcD | Reg5 first store-data source |
| SrcD1 | Reg5 second store-data source |
| SrcR | Reg5 address-base source |
| simm17 | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.SHIP.U.asl -->
```asl
readonly func InstructionContractOperation_HL_SHIP_U() => ScalarOperation
begin
    return ScalarOperation_HL_SHIP_U;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.SHIP.U.asl -->
```asl
readonly func InstructionContractHandler_HL_SHIP_U()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStorePair;
end;

pure func InstructionContractAGUAction_HL_SHIP_U()
    => ScalarAGUAction
begin
    return ScalarAGU_StorePair;
end;

pure func InstructionContractAGUAddressKind_HL_SHIP_U()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Immediate;
end;

pure func InstructionContractAGUSizeBytes_HL_SHIP_U()
    => integer {1,2,4,8}
begin
    return 2;
end;

pure func InstructionContractAGUOffsetScale_HL_SHIP_U()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_HL_SHIP_U()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_HL_SHIP_U()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_SHIP_U()
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
- simm17 assigns every signed 17-bit value -65536..65535; the encoded byte displacement is that value multiplied by 1.
- Each memory address must be aligned to the 2-byte access size; a 2-byte access is the complete transfer unit.

## State effects

- Sign-extend simm17, multiply it by 1, and add it modulo 2^PTO_XLEN to the SrcR base.
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

- hl.ship.u SrcD, SrcD1, [SrcR, simm]

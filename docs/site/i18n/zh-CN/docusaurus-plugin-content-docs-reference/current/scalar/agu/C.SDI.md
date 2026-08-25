<!-- GENERATED FROM: asl/scalar/agu/C.SDI.asl -->
# C.SDI

**Normative ASL source:** `asl/scalar/agu/C.SDI.asl`

C.SDI snapshots its scalar sources, forms its encoded address, and stores one aligned little-endian 8-byte value.

## Normative identity {#PTO-INST-SCALAR-C-SDI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-c-sdi-purpose role=purpose -->
## C.SDI 的作用

`C.SDI` 是一条独立的 `16` 位标量 AGU 指令，使用 `Compressed` 寻址，按小端序存储一个 `8` 字节值。压缩形式把隐式 `T#1` 快照为存储数据，并保留该队列项。

<!-- PTO-READER-BLOCK: scalar-c-sdi-mechanism role=mechanism -->
## 地址与传输机制

地址路径先对 `simm5` 做符号扩展并乘以 `8`，再把位移与快照中的 `SrcL` 相加，结果按 `2^PTO_XLEN` 取模。

完整预检通过后，在所选地址提交一次对齐的小端序 `8` 字节存储。

该形式不发布地址基址回写。

<!-- PTO-READER-BLOCK: scalar-c-sdi-inputs role=inputs-outputs -->
## 编码输入与输出

- `SrcL` 是一个 `5` 位字段，用来选择地址基址。
- `simm5` 是一个 `5` 位字段，用来选择乘以 `8` 缩放因子之前的有符号位移。
- `T#1` 是隐式且不消费队列项的存储数据源。

<!-- PTO-READER-BLOCK: scalar-c-sdi-effects role=effects -->
## 影响与完成顺序

所有显式和隐式标量源都会在任何内存或目的位置影响之前完成快照，因此别名读取指令执行前的值。

执行成功时记录一个 relaxed 存储事件；只有完整预检通过后，重叠的保留状态才会失效。

所有结果或回写发布完成后，`C.SDI` 把 `TPC` 前进 `2` 字节；被拒绝或发生故障的尝试不会退休。

<!-- PTO-READER-BLOCK: scalar-c-sdi-constraints role=constraints -->
## 合法性、故障与重启

每个访问地址都按 `8` 字节传输单元对齐。未对齐会在翻译前选择 `Fault_DataAlignment`；之后的权限或有界内存失败会在原始地址选择 `Fault_DataPage`。

固定位不匹配、字段取保留值或选中的 T/U 源不可用，会在指令影响之前选择 `Fault_IllegalInstruction`。

发生故障时不记录成功内存事件，也不提交部分内存、结果或回写影响。重新执行会从头重新计算源快照、地址、预检、传输和发布。

<!-- PTO-READER-BLOCK: scalar-c-sdi-example role=example -->
## 非规范阅读步骤

下面只说明如何使用本页，不增加指令行为。

- 从规范汇编形式 `c.sdi t#1, [srcL, simm]` 开始，找出已编码的地址字段。
- 然后把上面的寻址模式、传输动作、完成影响和故障边界，与下方确切的生成 ASL 契约逐项对照。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
c.sdi t#1, [srcL, simm]
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| c_sdi_16_bbec69bcfd5d | C16 | 16 | 0x003a / 0x003f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| c_sdi_16_bbec69bcfd5d | SrcL | 5 | encoding-defined | [{"instruction_lsb":6,"value_lsb":0,"width":5}] |
| c_sdi_16_bbec69bcfd5d | simm5 | 5 | signed | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| c_sdi_16_bbec69bcfd5d | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| c_sdi_16_bbec69bcfd5d | simm5 | 5 | 0–31 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 address-base source |
| simm5 | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/C.SDI.asl -->
```asl
readonly func InstructionContractOperation_C_SDI() => ScalarOperation
begin
    return ScalarOperation_C_SDI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/C.SDI.asl -->
```asl
readonly func InstructionContractHandler_C_SDI()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStore;
end;

pure func InstructionContractAGUAction_C_SDI()
    => ScalarAGUAction
begin
    return ScalarAGU_Store;
end;

pure func InstructionContractAGUAddressKind_C_SDI()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Compressed;
end;

pure func InstructionContractAGUSizeBytes_C_SDI()
    => integer {1,2,4,8}
begin
    return 8;
end;

pure func InstructionContractAGUOffsetScale_C_SDI()
    => integer {0..3}
begin
    return 3;
end;

pure func InstructionContractAGUUpdateMode_C_SDI()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_C_SDI()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_C_SDI()
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
- The implicit store-data source is T#1 and must be available before execution; reading it does not consume it.
- simm5 assigns every signed 5-bit value -16..15; the encoded byte displacement is that value multiplied by 8.
- Each memory address must be aligned to the 8-byte access size; a 8-byte access is the complete transfer unit.

## State effects

- Sign-extend simm5, multiply it by 8, and add it modulo 2^PTO_XLEN to the SrcL base.
- Snapshot implicit T#1 before memory effects and preserve the queue entry after the store.
- Successful execution advances TPC by 2 bytes; a rejected or faulting attempt does not retire.

## Memory effects and ordering

### Memory effects

- After complete preflight, perform one little-endian 8-byte store and record one relaxed store event.
- A successful overlapping store invalidates the overlapping reservation; a nonoverlapping reservation remains valid.

### Ordering

- Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.
- Complete the relaxed 8-byte memory operation, publish any result or writeback, and then advance TPC.

## Exceptions

- A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.
- A misaligned 8-byte address raises Fault_DataAlignment before translation or permission. A later permission or bounded-memory failure raises Fault_DataPage at the original address.
- A fault emits no successful memory event, performs no partial memory or destination effect, preserves pending writeback, and leaves TPC at the faulting instruction.
- Recovery performs a full reissue: every address, source snapshot, preflight, memory operation, and destination is recomputed with no retained progress.

## Examples

- c.sdi t#1, [srcL, simm]

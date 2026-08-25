<!-- GENERATED FROM: asl/scalar/agu/HL.LD.PCR.asl -->
# HL.LD.PCR

**Normative ASL source:** `asl/scalar/agu/HL.LD.PCR.asl`

HL.LD.PCR snapshots its scalar sources, forms its encoded address, and loads one aligned little-endian 8-byte value.

## Normative identity {#PTO-INST-SCALAR-HL-LD-PCR}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-ld-pcr-purpose role=purpose -->
## HL.LD.PCR 的作用

`HL.LD.PCR` 是一条独立的 `48` 位标量 AGU 指令，使用 `PCRelative` 寻址，按小端序加载一个 `8` 字节值；当结果窄于 `PTO_XLEN` 时，对传输位进行零扩展。

<!-- PTO-READER-BLOCK: scalar-hl-ld-pcr-mechanism role=mechanism -->
## 地址与传输机制

PC 相对地址路径先清除当前 `TPC` 的 `1:0` 位，再加上经过符号扩展并乘以 `4` 的 `simm` 位移，结果按 `2^PTO_XLEN` 取模。

完整预检通过后，执行一次对齐的小端序 `8` 字节加载。结果在发布到目的位置前会保留完整 64 位模式。

该形式不发布地址基址回写。

<!-- PTO-READER-BLOCK: scalar-hl-ld-pcr-inputs role=inputs-outputs -->
## 编码输入与输出

- `RegDst` 是一个 `5` 位字段，用来选择加载值结果。
- `simm` 是一个 `29` 位字段，用来选择乘以 `4` 缩放因子之前的有符号位移。

<!-- PTO-READER-BLOCK: scalar-hl-ld-pcr-effects role=effects -->
## 影响与完成顺序

所有显式和隐式标量源都会在任何内存或目的位置影响之前完成快照，因此别名读取指令执行前的值。

执行成功时记录一个 relaxed 加载事件；内存和保留状态保持不变。

所有结果或回写发布完成后，`HL.LD.PCR` 把 `TPC` 前进 `6` 字节；被拒绝或发生故障的尝试不会退休。

<!-- PTO-READER-BLOCK: scalar-hl-ld-pcr-constraints role=constraints -->
## 合法性、故障与重启

每个访问地址都按 `8` 字节传输单元对齐。未对齐会在翻译前选择 `Fault_DataAlignment`；之后的权限或有界内存失败会在原始地址选择 `Fault_DataPage`。

固定位不匹配、字段取保留值或选中的 T/U 源不可用，会在指令影响之前选择 `Fault_IllegalInstruction`。

发生故障时不记录成功内存事件，也不提交部分内存、结果或回写影响。重新执行会从头重新计算源快照、地址、预检、传输和发布。

<!-- PTO-READER-BLOCK: scalar-hl-ld-pcr-example role=example -->
## 非规范阅读步骤

下面只说明如何使用本页，不增加指令行为。

- 从规范汇编形式 `hl.ld.pcr [<symbol>], ->{t, u, Rd}` 开始，找出已编码的地址字段。
- 然后把上面的寻址模式、传输动作、完成影响和故障边界，与下方确切的生成 ASL 契约逐项对照。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.ld.pcr [<symbol>], ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_ld_pcr_48_703673c266da | HL48 | 48 | 0x00003039000e / 0x0000707f000f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_ld_pcr_48_703673c266da | RegDst | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_ld_pcr_48_703673c266da | simm | 29 | signed | [{"instruction_lsb":31,"value_lsb":0,"width":17},{"instruction_lsb":4,"value_lsb":17,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_ld_pcr_48_703673c266da | RegDst | 5 | 0–31 | none | none | Reg5 loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_ld_pcr_48_703673c266da | simm | 29 | 0–536870911 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 loaded-value destination or discard |
| simm | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.LD.PCR.asl -->
```asl
readonly func InstructionContractOperation_HL_LD_PCR() => ScalarOperation
begin
    return ScalarOperation_HL_LD_PCR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.LD.PCR.asl -->
```asl
readonly func InstructionContractHandler_HL_LD_PCR()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;

pure func InstructionContractAGUAction_HL_LD_PCR()
    => ScalarAGUAction
begin
    return ScalarAGU_Load;
end;

pure func InstructionContractAGUAddressKind_HL_LD_PCR()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_PCRelative;
end;

pure func InstructionContractAGUSizeBytes_HL_LD_PCR()
    => integer {1,2,4,8}
begin
    return 8;
end;

pure func InstructionContractAGUOffsetScale_HL_LD_PCR()
    => integer {0..3}
begin
    return 2;
end;

pure func InstructionContractAGUUpdateMode_HL_LD_PCR()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_HL_LD_PCR()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_LD_PCR()
    => boolean
begin
    return FALSE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Every displayed operand field is encoded explicitly; encoded zero is a value and never denotes omission.

## Legality

- Every Reg5 destination is assigned: codes 1..23 write GPRs, code 30 pushes U, code 31 pushes T, and codes 0 and 24..29 discard only that result.
- simm assigns every signed 29-bit value -268435456..268435455; the encoded byte displacement is that value multiplied by 4.
- Each memory address must be aligned to the 8-byte access size; a 8-byte access is the complete transfer unit.

## State effects

- Clear TPC bits 1:0, sign-extend the encoded displacement, multiply it by four, and add it modulo 2^PTO_XLEN.
- After a successful 8-byte load, preserve the complete 64-bit loaded bit pattern and publish it through the destination.
- Successful execution advances TPC by 6 bytes; a rejected or faulting attempt does not retire.

## Memory effects and ordering

### Memory effects

- After complete preflight, perform one little-endian 8-byte load and record one relaxed load event.
- The load preserves memory and reservation state.

### Ordering

- Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.
- Complete the relaxed 8-byte memory operation, publish any result or writeback, and then advance TPC.

## Exceptions

- A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.
- A misaligned 8-byte address raises Fault_DataAlignment before translation or permission. A later permission or bounded-memory failure raises Fault_DataPage at the original address.
- A fault emits no successful memory event, performs no partial memory or destination effect, preserves pending writeback, and leaves TPC at the faulting instruction.
- Recovery performs a full reissue: every address, source snapshot, preflight, memory operation, and destination is recomputed with no retained progress.

## Examples

- hl.ld.pcr [<symbol>], ->{t, u, Rd}

<!-- GENERATED FROM: asl/scalar/agu/HL.LWU.PCR.asl -->
# HL.LWU.PCR

**Normative ASL source:** `asl/scalar/agu/HL.LWU.PCR.asl`

HL.LWU.PCR snapshots its scalar sources, forms its encoded address, and loads one aligned little-endian 4-byte value.

## Normative identity {#PTO-INST-SCALAR-HL-LWU-PCR}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-lwu-pcr-purpose role=purpose -->
## HL.LWU.PCR 的作用

`HL.LWU.PCR` 是一条独立的 `48` 位标量 AGU 加载指令，其地址相对于指令流。它用对齐的当前指令指针加上经过缩放的符号位移构成地址，加载一个对齐的小端序 `4` 字节值；当结果窄于该宽度时，把传输位零扩展到 `PTO_XLEN`。

没有任何寄存器提供基址。因此当同一段代码在不同地址运行时，同一编码会访问不同的内存，也不存在地址基址回写。

设计要点：指令指针不是操作数，因此该形式不消耗程序可见的寄存器，只发布一个结果。地址仍然随代码移动，这正是它无需在编码中加入基址寄存器即可用于位置无关代码的原因。

<!-- PTO-READER-BLOCK: scalar-hl-lwu-pcr-mechanism role=mechanism -->
## HL.LWU.PCR 如何构成地址并完成传输

基址是当前 `TPC` 清零位 `[1:0]` 后的值，因此它总是 `4` 的整数倍。编码字段 `simm` 符号扩展到 `PTO_XLEN`，再左移 2 位，即放大 4 倍，乘积与该基址按 `2^PTO_XLEN` 取模相加。可达的字节位移从 `-1073741824` 到 `1073741820`。

预检之后，执行一次对齐的小端序 `4` 字节加载，并记录一个宽松加载事件。可执行路径用 `NormalizeScalarLoadResult` 规范化结果：该函数把 `4` 字节结果零扩展，因为 `ScalarAGUSignedLoadOfForm` 对本形式返回 `FALSE`，其高位为 `0`。

不会向任何地址基址回写，因为该形式没有基址操作数。

设计要点：对位移做符号扩展，使一个编码既能访问指令之前的字节也能访问其后的字节；清零两个指针位并对位移做移位，使该和始终是 `4` 的整数倍，而 `4` 字节正是传输单元。

<!-- PTO-READER-BLOCK: scalar-hl-lwu-pcr-inputs role=inputs-outputs -->
## 编码字段及其选择的对象

- `RegDst` 是一个 `5` 位选择子，用来选择加载值。

- `simm` 是一个 `29` 位有符号符号位移；编码的字节位移是该值乘以 `4`。

编码 `1`..`23` 写入绝对 GPR，`30` 压入 `U`，`31` 压入 `T`，`0` 只丢弃该结果，编码 `24`..`29` 不写入任何位置。

没有编码的基址选择子，也没有寄存器偏移，因此该形式不读取任何通用寄存器，也不可能有不可用的被选中 `T` 或 `U` 源。

设计要点：目的选择子为 `0` 时是丢弃结果，而不是取消整条指令，因此加载、其内存事件和`TPC` 前进都仍然发生。

<!-- PTO-READER-BLOCK: scalar-hl-lwu-pcr-effects role=effects -->
## 效果、快照与完成顺序

对齐基址与位移都在内存操作之前算出，因此向 `RegDst` 发布不会改变已经读取的字节。

- 成功执行会记录一个宽松加载事件，保持内存内容和保留状态不变，也不回写任何基址。

- 在结果发布之后，`HL.LWU.PCR` 把 `TPC` 前进 `6` 字节；被拒绝或发生故障的尝试不会退役。

<!-- PTO-READER-BLOCK: scalar-hl-lwu-pcr-constraints role=constraints -->
## 合法性、故障与重启

权限或受限内存范围失败会在原始地址产生 `Fault_DataPage`。这里的 `Fault_IllegalInstruction` 只用于固定位不匹配；由于该形式的每个编码字段都有分配，保留字段值不可能出现。

该形式的 `Fault_DataAlignment` 不可达：基址的低两位已清零，缩放后的位移是 `4` 的整数倍，因此和总是 `4` 的整数倍，而 `4` 字节正是传输单元。

设计要点：在相加之前清零指针位，使得无论指令从哪个半字开始，地址都保持对齐。若没有这一步，代码相对的加载可能因对齐而报故障，而不是完成加载。

故障不会发出成功的内存事件，也不产生部分内存或目的位置效果，并把 `TPC` 留在故障指令处；重试会重算对齐基址、位移、预检、传输与发布。

<!-- PTO-READER-BLOCK: scalar-hl-lwu-pcr-example role=example -->
## 非规范阅读示例

本示例说明如何使用本页，不增加指令行为。

- 从规范汇编 `hl.lwu.pcr [<symbol>], ->{t, u, Rd}` 入手，识别符号位移和目的选择子。

- 在另一代码地址复用同一编码之前，记住基址是对齐后的当前 `TPC`，而不是寄存器。

- 然后把上面的地址、效果和故障说明与下面的 ASL 契约对照检查，包括对齐并不在所列故障之中这一点。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.lwu.pcr [<symbol>], ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_lwu_pcr_48_95ba33b7b68c | HL48 | 48 | 0x00006039000e / 0x0000707f000f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_lwu_pcr_48_95ba33b7b68c | RegDst | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_lwu_pcr_48_95ba33b7b68c | simm | 29 | signed | [{"instruction_lsb":31,"value_lsb":0,"width":17},{"instruction_lsb":4,"value_lsb":17,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_lwu_pcr_48_95ba33b7b68c | RegDst | 5 | 0–31 | none | none | Reg5 loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_lwu_pcr_48_95ba33b7b68c | simm | 29 | 0–536870911 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 loaded-value destination or discard |
| simm | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.LWU.PCR.asl -->
```asl
readonly func InstructionContractOperation_HL_LWU_PCR() => ScalarOperation
begin
    return ScalarOperation_HL_LWU_PCR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.LWU.PCR.asl -->
```asl
readonly func InstructionContractHandler_HL_LWU_PCR()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;

pure func InstructionContractAGUAction_HL_LWU_PCR()
    => ScalarAGUAction
begin
    return ScalarAGU_Load;
end;

pure func InstructionContractAGUAddressKind_HL_LWU_PCR()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_PCRelative;
end;

pure func InstructionContractAGUSizeBytes_HL_LWU_PCR()
    => integer {1,2,4,8}
begin
    return 4;
end;

pure func InstructionContractAGUOffsetScale_HL_LWU_PCR()
    => integer {0..3}
begin
    return 2;
end;

pure func InstructionContractAGUUpdateMode_HL_LWU_PCR()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_HL_LWU_PCR()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_LWU_PCR()
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
- Each memory address must be aligned to the 4-byte access size; a 4-byte access is the complete transfer unit.

## State effects

- Clear TPC bits 1:0, sign-extend the encoded displacement, multiply it by four, and add it modulo 2^PTO_XLEN.
- After a successful 4-byte load, zero-extend the loaded value to PTO_XLEN and publish it through the destination.
- Successful execution advances TPC by 6 bytes; a rejected or faulting attempt does not retire.

## Memory effects and ordering

### Memory effects

- After complete preflight, perform one little-endian 4-byte load and record one relaxed load event.
- The load preserves memory and reservation state.

### Ordering

- Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.
- Complete the relaxed 4-byte memory operation, publish any result or writeback, and then advance TPC.

## Exceptions

- A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.
- A misaligned 4-byte address raises Fault_DataAlignment before translation or permission. A later permission or bounded-memory failure raises Fault_DataPage at the original address.
- A fault emits no successful memory event, performs no partial memory or destination effect, preserves pending writeback, and leaves TPC at the faulting instruction.
- Recovery performs a full reissue: every address, source snapshot, preflight, memory operation, and destination is recomputed with no retained progress.

## Examples

- hl.lwu.pcr [<symbol>], ->{t, u, Rd}

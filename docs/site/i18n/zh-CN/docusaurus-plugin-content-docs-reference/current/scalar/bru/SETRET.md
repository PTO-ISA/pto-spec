<!-- GENERATED FROM: asl/scalar/bru/SETRET.asl -->
# SETRET

**Normative ASL source:** `asl/scalar/bru/SETRET.asl`

SETRET - Write the architectural return address.

## Normative identity {#PTO-INST-SCALAR-SETRET}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-setret-purpose role=purpose -->
## SETRET 的作用

`SETRET` 用当前 `TPC` 和一个编码位移计算返回目标，并把它记录到架构返回状态和 Bundle 局部返回状态中。

它只记录地址而不转移控制：该指令不会跳转到它所计算的目标，顺序路径继续在后续指令处执行。之后的控制转移必须读取 `R10` 或保留的 Bundle 返回状态才能使用所记录的地址。

<!-- PTO-READER-BLOCK: scalar-setret-mechanism role=mechanism -->
## 目标如何计算

立即数先零扩展到完整字宽，再左移 `1` 位把半字偏移缩放为字节偏移，然后与执行时读取的 `TPC` 相加。计算得到的同一个字写入 GPR `R10`（架构返回地址寄存器）以及 Bundle 局部返回地址。

设计要点：移位量是固定 `1` 而不是字段，因此计算出的目标始终为偶数。返回点因此在构造上总是半字对齐，程序使用前无需再做掩码。

设计要点：基址是本条指令的 `TPC`，因此位移相对于 `SETRET` 自身而不是相对于下一条指令。

<!-- PTO-READER-BLOCK: scalar-setret-inputs-outputs role=inputs-outputs -->
## 输入与输出

- `imm20` 提供编码位移，按无符号处理并按 `2` 缩放；编码零提供数值零。
- 当前 `TPC` 提供基地址。
- 计算得到的目标写入 GPR `R10` 以及保留的 Bundle 返回状态。

<!-- PTO-READER-BLOCK: scalar-setret-effects role=effects -->
## 效果与顺序

目标作为一次更新发布到 `R10` 和 Bundle 局部返回地址，随后该指令沿普通顺序路径退出，`TPC` 前进 `4` 字节。

内存、保留状态、描述符、数值状态和谓词状态都不改变，该指令也没有需要检查就绪状态的源操作数。之后对 `R10` 的写入是普通 GPR 写，不会再耦合回 Bundle 局部返回地址。

<!-- PTO-READER-BLOCK: scalar-setret-constraints role=constraints -->
## 该指令可能引发的故障

该指令只携带一个不受约束的 `20` 位字段，因此该字段的每个编码都被分配，没有保留字段值。固定位不匹配会在任何效果之前引发 `Fault_IllegalInstruction`。

`SETRET` 没有需要校验的编码寄存器操作数，也没有内存访问，`SetReturnAddress` 本身不引发任何故障。除每条标量形式都要经过的适用性检查外，固定位不匹配是本编码唯一可能新增的故障。

<!-- PTO-READER-BLOCK: scalar-setret-example role=example -->
## 非规范示例

This example illustrates the current owner and does not create a second semantic definition.

在 `TPC=1000` 处执行编码字段为 `imm20=64` 的形式。位移缩放为 `128`，因此 `R10` 和 Bundle 局部返回地址都收到 `1128`，而执行继续，下一条指令的 `TPC=1004`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
setret uimm, ->Ra
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| setret_32_72003dcf3b59 | L32 | 32 | 0x00000507 / 0x00000fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| setret_32_72003dcf3b59 | imm20 | 20 | encoding-defined | [{"instruction_lsb":12,"value_lsb":0,"width":20}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| setret_32_72003dcf3b59 | imm20 | 20 | 0–1048575 | none | none | 20-bit immediate value | Encoded zero supplies numeric zero for the 20-bit immediate value. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| imm20 | 20-bit immediate value |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/bru/SETRET.asl -->
```asl
readonly func InstructionContractOperation_SETRET() => ScalarOperation
begin
    return ScalarOperation_SETRET;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/bru/SETRET.asl -->
```asl
readonly func InstructionContractHandler_SETRET() => ScalarSemanticHandler
begin
    return ScalarHandler_SetReturnAddress;
end;

pure func InstructionContractUsesTPC_SETRET()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractTarget_SETRET(
    base: Word,
    halfword_offset: Word)
    => Word
begin
    return base + LSL(halfword_offset, 1);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- The selected assembly form determines which fields are present; every present field carries its encoded value and no encoded zero means omission.

## Legality

- Every value in each unconstrained encoded field is assigned; constrained complements are reserved and reject before effects.

## State effects

- SETRET - Write the architectural return address.
- After decode and legality checks, execute the normative SetReturnAddress ASL handler; no other architectural state is modified.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- none

## Exceptions

- Reserved field encodings raise Fault_IllegalInstruction before effects; handler-specific arithmetic, memory, control-flow, system-register, and privilege faults follow the embedded normative ASL operation.

## Examples

- setret uimm, ->Ra

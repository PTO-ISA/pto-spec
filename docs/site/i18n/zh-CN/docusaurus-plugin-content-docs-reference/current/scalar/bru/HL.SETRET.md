<!-- GENERATED FROM: asl/scalar/bru/HL.SETRET.asl -->
# HL.SETRET

**Normative ASL source:** `asl/scalar/bru/HL.SETRET.asl`

HL.SETRET - Write the architectural return address.

## Normative identity {#PTO-INST-SCALAR-HL-SETRET}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-setret-purpose role=purpose -->
## HL.SETRET 的作用

`HL.SETRET` 相对当前 `TPC` 计算并记录架构返回地址。

<!-- PTO-READER-BLOCK: scalar-hl-setret-mechanism role=mechanism -->
## 执行机制

无符号 `32` 位立即数先零扩展并左移 `1` 位，再与快照的当前 `TPC` 相加。

同一目标同时写入 GPR `R10` 和指令束局部返回地址状态；指令不会跳转到该目标。

<!-- PTO-READER-BLOCK: scalar-hl-setret-inputs-outputs role=inputs-outputs -->
## 输入与输出

- `imm32` 提供编码立即数或位移。

<!-- PTO-READER-BLOCK: scalar-hl-setret-effects role=effects -->
## 效果与顺序

返回目标先完成发布，随后成功路径按普通规则让 `TPC` 前进 `6` 字节。

内存、保留状态、数值状态和谓词状态均不改变。

<!-- PTO-READER-BLOCK: scalar-hl-setret-constraints role=constraints -->
## 合法性与故障顺序

编码、保留字段值和源可用性都会在目的、控制或 `TPC` 效果前检查。

<!-- PTO-READER-BLOCK: scalar-hl-setret-example role=example -->
## 非规范示例

下面的示例只帮助理解当前所有者，不构成第二份语义定义。

`hl.setret imm, ->Ra` 记录返回目标，但不会把控制流转移到该目标。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.setret imm, ->Ra
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_setret_48_302bb793a800 | HL48 | 48 | 0x00000507000e / 0x00000fff000f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_setret_48_302bb793a800 | imm32 | 32 | encoding-defined | [{"instruction_lsb":28,"value_lsb":0,"width":20},{"instruction_lsb":4,"value_lsb":20,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_setret_48_302bb793a800 | imm32 | 32 | 0–4294967295 | none | none | 32-bit immediate value | Encoded zero supplies numeric zero for the 32-bit immediate value. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| imm32 | 32-bit immediate value |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/bru/HL.SETRET.asl -->
```asl
readonly func InstructionContractOperation_HL_SETRET() => ScalarOperation
begin
    return ScalarOperation_HL_SETRET;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/bru/HL.SETRET.asl -->
```asl
readonly func InstructionContractHandler_HL_SETRET() => ScalarSemanticHandler
begin
    return ScalarHandler_SetReturnAddress;
end;

pure func InstructionContractUsesTPC_HL_SETRET()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractTarget_HL_SETRET(
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

- HL.SETRET - Write the architectural return address.
- After decode and legality checks, execute the normative SetReturnAddress ASL handler; no other architectural state is modified.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- none

## Exceptions

- Reserved field encodings raise Fault_IllegalInstruction before effects; handler-specific arithmetic, memory, control-flow, system-register, and privilege faults follow the embedded normative ASL operation.

## Examples

- hl.setret imm, ->Ra

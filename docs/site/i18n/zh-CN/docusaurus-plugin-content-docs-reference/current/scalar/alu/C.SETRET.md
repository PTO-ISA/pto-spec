<!-- GENERATED FROM: asl/scalar/alu/C.SETRET.asl -->
# C.SETRET

**Normative ASL source:** `asl/scalar/alu/C.SETRET.asl`

Materialize an unsigned halfword-scaled TPC-relative return address in ra and captured return state.

## Normative identity {#PTO-INST-SCALAR-C-SETRET}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-c-setret-purpose role=purpose -->
## C.SETRET 的作用

`C.SETRET` 是一条 16 位标量 ALU 指令。它形成以半字为缩放单位的 TPC 相对返回地址，并把它记录到返回寄存器和已捕获的返回状态中；当前指令契约定义结果发布路径以及任何额外状态效果。

<!-- PTO-READER-BLOCK: scalar-c-setret-mechanism role=mechanism -->
## 结果形成方式

执行时先对编码输入做快照，然后形成以半字为缩放单位的 TPC 相对返回地址，并把它记录到返回寄存器和已捕获的返回状态中，最后才产生目标效果。

- 立即数宽度与扩展规则由下方编码字段确定；除非生成契约给出其他零值含义，编码零提供数值零。
- 结果发布使用当前指令契约为该助记符确定的位宽与扩展规则。

<!-- PTO-READER-BLOCK: scalar-c-setret-inputs role=inputs-outputs -->
## 输入与目标

- `uimm5` 是 5 位无符号字段，携带相对前进前 `TPC` 的无符号五位半字位移。

这些角色来自当前指令契约；T/U 源只被读取和快照，不会因源选择而出队。编码零的精确含义列在下方生成的默认值章节中。

<!-- PTO-READER-BLOCK: scalar-c-setret-effects role=effects -->
## 效果与顺序

返回地址在返回寄存器和已捕获返回状态更新前计算完成。

该 ALU 操作不产生内存效果。成功完成架构效果后，`TPC` 前进 2 字节。

该操作不会产生隐藏的标量发布目标或隐式内存访问。架构变化仅限于当前契约列出的状态效果。

<!-- PTO-READER-BLOCK: scalar-c-setret-constraints role=constraints -->
## 合法性与故障边界

所有编码立即数都已分配；该指令不解引用目标，也不单独形成调用。

下方生成的合法性表是已分配字段值、保留编码和目标丢弃编码的权威说明。解码与源可用性检查先于架构效果完成。

<!-- PTO-READER-BLOCK: scalar-c-setret-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

以一个小型 `C.SETRET` 示例说明：前进前 `TPC=0x100` 且 `uimm5=1` 时，`ra` 与已捕获返回状态都得到返回地址 `0x102`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
c.setret uimm, ->ra
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| c_setret_16_335651ef6c27 | C16 | 16 | 0x5016 / 0xf83f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| c_setret_16_335651ef6c27 | uimm5 | 5 | unsigned | [{"instruction_lsb":6,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| c_setret_16_335651ef6c27 | uimm5 | 5 | 0–31 | none | none | unsigned five-bit halfword displacement from the pre-increment TPC | Encoded zero supplies numeric zero for the 5-bit unsigned immediate. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| uimm5 | unsigned five-bit halfword displacement from the pre-increment TPC |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/C.SETRET.asl -->
```asl
readonly func InstructionContractOperation_C_SETRET() => ScalarOperation
begin
    return ScalarOperation_C_SETRET;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
Standalone scalar return-address materialization. Fused BSTART.CALL and BSTART.ICALL define call formation separately.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/C.SETRET.asl -->
```asl
readonly func InstructionContractHandler_C_SETRET() => ScalarSemanticHandler
begin
    return ScalarHandler_SetReturnAddress;
end;

pure func InstructionContractTarget_C_SETRET(
    tpc: Word,
    uimm5: bits(5))
    => Word
begin
    let halfword_offset = ZeroExtend{PTO_XLEN}(uimm5);
    return tpc + LSL(halfword_offset, 1);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- C.SETRET has no omitted field. Encoded uimm5 zero is the real zero displacement and materializes the address of C.SETRET itself.

## Legality

- Every uimm5 value 0..31 is assigned. The fixed destination is architectural ra (GPR10).
- C.SETRET is legal as a standalone scalar operation and does not by itself form a call.

## State effects

- Compute target = pre-increment TPC + (ZeroExtend(uimm5) << 1) with XLEN wrapping.
- Atomically write the same target to GPR10 ra and the captured return-address state; successful dispatch then advances TPC by two bytes.
- A later ordinary write to ra does not retroactively change the captured return-address state.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot the pre-increment TPC, compute the target, publish ra and captured return state together, then perform the ordinary two-byte sequential TPC advance.

## Exceptions

- All uimm5 values are legal. C.SETRET performs no target dereference and raises no alignment, memory, arithmetic, or block-control exception.

## Examples

- c.setret 0, ->ra
- c.setret 31, ->ra

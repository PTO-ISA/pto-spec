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

`C.SETRET` 由当前 `TPC` 加上按比例缩放的无符号立即数算出一个返回地址，并把它同时记入架构 `ra` 寄存器（GPR `10`）和指令束保存的返回地址状态。

设计要点：目标由 opcode 固定。16 位形式把五位有效载荷用于位移，因此 `ra` 是隐含的；没有可选的目标字段，该指令本身也不构成一次调用。

<!-- PTO-READER-BLOCK: scalar-c-setret-mechanism role=mechanism -->
## 结果形成方式

- `uimm5` 被零扩展后左移 `1` 位，得到 `0` 至 `62` 的偶数字节偏移。
- `TPC` 在顺序前进之前读取，因此目标是 `TPC + (uimm5 * 2)`。

同一个目标被一步写入 `ra` 和保存的返回地址状态，随后执行普通的 `2` 字节 `TPC` 前进。

设计要点：位移按 `2` 缩放，因此记录的目标相对于该指令自身地址总是偶数偏移。奇数目标无法编码，这正是本指令不需要对齐检查的原因。

设计要点：编码 `uimm5` 零是真实的零位移，因此 `c.setret 0, ->ra` 记录的是 `C.SETRET` 自身的地址，而不是下一条指令的地址。

设计要点：`ra` 和保存的返回地址状态一起写入，但它们不是同一份存储。指令束的返回路径读取保存的状态，因此之后对 `ra` 的普通写入只改变寄存器，不改变返回去向。

<!-- PTO-READER-BLOCK: scalar-c-setret-inputs role=inputs-outputs -->
## 输入与目标

- `uimm5` 是唯一编码操作数，即 `0` 至 `31` 的无符号半字位移。
- 目标是固定的：架构 `ra`，也就是 GPR `10`，以及保存的返回地址状态。

设计要点：值的来源是 `TPC` 而不是寄存器，因此 `C.SETRET` 不读取任何操作数存储。这就是它没有源可用性故障、也没有丢弃形式的原因；汇编文本中的 `->ra` 命名的是一个不可更改的目标。

<!-- PTO-READER-BLOCK: scalar-c-setret-effects role=effects -->
## 效果与顺序

先对 `TPC` 取快照，然后一起发布 `ra` 和保存的返回地址状态，最后 `TPC` 前进 `2` 字节。

没有其他状态改变：没有队列移动，没有内存访问，保留状态、描述符、数值状态、指令束、特权、谓词和控制流状态都不受影响。

<!-- PTO-READER-BLOCK: scalar-c-setret-constraints role=constraints -->
## 合法性与故障边界

`0` 至 `31` 的每个 `uimm5` 取值都已分配，因此 `C.SETRET` 没有保留位移。

无法译码的 16 位形式在 `PC` 处引发 `Fault_IllegalInstruction`，不适用于当前指令束的指令在 `TPC` 处引发 `Fault_BundleControl`。除这些检查外，`C.SETRET` 自身没有故障：它不解引用任何东西，因此不可能由它产生对齐、内存或权限故障。

设计要点：该指令既不校验目标，也不校验外层栈帧。它只是记录一个地址，因此所选位移是否正确由调用者负责，而不是架构可以拒绝的事情。

<!-- PTO-READER-BLOCK: scalar-c-setret-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

当 `TPC=4096` 时，`c.setret 2, ->ra` 把 `4096 + 4 = 4100` 记入 `ra` 和保存的返回地址状态，然后把 `TPC` 前进到 `4098`。`uimm5=0` 时记录值为 `4096`；`uimm5=31` 时为 `4158`。
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
Standalone scalar return-address materialization. Each BSTART variant's DIRECT form can fuse with C.SETRET into a distinct per-variant call instruction; the accepted BSTART.FP CALL and BSTART.STD CALL forms define call formation separately.
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

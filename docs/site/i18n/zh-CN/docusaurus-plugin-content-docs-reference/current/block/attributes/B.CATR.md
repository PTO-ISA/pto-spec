<!-- GENERATED FROM: asl/block/attributes/B.CATR.asl -->
# B.CATR

**Normative ASL source:** `asl/block/attributes/B.CATR.asl`

Defines one optional block control record for post-commit trap, transactional visibility, acquire/release ordering, remote execution, and dimension-reduction mode.

## Normative identity {#PTO-INST-BLOCK-B-CATR}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-b-catr-purpose role=purpose -->
## B.CATR 的作用

`B.CATR`（Block 控制属性）是可选的 32 位 header 命令。它记录六个一位 Block 控制标志：`trap`、`atom`、`aq`、`rl`、`far` 和 `DR`。它不执行计算，也不访问内存。Block 的操作及其提交会在之后读取这些已记录的标志。

这些标志保存在一个带 `present` 位的记录中，由 `SetBundleControlAttributeState` 写入。写入器见[属性 schema 模型](../model/schema/attributes.md)。

<!-- PTO-READER-BLOCK: block-b-catr-mechanism role=mechanism -->
## 放置与机制

Block header 是 Block 中位于 `BSTART` 之后、第一条 body 指令之前的部分。`B.CATR` 属于这里。当没有活动 Block、Block body 已经开始，或记录的 `present` 位已经置位时，命令分派器引发 `Fault_BundleControl`。

设计要点：第二条 `B.CATR` 是根据 `present` 位而不是字段值检测的。即使 `B.CATR` 的所有标志都为零，它也算作已写入，因此同一 header 中之后的 `B.CATR` 会被拒绝，而不是静默替换它。

成功提交后，该记录与其余 header 状态一起被清除。这些标志不会带入下一个 Block。

<!-- PTO-READER-BLOCK: block-b-catr-inputs role=inputs-outputs -->
## 编码字段

固定位为：低 15 位等于 `0x0023`，第 20 至 25 位和第 27 至 31 位为零（掩码 `0xfbf07fff`，匹配值 `0x00000023`）。六个标志如下：

- `rl`，第 15 位：release 排序。
- `aq`，第 16 位：acquire 排序。
- `atom`，第 17 位：整个 Block 的事务请求。
- `far`，第 18 位：远程执行请求。
- `trap`，第 19 位：同步的提交后陷阱请求。
- `DR`，第 26 位：维度归约模式。

六个位彼此独立。`aq` 与 `rl` 不要求 `atom`。

设计要点：省略 `B.CATR` 等价于把所有标志编码为零。与 `B.DATR` 不同，本命令没有省略与编码零含义不同的字段，因为每个标志的复位值都是零。

<!-- PTO-READER-BLOCK: block-b-catr-effects role=effects -->
## 各标志改变什么

`aq` 与 `rl` 通过 `CurrentBundleMemoryOrder` 选择 Block 内存顺序：两者都置位为 acquire-release，只置位一个为 acquire 或 release，都不置位为 relaxed。Tile 内存操作（例如 gather、scatter 和原子路径）把这个顺序传给它们的内存事件。

`trap` 只在成功提交之后起作用。`StopBundleAt` 先清除 Block 并选择下一个 PC，然后在该 PC 引发 `Fault_BundlePostCommit`。从该陷阱恢复会继续执行后继位置，而不是已退休的 Block。提交失败的 Block 不会引发提交后陷阱。

`far` 改变 Tile 操作的执行路径。形式模型针对发起核的输入执行该操作，并且只通过正常的本地提交发布结果。不存在可观察的中间远程结果。

`atom` 与 `DR` 会被记录，并可在 `LSRGET` 标识符 2 返回的打包控制字的第 8 位和第 12 位读取（见 [BARG](../model/state/barg.md)）。契约规定 `atom=1` 使 Block 成为一个全有或全无的事务。在当前可执行 ASL 中，没有操作读取 `CurrentBundleAtomic` 或 `CurrentBundleDimensionReduction`；对 `DR` 唯一的可执行检查是下面的提交规则。

<!-- PTO-READER-BLOCK: block-b-catr-constraints role=constraints -->
## 合法性与故障

- 放置错误或重复的 `B.CATR` 在记录改变之前引发 `Fault_BundleControl`。
- `DR=1` 在提交时检查。如果 `BARG` 中记录的 Block 类型既不是 `TileElement` 也不是 `TileMemory`，[提交验证](../model/commit/validation.md)会在任何 Block 效果之前引发 `Fault_BundleControl`。因此任何其他种类的 Block（例如 CUBE 矩阵 Block 或浮点 Block）都不能携带 `DR=1`。

设计要点：`DR` 在提交时检查，而不是在 `B.CATR` 执行时检查。ASL 注释说明，原始位可能在完整 header 选定其操作之前就被收集，因此检查要等到 Block 类型确定之后。

<!-- PTO-READER-BLOCK: block-b-catr-example role=example -->
## 非规范示例

以下为非规范示例，仅用于说明当前所有者，不替代其定义。

```asm
B.CATR {trap, atomic, <aq, rl, aqrl>, far, dr}
```

只置位 `aq` 和 `rl` 的 `B.CATR` 在固定的 `0x23` 之上编码第 15 位和第 16 位，得到字 `0x00018023`。该 Block 中的 Tile 内存操作随后以 acquire-release 顺序执行。若改为只置位 `trap`，则得到 `0x00080023`：Block 正常提交，然后在所选后继位置引发 `Fault_BundlePostCommit`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
B.CATR {trap, atomic, <aq, rl, aqrl>, far, dr}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| b_catr_32_e90bd52fa480 | L32 | 32 | 0x00000023 / 0xfbf07fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| b_catr_32_e90bd52fa480 | DR | 1 | encoding-defined | [{"instruction_lsb":26,"value_lsb":0,"width":1}] |
| b_catr_32_e90bd52fa480 | trap | 1 | encoding-defined | [{"instruction_lsb":19,"value_lsb":0,"width":1}] |
| b_catr_32_e90bd52fa480 | far | 1 | encoding-defined | [{"instruction_lsb":18,"value_lsb":0,"width":1}] |
| b_catr_32_e90bd52fa480 | atom | 1 | encoding-defined | [{"instruction_lsb":17,"value_lsb":0,"width":1}] |
| b_catr_32_e90bd52fa480 | aq | 1 | encoding-defined | [{"instruction_lsb":16,"value_lsb":0,"width":1}] |
| b_catr_32_e90bd52fa480 | rl | 1 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":1}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| b_catr_32_e90bd52fa480 | DR | 1 | 0–1 | none | none | dimension-reduction selector: zero multidimensional; one group-executed reduction mode | Encoded zero selects the default multidimensional operation mode. |
| b_catr_32_e90bd52fa480 | trap | 1 | 0–1 | none | none | synchronous post-commit trap request | Encoded zero disables the synchronous post-commit trap request. |
| b_catr_32_e90bd52fa480 | far | 1 | 0–1 | none | none | remote execution request using existing routing state | Encoded zero executes the block on the initiating core. |
| b_catr_32_e90bd52fa480 | atom | 1 | 0–1 | none | none | whole-block transaction selector | Encoded zero selects normal operation-specific commit visibility. |
| b_catr_32_e90bd52fa480 | aq | 1 | 0–1 | none | none | acquire ordering bit | Encoded zero disables acquire ordering. |
| b_catr_32_e90bd52fa480 | rl | 1 | 0–1 | none | none | release ordering bit | Encoded zero disables release ordering. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| DR | dimension-reduction selector: zero multidimensional; one group-executed reduction mode |
| trap | synchronous post-commit trap request |
| far | remote execution request using existing routing state |
| atom | whole-block transaction selector |
| aq | acquire ordering bit |
| rl | release ordering bit |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/attributes/B.CATR.asl -->
```asl
readonly func InstructionContractMatches_B_CATR(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_b_catr_32_e90bd52fa480);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
Optional header command after BSTART and before the first body instruction. At most one B.CATR may appear in a block.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/attributes/B.CATR.asl -->
```asl
readonly func InstructionContractHandler_B_CATR() => CommandSemanticHandler
begin
    return CommandHandler_SetBundleControlAttributes;
end;

pure func InstructionContractHeaderOnly_B_CATR()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractDuplicateRejects_B_CATR()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Omitting B.CATR is equivalent to trap=0, atom=0, aq=0, rl=0, far=0, and DR=0. Every encoded bit is explicit; zero never means an omitted instruction.

## Legality

- All six one-bit fields are independently assigned; aq and rl do not require atom=1.
- B.CATR is header-only and unique per block.
- DR=1 is assigned only for VEC, SFU, and TLSU blocks and rejects for CUBE and non-tile blocks before effects.

## State effects

- Defines one optional block control record for post-commit trap, transactional visibility, acquire/release ordering, remote execution, and dimension-reduction mode.
- trap=1 first commits and clears the block, then saves the selected continuation in a clean trap context; trap return resumes that continuation.
- far=1 captures the block inputs for the routing-selected remote target, waits for returned results, and commits those results only on the initiating core.
- DR=1 selects operation-defined dimension-reduction behavior for VEC, SFU, or TLSU; it never means dynamic rounding or direct-register addressing.

## Memory effects and ordering

### Memory effects

- aq prevents later-block memory effects from preceding this block; rl prevents earlier-block memory effects from following it; aq+rl applies both constraints.
- atom=1 makes the complete block one non-interleavable all-or-nothing architectural transaction: memory and register-output effects become visible together or remain ineffective.
- far=1 may transport inputs and returned results through a remote target selected by routing state, but only the initiating core's final commit is architecturally visible.

### Ordering

- aq prevents later-block memory effects from preceding this block.
- rl prevents earlier-block memory effects from following this block.
- When both bits are one, both acquire and release constraints apply independently.

## Exceptions

- A B.CATR outside an active header or a second B.CATR raises Illegal Block Exception before changing pending or architectural state.
- DR=1 in CUBE or a non-tile block raises Illegal Block Exception before block effects; VEC, SFU, and TLSU blocks may consume dimension-reduction mode.
- A failed or rejected block commit produces no post-commit trap and exposes no partial atomic-block result.

## Examples

- B.CATR {trap, atomic, <aq, rl, aqrl>, far, dr}

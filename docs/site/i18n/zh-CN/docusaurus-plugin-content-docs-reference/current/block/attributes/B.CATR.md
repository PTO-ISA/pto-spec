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

`B.CATR` 是一条 32 位 Block header 命令，用来记录可选的 Block 控制、排序、远程执行和归约属性。它修改待处理 Block 元数据，不会立即执行 Tile body 操作。

<!-- PTO-READER-BLOCK: block-b-catr-mechanism role=mechanism -->
## 位置与机制

该命令位于有效 Block header 中，并且在第一条 body 指令之前。重复或位置错误的使用会在待处理 header 状态变化前被拒绝。

命令被接受后，会在待处理 Block 状态中锁存一条带类型的属性记录。只有完整 header、绑定、维度和 body 满足所选操作 schema 后，该操作才会使用这些字段。

<!-- PTO-READER-BLOCK: block-b-catr-inputs role=inputs-outputs -->
## 操作数与 header 角色

- `DR` 选择多维模式或由操作定义的归约模式；其确切分配域仍以下方生成契约为准。
- `trap` 请求同步提交后陷阱；其确切分配域仍以下方生成契约为准。
- `far` 请求由路由状态选择的远程执行；其确切分配域仍以下方生成契约为准。
- `atom` 选择整个 Block 的事务可见性；其确切分配域仍以下方生成契约为准。
- `aq` 选择 acquire 排序；其确切分配域仍以下方生成契约为准。
- `rl` 选择 release 排序；其确切分配域仍以下方生成契约为准。

<!-- PTO-READER-BLOCK: block-b-catr-effects role=effects -->
## 待处理状态与完成

被接受的 header 命令只改变自己的待处理记录或 carrier。除非本所有者明确指出即时 header 状态更新，否则架构 Tile、Shared、GPR、内存和完成影响都推迟到完整 Block。

<!-- PTO-READER-BLOCK: block-b-catr-constraints role=constraints -->
## 合法性与故障边界

保留编码会在读取或待处理状态变化前被拒绝。位置、重复、角色或完成后 schema 不匹配，会在 body 影响前失败。

<!-- PTO-READER-BLOCK: block-b-catr-example role=example -->
## 非规范示例

以下为非规范示例，仅用于说明当前所有者，不替代其定义。

```asm
B.CATR {trap, atomic, <aq, rl, aqrl>, far, dr}
```

假设当前存在兼容的有效 header，并且之前没有冲突的 `B.CATR` 命令。把 `B.CATR {trap, atomic, <aq, rl, aqrl>, far, dr}` 放在下一个 header 槽，会记录该命令的待处理字段；它本身不会执行最终的 body 操作。
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

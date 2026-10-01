<!-- GENERATED FROM: asl/block/operands/B.IOR.asl -->
# B.IOR

**Normative ASL source:** `asl/block/operands/B.IOR.asl`

Bind up to three absolute GPR inputs and one absolute GPR output per record; ExecMaskPresent marks final-record GPR ExecutionMask words.

## Normative identity {#PTO-INST-BLOCK-B-IOR}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-b-ior-purpose role=purpose -->
## B.IOR 的作用

`B.IOR` 是一条 32 位块头部命令，把通用寄存器（GPR）绑定到当前块的操作。一条记录最多指定三个 GPR 输入和一个 GPR 输出。操作把它们用作标量操作数，例如全局内存基地址、行跨距、标量参数或标量结果。

`B.IOR` 执行时不读取任何 GPR。它记录选择器，所选操作在提交时读取这些寄存器。参见[标量绑定](../model/operands/scalar-bindings.md)。

<!-- PTO-READER-BLOCK: block-b-ior-mechanism role=mechanism -->
## 放置与机制

`B.IOR` 必须出现在活动块的头部，位于块启动之后、第一条主体指令之前。普通块只接受一条记录。有三类操作接受紧邻的第二条记录：TGPR2T、TIMG2COL，以及从 GPR 获取 ExecutionMask 的合格 Local CUBE 形式。

完整操作模式决定消费多少个选择器以及每个选择器的含义。记录本身总是保存四个选择器。输入按操作定义的顺序紧密排列到 `RegSrc0`、`RegSrc1` 与 `RegSrc2` 中，GPR ExecutionMask 字位于所有操作自有输入之后。

设计要点：省略与编码零不同。省略 `B.IOR` 时，每个被消费的槽位取操作自身的默认值。存在 `B.IOR` 时，选择器编码 0 指架构零 GPR，读出 0。对于 `TLOAD` 与 `TSTORE`，省略提供基地址零以及由列数和 `DataType` 计算出的紧密行跨距，而显式的 `RegSrc1 = zero` 提供跨距 0。

<!-- PTO-READER-BLOCK: block-b-ior-inputs role=inputs-outputs -->
## 字段与编码值

- `RegSrc0`（位 19:15）、`RegSrc1`（位 24:20）与 `RegSrc2`（位 31:27）是输入选择器。
- `RegDst`（位 11:7）是输出选择器。
- 每个选择器都写作绝对 GPR 编码 0 至 23：`zero`、`sp`、`a0` 至 `a7`、`ra`、`s0` 至 `s8` 以及 `x0` 至 `x3`。编码 24 至 31 在 `B.IOR` 中保留；相对 T 或 U 队列选择器永远不是合法的 `B.IOR` 字段，拒绝这些保留编码的是上面点名的那些 schema 检查。
- `ExecMaskPresent`（位 26）标记携带 GPR ExecutionMask 字的记录。位 25 固定为零。

设计要点：`ExecMaskPresent` 用于区分值为 `zero` 的掩码选择器与未使用的零选择器。它只在最后一条 `B.IOR` 记录上置位，且只在模式绑定 GPR ExecutionMask 时置位。`PredInv` 以及清零与合并的选择属于 `B.DATR` 控制，不是 `B.IOR` 字段。

<!-- PTO-READER-BLOCK: block-b-ior-effects role=effects -->
## 挂起状态

被接受的 `B.IOR` 写入一个标量绑定条目：四个选择器、一个源容量以及 `ExecMaskPresent` 标志。它不修改任何 GPR，也不访问内存。

操作在发布任何目标之前读取所绑定的输入。当操作定义了标量结果时，目标选择器接收该结果。源可以重复；当模式允许目标时，源也可以与目标指向同一个 GPR。

<!-- PTO-READER-BLOCK: block-b-ior-constraints role=constraints -->
## 合法性与故障边界

- 选择器编码 24 至 31 保留。记录仍会保存这些编码；只有在操作特定检查要求绝对 GPR 或掩码源时才会出现故障，例如 CUBE `TCI` 与 `TGPR2T`，它们在预检时以 `Fault_TileLegality` 拒绝。
- `B.IOR` 位于活动头部之外、在只允许一条记录的操作中出现第二条记录、出现第三条记录，或破坏 TGPR2T 或 TIMG2COL 流规则时，引发 `Fault_BundleControl`。
- 模式未消费的槽位中出现非零选择器、`ExecMaskPresent` 不在最后一条记录上或不适用，或其他模式不匹配时，在操作效果之前引发该操作的合法性故障。
- 带索引的 TLSU 操作要求显式的 `B.IOR`，其中 `RegSrc0` 为基地址，`RegSrc1`、`RegSrc2` 与 `RegDst` 全为零。

设计要点：多余的选择器必须为零。由于模式会拒绝非零的未使用字段，写在操作忽略的槽位中的多余寄存器名会被报告，而不是被悄悄丢弃。

<!-- PTO-READER-BLOCK: block-b-ior-example role=example -->
## 非规范示例

以下为非规范示例，仅用于说明当前所有者，不替代其定义。

```asm
B.IOR a0, a1, zero, ->zero
```

在 `TLOAD` 块中，这条记录从 `a0` 提供基地址，从 `a1` 提供以字节计的行跨距。`RegSrc2` 与 `RegDst` 为 `zero`，即未使用槽位的选择器。其字段为 `RegSrc0 = 2`、`RegSrc1 = 3`、`RegSrc2 = 0`、`RegDst = 0`、`ExecMaskPresent = 0`，编码为 `0x00310013`。若块改为省略 `B.IOR`，加载将使用基地址零和紧密行跨距。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
B.IOR [<gpr>[, <gpr>[, <gpr>]]][, -><gpr>][, ExecMaskPresent]
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| b_ior_32_c3ea71404eb3 | L32 | 32 | 0x00000013 / 0x0200707f | [{"field":"RegDst","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23]},{"field":"RegSrc0","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23]},{"field":"RegSrc1","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23]},{"field":"RegSrc2","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23]},{"field":"ExecMaskPresent","operator":"one-of","values":[0,1]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| b_ior_32_c3ea71404eb3 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| b_ior_32_c3ea71404eb3 | RegSrc0 | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| b_ior_32_c3ea71404eb3 | RegSrc1 | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| b_ior_32_c3ea71404eb3 | RegSrc2 | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |
| b_ior_32_c3ea71404eb3 | ExecMaskPresent | 1 | encoding-defined | [{"instruction_lsb":26,"value_lsb":0,"width":1}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Field value dispositions

### RegDst (`PTO-FIELD-BLOCK-GPR-SELECTOR`)

Selects one absolute architectural GPR for B.IOR input or output binding.

**Encoded zero:** Code zero names the architectural zero GPR; it never means an omitted B.IOR field.

| Code | Disposition | Meaning |
| ---: | --- | --- |
| 0 | assigned | zero |
| 1 | assigned | sp |
| 2 | assigned | a0 |
| 3 | assigned | a1 |
| 4 | assigned | a2 |
| 5 | assigned | a3 |
| 6 | assigned | a4 |
| 7 | assigned | a5 |
| 8 | assigned | a6 |
| 9 | assigned | a7 |
| 10 | assigned | ra |
| 11 | assigned | s0 |
| 12 | assigned | s1 |
| 13 | assigned | s2 |
| 14 | assigned | s3 |
| 15 | assigned | s4 |
| 16 | assigned | s5 |
| 17 | assigned | s6 |
| 18 | assigned | s7 |
| 19 | assigned | s8 |
| 20 | assigned | x0 |
| 21 | assigned | x1 |
| 22 | assigned | x2 |
| 23 | assigned | x3 |
| 24 | reserved | future extension |
| 25 | reserved | future extension |
| 26 | reserved | future extension |
| 27 | reserved | future extension |
| 28 | reserved | future extension |
| 29 | reserved | future extension |
| 30 | reserved | future extension |
| 31 | reserved | future extension |

**Reserved-value behavior:** Selectors 24 through 31 are reserved and raise Fault_IllegalInstruction before binding state changes.

### RegSrc0 (`PTO-FIELD-BLOCK-GPR-SELECTOR`)

Selects one absolute architectural GPR for B.IOR input or output binding.

**Encoded zero:** Code zero names the architectural zero GPR; it never means an omitted B.IOR field.

| Code | Disposition | Meaning |
| ---: | --- | --- |
| 0 | assigned | zero |
| 1 | assigned | sp |
| 2 | assigned | a0 |
| 3 | assigned | a1 |
| 4 | assigned | a2 |
| 5 | assigned | a3 |
| 6 | assigned | a4 |
| 7 | assigned | a5 |
| 8 | assigned | a6 |
| 9 | assigned | a7 |
| 10 | assigned | ra |
| 11 | assigned | s0 |
| 12 | assigned | s1 |
| 13 | assigned | s2 |
| 14 | assigned | s3 |
| 15 | assigned | s4 |
| 16 | assigned | s5 |
| 17 | assigned | s6 |
| 18 | assigned | s7 |
| 19 | assigned | s8 |
| 20 | assigned | x0 |
| 21 | assigned | x1 |
| 22 | assigned | x2 |
| 23 | assigned | x3 |
| 24 | reserved | future extension |
| 25 | reserved | future extension |
| 26 | reserved | future extension |
| 27 | reserved | future extension |
| 28 | reserved | future extension |
| 29 | reserved | future extension |
| 30 | reserved | future extension |
| 31 | reserved | future extension |

**Reserved-value behavior:** Selectors 24 through 31 are reserved and raise Fault_IllegalInstruction before binding state changes.

### RegSrc1 (`PTO-FIELD-BLOCK-GPR-SELECTOR`)

Selects one absolute architectural GPR for B.IOR input or output binding.

**Encoded zero:** Code zero names the architectural zero GPR; it never means an omitted B.IOR field.

| Code | Disposition | Meaning |
| ---: | --- | --- |
| 0 | assigned | zero |
| 1 | assigned | sp |
| 2 | assigned | a0 |
| 3 | assigned | a1 |
| 4 | assigned | a2 |
| 5 | assigned | a3 |
| 6 | assigned | a4 |
| 7 | assigned | a5 |
| 8 | assigned | a6 |
| 9 | assigned | a7 |
| 10 | assigned | ra |
| 11 | assigned | s0 |
| 12 | assigned | s1 |
| 13 | assigned | s2 |
| 14 | assigned | s3 |
| 15 | assigned | s4 |
| 16 | assigned | s5 |
| 17 | assigned | s6 |
| 18 | assigned | s7 |
| 19 | assigned | s8 |
| 20 | assigned | x0 |
| 21 | assigned | x1 |
| 22 | assigned | x2 |
| 23 | assigned | x3 |
| 24 | reserved | future extension |
| 25 | reserved | future extension |
| 26 | reserved | future extension |
| 27 | reserved | future extension |
| 28 | reserved | future extension |
| 29 | reserved | future extension |
| 30 | reserved | future extension |
| 31 | reserved | future extension |

**Reserved-value behavior:** Selectors 24 through 31 are reserved and raise Fault_IllegalInstruction before binding state changes.

### RegSrc2 (`PTO-FIELD-BLOCK-GPR-SELECTOR`)

Selects one absolute architectural GPR for B.IOR input or output binding.

**Encoded zero:** Code zero names the architectural zero GPR; it never means an omitted B.IOR field.

| Code | Disposition | Meaning |
| ---: | --- | --- |
| 0 | assigned | zero |
| 1 | assigned | sp |
| 2 | assigned | a0 |
| 3 | assigned | a1 |
| 4 | assigned | a2 |
| 5 | assigned | a3 |
| 6 | assigned | a4 |
| 7 | assigned | a5 |
| 8 | assigned | a6 |
| 9 | assigned | a7 |
| 10 | assigned | ra |
| 11 | assigned | s0 |
| 12 | assigned | s1 |
| 13 | assigned | s2 |
| 14 | assigned | s3 |
| 15 | assigned | s4 |
| 16 | assigned | s5 |
| 17 | assigned | s6 |
| 18 | assigned | s7 |
| 19 | assigned | s8 |
| 20 | assigned | x0 |
| 21 | assigned | x1 |
| 22 | assigned | x2 |
| 23 | assigned | x3 |
| 24 | reserved | future extension |
| 25 | reserved | future extension |
| 26 | reserved | future extension |
| 27 | reserved | future extension |
| 28 | reserved | future extension |
| 29 | reserved | future extension |
| 30 | reserved | future extension |
| 31 | reserved | future extension |

**Reserved-value behavior:** Selectors 24 through 31 are reserved and raise Fault_IllegalInstruction before binding state changes.

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| b_ior_32_c3ea71404eb3 | RegDst | 5 | 0–23 | none | 24–31 | absolute GPR destination | Encoded zero names the architectural zero GPR. |
| b_ior_32_c3ea71404eb3 | RegSrc0 | 5 | 0–23 | none | 24–31 | first absolute GPR source | Encoded zero names the architectural zero GPR. |
| b_ior_32_c3ea71404eb3 | RegSrc1 | 5 | 0–23 | none | 24–31 | second absolute GPR source | Encoded zero names the architectural zero GPR. |
| b_ior_32_c3ea71404eb3 | RegSrc2 | 5 | 0–23 | none | 24–31 | third absolute GPR source | Encoded zero names the architectural zero GPR. |
| b_ior_32_c3ea71404eb3 | ExecMaskPresent | 1 | 0–1 | none | none | marks that the final B.IOR record supplies the GPR ExecutionMask word(s) declared by the selected complete schema | No GPR ExecutionMask carrier is bound by this record. |

- `b_ior_32_c3ea71404eb3.RegDst` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.
- `b_ior_32_c3ea71404eb3.RegSrc0` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.
- `b_ior_32_c3ea71404eb3.RegSrc1` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.
- `b_ior_32_c3ea71404eb3.RegSrc2` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | absolute GPR destination |
| RegSrc0 | first absolute GPR source |
| RegSrc1 | second absolute GPR source |
| RegSrc2 | third absolute GPR source |
| ExecMaskPresent | marks that the final B.IOR record supplies the GPR ExecutionMask word(s) declared by the selected complete schema |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/operands/B.IOR.asl -->
```asl
readonly func InstructionContractMatches_B_IOR(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_b_ior_32_c3ea71404eb3);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
One B.IOR may appear after BSTART and before the block body when the complete schema declares GPR operands. Eligible Local CUBE ExecutionMask forms may use one or two immediately contiguous records; TGPR2T and TIMG2COL retain their separately owned two-record forms.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/operands/B.IOR.asl -->
```asl
// B.IOR's complete selected schema is authoritative for record count, source
// and destination role, omitted fields, and surplus rejection. TGPR2T uses
// exactly two contiguous source-only records with source arity 3+1. Eligible
// Local CUBE ExecutionMask GPR forms append one or two source words after all
// operation-owned GPR inputs and may use at most two contiguous records; the
// second is source-only, and the two words (when required) are one carrier.
// A third record, a misplaced record, a non-final presence flag, or any
// nonzero unconsumed selector is illegal. ExecMaskPresent is B.IOR[26];
// B.IOR[25] remains fixed zero. PredInv and Zero belong to B.DATR and are
// not encoded by B.IOR.
// All four selectors name complete 64-bit architectural GPRs in GPR0..GPR23.
// Canonical <gpr> spellings are zero, sp, a0..a7, ra, s0..s8, and x0..x3.
// Relative T/U queue selectors are not legal in any B.IOR field.
// Each B.IOR record binds up to three dense input slots, RegSrc0..RegSrc2.
// For eligible Local CUBE ExecutionMask forms, complete schemas concatenate
// up to two records in operation-owned order followed by mask word(s).
// Omission is distinct from an encoded zero selector. Consumers own raw-value
// validation before constrained assignment; a second B.IOR is accepted only
// by TGPR2T, TIMG2COL, or an eligible ExecutionMask GPR schema.
// Matrix complete-bundle consumers append optional scalar QuantParam then
// scalar LReLUParam in the same dense RegSrc order. Their omission/default,
// surplus-zero, and raw-carrier policy is owned by the dynamic schema at
// PTO-BLOCK-MODEL-DISPATCH-TILE-SCHEMA and
// spec/evidence/bundle-command-totality.json.
pure func InstructionContractMatrixPostProcessGPRQuantSlot_B_IOR() => integer
begin
    return 0;
end;

pure func InstructionContractMatrixPostProcessGPRLReLUSlot_B_IOR() => integer
begin
    return 1;
end;

pure func InstructionContractMatrixPostProcessGPRCapacity_B_IOR() => integer
begin
    return 3;
end;

pure func InstructionContractAbsoluteGPRSelectorLegal_B_IOR(
    selector: Reg5Selector) => boolean
begin
    return selector < PTO_ABSOLUTE_GPR_COUNT;
end;

// In TLOAD/TSTORE schemas source zero supplies the GM base and source one
// supplies row stride in bytes.  Omission is distinct from an
// encoded selector whose current value is zero.
// Indexed TLSU schemas require an explicit B.IOR: source zero supplies the GM
// base and source one, source two, and the destination supply zero.
pure func InstructionContractTLSUBaseSource_B_IOR() => integer
begin
    return 0;
end;

pure func InstructionContractTLSURowStrideSource_B_IOR() => integer
begin
    return 1;
end;

readonly func InstructionContractHandler_B_IOR() => CommandSemanticHandler
begin
    return CommandHandler_BindBundleScalarIO;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- The complete BSTART operation schema determines whether B.IOR is consumed and the number and roles of its GPR inputs and output.
- When B.IOR is omitted, every consumed input or output uses its operation-defined default. An explicitly encoded selector zero names the architectural zero GPR and is not omission.
- For TLOAD and TSTORE, omission supplies GM base zero and a dense byte row stride derived from the resolved column count and DataType; explicit RegSrc1=zero supplies a zero stride.
- All indexed TLSU forms require explicit B.IOR with RegSrc0 as the GM base address; RegSrc1, RegSrc2, and RegDst encode zero.
- Matrix postprocess B.IOR slots follow the complete B.FPATR schema: scalar QuantParam then scalar LReLUParam, with omitted consumed slots reading the zero GPR.

## Legality

- B.IOR is legal only after BSTART and before the block body when the complete selected schema declares GPR operands; an explicitly encoded zero selector names GPR0 and is not omission.
- RegDst and RegSrc0..RegSrc2 accept only absolute GPR selectors 0..23; selectors 24..31 are reserved and reject before effects.
- Sources may repeat and may alias RegDst where the selected complete schema permits a destination. Any nonzero unconsumed field rejects before block effects.
- Indexed TLSU consumes RegSrc0 as BaseGPR. RegSrc1, RegSrc2, and RegDst must be zero before memory or destination effects.
- Every ordinary block accepts at most one B.IOR. TGPR2T and TIMG2COL retain their exact two-record exceptions. An eligible Local CUBE ExecutionMask GPR form appends one or two words after all operation-owned GPR inputs and may use one or two contiguous records, in dense source order, for up to six GPR inputs. Any GPR destination is allowed only in the first record; the second record is source-only.
- ExecMaskPresent is one only on the final contiguous B.IOR record when a GPR ExecutionMask is bound. Earlier records, unpredicated forms, and Predicate-Tile forms require it to be zero. Selector GPR0 is legal and is distinguished from an unused zero selector by the final-record flag and exact schema arity.

## State effects

- Record the schema-permitted B.IOR selector state: one record for ordinary consumers or up to two immediately contiguous records for TGPR2T, TIMG2COL, or eligible Local CUBE ExecutionMask forms. Effective arity, roles, and ExecMaskPresent applicability derive from the complete operation schema.
- Inputs are read according to the selected operation before destination publication; executing B.IOR itself modifies no GPR.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- none

## Exceptions

- A nonzero unused field or other operation-schema mismatch raises a block/tile legality fault before operation effects.
- An out-of-range selector raises Fault_IllegalInstruction before binding state changes. Standalone or body-phase B.IOR raises Illegal Block Exception before binding state changes. Duplicate, noncontiguous, third, misplaced, or schema-inapplicable records and a non-final or inapplicable ExecMaskPresent flag raise Fault_BundleControl or Fault_TileLegality before effects.

## Examples

- B.IOR a0, a1, zero, ->zero
- B.IOR zero, ExecMaskPresent

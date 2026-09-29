<!-- GENERATED FROM: asl/block/model/dispatch/decode.asl -->
# Decode

**Normative ASL source:** `asl/block/model/dispatch/decode.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-DECODE}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-dispatch-decode-purpose role=purpose-scope -->
## 用途与范围

本单元把指令束命令的原始位转换为带类型的值。指令束命令是由命令分派处理的 Block 表面命令指令，例如 `BSTART`、`B.DIM`、`B.IOT`、`B.DATR` 或 `BSTOP`。形式（form）是这类命令在冻结命令目录中的一种具体编码。

本单元定义命令处理程序调用的字段提取函数、两个处理程序分类谓词，以及 `DecodeBundleOperationDescriptor`，它构建 `BSTART` 形式携带的操作描述符。它还定义 `CommandExecutionStatus`，即命令分派返回的 `Executed` 或 `Rejected` 结果。

<!-- PTO-READER-BLOCK: block-model-dispatch-decode-concepts role=concepts-state -->
## 概念与可见状态

除枚举类型外，本单元的每个函数都是 `pure`。本单元不读取也不写入任何架构状态。

- `CommandDecodedWord` 把字段扩展到 `PTO_XLEN` 位。目录标记为有符号的字段按其宽度符号扩展，该宽度必须是 8、12、15、17、25、30 或 42 位。其他字段一律零扩展。
- `CommandDecodedReg5` 保留低 5 位作为 GPR 选择子。`CommandDecodedTile` 保留低 6 位作为 `TileIndex`。`CommandDecodedSmall` 保留低 4 位。`CommandDecodedBool` 检查位 0。
- 队列标志辅助函数把单比特字段打包为 4 位值。Move 把 `i`、`e`、`s`、`r` 放在位 3 到 0。Pop 把 `e` 放在位 1，把 `r` 放在位 0。Push 把 `h` 放在位 3，把 `e` 放在位 2，把 `r` 放在位 0。
- `CommandDecodedBundleDimension` 选择维度槽位。带 `LoopNest` 字段的形式使用该字段的低 2 位。否则由 `B.DIM` 形式本身指定槽位：`->LB0` 得到 0，`->LB1` 得到 1，其他形式得到 2。

操作描述符记录 `form_identity`、`operation_class` 以及四个可选字段：`selector`、`data_type`、`mode` 和 `branch_type`。每个可选字段都有自己的有效标志。

<!-- PTO-READER-BLOCK: block-model-dispatch-decode-rules role=rules-interactions -->
## 规则与交互

选择子取自按以下顺序第一个适用的来源：编码变体常量、选择 Tile 操作的形式中的 10 位 Tile 操作码、5 位 `Function` 字段，以及目录选择子常量。若都不适用，`selector_valid` 为假。

当形式选择 Tile 操作或具有 `DataType` 字段时，`data_type_valid` 为真。`mode` 是 `Mode` 字段的低 2 位，`branch_type` 是 `BrType` 字段的低 3 位，二者都只在对应字段存在时取值。

设计要点：缺省字段与编码为零的字段保持区分。每个可选字段都带有有效标志，缺省字段以全零存储且标志为假。后续检查会测试该标志。例如，`BundleSelectorCode` 只有在 `mode_valid` 为真时才把 `mode` 放在选择子之上。

`CommandHandlerSupported` 对三个处理程序返回假：`SaveExecutionContext`、`RecoverExecutionContext` 和 `ExecuteCrossBlockTransfer`，它们分别服务 `ESAVE`、`ERCOV` 和 `XB`。命令分派在调用任何处理程序之前检查它，并对这些处理程序引发 `Fault_IllegalInstruction`。

设计要点：这些形式仍会解码为已知形式，但不会为它们运行任何处理程序。`XB` 契约说明了原因：保留解码得到的身份是为了冲突清点和失败即关闭（fail-closed）的分派。

`CommandHandlerAdvancesSequentially` 对指令束开始、指令束停止、`FRET.RA` 和 `FRET.STK` 处理程序为假。对其他处理程序，命令分派通常在无故障执行之后把命令字节长度加到 `TPC` 上，但 `B.HINT` 的 trace 形式除外。

设计要点：这四个处理程序自行选择下一个 `TPC`。开始和停止处理程序可能提交指令束，而提交会根据 `BARG` 写入 `TPC`。如果在它们之后再做固定的顺序步进，就会覆盖该选择。

<!-- PTO-READER-BLOCK: block-model-dispatch-decode-boundaries role=boundaries -->
## 架构边界

本单元不负责把原始位匹配到形式。`ExecuteCommandInstruction` 完成匹配，并在 `ExecuteDecodedBundleCommand` 运行之前检查操作数合法性。本单元也不判断描述符是否合法。`ExecuteDecodedBundleStart` 先解码描述符，再在提交任何前驱指令束之前用 `BundleOperationDescriptorLegal` 检查它。它只在 `BeginBundleAt` 无故障完成后才安装描述符。

<!-- PTO-READER-BLOCK: block-model-dispatch-decode-example role=example-usage -->
## 非规范阅读示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

32 位的 `B.DIM RegSrc, uimm, ->LB1` 没有 `LoopNest` 字段，因此 `CommandDecodedBundleDimension` 返回 1。它的处理程序不属于四个非顺序处理程序，因此在 `TPC` 0x1004 处无故障执行后，`TPC` 变为 0x1008。

`BSTART.STD DIRECT, <label>` 具有有符号的 17 位 `simm17` 字段。若对值为 `0x1FFFF` 的该字段应用 `CommandDecodedWord`，它会被符号扩展为 `PTO_XLEN` 位的 -1；同样的原始位若位于 `B.DIM` 的 `uimm17` 这类无符号 17 位字段中，则得到 131071。指令束开始路径本身通过生成的 `CommandSignedOffsetOfForm` 读取该偏移，它同样进行符号扩展。

<!-- PTO-READER-BLOCK: block-model-dispatch-decode-related role=related-owners-navigation -->
## 相关所有者

- [顶层分派](top-level.md) 在任何处理程序运行之前匹配形式并检查操作数。
- [命令](commands.md) 调用提取函数，并为顺序处理程序推进 `TPC`。
- [指令束开始分派](start.md) 解码、检查并安装操作描述符。
- [描述符合法性](descriptor-legality.md) 决定哪些解码后的描述符可以被安装。
- [XB](../../encoding/XB.md) 是一个保留形式，它可以解码但总是被拒绝。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/dispatch/decode.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-DECODE","surface":"block","classification":["model","dispatch","decode"],"depends_on":["PTO-BLOCK-B-CATR","PTO-BLOCK-B-DATR","PTO-BLOCK-B-DIM","PTO-BLOCK-B-HINT","PTO-BLOCK-B-IOR","PTO-BLOCK-B-IOS","PTO-BLOCK-B-IOT","PTO-BLOCK-BSTART","PTO-BLOCK-BSTART-ICALL","PTO-BLOCK-BSTART-FP","PTO-BLOCK-BSTART-GMOV","PTO-BLOCK-BSTART-MGATHER","PTO-BLOCK-BSTART-MGATHER-CAS","PTO-BLOCK-BSTART-MGATHER-MASK","PTO-BLOCK-BSTART-MSCATTER","PTO-BLOCK-BSTART-MSCATTER-MASK","PTO-BLOCK-BSTART-STD","PTO-BLOCK-BSTART-SYS","PTO-BLOCK-BSTART-TEPL","PTO-BLOCK-BSTART-TGEMV","PTO-BLOCK-BSTART-TGEMV-ACC","PTO-BLOCK-BSTART-TGEMV-BIAS","PTO-BLOCK-BSTART-TGEMVMX","PTO-BLOCK-BSTART-TGEMVMX-ACC","PTO-BLOCK-BSTART-TGEMVMX-BIAS","PTO-BLOCK-BSTART-TLOAD","PTO-BLOCK-BSTART-TMATMUL","PTO-BLOCK-BSTART-TMATMUL-ACC","PTO-BLOCK-BSTART-TMATMUL-BIAS","PTO-BLOCK-BSTART-TMATMULMX","PTO-BLOCK-BSTART-TMATMULMX-ACC","PTO-BLOCK-BSTART-TMATMULMX-BIAS","PTO-BLOCK-BSTART-TMOV","PTO-BLOCK-BSTART-TPREFETCH","PTO-BLOCK-BSTART-TSTORE","PTO-BLOCK-BSTOP","PTO-BLOCK-C-B-DIMI","PTO-BLOCK-C-BSTART","PTO-BLOCK-C-BSTART-FP","PTO-BLOCK-C-BSTART-STD","PTO-BLOCK-C-BSTART-SYS","PTO-BLOCK-C-BSTOP","PTO-BLOCK-ERCOV","PTO-BLOCK-ESAVE","PTO-BLOCK-FENTRY","PTO-BLOCK-FEXIT","PTO-BLOCK-FRET-RA","PTO-BLOCK-FRET-STK","PTO-BLOCK-HL-QMT","PTO-BLOCK-HL-QPOP","PTO-BLOCK-HL-QPUSH","PTO-BLOCK-MCOPY","PTO-BLOCK-MSET","PTO-BLOCK-XB"]}
// PTO-REQ-BUNDLE-DISPATCH-001: decoded bundle-command execution.

type CommandExecutionStatus of enumeration {
    CommandExecution_Executed,
    CommandExecution_Rejected
};

pure func CommandDecodedWord(instruction: bits(64),
                             form: integer {0..PTO_COMMAND_FORM_COUNT-1},
                             field: CommandOperandField) => Word
begin
    let raw = DecodeCommandOperandRaw(instruction, form, field);
    if CommandOperandSignedness(form, field) == ScalarField_Signed then
        case CommandOperandWidth(form, field) of
            when 8  => return SignExtend{PTO_XLEN}(raw[7:0]);
            when 12 => return SignExtend{PTO_XLEN}(raw[11:0]);
            when 15 => return SignExtend{PTO_XLEN}(raw[14:0]);
            when 17 => return SignExtend{PTO_XLEN}(raw[16:0]);
            when 25 => return SignExtend{PTO_XLEN}(raw[24:0]);
            when 30 => return SignExtend{PTO_XLEN}(raw[29:0]);
            when 42 => return SignExtend{PTO_XLEN}(raw[41:0]);
            otherwise => unreachable;
        end;
    end;
    return ZeroExtend{PTO_XLEN}(raw);
end;

pure func CommandDecodedReg5(instruction: bits(64),
                             form: integer {0..PTO_COMMAND_FORM_COUNT-1},
                             field: CommandOperandField) => Reg5Selector
begin
    return UInt(DecodeCommandOperandRaw(instruction, form, field)[4:0])
        as Reg5Selector;
end;

pure func CommandDecodedTile(instruction: bits(64),
                             form: integer {0..PTO_COMMAND_FORM_COUNT-1},
                             field: CommandOperandField) => TileIndex
begin
    return UInt(DecodeCommandOperandRaw(instruction, form, field)[5:0])
        as TileIndex;
end;

pure func CommandDecodedBool(instruction: bits(64),
                             form: integer {0..PTO_COMMAND_FORM_COUNT-1},
                             field: CommandOperandField) => boolean
begin
    return DecodeCommandOperandRaw(instruction, form, field)[0] == '1';
end;

pure func CommandHandlerSupported(handler: CommandSemanticHandler)
                                       => boolean
begin
    case handler of
        when CommandHandler_SaveExecutionContext,
             CommandHandler_RecoverExecutionContext,
             CommandHandler_ExecuteCrossBlockTransfer => return FALSE;
        otherwise => return TRUE;
    end;
end;

pure func CommandHandlerAdvancesSequentially(handler: CommandSemanticHandler)
                                             => boolean
begin
    return handler != CommandHandler_ExecuteBundleStart &&
           handler != CommandHandler_ExecuteBundleStop &&
           handler != CommandHandler_ExecuteFrameReturnAddress &&
           handler != CommandHandler_ExecuteFrameReturnStack;
end;

pure func CommandDecodedSmall(instruction: bits(64),
                              form: integer {0..PTO_COMMAND_FORM_COUNT-1},
                              field: CommandOperandField) => integer {0..15}
begin
    return UInt(DecodeCommandOperandRaw(instruction, form, field)[3:0])
        as integer {0..15};
end;

pure func CommandDecodedQueueMoveFlags(
    instruction: bits(64),
    form: integer {0..PTO_COMMAND_FORM_COUNT-1}) => bits(4)
begin
    var flags: bits(4) = Zeros{4};
    flags[3] = DecodeCommandOperandRaw(instruction, form, CommandField_i)[0];
    flags[2] = DecodeCommandOperandRaw(instruction, form, CommandField_e)[0];
    flags[1] = DecodeCommandOperandRaw(instruction, form, CommandField_s)[0];
    flags[0] = DecodeCommandOperandRaw(instruction, form, CommandField_r)[0];
    return flags;
end;

pure func CommandDecodedQueuePopFlags(
    instruction: bits(64),
    form: integer {0..PTO_COMMAND_FORM_COUNT-1}) => bits(4)
begin
    var flags: bits(4) = Zeros{4};
    flags[1] = DecodeCommandOperandRaw(instruction, form, CommandField_e)[0];
    flags[0] = DecodeCommandOperandRaw(instruction, form, CommandField_r)[0];
    return flags;
end;

pure func CommandDecodedQueuePushFlags(
    instruction: bits(64),
    form: integer {0..PTO_COMMAND_FORM_COUNT-1}) => bits(4)
begin
    var flags: bits(4) = Zeros{4};
    flags[3] = DecodeCommandOperandRaw(instruction, form, CommandField_h)[0];
    flags[2] = DecodeCommandOperandRaw(instruction, form, CommandField_e)[0];
    flags[0] = DecodeCommandOperandRaw(instruction, form, CommandField_r)[0];
    return flags;
end;

pure func CommandDecodedBundleDimension(instruction: bits(64),
                                       form: integer {0..PTO_COMMAND_FORM_COUNT-1})
                                       => BundleDimensionIndex
begin
    if CommandOperandPresent(form, CommandField_LoopNest) then
        return UInt(DecodeCommandOperandRaw(instruction, form,
            CommandField_LoopNest)[1:0]) as BundleDimensionIndex;
    end;
    case CommandOperationOfForm(form) of
        when CommandOperation_b_dim_32_27602ab68929 => return 0;
        when CommandOperation_b_dim_32_4191099a5f4d => return 1;
        otherwise => return 2;
    end;
end;

pure func DecodeBundleOperationDescriptor(
    instruction: bits(64),
    form: integer {0..PTO_COMMAND_FORM_COUNT-1}) => BundleOperationDescriptor
begin
    var selector = Zeros{10};
    var selector_valid = FALSE;
    if CommandBundleSelectorUsesEncodingVariant(form) then
        selector = CommandBundleSelectorConstantOfForm(instruction, form);
        selector_valid = TRUE;
    elsif CommandFormSelectsTileOperation(form) then
        selector = CommandTileCodeOfForm(instruction, form)[9:0];
        selector_valid = TRUE;
    elsif CommandOperandPresent(form, CommandField_Function) then
        selector[4:0] = DecodeCommandOperandRaw(instruction, form,
            CommandField_Function)[4:0];
        selector_valid = TRUE;
    elsif CommandBundleSelectorConstantPresent(form) then
        selector = CommandBundleSelectorConstantOfForm(instruction, form);
        selector_valid = TRUE;
    end;
    return BundleOperationDescriptor {
        valid = TRUE,
        form_identity = Zeros{7} + form,
        operation_class = CommandBundleOperationClassOfForm(form),
        selector_valid = selector_valid,
        selector = selector,
        data_type_valid = CommandFormSelectsTileOperation(form) ||
            CommandOperandPresent(form, CommandField_DataType),
        data_type = if CommandFormSelectsTileOperation(form) then
            CommandTileDataTypeOfForm(instruction, form)
            else if CommandOperandPresent(form, CommandField_DataType) then
            DecodeCommandOperandRaw(instruction, form, CommandField_DataType)[4:0]
            else Zeros{5},
        mode_valid = CommandOperandPresent(form, CommandField_Mode),
        mode = if CommandOperandPresent(form, CommandField_Mode) then
            DecodeCommandOperandRaw(instruction, form, CommandField_Mode)[1:0]
            else Zeros{2},
        branch_type_valid = CommandOperandPresent(form, CommandField_BrType),
        branch_type = if CommandOperandPresent(form, CommandField_BrType) then
            DecodeCommandOperandRaw(instruction, form, CommandField_BrType)[2:0]
            else Zeros{3}
    };
end;
```
<!-- GENERATED-ASL-END: unit -->

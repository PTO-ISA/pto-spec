<!-- GENERATED FROM: asl/block/execution/BSTART.TGEMV.ACC.asl -->
# BSTART.TGEMV.ACC

**Normative ASL source:** `asl/block/execution/BSTART.TGEMV.ACC.asl`

Starts CUBE Function 18 for the TGEMV_ACC M=1 Matrix-vector complete-bundle operation.

## Normative identity {#PTO-INST-BLOCK-BSTART-TGEMV-ACC}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-bstart-tgemv-acc-purpose role=purpose -->
## BSTART.TGEMV.ACC 的作用

`BSTART.TGEMV.ACC` 是 `TGEMV.ACC` 形式的 32 位 Block 起始命令。它建立待处理 Block 的身份和选择参数；真正执行 Block body 并提交结果的是完成后的整个 Block，而不是起始命令本身。

<!-- PTO-READER-BLOCK: block-bstart-tgemv-acc-mechanism role=mechanism -->
## 位置与机制

起始命令之后的 header 命令按顺序执行；`BSTOP` 或下一条 `BSTART` 是验证并退休完整 Block 的边界。当前所有者给出以下确切组成检查表：

```text
BSTART.TGEMV.ACC AType
B.DATR BType, RMode, Sat (optional; BType defaults to AType)
B.FPATR PreQuantMode, ReluMode, GroupNCode, RowMaxEn, GroupMaxEn, RowMaxInit, MaxAbsEn, TransA, TransB, CScaleEn (exactly one)
B.DIM LB0 M (optional, default 1; TGEMV permits only M=1)
B.DIM LB1 N (optional, default 1)
B.DIM LB2 K (optional, default 1)
B.IOT ordered Local mathematical sources: C CUBE_M16/M32 accumulator matching A with encoded selector distinct from DstTile, A CUBE_M16/M32 primary, B CUBE_N8 primary
B.IOT D matching A's CUBE_M16/M32 layout with a distinct encoded destination index, optional RowMaxOut, optional GroupMaxOut destinations
B.IOT/B.IOR postprocess operands selected by B.FPATR
BSTOP or the next BSTART completion boundary
```

任何有效前序 Block 成功退休后，该命令初始化新的待处理 `BARG` 或操作描述符，并从顺序 PC 继续执行 header。仅仅成功解码起始命令，不会让 Block 目的结果或内存结果变得可见。

<!-- PTO-READER-BLOCK: block-bstart-tgemv-acc-inputs role=inputs-outputs -->
## 操作数与 header 角色

- `DataType` 选择元素数据类型或继承哨兵；其确切分配域仍以下方生成契约为准。

<!-- PTO-READER-BLOCK: block-bstart-tgemv-acc-effects role=effects -->
## 待处理状态与完成

对适用性和目标检查而言，起始状态转换与前序 Block 退休是全有或全无的。起始命令成功后，后续完成边界会在任何 body 结果提交前验证完整组成。

<!-- PTO-READER-BLOCK: block-bstart-tgemv-acc-constraints role=constraints -->
## 合法性与故障边界

保留选择器、无效目标、完成后的组成错误或前序退休失败，都会在新 Block 或 body 影响之前被拒绝。

<!-- PTO-READER-BLOCK: block-bstart-tgemv-acc-example role=example -->
## 非规范示例

以下为非规范示例，仅用于说明当前所有者，不替代其定义。

```asm
BSTART.TGEMV.ACC DataType
```

假设前序 Block 退休和目标检查成功，`BSTART.TGEMV.ACC DataType` 会打开待处理的 `BSTART.TGEMV.ACC` 形式；后续 header/body 命令仍是暂定状态，直到 `BSTOP` 或下一条 `BSTART` 验证完整组成。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
BSTART.TGEMV.ACC DataType
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| bstart_tgemv_acc_32_9a471b21913e | L32 | 32 | 0x01231181 / 0x07ffffff | [{"field":"DataType","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,16,17,18,19,20,24,25,26,27,28]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| bstart_tgemv_acc_32_9a471b21913e | DataType | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Field value dispositions

### DataType (`PTO-FIELD-BLOCK-DATATYPE`)

Selects the Tile element data type carried by Block data attributes and typed Block starts.

**Encoded zero:** Code zero selects FP64; zero never means absent, inherited, NONE, or NULL.

| Code | Disposition | Meaning |
| ---: | --- | --- |
| 0 | assigned | FP64 |
| 1 | assigned | FP32 |
| 2 | assigned | TF32 |
| 3 | assigned | HF32 |
| 4 | assigned | FP16 |
| 5 | assigned | BF16 |
| 6 | assigned | HiF8 |
| 7 | assigned | E4M3 |
| 8 | assigned | E5M2 |
| 9 | assigned | E3M2 |
| 10 | assigned | E2M3 |
| 11 | assigned | E2M1X2 |
| 12 | assigned | E1M2X2 |
| 13 | assigned | E8M0 |
| 14 | assigned | HiF4X2 |
| 15 | reserved | future extension |
| 16 | assigned | S64 |
| 17 | assigned | S32 |
| 18 | assigned | S16 |
| 19 | assigned | S8 |
| 20 | assigned | S4X2 |
| 21 | reserved | future extension |
| 22 | reserved | future extension |
| 23 | reserved | future extension |
| 24 | assigned | U64 |
| 25 | assigned | U32 |
| 26 | assigned | U16 |
| 27 | assigned | U8 |
| 28 | assigned | U4X2 |
| 29 | reserved | future extension |
| 30 | reserved | future extension |
| 31 | reserved | future extension |

**Reserved-value behavior:** Reserved values are held for future extension and reject before architectural effects.

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| bstart_tgemv_acc_32_9a471b21913e | DataType | 5 | 0–14, 16–20, 24–28 | none | 15, 21–23, 29–31 | tile element data type selector | Encoded zero selects FP64. |

- `bstart_tgemv_acc_32_9a471b21913e.DataType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| DataType | tile element data type selector |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/execution/BSTART.TGEMV.ACC.asl -->
```asl
readonly func InstructionContractMatches_BSTART_TGEMV_ACC(
    operation: CommandOperation) => boolean
begin
    return operation ==
        CommandOperation_bstart_tgemv_acc_32_9a471b21913e;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.TGEMV.ACC AType
B.DATR BType, RMode, Sat (optional; BType defaults to AType)
B.FPATR PreQuantMode, ReluMode, GroupNCode, RowMaxEn, GroupMaxEn, RowMaxInit, MaxAbsEn, TransA, TransB, CScaleEn (exactly one)
B.DIM LB0 M (optional, default 1; TGEMV permits only M=1)
B.DIM LB1 N (optional, default 1)
B.DIM LB2 K (optional, default 1)
B.IOT ordered Local mathematical sources: C CUBE_M16/M32 accumulator matching A with encoded selector distinct from DstTile, A CUBE_M16/M32 primary, B CUBE_N8 primary
B.IOT D matching A's CUBE_M16/M32 layout with a distinct encoded destination index, optional RowMaxOut, optional GroupMaxOut destinations
B.IOT/B.IOR postprocess operands selected by B.FPATR
BSTOP or the next BSTART completion boundary
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/execution/BSTART.TGEMV.ACC.asl -->
```asl
readonly func InstructionContractTileOperation_BSTART_TGEMV_ACC()
    => TileOperation
begin
    return TileOperation_TGEMV_ACC;
end;

readonly func InstructionContractCubeFunction_BSTART_TGEMV_ACC()
    => integer {0..31}
begin
    return 18;
end;

readonly func InstructionContractSharedOperandsAllowed_BSTART_TGEMV_ACC()
    => boolean
begin
    return FALSE;
end;

readonly func InstructionContractHandler_BSTART_TGEMV_ACC()
    => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Encoded DataType is always AType. Omitted B.DATR preserves AType as BType, selects RNE, and disables saturation.
- Omitted LB0, LB1, and LB2 default M, N, and K independently to one; TGEMV fixes M to one.
- Exactly one all-zero B.FPATR selects no conversion, activation, or reduction; B.IOR and auxiliary B.IOT operands exist only when a selected postprocess mode requires them.
- Local A uses persistent CUBE_M16 or CUBE_M32, Local B uses persistent CUBE_N8, and D is newly allocated in A's M layout; Local C also uses A's M layout. M is fixed to one; N and K are arbitrary positive values independent of per-PE TSize.
- TransA=0 and TransB=0 select no logical transpose. TGEMV requires both controls to remain zero.
- C and D are both mandatory. In decoded blocks C's six-bit relative selector must differ from zero-extended DstTile before rename; direct Tile calls require destination TileIndex to differ from accumulator TileIndex.

## Legality

- The carrier selects exactly CUBE Function 18 and TileOperation_TGEMV_ACC.
- Local A uses persistent CUBE_M16 or CUBE_M32, Local B uses persistent CUBE_N8, and D is newly allocated in A's M layout; Local C also uses A's M layout. M is fixed to one; N and K are arbitrary positive values independent of per-PE TSize.
- C and D are both mandatory. In decoded blocks C's six-bit relative selector must differ from zero-extended DstTile before rename; direct Tile calls require destination TileIndex to differ from accumulator TileIndex.
- TGEMV is Local-only: TransA and TransB are zero and every effective Shared binding rejects before effects.
- AType and BType must be supported ordinary Matrix types from one numeric class. C is one explicit Local MxN accumulator source and D is a distinct newly published destination; C's encoded relative selector and D's zero-extended DstTile hand must differ before rename. M is fixed to one and every Shared binding is illegal.
- Every common nonzero four-bit PE_MASK is legal; all four PEs complete cooperative Shared readiness while only selected PEs allocate and publish. Mask zero is a strict no-op before descriptor reads, faults, allocation, readiness checks, or lifetime effects.
- B.DATR permits only BType, RMode, and Sat. Exactly one B.FPATR is mandatory and closes the conditional postprocess schema.

## State effects

- Start a CUBE Function 18 descriptor with encoded DataType preserved as AType.
- At block completion execute TileOperation_TGEMV_ACC using the resolved M, N, K, input types, mathematical operands, and B.FPATR postprocess schema.
- Publish the complete output group atomically after successful preflight and computation; do not consume mathematical or postprocess sources.
- For Local execution, publish D with A's CUBE_M16 or CUBE_M32 layout and final output dtype; ordinary Bias, MX scales, and enabled reduction auxiliaries keep their operation-owned layouts.
- C is snapshotted before multiplication and remains descriptor-and-payload unchanged after success or rejection.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Complete schema, field, type, dimension, descriptor, shape, capacity, readiness, alias, and allocation preflight precedes every source snapshot and destination effect.
- D and every enabled reduction output publish as one atomic group; rejection publishes none and successful sources persist.

## Exceptions

- A reserved DataType or fixed-bit mismatch raises Fault_IllegalInstruction before block state changes.
- Missing, duplicate, or non-Matrix B.FPATR use raises Fault_BundleControl before allocation or payload effects.
- Illegal types, dimensions, masks, binding streams, descriptors, shapes, capacities, aliases, readiness, or postprocess values raise Fault_TileLegality before source snapshots and effects.

## Examples

- BSTART.TGEMV.ACC AType; B.DATR BType, RMode, Sat (optional; BType defaults to AType); B.FPATR PreQuantMode, ReluMode, GroupNCode, RowMaxEn, GroupMaxEn, RowMaxInit, MaxAbsEn, TransA, TransB, CScaleEn (exactly one); B.DIM LB0 M (optional, default 1; TGEMV permits only M=1); B.DIM LB1 N (optional, default 1); B.DIM LB2 K (optional, default 1); B.IOT ordered Local mathematical sources: C CUBE_M16/M32 accumulator matching A with encoded selector distinct from DstTile, A CUBE_M16/M32 primary, B CUBE_N8 primary; B.IOT D matching A's CUBE_M16/M32 layout with a distinct encoded destination index, optional RowMaxOut, optional GroupMaxOut destinations; B.IOT/B.IOR postprocess operands selected by B.FPATR; BSTOP or the next BSTART completion boundary

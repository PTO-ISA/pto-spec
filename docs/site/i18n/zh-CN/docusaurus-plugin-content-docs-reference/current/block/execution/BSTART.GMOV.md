<!-- GENERATED FROM: asl/block/execution/BSTART.GMOV.asl -->
# BSTART.GMOV

**Normative ASL source:** `asl/block/execution/BSTART.GMOV.asl`

Collectively copies peer-PE Local fragments to selected Local destinations.

## Normative identity {#PTO-INST-BLOCK-BSTART-GMOV}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-bstart-gmov-purpose role=purpose -->
## BSTART.GMOV 的作用

`BSTART.GMOV` 是 `GMOV` 形式的 32 位 Block 起始命令。它建立待处理 Block 的身份和选择参数；真正执行 Block body 并提交结果的是完成后的整个 Block，而不是起始命令本身。

<!-- PTO-READER-BLOCK: block-bstart-gmov-mechanism role=mechanism -->
## 位置与机制

起始命令之后的 header 命令按顺序执行；`BSTOP` 或下一条 `BSTART` 是验证并退休完整 Block 的边界。当前所有者给出以下确切组成检查表：

```text
BSTART.GMOV DataType; optional B.DATR Layout; one terminating B.IOT with one Local source and one Local destination; optional B.IOR peer_tid; BSTOP
B.IOS and B.DIM are not members of a GMOV schema.
```

任何有效前序 Block 成功退休后，该命令初始化新的待处理 `BARG` 或操作描述符，并从顺序 PC 继续执行 header。仅仅成功解码起始命令，不会让 Block 目的结果或内存结果变得可见。

<!-- PTO-READER-BLOCK: block-bstart-gmov-inputs role=inputs-outputs -->
## 操作数与 header 角色

- `DataType` 选择元素数据类型或继承哨兵；其确切分配域仍以下方生成契约为准。
- `B.IOT source` 标识输入源或源角色选择；其确切分配域仍以下方生成契约为准。
- `B.IOT destination` 标识目的位置或发布选择；其确切分配域仍以下方生成契约为准。
- `B.IOT PE_MASK` 标识目的位置或发布选择；其确切分配域仍以下方生成契约为准。
- `B.IOR.RegSrc0` 选择具名的绝对 GPR 角色；其确切分配域仍以下方生成契约为准。

<!-- PTO-READER-BLOCK: block-bstart-gmov-effects role=effects -->
## 待处理状态与完成

对适用性和目标检查而言，起始状态转换与前序 Block 退休是全有或全无的。起始命令成功后，后续完成边界会在任何 body 结果提交前验证完整组成。

<!-- PTO-READER-BLOCK: block-bstart-gmov-constraints role=constraints -->
## 合法性与故障边界

保留选择器、无效目标、完成后的组成错误或前序退休失败，都会在新 Block 或 body 影响之前被拒绝。

<!-- PTO-READER-BLOCK: block-bstart-gmov-example role=example -->
## 非规范示例

以下为非规范示例，仅用于说明当前所有者，不替代其定义。

```asm
BSTART.GMOV DataType
```

假设前序 Block 退休和目标检查成功，`BSTART.GMOV DataType` 会打开待处理的 `BSTART.GMOV` 形式；后续 header/body 命令仍是暂定状态，直到 `BSTOP` 或下一条 `BSTART` 验证完整组成。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
BSTART.GMOV DataType
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| bstart_gmov_32_6c21e223eaa7 | L32 | 32 | 0x00d11181 / 0x07ffffff | [{"field":"DataType","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,16,17,18,19,20,24,25,26,27,28]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| bstart_gmov_32_6c21e223eaa7 | DataType | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |

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
| bstart_gmov_32_6c21e223eaa7 | DataType | 5 | 0–14, 16–20, 24–28 | none | 15, 21–23, 29–31 | byte-preserved Local fragment element type | Encoded zero selects FP64. |

- `bstart_gmov_32_6c21e223eaa7.DataType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| DataType | byte-preserved Local fragment element type |
| B.IOT source | Core4 peer-resolved Local source snapshot |
| B.IOT destination | renamed Local destination and per-PE TSize |
| B.IOT PE_MASK | selected destination request/write participants |
| B.IOR.RegSrc0 | each PE's private-GPR absolute peer_tid |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/execution/BSTART.GMOV.asl -->
```asl
readonly func InstructionContractMatches_BSTART_GMOV(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_bstart_gmov_32_6c21e223eaa7);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.GMOV DataType; optional B.DATR Layout; one terminating B.IOT with one Local source and one Local destination; optional B.IOR peer_tid; BSTOP
B.IOS and B.DIM are not members of a GMOV schema.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/execution/BSTART.GMOV.asl -->
```asl
readonly func InstructionContractHandler_BSTART_GMOV() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;

readonly func InstructionContractStartedTileOperation_BSTART_GMOV()
    => TileOperation
begin
    return TileOperation_GMOV;
end;

pure func InstructionContractStartsTileBundle_BSTART_GMOV()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- DataType is explicit; omitted B.DATR selects NORM.
- Omitted B.IOR supplies peer_tid zero independently in all four PEs. An explicit zero selector reads the architectural zero GPR and supplies the same value without invoking an omission default.

## Legality

- bstart_gmov_32_6c21e223eaa7.DataType accepts only 0..14, 16..20, 24..28; all other encodings are reserved.
- All four PEs rendezvous and all four peer-resolved source fragments must be allocated and ready, independent of PE_MASK.
- Any nonzero PE_MASK is legal and controls only destination request/allocation/write participation; PE_MASK=0000 is a strict no-op before source access or faults.
- Each PE's absolute peer_tid is 0..3; repeated peer identifiers are legal.

## State effects

- For each selected PE, allocate a new Local destination fragment and copy the byte-preserving peer-resolved source payload and definedness.
- Unselected PEs participate in rendezvous and readiness preflight but do not request, allocate, write, or complete a destination. Shared state is unchanged.

## Memory effects and ordering

### Memory effects

- none; GMOV performs no GM access and emits no PTO memory event

### Ordering

- Snapshot every source fragment and validate all descriptors, readiness, peer selectors, and participant agreement before allocating or writing any selected destination.
- Read-old/write-new behavior preserves a source snapshot when architectural aliases resolve to the same prior value.

## Exceptions

- Reserved DataType, malformed bindings, any Shared binding or B.DIM, incompatible descriptors, non-ready Core4 source, or any PE peer_tid outside 0..3 raises an Illegal Block exception before requests, allocation, destination writes, or events.
- Core4 convergence and source readiness are one combined preflight; a failed attempt exposes no partial destination.

## Examples

- BSTART.GMOV U8; B.IOT T#1, mask=0011, size=1, ->T; B.IOR zero, a0; BSTOP

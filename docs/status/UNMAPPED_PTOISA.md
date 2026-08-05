---
{
  "schema_version": 1,
  "id": "coverage.unmapped_ptoisa",
  "kind": "coverage",
  "title": "Unmapped PTOISA Intrinsics and Open Items",
  "status": "review",
  "visibility": "internal",
  "profile": "pto-isa-0.58.0",
  "sources": {
    "davincioo": "UNMAPPED_PTOISA.md"
  }
}
---
# Unmapped PTOISA Intrinsics and Open Items

<!-- BEGIN GENERATED: status-summary -->
## 当前状态摘要

本表由各指令状态页的 frontmatter 生成；下方历史审阅材料不再作为状态权威源。

| Opcode | 状态 | 指令族 | 状态页 |
| --- | --- | --- | --- |
| `ACCCVT` | removed | matrix-cube | [ACCCVT.md](ACCCVT.md) |
| `ALLOC_TILE` | unmapped | element-wise | [status/unmapped/ALLOC_TILE.md](status/unmapped/ALLOC_TILE.md) |
| `comm/TBROADCAST` | unmapped | communication | [status/comm/TBROADCAST.md](status/comm/TBROADCAST.md) |
| `comm/TGATHER` | unmapped | communication | [status/comm/TGATHER.md](status/comm/TGATHER.md) |
| `comm/TGET` | unmapped | communication | [status/comm/TGET.md](status/comm/TGET.md) |
| `comm/TGET_ASYNC` | unmapped | communication | [status/comm/TGET_ASYNC.md](status/comm/TGET_ASYNC.md) |
| `comm/TNOTIFY` | unmapped | communication | [status/comm/TNOTIFY.md](status/comm/TNOTIFY.md) |
| `comm/TPUT` | unmapped | communication | [status/comm/TPUT.md](status/comm/TPUT.md) |
| `comm/TPUT_ASYNC` | unmapped | communication | [status/comm/TPUT_ASYNC.md](status/comm/TPUT_ASYNC.md) |
| `comm/TREDUCE` | unmapped | communication | [status/comm/TREDUCE.md](status/comm/TREDUCE.md) |
| `comm/TSCATTER` | unmapped | communication | [status/comm/TSCATTER.md](status/comm/TSCATTER.md) |
| `comm/TTEST` | unmapped | communication | [status/comm/TTEST.md](status/comm/TTEST.md) |
| `comm/TWAIT` | unmapped | communication | [status/comm/TWAIT.md](status/comm/TWAIT.md) |
| `GET_TENSOR_VIEW_DIM` | unmapped | element-wise | [status/unmapped/GET_TENSOR_VIEW_DIM.md](status/unmapped/GET_TENSOR_VIEW_DIM.md) |
| `GET_TENSOR_VIEW_STRIDE` | unmapped | element-wise | [status/unmapped/GET_TENSOR_VIEW_STRIDE.md](status/unmapped/GET_TENSOR_VIEW_STRIDE.md) |
| `MAKE_TENSOR_VIEW` | unmapped | element-wise | [status/unmapped/MAKE_TENSOR_VIEW.md](status/unmapped/MAKE_TENSOR_VIEW.md) |
| `PARTITION_VIEW` | unmapped | element-wise | [status/unmapped/PARTITION_VIEW.md](status/unmapped/PARTITION_VIEW.md) |
| `SET_VALIDSHAPE` | unmapped | element-wise | [status/unmapped/SET_VALIDSHAPE.md](status/unmapped/SET_VALIDSHAPE.md) |
| `SUBSET` | unmapped | element-wise | [status/unmapped/SUBSET.md](status/unmapped/SUBSET.md) |
| `TALIAS` | unmapped | sync-config | [status/unmapped/TALIAS.md](status/unmapped/TALIAS.md) |
| `TALLOC` | unmapped | system-scheduling | [status/system/TALLOC.md](status/system/TALLOC.md) |
| `TASSIGN` | unmapped | sync-config | [status/unmapped/TASSIGN.md](status/unmapped/TASSIGN.md) |
| `TENSOR_VIEW_ADDR` | unmapped | element-wise | [status/unmapped/TENSOR_VIEW_ADDR.md](status/unmapped/TENSOR_VIEW_ADDR.md) |
| `TFILLPAD_EXPAND` | unmapped | layout-movement | [status/unmapped/TFILLPAD_EXPAND.md](status/unmapped/TFILLPAD_EXPAND.md) |
| `TFILLPAD_INPLACE` | unmapped | layout-movement | [status/unmapped/TFILLPAD_INPLACE.md](status/unmapped/TFILLPAD_INPLACE.md) |
| `TFREE` | unmapped | system-scheduling | [status/system/TFREE.md](status/system/TFREE.md) |
| `TGET_SCALE_ADDR` | unmapped | sync-config | [status/unmapped/TGET_SCALE_ADDR.md](status/unmapped/TGET_SCALE_ADDR.md) |
| `TILE_BUF_ADDR` | unmapped | element-wise | [status/unmapped/TILE_BUF_ADDR.md](status/unmapped/TILE_BUF_ADDR.md) |
| `TPACK` | unmapped | layout-movement | [status/unmapped/TPACK.md](status/unmapped/TPACK.md) |
| `TPOP` | unmapped | system-scheduling | [status/system/TPOP.md](status/system/TPOP.md) |
| `TPOW` | unmapped | element-wise | [status/unmapped/TPOW.md](status/unmapped/TPOW.md) |
| `TPOWS` | unmapped | tile-scalar | [status/unmapped/TPOWS.md](status/unmapped/TPOWS.md) |
| `TPREFETCH_ASYNC` | unmapped | memory-tlsu | [status/unmapped/TPREFETCH_ASYNC.md](status/unmapped/TPREFETCH_ASYNC.md) |
| `TPRINT` | unmapped | complex-special | [status/unmapped/TPRINT.md](status/unmapped/TPRINT.md) |
| `TPUSH` | unmapped | system-scheduling | [status/system/TPUSH.md](status/system/TPUSH.md) |
| `TRESHAPE` | unmapped | layout-movement | [status/unmapped/TRESHAPE.md](status/unmapped/TRESHAPE.md) |
| `TSET_IMG2COL_PADDING` | unmapped | sync-config | [status/unmapped/TSET_IMG2COL_PADDING.md](status/unmapped/TSET_IMG2COL_PADDING.md) |
| `TSET_IMG2COL_RPT` | unmapped | sync-config | [status/unmapped/TSET_IMG2COL_RPT.md](status/unmapped/TSET_IMG2COL_RPT.md) |
| `TSETFMATRIX` | unmapped | sync-config | [status/unmapped/TSETFMATRIX.md](status/unmapped/TSETFMATRIX.md) |
| `TSETHF32MODE` | unmapped | sync-config | [status/unmapped/TSETHF32MODE.md](status/unmapped/TSETHF32MODE.md) |
| `TSETTF32MODE` | unmapped | sync-config | [status/unmapped/TSETTF32MODE.md](status/unmapped/TSETTF32MODE.md) |
| `TSUBVIEW` | unmapped | sync-config | [status/unmapped/TSUBVIEW.md](status/unmapped/TSUBVIEW.md) |
| `TSYNC` | unmapped | sync-config | [status/unmapped/TSYNC.md](status/unmapped/TSYNC.md) |

<!-- END GENERATED: status-summary -->
本页收口当前 PTOISA 中尚未生成 DavinciOO block ISA intrinsic 页的指令，以及本轮不处理的统一遗留项。

## Unmapped PTOISA

当前未映射项分为两类：

- 非 `comm/` PTOISA：下面补充 PTO 定义、暂未补 intrinsic 的具体原因，以及后续需要定义的 block/header 方向。
- `comm/` PTOISA：属于通信 ISA，本轮仍保持单独列表，不混入普通 tileblock intrinsic。

### 非 comm 未映射 PTOISA

#### 资源、视图与同步类

| PTO 指令 | PTO 来源 | PTO 定义 | 暂未补原因 / 后续方向 |
| --- | --- | --- | --- |
| `TALIAS` | `../pto/TALIAS.md` | 创建与原 tile 共享底层 storage 的 alias tile view。 | 需要定义 alias/view 对 rename、retire、lifetime、写后可见性的影响；不是普通 tile compute。后续应定义 view/resource header。 |
| `TASSIGN` | `../pto/TASSIGN.md` | 将 Tile 对象绑定到 implementation-defined on-chip address，用于手工 placement。 | 涉及片上地址空间、placement 权限和资源占用模型；当前 Linx-style `B.IOT/B.DIM` 不表达地址绑定。后续应定义 resource/system block。 |
| `TRESHAPE` | `../pto/TRESHAPE.md` | 在字节内容不变的前提下，把 tile 重解释为另一种 type/shape。 | 需要定义 view metadata、tile allocation size 与新 shape 的关系。后续可和 `TALIAS/TSUBVIEW` 一起定义 view 类 intrinsic。 |
| `TSUBVIEW` | `../pto/TSUBVIEW.md` | 将一个 tile 解释为另一个 tile 的 subview。 | 需要 subview offset、shape、alias lifetime 与写回规则；当前 metadata header 只描述执行域，不描述存储视图。 |
| `TPUSH` | `../pto/TPUSH.md` | 向 pipe/FIFO producer endpoint push tile。 | 需要 pipe endpoint、slot ownership、阻塞/事件语义；不属于普通 tileblock compute。后续应定义 pipe/resource block。 |
| `TPOP` | `../pto/TPOP.md` | 从 pipe/FIFO consumer endpoint pop tile。 | 需要 consumer-local slot 持有、数据可见性和事件模型；不能只用 `B.IOT` output binding 表达。 |
| `TFREE` | `../pto/TFREE.md` | 释放由 consumer 持有的 pipe/FIFO slot。 | 需要和 `TPOP` 的 slot lifetime 绑定；是资源释放语义而不是 tile 数据计算。 |
| `TSYNC` | `../pto/TSYNC.md` | PTO execution synchronization，可表达 wait event 或特定 op class barrier。 | 需要统一 event/barrier/system ordering 模型；后续应进入 system/config ISA，而不是 TEPL tile intrinsic。 |

#### Extract、Insert、FP Scale 与 Store 变体

| PTO 指令 | PTO 来源 | PTO 定义 | 暂未补原因 / 后续方向 |
| --- | --- | --- | --- |
| `TEXTRACT` | `../pto/TEXTRACT.md` | 从 source tile 按 `indexRow/indexCol` 抽取 sub-tile 到 dst。 | 需要明确 offset、sub-tile shape 与 valid-region 的编码位置；可能需要 `B.ARG` 或新的 view/data-movement header。 |
| `TINSERT` | `../pto/TINSERT.md` | 将 source sub-tile 插入 dst 的 `indexRow/indexCol` 位置。 | 需要读旧 dst、局部覆盖、写回同一/新 dst 的 rename 和 retire 规则；不能按普通二源一目的 element-wise 直接映射。 |
| `TEXTRACT_FP` | `../pto/TEXTRACT_FP.md` | 带 `fp` scaling tile 的 `TEXTRACT` 变体。 | 除 extract offset 外，还需要定义 `fp` scale tile、FIXPIPE/scale 路径和 dtype 转换规则。 |
| `TINSERT_FP` | `../pto/TINSERT_FP.md` | 带 `fp` scaling tile 的 `TINSERT` 变体。 | 同时包含 insert 局部覆盖和 `fp` scale 语义，需要先统一 FP scale/FIXPIPE header。 |
| `TMOV_FP` | `../pto/TMOV_FP.md` | 使用 `fp` scaling tile 将 accumulator/中间结果 move/convert 到 dst tile。 | 涉及 ACC/FIXPIPE 出口、scale tile operand、round/sat/dtype 组合；本轮 ACC 保持 Linx 原设计，未重定义。 |
| `TSTORE_FP` | `../pto/TSTORE_FP.md` | 带 `fp` scaling tile 的 store 变体，将 tile/accumulator 结果写入 GM。 | 需要 memory store path、scale tile、dtype 转换、地址 operand 的组合定义；不是单纯 Tile output binding。 |
| `TGET_SCALE_ADDR` | `../pto/TGET_SCALE_ADDR.md` | 将输出 tile 的片上地址绑定为输入 tile 地址的 scaled form。 | 属于地址计算/地址绑定辅助指令，需要片上地址空间和 scale-address 规则；后续和 FP scale/FIXPIPE 一起设计。 |

#### IMG2COL 与系统配置类

| PTO 指令 | PTO 来源 | PTO 定义 | 暂未补原因 / 后续方向 |
| --- | --- | --- | --- |
| `TIMG2COL` | `../pto/TIMG2COL.md` | 将 feature-map tile 转换为 im2col-style matrix tile，用于卷积 lowering。 | 依赖 IMG2COL config、padding、repeat、FMATRIX、约定；需要先定义 config register/header。 |
| `TSETFMATRIX` | `../pto/TSETFMATRIX.md` | 设置 IMG2COL 使用的 FMATRIX register/config。 | 属于系统配置状态写入，当前还没有 DavinciOO `BSTART.SYS`/config block 方案。 |
| `TSET_IMG2COL_PADDING` | `../pto/TSET_IMG2COL_PADDING.md` | 设置 IMG2COL padding metadata。 | 需要定义 padding config 的寄存器、生命周期、与 `TIMG2COL` 的依赖关系。 |
| `TSET_IMG2COL_RPT` | `../pto/TSET_IMG2COL_RPT.md` | 设置 IMG2COL repeat metadata。 | 同上，需要 config 状态和 profile 行为。 |
| `TSETTF32MODE` | `../pto/TSETTF32MODE.md` | 配置 TF32 transform mode。 | 属于 profile/system mode 设置，需确定作用域、retire 可见性和与后续 matmul/convert 的关系。 |
| `TSETHF32MODE` | `../pto/TSETHF32MODE.md` | 配置 HF32 transform mode。 | 同 `TSETTF32MODE`，需要 system/config ISA 支撑。 |

#### 量化、打包与 Pad 类

| PTO 指令 | PTO 来源 | PTO 定义 | 暂未补原因 / 后续方向 |
| --- | --- | --- | --- |
| `TQUANT` | `../pto/TQUANT.md` | 将 FP32 tile 量化到低精度，并生成 scale/max/exponent 等辅助结果。 | 多输出、多 mode、scale/max tile 格式和 profile 行为未定；需要单独 quant header/opcode 设计。 |
| `TDEQUANT` | `../pto/TDEQUANT.md` | 使用 scale/offset tile 将整数 tile 反量化为浮点 tile。 | 需要定义 scale/offset dtype 组合、round/sat 规则；不能只靠现有 `B.DATR` 推导。 |
| `TPACK` | `../pto/TPACK.md` | 将 tile element pack/convert 到更窄或特定布局的 dst 表示。 | 需要 lane packing、bit packing、alignment、round/sat/profile 规则；后续应作为 pack/quant 类扩展。 |
| `TFILLPAD` | `../pto/TFILLPAD.md` | copy source 到 dst，并对 padding 或 valid-region 外元素写入 PadValue。 | 之前遗留的 PadValue、PTO valid-region 外值、DavinciOO inactive lane 行为尚未收口；该指令会显式写 valid-region 外区域。 |
| `TFILLPAD_EXPAND` | `../pto/TFILLPAD_EXPAND.md` | fillpad 的 expand 变体，允许 dst 覆盖比 src 更大的区域。 | 除 PadValue 规则外，还需要定义 expand shape、源外区域读取和目标外区域写入边界。 |
| `TFILLPAD_INPLACE` | `../pto/TFILLPAD_INPLACE.md` | 原地 fillpad，对同一个 tile 的 padding/invalid 区域进行填充。 | 需要读写同 tile 的 hazard/rename 规则，以及 inactive lane 写入是否 architecturally visible。 |

#### 特殊计算、调试、预取、排序与随机类

| PTO 指令 | PTO 来源 | PTO 定义 | 暂未补原因 / 后续方向 |
| --- | --- | --- | --- |
| `TCI` | `../pto/TCI.md` | 向 dst tile 生成连续整数序列，支持 runtime `start` 和 compile-time `descending`。 | 相对容易补，但仍需分配 opcode，并定义 `start` 标量、`descending` mode、dtype/shape 与事件语义。 |
| `TTRI` | `../pto/TTRI.md` | 生成上三角/下三角 mask tile，按 diagonal 参数决定分界。 | 相对容易补，但需要定义 orientation、diagonal 标量/立即数、mask dtype 与 TEPL/TLSU opcode。 |
| `TSORT32` | `../pto/TSORT32.md` | 对每个 32-element block 排序，并输出排序后的 value-index pair。 | 需要输出 element 格式、index 宽度、稳定性、临时资源和 profile 规则。 |
| `TMRGSORT` | `../pto/TMRGSORT.md` | 对多条已排序 list 做 merge sort。 | 比 `TSORT32` 更依赖 list 格式、临时 buffer、merge 策略和 profile 限制。 |
| `TRANDOM` | `../pto/TRANDOM.md` | 使用 key/counter 的 counter-based cipher 生成随机数 tile。 | 需要 RNG key/counter 状态、确定性规则、seed 更新和 profile 行为；不适合临时伪造为普通 TEPL。 |
| `TPREFETCH` | `../pto/TPREFETCH.md` | 将 GM 数据预取到 tile-local cache/buffer，不隐含同步。 | 有 memory/cache side effect 但没有普通 tile dst；需要 memory/cache header 和 ordering 规则。 |
| `TPRINT` | `../pto/TPRINT.md` | device-side debug print，可打印 Tile 或 GlobalTensor。 | 调试 side-effect 指令，需要 host/debug 通道、格式和执行副作用模型；不进入普通 compute intrinsic。 |

### comm 未映射 PTOISA

| PTO 指令 | PTO 来源 | 原因 | 后续方向 |
| --- | --- | --- | --- |
| `comm/TBROADCAST` | `../pto/comm/TBROADCAST.md` | PTO communication ISA；本轮不映射到普通 Linx tileblock/templateblock intrinsic。 | 后续单独定义通信 opcode/header、同步事件和跨核/跨 tile group profile。 |
| `comm/TGATHER` | `../pto/comm/TGATHER.md` | PTO communication ISA；不同于普通 tile `TGATHER/TGATHERB` 数据重排。 | 后续单独定义通信 gather 的 participant、rank/group、buffer 和事件语义。 |
| `comm/TGET` | `../pto/comm/TGET.md` | PTO communication ISA；本轮不映射到普通 memory load/store intrinsic。 | 后续定义远端/共享通信地址、阻塞语义和完成事件。 |
| `comm/TGET_ASYNC` | `../pto/comm/TGET_ASYNC.md` | PTO communication ISA；async 完成和 wait/test 语义需要事件模型。 | 后续与 `TWAIT/TTEST/TNOTIFY` 一起定义通信事件 header。 |
| `comm/TNOTIFY` | `../pto/comm/TNOTIFY.md` | PTO communication ISA；通知对象和可见性不是普通 tile operand。 | 后续定义 notify token、scope 和 ordering。 |
| `comm/TPUT` | `../pto/comm/TPUT.md` | PTO communication ISA；本轮不映射到普通 store intrinsic。 | 后续定义通信 put 的目标、scope、completion 和 memory visibility。 |
| `comm/TPUT_ASYNC` | `../pto/comm/TPUT_ASYNC.md` | PTO communication ISA；async put 需要 completion event。 | 后续与通信 wait/test 体系一起设计。 |
| `comm/TREDUCE` | `../pto/comm/TREDUCE.md` | PTO communication ISA；不同于本地 tile reduce。 | 后续定义 collective reduce 的 group、op、dst rank、同步和临时资源。 |
| `comm/TSCATTER` | `../pto/comm/TSCATTER.md` | PTO communication ISA；不同于普通 tile scatter/data movement。 | 后续定义 communication scatter participant 与 buffer 规则。 |
| `comm/TTEST` | `../pto/comm/TTEST.md` | PTO communication ISA；用于测试 async/event 状态。 | 后续定义事件寄存器/状态返回路径。 |
| `comm/TWAIT` | `../pto/comm/TWAIT.md` | PTO communication ISA；用于等待通信事件完成。 | 后续定义 wait scope、阻塞/非阻塞行为和 retire 边界。 |

## 统一遗留项

- OOB 规则：source/destination valid-region 外行为本轮不处理。
- `meta_mask` payload/profile 行为：只记录为动态 metadata mode，具体 payload 格式后续按 profile 定义。
- 其他 profile-specific 细节：quant、sort、img2col、system/communication 等后续分族补充。

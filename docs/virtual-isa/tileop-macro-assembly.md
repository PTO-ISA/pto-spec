# PTO TileOp macro assembly

This reference defines the canonical PTO 0.58.6 macro-assembly format for all 117 current direct Tile operations.
It is generated from the `PTO-TILEOP-MACRO` owners in `asl/arch/overview/instruction-classification.asl`; each physical mapping is cross-checked against the operation's owning `PTO-INSTRUCTION` metadata and `spec/catalog/tile-operations.json`.

## Syntax model

```text
TileOp <bundle configuration>, ordered sources, ->ordered destinations
```

- One TileOp macro instruction MUST occupy exactly one source line. A newline terminates the instruction; continuation syntax is not accepted and canonical disassembly never wraps the instruction.
- Configuration fields follow LB index order, then type/attribute fields, then `PEMask` when the physical bindings carry a PE mask.
- LB dimensions retain named roles such as `LB0:ValidCol`; attributes are positional self-describing values, so concrete assembly writes `FP32`, not `DataType:FP32`.
- An attribute may be removed from the angle-bracket list entirely when the selected TileOp schema supplies an exact default or a unique inference from typed operands; omission leaves no empty slot or placeholder.
- The assembler binds each bare attribute token through the selected TileOp schema value domain. An unresolved or multiply matching token is rejected rather than assigned by guesswork.
- `?` marks an optional configuration field whose exact default is recorded by the owning instruction contract.
- `.reuse` is not canonical: current `B.IOT` never releases a source.
- A source may carry `[subview=<range>]` and a destination may carry `[assemble=<range>]` when the owning operation accepts the corresponding range modifier.
- One macro instruction maps to one physical bundle. Its boundary is an explicit `BSTOP` or the next `BSTART`.
- `PEMask` is PE participation and is distinct from an element predicate carrier.
- Destinations may be Tile (`->DstTile<Size>`), Shared Tile (`->DstShared<Size>`), scalar through `B.IOR.RegDst` (`->ScalarDst`), legacy predicate Tile (`->PredicateTile<Size>`), CUBE PredicateCell (`->PredicateCell<Size>`), or predicate-mask GPR (`->PredicateGPR`).
- `X?` is optional; `X=value` states the virtual default; `X{if Condition}` is present only when that configuration condition holds.
- `X{must be Value}` is a legality constraint, not an omission default.
- `SourceOr1` and `SourceOrValidCol` mean an allocated Shared source contributes its descriptor value; an unallocated Shared source uses 1 or ValidCol as specified by TSTORE.
- `FPAttrs` expands to `PreQuantMode, ReluMode, GroupNCode, RowMaxEn, GroupMaxEn, RowMaxInit, MaxAbsEn, TransA, TransB, CScaleEn`.
- CUBE conditional operands explicitly name RowMax, GroupMax, quantization, ReLU, and CScale sources or destinations together with their controlling FPAttrs condition.

A concrete macro is always written on one line:

```text
TADD <LB0:100, LB1:a0, LB2:a1+10, FP32, Null, 1111>, T#1, T#2, ->T<2KB>
```

Destination metavariables likewise become physical binding operands. A Local destination names only its encoded `B.IOT.DstTile` hand: for example, `->T<2KB>` publishes a new `T#1`, while `->U<512B>` may publish a legacy packed predicate Tile or a CUBE PredicateCell as the new `U#1` according to the selected TCMP/TCMPS form. `->a0` is a scalar or predicate-mask result carried by `B.IOR.RegDst`. PTO 0.58.6 defines no architectural predicate-register destination for these TileOps.

## Complete format inventory

### elementwise-tile-tile/arithmetic

| TileOp | Engine | Canonical macro format |
| --- | --- | --- |
| `TADD` | `VEC` | `TADD <LB0:ValidCol, LB1:ValidRow?, LB2:Col?, DataType, PadValue?, PEMask>, SrcTile0, SrcTile1, ->DstTile<Size>` |
| `TFMA` | `VEC` | `TFMA <LB0:ValidCol, LB1:ValidRow?, LB2:Col?, DataType, PadValue?, PEMask>, SrcTile0, SrcTile1, SrcTile2, ->DstTile<Size>` |
| `TMAX` | `VEC` | `TMAX <LB0:ValidCol, LB1:ValidRow?, LB2:Col?, DataType, PadValue?, PEMask>, SrcTile0, SrcTile1, ->DstTile<Size>` |
| `TMIN` | `VEC` | `TMIN <LB0:ValidCol, LB1:ValidRow?, LB2:Col?, DataType, PadValue?, PEMask>, SrcTile0, SrcTile1, ->DstTile<Size>` |
| `TMUL` | `VEC` | `TMUL <LB0:ValidCol, LB1:ValidRow?, LB2:Col?, DataType, PadValue?, PEMask>, SrcTile0, SrcTile1, ->DstTile<Size>` |
| `TSUB` | `VEC` | `TSUB <LB0:ValidCol, LB1:ValidRow?, LB2:Col?, DataType, PadValue?, PEMask>, SrcTile0, SrcTile1, ->DstTile<Size>` |

### elementwise-tile-tile/format-conversion

| TileOp | Engine | Canonical macro format |
| --- | --- | --- |
| `TCVT` | `VEC` | `TCVT <LB0:ValidCol, LB1:ValidRow?, LB2:Col?, SrcDataType, DstDataType?, RMode?, Sat?, Canonicalize?, Layout?, PadValue?, PEMask>, SrcTile0, ->DstTile<Size>` |

### elementwise-tile-tile/logical

| TileOp | Engine | Canonical macro format |
| --- | --- | --- |
| `TABS` | `VEC` | `TABS <LB0:ValidCol, LB1:ValidRow?, LB2:Col?, DataType, PadValue?, PEMask>, SrcTile0, ->DstTile<Size>` |
| `TAND` | `VEC` | `TAND <LB0:ValidCol, LB1:ValidRow?, LB2:Col?, DataType, PadValue?, PEMask>, SrcTile0, SrcTile1, ->DstTile<Size>` |
| `TCMP` | `VEC` | `TCMP <LB0:ValidCol, LB1:ValidRow=1, LB2:Col=ValidCol, DataType, CMode=EQ, PadValue=Null, PEMask>, SrcTile0, SrcTile1, ->PredicateTile<Size>`<br>`TCMP <LB0:ValidCol, LB1:ValidRow=1, LB2:Col=ValidCol, DataType, CMode=EQ, PadValue=Null, PEMask>, SrcTile0, SrcTile1, ->PredicateCell<Size>`<br>`TCMP <LB0:ValidCol, LB1:ValidRow=1, LB2:Col=ValidCol, DataType, CMode=EQ, PadValue=Null, SatMode?, PEMask>, SrcTile0, SrcTile1, ->PredicateGPR` |
| `TNEG` | `VEC` | `TNEG <LB0:ValidCol, LB1:ValidRow?, LB2:Col?, DataType, PadValue?, PEMask>, SrcTile0, ->DstTile<Size>` |
| `TNOT` | `VEC` | `TNOT <LB0:ValidCol, LB1:ValidRow?, LB2:Col?, DataType, PadValue?, PEMask>, SrcTile0, ->DstTile<Size>` |
| `TOR` | `VEC` | `TOR <LB0:ValidCol, LB1:ValidRow?, LB2:Col?, DataType, PadValue?, PEMask>, SrcTile0, SrcTile1, ->DstTile<Size>` |
| `TRELU` | `VEC` | `TRELU <LB0:ValidCol, LB1:ValidRow?, LB2:Col?, DataType, PadValue?, PEMask>, SrcTile0, ->DstTile<Size>` |
| `TSEL` | `VEC` | `TSEL <LB0:ValidCol, LB1:ValidRow=1, LB2:Col=ValidCol, DataType, PadValue=Null, PEMask>, PredicateTile0, SrcTile1, SrcTile2, ->DstTile<Size>`<br>`TSEL <LB0:ValidCol, LB1:ValidRow=1, LB2:Col=ValidCol, DataType, PadValue=Null, PEMask>, PredicateCell0, SrcTile1, SrcTile2, ->DstTile<Size>`<br>`TSEL <LB0:ValidCol, LB1:ValidRow=1, LB2:Col=ValidCol, DataType, PadValue=Null, PEMask>, PredicateGPR0, PredicateGPR1{if DataType=U8}, SrcTile1, SrcTile2, ->DstTile<Size>` |
| `TSHL` | `VEC` | `TSHL <LB0:ValidCol, LB1:ValidRow?, LB2:Col?, DataType, PadValue?, PEMask>, SrcTile0, SrcTile1, ->DstTile<Size>` |
| `TSHR` | `VEC` | `TSHR <LB0:ValidCol, LB1:ValidRow?, LB2:Col?, DataType, PadValue?, PEMask>, SrcTile0, SrcTile1, ->DstTile<Size>` |
| `TXOR` | `VEC` | `TXOR <LB0:ValidCol, LB1:ValidRow?, LB2:Col?, DataType, PadValue?, PEMask>, SrcTile0, SrcTile1, ->DstTile<Size>` |

### elementwise-tile-tile/transcendental

| TileOp | Engine | Canonical macro format |
| --- | --- | --- |
| `TDIV` | `SFU` | `TDIV <LB0:ValidCol, LB1:ValidRow?, LB2:Col?, DataType, PadValue?, PEMask>, SrcTile0, SrcTile1, ->DstTile<Size>` |
| `TEXP` | `SFU` | `TEXP <LB0:ValidCol, LB1:ValidRow?, LB2:Col?, DataType, PadValue?, PEMask>, SrcTile0, ->DstTile<Size>` |
| `TLOG` | `SFU` | `TLOG <LB0:ValidCol, LB1:ValidRow?, LB2:Col?, DataType, PadValue?, PEMask>, SrcTile0, ->DstTile<Size>` |
| `TRECIP` | `SFU` | `TRECIP <LB0:ValidCol, LB1:ValidRow?, LB2:Col?, DataType, PadValue?, PEMask>, SrcTile0, ->DstTile<Size>` |
| `TREM` | `SFU` | `TREM <LB0:ValidCol, LB1:ValidRow?, LB2:Col?, DataType, PadValue?, PEMask>, SrcTile0, SrcTile1, ->DstTile<Size>` |
| `TRSQRT` | `SFU` | `TRSQRT <LB0:ValidCol, LB1:ValidRow?, LB2:Col?, DataType, PadValue?, PEMask>, SrcTile0, ->DstTile<Size>` |
| `TSQRT` | `SFU` | `TSQRT <LB0:ValidCol, LB1:ValidRow?, LB2:Col?, DataType, PadValue?, PEMask>, SrcTile0, ->DstTile<Size>` |

### irregular-and-complex/initialization

| TileOp | Engine | Canonical macro format |
| --- | --- | --- |
| `TCI` | `SFU` | `TCI <LB0:ValidCol, LB1:ValidRow=1, LB2:Col=ValidCol, DataType, PEMask>, Start=0, Direction=ascending, ->DstTile<Size>` |
| `TTRI` | `SFU` | `TTRI <LB0:ValidCol, LB1:ValidRow=1, LB2:Col=ValidCol, DataType, PEMask>, Diagonal=0, Orientation=lower, ->DstTile<Size>` |

### irregular-and-complex/layout

| TileOp | Engine | Canonical macro format |
| --- | --- | --- |
| `TGATHER` | `SFU` | `TGATHER <LB0:ValidCol, LB1:ValidRow?, LB2:Col?, ValueDataType, Layout?, PEMask>, SrcTile0, SrcTile1, ->DstTile<Size>` |
| `TSCATTER` | `SFU` | `TSCATTER <LB0:ValidCol, LB1:ValidRow?, LB2:Col?, ValueDataType, Layout?, PEMask>, SrcTile0, SrcTile1, ->DstTile<Size>` |

### layout-and-rearrangement/layout

| TileOp | Engine | Canonical macro format |
| --- | --- | --- |
| `TGPR2T` | `SFU` | `TGPR2T <LB0:ValidCol, LB1:ValidRow, U8, PadValueOrByteId?, RMode?, PEMask>, ScalarGPR0, ScalarGPR1, ScalarGPR2, ScalarGPR3, ->DstTile<Size>` |
| `TMOV` | `TLSU` | `TMOV <LB0, LB1?, LB2?, DataType, Layout?, PEMask>, SrcTile0, ->DstTile<Size>` |
| `TPACK` | `SFU` | `TPACK <LB0?, LB1?, LB2?, U32, Layout?, PEMask>, SrcTile0, SrcTile1, ScalarGPR0, ->DstTile<Size>` |
| `TPERMUTE` | `SFU` | `TPERMUTE <LB0?, LB1?, LB2?, DataType, Layout?, PEMask>, SrcTile0, SrcTile1, SrcTile2, ->DstTile<Size>` |
| `TSHUF` | `SFU` | `TSHUF <LB0?, LB1?, LB2?, DataType, Layout?, PEMask>, SrcTile0, SrcTile1, ScalarGPR0, ->DstTile<Size>` |
| `TUNPACK` | `SFU` | `TUNPACK <LB0?, LB1?, LB2?, U32, Layout?, PEMask>, SrcTile0, ScalarGPR0, ->DstTile<Size>` |

### matrix-and-matrix-vector/matrix-matrix

| TileOp | Engine | Canonical macro format |
| --- | --- | --- |
| `TMATMUL` | `CUBE` | `TMATMUL <LB0:M=1, LB1:N=1, LB2:K=1, AType, BType?, RMode?, Sat?, FPAttrs, PEMask>, SrcTile0, SrcTile1, RowMaxIn{if RowMaxEn&&RowMaxInit}, QuantParamTile{if PreQuantMode=vector}, ReluParamTile{if ReluMode=vector}, QuantParamGPR{if PreQuantMode=scalar}, ReluParamGPR{if ReluMode=scalar}, ->DstTile<Size>, ->RowMaxOut<Size>{if RowMaxEn}, ->GroupMaxOut<Size>{if GroupMaxEn}`<br>`TMATMUL.SHARED_RIGHT <LB0:M=1, LB1:N=1, LB2:K=1, AType, BType?, RMode?, Sat?, FPAttrs, PEMask{must be 1111}>, LocalLeftGroup, SharedRightGroup, RowMaxIn{if RowMaxEn&&RowMaxInit}, QuantParamTile{if PreQuantMode=vector}, ReluParamTile{if ReluMode=vector}, QuantParamGPR{if PreQuantMode=scalar}, ReluParamGPR{if ReluMode=scalar}, ->DstTile<Size>, ->RowMaxOut<Size>{if RowMaxEn}, ->GroupMaxOut<Size>{if GroupMaxEn}`<br>`TMATMUL.SHARED_BOTH <LB0:M=1, LB1:N=1, LB2:K=1, AType, BType?, RMode?, Sat?, FPAttrs, PEMask{must be 1111}>, SharedLeftGroup, SharedRightGroup, RowMaxIn{if RowMaxEn&&RowMaxInit}, QuantParamTile{if PreQuantMode=vector}, ReluParamTile{if ReluMode=vector}, QuantParamGPR{if PreQuantMode=scalar}, ReluParamGPR{if ReluMode=scalar}, ->DstTile<Size>, ->RowMaxOut<Size>{if RowMaxEn}, ->GroupMaxOut<Size>{if GroupMaxEn}` |
| `TMATMUL_ACC` | `CUBE` | `TMATMUL_ACC <LB0:M=1, LB1:N=1, LB2:K=1, AType, BType?, RMode?, Sat?, FPAttrs, PEMask>, AccTile, SrcTile0, SrcTile1, CScaleTile{if CScaleEn}, RowMaxIn{if RowMaxEn&&RowMaxInit}, QuantParamTile{if PreQuantMode=vector}, ReluParamTile{if ReluMode=vector}, QuantParamGPR{if PreQuantMode=scalar}, ReluParamGPR{if ReluMode=scalar}, ->DstTile<Size>, ->RowMaxOut<Size>{if RowMaxEn}, ->GroupMaxOut<Size>{if GroupMaxEn}`<br>`TMATMUL_ACC.SHARED_RIGHT <LB0:M=1, LB1:N=1, LB2:K=1, AType, BType?, RMode?, Sat?, FPAttrs, PEMask{must be 1111}>, AccTile, LocalLeftGroup, SharedRightGroup, CScaleTile{if CScaleEn}, RowMaxIn{if RowMaxEn&&RowMaxInit}, QuantParamTile{if PreQuantMode=vector}, ReluParamTile{if ReluMode=vector}, QuantParamGPR{if PreQuantMode=scalar}, ReluParamGPR{if ReluMode=scalar}, ->DstTile<Size>, ->RowMaxOut<Size>{if RowMaxEn}, ->GroupMaxOut<Size>{if GroupMaxEn}`<br>`TMATMUL_ACC.SHARED_BOTH <LB0:M=1, LB1:N=1, LB2:K=1, AType, BType?, RMode?, Sat?, FPAttrs, PEMask{must be 1111}>, AccTile, SharedLeftGroup, SharedRightGroup, CScaleTile{if CScaleEn}, RowMaxIn{if RowMaxEn&&RowMaxInit}, QuantParamTile{if PreQuantMode=vector}, ReluParamTile{if ReluMode=vector}, QuantParamGPR{if PreQuantMode=scalar}, ReluParamGPR{if ReluMode=scalar}, ->DstTile<Size>, ->RowMaxOut<Size>{if RowMaxEn}, ->GroupMaxOut<Size>{if GroupMaxEn}` |
| `TMATMUL_BIAS` | `CUBE` | `TMATMUL_BIAS <LB0:M=1, LB1:N=1, LB2:K=1, AType, BType?, RMode?, Sat?, FPAttrs, PEMask>, SrcTile0, SrcTile1, BiasTile, RowMaxIn{if RowMaxEn&&RowMaxInit}, QuantParamTile{if PreQuantMode=vector}, ReluParamTile{if ReluMode=vector}, QuantParamGPR{if PreQuantMode=scalar}, ReluParamGPR{if ReluMode=scalar}, ->DstTile<Size>, ->RowMaxOut<Size>{if RowMaxEn}, ->GroupMaxOut<Size>{if GroupMaxEn}`<br>`TMATMUL_BIAS.SHARED_RIGHT <LB0:M=1, LB1:N=1, LB2:K=1, AType, BType?, RMode?, Sat?, FPAttrs, PEMask{must be 1111}>, LocalLeftGroup, SharedRightGroup, BiasTile, RowMaxIn{if RowMaxEn&&RowMaxInit}, QuantParamTile{if PreQuantMode=vector}, ReluParamTile{if ReluMode=vector}, QuantParamGPR{if PreQuantMode=scalar}, ReluParamGPR{if ReluMode=scalar}, ->DstTile<Size>, ->RowMaxOut<Size>{if RowMaxEn}, ->GroupMaxOut<Size>{if GroupMaxEn}`<br>`TMATMUL_BIAS.SHARED_BOTH <LB0:M=1, LB1:N=1, LB2:K=1, AType, BType?, RMode?, Sat?, FPAttrs, PEMask{must be 1111}>, SharedLeftGroup, SharedRightGroup, BiasTile, RowMaxIn{if RowMaxEn&&RowMaxInit}, QuantParamTile{if PreQuantMode=vector}, ReluParamTile{if ReluMode=vector}, QuantParamGPR{if PreQuantMode=scalar}, ReluParamGPR{if ReluMode=scalar}, ->DstTile<Size>, ->RowMaxOut<Size>{if RowMaxEn}, ->GroupMaxOut<Size>{if GroupMaxEn}` |
| `TMATMUL_MX` | `CUBE` | `TMATMUL_MX <LB0:M=1, LB1:N=1, LB2:K=1, AType, BType?, RMode?, Sat?, FPAttrs, PEMask>, SrcTile0, RowScaleTile{if AType requires MX scale}, SrcTile1, ColumnScaleTile{if BType requires MX scale}, RowMaxIn{if RowMaxEn&&RowMaxInit}, QuantParamTile{if PreQuantMode=vector}, ReluParamTile{if ReluMode=vector}, QuantParamGPR{if PreQuantMode=scalar}, ReluParamGPR{if ReluMode=scalar}, ->DstTile<Size>, ->RowMaxOut<Size>{if RowMaxEn}, ->GroupMaxOut<Size>{if GroupMaxEn}`<br>`TMATMUL_MX.SHARED_RIGHT <LB0:M=1, LB1:N=1, LB2:K=1, AType, BType?, RMode?, Sat?, FPAttrs, PEMask{must be 1111}>, LocalLeftGroup, SharedRightGroup, RowMaxIn{if RowMaxEn&&RowMaxInit}, QuantParamTile{if PreQuantMode=vector}, ReluParamTile{if ReluMode=vector}, QuantParamGPR{if PreQuantMode=scalar}, ReluParamGPR{if ReluMode=scalar}, ->DstTile<Size>, ->RowMaxOut<Size>{if RowMaxEn}, ->GroupMaxOut<Size>{if GroupMaxEn}`<br>`TMATMUL_MX.SHARED_BOTH <LB0:M=1, LB1:N=1, LB2:K=1, AType, BType?, RMode?, Sat?, FPAttrs, PEMask{must be 1111}>, SharedLeftGroup, SharedRightGroup, RowMaxIn{if RowMaxEn&&RowMaxInit}, QuantParamTile{if PreQuantMode=vector}, ReluParamTile{if ReluMode=vector}, QuantParamGPR{if PreQuantMode=scalar}, ReluParamGPR{if ReluMode=scalar}, ->DstTile<Size>, ->RowMaxOut<Size>{if RowMaxEn}, ->GroupMaxOut<Size>{if GroupMaxEn}` |
| `TMATMUL_MX_ACC` | `CUBE` | `TMATMUL_MX_ACC <LB0:M=1, LB1:N=1, LB2:K=1, AType, BType?, RMode?, Sat?, FPAttrs, PEMask>, AccTile, SrcTile0, RowScaleTile{if AType requires MX scale}, SrcTile1, ColumnScaleTile{if BType requires MX scale}, CScaleTile{if CScaleEn}, RowMaxIn{if RowMaxEn&&RowMaxInit}, QuantParamTile{if PreQuantMode=vector}, ReluParamTile{if ReluMode=vector}, QuantParamGPR{if PreQuantMode=scalar}, ReluParamGPR{if ReluMode=scalar}, ->DstTile<Size>, ->RowMaxOut<Size>{if RowMaxEn}, ->GroupMaxOut<Size>{if GroupMaxEn}`<br>`TMATMUL_MX_ACC.SHARED_RIGHT <LB0:M=1, LB1:N=1, LB2:K=1, AType, BType?, RMode?, Sat?, FPAttrs, PEMask{must be 1111}>, AccTile, LocalLeftGroup, SharedRightGroup, CScaleTile{if CScaleEn}, RowMaxIn{if RowMaxEn&&RowMaxInit}, QuantParamTile{if PreQuantMode=vector}, ReluParamTile{if ReluMode=vector}, QuantParamGPR{if PreQuantMode=scalar}, ReluParamGPR{if ReluMode=scalar}, ->DstTile<Size>, ->RowMaxOut<Size>{if RowMaxEn}, ->GroupMaxOut<Size>{if GroupMaxEn}`<br>`TMATMUL_MX_ACC.SHARED_BOTH <LB0:M=1, LB1:N=1, LB2:K=1, AType, BType?, RMode?, Sat?, FPAttrs, PEMask{must be 1111}>, AccTile, SharedLeftGroup, SharedRightGroup, CScaleTile{if CScaleEn}, RowMaxIn{if RowMaxEn&&RowMaxInit}, QuantParamTile{if PreQuantMode=vector}, ReluParamTile{if ReluMode=vector}, QuantParamGPR{if PreQuantMode=scalar}, ReluParamGPR{if ReluMode=scalar}, ->DstTile<Size>, ->RowMaxOut<Size>{if RowMaxEn}, ->GroupMaxOut<Size>{if GroupMaxEn}` |
| `TMATMUL_MX_BIAS` | `CUBE` | `TMATMUL_MX_BIAS <LB0:M=1, LB1:N=1, LB2:K=1, AType, BType?, RMode?, Sat?, FPAttrs, PEMask>, SrcTile0, RowScaleTile{if AType requires MX scale}, SrcTile1, ColumnScaleTile{if BType requires MX scale}, BiasTile, RowMaxIn{if RowMaxEn&&RowMaxInit}, QuantParamTile{if PreQuantMode=vector}, ReluParamTile{if ReluMode=vector}, QuantParamGPR{if PreQuantMode=scalar}, ReluParamGPR{if ReluMode=scalar}, ->DstTile<Size>, ->RowMaxOut<Size>{if RowMaxEn}, ->GroupMaxOut<Size>{if GroupMaxEn}`<br>`TMATMUL_MX_BIAS.SHARED_RIGHT <LB0:M=1, LB1:N=1, LB2:K=1, AType, BType?, RMode?, Sat?, FPAttrs, PEMask{must be 1111}>, LocalLeftGroup, SharedRightGroup, BiasTile, RowMaxIn{if RowMaxEn&&RowMaxInit}, QuantParamTile{if PreQuantMode=vector}, ReluParamTile{if ReluMode=vector}, QuantParamGPR{if PreQuantMode=scalar}, ReluParamGPR{if ReluMode=scalar}, ->DstTile<Size>, ->RowMaxOut<Size>{if RowMaxEn}, ->GroupMaxOut<Size>{if GroupMaxEn}`<br>`TMATMUL_MX_BIAS.SHARED_BOTH <LB0:M=1, LB1:N=1, LB2:K=1, AType, BType?, RMode?, Sat?, FPAttrs, PEMask{must be 1111}>, SharedLeftGroup, SharedRightGroup, BiasTile, RowMaxIn{if RowMaxEn&&RowMaxInit}, QuantParamTile{if PreQuantMode=vector}, ReluParamTile{if ReluMode=vector}, QuantParamGPR{if PreQuantMode=scalar}, ReluParamGPR{if ReluMode=scalar}, ->DstTile<Size>, ->RowMaxOut<Size>{if RowMaxEn}, ->GroupMaxOut<Size>{if GroupMaxEn}` |

### matrix-and-matrix-vector/matrix-vector

| TileOp | Engine | Canonical macro format |
| --- | --- | --- |
| `TGEMV` | `CUBE` | `TGEMV <LB0:M=1, LB1:N=1, LB2:K=1, AType, BType?, RMode?, Sat?, FPAttrs, PEMask>, SrcVector, SrcMatrix, RowMaxIn{if RowMaxEn&&RowMaxInit}, QuantParamTile{if PreQuantMode=vector}, ReluParamTile{if ReluMode=vector}, QuantParamGPR{if PreQuantMode=scalar}, ReluParamGPR{if ReluMode=scalar}, ->DstTile<Size>, ->RowMaxOut<Size>{if RowMaxEn}, ->GroupMaxOut<Size>{if GroupMaxEn}` |
| `TGEMV_ACC` | `CUBE` | `TGEMV_ACC <LB0:M=1, LB1:N=1, LB2:K=1, AType, BType?, RMode?, Sat?, FPAttrs, PEMask>, AccTile, SrcVector, SrcMatrix, RowMaxIn{if RowMaxEn&&RowMaxInit}, QuantParamTile{if PreQuantMode=vector}, ReluParamTile{if ReluMode=vector}, QuantParamGPR{if PreQuantMode=scalar}, ReluParamGPR{if ReluMode=scalar}, ->DstTile<Size>, ->RowMaxOut<Size>{if RowMaxEn}, ->GroupMaxOut<Size>{if GroupMaxEn}` |
| `TGEMV_BIAS` | `CUBE` | `TGEMV_BIAS <LB0:M=1, LB1:N=1, LB2:K=1, AType, BType?, RMode?, Sat?, FPAttrs, PEMask>, SrcVector, SrcMatrix, BiasTile, RowMaxIn{if RowMaxEn&&RowMaxInit}, QuantParamTile{if PreQuantMode=vector}, ReluParamTile{if ReluMode=vector}, QuantParamGPR{if PreQuantMode=scalar}, ReluParamGPR{if ReluMode=scalar}, ->DstTile<Size>, ->RowMaxOut<Size>{if RowMaxEn}, ->GroupMaxOut<Size>{if GroupMaxEn}` |
| `TGEMV_MX` | `CUBE` | `TGEMV_MX <LB0:M=1, LB1:N=1, LB2:K=1, AType, BType?, RMode?, Sat?, FPAttrs, PEMask>, SrcVector, RowScaleTile{if AType requires MX scale}, SrcMatrix, ColumnScaleTile{if BType requires MX scale}, RowMaxIn{if RowMaxEn&&RowMaxInit}, QuantParamTile{if PreQuantMode=vector}, ReluParamTile{if ReluMode=vector}, QuantParamGPR{if PreQuantMode=scalar}, ReluParamGPR{if ReluMode=scalar}, ->DstTile<Size>, ->RowMaxOut<Size>{if RowMaxEn}, ->GroupMaxOut<Size>{if GroupMaxEn}` |
| `TGEMV_MX_ACC` | `CUBE` | `TGEMV_MX_ACC <LB0:M=1, LB1:N=1, LB2:K=1, AType, BType?, RMode?, Sat?, FPAttrs, PEMask>, AccTile, SrcVector, RowScaleTile{if AType requires MX scale}, SrcMatrix, ColumnScaleTile{if BType requires MX scale}, RowMaxIn{if RowMaxEn&&RowMaxInit}, QuantParamTile{if PreQuantMode=vector}, ReluParamTile{if ReluMode=vector}, QuantParamGPR{if PreQuantMode=scalar}, ReluParamGPR{if ReluMode=scalar}, ->DstTile<Size>, ->RowMaxOut<Size>{if RowMaxEn}, ->GroupMaxOut<Size>{if GroupMaxEn}` |
| `TGEMV_MX_BIAS` | `CUBE` | `TGEMV_MX_BIAS <LB0:M=1, LB1:N=1, LB2:K=1, AType, BType?, RMode?, Sat?, FPAttrs, PEMask>, SrcVector, RowScaleTile{if AType requires MX scale}, SrcMatrix, ColumnScaleTile{if BType requires MX scale}, BiasTile, RowMaxIn{if RowMaxEn&&RowMaxInit}, QuantParamTile{if PreQuantMode=vector}, ReluParamTile{if ReluMode=vector}, QuantParamGPR{if PreQuantMode=scalar}, ReluParamGPR{if ReluMode=scalar}, ->DstTile<Size>, ->RowMaxOut<Size>{if RowMaxEn}, ->GroupMaxOut<Size>{if GroupMaxEn}` |

### memory-and-data-movement/irregular

| TileOp | Engine | Canonical macro format |
| --- | --- | --- |
| `MGATHER` | `TLSU` | `MGATHER <LB0:ValidCol, LB1:ValidRow?, LB2:Col?, DataType, PadValue?, Layout?, PEMask>, [BaseGPR], RowStrideGPR, SrcTile0, ->DstTile<Size>` |
| `MGATHER_ADD` | `TLSU` | `MGATHER_ADD <DataType, PEMask>, [BaseGPR], SrcTile0, SrcTile1, ->DstTile<Size>` |
| `MGATHER_AND` | `TLSU` | `MGATHER_AND <DataType, PEMask>, [BaseGPR], SrcTile0, SrcTile1, ->DstTile<Size>` |
| `MGATHER_CAS` | `TLSU` | `MGATHER_CAS <DataType, PEMask>, [BaseGPR], RowStrideGPR, SrcTile0, SrcTile1, SrcTile2, ->DstTile<Size>` |
| `MGATHER_DEC` | `TLSU` | `MGATHER_DEC <DataType, PEMask>, [BaseGPR], SrcTile0, SrcTile1, ->DstTile<Size>` |
| `MGATHER_EXCH` | `TLSU` | `MGATHER_EXCH <DataType, PEMask>, [BaseGPR], SrcTile0, SrcTile1, ->DstTile<Size>` |
| `MGATHER_INC` | `TLSU` | `MGATHER_INC <DataType, PEMask>, [BaseGPR], SrcTile0, SrcTile1, ->DstTile<Size>` |
| `MGATHER_MASK` | `TLSU` | `MGATHER_MASK <LB0:ValidCol, LB1:ValidRow?, LB2:Col?, DataType, PadValue?, Layout?, PEMask>, [BaseGPR], RowStrideGPR, SrcTile0, PredicateTile1, ->DstTile<Size>` |
| `MGATHER_MAX` | `TLSU` | `MGATHER_MAX <DataType, PEMask>, [BaseGPR], SrcTile0, SrcTile1, ->DstTile<Size>` |
| `MGATHER_MIN` | `TLSU` | `MGATHER_MIN <DataType, PEMask>, [BaseGPR], SrcTile0, SrcTile1, ->DstTile<Size>` |
| `MGATHER_OR` | `TLSU` | `MGATHER_OR <DataType, PEMask>, [BaseGPR], SrcTile0, SrcTile1, ->DstTile<Size>` |
| `MGATHER_XOR` | `TLSU` | `MGATHER_XOR <DataType, PEMask>, [BaseGPR], SrcTile0, SrcTile1, ->DstTile<Size>` |
| `MSCATTER` | `TLSU` | `MSCATTER <LB0:ValidCol, LB1:ValidRow?, LB2:Col?, DataType, Layout?, PEMask>, [BaseGPR], RowStrideGPR, SrcTile0, SrcTile1` |
| `MSCATTER_ADD` | `TLSU` | `MSCATTER_ADD <DataType, PEMask>, [BaseGPR], SrcTile0, SrcTile1` |
| `MSCATTER_AND` | `TLSU` | `MSCATTER_AND <DataType, PEMask>, [BaseGPR], SrcTile0, SrcTile1` |
| `MSCATTER_DEC` | `TLSU` | `MSCATTER_DEC <DataType, PEMask>, [BaseGPR], SrcTile0, SrcTile1` |
| `MSCATTER_INC` | `TLSU` | `MSCATTER_INC <DataType, PEMask>, [BaseGPR], SrcTile0, SrcTile1` |
| `MSCATTER_MASK` | `TLSU` | `MSCATTER_MASK <LB0:ValidCol, LB1:ValidRow?, LB2:Col?, DataType, Layout?, PEMask>, [BaseGPR], RowStrideGPR, SrcTile0, SrcTile1, PredicateTile2` |
| `MSCATTER_MAX` | `TLSU` | `MSCATTER_MAX <DataType, PEMask>, [BaseGPR], SrcTile0, SrcTile1` |
| `MSCATTER_MIN` | `TLSU` | `MSCATTER_MIN <DataType, PEMask>, [BaseGPR], SrcTile0, SrcTile1` |
| `MSCATTER_OR` | `TLSU` | `MSCATTER_OR <DataType, PEMask>, [BaseGPR], SrcTile0, SrcTile1` |
| `MSCATTER_POPC` | `TLSU` | `MSCATTER_POPC <LB0:ValidCol, DataType, PEMask>, [BaseGPR], SrcTile0` |
| `MSCATTER_XOR` | `TLSU` | `MSCATTER_XOR <DataType, PEMask>, [BaseGPR], SrcTile0, SrcTile1` |

### memory-and-data-movement/pe-movement

| TileOp | Engine | Canonical macro format |
| --- | --- | --- |
| `GMOV` | `TLSU` | `GMOV <DataType, Layout?, PEMask>, SrcTile0, PeerTid?, ->DstTile<Size>` |

### memory-and-data-movement/regular

| TileOp | Engine | Canonical macro format |
| --- | --- | --- |
| `TLOAD` | `TLSU` | `TLOAD <LB0:ValidCol?, LB1:ValidRow?, LB2:Col=ValidCol, DataType, Layout?, PEMask>, [BaseGPR=zero, RowStrideGPR?], ->DstTile<Size>`<br>`TLOAD.SHARED <LB0:ValidCol?, LB1:ValidRow?, LB2:Col=ValidCol, DataType, Layout?, PEMask>, [BaseGPR=zero, RowStrideGPR?], ->DstShared<Size>`<br>`TLOAD.CUBE <LB0:ValidCol, LB1:ValidRow, CubeLayout, DTYPE_NONE, PadValue, PEMask>, [BaseGPR=zero, RowStrideGPR?], ->DstTile<Size>`<br>`TLOAD.WEIGHT <LB0:ValidK, LB1:ValidN, LB2:TotalK, DataType, WeightLayout{must be OHWI2NK or OIHW2NK}, PEMask>, [GMBaseGPR, ShapeGPR, StartGPR], ->DstShared<Size>` |
| `TPREFETCH` | `TLSU` | `TPREFETCH <LB0:ValidCol=1, LB1:ValidRow=1, LB2:Col=ValidCol, DataType, Layout?>, [BaseGPR=zero, RowStrideGPR?]` |
| `TSTORE` | `TLSU` | `TSTORE <LB0:ValidCol=SourceDescriptor, LB1:ValidRow=SourceDescriptor, LB2:Col=SourceDescriptor, DataType, Layout?, PEMask>, SrcTile, [BaseGPR=zero, RowStrideGPR?]`<br>`TSTORE.SHARED <LB0:ValidCol=SourceOr1, LB1:ValidRow=SourceOr1, LB2:Col=SourceOrValidCol, DataType, Layout?, PEMask>, SrcShared, [BaseGPR=zero, RowStrideGPR?]`<br>`TSTORE.CUBE <LB0:ValidCol, LB1:ValidRow, CubeLayout, DTYPE_NONE, PadValue, PEMask>, SrcTile, [BaseGPR=zero, RowStrideGPR?]` |

### reduce-and-expand/column-expansion

| TileOp | Engine | Canonical macro format |
| --- | --- | --- |
| `TCOLEXPAND` | `SFU` | `TCOLEXPAND <LB0:ValidCol, LB1:ValidRow?, LB2:Col?, DataType, Layout?, PadValue?, PEMask>, SrcTile0, ->DstTile<Size>` |
| `TCOLEXPANDADD` | `SFU` | `TCOLEXPANDADD <LB0:ValidCol, LB1:ValidRow?, LB2:Col?, DataType, Layout?, PadValue?, PEMask>, SrcTile0, SrcTile1, ->DstTile<Size>` |
| `TCOLEXPANDDIV` | `SFU` | `TCOLEXPANDDIV <LB0:ValidCol, LB1:ValidRow?, LB2:Col?, DataType, Layout?, PadValue?, PEMask>, SrcTile0, SrcTile1, ->DstTile<Size>` |
| `TCOLEXPANDEXPDIF` | `SFU` | `TCOLEXPANDEXPDIF <LB0:ValidCol, LB1:ValidRow?, LB2:Col?, DataType, Layout?, PadValue?, PEMask>, SrcTile0, SrcTile1, ->DstTile<Size>` |
| `TCOLEXPANDMAX` | `SFU` | `TCOLEXPANDMAX <LB0:ValidCol, LB1:ValidRow?, LB2:Col?, DataType, Layout?, PadValue?, PEMask>, SrcTile0, SrcTile1, ->DstTile<Size>` |
| `TCOLEXPANDMIN` | `SFU` | `TCOLEXPANDMIN <LB0:ValidCol, LB1:ValidRow?, LB2:Col?, DataType, Layout?, PadValue?, PEMask>, SrcTile0, SrcTile1, ->DstTile<Size>` |
| `TCOLEXPANDMUL` | `SFU` | `TCOLEXPANDMUL <LB0:ValidCol, LB1:ValidRow?, LB2:Col?, DataType, Layout?, PadValue?, PEMask>, SrcTile0, SrcTile1, ->DstTile<Size>` |
| `TCOLEXPANDSUB` | `SFU` | `TCOLEXPANDSUB <LB0:ValidCol, LB1:ValidRow?, LB2:Col?, DataType, Layout?, PadValue?, PEMask>, SrcTile0, SrcTile1, ->DstTile<Size>` |

### reduce-and-expand/column-reduction

| TileOp | Engine | Canonical macro format |
| --- | --- | --- |
| `TCOLARGMAX` | `SFU` | `TCOLARGMAX <LB0:ValidCol, LB1:ValidRow?, LB2:Col?, DataType, Layout?, PadValue?, PEMask>, SrcTile0, ->DstTile<Size>` |
| `TCOLARGMIN` | `SFU` | `TCOLARGMIN <LB0:ValidCol, LB1:ValidRow?, LB2:Col?, DataType, Layout?, PadValue?, PEMask>, SrcTile0, ->DstTile<Size>` |
| `TCOLMAX` | `SFU` | `TCOLMAX <LB0:ValidCol, LB1:ValidRow?, LB2:Col?, DataType, Layout?, PadValue?, PEMask>, SrcTile0, ->DstTile<Size>` |
| `TCOLMIN` | `SFU` | `TCOLMIN <LB0:ValidCol, LB1:ValidRow?, LB2:Col?, DataType, Layout?, PadValue?, PEMask>, SrcTile0, ->DstTile<Size>` |
| `TCOLPROD` | `SFU` | `TCOLPROD <LB0:ValidCol, LB1:ValidRow?, LB2:Col?, DataType, Layout?, PadValue?, PEMask>, SrcTile0, ->DstTile<Size>` |
| `TCOLSUM` | `SFU` | `TCOLSUM <LB0:ValidCol, LB1:ValidRow?, LB2:Col?, DataType, Layout?, PadValue?, PEMask>, SrcTile0, ->DstTile<Size>` |

### reduce-and-expand/row-expansion

| TileOp | Engine | Canonical macro format |
| --- | --- | --- |
| `TROWEXPAND` | `SFU` | `TROWEXPAND <LB0:ValidCol, LB1:ValidRow?, LB2:Col?, DataType, Layout?, PadValue?, PEMask>, SrcTile0, ->DstTile<Size>` |
| `TROWEXPANDADD` | `SFU` | `TROWEXPANDADD <LB0:ValidCol, LB1:ValidRow?, LB2:Col?, DataType, Layout?, PadValue?, PEMask>, SrcTile0, SrcTile1, ->DstTile<Size>` |
| `TROWEXPANDDIV` | `SFU` | `TROWEXPANDDIV <LB0:ValidCol, LB1:ValidRow?, LB2:Col?, DataType, Layout?, PadValue?, PEMask>, SrcTile0, SrcTile1, ->DstTile<Size>` |
| `TROWEXPANDEXPDIF` | `SFU` | `TROWEXPANDEXPDIF <LB0:ValidCol, LB1:ValidRow?, LB2:Col?, DataType, Layout?, PadValue?, PEMask>, SrcTile0, SrcTile1, ->DstTile<Size>` |
| `TROWEXPANDMAX` | `SFU` | `TROWEXPANDMAX <LB0:ValidCol, LB1:ValidRow?, LB2:Col?, DataType, Layout?, PadValue?, PEMask>, SrcTile0, SrcTile1, ->DstTile<Size>` |
| `TROWEXPANDMIN` | `SFU` | `TROWEXPANDMIN <LB0:ValidCol, LB1:ValidRow?, LB2:Col?, DataType, Layout?, PadValue?, PEMask>, SrcTile0, SrcTile1, ->DstTile<Size>` |
| `TROWEXPANDMUL` | `SFU` | `TROWEXPANDMUL <LB0:ValidCol, LB1:ValidRow?, LB2:Col?, DataType, Layout?, PadValue?, PEMask>, SrcTile0, SrcTile1, ->DstTile<Size>` |
| `TROWEXPANDSUB` | `SFU` | `TROWEXPANDSUB <LB0:ValidCol, LB1:ValidRow?, LB2:Col?, DataType, Layout?, PadValue?, PEMask>, SrcTile0, SrcTile1, ->DstTile<Size>` |

### reduce-and-expand/row-reduction

| TileOp | Engine | Canonical macro format |
| --- | --- | --- |
| `TROWARGMAX` | `SFU` | `TROWARGMAX <LB0:ValidCol, LB1:ValidRow?, LB2:Col?, DataType, Layout?, PadValue?, PEMask>, SrcTile0, ->DstTile<Size>` |
| `TROWARGMIN` | `SFU` | `TROWARGMIN <LB0:ValidCol, LB1:ValidRow?, LB2:Col?, DataType, Layout?, PadValue?, PEMask>, SrcTile0, ->DstTile<Size>` |
| `TROWMAX` | `SFU` | `TROWMAX <LB0:ValidCol, LB1:ValidRow?, LB2:Col?, DataType, Layout?, PadValue?, PEMask>, SrcTile0, ->DstTile<Size>` |
| `TROWMIN` | `SFU` | `TROWMIN <LB0:ValidCol, LB1:ValidRow?, LB2:Col?, DataType, Layout?, PadValue?, PEMask>, SrcTile0, ->DstTile<Size>` |
| `TROWPROD` | `SFU` | `TROWPROD <LB0:ValidCol, LB1:ValidRow?, LB2:Col?, DataType, Layout?, PadValue?, PEMask>, SrcTile0, ->DstTile<Size>` |
| `TROWSUM` | `SFU` | `TROWSUM <LB0:ValidCol, LB1:ValidRow?, LB2:Col?, DataType, Layout?, PadValue?, PEMask>, SrcTile0, ->DstTile<Size>` |

### tile-scalar-and-immediate/arithmetic

| TileOp | Engine | Canonical macro format |
| --- | --- | --- |
| `TADDS` | `VEC` | `TADDS <LB0:ValidCol, LB1:ValidRow?, LB2:Col?, DataType, PadValue?, PEMask>, SrcTile0, ScalarGPR0?, ->DstTile<Size>` |
| `TDIVS` | `SFU` | `TDIVS <LB0:ValidCol, LB1:ValidRow?, LB2:Col?, DataType, PadValue?, PEMask>, SrcTile0, ScalarGPR0?, ->DstTile<Size>` |
| `TMAXS` | `VEC` | `TMAXS <LB0:ValidCol, LB1:ValidRow?, LB2:Col?, DataType, PadValue?, PEMask>, SrcTile0, ScalarGPR0?, ->DstTile<Size>` |
| `TMINS` | `VEC` | `TMINS <LB0:ValidCol, LB1:ValidRow?, LB2:Col?, DataType, PadValue?, PEMask>, SrcTile0, ScalarGPR0?, ->DstTile<Size>` |
| `TMULS` | `VEC` | `TMULS <LB0:ValidCol, LB1:ValidRow?, LB2:Col?, DataType, PadValue?, PEMask>, SrcTile0, ScalarGPR0?, ->DstTile<Size>` |
| `TREMS` | `SFU` | `TREMS <LB0:ValidCol, LB1:ValidRow?, LB2:Col?, DataType, PadValue?, PEMask>, SrcTile0, ScalarGPR0?, ->DstTile<Size>` |
| `TSUBS` | `VEC` | `TSUBS <LB0:ValidCol, LB1:ValidRow?, LB2:Col?, DataType, PadValue?, PEMask>, SrcTile0, ScalarGPR0?, ->DstTile<Size>` |

### tile-scalar-and-immediate/initialization

| TileOp | Engine | Canonical macro format |
| --- | --- | --- |
| `TEXPANDS` | `VEC` | `TEXPANDS <LB0:ValidCol, LB1:ValidRow?, LB2:Col?, DataType, Layout?, PadValue?, PEMask>, ScalarGPR0?, ->DstTile<Size>` |

### tile-scalar-and-immediate/logical

| TileOp | Engine | Canonical macro format |
| --- | --- | --- |
| `TANDS` | `VEC` | `TANDS <LB0:ValidCol, LB1:ValidRow?, LB2:Col?, DataType, PadValue?, PEMask>, SrcTile0, ScalarGPR0?, ->DstTile<Size>` |
| `TCMPS` | `VEC` | `TCMPS <LB0:ValidCol, LB1:ValidRow=1, LB2:Col=ValidCol, DataType, CMode=EQ, PadValue=Null, PEMask>, SrcTile0, ScalarGPR0=zero, ->PredicateTile<Size>`<br>`TCMPS <LB0:ValidCol, LB1:ValidRow=1, LB2:Col=ValidCol, DataType, CMode=EQ, PadValue=Null, PEMask>, SrcTile0, ScalarGPR0=zero, ->PredicateCell<Size>`<br>`TCMPS <LB0:ValidCol, LB1:ValidRow=1, LB2:Col=ValidCol, DataType, CMode=EQ, PadValue=Null, SatMode?, PEMask>, SrcTile0, ScalarGPR0=zero, ->PredicateGPR` |
| `TORS` | `VEC` | `TORS <LB0:ValidCol, LB1:ValidRow?, LB2:Col?, DataType, PadValue?, PEMask>, SrcTile0, ScalarGPR0?, ->DstTile<Size>` |
| `TSELS` | `VEC` | `TSELS <LB0:ValidCol, LB1:ValidRow=1, LB2:Col=ValidCol, DataType, PadValue=Null, PEMask>, PredicateTile0, SrcTile1, ScalarFalseGPR=zero, ->DstTile<Size>`<br>`TSELS <LB0:ValidCol, LB1:ValidRow=1, LB2:Col=ValidCol, DataType, PadValue=Null, PEMask>, PredicateCell0, SrcTile1, ScalarFalseGPR=zero, ->DstTile<Size>`<br>`TSELS <LB0:ValidCol, LB1:ValidRow=1, LB2:Col=ValidCol, DataType, PadValue=Null, PEMask>, PredicateGPR0, PredicateGPR1{if DataType=U8}, SrcTile1, ScalarFalseGPR=zero, ->DstTile<Size>` |
| `TSHLS` | `VEC` | `TSHLS <LB0:ValidCol, LB1:ValidRow?, LB2:Col?, DataType, PadValue?, PEMask>, SrcTile0, ScalarGPR0?, ->DstTile<Size>` |
| `TSHRS` | `VEC` | `TSHRS <LB0:ValidCol, LB1:ValidRow?, LB2:Col?, DataType, PadValue?, PEMask>, SrcTile0, ScalarGPR0?, ->DstTile<Size>` |
| `TXORS` | `VEC` | `TXORS <LB0:ValidCol, LB1:ValidRow?, LB2:Col?, DataType, PadValue?, PEMask>, SrcTile0, ScalarGPR0?, ->DstTile<Size>` |

## Physical expansion and disassembly

The JSON catalog records the complete physical `block_composition`, defaults, exceptions, semantic source roles, and destination roles for every row above.
A TileOp assembler expands through that generated schema. A bundle-aware disassembler folds only a unique exact schema match and otherwise prints physical bundle assembly.

## Tool integration boundary

This catalog specifies the PTO 0.58.6 textual contract and deterministic physical expansion. LLVM MC and PTO-AS integration are downstream work tracked from issue 261; they must consume this schema rather than copy its operation table.
Every folded instruction remains one output line. A missing boundary, stale mnemonic, non-canonical command order, unmatched default, or ambiguous form remains physical assembly.

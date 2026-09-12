# PTO TileOp macro assembly

This reference defines the canonical PTO 0.58.6 macro-assembly format for all 117 current direct Tile operations.
It is generated from the `PTO-TILEOP-MACRO` owners in `asl/arch/overview/instruction-classification.asl`; each physical mapping is cross-checked against the operation's owning `PTO-INSTRUCTION` metadata and `spec/catalog/tile-operations.json`.

## Syntax model

```text
TileOp <bundle configuration>, ordered sources, ->ordered destinations
```

- One TileOp macro instruction MUST occupy exactly one source line. A newline terminates the instruction; continuation syntax is not accepted and canonical disassembly never wraps the instruction.
- Rectangular shapes use programmer-facing assignments such as `Row=8` and `Col=64`; matrix shapes use `M`, `N`, and `K`. TileOp source never exposes physical `LB0`, `LB1`, or `LB2` names.
- `Row` resolution: Row has no independent physical encoding and uses the selected form's resolution record: an ordinary row-major numeric destination may derive Row from TSize, Col, and element type; a mixed RowMajor/CUBE form uses that rule only for RowMajor and encoded ValidRow for CUBE; predicate and descriptor-preserving forms require source descriptor state; CUBE-layout TLOAD and TSTORE forms plus TGPR2T use encoded ValidRow; an unrecoverable Row prevents stateless folding.
- Valid-dimension defaults: the selected form's declared default is authoritative. The common rectangular defaults are `ValidRow=Row` and `ValidCol=Col`. canonical assembly omits a Valid field only when it equals the selected form's declared default.
- Irregular memory shape: Every MGATHER and MSCATTER form exposes ValidRow and ValidCol; physical Tile Row/Col are not macro operands, and ValidCol drives both LB0 and the canonical LB2 carrier.
- Descriptor-inherited shape: TPACK and TUNPACK preserve the first source Tile descriptor shape. They have no independently encoded macro shape, so a static object disassembler cannot print concrete Row or Col values without runtime descriptor state.
- Attributes use symbolic enum or string values such as `FP32`, `Null`, and `AllPE`; raw numeric carrier encodings are rejected.
- Canonical disassembly omits every exact selected-form attribute default, including fixed `DTYPE_NONE`, `PadValue=Null`, `PEMask=AllPE`, and zero-valued B.FPATR fields; omission leaves no empty slot or placeholder.
- The assembler binds each bare attribute token through the selected TileOp schema value domain. An unresolved or multiply matching token is rejected rather than assigned by guesswork.
- `?` marks an optional configuration field whose exact default is recorded by the owning instruction contract.
- `.reuse` is not canonical: current `B.IOT` never releases a source.
- Source range syntax: `Source[base=GPR, offset=uimm11]`. Destination range syntax: `->Destination<Size>[base=GPR, offset=uimm11]`. immediately after the owning B.IOT or B.IOS group in source0, source1, destination role order.
- One macro instruction is one Block instruction and maps to one physical BSTART bundle. The next non-modifier Block instruction or end of section closes its command range; source does not add `BSTOP`, `BSTART`, or `C.BSTART`.
- `PEMask` is PE participation and is distinct from an element predicate carrier. It defaults to `AllPE`; other accepted names are `NoPE`, `PE0`, `PE1`, `PE2`, `PE3`, `PE0_1`, and `PE0_1_2`.
- Destinations may be Tile (`->DstTile<Size>`), Shared Tile (`->DstShared<Size>`), scalar through `B.IOR.RegDst` (`->ScalarDst`), legacy predicate Tile (`->PredicateTile<Size>`), CUBE PredicateCell (`->PredicateCell<Size>`), or predicate-mask GPR (`->PredicateGPR`).
- `X?` is optional; `X=value` states the virtual default; `X{if Condition}` is present only when that configuration condition holds.
- `X{must be Value}` is a legality constraint, not an omission default.
- `SourceOr1` and `SourceOrValidCol` mean an allocated Shared source contributes its descriptor value; an unallocated Shared source uses 1 or ValidCol as specified by TSTORE.
- B.FPATR fields are direct entries in the bundle attribute list: enabled booleans use bare names such as `TransposeB`, and valued fields use assignments such as `PreMode=2`; there is no `FPAttrs(...)` wrapper.
- TGEMV-family `M=1` is a mandatory architectural constraint rather than an omission default. Canonical macro assembly prints it, while physical expansion omits the redundant value-one LB0 command.
- Canonical concrete GM address operands expose their physical role: addresses use `[base=a0]` and row strides use `stride=a1`. Ordinary scalar inputs remain bare GPRs such as `a2`, and scalar or predicate-mask results remain `->a3`.
- CUBE conditional operands explicitly name RowMax, GroupMax, quantization, ReLU, and CScale sources or destinations together with their controlling B.FPATR fields.

A concrete macro is always written on one line:

```text
TADD <Row=8, Col=64, FP32>, T#1, T#2, ->T<2KB>
```

A partial Tile retains the differing valid shape and nondefault symbolic values:

```text
TADD <Row=8, Col=64, ValidRow=7, ValidCol=60, FP32, Zero, PE0_1>, T#1, T#2, ->T<2KB>
```

Destination metavariables likewise become physical binding operands. A Local destination names only its encoded `B.IOT.DstTile` hand: for example, `->T<2KB>` publishes a new `T#1`, while `->U<512B>` may publish a legacy packed predicate Tile or a CUBE PredicateCell as the new `U#1` according to the selected TCMP/TCMPS form. `->a0` is a scalar or predicate-mask result carried by `B.IOR.RegDst`. PTO 0.58.6 defines no architectural predicate-register destination for these TileOps.

## Complete format inventory

### elementwise-tile-tile/arithmetic

| TileOp | Engine | Canonical macro format |
| --- | --- | --- |
| `TADD` | `VEC` | `TADD <Row=Derived, Col, ValidRow=Row, ValidCol=Col, DataType, PadValue?, PEMask=AllPE>, SrcTile0, SrcTile1, ->DstTile<Size>` |
| `TFMA` | `VEC` | `TFMA <Row=Derived, Col, ValidRow=Row, ValidCol=Col, DataType, PadValue?, PEMask=AllPE>, SrcTile0, SrcTile1, SrcTile2, ->DstTile<Size>` |
| `TMAX` | `VEC` | `TMAX <Row=Derived, Col, ValidRow=Row, ValidCol=Col, DataType, PadValue?, PEMask=AllPE>, SrcTile0, SrcTile1, ->DstTile<Size>` |
| `TMIN` | `VEC` | `TMIN <Row=Derived, Col, ValidRow=Row, ValidCol=Col, DataType, PadValue?, PEMask=AllPE>, SrcTile0, SrcTile1, ->DstTile<Size>` |
| `TMUL` | `VEC` | `TMUL <Row=Derived, Col, ValidRow=Row, ValidCol=Col, DataType, PadValue?, PEMask=AllPE>, SrcTile0, SrcTile1, ->DstTile<Size>` |
| `TSUB` | `VEC` | `TSUB <Row=Derived, Col, ValidRow=Row, ValidCol=Col, DataType, PadValue?, PEMask=AllPE>, SrcTile0, SrcTile1, ->DstTile<Size>` |

### elementwise-tile-tile/format-conversion

| TileOp | Engine | Canonical macro format |
| --- | --- | --- |
| `TCVT` | `VEC` | `TCVT <Row=Derived, Col, ValidRow=Row, ValidCol=Col, SrcDataType, DstDataType?, RMode?, Sat?, Canonicalize?, Layout?, PadValue?, PEMask=AllPE>, SrcTile0, ->DstTile<Size>` |

### elementwise-tile-tile/logical

| TileOp | Engine | Canonical macro format |
| --- | --- | --- |
| `TABS` | `VEC` | `TABS <Row=Derived, Col, ValidRow=Row, ValidCol=Col, DataType, PadValue?, PEMask=AllPE>, SrcTile0, ->DstTile<Size>` |
| `TAND` | `VEC` | `TAND <Row=Derived, Col, ValidRow=Row, ValidCol=Col, DataType, PadValue?, PEMask=AllPE>, SrcTile0, SrcTile1, ->DstTile<Size>` |
| `TCMP` | `VEC` | `TCMP <Row=Derived, Col, ValidRow=Row, ValidCol=Col, DataType, CMode=EQ, PadValue=Null, PEMask=AllPE>, SrcTile0, SrcTile1, ->PredicateTile<Size>`<br>`TCMP <Row=Derived, Col, ValidRow=Row, ValidCol=Col, DataType, CMode=EQ, PadValue=Null, PEMask=AllPE>, SrcTile0, SrcTile1, ->PredicateCell<Size>`<br>`TCMP <Row=Derived, Col, ValidRow=Row, ValidCol=Col, DataType, CMode=EQ, PadValue=Null, SatMode?, PEMask=AllPE>, SrcTile0, SrcTile1, ->PredicateGPR` |
| `TNEG` | `VEC` | `TNEG <Row=Derived, Col, ValidRow=Row, ValidCol=Col, DataType, PadValue?, PEMask=AllPE>, SrcTile0, ->DstTile<Size>` |
| `TNOT` | `VEC` | `TNOT <Row=Derived, Col, ValidRow=Row, ValidCol=Col, DataType, PadValue?, PEMask=AllPE>, SrcTile0, ->DstTile<Size>` |
| `TOR` | `VEC` | `TOR <Row=Derived, Col, ValidRow=Row, ValidCol=Col, DataType, PadValue?, PEMask=AllPE>, SrcTile0, SrcTile1, ->DstTile<Size>` |
| `TRELU` | `VEC` | `TRELU <Row=Derived, Col, ValidRow=Row, ValidCol=Col, DataType, PadValue?, PEMask=AllPE>, SrcTile0, ->DstTile<Size>` |
| `TSEL` | `VEC` | `TSEL <Row=Derived, Col, ValidRow=Row, ValidCol=Col, DataType, PadValue=Null, PEMask=AllPE>, PredicateTile0, SrcTile1, SrcTile2, ->DstTile<Size>`<br>`TSEL <Row=Derived, Col, ValidRow=Row, ValidCol=Col, DataType, PadValue=Null, PEMask=AllPE>, PredicateCell0, SrcTile1, SrcTile2, ->DstTile<Size>`<br>`TSEL <Row=Derived, Col, ValidRow=Row, ValidCol=Col, DataType, PadValue=Null, PEMask=AllPE>, PredicateGPR0, PredicateGPR1{if DataType=U8}, SrcTile1, SrcTile2, ->DstTile<Size>` |
| `TSHL` | `VEC` | `TSHL <Row=Derived, Col, ValidRow=Row, ValidCol=Col, DataType, PadValue?, PEMask=AllPE>, SrcTile0, SrcTile1, ->DstTile<Size>` |
| `TSHR` | `VEC` | `TSHR <Row=Derived, Col, ValidRow=Row, ValidCol=Col, DataType, PadValue?, PEMask=AllPE>, SrcTile0, SrcTile1, ->DstTile<Size>` |
| `TXOR` | `VEC` | `TXOR <Row=Derived, Col, ValidRow=Row, ValidCol=Col, DataType, PadValue?, PEMask=AllPE>, SrcTile0, SrcTile1, ->DstTile<Size>` |

### elementwise-tile-tile/transcendental

| TileOp | Engine | Canonical macro format |
| --- | --- | --- |
| `TDIV` | `SFU` | `TDIV <Row=Derived, Col, ValidRow=Row, ValidCol=Col, DataType, PadValue?, PEMask=AllPE>, SrcTile0, SrcTile1, ->DstTile<Size>` |
| `TEXP` | `SFU` | `TEXP <Row=Derived, Col, ValidRow=Row, ValidCol=Col, DataType, PadValue?, PEMask=AllPE>, SrcTile0, ->DstTile<Size>` |
| `TLOG` | `SFU` | `TLOG <Row=Derived, Col, ValidRow=Row, ValidCol=Col, DataType, PadValue?, PEMask=AllPE>, SrcTile0, ->DstTile<Size>` |
| `TRECIP` | `SFU` | `TRECIP <Row=Derived, Col, ValidRow=Row, ValidCol=Col, DataType, PadValue?, PEMask=AllPE>, SrcTile0, ->DstTile<Size>` |
| `TREM` | `SFU` | `TREM <Row=Derived, Col, ValidRow=Row, ValidCol=Col, DataType, PadValue?, PEMask=AllPE>, SrcTile0, SrcTile1, ->DstTile<Size>` |
| `TRSQRT` | `SFU` | `TRSQRT <Row=Derived, Col, ValidRow=Row, ValidCol=Col, DataType, PadValue?, PEMask=AllPE>, SrcTile0, ->DstTile<Size>` |
| `TSQRT` | `SFU` | `TSQRT <Row=Derived, Col, ValidRow=Row, ValidCol=Col, DataType, PadValue?, PEMask=AllPE>, SrcTile0, ->DstTile<Size>` |

### irregular-and-complex/initialization

| TileOp | Engine | Canonical macro format |
| --- | --- | --- |
| `TCI` | `SFU` | `TCI <Row=Derived, Col, ValidRow=Row, ValidCol=Col, DataType, PEMask=AllPE>, Start=0, Direction=ascending, ->DstTile<Size>` |
| `TTRI` | `SFU` | `TTRI <Row=Derived, Col, ValidRow=Row, ValidCol=Col, DataType, PEMask=AllPE>, Diagonal=0, Orientation=lower, ->DstTile<Size>` |

### irregular-and-complex/layout

| TileOp | Engine | Canonical macro format |
| --- | --- | --- |
| `TGATHER` | `SFU` | `TGATHER <Row=Derived, Col, ValidRow=Row, ValidCol=Col, ValueDataType, Layout?, PEMask=AllPE>, SrcTile0, SrcTile1, ->DstTile<Size>` |
| `TSCATTER` | `SFU` | `TSCATTER <Row=Derived, Col, ValidRow=Row, ValidCol=Col, ValueDataType, Layout?, PEMask=AllPE>, SrcTile0, SrcTile1, ->DstTile<Size>` |

### layout-and-rearrangement/layout

| TileOp | Engine | Canonical macro format |
| --- | --- | --- |
| `TGPR2T` | `SFU` | `TGPR2T <Row=Derived, Col=DestinationLayout, ValidRow=Row, ValidCol=Col, U8, PadValueOrByteId?, RMode?, PEMask=AllPE>, ScalarGPR0, ScalarGPR1, ScalarGPR2, ScalarGPR3, ->DstTile<Size>` |
| `TMOV` | `TLSU` | `TMOV <DataType, Layout?, PEMask=AllPE>, SrcTile0, ->DstTile<Size>` |
| `TPACK` | `SFU` | `TPACK <U32, Layout?, PEMask=AllPE>, SrcTile0, SrcTile1, ScalarGPR0, ->DstTile<Size>` |
| `TPERMUTE` | `SFU` | `TPERMUTE <DataType, Layout?, PEMask=AllPE>, SrcTile0, SrcTile1, SrcTile2, ->DstTile<Size>` |
| `TSHUF` | `SFU` | `TSHUF <DataType, Layout?, PEMask=AllPE>, SrcTile0, SrcTile1, ScalarGPR0, ->DstTile<Size>` |
| `TUNPACK` | `SFU` | `TUNPACK <U32, Layout?, PEMask=AllPE>, SrcTile0, ScalarGPR0, ->DstTile<Size>` |

### matrix-and-matrix-vector/matrix-matrix

| TileOp | Engine | Canonical macro format |
| --- | --- | --- |
| `TMATMUL` | `CUBE` | `TMATMUL <M=1, N=1, K=1, AType, BType?, RMode?, Sat?, PreMode=0, PostMode=0, PostScale=0, RowMax=0, GroupMax=0, RowMaxInit=0, FlushToZero=0, TransposeA=0, TransposeB=0, CScale=0, PEMask=AllPE>, SrcTile0, SrcTile1, RowMaxIn{if RowMax&&RowMaxInit}, QuantParamTile{if PreMode=vector}, ReluParamTile{if PostMode=vector}, QuantParamGPR{if PreMode=scalar}, ReluParamGPR{if PostMode=scalar}, ->DstTile<Size>, ->RowMaxOut<Size>{if RowMax}, ->GroupMaxOut<Size>{if GroupMax}`<br>`TMATMUL <M=1, N=1, K=1, AType, BType?, RMode?, Sat?, PreMode=0, PostMode=0, PostScale=0, RowMax=0, GroupMax=0, RowMaxInit=0, FlushToZero=0, TransposeA=0, TransposeB=0, CScale=0, PEMask=AllPE{must be AllPE}>, LocalLeftGroup, SharedRightGroup, RowMaxIn{if RowMax&&RowMaxInit}, QuantParamTile{if PreMode=vector}, ReluParamTile{if PostMode=vector}, QuantParamGPR{if PreMode=scalar}, ReluParamGPR{if PostMode=scalar}, ->DstTile<Size>, ->RowMaxOut<Size>{if RowMax}, ->GroupMaxOut<Size>{if GroupMax}`<br>`TMATMUL <M=1, N=1, K=1, AType, BType?, RMode?, Sat?, PreMode=0, PostMode=0, PostScale=0, RowMax=0, GroupMax=0, RowMaxInit=0, FlushToZero=0, TransposeA=0, TransposeB=0, CScale=0, PEMask=AllPE{must be AllPE}>, SharedLeftGroup, SharedRightGroup, RowMaxIn{if RowMax&&RowMaxInit}, QuantParamTile{if PreMode=vector}, ReluParamTile{if PostMode=vector}, QuantParamGPR{if PreMode=scalar}, ReluParamGPR{if PostMode=scalar}, ->DstTile<Size>, ->RowMaxOut<Size>{if RowMax}, ->GroupMaxOut<Size>{if GroupMax}` |
| `TMATMUL_ACC` | `CUBE` | `TMATMUL_ACC <M=1, N=1, K=1, AType, BType?, RMode?, Sat?, PreMode=0, PostMode=0, PostScale=0, RowMax=0, GroupMax=0, RowMaxInit=0, FlushToZero=0, TransposeA=0, TransposeB=0, CScale=0, PEMask=AllPE>, AccTile, SrcTile0, SrcTile1, CScaleTile{if CScale}, RowMaxIn{if RowMax&&RowMaxInit}, QuantParamTile{if PreMode=vector}, ReluParamTile{if PostMode=vector}, QuantParamGPR{if PreMode=scalar}, ReluParamGPR{if PostMode=scalar}, ->DstTile<Size>, ->RowMaxOut<Size>{if RowMax}, ->GroupMaxOut<Size>{if GroupMax}`<br>`TMATMUL_ACC <M=1, N=1, K=1, AType, BType?, RMode?, Sat?, PreMode=0, PostMode=0, PostScale=0, RowMax=0, GroupMax=0, RowMaxInit=0, FlushToZero=0, TransposeA=0, TransposeB=0, CScale=0, PEMask=AllPE{must be AllPE}>, AccTile, LocalLeftGroup, SharedRightGroup, CScaleTile{if CScale}, RowMaxIn{if RowMax&&RowMaxInit}, QuantParamTile{if PreMode=vector}, ReluParamTile{if PostMode=vector}, QuantParamGPR{if PreMode=scalar}, ReluParamGPR{if PostMode=scalar}, ->DstTile<Size>, ->RowMaxOut<Size>{if RowMax}, ->GroupMaxOut<Size>{if GroupMax}`<br>`TMATMUL_ACC <M=1, N=1, K=1, AType, BType?, RMode?, Sat?, PreMode=0, PostMode=0, PostScale=0, RowMax=0, GroupMax=0, RowMaxInit=0, FlushToZero=0, TransposeA=0, TransposeB=0, CScale=0, PEMask=AllPE{must be AllPE}>, AccTile, SharedLeftGroup, SharedRightGroup, CScaleTile{if CScale}, RowMaxIn{if RowMax&&RowMaxInit}, QuantParamTile{if PreMode=vector}, ReluParamTile{if PostMode=vector}, QuantParamGPR{if PreMode=scalar}, ReluParamGPR{if PostMode=scalar}, ->DstTile<Size>, ->RowMaxOut<Size>{if RowMax}, ->GroupMaxOut<Size>{if GroupMax}` |
| `TMATMUL_BIAS` | `CUBE` | `TMATMUL_BIAS <M=1, N=1, K=1, AType, BType?, RMode?, Sat?, PreMode=0, PostMode=0, PostScale=0, RowMax=0, GroupMax=0, RowMaxInit=0, FlushToZero=0, TransposeA=0, TransposeB=0, CScale=0, PEMask=AllPE>, SrcTile0, SrcTile1, BiasTile, RowMaxIn{if RowMax&&RowMaxInit}, QuantParamTile{if PreMode=vector}, ReluParamTile{if PostMode=vector}, QuantParamGPR{if PreMode=scalar}, ReluParamGPR{if PostMode=scalar}, ->DstTile<Size>, ->RowMaxOut<Size>{if RowMax}, ->GroupMaxOut<Size>{if GroupMax}`<br>`TMATMUL_BIAS <M=1, N=1, K=1, AType, BType?, RMode?, Sat?, PreMode=0, PostMode=0, PostScale=0, RowMax=0, GroupMax=0, RowMaxInit=0, FlushToZero=0, TransposeA=0, TransposeB=0, CScale=0, PEMask=AllPE{must be AllPE}>, LocalLeftGroup, SharedRightGroup, BiasTile, RowMaxIn{if RowMax&&RowMaxInit}, QuantParamTile{if PreMode=vector}, ReluParamTile{if PostMode=vector}, QuantParamGPR{if PreMode=scalar}, ReluParamGPR{if PostMode=scalar}, ->DstTile<Size>, ->RowMaxOut<Size>{if RowMax}, ->GroupMaxOut<Size>{if GroupMax}`<br>`TMATMUL_BIAS <M=1, N=1, K=1, AType, BType?, RMode?, Sat?, PreMode=0, PostMode=0, PostScale=0, RowMax=0, GroupMax=0, RowMaxInit=0, FlushToZero=0, TransposeA=0, TransposeB=0, CScale=0, PEMask=AllPE{must be AllPE}>, SharedLeftGroup, SharedRightGroup, BiasTile, RowMaxIn{if RowMax&&RowMaxInit}, QuantParamTile{if PreMode=vector}, ReluParamTile{if PostMode=vector}, QuantParamGPR{if PreMode=scalar}, ReluParamGPR{if PostMode=scalar}, ->DstTile<Size>, ->RowMaxOut<Size>{if RowMax}, ->GroupMaxOut<Size>{if GroupMax}` |
| `TMATMUL_MX` | `CUBE` | `TMATMUL_MX <M=1, N=1, K=1, AType, BType?, RMode?, Sat?, PreMode=0, PostMode=0, PostScale=0, RowMax=0, GroupMax=0, RowMaxInit=0, FlushToZero=0, TransposeA=0, TransposeB=0, CScale=0, PEMask=AllPE>, SrcTile0, RowScaleTile{if AType requires MX scale}, SrcTile1, ColumnScaleTile{if BType requires MX scale}, RowMaxIn{if RowMax&&RowMaxInit}, QuantParamTile{if PreMode=vector}, ReluParamTile{if PostMode=vector}, QuantParamGPR{if PreMode=scalar}, ReluParamGPR{if PostMode=scalar}, ->DstTile<Size>, ->RowMaxOut<Size>{if RowMax}, ->GroupMaxOut<Size>{if GroupMax}`<br>`TMATMUL_MX <M=1, N=1, K=1, AType, BType?, RMode?, Sat?, PreMode=0, PostMode=0, PostScale=0, RowMax=0, GroupMax=0, RowMaxInit=0, FlushToZero=0, TransposeA=0, TransposeB=0, CScale=0, PEMask=AllPE{must be AllPE}>, LocalLeftGroup, SharedRightGroup, RowMaxIn{if RowMax&&RowMaxInit}, QuantParamTile{if PreMode=vector}, ReluParamTile{if PostMode=vector}, QuantParamGPR{if PreMode=scalar}, ReluParamGPR{if PostMode=scalar}, ->DstTile<Size>, ->RowMaxOut<Size>{if RowMax}, ->GroupMaxOut<Size>{if GroupMax}`<br>`TMATMUL_MX <M=1, N=1, K=1, AType, BType?, RMode?, Sat?, PreMode=0, PostMode=0, PostScale=0, RowMax=0, GroupMax=0, RowMaxInit=0, FlushToZero=0, TransposeA=0, TransposeB=0, CScale=0, PEMask=AllPE{must be AllPE}>, SharedLeftGroup, SharedRightGroup, RowMaxIn{if RowMax&&RowMaxInit}, QuantParamTile{if PreMode=vector}, ReluParamTile{if PostMode=vector}, QuantParamGPR{if PreMode=scalar}, ReluParamGPR{if PostMode=scalar}, ->DstTile<Size>, ->RowMaxOut<Size>{if RowMax}, ->GroupMaxOut<Size>{if GroupMax}` |
| `TMATMUL_MX_ACC` | `CUBE` | `TMATMUL_MX_ACC <M=1, N=1, K=1, AType, BType?, RMode?, Sat?, PreMode=0, PostMode=0, PostScale=0, RowMax=0, GroupMax=0, RowMaxInit=0, FlushToZero=0, TransposeA=0, TransposeB=0, CScale=0, PEMask=AllPE>, AccTile, SrcTile0, RowScaleTile{if AType requires MX scale}, SrcTile1, ColumnScaleTile{if BType requires MX scale}, CScaleTile{if CScale}, RowMaxIn{if RowMax&&RowMaxInit}, QuantParamTile{if PreMode=vector}, ReluParamTile{if PostMode=vector}, QuantParamGPR{if PreMode=scalar}, ReluParamGPR{if PostMode=scalar}, ->DstTile<Size>, ->RowMaxOut<Size>{if RowMax}, ->GroupMaxOut<Size>{if GroupMax}`<br>`TMATMUL_MX_ACC <M=1, N=1, K=1, AType, BType?, RMode?, Sat?, PreMode=0, PostMode=0, PostScale=0, RowMax=0, GroupMax=0, RowMaxInit=0, FlushToZero=0, TransposeA=0, TransposeB=0, CScale=0, PEMask=AllPE{must be AllPE}>, AccTile, LocalLeftGroup, SharedRightGroup, CScaleTile{if CScale}, RowMaxIn{if RowMax&&RowMaxInit}, QuantParamTile{if PreMode=vector}, ReluParamTile{if PostMode=vector}, QuantParamGPR{if PreMode=scalar}, ReluParamGPR{if PostMode=scalar}, ->DstTile<Size>, ->RowMaxOut<Size>{if RowMax}, ->GroupMaxOut<Size>{if GroupMax}`<br>`TMATMUL_MX_ACC <M=1, N=1, K=1, AType, BType?, RMode?, Sat?, PreMode=0, PostMode=0, PostScale=0, RowMax=0, GroupMax=0, RowMaxInit=0, FlushToZero=0, TransposeA=0, TransposeB=0, CScale=0, PEMask=AllPE{must be AllPE}>, AccTile, SharedLeftGroup, SharedRightGroup, CScaleTile{if CScale}, RowMaxIn{if RowMax&&RowMaxInit}, QuantParamTile{if PreMode=vector}, ReluParamTile{if PostMode=vector}, QuantParamGPR{if PreMode=scalar}, ReluParamGPR{if PostMode=scalar}, ->DstTile<Size>, ->RowMaxOut<Size>{if RowMax}, ->GroupMaxOut<Size>{if GroupMax}` |
| `TMATMUL_MX_BIAS` | `CUBE` | `TMATMUL_MX_BIAS <M=1, N=1, K=1, AType, BType?, RMode?, Sat?, PreMode=0, PostMode=0, PostScale=0, RowMax=0, GroupMax=0, RowMaxInit=0, FlushToZero=0, TransposeA=0, TransposeB=0, CScale=0, PEMask=AllPE>, SrcTile0, RowScaleTile{if AType requires MX scale}, SrcTile1, ColumnScaleTile{if BType requires MX scale}, BiasTile, RowMaxIn{if RowMax&&RowMaxInit}, QuantParamTile{if PreMode=vector}, ReluParamTile{if PostMode=vector}, QuantParamGPR{if PreMode=scalar}, ReluParamGPR{if PostMode=scalar}, ->DstTile<Size>, ->RowMaxOut<Size>{if RowMax}, ->GroupMaxOut<Size>{if GroupMax}`<br>`TMATMUL_MX_BIAS <M=1, N=1, K=1, AType, BType?, RMode?, Sat?, PreMode=0, PostMode=0, PostScale=0, RowMax=0, GroupMax=0, RowMaxInit=0, FlushToZero=0, TransposeA=0, TransposeB=0, CScale=0, PEMask=AllPE{must be AllPE}>, LocalLeftGroup, SharedRightGroup, BiasTile, RowMaxIn{if RowMax&&RowMaxInit}, QuantParamTile{if PreMode=vector}, ReluParamTile{if PostMode=vector}, QuantParamGPR{if PreMode=scalar}, ReluParamGPR{if PostMode=scalar}, ->DstTile<Size>, ->RowMaxOut<Size>{if RowMax}, ->GroupMaxOut<Size>{if GroupMax}`<br>`TMATMUL_MX_BIAS <M=1, N=1, K=1, AType, BType?, RMode?, Sat?, PreMode=0, PostMode=0, PostScale=0, RowMax=0, GroupMax=0, RowMaxInit=0, FlushToZero=0, TransposeA=0, TransposeB=0, CScale=0, PEMask=AllPE{must be AllPE}>, SharedLeftGroup, SharedRightGroup, BiasTile, RowMaxIn{if RowMax&&RowMaxInit}, QuantParamTile{if PreMode=vector}, ReluParamTile{if PostMode=vector}, QuantParamGPR{if PreMode=scalar}, ReluParamGPR{if PostMode=scalar}, ->DstTile<Size>, ->RowMaxOut<Size>{if RowMax}, ->GroupMaxOut<Size>{if GroupMax}` |

### matrix-and-matrix-vector/matrix-vector

| TileOp | Engine | Canonical macro format |
| --- | --- | --- |
| `TGEMV` | `CUBE` | `TGEMV <M{must be 1}, N=1, K=1, AType, BType?, RMode?, Sat?, PreMode=0, PostMode=0, PostScale=0, RowMax=0, GroupMax=0, RowMaxInit=0, FlushToZero=0, TransposeA=0, TransposeB=0, CScale=0, PEMask=AllPE>, SrcVector, SrcMatrix, RowMaxIn{if RowMax&&RowMaxInit}, QuantParamTile{if PreMode=vector}, ReluParamTile{if PostMode=vector}, QuantParamGPR{if PreMode=scalar}, ReluParamGPR{if PostMode=scalar}, ->DstTile<Size>, ->RowMaxOut<Size>{if RowMax}, ->GroupMaxOut<Size>{if GroupMax}` |
| `TGEMV_ACC` | `CUBE` | `TGEMV_ACC <M{must be 1}, N=1, K=1, AType, BType?, RMode?, Sat?, PreMode=0, PostMode=0, PostScale=0, RowMax=0, GroupMax=0, RowMaxInit=0, FlushToZero=0, TransposeA=0, TransposeB=0, CScale=0, PEMask=AllPE>, AccTile, SrcVector, SrcMatrix, RowMaxIn{if RowMax&&RowMaxInit}, QuantParamTile{if PreMode=vector}, ReluParamTile{if PostMode=vector}, QuantParamGPR{if PreMode=scalar}, ReluParamGPR{if PostMode=scalar}, ->DstTile<Size>, ->RowMaxOut<Size>{if RowMax}, ->GroupMaxOut<Size>{if GroupMax}` |
| `TGEMV_BIAS` | `CUBE` | `TGEMV_BIAS <M{must be 1}, N=1, K=1, AType, BType?, RMode?, Sat?, PreMode=0, PostMode=0, PostScale=0, RowMax=0, GroupMax=0, RowMaxInit=0, FlushToZero=0, TransposeA=0, TransposeB=0, CScale=0, PEMask=AllPE>, SrcVector, SrcMatrix, BiasTile, RowMaxIn{if RowMax&&RowMaxInit}, QuantParamTile{if PreMode=vector}, ReluParamTile{if PostMode=vector}, QuantParamGPR{if PreMode=scalar}, ReluParamGPR{if PostMode=scalar}, ->DstTile<Size>, ->RowMaxOut<Size>{if RowMax}, ->GroupMaxOut<Size>{if GroupMax}` |
| `TGEMV_MX` | `CUBE` | `TGEMV_MX <M{must be 1}, N=1, K=1, AType, BType?, RMode?, Sat?, PreMode=0, PostMode=0, PostScale=0, RowMax=0, GroupMax=0, RowMaxInit=0, FlushToZero=0, TransposeA=0, TransposeB=0, CScale=0, PEMask=AllPE>, SrcVector, RowScaleTile{if AType requires MX scale}, SrcMatrix, ColumnScaleTile{if BType requires MX scale}, RowMaxIn{if RowMax&&RowMaxInit}, QuantParamTile{if PreMode=vector}, ReluParamTile{if PostMode=vector}, QuantParamGPR{if PreMode=scalar}, ReluParamGPR{if PostMode=scalar}, ->DstTile<Size>, ->RowMaxOut<Size>{if RowMax}, ->GroupMaxOut<Size>{if GroupMax}` |
| `TGEMV_MX_ACC` | `CUBE` | `TGEMV_MX_ACC <M{must be 1}, N=1, K=1, AType, BType?, RMode?, Sat?, PreMode=0, PostMode=0, PostScale=0, RowMax=0, GroupMax=0, RowMaxInit=0, FlushToZero=0, TransposeA=0, TransposeB=0, CScale=0, PEMask=AllPE>, AccTile, SrcVector, RowScaleTile{if AType requires MX scale}, SrcMatrix, ColumnScaleTile{if BType requires MX scale}, RowMaxIn{if RowMax&&RowMaxInit}, QuantParamTile{if PreMode=vector}, ReluParamTile{if PostMode=vector}, QuantParamGPR{if PreMode=scalar}, ReluParamGPR{if PostMode=scalar}, ->DstTile<Size>, ->RowMaxOut<Size>{if RowMax}, ->GroupMaxOut<Size>{if GroupMax}` |
| `TGEMV_MX_BIAS` | `CUBE` | `TGEMV_MX_BIAS <M{must be 1}, N=1, K=1, AType, BType?, RMode?, Sat?, PreMode=0, PostMode=0, PostScale=0, RowMax=0, GroupMax=0, RowMaxInit=0, FlushToZero=0, TransposeA=0, TransposeB=0, CScale=0, PEMask=AllPE>, SrcVector, RowScaleTile{if AType requires MX scale}, SrcMatrix, ColumnScaleTile{if BType requires MX scale}, BiasTile, RowMaxIn{if RowMax&&RowMaxInit}, QuantParamTile{if PreMode=vector}, ReluParamTile{if PostMode=vector}, QuantParamGPR{if PreMode=scalar}, ReluParamGPR{if PostMode=scalar}, ->DstTile<Size>, ->RowMaxOut<Size>{if RowMax}, ->GroupMaxOut<Size>{if GroupMax}` |

### memory-and-data-movement/irregular

| TileOp | Engine | Canonical macro format |
| --- | --- | --- |
| `MGATHER` | `TLSU` | `MGATHER <ValidRow=1, ValidCol=1, DataType, PadValue?, Layout?, PEMask=AllPE>, [BaseGPR], RowStrideGPR, SrcTile0, ->DstTile<Size>` |
| `MGATHER_ADD` | `TLSU` | `MGATHER_ADD <ValidRow=1, ValidCol=1, DataType, PEMask=AllPE>, [BaseGPR], SrcTile0, SrcTile1, ->DstTile<Size>` |
| `MGATHER_AND` | `TLSU` | `MGATHER_AND <ValidRow=1, ValidCol=1, DataType, PEMask=AllPE>, [BaseGPR], SrcTile0, SrcTile1, ->DstTile<Size>` |
| `MGATHER_CAS` | `TLSU` | `MGATHER_CAS <ValidRow=1, ValidCol=1, DataType, PEMask=AllPE>, [BaseGPR], RowStrideGPR, SrcTile0, SrcTile1, SrcTile2, ->DstTile<Size>` |
| `MGATHER_DEC` | `TLSU` | `MGATHER_DEC <ValidRow=1, ValidCol=1, DataType, PEMask=AllPE>, [BaseGPR], SrcTile0, SrcTile1, ->DstTile<Size>` |
| `MGATHER_EXCH` | `TLSU` | `MGATHER_EXCH <ValidRow=1, ValidCol=1, DataType, PEMask=AllPE>, [BaseGPR], SrcTile0, SrcTile1, ->DstTile<Size>` |
| `MGATHER_INC` | `TLSU` | `MGATHER_INC <ValidRow=1, ValidCol=1, DataType, PEMask=AllPE>, [BaseGPR], SrcTile0, SrcTile1, ->DstTile<Size>` |
| `MGATHER_MASK` | `TLSU` | `MGATHER_MASK <ValidRow=1, ValidCol=1, DataType, PadValue?, Layout?, PEMask=AllPE>, [BaseGPR], RowStrideGPR, SrcTile0, PredicateTile1, ->DstTile<Size>` |
| `MGATHER_MAX` | `TLSU` | `MGATHER_MAX <ValidRow=1, ValidCol=1, DataType, PEMask=AllPE>, [BaseGPR], SrcTile0, SrcTile1, ->DstTile<Size>` |
| `MGATHER_MIN` | `TLSU` | `MGATHER_MIN <ValidRow=1, ValidCol=1, DataType, PEMask=AllPE>, [BaseGPR], SrcTile0, SrcTile1, ->DstTile<Size>` |
| `MGATHER_OR` | `TLSU` | `MGATHER_OR <ValidRow=1, ValidCol=1, DataType, PEMask=AllPE>, [BaseGPR], SrcTile0, SrcTile1, ->DstTile<Size>` |
| `MGATHER_XOR` | `TLSU` | `MGATHER_XOR <ValidRow=1, ValidCol=1, DataType, PEMask=AllPE>, [BaseGPR], SrcTile0, SrcTile1, ->DstTile<Size>` |
| `MSCATTER` | `TLSU` | `MSCATTER <ValidRow=1, ValidCol=1, DataType, Layout?, PEMask=AllPE>, [BaseGPR], RowStrideGPR, SrcTile0, SrcTile1` |
| `MSCATTER_ADD` | `TLSU` | `MSCATTER_ADD <ValidRow=1, ValidCol=1, DataType, PEMask=AllPE>, [BaseGPR], SrcTile0, SrcTile1` |
| `MSCATTER_AND` | `TLSU` | `MSCATTER_AND <ValidRow=1, ValidCol=1, DataType, PEMask=AllPE>, [BaseGPR], SrcTile0, SrcTile1` |
| `MSCATTER_DEC` | `TLSU` | `MSCATTER_DEC <ValidRow=1, ValidCol=1, DataType, PEMask=AllPE>, [BaseGPR], SrcTile0, SrcTile1` |
| `MSCATTER_INC` | `TLSU` | `MSCATTER_INC <ValidRow=1, ValidCol=1, DataType, PEMask=AllPE>, [BaseGPR], SrcTile0, SrcTile1` |
| `MSCATTER_MASK` | `TLSU` | `MSCATTER_MASK <ValidRow=1, ValidCol=1, DataType, Layout?, PEMask=AllPE>, [BaseGPR], RowStrideGPR, SrcTile0, SrcTile1, PredicateTile2` |
| `MSCATTER_MAX` | `TLSU` | `MSCATTER_MAX <ValidRow=1, ValidCol=1, DataType, PEMask=AllPE>, [BaseGPR], SrcTile0, SrcTile1` |
| `MSCATTER_MIN` | `TLSU` | `MSCATTER_MIN <ValidRow=1, ValidCol=1, DataType, PEMask=AllPE>, [BaseGPR], SrcTile0, SrcTile1` |
| `MSCATTER_OR` | `TLSU` | `MSCATTER_OR <ValidRow=1, ValidCol=1, DataType, PEMask=AllPE>, [BaseGPR], SrcTile0, SrcTile1` |
| `MSCATTER_POPC` | `TLSU` | `MSCATTER_POPC <ValidRow=1, ValidCol=1, DataType, PEMask=AllPE>, [BaseGPR], SrcTile0` |
| `MSCATTER_XOR` | `TLSU` | `MSCATTER_XOR <ValidRow=1, ValidCol=1, DataType, PEMask=AllPE>, [BaseGPR], SrcTile0, SrcTile1` |

### memory-and-data-movement/pe-movement

| TileOp | Engine | Canonical macro format |
| --- | --- | --- |
| `GMOV` | `TLSU` | `GMOV <DataType, Layout?, PEMask=AllPE>, SrcTile0, PeerTid?, ->DstTile<Size>` |

### memory-and-data-movement/regular

| TileOp | Engine | Canonical macro format |
| --- | --- | --- |
| `TLOAD` | `TLSU` | `TLOAD <Row=Derived, Col, ValidRow=Row, ValidCol=Col, DataType, Layout?, PEMask=AllPE>, [base=BaseGPR, stride=RowStrideGPR], ->DstTile<Size>`<br>`TLOAD <Row=Derived, Col, ValidRow=Row, ValidCol=Col, DataType, Layout?, PEMask=AllPE>, [base=BaseGPR, stride=RowStrideGPR], ->DstShared<Size>`<br>`TLOAD <Row=Derived, Col=CubeLayout, ValidRow=Row, ValidCol=Col, DataType, CubeLayout, DTYPE_NONE=DTYPE_NONE, PadValue=Null, PEMask=AllPE>, [base=BaseGPR, stride=RowStrideGPR], ->DstTile<Size>`<br>`TLOAD <ValidK, ValidN, TotalK, DataType, WeightLayout{must be OHWI2NK or OIHW2NK}, PEMask=AllPE>, [GMBaseGPR, ShapeGPR, StartGPR], ->DstShared<Size>` |
| `TPREFETCH` | `TLSU` | `TPREFETCH <Row=Derived, Col, ValidRow=Row, ValidCol=1, DataType, Layout?>, [BaseGPR=zero, RowStrideGPR?]` |
| `TSTORE` | `TLSU` | `TSTORE <Row=Derived, Col=SourceDescriptor, ValidRow=SourceDescriptor, ValidCol=SourceDescriptor, DataType, Layout?, PEMask=AllPE>, SrcTile, [base=BaseGPR, stride=RowStrideGPR]`<br>`TSTORE <Row=Derived, Col=SourceOrValidCol, ValidRow=SourceOr1, ValidCol=SourceOr1, DataType, Layout?, PEMask=AllPE>, SrcShared, [base=BaseGPR, stride=RowStrideGPR]`<br>`TSTORE <Row=Derived, Col=CubeLayout, ValidRow=Row, ValidCol=Col, DataType, CubeLayout, DTYPE_NONE=DTYPE_NONE, PadValue=Null, PEMask=AllPE>, SrcTile, [base=BaseGPR, stride=RowStrideGPR]` |

### reduce-and-expand/column-expansion

| TileOp | Engine | Canonical macro format |
| --- | --- | --- |
| `TCOLEXPAND` | `SFU` | `TCOLEXPAND <Row=Derived, Col, ValidRow=Row, ValidCol=Col, DataType, Layout?, PadValue?, PEMask=AllPE>, SrcTile0, ->DstTile<Size>` |
| `TCOLEXPANDADD` | `SFU` | `TCOLEXPANDADD <Row=Derived, Col, ValidRow=Row, ValidCol=Col, DataType, Layout?, PadValue?, PEMask=AllPE>, SrcTile0, SrcTile1, ->DstTile<Size>` |
| `TCOLEXPANDDIV` | `SFU` | `TCOLEXPANDDIV <Row=Derived, Col, ValidRow=Row, ValidCol=Col, DataType, Layout?, PadValue?, PEMask=AllPE>, SrcTile0, SrcTile1, ->DstTile<Size>` |
| `TCOLEXPANDEXPDIF` | `SFU` | `TCOLEXPANDEXPDIF <Row=Derived, Col, ValidRow=Row, ValidCol=Col, DataType, Layout?, PadValue?, PEMask=AllPE>, SrcTile0, SrcTile1, ->DstTile<Size>` |
| `TCOLEXPANDMAX` | `SFU` | `TCOLEXPANDMAX <Row=Derived, Col, ValidRow=Row, ValidCol=Col, DataType, Layout?, PadValue?, PEMask=AllPE>, SrcTile0, SrcTile1, ->DstTile<Size>` |
| `TCOLEXPANDMIN` | `SFU` | `TCOLEXPANDMIN <Row=Derived, Col, ValidRow=Row, ValidCol=Col, DataType, Layout?, PadValue?, PEMask=AllPE>, SrcTile0, SrcTile1, ->DstTile<Size>` |
| `TCOLEXPANDMUL` | `SFU` | `TCOLEXPANDMUL <Row=Derived, Col, ValidRow=Row, ValidCol=Col, DataType, Layout?, PadValue?, PEMask=AllPE>, SrcTile0, SrcTile1, ->DstTile<Size>` |
| `TCOLEXPANDSUB` | `SFU` | `TCOLEXPANDSUB <Row=Derived, Col, ValidRow=Row, ValidCol=Col, DataType, Layout?, PadValue?, PEMask=AllPE>, SrcTile0, SrcTile1, ->DstTile<Size>` |

### reduce-and-expand/column-reduction

| TileOp | Engine | Canonical macro format |
| --- | --- | --- |
| `TCOLARGMAX` | `SFU` | `TCOLARGMAX <Row=Derived, Col, ValidRow=Row, ValidCol=Col, DataType, Layout?, PadValue?, PEMask=AllPE>, SrcTile0, ->DstTile<Size>` |
| `TCOLARGMIN` | `SFU` | `TCOLARGMIN <Row=Derived, Col, ValidRow=Row, ValidCol=Col, DataType, Layout?, PadValue?, PEMask=AllPE>, SrcTile0, ->DstTile<Size>` |
| `TCOLMAX` | `SFU` | `TCOLMAX <Row=Derived, Col, ValidRow=Row, ValidCol=Col, DataType, Layout?, PadValue?, PEMask=AllPE>, SrcTile0, ->DstTile<Size>` |
| `TCOLMIN` | `SFU` | `TCOLMIN <Row=Derived, Col, ValidRow=Row, ValidCol=Col, DataType, Layout?, PadValue?, PEMask=AllPE>, SrcTile0, ->DstTile<Size>` |
| `TCOLPROD` | `SFU` | `TCOLPROD <Row=Derived, Col, ValidRow=Row, ValidCol=Col, DataType, Layout?, PadValue?, PEMask=AllPE>, SrcTile0, ->DstTile<Size>` |
| `TCOLSUM` | `SFU` | `TCOLSUM <Row=Derived, Col, ValidRow=Row, ValidCol=Col, DataType, Layout?, PadValue?, PEMask=AllPE>, SrcTile0, ->DstTile<Size>` |

### reduce-and-expand/row-expansion

| TileOp | Engine | Canonical macro format |
| --- | --- | --- |
| `TROWEXPAND` | `SFU` | `TROWEXPAND <Row=Derived, Col, ValidRow=Row, ValidCol=Col, DataType, Layout?, PadValue?, PEMask=AllPE>, SrcTile0, ->DstTile<Size>` |
| `TROWEXPANDADD` | `SFU` | `TROWEXPANDADD <Row=Derived, Col, ValidRow=Row, ValidCol=Col, DataType, Layout?, PadValue?, PEMask=AllPE>, SrcTile0, SrcTile1, ->DstTile<Size>` |
| `TROWEXPANDDIV` | `SFU` | `TROWEXPANDDIV <Row=Derived, Col, ValidRow=Row, ValidCol=Col, DataType, Layout?, PadValue?, PEMask=AllPE>, SrcTile0, SrcTile1, ->DstTile<Size>` |
| `TROWEXPANDEXPDIF` | `SFU` | `TROWEXPANDEXPDIF <Row=Derived, Col, ValidRow=Row, ValidCol=Col, DataType, Layout?, PadValue?, PEMask=AllPE>, SrcTile0, SrcTile1, ->DstTile<Size>` |
| `TROWEXPANDMAX` | `SFU` | `TROWEXPANDMAX <Row=Derived, Col, ValidRow=Row, ValidCol=Col, DataType, Layout?, PadValue?, PEMask=AllPE>, SrcTile0, SrcTile1, ->DstTile<Size>` |
| `TROWEXPANDMIN` | `SFU` | `TROWEXPANDMIN <Row=Derived, Col, ValidRow=Row, ValidCol=Col, DataType, Layout?, PadValue?, PEMask=AllPE>, SrcTile0, SrcTile1, ->DstTile<Size>` |
| `TROWEXPANDMUL` | `SFU` | `TROWEXPANDMUL <Row=Derived, Col, ValidRow=Row, ValidCol=Col, DataType, Layout?, PadValue?, PEMask=AllPE>, SrcTile0, SrcTile1, ->DstTile<Size>` |
| `TROWEXPANDSUB` | `SFU` | `TROWEXPANDSUB <Row=Derived, Col, ValidRow=Row, ValidCol=Col, DataType, Layout?, PadValue?, PEMask=AllPE>, SrcTile0, SrcTile1, ->DstTile<Size>` |

### reduce-and-expand/row-reduction

| TileOp | Engine | Canonical macro format |
| --- | --- | --- |
| `TROWARGMAX` | `SFU` | `TROWARGMAX <Row=Derived, Col, ValidRow=Row, ValidCol=Col, DataType, Layout?, PadValue?, PEMask=AllPE>, SrcTile0, ->DstTile<Size>` |
| `TROWARGMIN` | `SFU` | `TROWARGMIN <Row=Derived, Col, ValidRow=Row, ValidCol=Col, DataType, Layout?, PadValue?, PEMask=AllPE>, SrcTile0, ->DstTile<Size>` |
| `TROWMAX` | `SFU` | `TROWMAX <Row=Derived, Col, ValidRow=Row, ValidCol=Col, DataType, Layout?, PadValue?, PEMask=AllPE>, SrcTile0, ->DstTile<Size>` |
| `TROWMIN` | `SFU` | `TROWMIN <Row=Derived, Col, ValidRow=Row, ValidCol=Col, DataType, Layout?, PadValue?, PEMask=AllPE>, SrcTile0, ->DstTile<Size>` |
| `TROWPROD` | `SFU` | `TROWPROD <Row=Derived, Col, ValidRow=Row, ValidCol=Col, DataType, Layout?, PadValue?, PEMask=AllPE>, SrcTile0, ->DstTile<Size>` |
| `TROWSUM` | `SFU` | `TROWSUM <Row=Derived, Col, ValidRow=Row, ValidCol=Col, DataType, Layout?, PadValue?, PEMask=AllPE>, SrcTile0, ->DstTile<Size>` |

### tile-scalar-and-immediate/arithmetic

| TileOp | Engine | Canonical macro format |
| --- | --- | --- |
| `TADDS` | `VEC` | `TADDS <Row=Derived, Col, ValidRow=Row, ValidCol=Col, DataType, PadValue?, PEMask=AllPE>, SrcTile0, ScalarGPR0?, ->DstTile<Size>` |
| `TDIVS` | `SFU` | `TDIVS <Row=Derived, Col, ValidRow=Row, ValidCol=Col, DataType, PadValue?, PEMask=AllPE>, SrcTile0, ScalarGPR0?, ->DstTile<Size>` |
| `TMAXS` | `VEC` | `TMAXS <Row=Derived, Col, ValidRow=Row, ValidCol=Col, DataType, PadValue?, PEMask=AllPE>, SrcTile0, ScalarGPR0?, ->DstTile<Size>` |
| `TMINS` | `VEC` | `TMINS <Row=Derived, Col, ValidRow=Row, ValidCol=Col, DataType, PadValue?, PEMask=AllPE>, SrcTile0, ScalarGPR0?, ->DstTile<Size>` |
| `TMULS` | `VEC` | `TMULS <Row=Derived, Col, ValidRow=Row, ValidCol=Col, DataType, PadValue?, PEMask=AllPE>, SrcTile0, ScalarGPR0?, ->DstTile<Size>` |
| `TREMS` | `SFU` | `TREMS <Row=Derived, Col, ValidRow=Row, ValidCol=Col, DataType, PadValue?, PEMask=AllPE>, SrcTile0, ScalarGPR0?, ->DstTile<Size>` |
| `TSUBS` | `VEC` | `TSUBS <Row=Derived, Col, ValidRow=Row, ValidCol=Col, DataType, PadValue?, PEMask=AllPE>, SrcTile0, ScalarGPR0?, ->DstTile<Size>` |

### tile-scalar-and-immediate/initialization

| TileOp | Engine | Canonical macro format |
| --- | --- | --- |
| `TEXPANDS` | `VEC` | `TEXPANDS <Row=Derived, Col, ValidRow=Row, ValidCol=Col, DataType, Layout?, PadValue?, PEMask=AllPE>, ScalarGPR0?, ->DstTile<Size>` |

### tile-scalar-and-immediate/logical

| TileOp | Engine | Canonical macro format |
| --- | --- | --- |
| `TANDS` | `VEC` | `TANDS <Row=Derived, Col, ValidRow=Row, ValidCol=Col, DataType, PadValue?, PEMask=AllPE>, SrcTile0, ScalarGPR0?, ->DstTile<Size>` |
| `TCMPS` | `VEC` | `TCMPS <Row=Derived, Col, ValidRow=Row, ValidCol=Col, DataType, CMode=EQ, PadValue=Null, PEMask=AllPE>, SrcTile0, ScalarGPR0=zero, ->PredicateTile<Size>`<br>`TCMPS <Row=Derived, Col, ValidRow=Row, ValidCol=Col, DataType, CMode=EQ, PadValue=Null, PEMask=AllPE>, SrcTile0, ScalarGPR0=zero, ->PredicateCell<Size>`<br>`TCMPS <Row=Derived, Col, ValidRow=Row, ValidCol=Col, DataType, CMode=EQ, PadValue=Null, SatMode?, PEMask=AllPE>, SrcTile0, ScalarGPR0=zero, ->PredicateGPR` |
| `TORS` | `VEC` | `TORS <Row=Derived, Col, ValidRow=Row, ValidCol=Col, DataType, PadValue?, PEMask=AllPE>, SrcTile0, ScalarGPR0?, ->DstTile<Size>` |
| `TSELS` | `VEC` | `TSELS <Row=Derived, Col, ValidRow=Row, ValidCol=Col, DataType, PadValue=Null, PEMask=AllPE>, PredicateTile0, SrcTile1, ScalarFalseGPR=zero, ->DstTile<Size>`<br>`TSELS <Row=Derived, Col, ValidRow=Row, ValidCol=Col, DataType, PadValue=Null, PEMask=AllPE>, PredicateCell0, SrcTile1, ScalarFalseGPR=zero, ->DstTile<Size>`<br>`TSELS <Row=Derived, Col, ValidRow=Row, ValidCol=Col, DataType, PadValue=Null, PEMask=AllPE>, PredicateGPR0, PredicateGPR1{if DataType=U8}, SrcTile1, ScalarFalseGPR=zero, ->DstTile<Size>` |
| `TSHLS` | `VEC` | `TSHLS <Row=Derived, Col, ValidRow=Row, ValidCol=Col, DataType, PadValue?, PEMask=AllPE>, SrcTile0, ScalarGPR0?, ->DstTile<Size>` |
| `TSHRS` | `VEC` | `TSHRS <Row=Derived, Col, ValidRow=Row, ValidCol=Col, DataType, PadValue?, PEMask=AllPE>, SrcTile0, ScalarGPR0?, ->DstTile<Size>` |
| `TXORS` | `VEC` | `TXORS <Row=Derived, Col, ValidRow=Row, ValidCol=Col, DataType, PadValue?, PEMask=AllPE>, SrcTile0, ScalarGPR0?, ->DstTile<Size>` |

## Physical expansion and disassembly

The JSON catalog records the complete physical `block_composition`, defaults, exceptions, semantic source roles, and destination roles for every row above.
A TileOp assembler expands through that generated schema. A bundle-aware disassembler folds every complete canonical physical schema. A configuration field such as `Row` that has no encoded carrier and remains runtime-derived is omitted from disassembly rather than printed as an invented value. When PredicateTile and PredicateCell forms have identical physical bytes, disassembly uses the first catalog form as the canonical spelling; reassembly preserves the bytes exactly.

## Tool integration boundary

This catalog specifies the PTO 0.58.6 textual contract and deterministic physical expansion. LLVM MC and PTO-AS integration are downstream work tracked from issue 261; they must consume this schema rather than copy its operation table.
Every folded instruction remains one output line. A decode failure, stale mnemonic, non-canonical command order, or unmatched encoded value remains physical assembly. Runtime descriptor state is not required for canonical folding.

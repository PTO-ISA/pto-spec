<!-- GENERATED FROM: asl/block/model/state/source-lifetime.asl -->
# Source Lifetime

**Normative ASL source:** `asl/block/model/state/source-lifetime.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-STATE-SOURCE-LIFETIME}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-source-lifetime-purpose role=purpose-scope -->
## 目的和范围

本单元在一个 dynamic last-use occurrence 中保持 source payload 存活，直到每个声明 participant 都成功完成。它将 occurrence 绑定到一个不可变 Local 或 Shared generation，因此 delayed PE 不会意外消费同一物理 slot 中的 replacement payload。

同一 owner 还跟踪 per-destination GMOV source selection。两种机制都在 PE 独立停止、fault、retry 或 squash 时保留 cross-PE source identity。

<!-- PTO-READER-BLOCK: block-source-lifetime-concepts role=concepts-state -->
## Occurrence 和 participant 状态

source-lifetime occurrence 记录其 ordinal、Core、invocation、instruction site、source kind 和 index、captured generation、declared participant mask、captured mask、completed mask，以及每个 PE 的 execution-domain token。ordinal 区分在其他方面命名同一 site 和 source 的并发 dynamic occurrence。

captured generation 不可变。occurrence outstanding 时，`SharedSourceLifetimePinned` 或 `LocalSourceLifetimePinned` 阻止替换这个确切 payload generation。

<!-- PTO-READER-BLOCK: block-source-lifetime-rules role=rules-interactions -->
## Capture 和 completion 规则

每个 participating PE 捕获一次，也只能完成一次。当其他 declared participant 仍未完成时，successful PE 直接返回而不消费 payload。当另一个 incomplete occurrence 仍固定同一 captured generation 时，一个 occurrence 的 completion 不会消费任何内容。最后一个这类 occurrence 完成后，owner 恰好一次消费该 generation，并退役所有与其匹配的 completed occurrence。

fault、retry、nonparticipation 和 squash 不计为 successful completion。domain squash 只移除 Core、invocation、PE 和 domain 匹配的 capture token；其他 PE 的 completed bit 仍属于该 occurrence。kernel end 或 abort 退役属于 closing invocation 的 occurrence。

<!-- PTO-READER-BLOCK: block-source-lifetime-boundaries role=boundaries -->
## 边界

unmatched 或 incomplete occurrence 可以无限期保持 payload live；此 owner 不会猜测 absent participant 已完成。有界 reference table 是模型界限，不是 portable rejection condition，也不是无关 group 发生冲突的规则。

仅当 Local 或 Shared slot 仍保存 captured generation 时，consumption 才改变 liveness。因此，slot reuse 后的 stale completion 不能消费 newer generation。

<!-- PTO-READER-BLOCK: block-source-lifetime-example role=example-usage -->
## 阅读示例

PE0 到 PE3 声明最后一次使用 Shared Tile S14 generation 6。PE0 首先完成，但 generation 6 仍被固定，因为还有三个 participant outstanding。PE1 在 capture 后 fault，因此其 bit 未完成。若 PE1 的 domain 被 squash，只移除该 stale capture；PE0 的 successful completion 保留。fresh-domain retry 可以在同一 occurrence 上重新 capture PE1。PE1 到 PE3 完成后，如果没有其他 incomplete occurrence 继续固定该 generation，generation 6 会被恰好消费一次。

<!-- PTO-READER-BLOCK: block-source-lifetime-related role=related-owners-navigation -->
## 相关所有者

- [Local payload generation](../../../arch/state/local-payload-generation.md) 读取并消费 PE-private generation。
- [Local generation squash](../operands/local-generation-squash.md) 移除 matching speculative capture。
- [PE execution context](../../../arch/state/pe-execution-context.md) 在选择切换和 trap 期间保存 per-PE capture state。
- [Kernel lifecycle](../../../arch/state/kernel-lifecycle.md) 在 end 和 abort 时退役 occurrence。
- [Shared registers](../../../tile/model/state/shared-registers.md) 拥有 Shared payload generation 和 liveness。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/state/source-lifetime.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-STATE-SOURCE-LIFETIME","surface":"block","classification":["model","state","source-lifetime"],"depends_on":["PTO-ARCH-MEMORY-MODEL-GM-OBLIGATIONS","PTO-ARCH-MEMORY-MODEL-ATOMIC-TSTORE-OBLIGATIONS","PTO-ARCH-STATE-LOCAL-PAYLOAD-GENERATION","PTO-BLOCK-MODEL-STATE-CONTROL-STATE","PTO-TILE-MODEL-STATE-SHARED-REGISTERS"]}
// PTO-STATE: {"id":"PTO-STATE-BLOCK-SOURCE-LIFETIME","classification":["block","source-lifetime"],"scope":"system","owner":"PTO-BLOCK-MODEL-STATE-SOURCE-LIFETIME","members":["_BundleSourceLifetimes","_NextBundleSourceLifetimeOrdinal","_BundleGMOVSourceSelections","_NextBundleGMOVSourceSelectionOrdinal"],"depends_on":["PTO-STATE-BLOCK-CONTROL","PTO-STATE-TILE-LOCAL"]}
// NDF-BEGIN: PTO-B-SOURCE-LIFETIME-PE-COMPLETION-001
// ndf: kind=contract level=L1 layer=block status=accepted
// Each dynamic last-use occurrence records its declared participant set and
// immutable source generation. A Shared source names one Shared payload
// generation; a Local capture pins its exact PE, tile, and payload generation.
// Atomic Local TSTORE groups those per-PE tuples in one collective occurrence,
// even when participants resolve different physical tiles or epochs. A
// successful participant returns immediately and completes only its own bit;
// captured payload generations are consumed exactly once only after every
// declared participant succeeds, and a Local tuple remains pinned while
// another incomplete occurrence captures that same tuple. Fault, retry,
// squash, and nonparticipation MUST NOT falsely complete an occurrence. An
// unmatched occurrence may retain payload, and an outstanding occurrence
// pins its captured generation against replacement. The bounded reference
// table is a model bound, not a portable rejection condition or
// conflicting-group restriction.
// A domain squash cancels only the matching PE capture token; successful
// completions from other PEs remain attached to the immutable occurrence.
// NDF-END: PTO-B-SOURCE-LIFETIME-PE-COMPLETION-001
// A bounded reference table represents arbitrarily many sequential dynamic
// occurrences. Exhaustion waits without introducing a portable fault.
type BundleSourceLifetimeLocalPEs of array [[PTO_MODEL_MEMORY_AGENTS]]
    of MemoryAgentId;
type BundleSourceLifetimeLocalTiles of array [[PTO_MODEL_MEMORY_AGENTS]]
    of TileIndex;
type BundleSourceLifetimeLocalEpochs of array [[PTO_MODEL_MEMORY_AGENTS]]
    of integer;

type BundleSourceLifetimeOccurrence of record {
    valid: boolean,
    ordinal: integer,
    core: PTOModelCoreIdentity,
    invocation: integer,
    origin: MemoryEventOrigin,
    source_acr: AccessControlRing,
    producer_site: Word,
    start_instruction: bits(64),
    operation_form: bits(7),
    operation_selector: bits(10),
    shared: boolean,
    resource: TileIndex,
    source_pe: MemoryAgentId,
    local_epoch: integer,
    shared_epoch: integer,
    participant_mask: bits(4),
    captured_mask: bits(4),
    completed_mask: bits(4),
    // Atomic Local TSTORE groups one dynamic cohort while retaining each
    // PE's independently captured physical source tuple. Generic Shared and
    // GMOV lifetimes continue to use the scalar source tuple above.
    atomic_local_cohort: boolean,
    source_selector_relative: boolean,
    local_source_pes: BundleSourceLifetimeLocalPEs,
    local_sources: BundleSourceLifetimeLocalTiles,
    local_epochs: BundleSourceLifetimeLocalEpochs,
    consumed_mask: bits(4),
    retry_only_mask: bits(4),
    domain_tokens: array [[PTO_MODEL_MEMORY_AGENTS]] of integer
};

func ResetSourceLifetimeState()
begin
    for slot = 0 to 63 do
        _BundleSourceLifetimes[[slot]].valid = FALSE;
    end;
    _NextBundleSourceLifetimeOrdinal = 1;
    _NextBundleGMOVSourceSelectionOrdinal = 1;
    ResetBundleGMOVSourceSelections();
end;

type BundleSourceLifetimeSnapshot of array [[64]]
    of BundleSourceLifetimeOccurrence;

var _BundleSourceLifetimes : BundleSourceLifetimeSnapshot;
var _NextBundleSourceLifetimeOrdinal : integer;

type BundleGMOVSourcePESelection of array [[PTO_MODEL_MEMORY_AGENTS]]
    of MemoryAgentId;
type BundleGMOVSourceTileSelection of array [[PTO_MODEL_MEMORY_AGENTS]]
    of TileIndex;
type BundleGMOVSourceEpochSelection of array [[PTO_MODEL_MEMORY_AGENTS]]
    of integer;

type BundleGMOVSourceSelection of record {
    valid: boolean,
    ordinal: integer,
    core: PTOModelCoreIdentity,
    invocation: integer,
    origin: MemoryEventOrigin,
    source_acr: AccessControlRing,
    producer_site: Word,
    start_instruction: bits(64),
    operation_form: bits(7),
    operation_selector: bits(10),
    raw_selector: TileIndex,
    relative: boolean,
    participant_mask: bits(4),
    captured_mask: bits(4),
    completed_mask: bits(4),
    domain_tokens: array [[PTO_MODEL_MEMORY_AGENTS]] of integer,
    source_pes: BundleGMOVSourcePESelection,
    sources: BundleGMOVSourceTileSelection,
    source_epochs: BundleGMOVSourceEpochSelection
};

type BundleGMOVSourceSelectionSnapshot of array [[64]]
    of BundleGMOVSourceSelection;

var _BundleGMOVSourceSelections : BundleGMOVSourceSelectionSnapshot;
var _NextBundleGMOVSourceSelectionOrdinal : integer;

readonly func BundleSourceLifetimeIdentityMatches(
    occurrence: BundleSourceLifetimeOccurrence,
    shared: boolean, source_pe: MemoryAgentId, source: TileIndex,
    local_epoch: integer, shared_epoch: integer,
    participant_mask: bits(4)) => boolean
begin
    return occurrence.valid &&
           occurrence.core == _CurrentModelCore &&
           occurrence.invocation == _CurrentKernelInvocation &&
           occurrence.origin == _CurrentMemoryOrigin &&
           occurrence.source_acr == CurrentACR() &&
           occurrence.producer_site == ReadBPC() &&
           occurrence.start_instruction == _BundleStartEncodedInstruction &&
           occurrence.operation_form == _BundleOperation.form_identity &&
           occurrence.operation_selector == _BundleOperation.selector &&
           !occurrence.atomic_local_cohort &&
           occurrence.shared == shared && occurrence.resource == source &&
           occurrence.source_pe == source_pe &&
           occurrence.local_epoch == local_epoch &&
           occurrence.shared_epoch == shared_epoch &&
           occurrence.participant_mask == participant_mask;
end;

readonly func FindBundleSourceLifetimeOrdinal(ordinal: integer)
    => integer {-1..63}
begin
    for slot = 0 to 63 do
        if _BundleSourceLifetimes[[slot]].valid &&
           _BundleSourceLifetimes[[slot]].ordinal == ordinal then
            return slot;
        end;
    end;
    return -1;
end;

func CaptureBundleSourceLifetime(
    shared: boolean, source_pe: MemoryAgentId, source: TileIndex,
    local_epoch: integer, shared_epoch: integer,
    participant_mask: bits(4), prior_ordinal: integer) => integer
begin
    let pe = _CurrentMemoryAgent as integer {0..3};
    let mask_bit = PTOPEMaskBitOfPEIdentity(_CurrentMemoryAgent);
    if participant_mask == Zeros{4} || participant_mask[mask_bit] != '1' then
        return 0;
    end;
    if prior_ordinal > 0 then
        let prior = FindBundleSourceLifetimeOrdinal(prior_ordinal);
        if prior >= 0 &&
           BundleSourceLifetimeIdentityMatches(
               _BundleSourceLifetimes[[prior]], shared, source_pe, source,
               local_epoch, shared_epoch, participant_mask) &&
           _BundleSourceLifetimes[[prior]].captured_mask[mask_bit] == '1' &&
           _BundleSourceLifetimes[[prior]].domain_tokens[[pe]] ==
               _BundleExecutionDomainToken then
            return prior_ordinal;
        end;
        return 0;
    end;
    var candidate: integer {-1..63} = -1;
    for slot = 0 to 63 do
        if BundleSourceLifetimeIdentityMatches(
               _BundleSourceLifetimes[[slot]], shared, source_pe, source,
               local_epoch, shared_epoch, participant_mask) &&
           _BundleSourceLifetimes[[slot]].captured_mask[mask_bit] == '0' then
            if candidate < 0 then
                candidate = slot;
            elsif _BundleSourceLifetimes[[slot]].ordinal <
                  _BundleSourceLifetimes[[candidate]].ordinal then
                candidate = slot;
            end;
        end;
    end;
    if candidate >= 0 then
        _BundleSourceLifetimes[[candidate]].captured_mask[mask_bit] = '1';
        _BundleSourceLifetimes[[candidate]].domain_tokens[[pe]] =
            _BundleExecutionDomainToken;
        return _BundleSourceLifetimes[[candidate]].ordinal;
    end;
    for slot = 0 to 63 do
        if !_BundleSourceLifetimes[[slot]].valid then
            let ordinal = _NextBundleSourceLifetimeOrdinal;
            _NextBundleSourceLifetimeOrdinal = ordinal + 1;
            _BundleSourceLifetimes[[slot]].valid = TRUE;
            _BundleSourceLifetimes[[slot]].ordinal = ordinal;
            _BundleSourceLifetimes[[slot]].core = _CurrentModelCore;
            _BundleSourceLifetimes[[slot]].invocation =
                _CurrentKernelInvocation;
            _BundleSourceLifetimes[[slot]].origin = _CurrentMemoryOrigin;
            _BundleSourceLifetimes[[slot]].source_acr = CurrentACR();
            _BundleSourceLifetimes[[slot]].producer_site = ReadBPC();
            _BundleSourceLifetimes[[slot]].start_instruction =
                _BundleStartEncodedInstruction;
            _BundleSourceLifetimes[[slot]].operation_form =
                _BundleOperation.form_identity;
            _BundleSourceLifetimes[[slot]].operation_selector =
                _BundleOperation.selector;
            _BundleSourceLifetimes[[slot]].shared = shared;
            _BundleSourceLifetimes[[slot]].resource = source;
            _BundleSourceLifetimes[[slot]].source_pe = source_pe;
            _BundleSourceLifetimes[[slot]].local_epoch = local_epoch;
            _BundleSourceLifetimes[[slot]].shared_epoch = shared_epoch;
            _BundleSourceLifetimes[[slot]].participant_mask = participant_mask;
            _BundleSourceLifetimes[[slot]].captured_mask = Zeros{4};
            _BundleSourceLifetimes[[slot]].completed_mask = Zeros{4};
            _BundleSourceLifetimes[[slot]].atomic_local_cohort = FALSE;
            _BundleSourceLifetimes[[slot]].source_selector_relative = FALSE;
            _BundleSourceLifetimes[[slot]].consumed_mask = Zeros{4};
            _BundleSourceLifetimes[[slot]].retry_only_mask = Zeros{4};
            for agent = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
                _BundleSourceLifetimes[[slot]].local_source_pes[[agent]] =
                    agent as MemoryAgentId;
                _BundleSourceLifetimes[[slot]].local_sources[[agent]] = 0;
                _BundleSourceLifetimes[[slot]].local_epochs[[agent]] = 0;
                _BundleSourceLifetimes[[slot]].domain_tokens[[agent]] = 0;
            end;
            _BundleSourceLifetimes[[slot]].captured_mask[mask_bit] = '1';
            _BundleSourceLifetimes[[slot]].domain_tokens[[pe]] =
                _BundleExecutionDomainToken;
            return ordinal;
        end;
    end;
    return 0;
end;

readonly func SharedSourceLifetimePinned(shared_id: SharedTileID) => boolean
begin
    let shared = SharedTileRecord(shared_id);
    for slot = 0 to 63 do
        if _BundleSourceLifetimes[[slot]].valid &&
           _BundleSourceLifetimes[[slot]].shared &&
           _BundleSourceLifetimes[[slot]].core == _CurrentModelCore &&
           _BundleSourceLifetimes[[slot]].resource ==
               (UInt(shared_id) as TileIndex) &&
           _BundleSourceLifetimes[[slot]].shared_epoch ==
               shared.payload_generation then return TRUE; end;
    end;
    return FALSE;
end;

func ResetBundleGMOVSourceSelections()
begin
    for slot = 0 to 63 do
        _BundleGMOVSourceSelections[[slot]].valid = FALSE;
    end;
end;

func RetireBundleGMOVSourceSelections(core: PTOModelCoreIdentity,
                                      invocation: integer)
begin
    for slot = 0 to 63 do
        if _BundleGMOVSourceSelections[[slot]].valid &&
           _BundleGMOVSourceSelections[[slot]].core == core &&
           _BundleGMOVSourceSelections[[slot]].invocation == invocation then
            _BundleGMOVSourceSelections[[slot]].valid = FALSE;
        end;
    end;
end;

func SquashBundleGMOVSourceSelections(core: PTOModelCoreIdentity,
                                      invocation: integer, domain: integer)
begin
    for slot = 0 to 63 do
        if _BundleGMOVSourceSelections[[slot]].valid &&
           _BundleGMOVSourceSelections[[slot]].core == core &&
           _BundleGMOVSourceSelections[[slot]].invocation == invocation then
            var captured_left = Zeros{4};
            for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
                let mask_bit = PTOPEMaskBitOfPEIdentity(pe);
                if _BundleGMOVSourceSelections[[slot]].captured_mask[mask_bit] ==
                       '1' &&
                   _BundleGMOVSourceSelections[[slot]].domain_tokens[[pe]] ==
                       domain then
                    _BundleGMOVSourceSelections[[slot]].captured_mask[
                        mask_bit] = '0';
                    _BundleGMOVSourceSelections[[slot]].completed_mask[
                        mask_bit] = '0';
                    _BundleGMOVSourceSelections[[slot]].domain_tokens[[pe]] = 0;
                else
                    captured_left[mask_bit] =
                        _BundleGMOVSourceSelections[[slot]].captured_mask[
                            mask_bit];
                end;
            end;
            if captured_left == Zeros{4} then
                _BundleGMOVSourceSelections[[slot]].valid = FALSE;
            end;
        end;
    end;
end;
```
<!-- GENERATED-ASL-END: unit -->

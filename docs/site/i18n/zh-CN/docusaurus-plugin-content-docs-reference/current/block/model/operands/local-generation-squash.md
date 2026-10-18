<!-- GENERATED FROM: asl/block/model/operands/local-generation-squash.asl -->
# Local Generation Squash

**Normative ASL source:** `asl/block/model/operands/local-generation-squash.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-OPERANDS-LOCAL-GENERATION-SQUASH}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-local-generation-squash-purpose role=purpose-scope -->
## 目的和范围

本单元移除属于一个 execution-domain token 的 speculative Block state。它协调 Local-generation writer 和 consumer、Shared-generation request，以及 source-lifetime 或 GMOV capture，使 squashed domain 此后不能完成这些保留工作。

domain token 是 scope key。属于其他 Core、invocation、PE 或 token 的状态必须保留。

<!-- PTO-READER-BLOCK: block-local-generation-squash-concepts role=concepts-state -->
## Squash 标识的内容

`SquashBundleExecutionDomain` 将当前 Core 和 invocation 与提供的 domain token 一起使用。它移除匹配的 Local-generation writer 和 consumer entry，然后将该标识传给 Shared-request 和 source-lifetime owner。

当 incomplete Shared candidate 含有 matching arrival 时，`MarkBundleSharedRequestDomainSquashed` 会在 candidate abort 前标记 live binding、saved PE image 和 retained trap image 中的 request。因此，恢复这些副本不能复活 cancelled Shared request。

<!-- PTO-READER-BLOCK: block-model-operands-local-generation-squash-shared-request role=rules-interactions -->
## Squash 交互

对于匹配的 Local-generation writer，squash 会移除该 writer 的 coverage 和 readiness contribution。如果不再有 writer，可以丢弃 incomplete generation；其他 domain 的 successful writer 仍然保留。匹配的 Shared candidate participation 被移除，而已经发布的数据不会重新打开。

source-lifetime 和 GMOV record 只丢失 token 匹配的 PE capture，其他 PE 的 successful completion 仍然属于该 occurrence。该函数不检查 GM obligation 或 generic replay state。

<!-- PTO-READER-BLOCK: block-local-generation-squash-boundaries role=boundaries -->
## 边界

squash 比 kernel abort 更窄。它不会退役整个 invocation、清除 peer readiness、移除另一个 Core 的 candidate，或撤销 published Shared Tile 或 committed memory event。不匹配的 token 使被检查 record 保持不变。

本单元也不制造 retry。recovery 可以恢复普通 saved field，但 squashed marker 阻止退役 domain 像仍然 live 一样提交或完成。

<!-- PTO-READER-BLOCK: block-local-generation-squash-example role=example-usage -->
## 阅读示例

假设 PE0 和 PE1 在不同 domain token 下贡献了 Local-generation writer。PE0 在其 token 被保存后中断，随后其 domain 被 squash。PE0 的 writer、source-lifetime capture 和匹配 request state 被移除，而 PE1 的 writer 和 readiness 保留。恢复 PE0 的 saved trap context 不会复活旧 contribution；新 Block 会获得新的 domain token。

<!-- PTO-READER-BLOCK: block-local-generation-squash-related role=related-owners-navigation -->
## 相关所有者

- [Local generation](local-generation.md) 拥有 writer coverage、readiness 和 publication。
- [Shared-generation PE requests](shared-generation-pe-requests.md) 拥有 per-PE candidate submission 和 release。
- [Source lifetime](../state/source-lifetime.md) 拥有 captured generation 和 participant completion。
- [Shared-generation state](../state/shared-generation-state.md) 在中止 incomplete candidate 前标记 matching Shared request 的 live 和 saved copy。
- [Trap context](../../../arch/state/trap-context.md) 保存不能复活 squashed token 的 Block state。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/operands/local-generation-squash.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-OPERANDS-LOCAL-GENERATION-SQUASH","surface":"block","classification":["model","operands","local-generation-squash"],"depends_on":["PTO-ARCH-PROGRAMMING-MODEL-CORE-PE-TOPOLOGY","PTO-BLOCK-MODEL-OPERANDS-LOCAL-GENERATION","PTO-BLOCK-MODEL-STATE-CONTROL-STATE","PTO-BLOCK-MODEL-STATE-SHARED-GENERATION","PTO-BLOCK-MODEL-STATE-TYPES"]}
func SquashBundleExecutionDomain(domain: integer)
begin
    for slot = 0 to 63 do
        var covered: bits(2048) = Zeros{2048};
        var ready: bits(2048) = Zeros{2048};
        var writers_left: integer {0..16} = 0;
        var compacted_writers: LocalGenerationWriterSnapshot =
            _LocalGenerations[[slot]].writers;
        for writer = 0 to _LocalGenerations[[slot]].writer_count - 1
            looplimit 16 do
            if _LocalGenerations[[slot]].writers[[writer]].valid &&
               _LocalGenerations[[slot]].writers[[writer]].identity
                   .execution_domain_token == domain then
                _LocalGenerations[[slot]].writers[[writer]].valid = FALSE;
                _LocalGenerations[[slot]].writers[[writer]].ready = FALSE;
            end;
        end;
        for writer = 0 to _LocalGenerations[[slot]].writer_count - 1
            looplimit 16 do
            if _LocalGenerations[[slot]].writers[[writer]].valid then
                compacted_writers[[writers_left]] =
                    _LocalGenerations[[slot]].writers[[writer]];
                writers_left = (writers_left + 1) as integer {0..16};
                for cell = 0 to 2047 do
                    if cell < _LocalGenerations[[slot]].writers[[writer]]
                        .cell_count then
                        let index = _LocalGenerations[[slot]].writers[[writer]]
                            .offset_cells + cell;
                        if index < 2048 then
                            covered[index] = '1';
                            if _LocalGenerations[[slot]].writers[[writer]].ready then
                                ready[index] = '1';
                            end;
                        end;
                    end;
                end;
            end;
        end;
        _LocalGenerations[[slot]].covered_cells = covered;
        _LocalGenerations[[slot]].ready_cells = ready;
        for writer = writers_left to 15 do
            compacted_writers[[writer]].valid = FALSE;
            compacted_writers[[writer]].ready = FALSE;
        end;
        _LocalGenerations[[slot]].writers = compacted_writers;
        _LocalGenerations[[slot]].writer_count = writers_left as integer {0..16};
        for index = 0 to _LocalGenerations[[slot]].consumer_count - 1
            looplimit 16 do
            if _LocalGenerations[[slot]].consumers[[index]].valid &&
               _LocalGenerations[[slot]].consumers[[index]]
                   .execution_domain_token == domain then
                _LocalGenerations[[slot]].consumers[[index]].state =
                    BundleConsumerDependency_Cancelled;
                _LocalGenerations[[slot]].consumers[[index]].valid = FALSE;
            end;
        end;
        for pe = 0 to 3 do
            var pe_covered = Zeros{2048};
            var pe_ready = Zeros{2048};
            for writer = 0 to _LocalGenerations[[slot]].writer_count - 1
                looplimit 16 do
                if _LocalGenerations[[slot]].writers[[writer]].valid &&
                   _LocalGenerations[[slot]].writers[[writer]].pe_mask[
                       PTOPEMaskBitOfPEIdentity(pe)] == '1' then
                    for cell = 0 to 2047 do
                        if cell < _LocalGenerations[[slot]].writers[[writer]].cell_count &&
                           _LocalGenerations[[slot]].writers[[writer]].offset_cells + cell < 2048 then
                            let index = _LocalGenerations[[slot]].writers[[writer]].offset_cells + cell;
                            pe_covered[index] = '1';
                            if _LocalGenerations[[slot]].writers[[writer]].ready then
                                pe_ready[index] = '1';
                            end;
                        end;
                    end;
                end;
            end;
            _LocalGenerations[[slot]].per_pe_covered_cells[[pe]] = pe_covered;
            _LocalGenerations[[slot]].per_pe_ready_cells[[pe]] = pe_ready;
        end;
        if writers_left == 0 && _LocalGenerations[[slot]].open then
            AbortBundleLocalGeneration(slot);
        end;
    end;
    SquashPEOwnedSharedGenerationRequest(_CurrentModelCore,
        _CurrentKernelInvocation, domain);
    SquashSourceLifetimes(_CurrentModelCore,
        _CurrentKernelInvocation, domain);
end;

// PTO-NDF: PTO-B-ASSEMBLE-SPECULATION-001
// Architecture event entry point for an execution-domain squash.  The event
// is not instruction-encoded; a control-flow, fault, or interrupt mechanism
// invokes this procedure after the decoded writer path has registered its
// portable identity.
func EnterBundleExecutionDomainSquashEvent(domain: integer)
begin
    SquashBundleExecutionDomain(domain);
end;
```
<!-- GENERATED-ASL-END: unit -->

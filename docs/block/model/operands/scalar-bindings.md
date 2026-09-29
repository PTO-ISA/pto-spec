<!-- GENERATED FROM: asl/block/model/operands/scalar-bindings.asl -->
# Scalar Bindings

**Normative ASL source:** `asl/block/model/operands/scalar-bindings.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-OPERANDS-SCALAR-BINDINGS}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-operands-scalar-bindings-purpose role=purpose-scope -->
## Purpose and scope

This unit owns the writers of two kinds of bundle header state: the bundle argument and the scalar bindings. A scalar binding is the record left by one `B.IOR` header command. It names the general-purpose registers (GPRs) that a bundle operation reads and writes.

The unit only records selections. It reads no GPR and checks no operation schema.

<!-- PTO-READER-BLOCK: block-model-operands-scalar-bindings-concepts role=concepts-state -->
## Concepts and visible state

`_BundleScalarBindings` has `PTO_BUNDLE_SCALAR_BINDING_COUNT` (32) entries. Each `BundleScalarBinding` entry holds:

- `valid`;
- `destination` and `source0`, `source1`, `source2`, each a 5-bit register selector;
- `source_count`, from 0 to 3;
- `execution_mask_present`.

The bundle argument is `_BundleArgument` with its 3-bit kind `_BundleArgumentKind`. The architectural register `_CommitArgument` is also written by the argument setters.

<!-- PTO-READER-BLOCK: block-model-operands-scalar-bindings-rules role=rules-interactions -->
## Rules and interactions

`SetBundleScalarBinding` marks the entry valid, stores the four selectors and `source_count`, and clears `execution_mask_present`. `SetBundleScalarBindingWithExecutionMask` calls it and then stores the supplied `execution_mask_present` flag.

The `B.IOR` handler in the command-dispatch unit is the caller. It first checks that a bundle is in its header phase, that the target entry is free, that entry 0 is free unless a multi-record stream is selected, and that the stream placement rules for TGPR2T and TIMG2COL hold; it faults with `Fault_BundleControl` otherwise. It then writes entry 0, or entry 1 when a multi-record stream (TGPR2T, TIMG2COL, or an execution-mask GPR stream) is selected and entry 0 is already valid. It passes `source_count` 3, except 1 for the second TGPR2T record when no execution mask is present.

Design point: `source_count` is the encoded capacity of the record, not the operation's arity. The ASL comment states that effective arity always comes from the complete operation schema, and a zero-valued selector is not treated as an absent operand. A schema that needs a source reads that selector even when it names register 0.

Design point: the setter does not validate selectors or read registers. Apart from the TGPR2T and TIMG2COL placement checks in the `B.IOR` handler, selector legality and all value reads happen later, when the selected operation's schema runs, so a `B.IOR` command itself never reads a GPR.

`SetBundleArgument(value)` writes `value` to `_BundleArgument` and `_CommitArgument` and sets the kind to `001`. `SetBundleArgumentKind(kind, value)` does the same with a caller-chosen kind.

<!-- PTO-READER-BLOCK: block-model-operands-scalar-bindings-boundaries role=boundaries -->
## Architectural boundaries

`ClearBundleHeaderState` clears every scalar binding, `_BundleArgument`, and `_BundleArgumentKind` at each bundle start and after commit. Bindings never carry into another bundle.

In the current ASL no command handler calls `SetBundleArgument` or `SetBundleArgumentKind`, and the command catalog has no form with that handler. The bundle argument is otherwise written only by reset, header clearing, and trap-context restore.

<!-- PTO-READER-BLOCK: block-model-operands-scalar-bindings-example role=example-usage -->
## Non-normative reading example

This example illustrates the current ASL owner and does not replace the normative operation.

A TIMG2COL bundle carries two `B.IOR` records. The first, `B.IOR x10, x0, x0, ->x0`, writes entry 0 with `source0` 10 and `source_count` 3. Entry 0 is now valid, so the second, `B.IOR x11, x12, x13, ->x0`, writes entry 1. The execution unit later reads `GMBase` from entry 0 `source0` and the three parameter words from entry 1.

<!-- PTO-READER-BLOCK: block-model-operands-scalar-bindings-related role=related-owners-navigation -->
## Related owners

- [Commands](../dispatch/commands.md) holds the `B.IOR` handler that calls these setters.
- [Scalar schema](../dispatch/scalar-schema.md) chooses the entry index and reads the selectors.
- [Descriptor state](../state/descriptor-state.md) clears the bindings.
- [B.IOR](../../operands/B.IOR.md) is the command page.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/operands/scalar-bindings.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-OPERANDS-SCALAR-BINDINGS","surface":"block","classification":["model","operands","scalar-bindings"],"depends_on":["PTO-BLOCK-MODEL-OPERANDS-SHARED-BINDINGS"]}
func SetBundleArgument(value: Word)
begin
    _BundleArgument = value;
    _BundleArgumentKind = '001';
    _CommitArgument = value;
end;

func SetBundleArgumentKind(kind: bits(3), value: Word)
begin
    _BundleArgumentKind = kind;
    _BundleArgument = value;
    _CommitArgument = value;
end;

func SetBundleScalarBinding(index: BundleScalarBindingIndex,
                           destination: Reg5Selector,
                           source0: Reg5Selector,
                           source1: Reg5Selector,
                           source2: Reg5Selector,
                           source_count: integer {0..3})
begin
    // source_count records the encoded binding capacity for direct helper
    // users.  Architectural effective arity is always derived from the
    // complete operation schema; zero-valued unused selectors are not
    // inferred as absent.
    _BundleScalarBindings[[index]].valid = TRUE;
    _BundleScalarBindings[[index]].destination = destination;
    _BundleScalarBindings[[index]].source0 = source0;
    _BundleScalarBindings[[index]].source1 = source1;
    _BundleScalarBindings[[index]].source2 = source2;
    _BundleScalarBindings[[index]].source_count = source_count;
    _BundleScalarBindings[[index]].execution_mask_present = FALSE;
end;

func SetBundleScalarBindingWithExecutionMask(
    index: BundleScalarBindingIndex,
    destination: Reg5Selector,
    source0: Reg5Selector,
    source1: Reg5Selector,
    source2: Reg5Selector,
    source_count: integer {0..3},
    execution_mask_present: boolean)
begin
    SetBundleScalarBinding(index, destination, source0, source1, source2,
        source_count);
    _BundleScalarBindings[[index]].execution_mask_present =
        execution_mask_present;
end;
```
<!-- GENERATED-ASL-END: unit -->

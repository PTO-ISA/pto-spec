<!-- GENERATED FROM: asl/block/model/operands/scalar-bindings.asl -->
# Scalar Bindings

**Normative ASL source:** `asl/block/model/operands/scalar-bindings.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-OPERANDS-SCALAR-BINDINGS}

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
end;
```
<!-- GENERATED-ASL-END: unit -->

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->

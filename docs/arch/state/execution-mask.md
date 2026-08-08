<!-- GENERATED FROM: asl/arch/state/execution-mask.asl -->
# Execution Mask

**Normative ASL source:** `asl/arch/state/execution-mask.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-STATE-EXECUTION-MASK}

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/state/execution-mask.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-STATE-EXECUTION-MASK","surface":"arch","classification":["state","execution-mask"],"depends_on":["PTO-ARCH-STATE-PROGRAM-COUNTER"]}
readonly func ReadExecutionMask() => Word
begin
    return _ExecutionMask;
end;

func WriteExecutionMask(value: Word)
begin
    _ExecutionMask = value;
end;
```
<!-- GENERATED-ASL-END: unit -->

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->

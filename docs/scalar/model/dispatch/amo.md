<!-- GENERATED FROM: asl/scalar/model/dispatch/amo.asl -->
# AMO

**Normative ASL source:** `asl/scalar/model/dispatch/amo.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-SCALAR-MODEL-DISPATCH-AMO}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-model-dispatch-amo-purpose role=purpose-scope -->
## Purpose and scope

This unit executes every decoded scalar atomic form. `ExecuteDecodedAMOForm` selects the access width and operation from the mnemonic, reads the operands, and calls the helpers in [AMO semantics](../amo/semantics.md).

| Mnemonics | Helper | Width |
| --- | --- | --- |
| `LR.B`, `LR.H`, `LR.W`, `LR.D` | `ExecuteDecodedLoadReserved` | 1, 2, 4, 8 |
| `SC.B`, `SC.H`, `SC.W`, `SC.D` | `ExecuteDecodedStoreConditional` | 1, 2, 4, 8 |
| `SWAPB` through `SWAPD`, `LW.*`, `LD.*` | RMW with result | 1 to 8 |
| `SW.*`, `SD.*` | RMW without result | 4, 8 |
| `CASB` through `CASD` and `HL.CAS*` | `ExecuteDecodedCompareAndSwap` | 1 to 8 |
| `DMA` | `ExecuteScalarDMACopy64` | 64 bytes |

<!-- PTO-READER-BLOCK: scalar-model-dispatch-amo-concepts role=concepts-state -->
## Concepts and visible state

The memory order comes from the `aq` and `rl` bits through `ScalarDecodedMemoryOrder`: neither is relaxed, `aq` alone is acquire, `rl` alone is release, and both are acquire-release. Forms that do not encode a bit read it as 0.

For LR, SC, RMW, and CAS, the address comes from `ScalarDecodedAtomicAddress`, which reads a Reg5 register and passes it with the decoded `far` bit to `AtomicAddress`; in this model the address is unchanged. `DMA` reads its two addresses directly.

Operand roles differ by family:

- LR: address in `SrcL`.
- SC: data in `SrcL`, address in `SrcR`.
- RMW: address in `SrcL`, operand in `SrcR`.
- CAS: address in `SrcL`, expected value in `SrcR`, desired value in `SrcD`.
- `DMA`: source address in `SrcL`, destination address in `SrcR`.

<!-- PTO-READER-BLOCK: scalar-model-dispatch-amo-rules role=rules-interactions -->
## Rules and interactions

Each handler reads its registers and passes the values to the semantic helper. It then writes the destination only if `_LastFault` is `Fault_None`.

Design point: all operand reads happen before the memory transaction, and the destination write happens after it and only on success. A faulting atomic writes no register and no memory. An SC that matched the reservation and then faulted has still cleared it (see [AMO semantics](../amo/semantics.md)).

LR, RMW with result, and CAS write `NormalizeAtomicReturn` of the old value. That zero-extends byte and halfword values, sign-extends word values, and keeps doubleword values.

SC writes the status: 0 for success, 1 for a reservation miss.

`SW.*` and `SD.*` pass `write_result` as FALSE. They update memory like `LW.*` and `LD.*` but have no destination field.

`DMA` has no destination and no memory-order bits; its events are relaxed.

<!-- PTO-READER-BLOCK: scalar-model-dispatch-amo-boundaries role=boundaries -->
## Architectural boundaries

`ScalarAtomicOperationForOperation` maps the `LW`, `LD`, `SW`, and `SD` suffixes (ADD, AND, OR, XOR, SMIN, SMAX, UMIN, UMAX) to an `AtomicOperation`. Any other operation is `unreachable`.

LR forms carry a `SrcZero` field. The LR handler never reads it.

This unit does not advance TPC and does not check operand legality; top-level dispatch does both.

<!-- PTO-READER-BLOCK: scalar-model-dispatch-amo-example role=example-usage -->
## Non-normative reading example

Take the 32-bit word 0x2403028B. It matches `LR.W` (mask 0xF000707F, match 0x2000000B).

| Field | Bit(s) | Raw | Meaning |
| --- | --- | --- | --- |
| `RegDst` | 11:7 | 5 | GPR 5 |
| `SrcL` | 19:15 | 6 | address from GPR 6 |
| `rl` | 25 | 0 | no release |
| `aq` | 26 | 1 | acquire |
| `far` | 27 | 0 | near hint |

With GPR 6 holding 0x100 and the word at 0x100 equal to 0x80000000, the handler performs an acquire load of 4 bytes. It records the reservation at 0x100 and writes 0xFFFFFFFF80000000 to GPR 5, because word results are sign-extended.

<!-- PTO-READER-BLOCK: scalar-model-dispatch-amo-related role=related-owners-navigation -->
## Related owners

- [AMO semantics](../amo/semantics.md) owns the LR/SC, RMW, CAS, and DMA transactions.
- [Scalar decode helpers](decode.md) own `ScalarDecodedMemoryOrder` and `ScalarDecodedAtomicAddress`.
- [Scalar memory](../agu/memory.md) owns probing and faults.
- [Memory ordering](../../../arch/memory-model/ordering.md) owns the meaning of each memory order.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/scalar/model/dispatch/amo.asl -->
```asl
// PTO-UNIT: {"id":"PTO-SCALAR-MODEL-DISPATCH-AMO","surface":"scalar","classification":["model","dispatch","amo"],"depends_on":["PTO-SCALAR-MODEL-DISPATCH-DECODE","PTO-SCALAR-MODEL-AMO-SEMANTICS","PTO-SCALAR-CASB","PTO-SCALAR-CASD","PTO-SCALAR-CASH","PTO-SCALAR-CASW","PTO-SCALAR-DMA","PTO-SCALAR-HL-CASB","PTO-SCALAR-HL-CASD","PTO-SCALAR-HL-CASH","PTO-SCALAR-HL-CASW","PTO-SCALAR-LD-ADD","PTO-SCALAR-LD-AND","PTO-SCALAR-LD-OR","PTO-SCALAR-LD-SMAX","PTO-SCALAR-LD-SMIN","PTO-SCALAR-LD-UMAX","PTO-SCALAR-LD-UMIN","PTO-SCALAR-LD-XOR","PTO-SCALAR-LR-B","PTO-SCALAR-LR-D","PTO-SCALAR-LR-H","PTO-SCALAR-LR-W","PTO-SCALAR-LW-ADD","PTO-SCALAR-LW-AND","PTO-SCALAR-LW-OR","PTO-SCALAR-LW-SMAX","PTO-SCALAR-LW-SMIN","PTO-SCALAR-LW-UMAX","PTO-SCALAR-LW-UMIN","PTO-SCALAR-LW-XOR","PTO-SCALAR-SC-B","PTO-SCALAR-SC-D","PTO-SCALAR-SC-H","PTO-SCALAR-SC-W","PTO-SCALAR-SD-ADD","PTO-SCALAR-SD-AND","PTO-SCALAR-SD-OR","PTO-SCALAR-SD-SMAX","PTO-SCALAR-SD-SMIN","PTO-SCALAR-SD-UMAX","PTO-SCALAR-SD-UMIN","PTO-SCALAR-SD-XOR","PTO-SCALAR-SW-ADD","PTO-SCALAR-SW-AND","PTO-SCALAR-SW-OR","PTO-SCALAR-SW-SMAX","PTO-SCALAR-SW-SMIN","PTO-SCALAR-SW-UMAX","PTO-SCALAR-SW-UMIN","PTO-SCALAR-SW-XOR","PTO-SCALAR-SWAPB","PTO-SCALAR-SWAPD","PTO-SCALAR-SWAPH","PTO-SCALAR-SWAPW"]}
pure func ScalarAtomicOperationForOperation(operation: ScalarOperation)
        => AtomicOperation
begin
    case operation of
        when ScalarOperation_LD_ADD, ScalarOperation_LW_ADD,
             ScalarOperation_SD_ADD, ScalarOperation_SW_ADD =>
            return Atomic_ADD;
        when ScalarOperation_LD_AND, ScalarOperation_LW_AND,
             ScalarOperation_SD_AND, ScalarOperation_SW_AND =>
            return Atomic_AND;
        when ScalarOperation_LD_OR, ScalarOperation_LW_OR,
             ScalarOperation_SD_OR, ScalarOperation_SW_OR =>
            return Atomic_OR;
        when ScalarOperation_LD_XOR, ScalarOperation_LW_XOR,
             ScalarOperation_SD_XOR, ScalarOperation_SW_XOR =>
            return Atomic_XOR;
        when ScalarOperation_LD_SMIN, ScalarOperation_LW_SMIN,
             ScalarOperation_SD_SMIN, ScalarOperation_SW_SMIN =>
            return Atomic_SMIN;
        when ScalarOperation_LD_SMAX, ScalarOperation_LW_SMAX,
             ScalarOperation_SD_SMAX, ScalarOperation_SW_SMAX =>
            return Atomic_SMAX;
        when ScalarOperation_LD_UMIN, ScalarOperation_LW_UMIN,
             ScalarOperation_SD_UMIN, ScalarOperation_SW_UMIN =>
            return Atomic_UMIN;
        when ScalarOperation_LD_UMAX, ScalarOperation_LW_UMAX,
             ScalarOperation_SD_UMAX, ScalarOperation_SW_UMAX =>
            return Atomic_UMAX;
        otherwise => unreachable;
    end;
end;

func ExecuteDecodedLoadReserved(
    instruction: bits(48), form: integer {0..PTO_SCALAR_FORM_COUNT-1},
    size_bytes: integer {1,2,4,8})
begin
    let old_value = LoadReserved(
        ScalarDecodedAtomicAddress(instruction, form, ScalarField_SrcL),
        size_bytes, ScalarDecodedMemoryOrder(instruction, form));
    if _LastFault == Fault_None then
        WriteScalarDestination(
            ScalarDecodedSelector(instruction, form, ScalarField_RegDst),
            NormalizeAtomicReturn(old_value, size_bytes));
    end;
end;

func ExecuteDecodedStoreConditional(
    instruction: bits(48), form: integer {0..PTO_SCALAR_FORM_COUNT-1},
    size_bytes: integer {1,2,4,8})
begin
    let status = StoreConditional(
        ScalarDecodedAtomicAddress(instruction, form, ScalarField_SrcR),
        size_bytes,
        ReadDecodedScalarRegister(instruction, form, ScalarField_SrcL),
        ScalarDecodedMemoryOrder(instruction, form));
    if _LastFault == Fault_None then
        WriteScalarDestination(
            ScalarDecodedSelector(instruction, form, ScalarField_RegDst), status);
    end;
end;

func ExecuteDecodedAtomicReadModifyWrite(
    instruction: bits(48), form: integer {0..PTO_SCALAR_FORM_COUNT-1},
    operation: AtomicOperation, size_bytes: integer {1,2,4,8},
    write_result: boolean)
begin
    let old_value = AtomicReadModifyWrite(
        ScalarDecodedAtomicAddress(instruction, form, ScalarField_SrcL),
        size_bytes, operation,
        ReadDecodedScalarRegister(instruction, form, ScalarField_SrcR),
        ScalarDecodedMemoryOrder(instruction, form));
    if write_result && _LastFault == Fault_None then
        WriteScalarDestination(
            ScalarDecodedSelector(instruction, form, ScalarField_RegDst),
            NormalizeAtomicReturn(old_value, size_bytes));
    end;
end;

func ExecuteDecodedCompareAndSwap(
    instruction: bits(48), form: integer {0..PTO_SCALAR_FORM_COUNT-1},
    size_bytes: integer {1,2,4,8})
begin
    let old_value = CompareAndSwap(
        ScalarDecodedAtomicAddress(instruction, form, ScalarField_SrcL),
        size_bytes,
        ReadDecodedScalarRegister(instruction, form, ScalarField_SrcR),
        ReadDecodedScalarRegister(instruction, form, ScalarField_SrcD),
        ScalarDecodedMemoryOrder(instruction, form));
    if _LastFault == Fault_None then
        WriteScalarDestination(
            ScalarDecodedSelector(instruction, form, ScalarField_RegDst),
            NormalizeAtomicReturn(old_value, size_bytes));
    end;
end;

func ExecuteDecodedAMOForm(instruction: bits(48),
                           form: integer {0..PTO_SCALAR_FORM_COUNT-1})
begin
    let operation = ScalarOperationOfForm(form);
    case operation of
        when ScalarOperation_DMA =>
            ExecuteScalarDMACopy64(
                ReadDecodedScalarRegister(instruction, form, ScalarField_SrcL),
                ReadDecodedScalarRegister(instruction, form, ScalarField_SrcR));
        when ScalarOperation_LR_B =>
            ExecuteDecodedLoadReserved(instruction, form, 1);
        when ScalarOperation_LR_H =>
            ExecuteDecodedLoadReserved(instruction, form, 2);
        when ScalarOperation_LR_W =>
            ExecuteDecodedLoadReserved(instruction, form, 4);
        when ScalarOperation_LR_D =>
            ExecuteDecodedLoadReserved(instruction, form, 8);

        when ScalarOperation_SC_B =>
            ExecuteDecodedStoreConditional(instruction, form, 1);
        when ScalarOperation_SC_H =>
            ExecuteDecodedStoreConditional(instruction, form, 2);
        when ScalarOperation_SC_W =>
            ExecuteDecodedStoreConditional(instruction, form, 4);
        when ScalarOperation_SC_D =>
            ExecuteDecodedStoreConditional(instruction, form, 8);

        when ScalarOperation_SWAPB =>
            ExecuteDecodedAtomicReadModifyWrite(
                instruction, form, Atomic_SWAP, 1, TRUE);
        when ScalarOperation_SWAPH =>
            ExecuteDecodedAtomicReadModifyWrite(
                instruction, form, Atomic_SWAP, 2, TRUE);
        when ScalarOperation_SWAPW =>
            ExecuteDecodedAtomicReadModifyWrite(
                instruction, form, Atomic_SWAP, 4, TRUE);
        when ScalarOperation_SWAPD =>
            ExecuteDecodedAtomicReadModifyWrite(
                instruction, form, Atomic_SWAP, 8, TRUE);

        when ScalarOperation_CASB, ScalarOperation_HL_CASB =>
            ExecuteDecodedCompareAndSwap(instruction, form, 1);
        when ScalarOperation_CASH, ScalarOperation_HL_CASH =>
            ExecuteDecodedCompareAndSwap(instruction, form, 2);
        when ScalarOperation_CASW, ScalarOperation_HL_CASW =>
            ExecuteDecodedCompareAndSwap(instruction, form, 4);
        when ScalarOperation_CASD, ScalarOperation_HL_CASD =>
            ExecuteDecodedCompareAndSwap(instruction, form, 8);

        when ScalarOperation_LW_ADD, ScalarOperation_LW_AND,
             ScalarOperation_LW_OR, ScalarOperation_LW_XOR,
             ScalarOperation_LW_SMIN, ScalarOperation_LW_SMAX,
             ScalarOperation_LW_UMIN, ScalarOperation_LW_UMAX =>
            ExecuteDecodedAtomicReadModifyWrite(instruction, form,
                ScalarAtomicOperationForOperation(operation), 4, TRUE);
        when ScalarOperation_LD_ADD, ScalarOperation_LD_AND,
             ScalarOperation_LD_OR, ScalarOperation_LD_XOR,
             ScalarOperation_LD_SMIN, ScalarOperation_LD_SMAX,
             ScalarOperation_LD_UMIN, ScalarOperation_LD_UMAX =>
            ExecuteDecodedAtomicReadModifyWrite(instruction, form,
                ScalarAtomicOperationForOperation(operation), 8, TRUE);
        when ScalarOperation_SW_ADD, ScalarOperation_SW_AND,
             ScalarOperation_SW_OR, ScalarOperation_SW_XOR,
             ScalarOperation_SW_SMIN, ScalarOperation_SW_SMAX,
             ScalarOperation_SW_UMIN, ScalarOperation_SW_UMAX =>
            ExecuteDecodedAtomicReadModifyWrite(instruction, form,
                ScalarAtomicOperationForOperation(operation), 4, FALSE);
        when ScalarOperation_SD_ADD, ScalarOperation_SD_AND,
             ScalarOperation_SD_OR, ScalarOperation_SD_XOR,
             ScalarOperation_SD_SMIN, ScalarOperation_SD_SMAX,
             ScalarOperation_SD_UMIN, ScalarOperation_SD_UMAX =>
            ExecuteDecodedAtomicReadModifyWrite(instruction, form,
                ScalarAtomicOperationForOperation(operation), 8, FALSE);

        otherwise => unreachable;
    end;
end;
```
<!-- GENERATED-ASL-END: unit -->

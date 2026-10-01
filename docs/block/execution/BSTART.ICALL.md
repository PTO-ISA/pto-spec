<!-- GENERATED FROM: asl/block/execution/BSTART.ICALL.asl -->
# BSTART.ICALL

**Normative ASL source:** `asl/block/execution/BSTART.ICALL.asl`

Atomically retires the old block, snapshots its BARG.BPCN into a new indirect-call BARG, and writes the independent return target to ra.

## Normative identity {#PTO-INST-BLOCK-BSTART-ICALL}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-bstart-icall-purpose role=purpose -->
## What BSTART.ICALL contributes

`BSTART.ICALL` is the fused indirect call. It retires the block that is active, snapshots that block's `BARG.BPCN` as the call target, opens a new Standard indirect-call block, and publishes an independent return target to `ra`. The call target is not encoded in this command at all; only the return address is.

The one accepted spelling is `BSTART.ICALL <rt_label>, ->ra`, a 32-bit word with match `0x50166001` under mask `0xf83fffff`. The mask fixes the high discriminator bits and bits 21 to 0, and leaves the unsigned 5-bit `uimm5` visible in bits 26 to 22. `InstructionContractTransfer_BSTART_ICALL` returns `BundleTransfer_IndirectCall` and `InstructionContractWritesReturnAddress_BSTART_ICALL` returns TRUE.

Design point: `BSTART.STD CALL, <label>` and `BSTART.FP CALL, <label>` take their target from `simm17` and their return address from the sequential word. `BSTART.ICALL` reverses that split: the target comes from the retiring block's `BARG.BPCN` and the return target comes from `uimm5`. The observable consequence is that a caller can call a destination the closing block only knows as its own candidate continuation.

<!-- PTO-READER-BLOCK: block-bstart-icall-mechanism role=mechanism -->
## Placement and mechanism

The start decodes the word, checks its descriptor, and requires `RetiringBundleBPCNAvailable`: the bundle must be active and its `BARG.BlockType` must be Standard or Floating. Otherwise `Fault_BundleControl` is raised at the instruction, before any target or return-address effect. On the accepted path the call target is the snapshot of the retiring `BARG.BPCN` and the return target is `P + 2 + 2 * uimm5`.

Design point: the new block is installed only when the predecessor commit leaves the program counter at the address of this instruction. A predecessor whose commit selects a different continuation keeps that continuation and installs no call state, and `ra` keeps the value it had before.

<!-- PTO-READER-BLOCK: block-bstart-icall-inputs role=inputs-outputs -->
## Operands and header roles

- `uimm5` is the unsigned 5-bit return-address displacement in bits 26 to 22. It is a displacement from the embedded high `C.SETRET` halfword, so encoded zero is a real zero and selects `P + 2`, while `uimm5` 3 selects `P + 8`.
- The retiring block's `BARG.BPCN` supplies the call target. That value must have its low bit clear, and the retiring block must be Standard or Floating.
- `ra` receives the return target when the new block is installed; `ra` is GPR 10, and the same value is kept as the architectural return address.

<!-- PTO-READER-BLOCK: block-bstart-icall-effects role=effects -->
## Pending state and completion

On success the new block records the `BSTART.ICALL` address in `BARG.BPC`, sets `BARG.BlockType` to STD, stores the retiring `BARG.BPCN` snapshot in `BARG.BPCN`, records ICALL in `BARG.TYPE`, sets `BARG.TAKEN` to 1, and publishes the return target to `ra`. The call target becomes the next PC only when `BSTOP` or the next `BSTART` commits the new block.

Any memory effects of the retiring block complete before the indirect-call `BARG` and `ra` are published, and `BSTART.ICALL` itself performs no memory access. If the retiring commit fails, `ra` and the retiring `BARG` are preserved and no candidate `BARG` is installed.

Design point: because `ra` is written only in the installation step, every earlier failure leaves the previous `ra` intact. A handler can therefore tell from `ra` alone whether the call was installed, and a retry of the same instruction starts from the same snapshot.

<!-- PTO-READER-BLOCK: block-bstart-icall-constraints role=constraints -->
## Legality and fault boundary

- This fused form is the only accepted indirect-call spelling; bare `BSTART.* ICALL` forms are deleted.
- A System retiring block raises `Fault_BundleControl`, because a System `BARG` has no selecting `BPCN`.
- An odd retiring `BARG.BPCN` raises `Fault_InstructionPC` before the retiring-block effects.
- A decode, applicability, target, or retiring-commit failure preserves `ra` and the retiring `BARG`, and installs no candidate `BARG`.

<!-- PTO-READER-BLOCK: block-bstart-icall-example role=example -->
## Non-normative worked example

This worked example is non-normative; it illustrates the current owner without replacing it.

```asm
BSTART.ICALL <rt_label>, ->ra
```

Assume the enclosing block was opened by `BSTART.STD DIRECT, callee`, so its `BARG.BPCN` holds `callee`. The `BSTART.ICALL` closing that block then calls `callee` and writes `P + 2` to `ra` when `uimm5` is 0, or `P + 8` when `uimm5` is 3. A matching `BSTART.STD RET` in the callee eventually continues at the value `ra` holds.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
BSTART.ICALL <rt_label>, ->ra
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| bstart_icall_32_50166001 | L32 | 32 | 0x50166001 / 0xf83fffff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| bstart_icall_32_50166001 | uimm5 | 5 | unsigned | [{"instruction_lsb":22,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| bstart_icall_32_50166001 | uimm5 | 5 | 0–31 | none | none | unsigned return-address displacement from the embedded high halfword | Encoded zero selects P+2 as the return target. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| uimm5 | unsigned return-address displacement from the embedded high halfword |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/execution/BSTART.ICALL.asl -->
```asl
readonly func InstructionContractMatches_BSTART_ICALL(operation: CommandOperation) => boolean
begin
    return operation == CommandOperation_bstart_icall_32_50166001;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.ICALL retires one active Standard or Floating block whose BARG.BPCN supplies the call target, then atomically opens a new Standard indirect-call block and writes ra.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/execution/BSTART.ICALL.asl -->
```asl
readonly func InstructionContractHandler_BSTART_ICALL() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;

readonly func InstructionContractTransfer_BSTART_ICALL()
    => BundleTransfer
begin
    return BundleTransfer_IndirectCall;
end;

pure func InstructionContractWritesReturnAddress_BSTART_ICALL()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Encoded uimm5 zero is a real zero displacement from the embedded C.SETRET halfword.

## Legality

- This fused form is the only accepted indirect-call spelling; bare BSTART.* ICALL forms are deleted.
- The retiring block must be Standard or Floating because System BARG has no selecting BPCN.

## State effects

- Installs BARG.BPC=P, BlockType=STD, BPCN=the retiring BARG.BPCN snapshot, TYPE=ICALL, TAKEN=1, and writes return_target to ra.
- The indirect target is selected only when the new block later commits.

## Memory effects and ordering

### Memory effects

- Any memory effects of the retiring block complete before the indirect-call BARG and ra are published; BSTART.ICALL itself performs no memory access.

### Ordering

- Snapshot and validate retiring BARG.BPCN, successfully commit the retiring block, then atomically install the new STD BARG and write ra.

## Exceptions

- No active retiring Standard or Floating block raises Fault_BundleControl before target or return-address effects.
- An odd retiring BARG.BPCN raises Fault_InstructionPC before retiring-block effects.
- Decode, applicability, target, or retiring-commit failure preserves ra and the retiring BARG and installs no candidate BARG.

## Examples

- BSTART.ICALL <rt_label>, ->ra

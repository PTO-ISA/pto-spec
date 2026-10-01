<!-- GENERATED FROM: asl/arch/dispatch/top-level.asl -->
# Top Level

**Normative ASL source:** `asl/arch/dispatch/top-level.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-DISPATCH-TOP-LEVEL}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-dispatch-top-level-purpose-scope role=purpose-scope -->
## Purpose and scope

`ExecutePTOInstruction` is the single decoded-instruction entry point on this page. It takes an already-fetched carrier as `instruction: bits(64)` plus `length_bits: integer {16,32,48,64}`, and returns `PTOInstruction_Executed` or `PTOInstruction_Rejected`.

`ExecuteNextPTOInstruction` is the fetch side: it reads the program counter, probes and fetches the bytes, then calls `ExecutePTOInstruction`.

<!-- PTO-READER-BLOCK: arch-dispatch-top-level-concepts-state role=concepts-state -->
## The decision order

The dispatcher asks one question first: `DecodeCommandForm(instruction, length_bits)`. That result is tested before `length_bits` is examined, and a length that yields a form goes to `ExecuteCommandInstruction` with the whole `bits(64)` carrier.

- `length_bits != 64`: the low `48` bits, `instruction[47:0]`, go to `ExecuteScalarInstruction`, and `length_bits` is narrowed to `16`, `32`, or `48`.
- `length_bits == 64`: no second decoder runs. The dispatcher calls `BeginArchitecturalInstructionAttempt()`, then `SetFault(Fault_IllegalInstruction, ReadTPC())`, and returns `PTOInstruction_Rejected`.
- In the two delegating branches a non-`Executed` owner status becomes `PTOInstruction_Rejected`.

Design point: the unmatched `64`-bit case is separated from the scalar case even though `ExecuteScalarInstruction` would accept a `48`-bit slice. A `64`-bit value with no command form therefore cannot reach scalar decoding, and is never silently decoded from its low `48` bits.

<!-- PTO-READER-BLOCK: arch-dispatch-top-level-rules-interactions role=rules-interactions -->
## Rules and interactions

`ExecuteNextPTOInstruction` reads `ReadTPC()` once and rejects an odd address before any memory probe: if `instruction_pc[0] == '1'`, it raises `Fault_InstructionPC` there and returns `PTOInstruction_Rejected`.

Otherwise it probes `2` bytes, fetches a `16`-bit prefix, and derives the length from `prefix[15:0]` through `DeterminePTOInstructionLength`; the table below lists the four corners of that rule.

A second probe covers the whole selected range, `size_bytes = length_bits DIV 8`, one of `2`, `4`, `6`, or `8`. It must be permitted and must report the same `physical_address` as the prefix probe, or the fetch raises `Fault_InstructionPage` at the original TPC. `TranslateInstructionAddress` returns its argument unchanged, so in this model that address equality always holds.

Design point: the complete-range probe runs after the `16`-bit prefix read and before the remaining bytes. `FetchPTOInstruction` asserts `probe.permitted` and assembles only the probed `size_bytes` into a `Zeros{64}` carrier, so a range that fails the second probe faults at the original TPC with no further byte read.

Design point: exactly one architectural attempt is begun per call. The command and scalar owners each begin their own attempt inside their bodies, and the dispatcher begins one only on the unmatched `64`-bit path, so architectural time advances by one unit per dispatch and `_LastFault` is cleared once before the selected owner runs.

<!-- PTO-READER-BLOCK: arch-dispatch-top-level-boundaries role=boundaries -->
## Architectural boundaries

`ExecutePTOInstruction` performs no legality check of its own. A matched command form is checked by `ExecuteCommandInstruction`: `Fault_IllegalInstruction` when `CommandFormOperandsLegal` fails, `Fault_BundleControl` when a pending terminal block state forbids the selected handler. A matched scalar form is checked by `ExecuteScalarInstruction`: `Fault_BundleControl` for an inapplicable operation, `Fault_IllegalInstruction` for form, register, and implicit-source legality failures.

The scalar owner reports illegal-instruction faults at `ReadPC()` and the dispatcher reports the unmatched `64`-bit fault at `ReadTPC()`; both read the same `_PC` variable.

Design point: `DecodeCommandForm` is called twice for a matched command form, once by the dispatcher and once inside `ExecuteCommandInstruction`. It is a pure function of carrier and length, so both calls return the same form; the dispatcher passes no decoded form, and the command owner stays correct when entered directly.

What stays unchanged: the dispatcher writes no register itself. On the unmatched `64`-bit path the changes come from its callees: `BeginArchitecturalInstructionAttempt` clears `_LastFault` and `_FaultAddress` and advances architectural time, and `SetFault` records the per-ring trap fields, switches the current ACR, and redirects TPC to the trap vector entry.

<!-- PTO-READER-BLOCK: arch-dispatch-top-level-example-usage role=example-usage -->
## Non-normative reading example

The length rule has four corners; each fixes how many bytes the complete probe covers.

| first halfword | selected length | bytes probed |
| --- | --- | --- |
| bits `3:1` are `'111'`, bit `0` is `'1'` | `64` | `8` |
| bits `3:1` are `'111'`, bit `0` is `'0'` | `48` | `6` |
| bits `3:1` are not `'111'`, bit `0` is `'0'` | `16` | `2` |
| bits `3:1` are not `'111'`, bit `0` is `'1'` | `32` | `4` |

For a `16`-bit length the carrier is assembled into a `Zeros{64}` value, so bits `15:0` hold the two bytes and bits `63:16` stay `0`; with no command form, `ExecutePTOInstruction` passes `instruction[47:0]` to `ExecuteScalarInstruction` with length `16`.

<!-- PTO-READER-BLOCK: arch-dispatch-top-level-related-owners role=related-owners-navigation -->
## Related owners

- [Instruction fetch](../memory-model/instruction-fetch.md) owns both probes and the length rule.
- [Command dispatch owner](../../block/model/dispatch/top-level.md) owns command-form legality and bundle effects.
- [Scalar dispatch owner](../../scalar/model/dispatch/top-level.md) owns scalar decode and the TPC advance.
- [Program counter](../state/program-counter.md) defines the shared `_PC` behind `ReadTPC()` and `ReadPC()`.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/dispatch/top-level.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-DISPATCH-TOP-LEVEL","surface":"arch","classification":["dispatch","top-level"],"depends_on":["PTO-ARCH-MEMORY-MODEL-INSTRUCTION-FETCH","PTO-BLOCK-MODEL-DISPATCH-TOP-LEVEL","PTO-SCALAR-MODEL-DISPATCH-TOP-LEVEL"]}

// NDF-BEGIN: PTO-REQ-INSTRUCTION-DISPATCH-001
// ndf: kind=contract level=L1 layer=architecture status=accepted
// ExecutePTOInstruction is the unique encoded-instruction entry point. It MUST
// prefer an accepted 64-bit command form, dispatch non-64-bit input to scalar
// decoding, and reject an otherwise unmatched 64-bit value with
// Fault_IllegalInstruction after beginning exactly one architectural attempt.
// ExecuteNextPTOInstruction MUST fetch through PTO-REQ-INSTRUCTION-FETCH-001
// and then invoke this encoded entry point without adding another decoder.
// NDF-END: PTO-REQ-INSTRUCTION-DISPATCH-001

type PTOInstructionExecutionStatus of enumeration {
    PTOInstruction_Executed,
    PTOInstruction_Rejected
};

func ExecutePTOInstruction(instruction: bits(64),
                           length_bits: integer {16,32,48,64})
                           => PTOInstructionExecutionStatus
begin
    if DecodeCommandForm(instruction, length_bits) != PTO_COMMAND_FORM_COUNT then
        let command_status = ExecuteCommandInstruction(instruction, length_bits);
        if command_status == CommandExecution_Executed then
            return PTOInstruction_Executed;
        else
            return PTOInstruction_Rejected;
        end;
    elsif length_bits != 64 then
        let scalar_status = ExecuteScalarInstruction(
            instruction[47:0], length_bits as integer {16,32,48});
        if scalar_status == ScalarExecution_Executed then
            return PTOInstruction_Executed;
        else
            return PTOInstruction_Rejected;
        end;
    else
        BeginArchitecturalInstructionAttempt();
        SetFault(Fault_IllegalInstruction, ReadTPC());
        return PTOInstruction_Rejected;
    end;
end;

func ExecuteNextPTOInstruction() => PTOInstructionExecutionStatus
begin
    let instruction_pc = ReadTPC();

    if instruction_pc[0] == '1' then
        SetFault(Fault_InstructionPC, instruction_pc);
        return PTOInstruction_Rejected;
    end;

    let prefix_probe = ProbeInstructionAccess(instruction_pc, 2);
    if !prefix_probe.permitted then
        SetFault(Fault_InstructionPage, instruction_pc);
        return PTOInstruction_Rejected;
    end;

    let prefix = FetchPTOInstruction(prefix_probe, 16);
    let length_bits = DeterminePTOInstructionLength(prefix[15:0]);
    let size_bytes = (length_bits DIV 8) as integer {2,4,6,8};
    let complete_probe = ProbeInstructionAccess(
        instruction_pc,
        size_bytes);
    if !complete_probe.permitted ||
       complete_probe.physical_address != prefix_probe.physical_address then
        SetFault(Fault_InstructionPage, instruction_pc);
        return PTOInstruction_Rejected;
    end;

    let instruction = FetchPTOInstruction(complete_probe, length_bits);
    return ExecutePTOInstruction(instruction, length_bits);
end;
```
<!-- GENERATED-ASL-END: unit -->

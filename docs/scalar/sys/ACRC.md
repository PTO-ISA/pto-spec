<!-- GENERATED FROM: asl/scalar/sys/ACRC.asl -->
# ACRC

**Normative ASL source:** `asl/scalar/sys/ACRC.asl`

ACRC requests context close and marks the final scalar position of the active SYS block.

## Normative identity {#PTO-INST-SCALAR-ACRC}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-acrc-purpose role=purpose -->
## What ACRC does

`ACRC` is the context-close request. It carries a 4-bit record type and, when the current access-control ring permits that request type, marks the end of the active SYS block and hands control to the architecture through a service-request trap.

It does not return a value and does not write any destination. On an accepted request its whole effect is the request it publishes and the final-position marker it sets on the block.

<!-- PTO-READER-BLOCK: scalar-acrc-mechanism role=mechanism -->
## How the instruction is placed and executed

This instruction is one scalar operation of an active SYS block. The scalar dispatcher first checks that a bundle is active and that its body is active with block kind System; a SYS form outside such a block is rejected with `Fault_BundleControl`, before any encoded-field check and before any architectural effect.

Encoded legality and source availability are then checked, and only then does the handler run.

`RST_Type` is a 4-bit field whose every value is an assigned encoding. The handler does not test the encoded value directly; it hands it to the architecture close-request rule, which asks the access-control table whether the current ring may issue this request type.

When the request is permitted, the handler first sets the block's terminal marker and then enters the service-request trap. The trap saves the pre-instruction context of the target ring, records the request type as the trap cause, sets trap number `6`, sets the fault address to the request site, and switches the current ring to the trap target. Request types `0` and `1` differ only in their target ring.

Design point: the terminal marker is set before the trap entry, not after. That is what makes the final-position rule survive the trap: once the trap returns, the block still knows that its last scalar position was consumed, so it cannot silently continue executing further scalar operations.

<!-- PTO-READER-BLOCK: scalar-acrc-inputs-outputs role=inputs-outputs -->
## Inputs and outputs

- `RST_Type` is the only encoded operand: a 4-bit return-stack record type. All sixteen values are assigned encodings; encoded zero is a real request type, not an omission.
- There is no destination field, so the instruction never pushes `T` or `U` and never writes a GPR.
- There is no source field, so no scalar register or queue entry is read.

<!-- PTO-READER-BLOCK: scalar-acrc-effects role=effects -->
## Architectural effects

On a permitted request the published effects are the service-request trap, the recorded request type, and one increment of the architecture-request epoch. The current ring becomes the trap target and `TPC` takes that ring's trap vector entry, so the ordinary `4`-byte advance does not apply.

After recovery, the block's terminal marker is still set. While it is set, a command instruction that is neither a bundle stop nor a bundle start is rejected with `Fault_BundleControl`, and a scalar instruction is rejected the same way. Only a bundle stop or a following bundle start can commit the block.

If the request is not permitted, the handler faults with `Fault_IllegalInstruction` before the terminal marker is set, so a rejected request leaves the block fully usable: no request is published, the epoch does not advance, and no trap cause is recorded.

<!-- PTO-READER-BLOCK: scalar-acrc-constraints role=constraints -->
## Placement and rejection

Invalid block placement is rejected first, with `Fault_BundleControl`, before the encoded field is even considered. A SYS operation outside the body of an active SYS block falls in that class.

The instruction is a terminating scalar position: it must be the final scalar operation of its block.

The permission table is what decides instruction-local acceptance, and it is consulted before the terminal marker is set. At the root ring no request type is permitted at all. At ring `1` only request types `0` and `2` are permitted. At rings `2` through `15` request types `0`, `1` and `2` are permitted. Every other four-bit value is rejected in every ring. The same encoded `RST_Type` therefore has different outcomes in different rings: only at the root ring is every value rejected.

<!-- PTO-READER-BLOCK: scalar-acrc-example role=example -->
## Non-normative example

`acrc rst_type` names the request through its `RST_Type` field. With `RST_Type=0` at a ring other than the root ring the request is accepted: the terminal marker is set and the service-request trap switches the current ring to the trap target. At the root ring the same instruction raises `Fault_IllegalInstruction` before the terminal marker is set, and the block keeps executing.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
acrc rst_type
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| acrc_32_a9c0e33f9904 | L32 | 32 | 0x0000302b / 0xff0fffff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| acrc_32_a9c0e33f9904 | RST_Type | 4 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":4}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| acrc_32_a9c0e33f9904 | RST_Type | 4 | 0–15 | none | none | return-stack record type | Encoded zero selects value zero of the return-stack record type. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RST_Type | return-stack record type |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/ACRC.asl -->
```asl
readonly func InstructionContractOperation_ACRC()
    => ScalarOperation
begin
    return ScalarOperation_ACRC;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
ACRC executes as one scalar operation in the body of an active SYS block.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/ACRC.asl -->
```asl
readonly func InstructionContractHandler_ACRC()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ArchitectureCloseRequest;
end;

pure func InstructionContractRequiresSystemBlock_ACRC()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractRequestWidth_ACRC()
    => integer {4}
begin
    return 4;
end;

pure func InstructionContractIsTerminalScalar_ACRC()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Every displayed operand is encoded explicitly. Encoded zero is an assigned value and never denotes omission.

## Legality

- Every fixed bit and explicit field constraint is checked before operation semantics.
- All four-bit request values are encoded; manager routing and current-ACR permission determine instruction-local acceptance.

## State effects

- A permitted request publishes the service-request trap, request type, and architecture-request epoch.
- After recovery, only BSTOP or a following BSTART may commit the block; another instruction raises Illegal Block Exception before effects.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Preflight request routing before setting the terminal marker or entering the service-request trap.
- On permission success, set the SYS terminal marker before trap entry so recovery preserves the final-position rule.

## Exceptions

- Invalid block placement raises Illegal Block Exception before encoded-field legality or effects.
- A reserved encoding or rejected access raises Illegal Instruction before destination, queue, system-state, or TPC effects.

## Examples

- acrc rst_type

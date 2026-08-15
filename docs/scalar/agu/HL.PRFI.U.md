<!-- GENERATED FROM: asl/scalar/agu/HL.PRFI.U.asl -->
# HL.PRFI.U

**Normative ASL source:** `asl/scalar/agu/HL.PRFI.U.asl`

HL.PRFI.U snapshots its scalar sources, forms its encoded address, and issues a non-binding 1-byte-granularity prefetch hint with no destination effect.

## Normative identity {#PTO-INST-SCALAR-HL-PRFI-U}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
hl.prfi.u{.l1,.l2,.l3} [SrcL, simm]
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_prfi_u_48_be73891e376e | HL48 | 48 | 0x00007029000e / 0x00007fff003f | [{"field":"model","operator":"one-of","values":[0,1,2]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_prfi_u_48_be73891e376e | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_prfi_u_48_be73891e376e | model | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_prfi_u_48_be73891e376e | simm17 | 17 | signed | [{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":6,"value_lsb":12,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_prfi_u_48_be73891e376e | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| hl_prfi_u_48_be73891e376e | model | 5 | 0–2 | none | 3–31 | cache-level hint selector | Encoded zero selects the non-binding L1 cache hint. |
| hl_prfi_u_48_be73891e376e | simm17 | 17 | 0–131071 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

- `hl_prfi_u_48_be73891e376e.model` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 address-base source |
| model | cache-level hint selector |
| simm17 | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.PRFI.U.asl -->
```asl
readonly func InstructionContractOperation_HL_PRFI_U() => ScalarOperation
begin
    return ScalarOperation_HL_PRFI_U;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.PRFI.U.asl -->
```asl
readonly func InstructionContractHandler_HL_PRFI_U()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarPrefetch;
end;

pure func InstructionContractAGUAction_HL_PRFI_U()
    => ScalarAGUAction
begin
    return ScalarAGU_Prefetch;
end;

pure func InstructionContractAGUAddressKind_HL_PRFI_U()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Immediate;
end;

pure func InstructionContractAGUSizeBytes_HL_PRFI_U()
    => integer {1,2,4,8}
begin
    return 1;
end;

pure func InstructionContractAGUOffsetScale_HL_PRFI_U()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_HL_PRFI_U()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_HL_PRFI_U()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_PRFI_U()
    => boolean
begin
    return FALSE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Every displayed operand field is encoded explicitly; encoded zero is a value and never denotes omission.
- model=0 selects L1, model=1 selects L2, and model=2 selects L3; the cache target is a non-binding performance hint.

## Legality

- Every encoded Reg5 source uses the complete domain: codes 0..23 select absolute GPRs, codes 24..27 select T#1..T#4, and codes 28..31 select U#1..U#4 without consumption.
- simm17 assigns every signed 17-bit value -65536..65535; the encoded byte displacement is that value multiplied by 1.
- model codes 0, 1, and 2 are assigned; codes 3..31 are reserved and raise Fault_IllegalInstruction before any scalar source read or architectural effect.

## State effects

- Sign-extend simm17, multiply it by 1, and add it modulo 2^PTO_XLEN to the SrcL base.
- Discard the formed address after issuing the non-binding hint; no encoded field publishes a result.
- Successful execution advances TPC by 6 bytes; a rejected or faulting attempt does not retire.

## Memory effects and ordering

### Memory effects

- The 1-byte-granularity hint performs no architectural translation, permission or alignment check, memory access, memory event, reservation update, ordering edge, or cache-placement guarantee.

### Ordering

- Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.
- For a legal model, form the hint, publish the optional address result, and then advance TPC by 6 bytes.

## Exceptions

- A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.
- A legal prefetch model cannot raise a data-access fault. A reserved model rejects before source reads and before optional address publication.

## Examples

- hl.prfi.u{.l1,.l2,.l3} [SrcL, simm]

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->

# ADR 0056: DataType code 31 is DTYPE_NONE

- Status: accepted
- Date: 2026-08-12
- Requirement: `PTO-REQ-BUNDLE-OPERATION-001`
- Decision source: [pto-spec issue 68](https://github.com/PTO-ISA/pto-spec/issues/68)

## Context

Some descriptor-preserving bundle operations need an encoded DataType field
without selecting a numerical format. Treating code 31 as a concrete type or a
default such as U8 would merge field validity with effective-type resolution
and could silently change destination descriptors.

## Decision

Encoded DataType value 31 has canonical spelling `DTYPE_NONE`. It is a valid
bundle-field sentinel but is not a `TileDataType`, has no element width, and
has no arithmetic, conversion, or packing meaning. Other unassigned DataType
codes remain illegal.

Effective DataType resolution uses this precedence:

1. a concrete `B.DATR` DataType;
2. a concrete BSTART DataType;
3. for descriptor-preserving TMOV only, an architecturally bound Local or
   Shared source descriptor.

`B.DATR DTYPE_NONE` applies its other legal fields but does not override a
concrete BSTART type. A source descriptor is the only permitted inheritance
source; allocation size and other heuristics MUST NOT infer a type. If an
operation requires a concrete type and resolution fails, the bundle produces
`Fault_TileLegality` before allocation, source consumption, or other effects.

Code 31 is decode-valid only in `B.DATR` and `BSTART.TMOV` for PTO ISA 0.58.0.
This is a corrigendum within the existing architecture version, not a new
numerical-format allocation.

## Consequences

ASL keeps encoded-field validity separate from concrete `TileDataType`
conversion. No path may pass code 31 to `TileDataTypeFromEncoding`, whose input
contract remains concrete-only. Assemblers and disassemblers use
`DTYPE_NONE`; profiles and implementations must keep it distinct from the
effective destination descriptor type.

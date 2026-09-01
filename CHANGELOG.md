# Changelog

This file is generated from accepted ADR metadata. It is a navigation aid,
not architecture authority; current meaning remains in the owning ASL/NDF.

## Release 0.58.5

### Block
- [ADR-0106](docs/status/decisions/0106-shared-source-subview-per-pe.md): Shared source B.SUBVIEW uses per-PE offsets

### Cross-cutting
- [ADR-0105](docs/status/decisions/0105-shared-whole-parent-readiness.md): Shared whole-parent readiness and single-issuer publication
- [ADR-0107](docs/status/decisions/0107-remove-legacy-shared-movement.md): Remove legacy Shared movement Functions
- [ADR-0108](docs/status/decisions/0108-0584-1-to-0585-compatibility.md): PTO ISA 0.58.4.1 to 0.58.5 compatibility boundary
- [ADR-0109](docs/status/decisions/0109-local-single-object-cap.md): Local single-object cap versus aggregate Local pool
- [ADR-0110](docs/status/decisions/0110-tcvt-cube-m16-m32-layout-closure.md): TCVT CUBE_M16 and CUBE_M32 layout closure
- [ADR-0112](docs/status/decisions/0112-tile-operation-type-roles-and-source-reinterpretation.md): Tile operation type roles and source reinterpretation
- [ADR-0113](docs/status/decisions/0113-cube-predicate-carriers-and-tgpr2t-superseding-contract.md): CUBE predicate carriers and TGPR2T superseding contract

### Tile
- [ADR-0103](docs/status/decisions/0103-private-cube-vector-and-cell-rearrangement.md): Private CUBE vector execution and CELL rearrangement

## Release 0.58.4

### Cross-cutting
- [ADR-0097](docs/status/decisions/0097-local-shared-capacity-and-cooperative-m-sharding.md): Local and Shared capacity pools with cooperative M-sharding
- [ADR-0098](docs/status/decisions/0098-b-range-modifiers.md): B.SUBVIEW and B.ASSEMBLE range-modifier association
- [ADR-0099](docs/status/decisions/0099-0583-to-0584-compatibility.md): PTO ISA 0.58.3 to 0.58.4 compatibility boundary
- [ADR-0100](docs/status/decisions/0100-cooperative-group-m-distribution.md): Cooperative Group-M Distribution and Inactive PE Semantics
- [ADR-0101](docs/status/decisions/0101-matrix-scale-and-cscale.md): Matrix Scale Cell Layouts, HiF4 Scale Words, and CScale

## Release 0.58.4.1

### Cross-cutting
- [ADR-0102](docs/status/decisions/0102-0584-1-publication-contract-corrections.md): PTO ISA 0.58.4.1 publication-contract correction boundary

## Release 0.58.3

### Architecture
- [ADR-0068](docs/status/decisions/0068-extension-first-use-profile-hook.md): Extension first-use is a target-profile hook

### Cross-cutting
- [ADR-0064](docs/status/decisions/0064-b-fpatr-complete-bundle-postprocess.md): B.FPATR Complete-Bundle Matrix PostProcess
- [ADR-0070](docs/status/decisions/0070-gm-local-cube-layout-transport.md): GM/Local CUBE Layout Transport
- [ADR-0071](docs/status/decisions/0071-local-cube-matrix-operands.md): Local CUBE Matrix Operand Contract
- [ADR-0072](docs/status/decisions/0072-cooperative-shared-cube-transpose.md): Cooperative Shared CUBE Inputs and Transpose
- [ADR-0073](docs/status/decisions/0073-cube-accumulator-atomic-output.md): CUBE Accumulator and Atomic Output Contract
- [ADR-0074](docs/status/decisions/0074-tload-tstore-gm-byte-row-stride.md): TLOAD/TSTORE GM Byte Row Stride
- [ADR-0096](docs/status/decisions/0096-b-iot-b-ios-sizecode-pemode.md): Re-encode B.IOT and B.IOS size and PE mode fields

### Tile
- [ADR-0069](docs/status/decisions/0069-local-cube-cell-state-and-geometry.md): Local CUBE CELL State and Geometry

## Release 0.58.2

### Architecture
- [ADR-0067](docs/status/decisions/0067-conditional-branch-extension-reservation.md): conditional branch extension reservation

### Block
- [ADR-0076](docs/status/decisions/0076-block-scalar-and-tile-bindings.md): Block scalar and tile bindings

### Cross-cutting
- [ADR-0075](docs/status/decisions/0075-block-attributes-and-lifecycle.md): Block attributes and lifecycle
- [ADR-0077](docs/status/decisions/0077-block-start-and-extension-reservations.md): Block start and extension reservations
- [ADR-0078](docs/status/decisions/0078-tlsu-and-global-memory-operations.md): TLSU and global-memory operations
- [ADR-0079](docs/status/decisions/0079-cube-and-matrix-operations.md): CUBE and matrix operations
- [ADR-0080](docs/status/decisions/0080-tile-elementwise-and-irregular-operations.md): Tile elementwise and irregular operations
- [ADR-0081](docs/status/decisions/0081-tile-scalar-and-immediate-operations.md): Tile scalar and immediate operations
- [ADR-0082](docs/status/decisions/0082-tile-reduction-expansion-and-generation.md): Tile reduction, expansion, and generation
- [ADR-0083](docs/status/decisions/0083-tile-conversion-layout-and-partial-operations.md): Tile conversion, layout, and partial operations
- [ADR-0084](docs/status/decisions/0084-scalar-system-and-queue-operations.md): Scalar, system, and queue operations
- [ADR-0085](docs/status/decisions/0085-numeric-postprocess-and-format-operations.md): Numeric post-process and format operations

## Release 0.58.1

### Architecture
- [ADR-0036](docs/status/decisions/0036-formal-source-and-evidence-boundary.md): Formal source and evidence boundary

### Block
- [ADR-0060](docs/status/decisions/0060-l-bstop-common-long-form.md): Restore `L.BSTOP` as the common 64-bit bundle stop
- [ADR-0076](docs/status/decisions/0076-block-scalar-and-tile-bindings.md): Block scalar and tile bindings

### Cross-cutting
- [ADR-0052](docs/status/decisions/0052-direct-tile-and-bundle-catalog-closure.md): Direct Tile and bundle catalog closure
- [ADR-0059](docs/status/decisions/0059-mnemonic-field-encoding-closure.md): Mnemonic and Encoded-Field Contract Closure
- [ADR-0061](docs/status/decisions/0061-barg-bpcn-commit-state.md): Bundle commit state uses BARG/BPCN
- [ADR-0065](docs/status/decisions/0065-cube-matrix-family-contract.md): CUBE Matrix Family Contract
- [ADR-0075](docs/status/decisions/0075-block-attributes-and-lifecycle.md): Block attributes and lifecycle
- [ADR-0077](docs/status/decisions/0077-block-start-and-extension-reservations.md): Block start and extension reservations
- [ADR-0078](docs/status/decisions/0078-tlsu-and-global-memory-operations.md): TLSU and global-memory operations
- [ADR-0079](docs/status/decisions/0079-cube-and-matrix-operations.md): CUBE and matrix operations
- [ADR-0080](docs/status/decisions/0080-tile-elementwise-and-irregular-operations.md): Tile elementwise and irregular operations
- [ADR-0081](docs/status/decisions/0081-tile-scalar-and-immediate-operations.md): Tile scalar and immediate operations
- [ADR-0082](docs/status/decisions/0082-tile-reduction-expansion-and-generation.md): Tile reduction, expansion, and generation
- [ADR-0083](docs/status/decisions/0083-tile-conversion-layout-and-partial-operations.md): Tile conversion, layout, and partial operations
- [ADR-0084](docs/status/decisions/0084-scalar-system-and-queue-operations.md): Scalar, system, and queue operations
- [ADR-0085](docs/status/decisions/0085-numeric-postprocess-and-format-operations.md): Numeric post-process and format operations

## Release 0.58.0

### Cross-cutting
- [ADR-0053](docs/status/decisions/0053-pto-isa-0580-tile-operation-cleanup.md): PTO ISA 0.58.0 Tile Operation Cleanup
- [ADR-0054](docs/status/decisions/0054-pe-local-tile-size-and-32-bit-shared-io-binding.md): PE-Local Tile Size and 32-bit Shared I/O Binding
- [ADR-0064](docs/status/decisions/0064-b-fpatr-complete-bundle-postprocess.md): B.FPATR Complete-Bundle Matrix PostProcess

## Unassigned

### Architecture
- [ADR-0001](docs/status/decisions/0001-pto-architecture-scope.md): Define PTO as a scalar, bundle/command, and tile ISA
- [ADR-0005](docs/status/decisions/0005-pto-v0-concrete-reference-profile.md): PTO v0 concrete reference profile
- [ADR-0006](docs/status/decisions/0006-pto-total-store-order.md): PTO total store order candidate model
- [ADR-0010](docs/status/decisions/0010-acr-routing-and-context-reset.md): PTO v0 ACR routing and context reset
- [ADR-0011](docs/status/decisions/0011-visible-ebarg-snapshot.md): Make EBARG the visible PTO v0 trap snapshot
- [ADR-0016](docs/status/decisions/0016-interrupt-pending-and-timer-state.md): Define interrupt pending and timer state
- [ADR-0017](docs/status/decisions/0017-system-register-behavior-classes.md): Classify every visible system register behavior
- [ADR-0037](docs/status/decisions/0037-numeric-profile-identity-and-variation-framework.md): Numeric profile identity and bounded variation framework
- [ADR-0042](docs/status/decisions/0042-numeric-variation-point-ownership.md): Numeric variation-point ownership
- [ADR-0049](docs/status/decisions/0049-hardware-subnormal-policy.md): Hardware numeric subnormal policy

### Block
- [ADR-0022](docs/status/decisions/0022-bundle-operation-descriptor-and-commit.md): Bundle operation descriptor and transactional commit
- [ADR-0032](docs/status/decisions/0032-bundle-command-totality-and-profile-boundaries.md): Bundle-command totality and PTO-v0 profile boundaries
- [ADR-0055](docs/status/decisions/0055-complete-bundle-bior-schema-and-defaults.md): Complete-Bundle B.IOR Schema and Defaults

### Cross-cutting
- [ADR-0003](docs/status/decisions/0003-pto-owned-system-register-names.md): Use PTO-owned system-register names
- [ADR-0008](docs/status/decisions/0008-architectural-state-contract.md): Define the PTO architectural state contract
- [ADR-0009](docs/status/decisions/0009-scalar-tpc-and-execution-status.md): scalar TPC and execution status
- [ADR-0013](docs/status/decisions/0013-tile-capacity-and-packed-storage.md): Define tile capacity and packed storage
- [ADR-0014](docs/status/decisions/0014-element-level-tile-definedness.md): Track tile definedness per element
- [ADR-0015](docs/status/decisions/0015-explicit-tile-handoff-slots.md): Define explicit tile handoff slots
- [ADR-0018](docs/status/decisions/0018-pto-v0-trap-disposition.md): Define the PTO v0 disposition of every trap identity
- [ADR-0020](docs/status/decisions/0020-production-memory-events-and-atomic-corners.md): Production memory events and atomic corners
- [ADR-0021](docs/status/decisions/0021-scalar-pc-relative-and-return-address.md): Scalar PC-relative and return-address state
- [ADR-0023](docs/status/decisions/0023-uniform-instruction-attempt-status.md): Uniform instruction-attempt status and fault isolation
- [ADR-0031](docs/status/decisions/0031-scalar-sys-totality-and-profile-boundaries.md): Scalar SYS totality and PTO-v0 profile boundaries
- [ADR-0033](docs/status/decisions/0033-tlsu-four-bit-memory-packing.md): TLSU four-bit memory packing and totality
- [ADR-0034](docs/status/decisions/0034-cube-raw-carrier-totality.md): CUBE raw-carrier totality and composite preflight
- [ADR-0035](docs/status/decisions/0035-vec-sfu-carrier-totality.md): VEC/SFU carrier totality and profile boundary
- [ADR-0038](docs/status/decisions/0038-scalar-numeric-flag-state-and-ownership.md): Scalar numeric flag state and producer ownership
- [ADR-0039](docs/status/decisions/0039-numeric-rounding-selector-ownership.md): Numeric rounding selector ownership
- [ADR-0040](docs/status/decisions/0040-numeric-format-namespace-ownership.md): Numeric format namespace ownership
- [ADR-0041](docs/status/decisions/0041-a2a3-mx-profile-applicability.md): A2/A3 MX CUBE profile applicability
- [ADR-0043](docs/status/decisions/0043-public-numeric-type-identity-and-availability.md): Public numeric type identity and target availability
- [ADR-0047](docs/status/decisions/0047-numeric-rounding-semantics.md): Numeric rounding semantics
- [ADR-0048](docs/status/decisions/0048-numeric-format-value-classification.md): Numeric format value classification
- [ADR-0050](docs/status/decisions/0050-hardware-special-value-checkpoint.md): Hardware special-value result checkpoint
- [ADR-0056](docs/status/decisions/0056-pto-encoding-ownership-and-gm-access.md): PTO Encoding Ownership and Per-PE GM Access
- [ADR-0057](docs/status/decisions/0057-tile-classification-and-engine-aliases.md): Tile Classification and Execution-Engine Aliases
- [ADR-0058](docs/status/decisions/0058-complete-bundle-gpr-operand-resolution.md): Complete-Bundle GPR Operand Resolution

### Scalar
- [ADR-0012](docs/status/decisions/0012-acrc-service-request.md): Define PTO v0 ACRC service requests
- [ADR-0024](docs/status/decisions/0024-pc-relative-and-unscaled-agu-addressing.md): PC-relative and unscaled AGU addressing
- [ADR-0025](docs/status/decisions/0025-scalar-bitfield-and-reverse-bounds.md): Scalar bitfield and byte-reversal bounds
- [ADR-0026](docs/status/decisions/0026-scalar-alu-totality-and-alias-order.md): Scalar ALU totality and alias order
- [ADR-0027](docs/status/decisions/0027-scalar-bru-totality-and-target-legality.md): Scalar BRU totality and target legality
- [ADR-0028](docs/status/decisions/0028-scalar-fsu-totality-and-profile-boundary.md): Scalar FSU totality and numeric-profile boundary
- [ADR-0029](docs/status/decisions/0029-scalar-agu-totality-and-restart.md): Scalar AGU totality, aliases, and restart
- [ADR-0030](docs/status/decisions/0030-scalar-amo-totality-and-reservation.md): Scalar AMO totality, reservations, and restart
- [ADR-0066](docs/status/decisions/0066-addtpc-page-scaled-immediate.md): ADDTPC page-scaled immediate

### Tile
- [ADR-0044](docs/status/decisions/0044-public-integer-conversion-result-subset.md): Public integer conversion result subset

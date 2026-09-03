# Changelog

This file is generated from accepted ADR metadata. It is a navigation aid,
not architecture authority; current meaning remains in the owning ASL/NDF.

## Release 0.58.5

### Architecture
- [ADR-GOV-0001](docs/status/decisions/ADR-GOV-0001-pto-architecture-scope.md): Define PTO as a scalar, bundle/command, and tile ISA

### Block
- [ADR-CUBE-0015](docs/status/decisions/ADR-CUBE-0015-shared-source-subview-per-pe.md): Shared source B.SUBVIEW uses per-PE offsets

### Cross-cutting
- [ADR-BLOCK-0009](docs/status/decisions/ADR-BLOCK-0009-barg-bpcn-commit-state.md): Bundle commit state uses BARG/BPCN
- [ADR-BLOCK-0012](docs/status/decisions/ADR-BLOCK-0012-block-attributes-and-lifecycle.md): Block attributes and lifecycle
- [ADR-BLOCK-0017](docs/status/decisions/ADR-BLOCK-0017-local-single-object-cap.md): Local single-object cap versus aggregate Local pool
- [ADR-CUBE-0014](docs/status/decisions/ADR-CUBE-0014-shared-whole-parent-readiness.md): Shared whole-parent readiness and single-issuer publication
- [ADR-CUBE-0016](docs/status/decisions/ADR-CUBE-0016-remove-legacy-shared-movement.md): Remove legacy Shared movement Functions
- [ADR-CUBE-0017](docs/status/decisions/ADR-CUBE-0017-tcvt-cube-m16-m32-layout-closure.md): TCVT CUBE_M16 and CUBE_M32 layout closure
- [ADR-GOV-0005](docs/status/decisions/ADR-GOV-0005-mnemonic-field-encoding-closure.md): Mnemonic and Encoded-Field Contract Closure
- [ADR-GOV-0009](docs/status/decisions/ADR-GOV-0009-0584-1-to-0585-compatibility.md): PTO ISA 0.58.4.1 to 0.58.5 compatibility boundary
- [ADR-MEM-0009](docs/status/decisions/ADR-MEM-0009-tlsu-and-global-memory-operations.md): TLSU and global-memory operations
- [ADR-SCALAR-0004](docs/status/decisions/ADR-SCALAR-0004-scalar-fsu-totality-and-profile-boundary.md): Scalar FSU totality and numeric-profile boundary
- [ADR-SCALAR-0006](docs/status/decisions/ADR-SCALAR-0006-scalar-system-and-queue-operations.md): Scalar, system, and queue operations
- [ADR-TILE-0004](docs/status/decisions/ADR-TILE-0004-bundle-command-totality-and-profile-boundaries.md): Bundle-command totality and PTO-v0 profile boundaries
- [ADR-TILE-0008](docs/status/decisions/ADR-TILE-0008-tile-elementwise-and-irregular-operations.md): Tile elementwise and irregular operations

### Scalar
- [ADR-MEM-0004](docs/status/decisions/ADR-MEM-0004-scalar-agu-totality-and-restart.md): Scalar AGU totality, aliases, and restart
- [ADR-SCALAR-0001](docs/status/decisions/ADR-SCALAR-0001-scalar-bitfield-and-reverse-bounds.md): Scalar bitfield and byte-reversal bounds

### Tile
- [ADR-CUBE-0013](docs/status/decisions/ADR-CUBE-0013-private-cube-vector-and-cell-rearrangement.md): Private CUBE vector execution and CELL rearrangement

## Release 0.58.4

### Cross-cutting
- [ADR-BLOCK-0016](docs/status/decisions/ADR-BLOCK-0016-b-range-modifiers.md): B.SUBVIEW and B.ASSEMBLE range-modifier association
- [ADR-CUBE-0010](docs/status/decisions/ADR-CUBE-0010-local-shared-capacity-and-cooperative-m-sharding.md): Local and Shared capacity pools with cooperative M-sharding
- [ADR-CUBE-0011](docs/status/decisions/ADR-CUBE-0011-cooperative-group-m-distribution.md): Cooperative Group-M Distribution and Inactive PE Semantics
- [ADR-CUBE-0012](docs/status/decisions/ADR-CUBE-0012-matrix-scale-and-cscale.md): Matrix Scale Cell Layouts, HiF4 Scale Words, and CScale
- [ADR-GOV-0007](docs/status/decisions/ADR-GOV-0007-0583-to-0584-compatibility.md): PTO ISA 0.58.3 to 0.58.4 compatibility boundary

## Release 0.58.4.1

### Cross-cutting
- [ADR-GOV-0008](docs/status/decisions/ADR-GOV-0008-0584-1-publication-contract-corrections.md): PTO ISA 0.58.4.1 publication-contract correction boundary

## Release 0.58.3

### Architecture
- [ADR-BLOCK-0011](docs/status/decisions/ADR-BLOCK-0011-extension-first-use-profile-hook.md): Extension first-use is a target-profile hook

### Cross-cutting
- [ADR-BLOCK-0015](docs/status/decisions/ADR-BLOCK-0015-b-iot-b-ios-sizecode-pemode.md): Re-encode B.IOT and B.IOS size and PE mode fields
- [ADR-CUBE-0002](docs/status/decisions/ADR-CUBE-0002-b-fpatr-complete-bundle-postprocess.md): B.FPATR Complete-Bundle Matrix PostProcess
- [ADR-CUBE-0005](docs/status/decisions/ADR-CUBE-0005-gm-local-cube-layout-transport.md): GM/Local CUBE Layout Transport
- [ADR-CUBE-0006](docs/status/decisions/ADR-CUBE-0006-local-cube-matrix-operands.md): Local CUBE Matrix Operand Contract
- [ADR-CUBE-0007](docs/status/decisions/ADR-CUBE-0007-cooperative-shared-cube-transpose.md): Cooperative Shared CUBE Inputs and Transpose
- [ADR-CUBE-0008](docs/status/decisions/ADR-CUBE-0008-cube-accumulator-atomic-output.md): CUBE Accumulator and Atomic Output Contract
- [ADR-MEM-0008](docs/status/decisions/ADR-MEM-0008-tload-tstore-gm-byte-row-stride.md): TLOAD/TSTORE GM Byte Row Stride

### Tile
- [ADR-CUBE-0004](docs/status/decisions/ADR-CUBE-0004-local-cube-cell-state-and-geometry.md): Local CUBE CELL State and Geometry

## Release 0.58.2

### Architecture
- [ADR-BLOCK-0010](docs/status/decisions/ADR-BLOCK-0010-conditional-branch-extension-reservation.md): conditional branch extension reservation

### Block
- [ADR-BLOCK-0013](docs/status/decisions/ADR-BLOCK-0013-block-scalar-and-tile-bindings.md): Block scalar and tile bindings

### Cross-cutting
- [ADR-BLOCK-0012](docs/status/decisions/ADR-BLOCK-0012-block-attributes-and-lifecycle.md): Block attributes and lifecycle
- [ADR-BLOCK-0014](docs/status/decisions/ADR-BLOCK-0014-block-start-and-extension-reservations.md): Block start and extension reservations
- [ADR-CUBE-0009](docs/status/decisions/ADR-CUBE-0009-cube-and-matrix-operations.md): CUBE and matrix operations
- [ADR-MEM-0009](docs/status/decisions/ADR-MEM-0009-tlsu-and-global-memory-operations.md): TLSU and global-memory operations
- [ADR-NUM-0012](docs/status/decisions/ADR-NUM-0012-numeric-postprocess-and-format-operations.md): Numeric post-process and format operations
- [ADR-SCALAR-0006](docs/status/decisions/ADR-SCALAR-0006-scalar-system-and-queue-operations.md): Scalar, system, and queue operations
- [ADR-TILE-0008](docs/status/decisions/ADR-TILE-0008-tile-elementwise-and-irregular-operations.md): Tile elementwise and irregular operations
- [ADR-TILE-0009](docs/status/decisions/ADR-TILE-0009-tile-scalar-and-immediate-operations.md): Tile scalar and immediate operations
- [ADR-TILE-0010](docs/status/decisions/ADR-TILE-0010-tile-reduction-expansion-and-generation.md): Tile reduction, expansion, and generation
- [ADR-TILE-0011](docs/status/decisions/ADR-TILE-0011-tile-conversion-layout-and-partial-operations.md): Tile conversion, layout, and partial operations

## Release 0.58.1

### Architecture
- [ADR-GOV-0003](docs/status/decisions/ADR-GOV-0003-formal-source-and-evidence-boundary.md): Formal source and evidence boundary

### Block
- [ADR-BLOCK-0008](docs/status/decisions/ADR-BLOCK-0008-l-bstop-common-long-form.md): Restore `L.BSTOP` as the common 64-bit bundle stop
- [ADR-BLOCK-0013](docs/status/decisions/ADR-BLOCK-0013-block-scalar-and-tile-bindings.md): Block scalar and tile bindings

### Cross-cutting
- [ADR-BLOCK-0009](docs/status/decisions/ADR-BLOCK-0009-barg-bpcn-commit-state.md): Bundle commit state uses BARG/BPCN
- [ADR-BLOCK-0012](docs/status/decisions/ADR-BLOCK-0012-block-attributes-and-lifecycle.md): Block attributes and lifecycle
- [ADR-BLOCK-0014](docs/status/decisions/ADR-BLOCK-0014-block-start-and-extension-reservations.md): Block start and extension reservations
- [ADR-CUBE-0003](docs/status/decisions/ADR-CUBE-0003-cube-matrix-family-contract.md): CUBE Matrix Family Contract
- [ADR-CUBE-0009](docs/status/decisions/ADR-CUBE-0009-cube-and-matrix-operations.md): CUBE and matrix operations
- [ADR-GOV-0004](docs/status/decisions/ADR-GOV-0004-direct-tile-and-bundle-catalog-closure.md): Direct Tile and bundle catalog closure
- [ADR-GOV-0005](docs/status/decisions/ADR-GOV-0005-mnemonic-field-encoding-closure.md): Mnemonic and Encoded-Field Contract Closure
- [ADR-MEM-0009](docs/status/decisions/ADR-MEM-0009-tlsu-and-global-memory-operations.md): TLSU and global-memory operations
- [ADR-NUM-0012](docs/status/decisions/ADR-NUM-0012-numeric-postprocess-and-format-operations.md): Numeric post-process and format operations
- [ADR-SCALAR-0006](docs/status/decisions/ADR-SCALAR-0006-scalar-system-and-queue-operations.md): Scalar, system, and queue operations
- [ADR-TILE-0008](docs/status/decisions/ADR-TILE-0008-tile-elementwise-and-irregular-operations.md): Tile elementwise and irregular operations
- [ADR-TILE-0009](docs/status/decisions/ADR-TILE-0009-tile-scalar-and-immediate-operations.md): Tile scalar and immediate operations
- [ADR-TILE-0010](docs/status/decisions/ADR-TILE-0010-tile-reduction-expansion-and-generation.md): Tile reduction, expansion, and generation
- [ADR-TILE-0011](docs/status/decisions/ADR-TILE-0011-tile-conversion-layout-and-partial-operations.md): Tile conversion, layout, and partial operations

## Release 0.58.0

### Cross-cutting
- [ADR-BLOCK-0004](docs/status/decisions/ADR-BLOCK-0004-pe-local-tile-size-and-32-bit-shared-io-binding.md): PE-Local Tile Size and 32-bit Shared I/O Binding
- [ADR-CUBE-0002](docs/status/decisions/ADR-CUBE-0002-b-fpatr-complete-bundle-postprocess.md): B.FPATR Complete-Bundle Matrix PostProcess
- [ADR-TILE-0007](docs/status/decisions/ADR-TILE-0007-pto-isa-0580-tile-operation-cleanup.md): PTO ISA 0.58.0 Tile Operation Cleanup

## Unassigned

### Architecture
- [ADR-GOV-0001](docs/status/decisions/ADR-GOV-0001-pto-architecture-scope.md): Define PTO as a scalar, bundle/command, and tile ISA
- [ADR-GOV-0002](docs/status/decisions/ADR-GOV-0002-pto-v0-concrete-reference-profile.md): PTO v0 concrete reference profile
- [ADR-MEM-0001](docs/status/decisions/ADR-MEM-0001-pto-total-store-order.md): PTO total store order candidate model
- [ADR-NUM-0001](docs/status/decisions/ADR-NUM-0001-numeric-profile-identity-and-variation-framework.md): Numeric profile identity and bounded variation framework
- [ADR-NUM-0005](docs/status/decisions/ADR-NUM-0005-numeric-variation-point-ownership.md): Numeric variation-point ownership
- [ADR-NUM-0010](docs/status/decisions/ADR-NUM-0010-hardware-subnormal-policy.md): Hardware numeric subnormal policy
- [ADR-STATE-0004](docs/status/decisions/ADR-STATE-0004-acr-routing-and-context-reset.md): PTO v0 ACR routing and context reset
- [ADR-STATE-0005](docs/status/decisions/ADR-STATE-0005-visible-ebarg-snapshot.md): Make EBARG the visible PTO v0 trap snapshot
- [ADR-STATE-0007](docs/status/decisions/ADR-STATE-0007-interrupt-pending-and-timer-state.md): Define interrupt pending and timer state
- [ADR-STATE-0008](docs/status/decisions/ADR-STATE-0008-system-register-behavior-classes.md): Classify every visible system register behavior

### Block
- [ADR-BLOCK-0005](docs/status/decisions/ADR-BLOCK-0005-complete-bundle-bior-schema-and-defaults.md): Complete-Bundle B.IOR Schema and Defaults
- [ADR-STATE-0011](docs/status/decisions/ADR-STATE-0011-bundle-operation-descriptor-and-commit.md): Bundle operation descriptor and transactional commit

### Cross-cutting
- [ADR-BLOCK-0006](docs/status/decisions/ADR-BLOCK-0006-tile-classification-and-engine-aliases.md): Tile Classification and Execution-Engine Aliases
- [ADR-BLOCK-0007](docs/status/decisions/ADR-BLOCK-0007-complete-bundle-gpr-operand-resolution.md): Complete-Bundle GPR Operand Resolution
- [ADR-CUBE-0001](docs/status/decisions/ADR-CUBE-0001-a2a3-mx-profile-applicability.md): A2/A3 MX CUBE profile applicability
- [ADR-CUBE-0018](docs/status/decisions/ADR-CUBE-0018-internal-acc-partial-sum-routing.md): InternalAcc partial-sum routing for CUBE matrix operations
- [ADR-MEM-0002](docs/status/decisions/ADR-MEM-0002-production-memory-events-and-atomic-corners.md): Production memory events and atomic corners
- [ADR-MEM-0006](docs/status/decisions/ADR-MEM-0006-tlsu-four-bit-memory-packing.md): TLSU four-bit memory packing and totality
- [ADR-MEM-0007](docs/status/decisions/ADR-MEM-0007-pto-encoding-ownership-and-gm-access.md): PTO Encoding Ownership and Per-PE GM Access
- [ADR-NUM-0002](docs/status/decisions/ADR-NUM-0002-scalar-numeric-flag-state-and-ownership.md): Scalar numeric flag state and producer ownership
- [ADR-NUM-0003](docs/status/decisions/ADR-NUM-0003-numeric-rounding-selector-ownership.md): Numeric rounding selector ownership
- [ADR-NUM-0004](docs/status/decisions/ADR-NUM-0004-numeric-format-namespace-ownership.md): Numeric format namespace ownership
- [ADR-NUM-0006](docs/status/decisions/ADR-NUM-0006-public-numeric-type-identity-and-availability.md): Public numeric type identity and target availability
- [ADR-NUM-0008](docs/status/decisions/ADR-NUM-0008-numeric-rounding-semantics.md): Numeric rounding semantics
- [ADR-NUM-0009](docs/status/decisions/ADR-NUM-0009-numeric-format-value-classification.md): Numeric format value classification
- [ADR-NUM-0011](docs/status/decisions/ADR-NUM-0011-hardware-special-value-checkpoint.md): Hardware special-value result checkpoint
- [ADR-SCALAR-0004](docs/status/decisions/ADR-SCALAR-0004-scalar-fsu-totality-and-profile-boundary.md): Scalar FSU totality and numeric-profile boundary
- [ADR-STATE-0001](docs/status/decisions/ADR-STATE-0001-pto-owned-system-register-names.md): Use PTO-owned system-register names
- [ADR-STATE-0002](docs/status/decisions/ADR-STATE-0002-architectural-state-contract.md): Define the PTO architectural state contract
- [ADR-STATE-0003](docs/status/decisions/ADR-STATE-0003-scalar-tpc-and-execution-status.md): scalar TPC and execution status
- [ADR-STATE-0009](docs/status/decisions/ADR-STATE-0009-pto-v0-trap-disposition.md): Define the PTO v0 disposition of every trap identity
- [ADR-STATE-0010](docs/status/decisions/ADR-STATE-0010-scalar-pc-relative-and-return-address.md): Scalar PC-relative and return-address state
- [ADR-STATE-0012](docs/status/decisions/ADR-STATE-0012-uniform-instruction-attempt-status.md): Uniform instruction-attempt status and fault isolation
- [ADR-STATE-0013](docs/status/decisions/ADR-STATE-0013-scalar-sys-totality-and-profile-boundaries.md): Scalar SYS totality and PTO-v0 profile boundaries
- [ADR-TILE-0001](docs/status/decisions/ADR-TILE-0001-tile-capacity-and-packed-storage.md): Define tile capacity and packed storage
- [ADR-TILE-0002](docs/status/decisions/ADR-TILE-0002-element-level-tile-definedness.md): Track tile definedness per element
- [ADR-TILE-0003](docs/status/decisions/ADR-TILE-0003-explicit-tile-handoff-slots.md): Define explicit tile handoff slots
- [ADR-TILE-0004](docs/status/decisions/ADR-TILE-0004-bundle-command-totality-and-profile-boundaries.md): Bundle-command totality and PTO-v0 profile boundaries
- [ADR-TILE-0005](docs/status/decisions/ADR-TILE-0005-cube-raw-carrier-totality.md): CUBE raw-carrier totality and composite preflight
- [ADR-TILE-0006](docs/status/decisions/ADR-TILE-0006-vec-sfu-carrier-totality.md): VEC/SFU carrier totality and profile boundary
- [ADR-TILE-0012](docs/status/decisions/ADR-TILE-0012-cube-m16-m32-reduction-expansion-layout.md): CUBE_M16/CUBE_M32 layout closure for tile reduction and expansion

### Scalar
- [ADR-MEM-0003](docs/status/decisions/ADR-MEM-0003-pc-relative-and-unscaled-agu-addressing.md): PC-relative and unscaled AGU addressing
- [ADR-MEM-0004](docs/status/decisions/ADR-MEM-0004-scalar-agu-totality-and-restart.md): Scalar AGU totality, aliases, and restart
- [ADR-MEM-0005](docs/status/decisions/ADR-MEM-0005-scalar-amo-totality-and-reservation.md): Scalar AMO totality, reservations, and restart
- [ADR-SCALAR-0001](docs/status/decisions/ADR-SCALAR-0001-scalar-bitfield-and-reverse-bounds.md): Scalar bitfield and byte-reversal bounds
- [ADR-SCALAR-0002](docs/status/decisions/ADR-SCALAR-0002-scalar-alu-totality-and-alias-order.md): Scalar ALU totality and alias order
- [ADR-SCALAR-0003](docs/status/decisions/ADR-SCALAR-0003-scalar-bru-totality-and-target-legality.md): Scalar BRU totality and target legality
- [ADR-SCALAR-0005](docs/status/decisions/ADR-SCALAR-0005-addtpc-page-scaled-immediate.md): ADDTPC page-scaled immediate
- [ADR-STATE-0006](docs/status/decisions/ADR-STATE-0006-acrc-service-request.md): Define PTO v0 ACRC service requests

### Tile
- [ADR-NUM-0007](docs/status/decisions/ADR-NUM-0007-public-integer-conversion-result-subset.md): Public integer conversion result subset

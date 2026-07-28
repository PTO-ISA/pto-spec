# PTO architecture boundary

PTO is a 64-bit scalar and tile instruction set with one architectural execution
level. Scalar instructions, direct tile instructions, and memory operations
update a single architecture-visible state. No instruction launches another
PTO instruction body.

## Scalar state

- XLEN is 64.
- There are 24 scalar GPRs, R0..R23; R0 is hardwired to zero.
- ABI aliases are sp=R1, a0..a7=R2..R9, ra=R10,
  s0/fp..s8=R11..R19, x0..x3=R20..R23.
- Reg5 source selectors 24..27 read element (0,0) of T1..T4; selectors 28..31
  read element (0,0) of U1..U4. They are direct references to the flat tile
  register file, not additional GPRs or queue positions.
- Reg5 destinations 1..23 write GPRs, 0 and 24..29 discard the value, 30 writes
  U1 element (0,0), and 31 writes T1 element (0,0). Compressed `->t` forms use
  that same direct T1 bridge. No implicit push, pop, or body-local state exists.
- PC, return address, commit argument, predicate mask, fault code/address,
  system state, and memory-ordering state are introduced only where required by
  retained forms.

## Tile state

- Six-bit tile indices select 64 registers.
- T/U/M/N hands occupy codes 0..15, 16..31, 32..47, and 48..63.
- A normal active tile has 256 bytes through 256 KiB capacity; zero is the empty
  tile. Total active per-thread capacity is at most 512 KiB.
- Shape, valid region, data type, layout, and location intent are visible.
- Elements outside the valid region are not architecturally observable unless
  an instruction explicitly defines them.
- Source operands are snapshotted before destination writes, defining
  read-before-write behavior for permitted aliases.

The ASL payload array is bounded by `PTO_MODEL_TILE_ELEMENTS` for executable
verification. This is not an architectural shape limit; descriptor capacity
defines architectural legality.

## Direct tile families

- TEPL contains 97 accepted element, reduction, expansion, layout, utility, and
  pipe operations.
- TMA contains TLOAD, TSTORE, TMOV, TPREFETCH, MGATHER, and MSCATTER.
- CUBE contains TMATMUL/TGEMV base, bias, accumulate, and MX variants.

The canonical selector and descriptor fields define encoding/operand facts, not
a command queue. Direct PTO operations have explicit destinations,
sources, dimensions, addresses, and attributes.

TPREFETCH is destination-free. It performs applicable address translation,
permission, and fault checks but allocates and writes no tile. This resolves a
known independent-documentation conflict in favor of the canonical PTO contract.

## Memory and faults

- Byte order is little-endian.
- Scalar and tile memory share one architectural ordering domain.
- The default memory model is TSO, with explicit acquire/release and fence rules.
- Atomic `aq` and `rl` bits map to relaxed, acquire, release, or
  acquire-release ordering. The portable one-level address model treats FAR as
  an explicit address-class hint with identity address translation; a platform
  profile may refine that address class without changing instruction decoding.
- Misalignment, translation, permission, and restart behavior are visible when
  defined; implementation-dependent profiles must be named.
- The bounded ASL byte array is executable-test infrastructure, not the
  architectural address-space size.

Exact scalar form recognition and operand extraction are generated from the
normative catalog. Split fields are reconstructed into contiguous values;
signedness remains explicit metadata so instruction semantics, not the decoder,
controls extension and scaling. Reg5 bridge behavior is defined in
`asl/scalar/operands.asl`.

`ExecuteScalarInstruction` is the decoded scalar execution boundary. Unknown or
illegal encodings raise the illegal-instruction fault, all 183 AGU, 107 ALU, 53
AMO, 66 BRU, and 35 SYS forms execute their checked-in state transitions, and
recognized families without completed operand-to-effect bindings return
`ScalarExecution_Unsupported` with no state change. This explicit result keeps
partial executable coverage observable.

## Excluded implementation detail

Physical tile addresses, allocation algorithms, pipelines, event IDs, backend
intrinsics, latency, throughput, target-specific scheduling, and cost models are
outside the portable ASL contract. A2/A3 and A5 differences belong in explicit
profiles, not silent branches in portable semantics.

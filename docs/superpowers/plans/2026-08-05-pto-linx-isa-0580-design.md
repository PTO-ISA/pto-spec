# PTO and Linx ISA v0.58 Coordinated Upgrade Design

## Objective

Promote PTO ISA and LinxISA to the same hard-break v0.58 contract. PTO
owns scalar and block/tile definitions. Linx imports those definitions exactly
and retains its Linx-only two-level vector ISA. Every active producer and
consumer upgrades together and rejects the former v0.57.1 ABI.

## Release boundary

- PTO and Linx release identity is 0.58.0.
- The upgrade is based on 0.57.1 but is not backward compatible.
- Historical v0.57.1 release artifacts remain immutable and clearly historical.
- PTO scalar and block forms are the sole source imported by Linx.
- Linx-only vector definitions remain additive.
- PTO reserves the exact encodings of BSTART.VPAR, BSTART.VSEQ,
  C.BSTART.VPAR, C.BSTART.VSEQ, V.QPOP, and V.QPUSH.
- The release remains maturity M4. Existing numeric, predicate, trap,
  queue-order, accumulator, and context gaps remain open.

## Shared register architecture

Each core contains four PEs and one private Shared tile-register bank containing
absolute architectural registers S0 through S255. All four PEs in that core can
access every Shared register. Different cores have independent banks.

The compiler allocates physical Shared register numbers. PTO C++ continues to
use typed SharedTile variables and does not expose an API for choosing Sx. The
architectural bank persists across blocks until overwritten or core reset.

Each Sx contains descriptor state, payload state divided into four fixed-offset
quarters, and initialization state for its descriptor and quarters. Reading
uninitialized state is legal and behaves like reading an undefined register.
A read never modifies descriptor or payload.

## Assembly and encoding

Canonical PTO-AS syntax is direction-sensitive:

~~~asm
C.B.IOS S17       // source
C.B.IOS -> S17    // destination
~~~

The 16-bit encoding remains unchanged. Bits 13:6 contain the absolute 8-bit
SharedID. No direction bit is added. The assembler and verifier derive the
required role from the surrounding BSTART function and reject syntax that
contradicts that role.

C.B.IOS binds only SharedID. Quarter selection is supplied by the operation's
B.IOT.PE_MASK.

## Predicate and data placement

PE_MASK is a four-bit quarter predicate:

- bit n selects quarter n at its fixed offset;
- multiple bits may be set;
- 0000 is a legal no-op;
- selected quarters are never packed;
- unselected Shared and memory ranges remain untouched.

Shared TLOAD and TSTORE accept an optional mask-only B.IOT companion. When the
companion is absent, the effective mask is 1111. Non-mask fields use canonical
zero values and non-canonical values are rejected.

## Atomicity, descriptors, and conflicts

A Shared destination performs one atomic read-modify-write over its descriptor
and selected quarters. No observer may see torn descriptor/payload state.

- A full 1111 write may replace descriptor and payload.
- A partial write to initialized Sx requires descriptor compatibility.
- A partial write to uninitialized Sx establishes the descriptor; selected
  quarters become initialized and unselected quarters remain undefined.
- Same-register source/destination behavior is read-old/write-new.

The architecture imposes no total order between concurrent PE accesses.
Non-overlapping accesses are valid. Overlapping concurrent accesses are
programmer error and architectural undefined behavior; hardware need not
detect or trap them. Without synchronization, a reader may observe either the
old or new complete value. Existing event and synchronization operations
establish visibility.

## Removed prior assumptions

Active v0.58 surfaces must remove:

- S#n relative/version syntax;
- architectural SSA or immutable Shared versions;
- compiler-visible physical version/reclamation semantics;
- fixed PE ownership of one quarter;
- immutable defined_mask architectural state;
- an eight-live-version capacity claim;
- implicit full-mask behavior when explicit mask-only B.IOT is present.

## Validation and integration

Integration proceeds from the normative PTO exact head to Linx and then to
downstream consumers. Each branch requires local gates, exact-head review, a
fresh hosted validation, no conflicts, and proof that the squash tree equals
the reviewed tree before cleanup. Checks remain fail closed; pending, skipped,
neutral, cancelled, or stale results are not success.

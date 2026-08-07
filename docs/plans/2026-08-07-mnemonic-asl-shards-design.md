# Mnemonic-owned ASL test shards

## Decision

Executable test ASL is organized by the instruction mnemonic or by an explicitly
named cross-cutting architecture contract. Normative ASL remains organized by
architecture subsystem under `asl/`.

The hosted workflow exposes every runtime shard as a separately named matrix
job. A final job named `validate` depends on the static gate and every runtime
shard so the existing protected-branch contract remains stable. Matrix failure
is fail-fast; no failed or cancelled shard is treated as success.

## Shared tile capacity contract

Local `B.IOT.TSize` and Shared `B.IOS.TSize` use the same encoding:

| TSize | Per-PE capacity |
| --- | ---: |
| `001` | 128 B |
| `010` | 256 B |
| `011` | 512 B |
| `100` | 1 KiB |
| `101` | 2 KiB |
| `110` | 4 KiB |
| `111` | 8 KiB |

Every capacity is a power of two. `rows` and `columns` describe the allocated
shape; `valid_rows` and `valid_columns` constrain the architecturally valid
region. The valid region cannot make an allocated shape fit a smaller TSize:
the complete allocated shape must satisfy
`ceil(rows * columns * element_bits / 8) <= capacity`.

The failed `TLOADShared` fixture intended to test descriptor mismatch against
an existing 512-byte Shared register. It incorrectly supplied TSize `001`
(128 bytes) for a 63-element U64 descriptor (504 bytes), so the reviewed
capacity precondition rejected the fixture before the descriptor-mismatch path.
The fixture must use TSize `011` (512 bytes); the normative mapping is not
changed.

## Test source layout

- `tests/asl/shards/` contains instruction-focused runtime entrypoints such as
  `tload-tstore.asl`, plus explicitly named cross-cutting entrypoints such as
  `tile-capacity.asl` and `tile-definedness.asl`.
- Existing test libraries remain shared source libraries so helpers and
  fixtures are not duplicated. A shard main imports only the libraries needed
  by its calls and invokes one focused test contract.
- Cross-instruction lifecycle, dispatch, capacity, and closure evidence uses a
  descriptive contract filename and remains visibly separate from mnemonic
  evidence.
- The canonical main remains the whole-suite execution contract.

The existing shard checker remains fail-closed, while the Makefile exposes its
checked shard-name inventory for GitHub Actions matrix construction. It still
proves that every canonical call occurs exactly once, rejects orphan/empty
shards, and proves every declared `Test*`/`Validate*` subprogram is reachable.

## Hosted workflow

The workflow has four layers:

1. `plan` checks release and repository invariants and emits the exact shard
   matrix from the checked repository.
2. `asl-shard / <name>` installs the pinned ASLRef and executes one named shard.
3. GitHub matrix fail-fast cancels remaining work after a failure where
   possible; independently running jobs may finish but cannot mask the result.
4. `validate` succeeds only if `plan` and every matrix child succeeded.

This provides mnemonic-oriented navigation without weakening strict ASLRef
execution or changing branch protection to a set of mutable shard names.

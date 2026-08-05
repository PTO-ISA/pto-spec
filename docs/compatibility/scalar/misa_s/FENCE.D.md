> DavinciOO v5 SYS extension. Linx `FENCE.D` keeps its v0.57 local encoding; `FENCE.D.CORE4` assigns a profile-isolated Core PE4 fence mode.

# FENCE.D / FENCE.D.CORE4

## Assembly

```asm
FENCE.D       pred_imm, succ_imm
FENCE.D.CORE4 pred_imm, succ_imm
```

`DSB` and `DSB.CORE4` are corresponding aliases.

## Encoding

| Bits | Field |
| --- | --- |
| `[31:28]` | fixed `0000` |
| `[27:24]` | `PRED_IMM` |
| `[23:20]` | `SUCC_IMM` |
| `[19:15]` | `FenceMode`: `00000` local, `00001` Core PE4 |
| `[14:0]` | inherited fixed pattern |

| Form | Mask | Match |
| --- | --- | --- |
| `FENCE.D` | `0xf00fffff` | `0x0000202b` |
| `FENCE.D.CORE4` | `0xf00fffff` | `0x0000a02b` |

## Local Fence

`FENCE.D pred,succ` keeps Linx memory-ordering semantics for the executing PE.

## Core4 Fence

`FENCE.D.CORE4` is an atomic composite operation for fixed participants PE0–PE3:

1. each PE makes older matching operations reach the release point;
2. it registers one arrival in the current implicit Core generation;
3. it waits until all four PEs arrive at the same dynamic barrier;
4. all PEs are released together;
5. newer matching operations cannot reach an observable point before acquire release.

`SYNCALL<core_scope>()` always emits `FENCE.D.CORE4 RW,RW`, covering scalar LSU and TLSU/MTE GM reads/writes. It does not include unrelated MMIO unless selected by a different explicit fence mask.

## Collective Legality

- One implicit Core barrier slot/generation is provided; there is no barrier ID.
- All four PEs execute the same static fence in the same dynamic order.
- The containing SYS body is straight-line, statically convergent and independently non-speculative.
- The fence is the body's final executable instruction.
- Participant mismatch is an illegal program and has no forward-progress guarantee.
- Flush/replay cannot duplicate arrival; exception, kill, debug termination and reset must clear or terminate the generation.

Reserved `FenceMode` values are illegal.

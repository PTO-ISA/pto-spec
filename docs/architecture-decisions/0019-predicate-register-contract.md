# ADR 0019: Define the PTO predicate-register contract

## Status

Superseded by [ADR 0046](0046-separate-execution-mask-and-warp-predicates.md).

## Historical context

This decision correctly identified that every visible predicate needs an
explicit reset, preservation, producer, and consumer contract. It incorrectly
treated the independent 64-bit kernel EXEC mask as warp predicate register P0
and therefore assigned the wrong width and control-flow role to P0 through P7.

ADR 0046 retains the requirement for explicit state and trap behavior while
separating the two architectural domains. This file remains only as the
decision-history record; it is not a current semantic source.

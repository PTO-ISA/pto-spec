---
{
  "id": "ADR-0113",
  "title": "Following BSTART preserves the predecessor-selected transfer",
  "status": "accepted",
  "authors": ["Codex"],
  "approvers": ["zhoubot"],
  "created": "2026-09-01",
  "accepted": "2026-09-01",
  "rejected": null,
  "superseded": null,
  "baseline": "92dfece46f768e46260e0da0a8a917024738c300",
  "target_releases": ["0.58.5"],
  "affected_ndf": [
    "PTO-REQ-BSTART-PREDECESSOR-TRANSFER-001"
  ],
  "affected_units": [
    "PTO-BLOCK-MODEL-DISPATCH-START"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": "https://github.com/PTO-ISA/pto-spec/issues/192",
  "release_impact": "required",
  "legacy_ids": []
}
---

# ADR 0113: Following BSTART preserves the predecessor-selected transfer

## Context

BSTOP and a following BSTART are both bundle commit boundaries. A following
BSTART is fetched at the predecessor's sequential boundary, but predecessor
commit may select a different DIRECT, conditional, indirect, call, or return
continuation. The existing dispatch committed the predecessor and then always
installed the fetched BSTART, overwriting a non-sequential committed TPC.

This caused a valid return block to select its return address and immediately
lose it when the sequential BSTART installed a new fallthrough block.

## Decision

A following BSTART first performs the existing candidate preflight and
predecessor commit. After a successful commit, dispatch compares the committed
TPC with the fetched BSTART instruction PC.

If the addresses differ, the predecessor selected control elsewhere. The
retired predecessor remains committed, its selected TPC is preserved, and the
fetched BSTART does not install a new BARG. If the addresses are equal, the
predecessor selected that boundary and the new BSTART installs normally.

A predecessor target may intentionally equal the fetched BSTART PC; equality
therefore selects normal installation. A failed predecessor commit retains the
old BARG and prevents installation exactly as before.

## Compatibility

- No encoding, assembly, target calculation, or BARG field changes.
- Fallthrough and untaken conditional streams continue installing the next
  sequential BSTART.
- Taken direct, conditional, indirect, call, and return streams no longer have
  their committed TPC overwritten by an instruction on the untaken path.
- Existing rollback behavior remains unchanged.
- Functional-model stop policy and ELF layout remain outside PTO architecture.

## Verification obligations

- Taken DIRECT, conditional, and RET predecessors skip non-selected BSTARTs.
- Fallthrough and untaken conditional predecessors install the sequential
  BSTART.
- A selected target equal to the current BSTART installs it.
- Failed predecessor commit retains old state and installs nothing.
- Instruction-attempt and cycle accounting remain explicit and deterministic.

## Decision state

The architecture owner authorized the selected rule on 2026-09-01. Focused
tests bind taken and sequential predecessor behavior to the owning ASL rule.

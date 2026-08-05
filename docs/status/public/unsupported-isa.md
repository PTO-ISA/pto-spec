---
{
  "schema_version": 1,
  "id": "status.unsupported-isa",
  "kind": "coverage",
  "title": "Unsupported ISA",
  "status": "active",
  "visibility": "public",
  "profile": "pto-isa-0.58.0",
  "family": "Support Status",
  "xlsx": { "order": 3 }
}
---
# Unsupported ISA

The following names are outside PTO ISA 0.58.0. This page intentionally does not link to internal or historical documents.

## Removed Tile operations

`ACCCVT`, `MGATHER_CAS`, `MGATHER_MASK`, `MSCATTER_MASK`, `TALLOC`, `TAXPY`, `TDEINTERLEAVE`, `TFREE`, `TGATHERB`, `THISTOGRAM`, `TINTERLEAVE`, `TPARTARGMAX`, `TPARTARGMIN`, `TPOP`, `TPRELU`, `TPUSH`, `TRESHAPE`, `TSORT`.

## Unsupported or historical Block/Header names

`B.ATTR`, `B.CACR`, `B.NEXT`, `BSTART.PAR`, `B.ITP`, `B.META`, `B.MRECTC`, `B.MRECTR`, `B.MSHP`, `B.OTA`, `S_TILE_STATE`.

## Other exclusions

- `TADDC` is not in the accepted Tile set for this release.
- `SYNCALL` is not a Tile intrinsic.
- Programmable parallel/vector block bodies and their local micro-ISA are not published.
- Experimental or internal communication, review and migration materials do not constitute public ISA support.

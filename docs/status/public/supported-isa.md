---
{
  "schema_version": 1,
  "id": "status.supported-isa",
  "kind": "coverage",
  "title": "Supported ISA",
  "status": "active",
  "visibility": "public",
  "profile": "pto-isa-0.58.0",
  "family": "Support Status",
  "xlsx": { "order": 2 }
}
---
# Supported ISA

PTO ISA 0.58.0 publishes the following architecture documentation:

| Area | Published scope |
| --- | --- |
| Tile Intrinsics | 106 operations in eight functional categories |
| Block Intrinsics | 26 active/public Block and Header pages in six document categories |
| Scalar & System ISA | 1105 compatibility pages grouped as MISA-C/F/G/H/L/S, Registers and Supporting Reference |
| Architecture Reference | Six introductory architecture documents |
| Encoding Workbook | One canonical workbook at `spec/encoding/PTO-ISA-Encoding.xlsx` |

The Tile catalog and encoding workbook determine the accepted Tile identities and encodings. Block support is limited to the pages in the public Block Intrinsics index. Scalar and System pages are compatibility reference material retained without semantic changes in this documentation release.

`BSTART.MPAR` and `BSTART.MSEQ` are supported forms documented within the `BSTART` page; they do not have separate instruction pages.

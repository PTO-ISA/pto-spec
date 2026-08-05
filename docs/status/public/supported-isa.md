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
| Scalar ISA | 474 accepted binary forms; 1105 published pages grouped as MISA-C/F/G/H/L/S, Registers, and Architecture Support |
| Block ISA | 26 active/public Block and Header pages in six document categories |
| Tile ISA | 109 operations in eight functional categories |
| Architecture Reference | Six introductory architecture documents |
| Encoding Workbook | One canonical workbook at `spec/encoding/PTO-ISA-Encoding.xlsx` |

The scalar form catalog determines the accepted Scalar ISA encodings and field constraints. The command catalog and public Block ISA pages determine accepted block forms. The Tile catalog and encoding workbook determine accepted Tile identities and encodings.

`BSTART.MPAR` and `BSTART.MSEQ` are supported forms documented within the `BSTART` page; they do not have separate instruction pages.

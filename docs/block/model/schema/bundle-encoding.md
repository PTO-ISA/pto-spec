<!-- GENERATED FROM: asl/block/model/schema/bundle-encoding.asl -->
# Bundle Encoding

**Normative ASL source:** `asl/block/model/schema/bundle-encoding.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-SCHEMA-BUNDLE-ENCODING}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-schema-bundle-encoding-purpose role=purpose-scope -->
## Purpose and scope

This unit defines the numeric codes of bundle kinds and transfer rules, the PE-mode to PE-mask table used by `B.IOT` and `B.IOS`, and the legality check for a saved `EBARG0` control word.

Its metadata also lists reviewed encoding overlaps in the command-form catalog.

<!-- PTO-READER-BLOCK: block-model-schema-bundle-encoding-concepts role=concepts-state -->
## Concepts and visible state

| Kind | Code | Transfer | Code |
| --- | --- | --- | --- |
| Standard | `0000` | Fallthrough | `000` |
| Floating | `0001` | Direct | `001` |
| System | `0010` | Conditional | `010` |
| TileElement | `0101` | Call | `011` |
| TileMemory | `0110` | Return | `100` |
| TileMatrix | `0111` | Indirect | `101` |
| FrameTemplate | `1000` | IndirectCall | `110` |

The 3-bit PE mode selects a 4-bit PE mask: `000` gives `0000`, `001` to `100` select a single PE (`1000`, `0100`, `0010`, `0001`), `101` gives `1100`, `110` gives `1110`, and `111` gives `1111`.

<!-- PTO-READER-BLOCK: block-model-schema-bundle-encoding-rules role=rules-interactions -->
## Rules and interactions

`BundleKindOf` and `BundleTransferOf` decode a code. Any code not listed decodes to `Standard` or `Fallthrough`.

`EBARGControlLegal` accepts a saved control word only if bits `63:15` are zero, the kind code in bits `10:7` is one of the listed kinds, the transfer code in bits `13:11` is at most 6, and bit 6 (body active) implies bit 5 (bundle active). Trap-context recovery uses this check.

Design point: recovery checks the saved control word instead of trusting it. A word with an unassigned kind, an unassigned transfer, or a body without an active bundle is rejected. Decoding it would otherwise map the bad code silently to `Standard` or `Fallthrough`.

Design point: PE mode `000` maps to mask `0000`. A binding with that mask is a strict no-op in the command dispatcher after the SizeCode check: it skips placement, stream, schema, allocation, and descriptor checks, and in a header records only that zero participation was seen and opens its range group. Mode `000` therefore encodes "no participating PE" without a separate flag.

<!-- PTO-READER-BLOCK: block-model-schema-bundle-encoding-boundaries role=boundaries -->
## Architectural boundaries

The metadata records three reviewed overlaps. Two concern `B.IOT` source-only forms, which fix `SizeCode` to zero, and destination forms, which require `SizeCode` 1 to 12. The third is `C.BSTOP`, which uses the `BrType` value 0 that `C.BSTART.STD` excludes.

Codes `0011`, `0100`, and `1001` to `1111` are not assigned to any kind.

<!-- PTO-READER-BLOCK: block-model-schema-bundle-encoding-example role=example-usage -->
## Non-normative reading example

This example illustrates the current ASL owner and does not replace the normative operation.

A saved control word for an active `TileElement` body with a `Fallthrough` transfer has bit 4 set, bits 5 and 6 set, kind `0101` in bits `10:7`, and `000` in bits `13:11`. It passes `EBARGControlLegal`. The same word with bit 5 clear fails, because bit 6 claims a body without an active bundle.

<!-- PTO-READER-BLOCK: block-model-schema-bundle-encoding-related role=related-owners-navigation -->
## Related owners

- [State types](../state/types.md) declares the enumerations.
- [BARG helpers](../state/barg.md) pack these codes into the `LSRGET` control word.
- [Trap context](../../../arch/state/trap-context.md) writes and checks the `EBARG0` word.
- [B.IOT](../../operands/B.IOT.md) and [B.IOS](../../operands/B.IOS.md) use the PE-mode table.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/schema/bundle-encoding.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-SCHEMA-BUNDLE-ENCODING","surface":"block","classification":["model","schema","bundle-encoding"],"depends_on":["PTO-BLOCK-MODEL-STATE-TYPES"],"catalog_projection":{"catalog":"command-forms","isa":"PTO Instruction Set Architecture","reviewed_encoding_overlaps":[{"broad_form_id":"b_iot_32_10db6db84f5d","narrow_form_id":"b_iot_32_c11eb189dd83","reason":"source-only form fixes SizeCode to zero; destination form requires SizeCode 1..12 and a 2-bit DstTile"},{"broad_form_id":"b_iot_32_8b8bce6bffe8","narrow_form_id":"b_iot_32_2c07e7177fad","reason":"source-only form fixes SizeCode to zero; destination form requires SizeCode 1..12 and a 2-bit DstTile"},{"broad_form_id":"c_bstart_std_16_8b40f078c14a","narrow_form_id":"c_bstop_16_ca4743d8a95e","reason":"C.BSTOP fixes the broad C.BSTART.STD BrType field to excluded value 0"}],"schema_version":2,"surface":"command-and-boundary"}}
pure func BundleKindCode(kind: BundleKind) => bits(4)
begin
    case kind of
        when BundleKind_Standard => return '0000';
        when BundleKind_Floating => return '0001';
        when BundleKind_System => return '0010';
        when BundleKind_TileElement => return '0101';
        when BundleKind_TileMemory => return '0110';
        when BundleKind_TileMatrix => return '0111';
        when BundleKind_FrameTemplate => return '1000';
    end;
end;

pure func BundleKindOf(code: bits(4)) => BundleKind
begin
    if code == '0001' then return BundleKind_Floating;
    elsif code == '0010' then return BundleKind_System;
    elsif code == '0101' then return BundleKind_TileElement;
    elsif code == '0110' then return BundleKind_TileMemory;
    elsif code == '0111' then return BundleKind_TileMatrix;
    elsif code == '1000' then return BundleKind_FrameTemplate;
    else return BundleKind_Standard;
    end;
end;

pure func PEMaskOfPEMode(mode: bits(3)) => bits(4)
begin
    case mode of
        when '000' => return '0000';
        when '001' => return '1000';
        when '010' => return '0100';
        when '011' => return '0010';
        when '100' => return '0001';
        when '101' => return '1100';
        when '110' => return '1110';
        when '111' => return '1111';
    end;
end;

pure func BundleTransferCode(transfer: BundleTransfer) => bits(3)
begin
    case transfer of
        when BundleTransfer_Fallthrough => return '000';
        when BundleTransfer_Direct => return '001';
        when BundleTransfer_Conditional => return '010';
        when BundleTransfer_Call => return '011';
        when BundleTransfer_Return => return '100';
        when BundleTransfer_Indirect => return '101';
        when BundleTransfer_IndirectCall => return '110';
    end;
end;

pure func BundleTransferOf(code: bits(3)) => BundleTransfer
begin
    if code == '001' then return BundleTransfer_Direct;
    elsif code == '010' then return BundleTransfer_Conditional;
    elsif code == '011' then return BundleTransfer_Call;
    elsif code == '100' then return BundleTransfer_Return;
    elsif code == '101' then return BundleTransfer_Indirect;
    elsif code == '110' then return BundleTransfer_IndirectCall;
    else return BundleTransfer_Fallthrough;
    end;
end;

pure func EBARGControlLegal(control: Word) => boolean
begin
    let kind_code = UInt(control[10:7]);
    return control[63:15] == Zeros{49} &&
           (kind_code <= 2 || (kind_code >= 5 && kind_code <= 8)) &&
           UInt(control[13:11]) <= 6 &&
           (control[6] == '0' || control[5] == '1');
end;
```
<!-- GENERATED-ASL-END: unit -->

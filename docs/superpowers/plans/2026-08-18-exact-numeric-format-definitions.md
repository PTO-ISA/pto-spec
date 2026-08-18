# Exact Numeric Format Definitions Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Define every floating and scale `TileDataType` precisely in ASL, with exact integer-times-power-of-two decomposition and same-basename production, documentation, and test files.

**Architecture:** Keep `asl/numeric/formats.asl` as the cross-format dispatcher and hardware-profile helper surface. Put each format's descriptor and finite decoder in `asl/numeric/formats/<name>.asl`; put its normative page in `docs/numeric/formats/<name>.md`; and put its direct executable evidence in `tests/asl/numeric/formats/<name>.asl`. Existing value-classification APIs remain stable, while the new descriptor and decomposition APIs add structure without selecting arithmetic, rounding, flags, or operation/type support.

**Tech Stack:** ASL1 accepted by the repository-pinned ASLRef, GNU Make source/test manifests, Python evidence generators/checkers, Markdown normative documentation.

## Global Constraints

- Preserve the active `pto-v0` raw-carrier behavior and every existing public ASL function signature.
- Do not add arithmetic, conversion, rounding, exception-flag, matrix-result, or operation/type-support semantics.
- Represent a finite value exactly as `(-1)^negative * UInt(significand) * 2^exponent`.
- Use one production ASL, documentation, and test file per format with the same lowercase basename.
- Distinguish carrier width, logical lane width, lanes per carrier, and required zero padding.
- Decode one logical low-nibble lane for packed four-bit formats; existing TLSU packing remains unchanged.
- Decode E8M0 independently from low-precision base values; do not apply a scale inside the format decoder.
- Reference only PTO-owned requirements, ADRs, profiles, and repository artifacts in checked-in content.
- Do not add dependencies or modify generated `build/` and `.cache/` content.
- Preserve unrelated staged and unstaged user changes; each commit uses explicit path lists.

---

## File map and interfaces

### Common files

- Modify: `asl/types.asl`
- Modify: `asl/numeric/formats.asl`
- Modify: `Makefile`
- Create: `docs/numeric/formats/index.md`
- Create: `tests/asl/numeric/formats/common.asl`
- Create: `tests/asl/shards/numeric-formats.asl`
- Modify: `tests/asl/main.asl`

### Same-basename format triples

For every basename below, create all three paths:

```text
asl/numeric/formats/<basename>.asl
docs/numeric/formats/<basename>.md
tests/asl/numeric/formats/<basename>.asl
```

Basenames:

```text
fp64 fp32 tf32 hf32 fp16 bf16 hif8 e4m3 e5m2 e3m2 e2m3
e2m1x2 e1m2x2 e8m0 hif4x2
```

### New public ASL types

Add to `asl/types.asl`:

```asl
type NumericFormatKind of enumeration {
    NumericFormatKind_Unavailable,
    NumericFormatKind_FixedBinary,
    NumericFormatKind_HiF8,
    NumericFormatKind_E8M0
};

type NumericFormatDescriptor of record {
    available: boolean,
    kind: NumericFormatKind,
    carrier_bits: integer {0..64},
    lane_bits: integer {0..64},
    lanes_per_carrier: integer {0..2},
    sign_bits: integer {0..1},
    sign_bit: integer {0..63},
    exponent_bits_min: integer {0..11},
    exponent_bits_max: integer {0..11},
    fraction_bits_min: integer {0..52},
    fraction_bits_max: integer {0..52},
    exponent_bias_available: boolean,
    exponent_bias: integer {0..1023},
    required_low_zero_bits: integer {0..13},
    required_high_zero_bits: integer {0..2},
    has_zero: boolean,
    has_signed_zero: boolean,
    has_subnormal: boolean,
    has_infinity: boolean,
    has_quiet_nan: boolean,
    has_signaling_nan: boolean
};

type HiF8DotField of enumeration {
    HiF8DotField_Denormal,
    HiF8DotField_D0,
    HiF8DotField_D1,
    HiF8DotField_D2,
    HiF8DotField_D3,
    HiF8DotField_D4
};
```

### New public ASL functions

```asl
pure func TileNumericFormatDescriptor(data_type: TileDataType)
    => NumericFormatDescriptor;

pure func TileNumericFiniteDecomposition(data_type: TileDataType,
                                          value: Word)
    => (boolean, boolean, Word, integer {-1074..1023});

pure func HiF8DecodeDotField(value: bits(8))
    => (HiF8DotField, integer {0..4}, integer {1..3});

pure func HardwareNumericScaleBlockElements() => integer {32};
```

The decomposition tuple is `(available, negative, significand, exponent)`.
When `available` is false, the remaining values are deterministic zeros but
have no numeric meaning.

Each per-format file exports:

```text
<Format>NumericFormatDescriptor
<Format>FiniteDecomposition
```

For example, `fp32.asl` exports `FP32NumericFormatDescriptor` and
`FP32FiniteDecomposition`.

---

### Task 1: Add the common descriptor and test topology

**Files:**

- Modify: `asl/types.asl`
- Modify: `asl/numeric/formats.asl`
- Modify: `Makefile`
- Create: `tests/asl/numeric/formats/common.asl`
- Create: `tests/asl/shards/numeric-formats.asl`
- Modify: `tests/asl/main.asl`

**Interfaces:**

- Produces: `NumericFormatKind`, `NumericFormatDescriptor`, `HiF8DotField`, `TileNumericFormatDescriptor`, and `TileNumericFiniteDecomposition`.
- Preserves: `TileNumericEncodingValid`, `TileNumericValueClass`, `TileNumericCanonicalNaN`, and all existing hardware-profile helpers.

- [ ] **Step 1: Write the failing common API test**

Create `tests/asl/numeric/formats/common.asl` with `TestNumericFormatCommon`.
Assert that integer types return an unavailable floating descriptor and an
unavailable finite decomposition:

```asl
func TestNumericFormatCommon()
begin
    let descriptor = TileNumericFormatDescriptor(TileDataType_S32);
    assert !descriptor.available;
    assert descriptor.kind == NumericFormatKind_Unavailable;
    assert descriptor.carrier_bits == 0;
    let (available, negative, significand, exponent) =
        TileNumericFiniteDecomposition(TileDataType_S32,
            Zeros{PTO_XLEN} + 1);
    assert !available;
    assert !negative;
    assert significand == Zeros{PTO_XLEN};
    assert exponent == 0;
end;
```

Add `TestNumericFormatCommon()` to `tests/asl/main.asl`. Create
`tests/asl/shards/numeric-formats.asl` with the same call. Add the new test
library and shard to the Makefile.

- [ ] **Step 2: Run the focused shard and verify RED**

Run:

```bash
make test-shard-numeric-formats
```

Expected: strict type-check failure because `NumericFormatDescriptor` and the
two generic functions do not exist.

- [ ] **Step 3: Add the minimal common production API**

Add the exact types shown in this plan to `asl/types.asl`. Add unavailable
descriptor construction and temporary total dispatch defaults to
`asl/numeric/formats.asl`. Every floating/scale type may initially return
unavailable; integer types must return unavailable permanently. Do not alter
existing classification behavior.

- [ ] **Step 4: Run the focused shard and verify GREEN**

Run `make test-shard-numeric-formats` and require a clean pass.

- [ ] **Step 5: Commit only the common contract files**

```bash
git add asl/types.asl asl/numeric/formats.asl Makefile \
  tests/asl/numeric/formats/common.asl \
  tests/asl/shards/numeric-formats.asl tests/asl/main.asl
git commit --only asl/types.asl asl/numeric/formats.asl Makefile \
  tests/asl/numeric/formats/common.asl \
  tests/asl/shards/numeric-formats.asl tests/asl/main.asl \
  -m "spec: add exact numeric format contracts"
```

---

### Task 2: Implement FP64, FP32, TF32, HF32, FP16, and BF16

**Files:**

- Create: `asl/numeric/formats/{fp64,fp32,tf32,hf32,fp16,bf16}.asl`
- Create: `docs/numeric/formats/{fp64,fp32,tf32,hf32,fp16,bf16}.md`
- Create: `tests/asl/numeric/formats/{fp64,fp32,tf32,hf32,fp16,bf16}.asl`
- Modify: `asl/numeric/formats.asl`
- Modify: `Makefile`
- Modify: `tests/asl/main.asl`
- Modify: `tests/asl/shards/numeric-formats.asl`

**Interfaces:**

- Produces: descriptor and finite-decomposition functions for six wide fixed-binary formats.
- Consumes: `NumericFormatDescriptor` and the generic dispatch functions from Task 1.

- [ ] **Step 1: Add six failing same-basename tests**

Each test function asserts descriptor values, class boundaries, and exact
decomposition. Use these exact boundary vectors:

| Format | Min subnormal `(raw,sig,exp)` | Max subnormal `(raw,sig,exp)` | Min normal `(raw,sig,exp)` | Max normal `(raw,sig,exp)` |
| --- | --- | --- | --- | --- |
| FP64 | `1,1,-1074` | `0x000fffffffffffff,0x000fffffffffffff,-1074` | `0x0010000000000000,0x0010000000000000,-1074` | `0x7fefffffffffffff,0x001fffffffffffff,971` |
| FP32 | `1,1,-149` | `0x007fffff,0x007fffff,-149` | `0x00800000,0x00800000,-149` | `0x7f7fffff,0x00ffffff,104` |
| TF32 | `0x00002000,1,-136` | `0x007fe000,0x3ff,-136` | `0x00800000,0x400,-136` | `0x7f7fe000,0x7ff,117` |
| HF32 | `0x00001000,1,-137` | `0x007ff000,0x7ff,-137` | `0x00800000,0x800,-137` | `0x7f7ff000,0xfff,116` |
| FP16 | `1,1,-24` | `0x03ff,0x03ff,-24` | `0x0400,0x0400,-24` | `0x7bff,0x07ff,5` |
| BF16 | `1,1,-133` | `0x007f,0x007f,-133` | `0x0080,0x0080,-133` | `0x7f7f,0x00ff,120` |

Also assert positive and negative zero, both infinities, quiet and signaling
NaNs, and a negative finite value for each format. TF32 must reject raw `1`;
HF32 must reject raw `1`. Add all six test calls to canonical main and the
numeric-format shard.

- [ ] **Step 2: Run the focused shard and verify RED**

Run `make test-shard-numeric-formats`.

Expected: undefined per-format descriptor/decomposition functions or generic
dispatch returning unavailable for the six types.

- [ ] **Step 3: Implement the six format files**

Use these exact descriptors:

| Format | Carrier/lane/lanes | Sign bit | E bits | M bits | Bias | Low-zero | Capabilities |
| --- | --- | ---: | ---: | ---: | ---: | ---: | --- |
| FP64 | `64/64/1` | 63 | 11 | 52 | 1023 | 0 | zero, signed zero, subnormal, infinity, qNaN, sNaN |
| FP32 | `32/32/1` | 31 | 8 | 23 | 127 | 0 | zero, signed zero, subnormal, infinity, qNaN, sNaN |
| TF32 | `32/32/1` | 31 | 8 | 10 | 127 | 13 | zero, signed zero, subnormal, infinity, qNaN, sNaN |
| HF32 | `32/32/1` | 31 | 8 | 11 | 127 | 12 | zero, signed zero, subnormal, infinity, qNaN, sNaN |
| FP16 | `16/16/1` | 15 | 5 | 10 | 15 | 0 | zero, signed zero, subnormal, infinity, qNaN, sNaN |
| BF16 | `16/16/1` | 15 | 8 | 7 | 127 | 0 | zero, signed zero, subnormal, infinity, qNaN, sNaN |

For valid finite fixed-binary values implement:

```text
zero      -> significand 0, exponent 0
subnormal -> significand fraction, exponent 1 - bias - fraction_bits
normal    -> significand 2^fraction_bits + fraction,
             exponent encoded_exponent - bias - fraction_bits
```

Use `Word` bit operations and `LSL(Zeros{PTO_XLEN} + 1, fraction_bits)` for the
hidden bit. Reject NaN, infinity, and invalid TF32/HF32 low bits by returning
`available = FALSE`.

- [ ] **Step 4: Wire generic dispatch and source order**

List the six ASL files before `asl/numeric/formats.asl` in the Makefile. Update
`TileNumericFormatDescriptor` and `TileNumericFiniteDecomposition` to call the
matching per-format functions.

- [ ] **Step 5: Run the focused shard and verify GREEN**

Run `make test-shard-numeric-formats` and require every boundary to pass.

- [ ] **Step 6: Write six same-basename documentation pages**

Each page contains: identity; carrier/lane widths; exact field layout; required
zero bits; zero/subnormal/normal/infinity/NaN rules; exact decomposition;
canonical NaN; signed zero; excluded operation/profile behavior; and the four
PTO requirement IDs. Use the descriptor and boundary tables above verbatim as
facts, not copied prose.

- [ ] **Step 7: Commit the six-format slice**

Stage and commit only the six triples, dispatcher, Makefile, main, and shard:

```bash
git add asl/numeric/formats.asl asl/numeric/formats/fp64.asl \
  asl/numeric/formats/fp32.asl asl/numeric/formats/tf32.asl \
  asl/numeric/formats/hf32.asl asl/numeric/formats/fp16.asl \
  asl/numeric/formats/bf16.asl docs/numeric/formats/fp64.md \
  docs/numeric/formats/fp32.md docs/numeric/formats/tf32.md \
  docs/numeric/formats/hf32.md docs/numeric/formats/fp16.md \
  docs/numeric/formats/bf16.md tests/asl/numeric/formats/fp64.asl \
  tests/asl/numeric/formats/fp32.asl tests/asl/numeric/formats/tf32.asl \
  tests/asl/numeric/formats/hf32.asl tests/asl/numeric/formats/fp16.asl \
  tests/asl/numeric/formats/bf16.asl Makefile tests/asl/main.asl \
  tests/asl/shards/numeric-formats.asl
git commit --only asl/numeric/formats.asl asl/numeric/formats/fp64.asl \
  asl/numeric/formats/fp32.asl asl/numeric/formats/tf32.asl \
  asl/numeric/formats/hf32.asl asl/numeric/formats/fp16.asl \
  asl/numeric/formats/bf16.asl docs/numeric/formats/fp64.md \
  docs/numeric/formats/fp32.md docs/numeric/formats/tf32.md \
  docs/numeric/formats/hf32.md docs/numeric/formats/fp16.md \
  docs/numeric/formats/bf16.md tests/asl/numeric/formats/fp64.asl \
  tests/asl/numeric/formats/fp32.asl tests/asl/numeric/formats/tf32.asl \
  tests/asl/numeric/formats/hf32.asl tests/asl/numeric/formats/fp16.asl \
  tests/asl/numeric/formats/bf16.asl Makefile tests/asl/main.asl \
  tests/asl/shards/numeric-formats.asl \
  -m "spec: define wide floating formats exactly"
```

---

### Task 3: Implement E4M3, E5M2, E3M2, and E2M3

**Files:**

- Create: `asl/numeric/formats/{e4m3,e5m2,e3m2,e2m3}.asl`
- Create: `docs/numeric/formats/{e4m3,e5m2,e3m2,e2m3}.md`
- Create: `tests/asl/numeric/formats/{e4m3,e5m2,e3m2,e2m3}.asl`
- Modify: `asl/numeric/formats.asl`
- Modify: `Makefile`
- Modify: `tests/asl/main.asl`
- Modify: `tests/asl/shards/numeric-formats.asl`

**Interfaces:**

- Produces: exact fixed-binary low-precision descriptors and decompositions.
- Preserves: E4M3 one-code NaN behavior, E5M2 IEEE-style specials, and FP6 zero-extension constraints.

- [ ] **Step 1: Add four failing same-basename tests**

Use these exact vectors:

| Format | Min subnormal | Max subnormal | Min normal | Max normal |
| --- | --- | --- | --- | --- |
| E4M3 | `raw=0x01,sig=1,exp=-9` | `0x07,7,-9` | `0x08,8,-9` | `0x7e,14,5` |
| E5M2 | `0x01,1,-16` | `0x03,3,-16` | `0x04,4,-16` | `0x7b,7,13` |
| E3M2 | `0x01,1,-4` | `0x03,3,-4` | `0x04,4,-4` | `0x1f,7,2` |
| E2M3 | `0x01,1,-3` | `0x07,7,-3` | `0x08,8,-3` | `0x1f,15,-1` |

Assert E4M3 `0x7f` and `0xff` are quiet NaNs and no encoding is infinity.
Assert E5M2 `0x7c` is +infinity, `0xfc` is -infinity, `0x7e` is quiet NaN,
and `0x7d` is signaling NaN. Assert all valid E3M2/E2M3 encodings are finite,
and raw values with bits `[7:6] != 00` are invalid.

- [ ] **Step 2: Run the focused shard and verify RED**

Run `make test-shard-numeric-formats`; require failure on the missing four
format functions or unavailable generic dispatch.

- [ ] **Step 3: Implement descriptors and finite decoders**

Use:

| Format | Carrier/lane/lanes | Sign | E | M | Bias | High-zero | Specials |
| --- | --- | ---: | ---: | ---: | ---: | ---: | --- |
| E4M3 | `8/8/1` | 7 | 4 | 3 | 7 | 0 | no infinity; E=15/M=7 quiet NaN |
| E5M2 | `8/8/1` | 7 | 5 | 2 | 15 | 0 | infinity, qNaN, sNaN |
| E3M2 | `8/6/1` | 5 | 3 | 2 | 3 | 2 | finite only |
| E2M3 | `8/6/1` | 5 | 2 | 3 | 1 | 2 | finite only |

Return unavailable for E4M3 NaN, E5M2 infinity/NaN, and invalid FP6 padding.

- [ ] **Step 4: Wire dispatch and verify GREEN**

Add the four sources to Makefile dependency order, extend both generic
dispatchers, and run `make test-shard-numeric-formats` to a clean pass.

- [ ] **Step 5: Write four same-basename documentation pages**

Document exact fields, formulas, raw boundaries, special-value differences,
and the FP6 carrier/payload distinction. State that the decoder returns the
unscaled base value and does not apply E8M0.

- [ ] **Step 6: Commit the low-precision fixed-binary slice**

Commit only the four triples plus dispatcher, Makefile, main, and shard with:

```bash
git add asl/numeric/formats.asl asl/numeric/formats/e4m3.asl \
  asl/numeric/formats/e5m2.asl asl/numeric/formats/e3m2.asl \
  asl/numeric/formats/e2m3.asl docs/numeric/formats/e4m3.md \
  docs/numeric/formats/e5m2.md docs/numeric/formats/e3m2.md \
  docs/numeric/formats/e2m3.md tests/asl/numeric/formats/e4m3.asl \
  tests/asl/numeric/formats/e5m2.asl tests/asl/numeric/formats/e3m2.asl \
  tests/asl/numeric/formats/e2m3.asl Makefile tests/asl/main.asl \
  tests/asl/shards/numeric-formats.asl
git commit --only asl/numeric/formats.asl asl/numeric/formats/e4m3.asl \
  asl/numeric/formats/e5m2.asl asl/numeric/formats/e3m2.asl \
  asl/numeric/formats/e2m3.asl docs/numeric/formats/e4m3.md \
  docs/numeric/formats/e5m2.md docs/numeric/formats/e3m2.md \
  docs/numeric/formats/e2m3.md tests/asl/numeric/formats/e4m3.asl \
  tests/asl/numeric/formats/e5m2.asl tests/asl/numeric/formats/e3m2.asl \
  tests/asl/numeric/formats/e2m3.asl Makefile tests/asl/main.asl \
  tests/asl/shards/numeric-formats.asl \
  -m "spec: define low-precision binary formats exactly"
```

---

### Task 4: Implement HiF8 dynamic decoding

**Files:**

- Create: `asl/numeric/formats/hif8.asl`
- Create: `docs/numeric/formats/hif8.md`
- Create: `tests/asl/numeric/formats/hif8.asl`
- Modify: `asl/numeric/formats.asl`
- Modify: `Makefile`
- Modify: `tests/asl/main.asl`
- Modify: `tests/asl/shards/numeric-formats.asl`

**Interfaces:**

- Produces: `HiF8NumericFormatDescriptor`, `HiF8DecodeDotField`, and `HiF8FiniteDecomposition`.

- [ ] **Step 1: Write the failing HiF8 test**

Assert the descriptor is `carrier=8`, `lane=8`, one lane, sign bit 7,
exponent width 0..4, fraction width 1..3, no fixed bias, one zero, no signed
zero, subnormal, infinity, quiet NaN, and no signaling NaN.

Assert dot decoding:

```text
0000 -> Denormal, E0, M3
0001 -> D0,       E0, M3
001  -> D1,       E1, M3
01   -> D2,       E2, M3
10   -> D3,       E3, M2
11   -> D4,       E4, M1
```

Assert exact finite values:

| Raw | Meaning | Decomposition |
| ---: | --- | --- |
| `0x00` | zero | `available,+,0,0` |
| `0x01` | minimum positive subnormal | `available,+,1,-22` |
| `0x07` | maximum positive subnormal | `available,+,1,-16` |
| `0x81` | negative minimum subnormal | `available,-,1,-22` |
| `0x08` | D0, M=0 | `available,+,8,-3` |
| `0x0f` | D0, M=7 | `available,+,15,-3` |
| `0x10` | D1, E=+1, M=0 | `available,+,8,-2` |
| `0x18` | D1, E=-1, M=0 | `available,+,8,-4` |
| `0x20` | D2 exponent lower boundary | `available,+,8,-1` |
| `0x40` | D3 exponent lower boundary | `available,+,4,2` |
| `0x60` | D4 exponent lower boundary | `available,+,2,7` |
| `0x6e` | largest positive non-special D4/M0 boundary | `available,+,2,14` |

Assert `0x80` is quiet NaN, `0x6f` is +infinity, and `0xef` is -infinity;
finite decomposition returns unavailable for all three.

- [ ] **Step 2: Run the focused shard and verify RED**

Run `make test-shard-numeric-formats`; require missing HiF8 APIs or unavailable
dispatch.

- [ ] **Step 3: Implement dot-field and exponent decoding**

Decode prefixes by longest applicable prefix. For D1..D4, treat the exponent
field's most-significant bit as exponent sign and prepend an implicit magnitude
one to the remaining bits. For a normal with `m` fraction bits:

```text
significand = 2^m + fraction
exponent = signed_exponent - m
```

For prefix `0000`, mantissa 1..7:

```text
significand = 1
exponent = mantissa - 23
```

Apply special raw encodings before ordinary decomposition.

- [ ] **Step 4: Wire dispatch and verify GREEN**

Add `hif8.asl` to Makefile, extend generic descriptor/decomposition dispatch,
and run `make test-shard-numeric-formats`.

- [ ] **Step 5: Write `hif8.md`**

Document all six prefix layouts, exponent sign-magnitude decoding, finite
decomposition, subnormal domain, and the four special rows: zero, NaN, +Inf,
and -Inf.

- [ ] **Step 6: Commit the HiF8 slice**

```bash
git add asl/numeric/formats.asl asl/numeric/formats/hif8.asl \
  docs/numeric/formats/hif8.md tests/asl/numeric/formats/hif8.asl \
  Makefile tests/asl/main.asl tests/asl/shards/numeric-formats.asl
git commit --only asl/numeric/formats.asl asl/numeric/formats/hif8.asl \
  docs/numeric/formats/hif8.md tests/asl/numeric/formats/hif8.asl \
  Makefile tests/asl/main.asl tests/asl/shards/numeric-formats.asl \
  -m "spec: define HiF8 dynamic format exactly"
```

---

### Task 5: Implement packed FP4 identities and E8M0 scale

**Files:**

- Create: `asl/numeric/formats/{e2m1x2,e1m2x2,hif4x2,e8m0}.asl`
- Create: `docs/numeric/formats/{e2m1x2,e1m2x2,hif4x2,e8m0}.md`
- Create: `tests/asl/numeric/formats/{e2m1x2,e1m2x2,hif4x2,e8m0}.asl`
- Modify: `asl/numeric/formats.asl`
- Modify: `Makefile`
- Modify: `tests/asl/main.asl`
- Modify: `tests/asl/shards/numeric-formats.asl`

**Interfaces:**

- Produces: exact logical-lane decoders for three packed identities, E8M0 scale decoding, and `HardwareNumericScaleBlockElements`.

- [ ] **Step 1: Add four failing same-basename tests**

For E2M1X2, exhaust all positive low-nibble values:

```text
0:+0, 1:+0.5, 2:+1, 3:+1.5, 4:+2, 5:+3, 6:+4, 7:+6
```

Repeat encodings 8..15 with negative sign, including negative zero at 8.
Expected decompositions use `(sig,exp)`:

```text
0:(0,0), 1:(1,-1), 2:(2,-1), 3:(3,-1),
4:(2,0), 5:(3,0), 6:(2,1), 7:(3,1)
```

For E1M2X2 and HiF4X2, exhaust:

```text
0:+0, 1:+0.25, 2:+0.5, 3:+0.75,
4:+1, 5:+1.25, 6:+1.5, 7:+1.75
```

Use `(sig,exp)` `0:(0,0)`, `1..3:(raw,-2)`, and
`4..7:(raw,-2)`, then repeat with negative sign for 8..15.

For E8M0 assert:

```text
raw 0x00 -> +1 * 2^-127
raw 0x01 -> +1 * 2^-126
raw 0x7f -> +1 * 2^0
raw 0x80 -> +1 * 2^1
raw 0xfe -> +1 * 2^127
raw 0xff -> quiet NaN and unavailable finite decomposition
```

Assert `HardwareNumericScaleBlockElements() == 32`.

- [ ] **Step 2: Run the focused shard and verify RED**

Run `make test-shard-numeric-formats`; require failure on missing packed/scale
functions or unavailable dispatch.

- [ ] **Step 3: Implement the three packed format files**

Use carrier width 8, lane width 4, and two lanes per carrier. Decomposition
consumes `value[3:0]` only. E2M1X2 is S1/E2/M1; E1M2X2 and HiF4X2 are
S1/E1/M2. All encodings are finite; all have signed zero; none has
subnormal, infinity, or NaN capability. Keep HiF4X2 a distinct descriptor
identity even though its raw lane values equal E1M2X2.

- [ ] **Step 4: Implement E8M0**

Use carrier/lane width 8, one lane, no sign, E8/M0, bias 127, no zero,
subnormal, infinity, or signed zero, and one quiet NaN at `0xff`. For raw
`0x00..0xfe`, return `(TRUE, FALSE, 1, UInt(raw)-127)`. Return unavailable for
`0xff`. Return scale block size 32 from the named hardware helper.

- [ ] **Step 5: Wire dispatch and verify GREEN**

Add the four sources to Makefile, extend both generic dispatchers, and run
`make test-shard-numeric-formats`.

- [ ] **Step 6: Write four same-basename pages**

The three packed pages include all 16 lane values and link to the PTO-owned
packing ADR. `e8m0.md` defines the power-of-two scale, NaN, absence of zero,
and 32-element scale block while excluding operation-level scale application.

- [ ] **Step 7: Commit the packed and scale slice**

```bash
git add asl/numeric/formats.asl \
  asl/numeric/formats/e2m1x2.asl asl/numeric/formats/e1m2x2.asl \
  asl/numeric/formats/hif4x2.asl asl/numeric/formats/e8m0.asl \
  docs/numeric/formats/e2m1x2.md docs/numeric/formats/e1m2x2.md \
  docs/numeric/formats/hif4x2.md docs/numeric/formats/e8m0.md \
  tests/asl/numeric/formats/e2m1x2.asl \
  tests/asl/numeric/formats/e1m2x2.asl \
  tests/asl/numeric/formats/hif4x2.asl \
  tests/asl/numeric/formats/e8m0.asl Makefile tests/asl/main.asl \
  tests/asl/shards/numeric-formats.asl
git commit --only asl/numeric/formats.asl \
  asl/numeric/formats/e2m1x2.asl asl/numeric/formats/e1m2x2.asl \
  asl/numeric/formats/hif4x2.asl asl/numeric/formats/e8m0.asl \
  docs/numeric/formats/e2m1x2.md docs/numeric/formats/e1m2x2.md \
  docs/numeric/formats/hif4x2.md docs/numeric/formats/e8m0.md \
  tests/asl/numeric/formats/e2m1x2.asl \
  tests/asl/numeric/formats/e1m2x2.asl \
  tests/asl/numeric/formats/hif4x2.asl \
  tests/asl/numeric/formats/e8m0.asl Makefile tests/asl/main.asl \
  tests/asl/shards/numeric-formats.asl \
  -m "spec: define packed formats and E8M0 scale"
```

---

### Task 6: Consolidate dispatch and remove duplicate broad format tests

**Files:**

- Modify: `asl/numeric/formats.asl`
- Modify: `tests/asl/profile-tests.asl`
- Modify: `tests/asl/numeric/formats/common.asl`
- Modify: `tests/asl/main.asl`
- Modify: `tests/asl/shards/concurrency-profile.asl`
- Modify: `tests/asl/shards/numeric-formats.asl`

**Interfaces:**

- Ensures: every one of 15 floating/scale identities resolves to one descriptor and one exact decoder; all ten integer identities return unavailable.
- Preserves: cross-format subnormal policy and special-result profile tests.

- [ ] **Step 1: Add failing totality assertions to `common.asl`**

Assert descriptor availability for FP64 through HiF4X2, exact unavailability
for S64/S32/S16/S8/S4X2/U64/U32/U16/U8/U4X2, and consistency between
descriptor capabilities and `HardwareNumericTypeHasSubnormals`,
`HardwareNumericSignedZeroEncodings`, and canonical-NaN availability.

- [ ] **Step 2: Verify RED if any dispatcher case is missing**

Run `make test-shard-numeric-formats`. Expected: failure naming the omitted or
inconsistent identity. If it passes immediately, deliberately replace one
descriptor dispatch case with unavailable, rerun to observe the intended
failure, then restore it before continuing.

- [ ] **Step 3: Make dispatch total and remove per-format duplication**

Keep format-specific boundary assertions only in same-basename test files.
Retain `ValidateNumericFormatClassification` in `profile-tests.asl` for
cross-format subnormal policy, comparison/min/max special behavior, and shared
scalar FP32/FP64 integration. Do not delete coverage; move assertions to the
new files before removing duplicates.

- [ ] **Step 4: Run both affected shards**

```bash
make test-shard-numeric-formats
make test-shard-concurrency-profile
```

Require both to pass.

- [ ] **Step 5: Commit the consolidation**

```bash
git add asl/numeric/formats.asl tests/asl/profile-tests.asl \
  tests/asl/numeric/formats/common.asl tests/asl/main.asl \
  tests/asl/shards/concurrency-profile.asl \
  tests/asl/shards/numeric-formats.asl
git commit --only asl/numeric/formats.asl tests/asl/profile-tests.asl \
  tests/asl/numeric/formats/common.asl tests/asl/main.asl \
  tests/asl/shards/concurrency-profile.asl \
  tests/asl/shards/numeric-formats.asl \
  -m "test: isolate numeric format evidence"
```

---

### Task 7: Add the format index, ADR, and requirement traceability

**Files:**

- Create: `docs/numeric/formats/index.md`
- Create: `docs/architecture-decisions/0057-exact-numeric-format-decomposition.md`
- Modify: `docs/architecture.md`
- Modify: `docs/normative-sources.md`
- Modify: `docs/coverage.md`
- Modify: `spec/requirements.json`

**Interfaces:**

- Produces: PTO-owned normative explanation and stable traceability for the exact ASL format contracts.

- [ ] **Step 1: Write the ADR and index**

The ADR accepts a new `PD-02-SC3` checkpoint with these rules:

```text
1. Carrier, lane, packing, and padding are distinct properties.
2. Every finite floating/scale encoding has one exact integer-times-power-of-two decomposition.
3. HiF8 uses the accepted dynamic dot/exponent/mantissa decoder.
4. E8M0 decodes a scale but does not apply it to an operation.
5. Classification and exact decomposition do not select arithmetic or profile support.
```

The index links all 15 same-basename pages and defines the common tuple once.
It contains only PTO-owned links.

- [ ] **Step 2: Update architecture, normative sources, and coverage**

Add the exact-decomposition checkpoint without changing the M4 floor or
claiming S5-T2 conformance. State that all 15 floating/scale identities have
executable descriptors and exact finite decoders, while arithmetic and
operation/type/profile legality remain open.

- [ ] **Step 3: Update stable requirement traceability**

Add the ADR, index, all 15 production ASL files, all 15 documentation pages,
and all 16 numeric-format test files to the model/tests lists of:

```text
PTO-REQ-PROFILE-001
PTO-REQ-SCALAR-FP-001
PTO-REQ-HARDWARE-NUMERIC-001
PTO-REQ-CLOSURE-001
```

Do not create an external-source requirement or path.

- [ ] **Step 4: Validate documentation hygiene**

```bash
./scripts/check-publication-hygiene
rg -n '/Users/|Documents/' asl/numeric docs/numeric \
  docs/architecture-decisions/0057-exact-numeric-format-decomposition.md \
  tests/asl/numeric spec/requirements.json
git diff --check
```

Expected: `rg` returns no matches and `git diff --check` passes.

- [ ] **Step 5: Commit normative documentation and traceability**

```bash
git add docs/numeric/formats/index.md \
  docs/architecture-decisions/0057-exact-numeric-format-decomposition.md \
  docs/architecture.md docs/normative-sources.md docs/coverage.md \
  spec/requirements.json
git commit --only docs/numeric/formats/index.md \
  docs/architecture-decisions/0057-exact-numeric-format-decomposition.md \
  docs/architecture.md docs/normative-sources.md docs/coverage.md \
  spec/requirements.json \
  -m "docs: accept exact numeric format decomposition"
```

---

### Task 8: Extend generated numeric-format evidence and repository checks

**Files:**

- Modify: `scripts/generate-numeric-format-namespace-contract`
- Modify: `scripts/check-catalogs`
- Modify: `spec/evidence/numeric-format-namespace-contract.json`
- Modify: `spec/evidence/release-traceability-readiness.json`
- Modify: `spec/release-manifest.json`

**Interfaces:**

- Produces: fail-closed machine-readable proof of descriptor/decomposition coverage.

- [ ] **Step 1: Write the failing generator/checker expectations**

Extend the generated schema with:

```json
"exact_decomposition": {
  "checkpoint_id": "PD-02-SC3",
  "acceptance_record": "docs/architecture-decisions/0057-exact-numeric-format-decomposition.md",
  "descriptor": "TileNumericFormatDescriptor",
  "finite_decoder": "TileNumericFiniteDecomposition",
  "representation": "(-1)^negative * UInt(significand) * 2^exponent",
  "format_count": 15,
  "status": "closed"
}
```

Each floating/scale format row gains carrier bits, lane bits, lanes per carrier,
field-width ranges, bias availability/value, zero-padding counts, capability
flags, production ASL path, documentation path, and test path. Add the 15 ASL
files and ADR to the content-addressed source list. Update the checker to
require exact source/test existence and function-name witnesses.

- [ ] **Step 2: Run the checker and verify RED**

Run:

```bash
./scripts/generate-numeric-format-namespace-contract --check
```

Expected: stale generated evidence because the schema and source hashes have
changed.

- [ ] **Step 3: Regenerate the format contract**

```bash
./scripts/generate-numeric-format-namespace-contract --write
./scripts/generate-numeric-format-namespace-contract --check
```

Require the second command to pass.

- [ ] **Step 4: Regenerate dependent traceability and manifest evidence**

```bash
./scripts/generate-release-traceability-readiness
./scripts/generate-release-manifest
./scripts/generate-release-traceability-readiness --check
./scripts/generate-release-manifest --check
```

Inspect generated diffs and confirm they contain only expected source hashes,
traceability links, counts, and manifest projections.

- [ ] **Step 5: Run the catalog checker**

Run `./scripts/check-catalogs`. Require schema, source hashes, test witnesses,
and summary counts to pass.

- [ ] **Step 6: Commit evidence and checks**

```bash
git add scripts/generate-numeric-format-namespace-contract \
  scripts/check-catalogs spec/evidence/numeric-format-namespace-contract.json \
  spec/evidence/release-traceability-readiness.json spec/release-manifest.json
git commit --only scripts/generate-numeric-format-namespace-contract \
  scripts/check-catalogs spec/evidence/numeric-format-namespace-contract.json \
  spec/evidence/release-traceability-readiness.json spec/release-manifest.json \
  -m "spec: track exact numeric format evidence"
```

---

### Task 9: Run final verification and review the complete change

**Files:**

- Verify only; modify a file only to fix a demonstrated failure in the files owned by Tasks 1–8.

**Interfaces:**

- Proves: ASL type soundness, direct format execution, shard closure, repository consistency, evidence freshness, and publication hygiene.

- [ ] **Step 1: Run focused numeric tests**

```bash
make test-shard-numeric-formats
make test-shard-concurrency-profile
```

- [ ] **Step 2: Run strict specification and repository checks**

```bash
make check
make repo-check
./scripts/check-catalogs
git diff --check
```

- [ ] **Step 3: Run the complete executable suite**

```bash
make test-parallel
```

If ASLRef setup is unavailable, record the exact missing prerequisite and keep
the successful repository/checker evidence separate from the unexecuted gate.

- [ ] **Step 4: Verify source-identity hygiene**

```bash
./scripts/check-publication-hygiene
rg -n '/Users/|Documents/' asl/numeric docs/numeric \
  docs/architecture-decisions/0057-exact-numeric-format-decomposition.md \
  tests/asl/numeric spec/requirements.json \
  spec/evidence/numeric-format-namespace-contract.json
```

Expected: no matches.

- [ ] **Step 5: Inspect scope and generated-file hygiene**

```bash
git status --short
git diff --stat b481d642..HEAD
git ls-files build .cache
```

Confirm no unrelated worktree changes were committed, and generated build/cache
files remain untracked.

- [ ] **Step 6: Request code review before integration**

Use the repository's `requesting-code-review` workflow against the complete
numeric-format commit range. Resolve correctness findings, rerun the smallest
affected test first, then rerun Steps 1–4 before claiming completion.

---

## Plan self-review

- Every approved format has one same-basename ASL, documentation, and test file.
- Every new production API is introduced by a failing test.
- FP6 carrier padding, TF32/HF32 low zero bits, packed FP4 lanes, HiF8 dynamic
  fields, and E8M0 scaling are all explicit.
- Existing classifiers and profile-special behavior remain covered.
- Requirements, ADR, coverage, evidence generation, and release traceability
  are updated together.
- The plan introduces no operation arithmetic or target-conformance claim.
- No checked-in artifact records a non-public migration source identity or path.

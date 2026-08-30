<!-- GENERATED FROM: asl/arch/profile/service-request-intercept.asl -->
# Service Request Intercept

**Normative ASL source:** `asl/arch/profile/service-request-intercept.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-PROFILE-SERVICE-REQUEST-INTERCEPT}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-service-request-intercept-purpose role=purpose-scope -->
## Purpose and scope

This architecture profile hook separates portable ACRC behavior from a separately owned execution-model or hosted-ABI intercept. PTO itself assigns no syscall, process, or host-request meaning.

<!-- PTO-READER-BLOCK: arch-service-request-intercept-concepts role=concepts-state -->
## Hook result

`FALSE` means the architecture owner continues with ACRC permission, service-ring routing, trap publication, terminal marking, and recovery. An overriding model may return `TRUE` only under its own model/ABI NDF.

<!-- PTO-READER-BLOCK: arch-service-request-intercept-rules role=rules-interactions -->
## Preservation rule

The portable default is always `FALSE`. A model override must leave every non-intercepted request on the exact PTO path and may not use the hook to alter instruction encoding, legality, or unrelated state transitions.

<!-- PTO-READER-BLOCK: arch-service-request-intercept-boundaries role=boundaries -->
## Boundaries

PTO defines the hook and preservation requirement only. Request tokens, result GPRs, resume policy, ELF conventions, process status, and syscall numbers belong to the consuming model repository.

<!-- PTO-READER-BLOCK: arch-service-request-intercept-example role=example-usage -->
## Non-normative example

A freestanding model may map one reviewed ACRC tuple to a host-exit request. That tuple is model ABI; executing the same ACRC without the model override follows portable PTO service-request semantics.

<!-- PTO-READER-BLOCK: arch-service-request-intercept-related role=related-owners-navigation -->
## Related owners

- [Functional-model harness](functional-model.md) supplies one non-architectural implementation.
- [Fault precision](../memory-model/fault-precision.md) owns portable service-request trap publication.
- [ACRC](../../scalar/sys/ACRC.md) owns the instruction-local contract.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/profile/service-request-intercept.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-PROFILE-SERVICE-REQUEST-INTERCEPT","surface":"arch","classification":["profile","service-request-intercept"],"depends_on":["PTO-ARCH-DATA-TYPES-INTEGER"]}

// NDF-BEGIN: PTO-REQ-SERVICE-REQUEST-INTERCEPT-001
// ndf: kind=contract level=L1 layer=architecture status=accepted
// Portable PTO execution MUST NOT intercept an ACRC close request before its
// architecture-owned permission, routing, trap, terminal, and recovery rules.
// A separately owned execution-model profile MAY override the hook only under
// its own model or hosted-ABI contract.  A false result MUST retain the exact
// portable ACRC transition, and PTO assigns no syscall or process meaning to
// an intercepted request.
// NDF-END: PTO-REQ-SERVICE-REQUEST-INTERCEPT-001

impdef func InterceptArchitectureCloseRequest(
    request_type: bits(4)) => boolean
begin
    return FALSE;
end;
```
<!-- GENERATED-ASL-END: unit -->

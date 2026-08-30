<!-- GENERATED FROM: asl/arch/profile/service-request-intercept.asl -->
# Service Request Intercept

**Normative ASL source:** `asl/arch/profile/service-request-intercept.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-PROFILE-SERVICE-REQUEST-INTERCEPT}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->

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

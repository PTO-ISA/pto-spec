<!-- GENERATED FROM: asl/scalar/model/sys/registers.asl -->
# Registers

**Normative ASL source:** `asl/scalar/model/sys/registers.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-SCALAR-MODEL-SYS-REGISTERS}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-model-sys-registers-purpose role=purpose-scope -->
## Purpose and scope

This unit implements scalar system-register (SSR) transfers by 24-bit address. It checks access-ring permission and access class, routes an address to a base register or a context register, and runs the read, write, and swap helpers used by `SSRGET`, `SSRSET`, and `SSRSWAP`.

The helpers are `ReadSystemRegisterAddress`, `WriteSystemRegisterAddress`, `SwapSystemRegisterAddress`, and the four `Execute...` wrappers that dispatch calls.

<!-- PTO-READER-BLOCK: scalar-model-sys-registers-concepts role=concepts-state -->
## Concepts and visible state

An SSR address is a `SystemRegisterAddress` of 24 bits. Two kinds of address exist:

- Base registers are 14 fixed addresses, such as 0x0000 `THREAD_PTR`, 0x0020 `CORE_STATE`, 0x0027 `TILE_CAPACITY`, and 0x0C00 `CYCLE`. `BaseSystemRegisterOfAddress` maps them to the `SystemRegister` enumeration.
- Extended registers are the other addresses. Bits 15:12 name an access-ring bank, and bits 11:0 name the register within it. Most are stored in `_ExtendedSystemRegisters`, indexed by bits 15:0.

An access class is read-only, write-only, read-write, or unknown. The generated `SystemRegisterAccessOf` returns it for each address.

Access-ring (ACR) permission is simple in this model: an address whose bits 11:0 are below 0x0F00 is open to every ring; any other address needs ACR0.

<!-- PTO-READER-BLOCK: scalar-model-sys-registers-rules role=rules-interactions -->
## Rules and interactions

`ReadSystemRegisterAddress` rejects a read when the ring lacks permission or the class is unknown or write-only. The rejection raises `Fault_IllegalInstruction` and returns 0. Otherwise it reads the base register, or one of five extended registers with special read behavior (0x0F02 trap status, 0x0F03 trap argument, 0x0F08 interrupt pending, 0x0F09 top pending interrupt, 0x0F20 time), or the stored extended value.

`WriteSystemRegisterAddress` rejects a write when the ring lacks permission or the class is unknown or read-only. Writes to 0x0F02, 0x0F03, and 0x0F0A (end of interrupt) have special effects, and a write to 0x0F21 also refreshes the ring's timer-pending state.

`ExecuteSystemRegisterSet` and `ExecuteSystemRegisterSwap` check permission before they read their Reg5 source.

Design point: a check that fails comes before any source read or register access. A rejected transfer therefore reads no source, writes no destination, and changes no register.

`SwapSystemRegisterAddress` requires read permission, write permission, and the read-write class before it reads.

Design point: the swap preflight exists because some reads have effects. The ASL comment names timer-pending refresh on a read-only register. Checking both directions first means a rejected swap cannot perform a read-side effect and then fail on the write.

The get helpers write the destination only if `_LastFault` is `Fault_None`.

<!-- PTO-READER-BLOCK: scalar-model-sys-registers-boundaries role=boundaries -->
## Architectural boundaries

`SystemRegisterFileIndexOf` asserts that bits 23:16 are zero. A nonzero high byte reaches that assertion only if the class lookup has admitted the address; the generated table admits only addresses with bits 23:16 clear.

Writes to base registers go to `WriteSystemRegister` in [SYS semantics](semantics.md). Only `THREAD_PTR`, `GLOBAL_PTR`, `CORE_STATE`, and `CORE_FEATURE_ENABLE` are writable there, and writing `CORE_STATE` also updates the current access ring from bits 3:0.

Trap, interrupt, and timer registers are owned by their architecture units; this unit only routes to them.

<!-- PTO-READER-BLOCK: scalar-model-sys-registers-example role=example-usage -->
## Non-normative reading example

Consider `SSRSWAP` at ACR2 with address 0x0010 (`TIME`), then at ACR0 with address 0x1F03.

| Case | Permission | Class | Result |
| --- | --- | --- | --- |
| 0x0010 at ACR2 | open, since 0x010 is below 0xF00 | read-only | `Fault_IllegalInstruction`; no read, no write |
| 0x1F03 at ACR0 | ACR0 | read-write | old ring-1 trap argument returned, new value stored |

In the second case the ring bank is 1, taken from bits 15:12, so the swap touches `_ACRTrapArgument0` for ring 1.

<!-- PTO-READER-BLOCK: scalar-model-sys-registers-related role=related-owners-navigation -->
## Related owners

- [SYS semantics](semantics.md) owns base-register read and write and `CORE_STATE` side effects.
- [SYS dispatch](../dispatch/sys.md) decodes the SSR address and destination.
- [Access control](../../../arch/system-registers/access-control.md) owns `CurrentACR`.
- [Interrupts](../../../arch/system-registers/interrupt.md) and [timer](../../../arch/system-registers/timer.md) own the special extended registers.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/scalar/model/sys/registers.asl -->
```asl
// PTO-UNIT: {"id":"PTO-SCALAR-MODEL-SYS-REGISTERS","surface":"scalar","classification":["model","sys","registers"],"depends_on":["PTO-SCALAR-MODEL-SYS-SEMANTICS","PTO-ARCH-SYSTEM-REGISTERS-MAINTENANCE"]}
// PTO-REQ-SCALAR-SSR-001, PTO-REQ-RESET-001: canonical 24-bit
// system-register addressing with explicit Access Control Ring checks.

readonly func SystemRegisterAccessPermitted(
    address: SystemRegisterAddress, write: boolean,
    ring: AccessControlRing) => boolean
begin
    // Base registers are available at every level. Context, translation, and
    // debug register families are ACR0-only in the PTO v0 profile.
    return UInt(address[11:0]) < 0x0f00 || ring == 0;
end;

pure func IsBaseSystemRegisterAddress(address: SystemRegisterAddress) => boolean
begin
    return address == Zeros{24} + 0x0000 ||
           address == Zeros{24} + 0x0001 ||
           address == Zeros{24} + 0x0010 ||
           address == Zeros{24} + 0x0020 ||
           address == Zeros{24} + 0x0021 ||
           address == Zeros{24} + 0x0022 ||
           address == Zeros{24} + 0x0023 ||
           address == Zeros{24} + 0x0024 ||
           address == Zeros{24} + 0x0025 ||
           address == Zeros{24} + 0x0026 ||
           address == Zeros{24} + 0x0027 ||
           address == Zeros{24} + 0x0050 ||
           address == Zeros{24} + 0x0051 ||
           address == Zeros{24} + 0x0c00;
end;

pure func BaseSystemRegisterOfAddress(address: SystemRegisterAddress) => SystemRegister
begin
    case UInt(address) of
        when 0x0000 => return SystemRegister_THREAD_PTR;
        when 0x0001 => return SystemRegister_GLOBAL_PTR;
        when 0x0010 => return SystemRegister_TIME;
        when 0x0020 => return SystemRegister_CORE_STATE;
        when 0x0021 => return SystemRegister_CORE_ID;
        when 0x0022 => return SystemRegister_VENDOR;
        when 0x0023 => return SystemRegister_VERSION;
        when 0x0024 => return SystemRegister_CORE_FEATURE;
        when 0x0025 => return SystemRegister_CORE_FEATURE_ENABLE;
        when 0x0026 => return SystemRegister_THREAD_ID;
        when 0x0027 => return SystemRegister_TILE_CAPACITY;
        when 0x0050 => return SystemRegister_BLOCKNUM;
        when 0x0051 => return SystemRegister_BLOCKID;
        when 0x0c00 => return SystemRegister_CYCLE;
        otherwise => unreachable;
    end;
end;

pure func SystemRegisterFileIndexOf(address: SystemRegisterAddress)
        => SystemRegisterFileIndex
begin
    assert address[23:16] == Zeros{8};
    return UInt(address[15:0]) as SystemRegisterFileIndex;
end;

func ReadSystemRegisterAddress(address: SystemRegisterAddress) => Word
begin
    if !SystemRegisterAccessPermitted(address, FALSE, CurrentACR()) then
        SetFault(Fault_IllegalInstruction, ReadPC());
        return Zeros{PTO_XLEN};
    end;
    let access = SystemRegisterAccessOf(address);
    if access == SystemRegisterAccess_Unknown ||
       access == SystemRegisterAccess_WriteOnly then
        SetFault(Fault_IllegalInstruction, ReadPC());
        return Zeros{PTO_XLEN};
    end;
    if IsBaseSystemRegisterAddress(address) then
        return ReadSystemRegister(BaseSystemRegisterOfAddress(address));
    end;

    let low_index = UInt(address[11:0]);
    let ring = UInt(address[15:12]) as AccessControlRing;
    if low_index == 0x0f02 then return PackTrapStatus(ring); end;
    if low_index == 0x0f03 then return _ACRTrapArgument0[[ring]]; end;
    if low_index == 0x0f08 then return ReadInterruptPending(ring); end;
    if low_index == 0x0f09 then return ReadTopPendingInterrupt(ring); end;
    if low_index == 0x0f20 then return ReadMonotonicTime(); end;
    return _ExtendedSystemRegisters[[SystemRegisterFileIndexOf(address)]];
end;

readonly func SystemRegisterWritePermitted(address: SystemRegisterAddress)
    => boolean
begin
    let access = SystemRegisterAccessOf(address);
    return SystemRegisterAccessPermitted(address, TRUE, CurrentACR()) &&
           access != SystemRegisterAccess_Unknown &&
           access != SystemRegisterAccess_ReadOnly;
end;

readonly func SystemRegisterSwapPermitted(address: SystemRegisterAddress)
    => boolean
begin
    return SystemRegisterAccessPermitted(address, FALSE, CurrentACR()) &&
           SystemRegisterAccessPermitted(address, TRUE, CurrentACR()) &&
           SystemRegisterAccessOf(address) == SystemRegisterAccess_ReadWrite;
end;

func WriteSystemRegisterAddress(address: SystemRegisterAddress, value: Word)
begin
    if !SystemRegisterWritePermitted(address) then
        SetFault(Fault_IllegalInstruction, ReadPC());
        return;
    end;
    if IsBaseSystemRegisterAddress(address) then
        WriteSystemRegister(BaseSystemRegisterOfAddress(address), value);
        return;
    end;

    let low_index = UInt(address[11:0]);
    let ring = UInt(address[15:12]) as AccessControlRing;
    if low_index == 0x0f02 then
        UnpackTrapStatus(ring, value);
    elsif low_index == 0x0f03 then
        _ACRTrapArgument0[[ring]] = value;
    else
        if low_index == 0x0f0a then
            EndOfInterrupt(ring, value);
        else
            _ExtendedSystemRegisters[[SystemRegisterFileIndexOf(address)]] = value;
            if low_index == 0x0f21 then RefreshTimerPending(ring); end;
        end;
    end;
end;

func SwapSystemRegisterAddress(address: SystemRegisterAddress, value: Word) => Word
begin
    // A swap is a read/write transaction.  Preflight both permissions and the
    // access class before reading so a rejected swap cannot trigger read-side
    // effects such as timer-pending refresh on a read-only register.
    if !SystemRegisterSwapPermitted(address) then
        SetFault(Fault_IllegalInstruction, ReadPC());
        return Zeros{PTO_XLEN};
    end;
    let old_value = ReadSystemRegisterAddress(address);
    if _LastFault == Fault_None then WriteSystemRegisterAddress(address, value); end;
    return old_value;
end;

func ExecuteSystemRegisterGet(destination: Reg5Selector,
                              address: SystemRegisterAddress)
begin
    let value = ReadSystemRegisterAddress(address);
    if _LastFault == Fault_None then WriteScalarDestination(destination, value); end;
end;

func ExecuteCompressedSystemRegisterGet(address: SystemRegisterAddress)
begin
    let value = ReadSystemRegisterAddress(address);
    if _LastFault == Fault_None then WriteCompressedTResult(value); end;
end;

func ExecuteSystemRegisterSet(source: Reg5Selector,
                              address: SystemRegisterAddress)
begin
    if !SystemRegisterWritePermitted(address) then
        SetFault(Fault_IllegalInstruction, ReadPC());
        return;
    end;
    let value = ReadScalarRegisterOperand(source);
    WriteSystemRegisterAddress(address, value);
end;

func ExecuteSystemRegisterSwap(destination: Reg5Selector, source: Reg5Selector,
                               address: SystemRegisterAddress)
begin
    if !SystemRegisterSwapPermitted(address) then
        SetFault(Fault_IllegalInstruction, ReadPC());
        return;
    end;
    let value = ReadScalarRegisterOperand(source);
    let old_value = SwapSystemRegisterAddress(address, value);
    if _LastFault == Fault_None then WriteScalarDestination(destination, old_value); end;
end;
```
<!-- GENERATED-ASL-END: unit -->

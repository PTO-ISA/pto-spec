// Test-only physical translation controls for issue 397's bounded A11/A18/A21
// witnesses. This file is appended only by scripts/aslref-atomic-translation.
// It replaces the environment hook and adds its control; all access probes,
// permissions, Atomic TSTORE and storage/event implementations stay production.
var _Issue397TranslationMode : integer {0..3} = 0;

readonly func TranslateDataAddress(address: Word,
                                   size_bytes: integer {1..262144},
                                   write: boolean) => Word
begin
    if _Issue397TranslationMode == 1 then
        // Two distinct virtual coordinates deliberately name one physical
        // U32 range. The translator never changes the access footprint.
        if address == Zeros{PTO_XLEN} + 0x300 ||
           address == Zeros{PTO_XLEN} + 0x304 then
            return Zeros{PTO_XLEN} + 0x500;
        end;
    elsif _Issue397TranslationMode == 2 then
        // One virtual range resolves differently for the read and write half
        // of an atomic preflight, which must reject before effects.
        if address == Zeros{PTO_XLEN} + 0x300 then
            if write then return Zeros{PTO_XLEN} + 0x504;
            else return Zeros{PTO_XLEN} + 0x500; end;
        end;
    elsif _Issue397TranslationMode == 3 then
        // Admission-time map used by the immutable-target witness.
        if address == Zeros{PTO_XLEN} + 0x300 then
            return Zeros{PTO_XLEN} + 0x600;
        end;
    end;
    return address;
end;

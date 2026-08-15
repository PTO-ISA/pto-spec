// PTO-UNIT: {"id":"PTO-TEST-ARCH-TEMPORARY-QUEUE-VALIDITY-001","surface":"arch","classification":["programming-model","execution-context","arch-state-temporary-queue-validity-001"],"depends_on":["PTO-ARCH-PROGRAMMING-MODEL-EXECUTION-CONTEXT"]}
// PTO-TEST: {"id":"PTO-AVS-ARCH-TEMPORARY-QUEUE-VALIDITY-001","source":"asl/arch/programming-model/execution-context.asl","requirements":["PTO-REQ-STATE-001"],"kind":"state-transition","summary":"Temporary queue pushes publish only initialized relative sources and shift readiness with their values","pass_condition":"reset leaves every T/U source unavailable, one push makes only index zero available, and a second push shifts the prior value and readiness to index one","related_sources":["asl/scalar/model/types/operands.asl"]}

func main() => integer
begin
    ResetProfileState();

    for index = 0 to PTO_TEMPORARY_QUEUE_DEPTH - 1 do
        assert !TemporaryQueueSourceAvailable(
            TRUE,
            index as TemporaryQueueIndex);
        assert !TemporaryQueueSourceAvailable(
            FALSE,
            index as TemporaryQueueIndex);
    end;

    PushTemporaryQueue(TRUE, Zeros{PTO_XLEN} + 0x11);
    assert TemporaryQueueSourceAvailable(TRUE, 0);
    assert !TemporaryQueueSourceAvailable(TRUE, 1);
    assert ReadTemporaryQueue(TRUE, 0) == Zeros{PTO_XLEN} + 0x11;

    PushTemporaryQueue(TRUE, Zeros{PTO_XLEN} + 0x22);
    assert TemporaryQueueSourceAvailable(TRUE, 0);
    assert TemporaryQueueSourceAvailable(TRUE, 1);
    assert !TemporaryQueueSourceAvailable(TRUE, 2);
    assert ReadTemporaryQueue(TRUE, 0) == Zeros{PTO_XLEN} + 0x22;
    assert ReadTemporaryQueue(TRUE, 1) == Zeros{PTO_XLEN} + 0x11;

    PushTemporaryQueue(FALSE, Zeros{PTO_XLEN} + 0x33);
    assert TemporaryQueueSourceAvailable(FALSE, 0);
    assert !TemporaryQueueSourceAvailable(FALSE, 1);
    assert ReadTemporaryQueue(FALSE, 0) == Zeros{PTO_XLEN} + 0x33;
    return 0;
end;

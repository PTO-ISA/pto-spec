// PTO-TEST: {"id":"PTO-AVS-ARCH-GQM-STATUS-002","source":"asl/arch/programming-model/general-queue-management.asl","requirements":[],"kind":"state-transition","summary":"GQM push and pop report operation-specific success, retry, and error status","pass_condition":"full and suspended pushes report retry, empty pop reports retry, suspended non-empty pop succeeds, and missing or corrupt queues report error","related_sources":[]}
func main() => integer
begin
    ResetProfileState();
    let address = Zeros{PTO_XLEN} + 0x2000;
    let missing = Zeros{PTO_XLEN} + 0x3000;
    - = InitializeGQMQueue(address, 1);

    let pushed = PushGQMQueueEntry(address, Zeros{PTO_XLEN} + 0x55,
        FALSE, FALSE, FALSE);
    assert pushed[63:62] == '00';
    let full_push = PushGQMQueueEntry(address, Zeros{PTO_XLEN} + 0x66,
        FALSE, TRUE, FALSE);
    assert full_push[63:62] == '01';
    SetGQMQueueSuspended(address, TRUE);

    let suspended_pop = PopGQMQueueEntry(address, TRUE, FALSE);
    assert suspended_pop.result[63:62] == '00';
    assert suspended_pop.data == Zeros{PTO_XLEN} + 0x55;

    let empty_pop = PopGQMQueueEntry(address, TRUE, FALSE);
    assert empty_pop.result[63:62] == '01';
    let suspended_push = PushGQMQueueEntry(address,
        Zeros{PTO_XLEN} + 0x66, FALSE, TRUE, FALSE);
    assert suspended_push[63:62] == '01';

    SetGQMQueueCorrupt(address, TRUE);
    let corrupt_pop = PopGQMQueueEntry(address, TRUE, FALSE);
    assert corrupt_pop.result[63:62] == '10';

    let missing_pop = PopGQMQueueEntry(missing, TRUE, FALSE);
    assert missing_pop.result[63:62] == '10';
    return 0;
end;

#include "interpreter.h"
#include "module.h"
#include "pto_generated_determine_length_cases.h"
#include "pto_generated_runtime_image.h"
#include "runtime_model.h"
#include "value.h"

#include <array>
#include <cassert>
#include <cstdint>
#include <memory>
#include <string>
#include <vector>

namespace {

using pto::model::BindingId;
using pto::model::Function;
using pto::model::Instruction;
using pto::model::MemoryCallbacks;
using pto::model::MemoryWrite;
using pto::model::Module;
using pto::model::OpCode;
using pto::model::RuntimeModel;
using pto::model::StepResult;

constexpr BindingId kCounter = 500;
constexpr BindingId kObserved = 501;

struct MemoryHarness {
    std::array<std::uint8_t, 64> bytes{};
    int reset_count = 0;
    int probe_count = 0;
    int read_count = 0;
    bool fail_reset = false;
    bool fail_probe = false;
    bool fail_read = false;
    bool fail_commit = false;
    std::vector<MemoryWrite> committed_writes;
    RuntimeModel *reentrant_model = nullptr;
    pto_status_t reentrant_status = PTO_STATUS_OK;

    MemoryCallbacks Callbacks() {
        return MemoryCallbacks{
            [this]() {
                if (fail_reset) {
                    return static_cast<pto_status_t>(PTO_STATUS_HOST_RESET_ERROR);
                }
                bytes.fill(0);
                ++reset_count;
                return static_cast<pto_status_t>(PTO_STATUS_OK);
            },
            [this](pto_memory_access_kind_t,
                   std::uint64_t address,
                   std::uint64_t size,
                   bool *permitted) {
                ++probe_count;
                if (fail_probe) {
                    return static_cast<pto_status_t>(PTO_STATUS_HOST_PROBE_ERROR);
                }
                *permitted = address <= bytes.size() &&
                             size <= bytes.size() - address;
                return static_cast<pto_status_t>(PTO_STATUS_OK);
            },
            [this](std::uint64_t address,
                   std::uint8_t *output,
                   std::uint64_t size) {
                ++read_count;
                if (fail_read) {
                    return static_cast<pto_status_t>(PTO_STATUS_HOST_READ_ERROR);
                }
                if (address > bytes.size() || size > bytes.size() - address) {
                    return static_cast<pto_status_t>(PTO_STATUS_HOST_READ_ERROR);
                }
                for (std::uint64_t index = 0; index < size; ++index) {
                    output[index] = bytes[address + index];
                }
                return static_cast<pto_status_t>(PTO_STATUS_OK);
            },
            [this](const std::vector<MemoryWrite> &writes) {
                if (reentrant_model != nullptr) {
                    StepResult nested;
                    reentrant_status = reentrant_model->Step(&nested);
                }
                if (fail_commit) {
                    return static_cast<pto_status_t>(
                        PTO_STATUS_HOST_COMMIT_ERROR);
                }
                committed_writes = writes;
                for (const MemoryWrite &write : writes) {
                    bytes.at(write.address) = write.value;
                }
                return static_cast<pto_status_t>(PTO_STATUS_OK);
            }};
    }
};

std::shared_ptr<const Module> SyntheticModule(pto_step_state_t terminal) {
    OpCode terminal_opcode = OpCode::kReturnExecuted;
    if (terminal == PTO_STEP_TRAP) {
        terminal_opcode = OpCode::kReturnTrap;
    } else if (terminal == PTO_STEP_HOST_REQUEST) {
        terminal_opcode = OpCode::kReturnHostRequest;
    }
    std::vector<Instruction> instructions{
        {OpCode::kIncrementGlobalU64, kCounter, 0, 1, 0},
        {OpCode::kProbeMemory, 0, 1, PTO_MEMORY_ACCESS_WRITE, 5},
        {OpCode::kWriteMemoryImmediate, 0, 0, 0x11, 5},
        {OpCode::kWriteMemoryImmediate, 0, 0, 0x42, 5},
        {OpCode::kReadMemoryToGlobal, kObserved, 0, 0, 5},
        {terminal_opcode, 0, 0, 0, 0}};
    std::string error;
    auto module = Module::Create(
        {Function{pto::model::binding::kStepEntrypoint,
                  std::move(instructions)}},
        pto::model::binding::kStepEntrypoint,
        &error);
    assert(module != nullptr);
    assert(error.empty());
    return module;
}

void TestValues() {
    const auto wide = pto::model::BigInteger::FromUnsignedWords({0, 0, 1});
    const auto sum = wide.Add(pto::model::BigInteger(7));
    assert(sum == pto::model::BigInteger::FromUnsignedWords({7, 0, 1}));
    assert(pto::model::BigInteger(-9).Add(pto::model::BigInteger(4)) ==
           pto::model::BigInteger(-5));
    const auto bits = pto::model::BitVector::FromU64(65, 3);
    assert(bits.width() == 65 && bits.bit(0) && bits.bit(1));
    auto array = std::make_shared<pto::model::PagedLazyArray>(
        [](std::uint64_t) { return pto::model::Value(false); });
    array->Set(130, pto::model::Value(true));
    assert(std::get<bool>(array->Get(130).storage()));
    pto::model::TupleValue tuple;
    tuple.emplace_back(pto::model::EnumValue{9, 2});
    pto::model::Value tuple_value(std::move(tuple));
    assert(std::holds_alternative<std::shared_ptr<pto::model::TupleValue>>(
        tuple_value.storage()));
    pto::model::RecordValue record;
    record.emplace(4, pto::model::Value(bits));
    pto::model::Value record_value(std::move(record));
    assert(std::holds_alternative<std::shared_ptr<pto::model::RecordValue>>(
        record_value.storage()));
}

void TestRuntime() {
    const auto module = SyntheticModule(PTO_STEP_EXECUTED);
    MemoryHarness left_memory;
    MemoryHarness right_memory;
    RuntimeModel left(module, left_memory.Callbacks());
    RuntimeModel right(module, right_memory.Callbacks());
    assert(left.Reset({0x100}) == PTO_STATUS_OK);
    assert(right.Reset({0x200}) == PTO_STATUS_OK);
    assert(left_memory.reset_count == 1 && right_memory.reset_count == 1);

    StepResult result;
    assert(left.Step(&result) == PTO_STATUS_OK);
    assert(result.state == PTO_STEP_EXECUTED);
    assert(left.GlobalU64(kCounter) == 1);
    assert(right.GlobalU64(kCounter) == 0);
    assert(left.GlobalU64(kObserved) == 0x42);
    assert(left_memory.read_count == 0);
    assert(left_memory.probe_count == 1);
    assert(left_memory.bytes[5] == 0x42);
    assert(left_memory.committed_writes.size() == 2);
    assert(left_memory.committed_writes[0].value == 0x11);
    assert(left_memory.committed_writes[1].value == 0x42);

    left_memory.fail_reset = true;
    assert(left.Reset({0x300}) == PTO_STATUS_HOST_RESET_ERROR);
    assert(left.GlobalU64(kCounter) == 1);

    MemoryHarness rollback_memory;
    RuntimeModel rollback(module, rollback_memory.Callbacks());
    assert(rollback.Reset({0}) == PTO_STATUS_OK);
    rollback_memory.fail_commit = true;
    assert(rollback.Step(&result) == PTO_STATUS_HOST_COMMIT_ERROR);
    assert(rollback.GlobalU64(kCounter) == 0);
    assert(rollback_memory.bytes[5] == 0);

    MemoryHarness probe_failure_memory;
    RuntimeModel probe_failure(module, probe_failure_memory.Callbacks());
    assert(probe_failure.Reset({0}) == PTO_STATUS_OK);
    probe_failure_memory.fail_probe = true;
    assert(probe_failure.Step(&result) == PTO_STATUS_HOST_PROBE_ERROR);
    assert(probe_failure.GlobalU64(kCounter) == 0);
    assert(probe_failure_memory.bytes[5] == 0);

    std::string error;
    auto read_failure_module = Module::Create(
        {Function{pto::model::binding::kStepEntrypoint,
                  {{OpCode::kIncrementGlobalU64, kCounter, 0, 1, 0},
                   {OpCode::kReadMemoryToGlobal, kObserved, 0, 0, 9},
                   {OpCode::kReturnExecuted, 0, 0, 0, 0}}}},
        pto::model::binding::kStepEntrypoint,
        &error);
    assert(read_failure_module != nullptr);
    MemoryHarness read_failure_memory;
    RuntimeModel read_failure(
        read_failure_module, read_failure_memory.Callbacks());
    assert(read_failure.Reset({0}) == PTO_STATUS_OK);
    read_failure_memory.fail_read = true;
    assert(read_failure.Step(&result) == PTO_STATUS_HOST_READ_ERROR);
    assert(read_failure.GlobalU64(kCounter) == 0);

    auto evaluator_failure_module = Module::Create(
        {Function{pto::model::binding::kStepEntrypoint,
                  {{OpCode::kIncrementGlobalU64, kCounter, 0, 1, 0},
                   {OpCode::kStoreLocalToGlobal, kObserved, 77, 0, 0},
                   {OpCode::kReturnExecuted, 0, 0, 0, 0}}}},
        pto::model::binding::kStepEntrypoint,
        &error);
    assert(evaluator_failure_module != nullptr);
    MemoryHarness evaluator_failure_memory;
    RuntimeModel evaluator_failure(
        evaluator_failure_module, evaluator_failure_memory.Callbacks());
    assert(evaluator_failure.Reset({0}) == PTO_STATUS_OK);
    assert(evaluator_failure.Step(&result) == PTO_STATUS_MIR_INVALID);
    assert(evaluator_failure.GlobalU64(kCounter) == 0);

    MemoryHarness busy_memory;
    RuntimeModel busy(module, busy_memory.Callbacks());
    assert(busy.Reset({0}) == PTO_STATUS_OK);
    busy_memory.reentrant_model = &busy;
    assert(busy.Step(&result) == PTO_STATUS_OK);
    assert(busy_memory.reentrant_status == PTO_STATUS_BUSY);

    const auto trap_module = SyntheticModule(PTO_STEP_TRAP);
    MemoryHarness trap_memory;
    RuntimeModel trap(trap_module, trap_memory.Callbacks());
    assert(trap.Reset({0}) == PTO_STATUS_OK);
    assert(trap.Step(&result) == PTO_STATUS_OK);
    assert(result.state == PTO_STEP_TRAP);
    assert(trap.GlobalU64(kCounter) == 1);
    assert(trap_memory.bytes[5] == 0x42);
}

void TestInvalidModules() {
    std::string error;
    auto invalid = Module::Create({}, pto::model::binding::kStepEntrypoint,
                                  &error);
    assert(invalid == nullptr && !error.empty());

    error.clear();
    invalid = Module::Create(
        {Function{pto::model::binding::kStepEntrypoint,
                  {{static_cast<OpCode>(0xff), 0, 0, 0, 0}}}},
        pto::model::binding::kStepEntrypoint,
        &error);
    assert(invalid == nullptr && !error.empty());

    MemoryHarness memory;
    auto module = SyntheticModule(PTO_STEP_EXECUTED);
    RuntimeModel dangling(module, memory.Callbacks());
    assert(dangling.Reset({0}) == PTO_STATUS_OK);
    module.reset();
    StepResult result;
    assert(dangling.Step(&result) == PTO_STATUS_MIR_INVALID);
    assert(result.state == PTO_STEP_UNSUPPORTED);
}

void TestGeneratedDetermineLength() {
    MemoryHarness memory;
    const auto module = pto::model::GeneratedDetermineLengthModule();
    RuntimeModel runtime(module, memory.Callbacks());
    assert(runtime.Reset({0}) == PTO_STATUS_OK);
    for (const DetermineLengthCase &test_case : kDetermineLengthCases) {
        std::uint64_t result = 0;
        assert(runtime.InvokeU16(
                   pto::model::GeneratedDetermineLengthBinding(),
                   test_case.first_halfword,
                   &result) == PTO_STATUS_OK);
        assert(result == test_case.length_bits);
    }
    StepResult step_result;
    assert(runtime.Step(&step_result) == PTO_STATUS_MIR_INVALID);
    assert(step_result.state == PTO_STEP_UNSUPPORTED);
    assert(memory.read_count == 0);
    assert(memory.committed_writes.empty());
}

void TestTypedAssert() {
    const auto make_module = [](std::uint64_t right) {
        std::string error;
        auto module = Module::Create(
            {Function{600,
                      {{OpCode::kLoadBitsImmediate, 0, 0, 1, 1},
                       {OpCode::kLoadBitsImmediate, 0, 1, right, 1},
                       {OpCode::kEqual, 0, 2, 0, 1},
                       {OpCode::kAssertTrue, 0, 2, 0, 0},
                       {OpCode::kLoadIntegerImmediate, 0, 3, 7, 0},
                       {OpCode::kReturnValue, 0, 3, 0, 0}}}},
            600,
            &error);
        assert(module != nullptr && error.empty());
        return module;
    };
    MemoryHarness memory;
    auto passing_module = make_module(1);
    RuntimeModel passing(passing_module, memory.Callbacks());
    assert(passing.Reset({0}) == PTO_STATUS_OK);
    std::uint64_t result = 0;
    assert(passing.InvokeU16(600, 0, &result) == PTO_STATUS_OK);
    assert(result == 7);

    auto failing_module = make_module(0);
    RuntimeModel failing(failing_module, memory.Callbacks());
    assert(failing.Reset({0}) == PTO_STATUS_OK);
    assert(failing.InvokeU16(600, 0, &result) == PTO_STATUS_MIR_INVALID);
}

}  // namespace

int main() {
    TestValues();
    TestRuntime();
    TestInvalidModules();
    TestGeneratedDetermineLength();
    TestTypedAssert();
    return 0;
}

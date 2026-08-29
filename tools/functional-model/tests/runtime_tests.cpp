#include "interpreter.h"
#include "module.h"
#include "pto_generated_determine_length_cases.h"
#include "pto_generated_runtime_image.h"
#include "runtime_model.h"
#include "value.h"

#include <array>
#include <cassert>
#include <condition_variable>
#include <cstdint>
#include <cstdio>
#include <memory>
#include <mutex>
#include <string>
#include <thread>
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
    std::array<std::uint8_t, 8192> bytes{};
    int reset_count = 0;
    int probe_count = 0;
    int read_count = 0;
    bool fail_reset = false;
    bool fail_probe = false;
    bool fail_read = false;
    bool fail_commit = false;
    int commit_count = 0;
    std::vector<MemoryWrite> committed_writes;
    RuntimeModel *reentrant_model = nullptr;
    pto_status_t reentrant_status = PTO_STATUS_OK;
    bool block_commit = false;
    bool commit_entered = false;
    bool release_commit = false;
    std::mutex commit_mutex;
    std::condition_variable commit_condition;

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
                if (block_commit) {
                    std::unique_lock<std::mutex> lock(commit_mutex);
                    commit_entered = true;
                    commit_condition.notify_all();
                    commit_condition.wait(lock, [this]() { return release_commit; });
                }
                if (reentrant_model != nullptr) {
                    StepResult nested;
                    reentrant_status = reentrant_model->StepPrimaryForTesting(&nested);
                }
                if (fail_commit) {
                    return static_cast<pto_status_t>(
                        PTO_STATUS_HOST_COMMIT_ERROR);
                }
                ++commit_count;
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

void TestConcurrentAndLongIsolation() {
    constexpr std::uint64_t kStepCount = 1000;
    const auto module = SyntheticModule(PTO_STEP_EXECUTED);

    MemoryHarness interleaved_left_memory;
    MemoryHarness interleaved_right_memory;
    RuntimeModel interleaved_left(module, interleaved_left_memory.Callbacks());
    RuntimeModel interleaved_right(module, interleaved_right_memory.Callbacks());
    assert(interleaved_left.InitializeForTesting({0x100}) == PTO_STATUS_OK);
    assert(interleaved_right.InitializeForTesting({0x200}) == PTO_STATUS_OK);
    StepResult left_result;
    StepResult right_result;
    for (std::uint64_t index = 0; index < kStepCount; ++index) {
        assert(interleaved_left.StepPrimaryForTesting(&left_result) == PTO_STATUS_OK);
        assert(interleaved_right.StepPrimaryForTesting(&right_result) == PTO_STATUS_OK);
    }
    assert(interleaved_left.GlobalU64(kCounter) == kStepCount);
    assert(interleaved_right.GlobalU64(kCounter) == kStepCount);
    assert(interleaved_left_memory.commit_count == kStepCount);
    assert(interleaved_right_memory.commit_count == kStepCount);

    MemoryHarness serial_left_memory;
    MemoryHarness serial_right_memory;
    RuntimeModel serial_left(module, serial_left_memory.Callbacks());
    RuntimeModel serial_right(module, serial_right_memory.Callbacks());
    assert(serial_left.InitializeForTesting({0x100}) == PTO_STATUS_OK);
    assert(serial_right.InitializeForTesting({0x200}) == PTO_STATUS_OK);
    for (std::uint64_t index = 0; index < kStepCount; ++index) {
        assert(serial_left.StepPrimaryForTesting(&left_result) == PTO_STATUS_OK);
    }
    for (std::uint64_t index = 0; index < kStepCount; ++index) {
        assert(serial_right.StepPrimaryForTesting(&right_result) == PTO_STATUS_OK);
    }
    assert(serial_left.GlobalU64(kCounter) == interleaved_left.GlobalU64(kCounter));
    assert(serial_right.GlobalU64(kCounter) == interleaved_right.GlobalU64(kCounter));
    assert(serial_left_memory.bytes == interleaved_left_memory.bytes);
    assert(serial_right_memory.bytes == interleaved_right_memory.bytes);

    MemoryHarness parallel_left_memory;
    MemoryHarness parallel_right_memory;
    RuntimeModel parallel_left(module, parallel_left_memory.Callbacks());
    RuntimeModel parallel_right(module, parallel_right_memory.Callbacks());
    assert(parallel_left.InitializeForTesting({0x100}) == PTO_STATUS_OK);
    assert(parallel_right.InitializeForTesting({0x200}) == PTO_STATUS_OK);
    pto_status_t parallel_left_status = PTO_STATUS_INTERNAL_ERROR;
    pto_status_t parallel_right_status = PTO_STATUS_INTERNAL_ERROR;
    std::thread left_thread([&]() {
        StepResult result;
        for (std::uint64_t index = 0; index < kStepCount; ++index) {
            parallel_left_status = parallel_left.StepPrimaryForTesting(&result);
            if (parallel_left_status != PTO_STATUS_OK) return;
        }
    });
    std::thread right_thread([&]() {
        StepResult result;
        for (std::uint64_t index = 0; index < kStepCount; ++index) {
            parallel_right_status = parallel_right.StepPrimaryForTesting(&result);
            if (parallel_right_status != PTO_STATUS_OK) return;
        }
    });
    left_thread.join();
    right_thread.join();
    assert(parallel_left_status == PTO_STATUS_OK);
    assert(parallel_right_status == PTO_STATUS_OK);
    assert(parallel_left.GlobalU64(kCounter) == kStepCount);
    assert(parallel_right.GlobalU64(kCounter) == kStepCount);

    MemoryHarness busy_memory;
    busy_memory.block_commit = true;
    RuntimeModel busy(module, busy_memory.Callbacks());
    assert(busy.InitializeForTesting({0}) == PTO_STATUS_OK);
    pto_status_t first_status = PTO_STATUS_INTERNAL_ERROR;
    std::thread first([&]() {
        StepResult result;
        first_status = busy.StepPrimaryForTesting(&result);
    });
    {
        std::unique_lock<std::mutex> lock(busy_memory.commit_mutex);
        busy_memory.commit_condition.wait(
            lock, [&]() { return busy_memory.commit_entered; });
    }
    StepResult competing_result;
    assert(busy.StepPrimaryForTesting(&competing_result) == PTO_STATUS_BUSY);
    {
        std::lock_guard<std::mutex> lock(busy_memory.commit_mutex);
        busy_memory.release_commit = true;
    }
    busy_memory.commit_condition.notify_all();
    first.join();
    assert(first_status == PTO_STATUS_OK);
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
    assert(left.InitializeForTesting({0x100}) == PTO_STATUS_OK);
    assert(right.InitializeForTesting({0x200}) == PTO_STATUS_OK);
    assert(left_memory.reset_count == 1 && right_memory.reset_count == 1);

    StepResult result;
    assert(left.StepPrimaryForTesting(&result) == PTO_STATUS_OK);
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
    assert(left.InitializeForTesting({0x300}) == PTO_STATUS_HOST_RESET_ERROR);
    assert(left.GlobalU64(kCounter) == 1);

    MemoryHarness rollback_memory;
    RuntimeModel rollback(module, rollback_memory.Callbacks());
    assert(rollback.InitializeForTesting({0}) == PTO_STATUS_OK);
    rollback_memory.fail_commit = true;
    assert(rollback.StepPrimaryForTesting(&result) == PTO_STATUS_HOST_COMMIT_ERROR);
    assert(rollback.GlobalU64(kCounter) == 0);
    assert(rollback_memory.bytes[5] == 0);

    MemoryHarness probe_failure_memory;
    RuntimeModel probe_failure(module, probe_failure_memory.Callbacks());
    assert(probe_failure.InitializeForTesting({0}) == PTO_STATUS_OK);
    probe_failure_memory.fail_probe = true;
    assert(probe_failure.StepPrimaryForTesting(&result) == PTO_STATUS_HOST_PROBE_ERROR);
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
    assert(read_failure.InitializeForTesting({0}) == PTO_STATUS_OK);
    read_failure_memory.fail_read = true;
    assert(read_failure.StepPrimaryForTesting(&result) == PTO_STATUS_HOST_READ_ERROR);
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
    assert(evaluator_failure.InitializeForTesting({0}) == PTO_STATUS_OK);
    assert(evaluator_failure.StepPrimaryForTesting(&result) == PTO_STATUS_MIR_INVALID);
    assert(evaluator_failure.GlobalU64(kCounter) == 0);

    MemoryHarness busy_memory;
    RuntimeModel busy(module, busy_memory.Callbacks());
    assert(busy.InitializeForTesting({0}) == PTO_STATUS_OK);
    busy_memory.reentrant_model = &busy;
    assert(busy.StepPrimaryForTesting(&result) == PTO_STATUS_OK);
    assert(busy_memory.reentrant_status == PTO_STATUS_BUSY);

    const auto trap_module = SyntheticModule(PTO_STEP_TRAP);
    MemoryHarness trap_memory;
    RuntimeModel trap(trap_module, trap_memory.Callbacks());
    assert(trap.InitializeForTesting({0}) == PTO_STATUS_OK);
    assert(trap.StepPrimaryForTesting(&result) == PTO_STATUS_OK);
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
    std::vector<Function> arity_functions;
    arity_functions.push_back(Function{
        800,
        {{OpCode::kCallProcedure, 801, 0, 1, 0},
         {OpCode::kReturnProcedure, 0, 0, 0, 0}},
        0});
    arity_functions.push_back(Function{
        801,
        {{OpCode::kReturnProcedure, 0, 0, 0, 0}},
        0});
    invalid = Module::Create(std::move(arity_functions), 800, &error);
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
    assert(dangling.InitializeForTesting({0}) == PTO_STATUS_OK);
    module.reset();
    StepResult result;
    assert(dangling.StepPrimaryForTesting(&result) == PTO_STATUS_MIR_INVALID);
    assert(result.state == PTO_STEP_UNSUPPORTED);
}

void TestGeneratedDetermineLength() {
    MemoryHarness memory;
    const auto module = pto::model::GeneratedDetermineLengthModule();
    RuntimeModel runtime(module, memory.Callbacks());
    assert(runtime.InitializeForTesting({0}) == PTO_STATUS_OK);
    for (const DetermineLengthCase &test_case : kDetermineLengthCases) {
        std::uint64_t result = 0;
        assert(runtime.InvokeU16(
                   pto::model::GeneratedDetermineLengthBinding(),
                   test_case.first_halfword,
                   &result) == PTO_STATUS_OK);
        assert(result == test_case.length_bits);
    }
    StepResult step_result;
    assert(runtime.StepPrimaryForTesting(&step_result) == PTO_STATUS_MIR_INVALID);
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
    assert(passing.InitializeForTesting({0}) == PTO_STATUS_OK);
    std::uint64_t result = 0;
    assert(passing.InvokeU16(600, 0, &result) == PTO_STATUS_OK);
    assert(result == 7);

    auto failing_module = make_module(0);
    RuntimeModel failing(failing_module, memory.Callbacks());
    assert(failing.InitializeForTesting({0}) == PTO_STATUS_OK);
    assert(failing.InvokeU16(600, 0, &result) == PTO_STATUS_MIR_INVALID);
}

void TestNumericCallFrames() {
    std::string error;
    auto module = Module::Create(
        {Function{700,
                  {{OpCode::kLoadBitsImmediate, 0, 0, 5, 16},
                   {OpCode::kPushArgument, 0, 0, 0, 0},
                   {OpCode::kCallValue, 701, 1, 1, 0},
                   {OpCode::kCallProcedure, 702, 0, 0, 0},
                   {OpCode::kReturnValue, 0, 1, 0, 0}}},
         Function{701,
                  {{OpCode::kLoadArgumentBits, 0, 0, 16, 0},
                   {OpCode::kLoadBitsImmediate, 0, 1, 5, 16},
                   {OpCode::kEqual, 0, 2, 0, 1},
                   {OpCode::kAssertTrue, 0, 2, 0, 0},
                   {OpCode::kLoadIntegerImmediate, 0, 3, 5, 0},
                   {OpCode::kReturnValue, 0, 3, 0, 0}}, 1},
         Function{702, {{OpCode::kReturnProcedure, 0, 0, 0, 0}}}},
        700,
        &error);
    assert(module != nullptr && error.empty());
    MemoryHarness memory;
    RuntimeModel runtime(module, memory.Callbacks());
    assert(runtime.InitializeForTesting({0}) == PTO_STATUS_OK);
    std::uint64_t result = 0;
    assert(runtime.InvokeU16(700, 0, &result) == PTO_STATUS_OK);
    assert(result == 5);
}

void TestNumericIntegerExterns() {
    const pto::model::BitVector all_ones =
        pto::model::BitVector::FromU64(64, UINT64_MAX);
    std::uint64_t unsigned_value = 0;
    assert(all_ones.ToUnsignedInteger().TryToU64(&unsigned_value));
    assert(unsigned_value == UINT64_MAX);
    assert(all_ones.ToSignedInteger() == pto::model::BigInteger(-1));
    const pto::model::BitVector wide =
        pto::model::BitVector::FromU64(65, UINT64_MAX);
    assert(wide.ToUnsignedInteger() ==
           pto::model::BigInteger::FromUnsignedWords(
               {UINT32_MAX, UINT32_MAX}));
}

std::uint64_t ValueU64(const pto::model::Value &value) {
    std::uint64_t result = 0;
    if (const auto *bits = std::get_if<pto::model::BitVector>(&value.storage()))
        assert(bits->TryToU64(&result));
    else
        assert(std::get<pto::model::BigInteger>(value.storage()).TryToU64(&result));
    return result;
}

void TestGeneratedResetState() {
    auto module = pto::model::GeneratedResetModule();
    MemoryHarness left_memory;
    MemoryHarness right_memory;
    RuntimeModel left(module, left_memory.Callbacks());
    RuntimeModel right(module, right_memory.Callbacks());
    pto::model::InitialState initial;
    initial.entry_tpc = 0x100;
    initial.pe0_gpr_valid_mask = (UINT32_C(1) << 0) | (UINT32_C(1) << 2);
    initial.pe0_gpr[0] = 0xff;
    initial.pe0_gpr[2] = 0x55;
    assert(left.Reset(initial) == PTO_STATUS_OK);
    assert(right.Reset({0x200}) == PTO_STATUS_OK);
    assert(left_memory.reset_count == 1 && right_memory.reset_count == 1);
    assert(ValueU64(*left.GlobalValueForTesting(
               pto::model::GeneratedPCGlobalBinding())) == 0x100);
    assert(ValueU64(*right.GlobalValueForTesting(
               pto::model::GeneratedPCGlobalBinding())) == 0x200);
    const auto &pe_files = *std::get<std::shared_ptr<pto::model::PagedLazyArray>>(
        left.GlobalValueForTesting(
            pto::model::GeneratedPEGPRsGlobalBinding())->storage());
    const auto pe0 = pe_files.Get(0);
    const auto pe1 = pe_files.Get(1);
    const auto &pe0_gprs = *std::get<std::shared_ptr<pto::model::PagedLazyArray>>(
        pe0.storage());
    const auto &pe1_gprs = *std::get<std::shared_ptr<pto::model::PagedLazyArray>>(
        pe1.storage());
    assert(ValueU64(pe0_gprs.Get(0)) == 0);
    assert(ValueU64(pe0_gprs.Get(2)) == 0x55);
    assert(ValueU64(pe1_gprs.Get(2)) == 0);
}

void TestGeneratedPredecodeSteps() {
    auto module = pto::model::GeneratedResetModule();
    MemoryHarness memory;
    RuntimeModel runtime(module, memory.Callbacks());
    StepResult result;
    pto_status_t uninitialized_status = runtime.Step(&result);
    if (uninitialized_status != PTO_STATUS_OK)
        std::fprintf(stderr, "uninitialized step status=%u: %s\n", uninitialized_status,
                     runtime.last_error().c_str());
    assert(uninitialized_status == PTO_STATUS_OK);
    assert(result.state == PTO_STEP_UNSUPPORTED);
    assert(result.instruction_status == PTO_INSTRUCTION_NOT_ATTEMPTED);
    assert(memory.reset_count == 0 && memory.read_count == 0);

    assert(runtime.Reset({0x100}) == PTO_STATUS_OK);
    memory.read_count = 0;
    assert(runtime.SetGlobalForTesting(
        pto::model::GeneratedPCGlobalBinding(),
        pto::model::Value(pto::model::BitVector::FromU64(64, 0x101))));
    pto_status_t odd_status = runtime.Step(&result);
    if (odd_status != PTO_STATUS_OK)
        std::fprintf(stderr, "odd step status=%u: %s\n", odd_status,
                     runtime.last_error().c_str());
    assert(odd_status == PTO_STATUS_OK);
    assert(result.state == PTO_STEP_TRAP);
    assert(result.instruction_status == PTO_INSTRUCTION_NOT_ATTEMPTED);
    assert(result.fault_code == 3 && result.fault_cause == 0);
    assert(memory.read_count == 0);

    assert(runtime.Reset({4096}) == PTO_STATUS_OK);
    memory.read_count = 0;
    assert(runtime.Step(&result) == PTO_STATUS_OK);
    assert(result.state == PTO_STEP_TRAP);
    assert(result.instruction_status == PTO_INSTRUCTION_NOT_ATTEMPTED);
    assert(result.fault_code == 4 && result.fault_cause == 0);
    assert(memory.read_count == 0);
}

void TestGeneratedScalarSteps() {
    auto module = pto::model::GeneratedResetModule();
    MemoryHarness memory;
    RuntimeModel runtime(module, memory.Callbacks());
    assert(runtime.Reset({0x100}) == PTO_STATUS_OK);
    memory.bytes[0x100] = 0x16;
    memory.bytes[0x101] = 0x14;
    memory.read_count = 0;
    StepResult result;
    pto_status_t status = runtime.Step(&result);
    if (status != PTO_STATUS_OK)
        std::fprintf(stderr, "C.MOVI status=%u: %s\n", status,
                     runtime.last_error().c_str());
    assert(status == PTO_STATUS_OK);
    if (result.state != PTO_STEP_EXECUTED)
        std::fprintf(stderr,
                     "C.MOVI result state=%u instruction=%u fault=%u length=%u raw=%llx\n",
                     result.state, result.instruction_status, result.fault_code,
                     result.length_bits,
                     static_cast<unsigned long long>(result.raw_instruction));
    assert(result.state == PTO_STEP_EXECUTED);
    assert(result.instruction_status == PTO_INSTRUCTION_EXECUTED);
    assert(result.length_bits == 16 && result.raw_instruction == 0x1416);
    assert(result.pre_tpc == 0x100 && result.post_tpc == 0x102);
    assert(result.fault_code == 0);
    assert(memory.read_count == 4);
    const auto &pe_files = *std::get<std::shared_ptr<pto::model::PagedLazyArray>>(
        runtime.GlobalValueForTesting(
            pto::model::GeneratedPEGPRsGlobalBinding())->storage());
    const auto pe0 = pe_files.Get(0);
    const auto &gprs = *std::get<std::shared_ptr<pto::model::PagedLazyArray>>(
        pe0.storage());
    assert(ValueU64(gprs.Get(2)) == UINT64_C(0xfffffffffffffff0));
    const auto &system = *std::get<std::shared_ptr<pto::model::RecordValue>>(
        runtime.GlobalValueForTesting(
            pto::model::GeneratedSystemRegistersGlobalBinding())->storage());
    assert(ValueU64(system.at(
               pto::model::GeneratedCycleFieldBinding())) == 1);

    pto::model::InitialState add_initial;
    add_initial.entry_tpc = 0x100;
    add_initial.pe0_gpr_valid_mask = (UINT32_C(1) << 1) | (UINT32_C(1) << 2);
    add_initial.pe0_gpr[1] = 10;
    add_initial.pe0_gpr[2] = 20;
    assert(runtime.Reset(add_initial) == PTO_STATUS_OK);
    memory.bytes[0x100] = 0x85;
    memory.bytes[0x101] = 0x81;
    memory.bytes[0x102] = 0x20;
    memory.bytes[0x103] = 0x00;
    memory.read_count = 0;
    status = runtime.Step(&result);
    if (status != PTO_STATUS_OK)
        std::fprintf(stderr, "ADD status=%u: %s\n", status,
                     runtime.last_error().c_str());
    assert(status == PTO_STATUS_OK);
    assert(result.state == PTO_STEP_EXECUTED);
    assert(result.instruction_status == PTO_INSTRUCTION_EXECUTED);
    assert(result.length_bits == 32 && result.raw_instruction == 0x00208185);
    assert(result.pre_tpc == 0x100 && result.post_tpc == 0x104);
    assert(memory.read_count == 6);
    const auto &add_pe_files = *std::get<std::shared_ptr<pto::model::PagedLazyArray>>(
        runtime.GlobalValueForTesting(
            pto::model::GeneratedPEGPRsGlobalBinding())->storage());
    const auto add_pe0 = add_pe_files.Get(0);
    const auto &add_gprs = *std::get<std::shared_ptr<pto::model::PagedLazyArray>>(
        add_pe0.storage());
    assert(ValueU64(add_gprs.Get(1)) == 10);
    assert(ValueU64(add_gprs.Get(2)) == 20);
    assert(ValueU64(add_gprs.Get(3)) == 30);
    const auto &add_system = *std::get<std::shared_ptr<pto::model::RecordValue>>(
        runtime.GlobalValueForTesting(
            pto::model::GeneratedSystemRegistersGlobalBinding())->storage());
    assert(ValueU64(add_system.at(
               pto::model::GeneratedCycleFieldBinding())) == 1);

    pto::model::InitialState xori_initial;
    xori_initial.entry_tpc = 0x100;
    xori_initial.pe0_gpr_valid_mask = UINT32_C(1) << 1;
    assert(runtime.Reset(xori_initial) == PTO_STATUS_OK);
    const std::uint8_t xori_bytes[] = {0x0e, 0x80, 0x95, 0xc0, 0x00, 0x00};
    std::copy(std::begin(xori_bytes), std::end(xori_bytes),
              memory.bytes.begin() + 0x100);
    memory.read_count = 0;
    status = runtime.Step(&result);
    if (status != PTO_STATUS_OK)
        std::fprintf(stderr, "HL.XORI status=%u: %s\n", status,
                     runtime.last_error().c_str());
    assert(status == PTO_STATUS_OK);
    assert(result.state == PTO_STEP_EXECUTED);
    assert(result.instruction_status == PTO_INSTRUCTION_EXECUTED);
    assert(result.length_bits == 48 && result.raw_instruction == 0xc095800e);
    assert(result.pre_tpc == 0x100 && result.post_tpc == 0x106);
    assert(memory.read_count == 8);
    const auto &xori_files = *std::get<std::shared_ptr<pto::model::PagedLazyArray>>(
        runtime.GlobalValueForTesting(
            pto::model::GeneratedPEGPRsGlobalBinding())->storage());
    const auto xori_pe0 = xori_files.Get(0);
    const auto &xori_gprs = *std::get<std::shared_ptr<pto::model::PagedLazyArray>>(
        xori_pe0.storage());
    assert(ValueU64(xori_gprs.Get(1)) == UINT64_C(0xffffffffff800000));

    assert(runtime.Reset({0x280}) == PTO_STATUS_OK);
    const auto *prestart_bundle = runtime.GlobalValueForTesting(
        pto::model::GeneratedBundleActiveGlobalBinding());
    assert(prestart_bundle != nullptr);
    assert(!std::get<bool>(prestart_bundle->storage()));
    memory.bytes[0x280] = 0x11;
    memory.bytes[0x281] = 0x00;
    memory.bytes[0x282] = 0x00;
    memory.bytes[0x283] = 0x00;
    status = runtime.Step(&result);
    if (status != PTO_STATUS_OK)
        std::fprintf(stderr, "BSTART status=%u: %s\n", status,
                     runtime.last_error().c_str());
    if (status == PTO_STATUS_OK && result.state != PTO_STEP_EXECUTED)
        std::fprintf(stderr, "BSTART result state=%u instruction=%u fault=%u\n",
                     result.state, result.instruction_status, result.fault_code);
    assert(status == PTO_STATUS_OK && result.state == PTO_STEP_EXECUTED);
    assert(result.length_bits == 32 && result.post_tpc == 0x284);
    const std::uint8_t stop_bytes[] =
        {0x0f, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00};
    std::copy(std::begin(stop_bytes), std::end(stop_bytes),
              memory.bytes.begin() + 0x284);
    memory.read_count = 0;
    status = runtime.Step(&result);
    if (status != PTO_STATUS_OK)
        std::fprintf(stderr, "L.BSTOP status=%u: %s\n", status,
                     runtime.last_error().c_str());
    assert(status == PTO_STATUS_OK);
    assert(result.state == PTO_STEP_EXECUTED);
    assert(result.instruction_status == PTO_INSTRUCTION_EXECUTED);
    assert(result.length_bits == 64);
    assert(result.raw_instruction == UINT64_C(0x000000010000000f));
    assert(result.pre_tpc == 0x284 && result.post_tpc == 0x280);
    assert(result.fault_code == 0 && memory.read_count == 10);
    const auto *bundle_active = runtime.GlobalValueForTesting(
        pto::model::GeneratedBundleActiveGlobalBinding());
    assert(bundle_active != nullptr);
    assert(!std::get<bool>(bundle_active->storage()));
    const auto &block_system = *std::get<std::shared_ptr<pto::model::RecordValue>>(
        runtime.GlobalValueForTesting(
            pto::model::GeneratedSystemRegistersGlobalBinding())->storage());
    assert(ValueU64(block_system.at(
               pto::model::GeneratedCycleFieldBinding())) == 2);
}

void TestGeneratedFaultSteps() {
    auto module = pto::model::GeneratedResetModule();
    MemoryHarness memory;
    RuntimeModel runtime(module, memory.Callbacks());
    assert(runtime.Reset({0x100}) == PTO_STATUS_OK);
    memory.bytes[0x100] = 0x0f;
    memory.bytes[0x101] = 0x00;
    for (std::size_t index = 2; index < 8; ++index)
        memory.bytes[0x100 + index] = 0;
    memory.read_count = 0;
    StepResult result;
    assert(runtime.Step(&result) == PTO_STATUS_OK);
    assert(result.state == PTO_STEP_TRAP);
    assert(result.instruction_status == PTO_INSTRUCTION_REJECTED);
    assert(result.fault_code == 2 && result.length_bits == 64);
    assert(result.raw_instruction == 0x0f && memory.read_count == 10);

    assert(runtime.Reset({4092}) == PTO_STATUS_OK);
    memory.bytes[4092] = 0x0f;
    memory.bytes[4093] = 0x00;
    memory.read_count = 0;
    assert(runtime.Step(&result) == PTO_STATUS_OK);
    assert(result.state == PTO_STEP_TRAP);
    assert(result.instruction_status == PTO_INSTRUCTION_NOT_ATTEMPTED);
    assert(result.fault_code == 4 && result.length_bits == 64);
    assert(memory.read_count == 2);
    const auto &system = *std::get<std::shared_ptr<pto::model::RecordValue>>(
        runtime.GlobalValueForTesting(
            pto::model::GeneratedSystemRegistersGlobalBinding())->storage());
    assert(ValueU64(system.at(
               pto::model::GeneratedCycleFieldBinding())) == 0);
}

void TestGeneratedHostRequests() {
    auto module = pto::model::GeneratedResetModule();
    MemoryHarness memory;
    RuntimeModel runtime(module, memory.Callbacks());
    pto::model::InitialState initial;
    initial.entry_tpc = 0x200;
    initial.pe0_gpr_valid_mask = UINT32_C(1) << 4;
    initial.pe0_gpr[4] = 0x44;
    assert(runtime.Reset(initial) == PTO_STATUS_OK);
    assert(runtime.BeginHostRequestForTesting(94, 8, 4, 0x204) == PTO_STATUS_OK);
    memory.read_count = 0;
    StepResult first, second;
    assert(runtime.Step(&first) == PTO_STATUS_OK);
    assert(runtime.Step(&second) == PTO_STATUS_OK);
    assert(first.state == PTO_STEP_HOST_REQUEST &&
           second.state == PTO_STEP_HOST_REQUEST);
    assert(first.request_token == second.request_token);
    assert(first.origin_pe == 0 && first.request_type == 94);
    assert(first.request_argument0 == 8 && memory.read_count == 0);
    const std::uint64_t token = first.request_token;
    MemoryHarness other_memory;
    RuntimeModel other(module, other_memory.Callbacks());
    assert(other.Reset(initial) == PTO_STATUS_OK);
    assert(other.BeginHostRequestForTesting(94, 8, 4, 0x204) == PTO_STATUS_OK);
    StepResult other_step;
    assert(other.Step(&other_step) == PTO_STATUS_OK);
    assert(other_step.request_token == token);
    assert(other.CompleteHostRequest(other_step.request_token, 0x55) ==
           PTO_STATUS_OK);
    assert(runtime.Step(&second) == PTO_STATUS_OK);
    assert(second.request_token == token);
    assert(runtime.CompleteHostRequest(token + 1, 0x99) ==
           PTO_STATUS_INVALID_STATE);
    assert(runtime.CompleteHostRequest(token, 0xaa) == PTO_STATUS_OK);
    assert(runtime.CompleteHostRequest(token, 0xbb) == PTO_STATUS_INVALID_STATE);
    assert(ValueU64(*runtime.GlobalValueForTesting(
               pto::model::GeneratedPCGlobalBinding())) == 0x204);
    const auto &files = *std::get<std::shared_ptr<pto::model::PagedLazyArray>>(
        runtime.GlobalValueForTesting(
            pto::model::GeneratedPEGPRsGlobalBinding())->storage());
    const auto pe0 = files.Get(0);
    const auto &gprs = *std::get<std::shared_ptr<pto::model::PagedLazyArray>>(
        pe0.storage());
    assert(ValueU64(gprs.Get(4)) == 0xaa);

    assert(runtime.Reset(initial) == PTO_STATUS_OK);
    assert(runtime.BeginHostRequestForTesting(94, 9, 4, 0x204) == PTO_STATUS_OK);
    assert(runtime.Step(&first) == PTO_STATUS_OK);
    const std::uint64_t old_token = first.request_token;
    assert(runtime.Reset(initial) == PTO_STATUS_OK);
    assert(runtime.BeginHostRequestForTesting(94, 10, 4, 0x204) == PTO_STATUS_OK);
    assert(runtime.Step(&second) == PTO_STATUS_OK);
    assert(second.request_token > old_token);
    assert(runtime.CompleteHostRequest(old_token, 1) == PTO_STATUS_INVALID_STATE);
    assert(runtime.SetGlobalForTesting(
        pto::model::GeneratedNextTokenGlobalBinding(),
        pto::model::Value(pto::model::BitVector::FromU64(64, UINT64_MAX))));
    assert(runtime.Reset(initial) == PTO_STATUS_OK);
    assert(runtime.BeginHostRequestForTesting(94, 0, 4, 0x204) ==
           PTO_STATUS_INVALID_STATE);
}

void TestGeneratedStoreTransactions() {
    auto module = pto::model::GeneratedResetModule();
    MemoryHarness memory;
    RuntimeModel runtime(module, memory.Callbacks());
    const auto prepare = [&](std::uint64_t base) {
        pto::model::InitialState initial;
        initial.entry_tpc = 0x100;
        initial.pe0_gpr_valid_mask =
            (UINT32_C(1) << 1) | (UINT32_C(1) << 2) | (UINT32_C(1) << 3);
        initial.pe0_gpr[1] = base;
        initial.pe0_gpr[2] = 0;
        initial.pe0_gpr[3] = 0x11223344;
        assert(runtime.Reset(initial) == PTO_STATUS_OK);
        memory.bytes[0x100] = 0x49;
        memory.bytes[0x101] = 0xa0;
        memory.bytes[0x102] = 0x20;
        memory.bytes[0x103] = 0x18;
        memory.commit_count = 0;
        memory.committed_writes.clear();
    };
    StepResult result;
    prepare(0x200);
    pto_status_t store_status = runtime.Step(&result);
    if (store_status != PTO_STATUS_OK)
        std::fprintf(stderr, "SW status=%u: %s\n", store_status,
                     runtime.last_error().c_str());
    assert(store_status == PTO_STATUS_OK);
    assert(result.state == PTO_STEP_EXECUTED && result.fault_code == 0);
    assert(result.post_tpc == 0x104 && memory.commit_count == 1);
    assert(memory.committed_writes.size() == 4);
    const std::uint8_t expected[] = {0x44, 0x33, 0x22, 0x11};
    for (std::size_t index = 0; index < 4; ++index) {
        assert(memory.committed_writes[index].address == 0x200 + index);
        assert(memory.committed_writes[index].value == expected[index]);
        assert(memory.bytes[0x200 + index] == expected[index]);
    }

    prepare(0x200);
    memory.fail_commit = true;
    assert(runtime.Step(&result) == PTO_STATUS_HOST_COMMIT_ERROR);
    assert(memory.commit_count == 0);
    for (std::size_t index = 0; index < 4; ++index)
        assert(memory.bytes[0x200 + index] == 0);
    assert(ValueU64(*runtime.GlobalValueForTesting(
               pto::model::GeneratedPCGlobalBinding())) == 0x100);
    const auto &failed_system = *std::get<std::shared_ptr<pto::model::RecordValue>>(
        runtime.GlobalValueForTesting(
            pto::model::GeneratedSystemRegistersGlobalBinding())->storage());
    assert(ValueU64(failed_system.at(
               pto::model::GeneratedCycleFieldBinding())) == 0);
    const auto &failed_files = *std::get<std::shared_ptr<pto::model::PagedLazyArray>>(
        runtime.GlobalValueForTesting(
            pto::model::GeneratedPEGPRsGlobalBinding())->storage());
    const auto failed_pe0 = failed_files.Get(0);
    const auto &failed_gprs = *std::get<std::shared_ptr<pto::model::PagedLazyArray>>(
        failed_pe0.storage());
    assert(ValueU64(failed_gprs.Get(3)) == UINT64_C(0x11223344));
    memory.fail_commit = false;
    assert(runtime.Step(&result) == PTO_STATUS_OK);
    assert(memory.commit_count == 1 && result.post_tpc == 0x104);

    prepare(0x201);
    assert(runtime.Step(&result) == PTO_STATUS_OK);
    assert(result.state == PTO_STEP_TRAP && result.fault_code == 5);
    assert(memory.commit_count == 0 && memory.committed_writes.empty());

    prepare(4096);
    assert(runtime.Step(&result) == PTO_STATUS_OK);
    assert(result.state == PTO_STEP_TRAP && result.fault_code == 6);
    assert(memory.commit_count == 0 && memory.committed_writes.empty());
}

}  // namespace

int main() {
    TestValues();
    TestRuntime();
    TestConcurrentAndLongIsolation();
    TestInvalidModules();
    TestGeneratedDetermineLength();
    TestTypedAssert();
    TestNumericCallFrames();
    TestNumericIntegerExterns();
    TestGeneratedResetState();
    TestGeneratedPredecodeSteps();
    TestGeneratedScalarSteps();
    TestGeneratedFaultSteps();
    TestGeneratedHostRequests();
    TestGeneratedStoreTransactions();
    return 0;
}

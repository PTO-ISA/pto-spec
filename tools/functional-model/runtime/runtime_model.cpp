#include "runtime_model.h"

#include "pto_generated_runtime_image.h"

#include <utility>

namespace pto::model {

RuntimeModel::BusyGuard::BusyGuard(std::atomic_flag *busy)
    : busy_(busy), acquired_(!busy_->test_and_set()) {}

RuntimeModel::BusyGuard::~BusyGuard() {
    if (acquired_) {
        busy_->clear();
    }
}

bool RuntimeModel::BusyGuard::acquired() const { return acquired_; }

RuntimeModel::RuntimeModel(std::weak_ptr<const Module> module,
                           MemoryCallbacks callbacks)
    : module_(std::move(module)), callbacks_(std::move(callbacks)) {
    if (const auto resolved = module_.lock()) {
        for (const GlobalDefinition &global : resolved->globals()) {
            state_.typed_globals.emplace(global.id, global.value.Clone());
        }
    }
}

pto_status_t RuntimeModel::Reset(const InitialState &initial) {
    BusyGuard guard(&busy_);
    if (!guard.acquired()) {
        return PTO_STATUS_BUSY;
    }
    if ((initial.entry_tpc & 1U) != 0 ||
        (initial.pe0_gpr_valid_mask & UINT32_C(0xff000000)) != 0)
        return PTO_STATUS_INVALID_ARGUMENT;
    const auto module = module_.lock();
    if (!module) {
        SetError("generated reset module is unavailable");
        return PTO_STATUS_MIR_INVALID;
    }
    RuntimeState candidate = state_;
    MemoryTransaction memory(callbacks_);
    const Function *reset = module->FindFunction(GeneratedResetBinding());
    if (reset == nullptr) {
        SetError("generated reset entrypoint is unavailable");
        return PTO_STATUS_MIR_INVALID;
    }
    EvaluationResult evaluation = interpreter_.Evaluate(
        *module, *reset, &candidate, &memory,
        {Value(BitVector::FromU64(64, initial.entry_tpc))});
    if (evaluation.status != PTO_STATUS_OK || evaluation.return_value) {
        SetError("generated InitializeFunctionalModel evaluation failed");
        return evaluation.status == PTO_STATUS_OK ? PTO_STATUS_MIR_INVALID
                                                  : evaluation.status;
    }
    const Function *initialize_gpr = module->FindFunction(
        GeneratedInitializeGPRBinding());
    if (initialize_gpr == nullptr) {
        SetError("generated InitializeFunctionalModelGPR entrypoint is unavailable");
        return PTO_STATUS_MIR_INVALID;
    }
    for (std::uint32_t index = 0; index < 24; ++index) {
        if ((initial.pe0_gpr_valid_mask & (UINT32_C(1) << index)) == 0) continue;
        evaluation = interpreter_.Evaluate(
            *module, *initialize_gpr, &candidate, &memory,
            {Value(BigInteger(index)),
             Value(BitVector::FromU64(64, initial.pe0_gpr[index]))});
        const auto *accepted = evaluation.return_value
            ? std::get_if<bool>(&evaluation.return_value->storage()) : nullptr;
        if (evaluation.status != PTO_STATUS_OK || accepted == nullptr || !*accepted) {
            SetError("generated InitializeFunctionalModelGPR evaluation failed");
            return evaluation.status == PTO_STATUS_OK ? PTO_STATUS_INVALID_STATE
                                                      : evaluation.status;
        }
    }
    state_ = std::move(candidate);
    last_error_.clear();
    return PTO_STATUS_OK;
}

pto_status_t RuntimeModel::InitializeForTesting(const InitialState &initial) {
    BusyGuard guard(&busy_);
    if (!guard.acquired()) return PTO_STATUS_BUSY;
    RuntimeState candidate = state_;
    candidate.tpc = initial.entry_tpc;
    const pto_status_t status = callbacks_.reset
        ? callbacks_.reset() : PTO_STATUS_INVALID_STATE;
    if (status != PTO_STATUS_OK) return status;
    state_ = std::move(candidate);
    return PTO_STATUS_OK;
}

pto_status_t RuntimeModel::Step(StepResult *result) {
    if (result == nullptr) {
        return PTO_STATUS_INVALID_ARGUMENT;
    }
    BusyGuard guard(&busy_);
    if (!guard.acquired()) {
        return PTO_STATUS_BUSY;
    }
    const std::shared_ptr<const Module> module = module_.lock();
    if (!module) {
        result->state = PTO_STEP_UNSUPPORTED;
        SetError("generated executable module is absent or expired");
        return PTO_STATUS_MIR_INVALID;
    }
    const Function *function = module->FindFunction(GeneratedStepBinding());
    if (function == nullptr) {
        result->state = PTO_STEP_UNSUPPORTED;
        SetError("ExecuteOnePTOStep binding is unresolved");
        return PTO_STATUS_MIR_INVALID;
    }

    RuntimeState candidate = state_;
    MemoryTransaction memory(callbacks_);
    const EvaluationResult evaluation =
        interpreter_.Evaluate(*module, *function, &candidate, &memory);
    if (evaluation.status != PTO_STATUS_OK || !evaluation.return_value ||
        !std::holds_alternative<std::shared_ptr<RecordValue>>(
            evaluation.return_value->storage())) {
        result->state = PTO_STEP_UNSUPPORTED;
        SetError("runtime evaluator or callback failed");
        return evaluation.status == PTO_STATUS_OK ? PTO_STATUS_MIR_INVALID
                                                   : evaluation.status;
    }
    const auto &record = *std::get<std::shared_ptr<RecordValue>>(
        evaluation.return_value->storage());
    const GeneratedStepFieldBindings fields = GeneratedStepFields();
    const auto field = [&record](std::uint32_t id) -> const Value * {
        const auto found = record.find(id);
        return found == record.end() ? nullptr : &found->second;
    };
    const auto unsigned_value = [](const Value *value, std::uint64_t *output) {
        if (value == nullptr) return false;
        if (const auto *bits = std::get_if<BitVector>(&value->storage()))
            return bits->TryToU64(output);
        if (const auto *integer = std::get_if<BigInteger>(&value->storage()))
            return integer->TryToU64(output);
        return false;
    };
    const auto enum_value = [](const Value *value, std::uint32_t *output) {
        const auto *enumeration = value == nullptr ? nullptr
            : std::get_if<EnumValue>(&value->storage());
        if (enumeration == nullptr) return false;
        *output = enumeration->member_id;
        return true;
    };
    std::uint32_t status_member = 0;
    std::uint32_t instruction_member = 0;
    std::uint64_t length = 0, origin = 0, request_type = 0;
    if (!enum_value(field(fields.status), &status_member) ||
        !enum_value(field(fields.instruction_status), &instruction_member) ||
        !unsigned_value(field(fields.length_bits), &length) ||
        !enum_value(field(fields.fault), result ? &result->fault_code : nullptr) ||
        !unsigned_value(field(fields.origin_pe), &origin) ||
        !unsigned_value(field(fields.request_type), &request_type))
        return PTO_STATUS_MIR_INVALID;
    result->state = status_member + 1;
    result->instruction_status = instruction_member;
    result->length_bits = static_cast<std::uint32_t>(length);
    result->origin_pe = static_cast<std::uint32_t>(origin);
    result->request_type = static_cast<std::uint32_t>(request_type);
    std::uint64_t cause = 0;
    if (!unsigned_value(field(fields.sequence), &result->sequence) ||
        !unsigned_value(field(fields.pre_tpc), &result->pre_tpc) ||
        !unsigned_value(field(fields.post_tpc), &result->post_tpc) ||
        !unsigned_value(field(fields.pre_bpc), &result->pre_bpc) ||
        !unsigned_value(field(fields.post_bpc), &result->post_bpc) ||
        !unsigned_value(field(fields.raw_instruction), &result->raw_instruction) ||
        !unsigned_value(field(fields.fault_address), &result->fault_address) ||
        !unsigned_value(field(fields.fault_cause), &cause) ||
        !unsigned_value(field(fields.request_token), &result->request_token) ||
        !unsigned_value(field(fields.request_argument0), &result->request_argument0))
        return PTO_STATUS_MIR_INVALID;
    result->fault_cause = static_cast<std::uint32_t>(cause);
    const pto_status_t commit_status = memory.Commit();
    if (commit_status != PTO_STATUS_OK) {
        result->state = PTO_STEP_UNSUPPORTED;
        SetError("atomic physical-memory commit failed");
        return commit_status;
    }
    state_ = std::move(candidate);
    last_error_.clear();
    return PTO_STATUS_OK;
}

pto_status_t RuntimeModel::StepPrimaryForTesting(StepResult *result) {
    if (result == nullptr) return PTO_STATUS_INVALID_ARGUMENT;
    BusyGuard guard(&busy_);
    if (!guard.acquired()) return PTO_STATUS_BUSY;
    const auto module = module_.lock();
    if (!module) return PTO_STATUS_MIR_INVALID;
    const Function *function = module->FindFunction(module->step_entrypoint());
    if (function == nullptr) return PTO_STATUS_MIR_INVALID;
    RuntimeState candidate = state_;
    MemoryTransaction memory(callbacks_);
    const EvaluationResult evaluation =
        interpreter_.Evaluate(*module, *function, &candidate, &memory);
    if (evaluation.status != PTO_STATUS_OK || evaluation.return_value)
        return evaluation.status == PTO_STATUS_OK ? PTO_STATUS_MIR_INVALID
                                                  : evaluation.status;
    const pto_status_t commit_status = memory.Commit();
    if (commit_status != PTO_STATUS_OK) return commit_status;
    candidate.sequence += 1;
    result->state = evaluation.step_state;
    result->sequence = candidate.sequence;
    state_ = std::move(candidate);
    return PTO_STATUS_OK;
}

pto_status_t RuntimeModel::CompleteHostRequest(std::uint64_t token,
                                               std::uint64_t scalar_result) {
    (void)token;
    (void)scalar_result;
    BusyGuard guard(&busy_);
    if (!guard.acquired()) {
        return PTO_STATUS_BUSY;
    }
    SetError("generated host-completion entrypoint is not connected");
    return PTO_STATUS_MIR_INVALID;
}

pto_status_t RuntimeModel::InvokeU16(BindingId function,
                                     std::uint16_t argument,
                                     std::uint64_t *result) {
    if (result == nullptr) {
        return PTO_STATUS_INVALID_ARGUMENT;
    }
    BusyGuard guard(&busy_);
    if (!guard.acquired()) {
        return PTO_STATUS_BUSY;
    }
    const std::shared_ptr<const Module> module = module_.lock();
    if (!module) {
        SetError("generated executable module is absent or expired");
        return PTO_STATUS_MIR_INVALID;
    }
    const Function *target = module->FindFunction(function);
    if (target == nullptr) {
        SetError("generated numeric function binding is unresolved");
        return PTO_STATUS_MIR_INVALID;
    }
    RuntimeState candidate = state_;
    MemoryTransaction memory(callbacks_);
    const EvaluationResult evaluation = interpreter_.Evaluate(
        *module,
        *target,
        &candidate,
        &memory,
        {Value(BitVector::FromU64(16, argument))});
    if (evaluation.status != PTO_STATUS_OK || !evaluation.return_value) {
        SetError("generated numeric function evaluation failed");
        return evaluation.status == PTO_STATUS_OK
            ? PTO_STATUS_MIR_INVALID
            : evaluation.status;
    }
    const auto *integer = std::get_if<BigInteger>(
        &evaluation.return_value->storage());
    if (evaluation.step_state != PTO_STEP_UNSUPPORTED || integer == nullptr ||
        !integer->TryToU64(result) || !memory.writes().empty() ||
        candidate.globals != state_.globals ||
        candidate.sequence != state_.sequence || candidate.tpc != state_.tpc ||
        candidate.bpc != state_.bpc) {
        SetError("generated numeric function violated its pure result contract");
        return PTO_STATUS_MIR_INVALID;
    }
    last_error_.clear();
    return PTO_STATUS_OK;
}

std::string RuntimeModel::last_error() const { return last_error_; }

std::uint64_t RuntimeModel::GlobalU64(BindingId id) const {
    const auto found = state_.globals.find(id);
    return found == state_.globals.end() ? 0 : found->second;
}

const Value *RuntimeModel::GlobalValueForTesting(BindingId id) const {
    const auto found = state_.typed_globals.find(id);
    return found == state_.typed_globals.end() ? nullptr : &found->second;
}

void RuntimeModel::SetError(std::string error) {
    last_error_ = std::move(error);
}

std::shared_ptr<const Module> DisconnectedModule() {
    return nullptr;
}

}  // namespace pto::model

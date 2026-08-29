#include "runtime_model.h"

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
    : module_(std::move(module)), callbacks_(std::move(callbacks)) {}

pto_status_t RuntimeModel::Reset(const InitialState &initial) {
    BusyGuard guard(&busy_);
    if (!guard.acquired()) {
        return PTO_STATUS_BUSY;
    }
    RuntimeState candidate;
    candidate.tpc = initial.entry_tpc;
    if (!callbacks_.reset) {
        SetError("physical-memory reset callback is missing");
        return PTO_STATUS_INVALID_STATE;
    }
    const pto_status_t status = callbacks_.reset();
    if (status != PTO_STATUS_OK) {
        SetError("physical-memory reset callback failed");
        return status;
    }
    state_ = std::move(candidate);
    last_error_.clear();
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
    const Function *function = module->FindFunction(module->step_entrypoint());
    if (function == nullptr) {
        result->state = PTO_STEP_UNSUPPORTED;
        SetError("ExecuteOnePTOStep binding is unresolved");
        return PTO_STATUS_MIR_INVALID;
    }

    RuntimeState candidate = state_;
    MemoryTransaction memory(callbacks_);
    const EvaluationResult evaluation =
        interpreter_.Evaluate(*module, *function, &candidate, &memory);
    if (evaluation.status != PTO_STATUS_OK || evaluation.return_value) {
        result->state = PTO_STEP_UNSUPPORTED;
        SetError("runtime evaluator or callback failed");
        return evaluation.status == PTO_STATUS_OK
            ? PTO_STATUS_MIR_INVALID
            : evaluation.status;
    }
    const pto_status_t commit_status = memory.Commit();
    if (commit_status != PTO_STATUS_OK) {
        result->state = PTO_STEP_UNSUPPORTED;
        SetError("atomic physical-memory commit failed");
        return commit_status;
    }
    candidate.sequence += 1;
    result->state = evaluation.step_state;
    result->sequence = candidate.sequence;
    result->pre_tpc = state_.tpc;
    result->post_tpc = candidate.tpc;
    result->pre_bpc = state_.bpc;
    result->post_bpc = candidate.bpc;
    state_ = std::move(candidate);
    last_error_.clear();
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

void RuntimeModel::SetError(std::string error) {
    last_error_ = std::move(error);
}

std::shared_ptr<const Module> DisconnectedModule() {
    return nullptr;
}

}  // namespace pto::model

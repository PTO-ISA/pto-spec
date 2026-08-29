#ifndef PTO_FUNCTIONAL_MODEL_RUNTIME_MODEL_H
#define PTO_FUNCTIONAL_MODEL_RUNTIME_MODEL_H

#include "interpreter.h"
#include "module.h"
#include "transaction.h"

#include <atomic>
#include <array>
#include <cstdint>
#include <memory>
#include <string>

namespace pto::model {

struct InitialState {
    std::uint64_t entry_tpc = 0;
    std::uint32_t pe0_gpr_valid_mask = 0;
    std::array<std::uint64_t, 24> pe0_gpr{};
};

struct StepResult {
    pto_step_state_t state = PTO_STEP_UNSUPPORTED;
    std::uint64_t sequence = 0;
    std::uint64_t pre_tpc = 0;
    std::uint64_t post_tpc = 0;
    std::uint64_t pre_bpc = 0;
    std::uint64_t post_bpc = 0;
};

class RuntimeModel {
  public:
    RuntimeModel(std::weak_ptr<const Module> module, MemoryCallbacks callbacks);
    pto_status_t Reset(const InitialState &initial);
    pto_status_t InitializeForTesting(const InitialState &initial);
    pto_status_t Step(StepResult *result);
    pto_status_t CompleteHostRequest(std::uint64_t token,
                                     std::uint64_t scalar_result);
    pto_status_t InvokeU16(BindingId function,
                           std::uint16_t argument,
                           std::uint64_t *result);
    std::string last_error() const;
    std::uint64_t GlobalU64(BindingId id) const;
    const Value *GlobalValueForTesting(BindingId id) const;

  private:
    class BusyGuard {
      public:
        explicit BusyGuard(std::atomic_flag *busy);
        ~BusyGuard();
        bool acquired() const;

      private:
        std::atomic_flag *busy_;
        bool acquired_;
    };

    void SetError(std::string error);
    std::weak_ptr<const Module> module_;
    MemoryCallbacks callbacks_;
    RuntimeState state_;
    Interpreter interpreter_;
    mutable std::string last_error_;
    std::atomic_flag busy_ = ATOMIC_FLAG_INIT;
};

std::shared_ptr<const Module> DisconnectedModule();

}  // namespace pto::model

#endif

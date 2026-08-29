#ifndef PTO_FUNCTIONAL_MODEL_INTERPRETER_H
#define PTO_FUNCTIONAL_MODEL_INTERPRETER_H

#include "module.h"
#include "transaction.h"
#include "value.h"

#include <cstdint>
#include <optional>
#include <unordered_map>
#include <utility>
#include <vector>

namespace pto::model {

struct RuntimeState {
    std::unordered_map<BindingId, std::uint64_t> globals;
    std::uint64_t sequence = 0;
    std::uint64_t tpc = 0;
    std::uint64_t bpc = 0;
};

struct EvaluationResult {
    EvaluationResult() = default;
    EvaluationResult(pto_status_t status_value,
                     pto_step_state_t step_state_value,
                     std::optional<Value> return_value_value = std::nullopt)
        : status(status_value),
          step_state(step_state_value),
          return_value(std::move(return_value_value)) {}
    pto_status_t status = PTO_STATUS_OK;
    pto_step_state_t step_state = PTO_STEP_UNSUPPORTED;
    std::optional<Value> return_value;
};

class Interpreter {
  public:
    EvaluationResult Evaluate(const Function &function,
                              RuntimeState *state,
                              MemoryTransaction *memory,
                              const std::vector<Value> &arguments = {}) const;

  private:
    struct CallFrame {
        BindingId function_id;
        std::unordered_map<std::uint32_t, std::uint64_t> locals;
        std::unordered_map<std::uint32_t, Value> typed_locals;
    };
};

}  // namespace pto::model

#endif

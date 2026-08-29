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
    std::unordered_map<BindingId, Value> typed_globals;
    std::uint64_t sequence = 0;
    std::uint64_t tpc = 0;
    std::uint64_t bpc = 0;
};

struct EvaluationResult {
    EvaluationResult() = default;
    EvaluationResult(pto_status_t status_value,
                     pto_step_state_t step_state_value,
                     std::optional<Value> return_value_value = std::nullopt,
                     BindingId failure_function_value = 0,
                     std::uint32_t failure_node_value = 0,
                     std::uint32_t failure_constructor_value = 0)
        : status(status_value),
          step_state(step_state_value),
          return_value(std::move(return_value_value)),
          failure_function(failure_function_value),
          failure_node(failure_node_value),
          failure_constructor(failure_constructor_value) {}
    pto_status_t status = PTO_STATUS_OK;
    pto_step_state_t step_state = PTO_STEP_UNSUPPORTED;
    std::optional<Value> return_value;
    BindingId failure_function = 0;
    std::uint32_t failure_node = 0;
    std::uint32_t failure_constructor = 0;
};

class Interpreter {
  public:
    EvaluationResult Evaluate(const Module &module,
                              const Function &function,
                              RuntimeState *state,
                              MemoryTransaction *memory,
                              const std::vector<Value> &arguments = {},
                              std::uint64_t instruction_limit = (UINT64_C(1) << 20)) const;

  private:
    EvaluationResult EvaluateInternal(const Module &module,
                                      const Function &function,
                                      RuntimeState *state,
                                      MemoryTransaction *memory,
                                      const std::vector<Value> &arguments,
                                      std::uint32_t depth,
                                      std::uint64_t *remaining) const;
    struct CallFrame {
        BindingId function_id;
        std::unordered_map<std::uint32_t, std::uint64_t> locals;
        std::unordered_map<std::uint32_t, Value> typed_locals;
        std::vector<Value> pending_arguments;
    };
};

}  // namespace pto::model

#endif

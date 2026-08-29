#ifndef PTO_FUNCTIONAL_MODEL_INTERPRETER_H
#define PTO_FUNCTIONAL_MODEL_INTERPRETER_H

#include "module.h"
#include "transaction.h"

#include <cstdint>
#include <unordered_map>
#include <vector>

namespace pto::model {

struct RuntimeState {
    std::unordered_map<BindingId, std::uint64_t> globals;
    std::uint64_t sequence = 0;
    std::uint64_t tpc = 0;
    std::uint64_t bpc = 0;
};

struct EvaluationResult {
    pto_status_t status = PTO_STATUS_OK;
    pto_step_state_t step_state = PTO_STEP_UNSUPPORTED;
};

class Interpreter {
  public:
    EvaluationResult Evaluate(const Function &function,
                              RuntimeState *state,
                              MemoryTransaction *memory) const;

  private:
    struct CallFrame {
        BindingId function_id;
        std::unordered_map<std::uint32_t, std::uint64_t> locals;
    };
};

}  // namespace pto::model

#endif

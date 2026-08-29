#include "interpreter.h"

namespace pto::model {

EvaluationResult Interpreter::Evaluate(const Function &function,
                                       RuntimeState *state,
                                       MemoryTransaction *memory) const {
    if (state == nullptr || memory == nullptr) {
        return {PTO_STATUS_INVALID_ARGUMENT, PTO_STEP_UNSUPPORTED};
    }
    CallFrame frame{function.id, {}};
    for (const Instruction &instruction : function.instructions) {
        switch (instruction.opcode) {
            case OpCode::kSetLocalU64:
                frame.locals[instruction.local] = instruction.immediate;
                break;
            case OpCode::kAddLocalU64:
                frame.locals[instruction.local] += instruction.immediate;
                break;
            case OpCode::kStoreLocalToGlobal: {
                const auto local = frame.locals.find(instruction.local);
                if (local == frame.locals.end()) {
                    return {PTO_STATUS_MIR_INVALID, PTO_STEP_UNSUPPORTED};
                }
                state->globals[instruction.binding] = local->second;
                break;
            }
            case OpCode::kIncrementGlobalU64:
                state->globals[instruction.binding] += instruction.immediate;
                break;
            case OpCode::kProbeMemory: {
                bool permitted = false;
                const pto_status_t status = memory->Probe(
                    static_cast<pto_memory_access_kind_t>(instruction.immediate),
                    instruction.address,
                    instruction.local,
                    &permitted);
                if (status != PTO_STATUS_OK) {
                    return {status, PTO_STEP_UNSUPPORTED};
                }
                if (!permitted) {
                    return {PTO_STATUS_MIR_INVALID, PTO_STEP_UNSUPPORTED};
                }
                break;
            }
            case OpCode::kWriteMemoryImmediate:
                memory->Write(instruction.address,
                              static_cast<std::uint8_t>(instruction.immediate));
                break;
            case OpCode::kReadMemoryToGlobal: {
                std::uint8_t value = 0;
                const pto_status_t status =
                    memory->Read(instruction.address, &value, 1);
                if (status != PTO_STATUS_OK) {
                    return {status, PTO_STEP_UNSUPPORTED};
                }
                state->globals[instruction.binding] = value;
                break;
            }
            case OpCode::kReturnExecuted:
                return {PTO_STATUS_OK, PTO_STEP_EXECUTED};
            case OpCode::kReturnTrap:
                return {PTO_STATUS_OK, PTO_STEP_TRAP};
            case OpCode::kReturnHostRequest:
                return {PTO_STATUS_OK, PTO_STEP_HOST_REQUEST};
        }
    }
    return {PTO_STATUS_MIR_INVALID, PTO_STEP_UNSUPPORTED};
}

}  // namespace pto::model

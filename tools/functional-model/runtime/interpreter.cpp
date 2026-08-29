#include "interpreter.h"

#include <stdexcept>

namespace pto::model {

namespace {

bool EqualValues(const Value &left, const Value &right, bool *equal) {
    if (equal == nullptr || left.storage().index() != right.storage().index()) {
        return false;
    }
    if (const auto *value = std::get_if<bool>(&left.storage())) {
        *equal = *value == std::get<bool>(right.storage());
        return true;
    }
    if (const auto *value = std::get_if<BigInteger>(&left.storage())) {
        *equal = *value == std::get<BigInteger>(right.storage());
        return true;
    }
    if (const auto *value = std::get_if<BitVector>(&left.storage())) {
        *equal = *value == std::get<BitVector>(right.storage());
        return true;
    }
    if (const auto *value = std::get_if<EnumValue>(&left.storage())) {
        *equal = *value == std::get<EnumValue>(right.storage());
        return true;
    }
    return false;
}

}  // namespace

EvaluationResult Interpreter::Evaluate(const Module &module,
                                       const Function &function,
                                       RuntimeState *state,
                                       MemoryTransaction *memory,
                                       const std::vector<Value> &arguments) const {
    return EvaluateInternal(module, function, state, memory, arguments, 0);
}

EvaluationResult Interpreter::EvaluateInternal(
    const Module &module,
    const Function &function,
    RuntimeState *state,
    MemoryTransaction *memory,
    const std::vector<Value> &arguments,
    std::uint32_t depth) const {
    if (state == nullptr || memory == nullptr) {
        return {PTO_STATUS_INVALID_ARGUMENT, PTO_STEP_UNSUPPORTED};
    }
    if (depth >= 256) {
        return {PTO_STATUS_RESOURCE_LIMIT, PTO_STEP_UNSUPPORTED};
    }
    CallFrame frame{function.id, {}, {}, {}};
    std::size_t pc = 0;
    while (pc < function.instructions.size()) {
        const Instruction &instruction = function.instructions[pc];
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
            case OpCode::kLoadArgumentBits:
                if (instruction.binding >= arguments.size() ||
                    !std::holds_alternative<BitVector>(
                        arguments[instruction.binding].storage()) ||
                    std::get<BitVector>(arguments[instruction.binding].storage()).width() !=
                        instruction.immediate) {
                    return {PTO_STATUS_MIR_INVALID, PTO_STEP_UNSUPPORTED};
                }
                frame.typed_locals.insert_or_assign(
                    instruction.local, arguments[instruction.binding]);
                break;
            case OpCode::kLoadBitsImmediate:
                frame.typed_locals.insert_or_assign(
                    instruction.local,
                    Value(BitVector::FromU64(
                        static_cast<std::size_t>(instruction.address),
                        instruction.immediate)));
                break;
            case OpCode::kLoadIntegerImmediate:
                frame.typed_locals.insert_or_assign(
                    instruction.local,
                    Value(BigInteger::FromUnsignedWords(
                        {static_cast<std::uint32_t>(instruction.immediate),
                         static_cast<std::uint32_t>(instruction.immediate >> 32)})));
                break;
            case OpCode::kSliceBits: {
                const auto source = frame.typed_locals.find(instruction.binding);
                if (source == frame.typed_locals.end() ||
                    !std::holds_alternative<BitVector>(source->second.storage())) {
                    return {PTO_STATUS_MIR_INVALID, PTO_STEP_UNSUPPORTED};
                }
                try {
                    frame.typed_locals.insert_or_assign(
                        instruction.local,
                        Value(std::get<BitVector>(source->second.storage()).Slice(
                            static_cast<std::size_t>(instruction.immediate),
                            static_cast<std::size_t>(instruction.address))));
                } catch (const std::out_of_range &) {
                    return {PTO_STATUS_MIR_INVALID, PTO_STEP_UNSUPPORTED};
                }
                break;
            }
            case OpCode::kEqual:
            case OpCode::kNotEqual: {
                const auto left = frame.typed_locals.find(instruction.binding);
                const auto right = frame.typed_locals.find(
                    static_cast<std::uint32_t>(instruction.address));
                bool equal = false;
                if (left == frame.typed_locals.end() ||
                    right == frame.typed_locals.end() ||
                    !EqualValues(left->second, right->second, &equal)) {
                    return {PTO_STATUS_MIR_INVALID, PTO_STEP_UNSUPPORTED};
                }
                frame.typed_locals.insert_or_assign(
                    instruction.local,
                    Value(instruction.opcode == OpCode::kEqual ? equal : !equal));
                break;
            }
            case OpCode::kAssertTrue: {
                const auto condition = frame.typed_locals.find(instruction.local);
                if (condition == frame.typed_locals.end() ||
                    !std::holds_alternative<bool>(condition->second.storage()) ||
                    !std::get<bool>(condition->second.storage())) {
                    return {PTO_STATUS_MIR_INVALID, PTO_STEP_UNSUPPORTED};
                }
                break;
            }
            case OpCode::kPushArgument: {
                const auto value = frame.typed_locals.find(instruction.local);
                if (value == frame.typed_locals.end()) {
                    return {PTO_STATUS_MIR_INVALID, PTO_STEP_UNSUPPORTED};
                }
                frame.pending_arguments.push_back(value->second);
                break;
            }
            case OpCode::kCallValue:
            case OpCode::kCallProcedure: {
                const Function *target = module.FindFunction(instruction.binding);
                if (target == nullptr ||
                    frame.pending_arguments.size() != instruction.immediate) {
                    return {PTO_STATUS_MIR_INVALID, PTO_STEP_UNSUPPORTED};
                }
                EvaluationResult called = EvaluateInternal(
                    module,
                    *target,
                    state,
                    memory,
                    frame.pending_arguments,
                    depth + 1);
                frame.pending_arguments.clear();
                if (called.status != PTO_STATUS_OK) {
                    return called;
                }
                if (instruction.opcode == OpCode::kCallValue) {
                    if (!called.return_value) {
                        return {PTO_STATUS_MIR_INVALID, PTO_STEP_UNSUPPORTED};
                    }
                    frame.typed_locals.insert_or_assign(
                        instruction.local, *called.return_value);
                } else if (called.return_value) {
                    return {PTO_STATUS_MIR_INVALID, PTO_STEP_UNSUPPORTED};
                }
                break;
            }
            case OpCode::kBranchIfFalse: {
                const auto condition = frame.typed_locals.find(instruction.local);
                if (condition == frame.typed_locals.end() ||
                    !std::holds_alternative<bool>(condition->second.storage())) {
                    return {PTO_STATUS_MIR_INVALID, PTO_STEP_UNSUPPORTED};
                }
                if (!std::get<bool>(condition->second.storage())) {
                    pc = static_cast<std::size_t>(instruction.address);
                    continue;
                }
                break;
            }
            case OpCode::kJump:
                pc = static_cast<std::size_t>(instruction.address);
                continue;
            case OpCode::kReturnValue: {
                const auto value = frame.typed_locals.find(instruction.local);
                if (value == frame.typed_locals.end()) {
                    return {PTO_STATUS_MIR_INVALID, PTO_STEP_UNSUPPORTED};
                }
                return {PTO_STATUS_OK, PTO_STEP_UNSUPPORTED, value->second};
            }
            case OpCode::kReturnProcedure:
                return {PTO_STATUS_OK, PTO_STEP_UNSUPPORTED};
            case OpCode::kReturnExecuted:
                return {PTO_STATUS_OK, PTO_STEP_EXECUTED};
            case OpCode::kReturnTrap:
                return {PTO_STATUS_OK, PTO_STEP_TRAP};
            case OpCode::kReturnHostRequest:
                return {PTO_STATUS_OK, PTO_STEP_HOST_REQUEST};
        }
        ++pc;
    }
    return {PTO_STATUS_MIR_INVALID, PTO_STEP_UNSUPPORTED};
}

}  // namespace pto::model

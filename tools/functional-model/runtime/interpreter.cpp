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
                                       const std::vector<Value> &arguments,
                                       std::uint64_t instruction_limit) const {
    return EvaluateInternal(
        module, function, state, memory, arguments, 0, &instruction_limit);
}

EvaluationResult Interpreter::EvaluateInternal(
    const Module &module,
    const Function &function,
    RuntimeState *state,
    MemoryTransaction *memory,
    const std::vector<Value> &arguments,
    std::uint32_t depth,
    std::uint64_t *remaining) const {
    if (state == nullptr || memory == nullptr) {
        return {PTO_STATUS_INVALID_ARGUMENT, PTO_STEP_UNSUPPORTED};
    }
    if (depth >= 256) {
        return {PTO_STATUS_RESOURCE_LIMIT, PTO_STEP_UNSUPPORTED};
    }
    CallFrame frame{function.id, {}, {}, {}};
    std::size_t pc = 0;
    while (pc < function.instructions.size()) {
        if (remaining == nullptr || *remaining == 0) {
            return {PTO_STATUS_RESOURCE_LIMIT, PTO_STEP_UNSUPPORTED};
        }
        --*remaining;
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
                    (instruction.immediate != 0 &&
                     std::get<BitVector>(arguments[instruction.binding].storage()).width() !=
                         instruction.immediate)) {
                    return {PTO_STATUS_MIR_INVALID, PTO_STEP_UNSUPPORTED};
                }
                frame.typed_locals.insert_or_assign(
                    instruction.local, arguments[instruction.binding]);
                break;
            case OpCode::kLoadArgumentInteger:
                if (instruction.binding >= arguments.size() ||
                    !std::holds_alternative<BigInteger>(
                        arguments[instruction.binding].storage()))
                    return {PTO_STATUS_MIR_INVALID, PTO_STEP_UNSUPPORTED};
                frame.typed_locals.insert_or_assign(
                    instruction.local, arguments[instruction.binding].Clone());
                break;
            case OpCode::kLoadArgumentEnum:
                if (instruction.binding >= arguments.size() ||
                    !std::holds_alternative<EnumValue>(
                        arguments[instruction.binding].storage()))
                    return {PTO_STATUS_MIR_INVALID, PTO_STEP_UNSUPPORTED};
                frame.typed_locals.insert_or_assign(
                    instruction.local, arguments[instruction.binding].Clone());
                break;
            case OpCode::kLoadArgumentBool:
                if (instruction.binding >= arguments.size() ||
                    !std::holds_alternative<bool>(
                        arguments[instruction.binding].storage()))
                    return {PTO_STATUS_MIR_INVALID, PTO_STEP_UNSUPPORTED};
                frame.typed_locals.insert_or_assign(
                    instruction.local, arguments[instruction.binding].Clone());
                break;
            case OpCode::kLoadArgumentValue:
                if (instruction.binding >= arguments.size())
                    return {PTO_STATUS_MIR_INVALID, PTO_STEP_UNSUPPORTED};
                frame.typed_locals.insert_or_assign(
                    instruction.local, arguments[instruction.binding].Clone());
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
            case OpCode::kLoadIntegerNegative:
                if (instruction.immediate > static_cast<std::uint64_t>(INT64_MAX))
                    return {PTO_STATUS_RESOURCE_LIMIT, PTO_STEP_UNSUPPORTED};
                frame.typed_locals.insert_or_assign(
                    instruction.local,
                    Value(BigInteger(-static_cast<std::int64_t>(instruction.immediate))));
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
            case OpCode::kDynamicSlice: {
                const auto source = frame.typed_locals.find(instruction.binding);
                const auto start_value = frame.typed_locals.find(
                    static_cast<std::uint32_t>(instruction.immediate));
                const auto width_value = frame.typed_locals.find(
                    static_cast<std::uint32_t>(instruction.address));
                std::uint64_t start = 0;
                std::uint64_t width = 0;
                if (source == frame.typed_locals.end() ||
                    start_value == frame.typed_locals.end() ||
                    width_value == frame.typed_locals.end() ||
                    !std::holds_alternative<BigInteger>(start_value->second.storage()) ||
                    !std::holds_alternative<BigInteger>(width_value->second.storage()) ||
                    !std::get<BigInteger>(start_value->second.storage()).TryToU64(&start) ||
                    !std::get<BigInteger>(width_value->second.storage()).TryToU64(&width) ||
                    width > (UINT64_C(1) << 20))
                    return {PTO_STATUS_MIR_INVALID, PTO_STEP_UNSUPPORTED};
                try {
                    if (const auto *bits = std::get_if<BitVector>(
                            &source->second.storage())) {
                        frame.typed_locals.insert_or_assign(
                            instruction.local,
                            Value(bits->Slice(static_cast<std::size_t>(start),
                                              static_cast<std::size_t>(width))));
                    } else if (const auto *integer = std::get_if<BigInteger>(
                                   &source->second.storage());
                               integer != nullptr && integer->IsZero() && start == 0) {
                        frame.typed_locals.insert_or_assign(
                            instruction.local,
                            Value(BitVector(static_cast<std::size_t>(width))));
                    } else {
                        return {PTO_STATUS_MIR_INVALID, PTO_STEP_UNSUPPORTED};
                    }
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
            case OpCode::kCopyValue: {
                const auto value = frame.typed_locals.find(instruction.binding);
                if (value == frame.typed_locals.end())
                    return {PTO_STATUS_MIR_INVALID, PTO_STEP_UNSUPPORTED};
                frame.typed_locals.insert_or_assign(
                    instruction.local, value->second.Clone());
                break;
            }
            case OpCode::kLoadGlobal: {
                const auto value = state->typed_globals.find(instruction.binding);
                if (value == state->typed_globals.end())
                    return {PTO_STATUS_MIR_INVALID, PTO_STEP_UNSUPPORTED};
                frame.typed_locals.insert_or_assign(
                    instruction.local, value->second.Clone());
                break;
            }
            case OpCode::kLoadBool:
                frame.typed_locals.insert_or_assign(
                    instruction.local, Value(instruction.immediate != 0));
                break;
            case OpCode::kLoadEnum:
                frame.typed_locals.insert_or_assign(
                    instruction.local,
                    Value(EnumValue{
                        static_cast<std::uint32_t>(instruction.immediate),
                        static_cast<std::uint32_t>(instruction.address)}));
                break;
            case OpCode::kStoreGlobal: {
                const auto value = frame.typed_locals.find(instruction.local);
                if (value == frame.typed_locals.end())
                    return {PTO_STATUS_MIR_INVALID, PTO_STEP_UNSUPPORTED};
                state->typed_globals.insert_or_assign(
                    instruction.binding, value->second.Clone());
                break;
            }
            case OpCode::kCallValue:
            case OpCode::kCallProcedure: {
                const Function *target = module.FindFunction(instruction.binding);
                if (target == nullptr ||
                    frame.pending_arguments.size() != instruction.immediate ||
                    target->argument_count != instruction.immediate) {
                    return {PTO_STATUS_MIR_INVALID, PTO_STEP_UNSUPPORTED};
                }
                EvaluationResult called = EvaluateInternal(
                    module,
                    *target,
                    state,
                    memory,
                    frame.pending_arguments,
                    depth + 1,
                    remaining);
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
            case OpCode::kCallExtern: {
                const ExternDefinition *target = module.FindExtern(instruction.binding);
                if (target == nullptr ||
                    frame.pending_arguments.size() != target->argument_count ||
                    target->argument_count != instruction.immediate) {
                    return {PTO_STATUS_MIR_INVALID, PTO_STEP_UNSUPPORTED};
                }
                if (target->kind == ExternKind::kResetPhysicalMemory) {
                    if (!frame.pending_arguments.empty())
                        return {PTO_STATUS_MIR_INVALID, PTO_STEP_UNSUPPORTED};
                    const pto_status_t reset_status = memory->Reset();
                    if (reset_status != PTO_STATUS_OK)
                        return {reset_status, PTO_STEP_UNSUPPORTED};
                    break;
                }
                if (target->kind == ExternKind::kReadPhysicalMemoryByte) {
                    if (frame.pending_arguments.size() != 1 ||
                        !std::holds_alternative<BitVector>(
                            frame.pending_arguments[0].storage()))
                        return {PTO_STATUS_MIR_INVALID, PTO_STEP_UNSUPPORTED};
                    std::uint64_t address = 0;
                    std::uint8_t byte = 0;
                    if (!std::get<BitVector>(frame.pending_arguments[0].storage())
                             .TryToU64(&address))
                        return {PTO_STATUS_MIR_INVALID, PTO_STEP_UNSUPPORTED};
                    const pto_status_t read_status = memory->Read(address, &byte, 1);
                    if (read_status != PTO_STATUS_OK)
                        return {read_status, PTO_STEP_UNSUPPORTED};
                    frame.pending_arguments.clear();
                    frame.typed_locals.insert_or_assign(
                        instruction.local, Value(BitVector::FromU64(8, byte)));
                    break;
                }
                if (target->kind == ExternKind::kWritePhysicalMemoryByte) {
                    if (frame.pending_arguments.size() != 2 ||
                        !std::holds_alternative<BitVector>(
                            frame.pending_arguments[0].storage()) ||
                        !std::holds_alternative<BitVector>(
                            frame.pending_arguments[1].storage()))
                        return {PTO_STATUS_MIR_INVALID, PTO_STEP_UNSUPPORTED};
                    std::uint64_t address = 0, value = 0;
                    if (!std::get<BitVector>(frame.pending_arguments[0].storage())
                             .TryToU64(&address) ||
                        !std::get<BitVector>(frame.pending_arguments[1].storage())
                             .TryToU64(&value) || value > 0xff)
                        return {PTO_STATUS_MIR_INVALID, PTO_STEP_UNSUPPORTED};
                    memory->Write(address, static_cast<std::uint8_t>(value));
                    frame.pending_arguments.clear();
                    break;
                }
                if (frame.pending_arguments.empty() ||
                    !std::holds_alternative<BitVector>(
                        frame.pending_arguments[0].storage())) {
                    return {PTO_STATUS_MIR_INVALID, PTO_STEP_UNSUPPORTED};
                }
                const BitVector &bits = std::get<BitVector>(
                    frame.pending_arguments[0].storage());
                if (frame.pending_arguments.size() == 2) {
                    const auto *width = std::get_if<BigInteger>(
                        &frame.pending_arguments[1].storage());
                    std::uint64_t width_value = 0;
                    if (width == nullptr || !width->TryToU64(&width_value) ||
                        width_value != bits.width())
                        return {PTO_STATUS_MIR_INVALID, PTO_STEP_UNSUPPORTED};
                } else if (frame.pending_arguments.size() != 1) {
                    return {PTO_STATUS_MIR_INVALID, PTO_STEP_UNSUPPORTED};
                }
                BigInteger result = target->kind == ExternKind::kUInt
                    ? bits.ToUnsignedInteger() : bits.ToSignedInteger();
                frame.pending_arguments.clear();
                frame.typed_locals.insert_or_assign(
                    instruction.local, Value(std::move(result)));
                break;
            }
            case OpCode::kIntegerAdd:
            case OpCode::kIntegerSubtract:
            case OpCode::kIntegerMultiply:
            case OpCode::kIntegerDivide:
            case OpCode::kIntegerModulo:
            case OpCode::kIntegerLessEqual:
            case OpCode::kIntegerGreaterEqual:
            case OpCode::kIntegerLess:
            case OpCode::kIntegerGreater: {
                const auto left = frame.typed_locals.find(instruction.binding);
                const auto right = frame.typed_locals.find(
                    static_cast<std::uint32_t>(instruction.address));
                if (left == frame.typed_locals.end() || right == frame.typed_locals.end())
                    return {PTO_STATUS_MIR_INVALID, PTO_STEP_UNSUPPORTED};
                if (instruction.opcode == OpCode::kIntegerAdd &&
                    std::holds_alternative<BitVector>(left->second.storage()) &&
                    (std::holds_alternative<BitVector>(right->second.storage()) ||
                     std::holds_alternative<BigInteger>(right->second.storage()))) {
                    try {
                        const BitVector &left_bits =
                            std::get<BitVector>(left->second.storage());
                        BitVector right_bits = BitVector(left_bits.width());
                        if (const auto *bits = std::get_if<BitVector>(
                                &right->second.storage())) {
                            right_bits = *bits;
                        } else {
                            std::uint64_t carrier = 0;
                            if (!std::get<BigInteger>(right->second.storage())
                                     .TryToU64(&carrier))
                                return {PTO_STATUS_MIR_INVALID,
                                        PTO_STEP_UNSUPPORTED};
                            right_bits = BitVector::FromU64(
                                left_bits.width(), carrier);
                        }
                        frame.typed_locals.insert_or_assign(
                            instruction.local,
                            Value(left_bits.BitAdd(right_bits)));
                    } catch (const std::invalid_argument &) {
                        return {PTO_STATUS_MIR_INVALID, PTO_STEP_UNSUPPORTED};
                    }
                    break;
                }
                if (!std::holds_alternative<BigInteger>(left->second.storage()) ||
                    !std::holds_alternative<BigInteger>(right->second.storage()))
                    return {PTO_STATUS_MIR_INVALID, PTO_STEP_UNSUPPORTED};
                const BigInteger &l = std::get<BigInteger>(left->second.storage());
                const BigInteger &r = std::get<BigInteger>(right->second.storage());
                if (instruction.opcode == OpCode::kIntegerAdd ||
                    instruction.opcode == OpCode::kIntegerSubtract ||
                    instruction.opcode == OpCode::kIntegerMultiply ||
                    instruction.opcode == OpCode::kIntegerDivide ||
                    instruction.opcode == OpCode::kIntegerModulo) {
                    if (instruction.opcode == OpCode::kIntegerDivide ||
                        instruction.opcode == OpCode::kIntegerModulo) {
                        BigInteger result;
                        const bool valid = instruction.opcode == OpCode::kIntegerDivide
                            ? l.Divide(r, &result) : l.Modulo(r, &result);
                        if (!valid)
                            return {PTO_STATUS_MIR_INVALID, PTO_STEP_UNSUPPORTED};
                        frame.typed_locals.insert_or_assign(
                            instruction.local, Value(std::move(result)));
                        break;
                    }
                    frame.typed_locals.insert_or_assign(
                        instruction.local,
                        Value(instruction.opcode == OpCode::kIntegerMultiply
                                  ? l.Multiply(r)
                                  : l.Add(instruction.opcode == OpCode::kIntegerAdd
                                              ? r : r.Negated())));
                } else {
                    const int order = l.Compare(r);
                    bool comparison = false;
                    if (instruction.opcode == OpCode::kIntegerLessEqual)
                        comparison = order <= 0;
                    else if (instruction.opcode == OpCode::kIntegerGreaterEqual)
                        comparison = order >= 0;
                    else if (instruction.opcode == OpCode::kIntegerLess)
                        comparison = order < 0;
                    else comparison = order > 0;
                    frame.typed_locals.insert_or_assign(
                        instruction.local, Value(comparison));
                }
                break;
            }
            case OpCode::kIntegerStep: {
                const auto value = frame.typed_locals.find(instruction.local);
                if (value == frame.typed_locals.end() ||
                    !std::holds_alternative<BigInteger>(value->second.storage()))
                    return {PTO_STATUS_MIR_INVALID, PTO_STEP_UNSUPPORTED};
                const BigInteger delta(instruction.immediate == 0 ? 1 : -1);
                frame.typed_locals.insert_or_assign(
                    instruction.local,
                    Value(std::get<BigInteger>(value->second.storage()).Add(delta)));
                break;
            }
            case OpCode::kIntegerNegate: {
                const auto value = frame.typed_locals.find(instruction.binding);
                if (value == frame.typed_locals.end() ||
                    !std::holds_alternative<BigInteger>(value->second.storage()))
                    return {PTO_STATUS_MIR_INVALID, PTO_STEP_UNSUPPORTED};
                frame.typed_locals.insert_or_assign(
                    instruction.local,
                    Value(std::get<BigInteger>(value->second.storage()).Negated()));
                break;
            }
            case OpCode::kBitOr: {
                const auto left = frame.typed_locals.find(instruction.binding);
                const auto right = frame.typed_locals.find(
                    static_cast<std::uint32_t>(instruction.address));
                if (left == frame.typed_locals.end() || right == frame.typed_locals.end())
                    return {PTO_STATUS_MIR_INVALID, PTO_STEP_UNSUPPORTED};
                if (std::holds_alternative<bool>(left->second.storage()) &&
                    std::holds_alternative<bool>(right->second.storage())) {
                    frame.typed_locals.insert_or_assign(
                        instruction.local,
                        Value(std::get<bool>(left->second.storage()) ||
                              std::get<bool>(right->second.storage())));
                    break;
                }
                if (!std::holds_alternative<BitVector>(left->second.storage()) ||
                    !std::holds_alternative<BitVector>(right->second.storage()))
                    return {PTO_STATUS_MIR_INVALID, PTO_STEP_UNSUPPORTED};
                try {
                    frame.typed_locals.insert_or_assign(
                        instruction.local,
                        Value(std::get<BitVector>(left->second.storage()).BitOr(
                            std::get<BitVector>(right->second.storage()))));
                } catch (const std::invalid_argument &) {
                    return {PTO_STATUS_MIR_INVALID, PTO_STEP_UNSUPPORTED};
                }
                break;
            }
            case OpCode::kBitAnd: {
                const auto left = frame.typed_locals.find(instruction.binding);
                const auto right = frame.typed_locals.find(
                    static_cast<std::uint32_t>(instruction.address));
                if (left == frame.typed_locals.end() || right == frame.typed_locals.end())
                    return {PTO_STATUS_MIR_INVALID, PTO_STEP_UNSUPPORTED};
                if (std::holds_alternative<bool>(left->second.storage()) &&
                    std::holds_alternative<bool>(right->second.storage())) {
                    frame.typed_locals.insert_or_assign(
                        instruction.local,
                        Value(std::get<bool>(left->second.storage()) &&
                              std::get<bool>(right->second.storage())));
                    break;
                }
                if (!std::holds_alternative<BitVector>(left->second.storage()) ||
                    !std::holds_alternative<BitVector>(right->second.storage()))
                    return {PTO_STATUS_MIR_INVALID, PTO_STEP_UNSUPPORTED};
                try {
                    frame.typed_locals.insert_or_assign(
                        instruction.local,
                        Value(std::get<BitVector>(left->second.storage()).BitAnd(
                            std::get<BitVector>(right->second.storage()))));
                } catch (const std::invalid_argument &) {
                    return {PTO_STATUS_MIR_INVALID, PTO_STEP_UNSUPPORTED};
                }
                break;
            }
            case OpCode::kBitConcat: {
                const auto left = frame.typed_locals.find(instruction.binding);
                const auto right = frame.typed_locals.find(
                    static_cast<std::uint32_t>(instruction.address));
                if (left == frame.typed_locals.end() || right == frame.typed_locals.end() ||
                    !std::holds_alternative<BitVector>(left->second.storage()) ||
                    !std::holds_alternative<BitVector>(right->second.storage()))
                    return {PTO_STATUS_MIR_INVALID, PTO_STEP_UNSUPPORTED};
                try {
                    frame.typed_locals.insert_or_assign(
                        instruction.local,
                        Value(std::get<BitVector>(left->second.storage()).Concat(
                            std::get<BitVector>(right->second.storage()))));
                } catch (const std::invalid_argument &) {
                    return {PTO_STATUS_RESOURCE_LIMIT, PTO_STEP_UNSUPPORTED};
                }
                break;
            }
            case OpCode::kBitXor: {
                const auto left = frame.typed_locals.find(instruction.binding);
                const auto right = frame.typed_locals.find(
                    static_cast<std::uint32_t>(instruction.address));
                if (left == frame.typed_locals.end() || right == frame.typed_locals.end() ||
                    !std::holds_alternative<BitVector>(left->second.storage()) ||
                    !std::holds_alternative<BitVector>(right->second.storage()))
                    return {PTO_STATUS_MIR_INVALID, PTO_STEP_UNSUPPORTED};
                try {
                    frame.typed_locals.insert_or_assign(
                        instruction.local,
                        Value(std::get<BitVector>(left->second.storage()).BitXor(
                            std::get<BitVector>(right->second.storage()))));
                } catch (const std::invalid_argument &) {
                    return {PTO_STATUS_MIR_INVALID, PTO_STEP_UNSUPPORTED};
                }
                break;
            }
            case OpCode::kBitNot: {
                const auto value = frame.typed_locals.find(instruction.binding);
                if (value == frame.typed_locals.end())
                    return {PTO_STATUS_MIR_INVALID, PTO_STEP_UNSUPPORTED};
                if (const auto *boolean = std::get_if<bool>(&value->second.storage())) {
                    frame.typed_locals.insert_or_assign(
                        instruction.local, Value(!*boolean));
                    break;
                }
                if (!std::holds_alternative<BitVector>(value->second.storage()))
                    return {PTO_STATUS_MIR_INVALID, PTO_STEP_UNSUPPORTED};
                frame.typed_locals.insert_or_assign(
                    instruction.local,
                    Value(std::get<BitVector>(value->second.storage()).BitNot()));
                break;
            }
            case OpCode::kGetArray: {
                const auto base = frame.typed_locals.find(instruction.binding);
                const auto index = frame.typed_locals.find(
                    static_cast<std::uint32_t>(instruction.address));
                std::uint64_t array_index = 0;
                if (base == frame.typed_locals.end() ||
                    index == frame.typed_locals.end() ||
                    !std::holds_alternative<std::shared_ptr<PagedLazyArray>>(
                        base->second.storage()) ||
                    !std::holds_alternative<BigInteger>(index->second.storage()) ||
                    !std::get<BigInteger>(index->second.storage()).TryToU64(&array_index))
                    return {PTO_STATUS_MIR_INVALID, PTO_STEP_UNSUPPORTED};
                frame.typed_locals.insert_or_assign(
                    instruction.local,
                    std::get<std::shared_ptr<PagedLazyArray>>(
                        base->second.storage())->Get(array_index).Clone());
                break;
            }
            case OpCode::kGetTuple: {
                const auto base = frame.typed_locals.find(instruction.binding);
                if (base == frame.typed_locals.end() ||
                    !std::holds_alternative<std::shared_ptr<TupleValue>>(
                        base->second.storage()))
                    return {PTO_STATUS_MIR_INVALID, PTO_STEP_UNSUPPORTED};
                const auto &tuple = *std::get<std::shared_ptr<TupleValue>>(
                    base->second.storage());
                if (instruction.immediate >= tuple.size())
                    return {PTO_STATUS_MIR_INVALID, PTO_STEP_UNSUPPORTED};
                frame.typed_locals.insert_or_assign(
                    instruction.local,
                    tuple[static_cast<std::size_t>(instruction.immediate)].Clone());
                break;
            }
            case OpCode::kSetArray: {
                const auto base = frame.typed_locals.find(instruction.local);
                const auto index = frame.typed_locals.find(instruction.binding);
                const auto value = frame.typed_locals.find(
                    static_cast<std::uint32_t>(instruction.address));
                std::uint64_t array_index = 0;
                if (base == frame.typed_locals.end() ||
                    index == frame.typed_locals.end() ||
                    value == frame.typed_locals.end() ||
                    !std::holds_alternative<std::shared_ptr<PagedLazyArray>>(
                        base->second.storage()) ||
                    !std::holds_alternative<BigInteger>(index->second.storage()) ||
                    !std::get<BigInteger>(index->second.storage()).TryToU64(&array_index))
                    return {PTO_STATUS_MIR_INVALID, PTO_STEP_UNSUPPORTED};
                Value updated = base->second.Clone();
                std::get<std::shared_ptr<PagedLazyArray>>(updated.storage())->Set(
                    array_index, value->second.Clone());
                frame.typed_locals.insert_or_assign(
                    instruction.local, std::move(updated));
                break;
            }
            case OpCode::kGetField: {
                const auto base = frame.typed_locals.find(instruction.binding);
                if (base == frame.typed_locals.end() ||
                    !std::holds_alternative<std::shared_ptr<RecordValue>>(
                        base->second.storage()))
                    return {PTO_STATUS_MIR_INVALID, PTO_STEP_UNSUPPORTED};
                const auto &record = *std::get<std::shared_ptr<RecordValue>>(
                    base->second.storage());
                const auto field = record.find(
                    static_cast<std::uint32_t>(instruction.immediate));
                if (field == record.end())
                    return {PTO_STATUS_MIR_INVALID, PTO_STEP_UNSUPPORTED};
                frame.typed_locals.insert_or_assign(
                    instruction.local, field->second.Clone());
                break;
            }
            case OpCode::kCreateArray: {
                const auto value = frame.typed_locals.find(instruction.binding);
                const auto length = frame.typed_locals.find(
                    static_cast<std::uint32_t>(instruction.address));
                std::uint64_t length_value = 0;
                if (value == frame.typed_locals.end() ||
                    length == frame.typed_locals.end() ||
                    !std::holds_alternative<BigInteger>(length->second.storage()) ||
                    !std::get<BigInteger>(length->second.storage())
                         .TryToU64(&length_value) ||
                    length_value > (UINT64_C(1) << 20))
                    return {PTO_STATUS_RESOURCE_LIMIT, PTO_STEP_UNSUPPORTED};
                const Value default_value = value->second.Clone();
                frame.typed_locals.insert_or_assign(
                    instruction.local,
                    Value(std::make_shared<PagedLazyArray>(
                        [default_value](std::uint64_t) {
                            return default_value.Clone();
                        })));
                break;
            }
            case OpCode::kCreateTuple:
                frame.typed_locals.insert_or_assign(
                    instruction.local, Value(TupleValue{}));
                break;
            case OpCode::kAppendTuple: {
                const auto tuple = frame.typed_locals.find(instruction.local);
                const auto value = frame.typed_locals.find(instruction.binding);
                if (tuple == frame.typed_locals.end() ||
                    value == frame.typed_locals.end() ||
                    !std::holds_alternative<std::shared_ptr<TupleValue>>(
                        tuple->second.storage()))
                    return {PTO_STATUS_MIR_INVALID, PTO_STEP_UNSUPPORTED};
                Value updated = tuple->second.Clone();
                std::get<std::shared_ptr<TupleValue>>(updated.storage())
                    ->push_back(value->second.Clone());
                frame.typed_locals.insert_or_assign(
                    instruction.local, std::move(updated));
                break;
            }
            case OpCode::kSetField: {
                const auto base = frame.typed_locals.find(instruction.local);
                const auto value = frame.typed_locals.find(instruction.binding);
                if (base == frame.typed_locals.end() ||
                    value == frame.typed_locals.end() ||
                    !std::holds_alternative<std::shared_ptr<RecordValue>>(
                        base->second.storage()))
                    return {PTO_STATUS_MIR_INVALID, PTO_STEP_UNSUPPORTED};
                Value updated = base->second.Clone();
                auto &record = *std::get<std::shared_ptr<RecordValue>>(
                    updated.storage());
                const std::uint32_t field_id =
                    static_cast<std::uint32_t>(instruction.immediate);
                if (record.find(field_id) == record.end())
                    return {PTO_STATUS_MIR_INVALID, PTO_STEP_UNSUPPORTED};
                record.insert_or_assign(field_id, value->second.Clone());
                frame.typed_locals.insert_or_assign(
                    instruction.local, std::move(updated));
                break;
            }
            case OpCode::kCreateRecord:
                frame.typed_locals.insert_or_assign(
                    instruction.local, Value(RecordValue{}));
                break;
            case OpCode::kInsertField: {
                const auto base = frame.typed_locals.find(instruction.local);
                const auto value = frame.typed_locals.find(instruction.binding);
                if (base == frame.typed_locals.end() ||
                    value == frame.typed_locals.end() ||
                    !std::holds_alternative<std::shared_ptr<RecordValue>>(
                        base->second.storage()))
                    return {PTO_STATUS_MIR_INVALID, PTO_STEP_UNSUPPORTED};
                auto &record = *std::get<std::shared_ptr<RecordValue>>(
                    base->second.mutable_storage());
                record.insert_or_assign(
                    static_cast<std::uint32_t>(instruction.immediate),
                    value->second.Clone());
                break;
            }
            case OpCode::kSetSlice: {
                const auto base = frame.typed_locals.find(instruction.local);
                const auto value = frame.typed_locals.find(instruction.binding);
                if (base == frame.typed_locals.end() ||
                    value == frame.typed_locals.end() ||
                    !std::holds_alternative<BitVector>(base->second.storage()) ||
                    !std::holds_alternative<BitVector>(value->second.storage()))
                    return {PTO_STATUS_MIR_INVALID, PTO_STEP_UNSUPPORTED};
                Value updated = base->second.Clone();
                try {
                    std::get<BitVector>(updated.mutable_storage()).SetSlice(
                        static_cast<std::size_t>(instruction.immediate),
                        static_cast<std::size_t>(instruction.address),
                        std::get<BitVector>(value->second.storage()));
                } catch (const std::out_of_range &) {
                    return {PTO_STATUS_MIR_INVALID, PTO_STEP_UNSUPPORTED};
                }
                frame.typed_locals.insert_or_assign(
                    instruction.local, std::move(updated));
                break;
            }
            case OpCode::kCheckBitWidth: {
                const auto value = frame.typed_locals.find(instruction.local);
                if (value == frame.typed_locals.end() ||
                    !std::holds_alternative<BitVector>(value->second.storage()) ||
                    std::get<BitVector>(value->second.storage()).width() !=
                        instruction.immediate)
                    return {PTO_STATUS_MIR_INVALID, PTO_STEP_UNSUPPORTED};
                break;
            }
            case OpCode::kDynamicSetSlice: {
                const auto base = frame.typed_locals.find(instruction.local);
                const auto value = frame.typed_locals.find(instruction.binding);
                const auto start_value = frame.typed_locals.find(
                    static_cast<std::uint32_t>(instruction.immediate));
                const auto width_value = frame.typed_locals.find(
                    static_cast<std::uint32_t>(instruction.address));
                std::uint64_t start = 0, width = 0;
                if (base == frame.typed_locals.end() ||
                    value == frame.typed_locals.end() ||
                    start_value == frame.typed_locals.end() ||
                    width_value == frame.typed_locals.end() ||
                    !std::holds_alternative<BitVector>(base->second.storage()) ||
                    !std::holds_alternative<BitVector>(value->second.storage()) ||
                    !std::holds_alternative<BigInteger>(start_value->second.storage()) ||
                    !std::holds_alternative<BigInteger>(width_value->second.storage()) ||
                    !std::get<BigInteger>(start_value->second.storage()).TryToU64(&start) ||
                    !std::get<BigInteger>(width_value->second.storage()).TryToU64(&width))
                    return {PTO_STATUS_MIR_INVALID, PTO_STEP_UNSUPPORTED};
                Value updated = base->second.Clone();
                try {
                    std::get<BitVector>(updated.mutable_storage()).SetSlice(
                        static_cast<std::size_t>(start),
                        static_cast<std::size_t>(width),
                        std::get<BitVector>(value->second.storage()));
                } catch (const std::out_of_range &) {
                    return {PTO_STATUS_MIR_INVALID, PTO_STEP_UNSUPPORTED};
                }
                frame.typed_locals.insert_or_assign(
                    instruction.local, std::move(updated));
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
            case OpCode::kUnsupportedNode:
                return {PTO_STATUS_MIR_INVALID, PTO_STEP_UNSUPPORTED,
                        std::nullopt, function.id, instruction.local,
                        static_cast<std::uint32_t>(instruction.immediate)};
        }
        ++pc;
    }
    return {PTO_STATUS_MIR_INVALID, PTO_STEP_UNSUPPORTED};
}

}  // namespace pto::model

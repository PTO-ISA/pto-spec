#include "module.h"

#include "pto/pto_asl_model.h"

#include <algorithm>
#include <deque>
#include <unordered_set>
#include <utility>
#include <vector>

namespace pto::model {

std::shared_ptr<const Module> Module::Create(std::vector<Function> functions,
                                             BindingId step_entrypoint,
                                             std::string *error,
                                             std::vector<ExternDefinition> externs,
                                             std::vector<GlobalDefinition> globals) {
    constexpr std::size_t kMaximumFunctions = 8192;
    constexpr std::size_t kMaximumInstructions = 1U << 20;
    if (functions.size() > kMaximumFunctions) {
        if (error != nullptr) {
            *error = "module exceeds the function resource limit";
        }
        return nullptr;
    }
    std::unordered_set<BindingId> ids;
    std::size_t instruction_count = 0;
    for (const Function &function : functions) {
        if (!ids.insert(function.id).second) {
            if (error != nullptr) {
                *error = "module contains a zero or duplicate function binding";
            }
            return nullptr;
        }
        instruction_count += function.instructions.size();
        if (instruction_count > kMaximumInstructions ||
            function.instructions.empty()) {
            if (error != nullptr) {
                *error = "module has an empty function or exceeds the instruction limit";
            }
            return nullptr;
        }
        for (std::size_t index = 0; index < function.instructions.size(); ++index) {
            const Instruction &instruction = function.instructions[index];
            switch (instruction.opcode) {
                case OpCode::kSetLocalU64:
                case OpCode::kAddLocalU64:
                case OpCode::kWriteMemoryImmediate:
                case OpCode::kLoadArgumentBits:
                case OpCode::kLoadArgumentInteger:
                case OpCode::kLoadArgumentValue:
                case OpCode::kLoadArgumentEnum:
                case OpCode::kLoadArgumentBool:
                case OpCode::kLoadBitsImmediate:
                case OpCode::kLoadIntegerImmediate:
                case OpCode::kLoadIntegerNegative:
                case OpCode::kSliceBits:
                case OpCode::kDynamicSlice:
                case OpCode::kEqual:
                case OpCode::kNotEqual:
                case OpCode::kAssertTrue:
                case OpCode::kPushArgument:
                case OpCode::kCopyValue:
                case OpCode::kLoadGlobal:
                case OpCode::kLoadBool:
                case OpCode::kLoadEnum:
                    break;
                case OpCode::kStoreGlobal:
                case OpCode::kIntegerAdd:
                case OpCode::kIntegerSubtract:
                case OpCode::kIntegerMultiply:
                case OpCode::kIntegerDivide:
                case OpCode::kBitOr:
                case OpCode::kBitAnd:
                case OpCode::kBitConcat:
                case OpCode::kBitXor:
                case OpCode::kBitNot:
                case OpCode::kIntegerLessEqual:
                case OpCode::kIntegerGreaterEqual:
                case OpCode::kIntegerLess:
                case OpCode::kIntegerGreater:
                case OpCode::kIntegerStep:
                case OpCode::kGetArray:
                case OpCode::kSetArray:
                case OpCode::kGetField:
                case OpCode::kSetField:
                case OpCode::kCreateRecord:
                case OpCode::kInsertField:
                case OpCode::kSetSlice:
                case OpCode::kDynamicSetSlice:
                case OpCode::kCheckBitWidth:
                    break;
                case OpCode::kCallValue:
                case OpCode::kCallProcedure:
                case OpCode::kCallExtern:
                    break;
                case OpCode::kStoreLocalToGlobal:
                case OpCode::kIncrementGlobalU64:
                case OpCode::kReadMemoryToGlobal:
                    if (instruction.binding == 0) {
                        if (error != nullptr) {
                            *error = "module instruction has a zero value binding";
                        }
                        return nullptr;
                    }
                    break;
                case OpCode::kProbeMemory:
                    if (instruction.local == 0 ||
                        instruction.immediate < PTO_MEMORY_ACCESS_FETCH ||
                        instruction.immediate > PTO_MEMORY_ACCESS_WRITE) {
                        if (error != nullptr) {
                            *error = "module memory probe is malformed";
                        }
                        return nullptr;
                    }
                    break;
                case OpCode::kBranchIfFalse:
                case OpCode::kJump:
                    if (instruction.address >= function.instructions.size()) {
                        if (error != nullptr) {
                            *error = "module branch target is out of range";
                        }
                        return nullptr;
                    }
                    break;
                case OpCode::kReturnValue:
                case OpCode::kReturnProcedure:
                case OpCode::kReturnExecuted:
                case OpCode::kReturnTrap:
                case OpCode::kReturnHostRequest:
                case OpCode::kUnsupportedNode:
                    break;
                default:
                    if (error != nullptr) {
                        *error = "module contains an unknown opcode";
                    }
                    return nullptr;
            }
        }
        std::vector<bool> reachable(function.instructions.size(), false);
        std::deque<std::size_t> pending{0};
        while (!pending.empty()) {
            const std::size_t index = pending.front();
            pending.pop_front();
            if (reachable[index]) {
                continue;
            }
            reachable[index] = true;
            const Instruction &instruction = function.instructions[index];
            if (instruction.opcode == OpCode::kReturnValue ||
                instruction.opcode == OpCode::kReturnProcedure ||
                instruction.opcode == OpCode::kReturnExecuted ||
                instruction.opcode == OpCode::kReturnTrap ||
                instruction.opcode == OpCode::kReturnHostRequest) {

                continue;
            }
            if (instruction.opcode == OpCode::kJump) {
                pending.push_back(static_cast<std::size_t>(instruction.address));
                continue;
            }
            if (instruction.opcode == OpCode::kUnsupportedNode &&
                instruction.address == 1) continue;
            if (index + 1 >= function.instructions.size()) {
                if (error != nullptr) {
                    *error = "module function has a reachable fallthrough exit: " +
                             std::to_string(function.id);
                }
                return nullptr;
            }
            pending.push_back(index + 1);
            if (instruction.opcode == OpCode::kBranchIfFalse) {
                pending.push_back(static_cast<std::size_t>(instruction.address));
            }
        }
        if (!std::all_of(reachable.begin(), reachable.end(),
                         [](bool value) { return value; })) {
            if (error != nullptr) {
                *error = "module function contains unreachable bytecode";
            }
            return nullptr;
        }
    }
    if (step_entrypoint == 0 || ids.find(step_entrypoint) == ids.end()) {
        if (error != nullptr) {
            *error = "module step entrypoint is unresolved";
        }
        return nullptr;
    }
    for (const Function &function : functions) {
        for (const Instruction &instruction : function.instructions) {
            if ((instruction.opcode == OpCode::kCallValue ||
                 instruction.opcode == OpCode::kCallProcedure) &&
                ids.find(instruction.binding) == ids.end()) {
                if (error != nullptr) {
                    *error = "module call has an unresolved numeric target";
                }
                return nullptr;
            }
            if (instruction.opcode == OpCode::kCallExtern) {
                const auto target = std::find_if(
                    externs.begin(), externs.end(),
                    [&instruction](const ExternDefinition &candidate) {
                        return candidate.id == instruction.binding;
                    });
                if (target == externs.end() ||
                    target->argument_count != instruction.immediate) {
                    if (error != nullptr) {
                        *error = "module extern call is unresolved or has wrong arity";
                    }
                    return nullptr;
                }
            }
            if (instruction.opcode == OpCode::kCallValue ||
                instruction.opcode == OpCode::kCallProcedure) {
                const auto target = std::find_if(
                    functions.begin(), functions.end(),
                    [&instruction](const Function &candidate) {
                        return candidate.id == instruction.binding;
                    });
                if (target == functions.end() ||
                    target->argument_count != instruction.immediate) {
                    if (error != nullptr) {
                        *error = "module call arity does not match numeric target";
                    }
                    return nullptr;
                }
            }
        }
    }
    return std::shared_ptr<const Module>(
        new Module(std::move(functions), step_entrypoint, std::move(externs),
                   std::move(globals)));
}

Module::Module(std::vector<Function> functions,
               BindingId step_entrypoint,
               std::vector<ExternDefinition> externs,
               std::vector<GlobalDefinition> globals)
    : functions_(std::move(functions)),
      step_entrypoint_(step_entrypoint),
      externs_(std::move(externs)),
      globals_(std::move(globals)) {
    for (std::size_t index = 0; index < functions_.size(); ++index) {
        function_indices_.emplace(functions_[index].id, index);
    }
}

const Function *Module::FindFunction(BindingId id) const {
    const auto found = function_indices_.find(id);
    return found == function_indices_.end() ? nullptr
                                            : &functions_[found->second];
}

BindingId Module::step_entrypoint() const { return step_entrypoint_; }

const ExternDefinition *Module::FindExtern(BindingId id) const {
    const auto found = std::find_if(
        externs_.begin(), externs_.end(),
        [id](const ExternDefinition &candidate) { return candidate.id == id; });
    return found == externs_.end() ? nullptr : &*found;
}

const std::vector<GlobalDefinition> &Module::globals() const { return globals_; }

}  // namespace pto::model

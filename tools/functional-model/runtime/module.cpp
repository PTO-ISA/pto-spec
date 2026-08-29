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
                                             std::string *error) {
    constexpr std::size_t kMaximumFunctions = 4096;
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
        if (function.id == 0 || !ids.insert(function.id).second) {
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
                case OpCode::kLoadBitsImmediate:
                case OpCode::kLoadIntegerImmediate:
                case OpCode::kSliceBits:
                case OpCode::kEqual:
                case OpCode::kNotEqual:
                case OpCode::kAssertTrue:
                case OpCode::kPushArgument:
                case OpCode::kCopyValue:
                case OpCode::kLoadGlobal:
                case OpCode::kLoadBool:
                    break;
                case OpCode::kStoreGlobal:
                    break;
                case OpCode::kCallValue:
                case OpCode::kCallProcedure:
                    if (instruction.binding == 0) {
                        if (error != nullptr) {
                            *error = "module call has a zero numeric target";
                        }
                        return nullptr;
                    }
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
            if (index + 1 >= function.instructions.size()) {
                if (error != nullptr) {
                    *error = "module function has a reachable fallthrough exit";
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
        }
    }
    return std::shared_ptr<const Module>(
        new Module(std::move(functions), step_entrypoint));
}

Module::Module(std::vector<Function> functions, BindingId step_entrypoint)
    : functions_(std::move(functions)), step_entrypoint_(step_entrypoint) {
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

}  // namespace pto::model

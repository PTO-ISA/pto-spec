#include "module.h"

#include "pto/pto_asl_model.h"

#include <unordered_set>
#include <utility>

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
            const bool is_last = index + 1 == function.instructions.size();
            switch (instruction.opcode) {
                case OpCode::kSetLocalU64:
                case OpCode::kAddLocalU64:
                case OpCode::kWriteMemoryImmediate:
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
                case OpCode::kReturnExecuted:
                case OpCode::kReturnTrap:
                case OpCode::kReturnHostRequest:
                    if (!is_last) {
                        if (error != nullptr) {
                            *error = "module function has an early terminal opcode";
                        }
                        return nullptr;
                    }
                    break;
                default:
                    if (error != nullptr) {
                        *error = "module contains an unknown opcode";
                    }
                    return nullptr;
            }
        }
        const OpCode terminal = function.instructions.back().opcode;
        if (terminal != OpCode::kReturnExecuted &&
            terminal != OpCode::kReturnTrap &&
            terminal != OpCode::kReturnHostRequest) {
            if (error != nullptr) {
                *error = "module function has no terminal opcode";
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

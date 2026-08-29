#ifndef PTO_FUNCTIONAL_MODEL_MODULE_H
#define PTO_FUNCTIONAL_MODEL_MODULE_H

#include <cstdint>
#include <memory>
#include <string>
#include <unordered_map>
#include <vector>

namespace pto::model {

using BindingId = std::uint32_t;

namespace binding {
inline constexpr BindingId kResetEntrypoint = 1;
inline constexpr BindingId kStepEntrypoint = 2;
inline constexpr BindingId kCompleteHostRequestEntrypoint = 3;
inline constexpr BindingId kReadPhysicalMemoryByte = 0x100;
inline constexpr BindingId kWritePhysicalMemoryByte = 0x101;
inline constexpr BindingId kResetPhysicalMemory = 0x102;
}  // namespace binding

enum class ExternKind : std::uint8_t { kUInt, kSInt };

struct ExternDefinition {
    BindingId id;
    ExternKind kind;
    std::uint32_t argument_count;
};

enum class OpCode : std::uint8_t {
    kSetLocalU64,
    kAddLocalU64,
    kStoreLocalToGlobal,
    kIncrementGlobalU64,
    kProbeMemory,
    kWriteMemoryImmediate,
    kReadMemoryToGlobal,
    kLoadArgumentBits,
    kLoadBitsImmediate,
    kLoadIntegerImmediate,
    kSliceBits,
    kEqual,
    kNotEqual,
    kAssertTrue,
    kPushArgument,
    kCallValue,
    kCallProcedure,
    kCallExtern,
    kCopyValue,
    kLoadGlobal,
    kLoadBool,
    kLoadEnum,
    kStoreGlobal,
    kIntegerAdd,
    kIntegerSubtract,
    kIntegerMultiply,
    kIntegerLessEqual,
    kIntegerGreaterEqual,
    kIntegerStep,
    kGetArray,
    kSetArray,
    kGetField,
    kSetField,
    kSetSlice,
    kCheckBitWidth,
    kBranchIfFalse,
    kJump,
    kReturnValue,
    kReturnProcedure,
    kReturnExecuted,
    kReturnTrap,
    kReturnHostRequest
};

struct Instruction {
    OpCode opcode;
    BindingId binding = 0;
    std::uint32_t local = 0;
    std::uint64_t immediate = 0;
    std::uint64_t address = 0;
};

struct Function {
    BindingId id;
    std::vector<Instruction> instructions;
    std::uint32_t argument_count = 0;
};

class Module final {
  public:
    static std::shared_ptr<const Module> Create(
        std::vector<Function> functions,
        BindingId step_entrypoint,
        std::string *error,
        std::vector<ExternDefinition> externs = {});

    const Function *FindFunction(BindingId id) const;
    BindingId step_entrypoint() const;
    const ExternDefinition *FindExtern(BindingId id) const;

  private:
    Module(std::vector<Function> functions,
           BindingId step_entrypoint,
           std::vector<ExternDefinition> externs);
    std::vector<Function> functions_;
    std::unordered_map<BindingId, std::size_t> function_indices_;
    BindingId step_entrypoint_;
    std::vector<ExternDefinition> externs_;
};

}  // namespace pto::model

#endif

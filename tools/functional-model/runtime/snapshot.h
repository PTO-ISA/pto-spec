#ifndef PTO_FUNCTIONAL_MODEL_SNAPSHOT_H
#define PTO_FUNCTIONAL_MODEL_SNAPSHOT_H

#include "interpreter.h"

#include <array>
#include <cstddef>
#include <cstdint>
#include <string>
#include <vector>

namespace pto::model {

inline constexpr std::uint32_t kSnapshotSchemaVersion = 1;
inline constexpr std::size_t kSnapshotHeaderSize = 96;
inline constexpr std::size_t kSnapshotMaximumSize = 256U * 1024U * 1024U;

pto_status_t EncodeSnapshot(const RuntimeState &state,
                            std::vector<std::uint8_t> *snapshot,
                            std::string *error);
pto_status_t DecodeSnapshot(const std::uint8_t *snapshot,
                            std::size_t snapshot_size,
                            const RuntimeState &prototype, RuntimeState *state,
                            std::string *error);
pto_status_t DigestStateBindings(const RuntimeState &state,
                                 const std::vector<BindingId> &bindings,
                                 std::array<std::uint8_t, 32> *digest,
                                 std::string *error);

} // namespace pto::model

#endif

#ifndef PTO_FUNCTIONAL_MODEL_TRACE_DIGEST_H
#define PTO_FUNCTIONAL_MODEL_TRACE_DIGEST_H

#include "transaction.h"

#include <array>
#include <cstddef>
#include <cstdint>
#include <vector>

namespace pto::model {

std::array<std::uint8_t, 32> Sha256Bytes(const std::uint8_t *data,
                                         std::size_t size);

std::array<std::uint8_t, 32>
DigestMemoryWrites(const std::vector<MemoryWrite> &writes);

} // namespace pto::model

#endif

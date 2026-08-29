#include "transaction.h"

#include <algorithm>

namespace pto::model {

MemoryTransaction::MemoryTransaction(const MemoryCallbacks &callbacks)
    : callbacks_(callbacks) {}

pto_status_t MemoryTransaction::Probe(pto_memory_access_kind_t kind,
                                      std::uint64_t address,
                                      std::uint64_t size,
                                      bool *permitted) const {
    if (!callbacks_.probe || permitted == nullptr) {
        return PTO_STATUS_INVALID_STATE;
    }
    return callbacks_.probe(kind, address, size, permitted);
}

pto_status_t MemoryTransaction::Read(std::uint64_t address,
                                     std::uint8_t *bytes,
                                     std::uint64_t size) const {
    if (bytes == nullptr || !callbacks_.read) {
        return PTO_STATUS_INVALID_STATE;
    }
    for (std::uint64_t offset = 0; offset < size; ++offset) {
        const std::uint64_t current = address + offset;
        const auto found = std::find_if(
            writes_.rbegin(), writes_.rend(),
            [current](const MemoryWrite &write) {
                return write.address == current;
            });
        if (found != writes_.rend()) {
            bytes[offset] = found->value;
            continue;
        }
        const pto_status_t status = callbacks_.read(current, &bytes[offset], 1);
        if (status != PTO_STATUS_OK) {
            return status;
        }
    }
    return PTO_STATUS_OK;
}

void MemoryTransaction::Write(std::uint64_t address, std::uint8_t value) {
    writes_.push_back(MemoryWrite{address, value});
}

pto_status_t MemoryTransaction::Commit() const {
    if (writes_.empty()) {
        return PTO_STATUS_OK;
    }
    if (!callbacks_.commit) {
        return PTO_STATUS_INVALID_STATE;
    }
    return callbacks_.commit(writes_);
}

const std::vector<MemoryWrite> &MemoryTransaction::writes() const {
    return writes_;
}

}  // namespace pto::model

#ifndef PTO_FUNCTIONAL_MODEL_TRANSACTION_H
#define PTO_FUNCTIONAL_MODEL_TRANSACTION_H

#include "pto/pto_asl_model.h"

#include <cstdint>
#include <functional>
#include <vector>

namespace pto::model {

struct MemoryWrite {
    std::uint64_t address;
    std::uint8_t value;
};

struct MemoryCallbacks {
    std::function<pto_status_t()> reset;
    std::function<pto_status_t(pto_memory_access_kind_t,
                               std::uint64_t,
                               std::uint64_t,
                               bool *)>
        probe;
    std::function<pto_status_t(std::uint64_t, std::uint8_t *, std::uint64_t)>
        read;
    std::function<pto_status_t(const std::vector<MemoryWrite> &)> commit;
};

class MemoryTransaction {
  public:
    explicit MemoryTransaction(const MemoryCallbacks &callbacks);
    pto_status_t Probe(pto_memory_access_kind_t kind,
                       std::uint64_t address,
                       std::uint64_t size,
                       bool *permitted) const;
    pto_status_t Read(std::uint64_t address,
                      std::uint8_t *bytes,
                      std::uint64_t size) const;
    void Write(std::uint64_t address, std::uint8_t value);
    pto_status_t Commit() const;
    const std::vector<MemoryWrite> &writes() const;

  private:
    const MemoryCallbacks &callbacks_;
    std::vector<MemoryWrite> writes_;
};

}  // namespace pto::model

#endif

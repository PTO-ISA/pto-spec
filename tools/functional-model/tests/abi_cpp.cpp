#include "pto/pto_asl_model.h"

#include <cassert>
#include <cstdint>
#include <vector>
#include <type_traits>

int main() {
    static_assert(std::is_standard_layout_v<pto_model_config_t>);
    static_assert(std::is_standard_layout_v<pto_step_result_t>);
    assert(pto_model_create(nullptr, nullptr) == PTO_STATUS_INVALID_ARGUMENT);
    std::uint64_t size = 0;
    assert(pto_model_descriptor_json(nullptr, &size) ==
           PTO_STATUS_BUFFER_TOO_SMALL);
    std::vector<char> descriptor(size);
    assert(pto_model_descriptor_json(descriptor.data(), &size) ==
           PTO_STATUS_OK);
    assert(descriptor.back() == '\0');
    assert(descriptor.front() == '{');
    pto_model_destroy(nullptr);
    return 0;
}

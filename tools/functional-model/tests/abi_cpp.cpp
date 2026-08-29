#include "pto/pto_asl_model.h"

#include <cassert>
#include <type_traits>

int main() {
    static_assert(std::is_standard_layout_v<pto_model_config_t>);
    static_assert(std::is_standard_layout_v<pto_step_result_t>);
    assert(pto_model_create(nullptr, nullptr) == PTO_STATUS_INVALID_ARGUMENT);
    pto_model_destroy(nullptr);
    return 0;
}

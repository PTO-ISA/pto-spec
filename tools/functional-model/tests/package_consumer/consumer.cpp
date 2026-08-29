#include <pto/pto_asl_model.h>

#include <cassert>
#include <cstdint>
#include <vector>

int main() {
    std::uint64_t size = 0;
    assert(pto_model_descriptor_json(nullptr, &size) ==
           PTO_STATUS_BUFFER_TOO_SMALL);
    std::vector<char> descriptor(size);
    assert(pto_model_descriptor_json(descriptor.data(), &size) == PTO_STATUS_OK);
    assert(descriptor.front() == '{');
    assert(descriptor.back() == '\0');
    return 0;
}

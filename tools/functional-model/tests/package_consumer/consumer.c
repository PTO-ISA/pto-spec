#include <pto/pto_asl_model.h>

#include <assert.h>
#include <stdint.h>
#include <string.h>

typedef struct {
    uint8_t bytes[512];
} memory_t;

static pto_status_t reset_memory(void *user_data) {
    memset(user_data, 0, sizeof(memory_t));
    return PTO_STATUS_OK;
}

static pto_status_t probe_memory(void *user_data,
                                 pto_memory_access_kind_t kind,
                                 uint64_t address,
                                 uint64_t size,
                                 uint8_t *out_permitted) {
    (void)user_data;
    (void)kind;
    *out_permitted = address <= sizeof(memory_t) &&
                     size <= sizeof(memory_t) - address;
    return PTO_STATUS_OK;
}

static pto_status_t read_memory(void *user_data,
                                uint64_t address,
                                uint8_t *out_bytes,
                                uint64_t size) {
    memory_t *memory = (memory_t *)user_data;
    memcpy(out_bytes, memory->bytes + address, (size_t)size);
    return PTO_STATUS_OK;
}

static pto_status_t commit_memory(void *user_data,
                                  const pto_memory_write_t *writes,
                                  uint64_t count) {
    memory_t *memory = (memory_t *)user_data;
    uint64_t index;
    for (index = 0; index < count; ++index)
        memory->bytes[writes[index].address] = writes[index].value;
    return PTO_STATUS_OK;
}

int main(void) {
    memory_t memory = {{0}};
    pto_model_config_t config = {0};
    config.abi_version = PTO_ASL_MODEL_EXPERIMENTAL_ABI_VERSION;
    config.struct_size = sizeof(config);
    config.memory.abi_version = PTO_ASL_MODEL_EXPERIMENTAL_ABI_VERSION;
    config.memory.struct_size = sizeof(config.memory);
    config.memory.user_data = &memory;
    config.memory.reset = reset_memory;
    config.memory.probe = probe_memory;
    config.memory.read = read_memory;
    config.memory.commit = commit_memory;
    uint64_t digest_size = sizeof(config.expected_descriptor_sha256);
    assert(pto_model_descriptor_sha256(config.expected_descriptor_sha256,
                                       &digest_size) == PTO_STATUS_OK);

    pto_model_t *model = NULL;
    assert(pto_model_create(&config, &model) == PTO_STATUS_OK);
    pto_initial_state_t initial = {0};
    initial.abi_version = PTO_ASL_MODEL_EXPERIMENTAL_ABI_VERSION;
    initial.struct_size = sizeof(initial);
    initial.entry_tpc = 0x100;
    assert(pto_model_reset(model, &initial) == PTO_STATUS_OK);
    memory.bytes[0x100] = 0x16;
    memory.bytes[0x101] = 0x14;

    pto_step_result_t result = {0};
    result.abi_version = PTO_ASL_MODEL_EXPERIMENTAL_ABI_VERSION;
    result.struct_size = sizeof(result);
    assert(pto_model_step(model, &result) == PTO_STATUS_OK);
    assert(result.step_state == PTO_STEP_EXECUTED);
    assert(result.instruction_status == PTO_INSTRUCTION_EXECUTED);
    assert(result.raw_instruction_le == UINT64_C(0x1416));
    assert(result.length_bits == 16);
    assert(result.pre_tpc == UINT64_C(0x100));
    assert(result.post_tpc == UINT64_C(0x102));
    pto_model_destroy(model);
    return 0;
}

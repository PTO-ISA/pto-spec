#include "pto/pto_asl_model.h"

#include <assert.h>
#include <stdio.h>
#include <string.h>

static pto_status_t reset_memory(void *user_data) {
    memset(user_data, 0, 16);
    return PTO_STATUS_OK;
}

static pto_status_t probe_memory(void *user_data,
                                 pto_memory_access_kind_t kind,
                                 uint64_t address,
                                 uint64_t size,
                                 uint8_t *out_permitted) {
    (void)user_data;
    (void)kind;
    *out_permitted = address <= 16 && size <= 16 - address;
    return PTO_STATUS_OK;
}

static pto_status_t read_memory(void *user_data,
                                uint64_t address,
                                uint8_t *out_bytes,
                                uint64_t size) {
    memcpy(out_bytes, (uint8_t *)user_data + address, (size_t)size);
    return PTO_STATUS_OK;
}

static pto_status_t commit_memory(void *user_data,
                                  const pto_memory_write_t *writes,
                                  uint64_t write_count) {
    uint8_t *memory = (uint8_t *)user_data;
    uint64_t index;
    for (index = 0; index < write_count; ++index) {
        memory[writes[index].address] = writes[index].value;
    }
    return PTO_STATUS_OK;
}

int main(void) {
    uint8_t memory[16] = {0};
    pto_model_config_t config = {0};
    config.abi_version = PTO_ASL_MODEL_EXPERIMENTAL_ABI_VERSION;
    config.struct_size = sizeof(config);
    config.memory.abi_version = PTO_ASL_MODEL_EXPERIMENTAL_ABI_VERSION;
    config.memory.struct_size = sizeof(config.memory);
    config.memory.user_data = memory;
    config.memory.reset = reset_memory;
    config.memory.probe = probe_memory;
    config.memory.read = read_memory;
    config.memory.commit = commit_memory;

    pto_model_t *model = NULL;
    assert(pto_model_create(&config, &model) == PTO_STATUS_OK);
    assert(model != NULL);

    pto_initial_state_t initial = {0};
    initial.abi_version = PTO_ASL_MODEL_EXPERIMENTAL_ABI_VERSION;
    initial.struct_size = sizeof(initial);
    initial.entry_tpc = 0x100;
    pto_status_t reset_status = pto_model_reset(model, &initial);
    if (reset_status != PTO_STATUS_OK) {
        uint64_t diagnostic_size = 0;
        (void)pto_model_last_error(model, NULL, &diagnostic_size);
        char diagnostic[256] = {0};
        if (diagnostic_size <= sizeof(diagnostic))
            (void)pto_model_last_error(model, diagnostic, &diagnostic_size);
        fprintf(stderr, "reset status=%u: %s\n", reset_status, diagnostic);
    }
    assert(reset_status == PTO_STATUS_OK);

    pto_step_result_t result = {0};
    result.abi_version = PTO_ASL_MODEL_EXPERIMENTAL_ABI_VERSION;
    result.struct_size = sizeof(result);
    assert(pto_model_step(model, &result) == PTO_STATUS_MIR_INVALID);
    assert(result.step_state == PTO_STEP_UNSUPPORTED);
    uint64_t error_size = 0;
    assert(pto_model_last_error(model, NULL, &error_size) ==
           PTO_STATUS_BUFFER_TOO_SMALL);
    assert(error_size > 1 && error_size < 128);
    char error_buffer[128];
    assert(pto_model_last_error(model, error_buffer, &error_size) ==
           PTO_STATUS_OK);
    assert(error_buffer[0] != '\0');

    result.struct_size -= 1;
    assert(pto_model_step(model, &result) == PTO_STATUS_ABI_MISMATCH);

    initial.pe0_gpr_valid_mask = 1;
    reset_status = pto_model_reset(model, &initial);
    if (reset_status != PTO_STATUS_OK) {
        uint64_t size = sizeof(error_buffer);
        (void)pto_model_last_error(model, error_buffer, &size);
        fprintf(stderr, "GPR reset status=%u: %s\n", reset_status, error_buffer);
    }
    assert(reset_status == PTO_STATUS_OK);

    config.abi_version = 0;
    pto_model_t *invalid = NULL;
    assert(pto_model_create(&config, &invalid) == PTO_STATUS_ABI_MISMATCH);
    assert(invalid == NULL);
    config.abi_version = PTO_ASL_MODEL_EXPERIMENTAL_ABI_VERSION;
    config.struct_size -= 1;
    assert(pto_model_create(&config, &invalid) == PTO_STATUS_ABI_MISMATCH);
    pto_model_destroy(model);
    return 0;
}

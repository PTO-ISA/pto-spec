#include "pto/pto_asl_model.h"

#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
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
    uint64_t descriptor_size = 0;
    uint64_t digest_size = 0;
    assert(pto_model_descriptor_json(NULL, &descriptor_size) ==
           PTO_STATUS_BUFFER_TOO_SMALL);
    assert(descriptor_size > 1);
    assert(pto_model_descriptor_sha256(NULL, &digest_size) ==
           PTO_STATUS_BUFFER_TOO_SMALL);
    assert(digest_size == 32);

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

    pto_model_t *invalid = NULL;
    assert(pto_model_create(&config, &invalid) == PTO_STATUS_ABI_MISMATCH);
    assert(invalid == NULL);
    digest_size = sizeof(config.expected_descriptor_sha256);
    assert(pto_model_descriptor_sha256(config.expected_descriptor_sha256,
                                       &digest_size) == PTO_STATUS_OK);
    assert(digest_size == 32);
    config.expected_descriptor_sha256[0] ^= UINT8_C(1);
    assert(pto_model_create(&config, &invalid) == PTO_STATUS_ABI_MISMATCH);
    assert(invalid == NULL);
    config.expected_descriptor_sha256[0] ^= UINT8_C(1);

    pto_model_t *model = NULL;
    assert(pto_model_create(&config, &model) == PTO_STATUS_OK);
    assert(model != NULL);

    pto_step_result_t uninitialized = {0};
    uninitialized.abi_version = PTO_ASL_MODEL_EXPERIMENTAL_ABI_VERSION;
    uninitialized.struct_size = sizeof(uninitialized);
    pto_status_t uninitialized_status = pto_model_step(model, &uninitialized);
    if (uninitialized_status != PTO_STATUS_OK) {
        uint64_t size = 256;
        char message[256] = {0};
        (void)pto_model_last_error(model, message, &size);
        fprintf(stderr, "uninitialized status=%u: %s\n",
                uninitialized_status, message);
    }
    assert(uninitialized_status == PTO_STATUS_OK);
    assert(uninitialized.step_state == PTO_STEP_UNSUPPORTED);
    assert(uninitialized.instruction_status == PTO_INSTRUCTION_NOT_ATTEMPTED);
    assert(uninitialized.fault_code == 0);

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
    assert(pto_model_step(model, &result) == PTO_STATUS_OK);

    result.struct_size -= 1;
    assert(pto_model_step(model, &result) == PTO_STATUS_ABI_MISMATCH);

    uint64_t write_count = 1;
    assert(pto_model_last_memory_writes(model, NULL, &write_count) ==
           PTO_STATUS_OK);
    assert(write_count == 0);

    initial.pe0_gpr_valid_mask = 1;
    reset_status = pto_model_reset(model, &initial);
    if (reset_status != PTO_STATUS_OK) {
        char error_buffer[128] = {0};
        uint64_t size = sizeof(error_buffer);
        (void)pto_model_last_error(model, error_buffer, &size);
        fprintf(stderr, "GPR reset status=%u: %s\n", reset_status, error_buffer);
    }
    assert(reset_status == PTO_STATUS_OK);

    config.abi_version = 0;
    assert(pto_model_create(&config, &invalid) == PTO_STATUS_ABI_MISMATCH);
    assert(invalid == NULL);
    config.abi_version = PTO_ASL_MODEL_EXPERIMENTAL_ABI_VERSION;
    config.struct_size -= 1;
    assert(pto_model_create(&config, &invalid) == PTO_STATUS_ABI_MISMATCH);

    initial.entry_tpc = 0;
    initial.pe0_gpr_valid_mask =
        (UINT32_C(1) << 1) | (UINT32_C(1) << 2) | (UINT32_C(1) << 3);
    initial.pe0_gpr[1] = 8;
    initial.pe0_gpr[2] = 0;
    initial.pe0_gpr[3] = UINT64_C(0x11223344);
    assert(pto_model_reset(model, &initial) == PTO_STATUS_OK);
    memory[0] = UINT8_C(0x49);
    memory[1] = UINT8_C(0xa0);
    memory[2] = UINT8_C(0x20);
    memory[3] = UINT8_C(0x18);
    result.abi_version = PTO_ASL_MODEL_EXPERIMENTAL_ABI_VERSION;
    result.struct_size = sizeof(result);
    assert(pto_model_step(model, &result) == PTO_STATUS_OK);
    assert(result.memory_write_count == 4);
    const uint8_t expected_digest[32] = {
        0x76, 0x3a, 0xe4, 0xe6, 0x32, 0xeb, 0x06, 0x21,
        0xfb, 0x69, 0xaa, 0x12, 0x48, 0x56, 0xf8, 0x20,
        0x22, 0xb5, 0xcd, 0x25, 0x4b, 0xaf, 0xa1, 0x99,
        0x77, 0xf7, 0xae, 0xf6, 0x16, 0xab, 0x20, 0x5e};
    assert(memcmp(result.memory_write_sha256, expected_digest,
                  sizeof(expected_digest)) == 0);
    write_count = 0;
    assert(pto_model_last_memory_writes(model, NULL, &write_count) ==
           PTO_STATUS_BUFFER_TOO_SMALL);
    assert(write_count == 4);
    pto_memory_write_t writes[4] = {{0}};
    assert(pto_model_last_memory_writes(model, writes, &write_count) ==
           PTO_STATUS_OK);
    assert(write_count == 4);
    const uint8_t expected_values[4] = {0x44, 0x33, 0x22, 0x11};
    for (uint64_t index = 0; index < write_count; ++index) {
        assert(writes[index].abi_version ==
               PTO_ASL_MODEL_EXPERIMENTAL_ABI_VERSION);
        assert(writes[index].struct_size == sizeof(pto_memory_write_t));
        assert(writes[index].address == 8 + index);
        assert(writes[index].value == expected_values[index]);
    }

    uint64_t snapshot_size = 0;
    pto_status_t snapshot_status =
        pto_model_snapshot(model, NULL, &snapshot_size);
    if (snapshot_status != PTO_STATUS_BUFFER_TOO_SMALL) {
        char snapshot_error[256] = {0};
        uint64_t snapshot_error_size = sizeof(snapshot_error);
        (void)pto_model_last_error(
            model, snapshot_error, &snapshot_error_size);
        fprintf(stderr, "snapshot status=%u: %s\n",
                snapshot_status, snapshot_error);
    }
    assert(snapshot_status == PTO_STATUS_BUFFER_TOO_SMALL);
    assert(snapshot_size > 96);
    uint8_t *snapshot = (uint8_t *)malloc((size_t)snapshot_size);
    assert(snapshot != NULL);
    uint64_t copied_snapshot_size = snapshot_size;
    assert(pto_model_snapshot(model, snapshot, &copied_snapshot_size) ==
           PTO_STATUS_OK);
    assert(copied_snapshot_size == snapshot_size);
    assert(memcmp(snapshot, "PTOFMSN1", 8) == 0);
    assert(snapshot[8] == PTO_ASL_MODEL_SNAPSHOT_SCHEMA_VERSION);
    memory[15] = UINT8_C(0x5a);
    assert(pto_model_restore(model, snapshot, snapshot_size) == PTO_STATUS_OK);
    assert(memory[15] == UINT8_C(0x5a));

    snapshot[32] ^= UINT8_C(1);
    assert(pto_model_restore(model, snapshot, snapshot_size) ==
           PTO_STATUS_SNAPSHOT_INCOMPATIBLE);
    snapshot[32] ^= UINT8_C(1);
    snapshot[snapshot_size - 1] ^= UINT8_C(1);
    assert(pto_model_restore(model, snapshot, snapshot_size) ==
           PTO_STATUS_SNAPSHOT_INVALID);
    snapshot[snapshot_size - 1] ^= UINT8_C(1);
    assert(pto_model_restore(model, snapshot, snapshot_size - 1) ==
           PTO_STATUS_SNAPSHOT_INVALID);
    free(snapshot);
    pto_model_destroy(model);
    return 0;
}

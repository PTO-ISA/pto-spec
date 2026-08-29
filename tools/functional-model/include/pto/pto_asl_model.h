#ifndef PTO_ASL_MODEL_H
#define PTO_ASL_MODEL_H

#include <stddef.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

#define PTO_ASL_MODEL_EXPERIMENTAL_ABI_VERSION UINT32_C(0x00030001)

/* G3a experimental surface: source and binary compatibility are not stable. */

typedef struct pto_model pto_model_t;
typedef uint32_t pto_status_t;

enum {
    PTO_STATUS_OK = 0,
    PTO_STATUS_INVALID_ARGUMENT = 1,
    PTO_STATUS_ABI_MISMATCH = 2,
    PTO_STATUS_INVALID_STATE = 3,
    PTO_STATUS_BUSY = 4,
    PTO_STATUS_UNSUPPORTED = 5,
    PTO_STATUS_HOST_PROBE_ERROR = 6,
    PTO_STATUS_HOST_READ_ERROR = 7,
    PTO_STATUS_HOST_COMMIT_ERROR = 8,
    PTO_STATUS_HOST_RESET_ERROR = 9,
    PTO_STATUS_MIR_INVALID = 10,
    PTO_STATUS_RESOURCE_LIMIT = 11,
    PTO_STATUS_INTERNAL_ERROR = 12,
    PTO_STATUS_BUFFER_TOO_SMALL = 13
};

typedef uint32_t pto_step_state_t;
enum {
    PTO_STEP_EXECUTED = 1,
    PTO_STEP_TRAP = 2,
    PTO_STEP_HOST_REQUEST = 3,
    PTO_STEP_UNSUPPORTED = 4
};
typedef uint32_t pto_instruction_status_t;
enum {
    PTO_INSTRUCTION_NOT_ATTEMPTED = 0,
    PTO_INSTRUCTION_EXECUTED = 1,
    PTO_INSTRUCTION_REJECTED = 2
};

typedef uint32_t pto_memory_access_kind_t;
enum {
    PTO_MEMORY_ACCESS_FETCH = 1,
    PTO_MEMORY_ACCESS_READ = 2,
    PTO_MEMORY_ACCESS_WRITE = 3
};

typedef struct {
    uint32_t abi_version;
    uint32_t struct_size;
    uint64_t address;
    uint8_t value;
    uint8_t reserved[7];
} pto_memory_write_t;

typedef struct {
    uint32_t abi_version;
    uint32_t struct_size;
    void *user_data;
    pto_status_t (*reset)(void *user_data);
    pto_status_t (*probe)(void *user_data,
                          pto_memory_access_kind_t access_kind,
                          uint64_t address,
                          uint64_t size,
                          uint8_t *out_permitted);
    pto_status_t (*read)(void *user_data,
                         uint64_t address,
                         uint8_t *out_bytes,
                         uint64_t size);
    pto_status_t (*commit)(void *user_data,
                           const pto_memory_write_t *writes,
                           uint64_t write_count);
} pto_memory_callbacks_t;

/* Callbacks and user_data are bound by create and must remain valid until
 * destroy. Reentry into the same model is rejected with PTO_STATUS_BUSY. */

typedef struct {
    uint32_t abi_version;
    uint32_t struct_size;
    uint64_t flags;
    /* Required. Copy the exact 32-byte value returned by
     * pto_model_descriptor_sha256 before create. */
    uint8_t expected_descriptor_sha256[32];
    pto_memory_callbacks_t memory;
} pto_model_config_t;

typedef struct {
    uint32_t abi_version;
    uint32_t struct_size;
    uint32_t pe0_gpr_valid_mask;
    uint32_t reserved0;
    uint64_t entry_tpc;
    uint64_t pe0_gpr[24];
} pto_initial_state_t;

typedef struct {
    uint32_t abi_version;
    uint32_t struct_size;
    pto_step_state_t step_state;
    pto_instruction_status_t instruction_status;
    uint32_t length_bits;
    uint32_t fault_code;
    uint32_t fault_cause;
    uint32_t origin_pe;
    uint32_t request_type;
    uint64_t sequence;
    uint64_t pre_tpc;
    uint64_t post_tpc;
    uint64_t pre_bpc;
    uint64_t post_bpc;
    uint64_t raw_instruction_le;
    uint64_t fault_address;
    uint64_t request_token;
    uint64_t request_argument0;
} pto_step_result_t;

typedef struct {
    uint32_t abi_version;
    uint32_t struct_size;
    uint64_t scalar_result;
} pto_host_response_t;

pto_status_t pto_model_create(const pto_model_config_t *config,
                              pto_model_t **out_model);
void pto_model_destroy(pto_model_t *model);
pto_status_t pto_model_reset(pto_model_t *model,
                             const pto_initial_state_t *initial_state);
pto_status_t pto_model_step(pto_model_t *model,
                            pto_step_result_t *out_result);
pto_status_t pto_model_complete_host_request(
    pto_model_t *model,
    uint64_t request_token,
    const pto_host_response_t *response);
pto_status_t pto_model_last_error(pto_model_t *model,
                                  char *buffer,
                                  uint64_t *inout_size);
pto_status_t pto_model_descriptor_json(char *buffer, uint64_t *inout_size);
pto_status_t pto_model_descriptor_sha256(uint8_t *buffer,
                                         uint64_t *inout_size);

#ifdef __cplusplus
}
#endif

#endif

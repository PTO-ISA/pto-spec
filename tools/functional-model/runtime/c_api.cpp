#include "pto/pto_asl_model.h"

#include "runtime_model.h"
#include "pto_generated_descriptor.h"
#include "pto_generated_runtime_image.h"

#include <algorithm>
#include <cstring>
#include <memory>
#include <new>
#include <string>
#include <utility>
#include <vector>

struct pto_model {
    std::shared_ptr<const pto::model::Module> module_owner;
    std::unique_ptr<pto::model::RuntimeModel> runtime;
};

namespace {

template <typename T>
bool ValidStruct(const T *value) {
    return value != nullptr &&
           value->abi_version == PTO_ASL_MODEL_EXPERIMENTAL_ABI_VERSION &&
           value->struct_size == sizeof(T);
}

bool DescriptorMatches(const std::uint8_t expected[32]) {
    const auto &actual = pto::model::GeneratedDescriptorSha256();
    return std::equal(actual.begin(), actual.end(), expected);
}

pto_status_t CopyOut(const std::uint8_t *source,
                     std::uint64_t source_size,
                     bool append_nul,
                     void *buffer,
                     std::uint64_t *inout_size) {
    if (inout_size == nullptr) {
        return PTO_STATUS_INVALID_ARGUMENT;
    }
    const std::uint64_t required = source_size + (append_nul ? 1U : 0U);
    if (buffer == nullptr || *inout_size < required) {
        *inout_size = required;
        return PTO_STATUS_BUFFER_TOO_SMALL;
    }
    std::memcpy(buffer, source, static_cast<std::size_t>(source_size));
    if (append_nul) {
        static_cast<char *>(buffer)[source_size] = '\0';
    }
    *inout_size = required;
    return PTO_STATUS_OK;
}

pto::model::MemoryCallbacks BindCallbacks(
    const pto_memory_callbacks_t &callbacks) {
    pto::model::MemoryCallbacks bound;
    bound.reset = [callbacks]() { return callbacks.reset(callbacks.user_data); };
    bound.probe = [callbacks](pto_memory_access_kind_t kind,
                              std::uint64_t address,
                              std::uint64_t size,
                              bool *permitted) {
        std::uint8_t result = 0;
        const pto_status_t status = callbacks.probe(
            callbacks.user_data, kind, address, size, &result);
        if (status == PTO_STATUS_OK && permitted != nullptr) {
            *permitted = result != 0;
        }
        return status;
    };
    bound.read = [callbacks](std::uint64_t address,
                             std::uint8_t *bytes,
                             std::uint64_t size) {
        return callbacks.read(callbacks.user_data, address, bytes, size);
    };
    bound.commit = [callbacks](
                       const std::vector<pto::model::MemoryWrite> &writes) {
        std::vector<pto_memory_write_t> abi_writes;
        abi_writes.reserve(writes.size());
        for (const pto::model::MemoryWrite &write : writes) {
            pto_memory_write_t converted{};
            converted.abi_version = PTO_ASL_MODEL_EXPERIMENTAL_ABI_VERSION;
            converted.struct_size = sizeof(converted);
            converted.address = write.address;
            converted.value = write.value;
            abi_writes.push_back(converted);
        }
        return callbacks.commit(callbacks.user_data,
                                abi_writes.data(),
                                abi_writes.size());
    };
    return bound;
}

}  // namespace

extern "C" pto_status_t pto_model_create(const pto_model_config_t *config,
                                         pto_model_t **out_model) {
    if (out_model == nullptr) {
        return PTO_STATUS_INVALID_ARGUMENT;
    }
    *out_model = nullptr;
    if (!ValidStruct(config) || !ValidStruct(&config->memory)) {
        return PTO_STATUS_ABI_MISMATCH;
    }
    if (!DescriptorMatches(config->expected_descriptor_sha256)) {
        return PTO_STATUS_ABI_MISMATCH;
    }
    if (config->flags != 0 || config->memory.reset == nullptr ||
        config->memory.probe == nullptr || config->memory.read == nullptr ||
        config->memory.commit == nullptr) {
        return PTO_STATUS_INVALID_ARGUMENT;
    }
    try {
        auto model = std::make_unique<pto_model>();
        model->module_owner = pto::model::GeneratedResetModule();
        model->runtime = std::make_unique<pto::model::RuntimeModel>(
            model->module_owner, BindCallbacks(config->memory));
        *out_model = model.release();
        return PTO_STATUS_OK;
    } catch (const std::bad_alloc &) {
        return PTO_STATUS_RESOURCE_LIMIT;
    } catch (...) {
        return PTO_STATUS_INTERNAL_ERROR;
    }
}

extern "C" pto_status_t pto_model_descriptor_json(
    char *buffer, std::uint64_t *inout_size) {
    return CopyOut(pto::model::GeneratedDescriptorData(),
                   pto::model::GeneratedDescriptorSize(), true, buffer,
                   inout_size);
}

extern "C" pto_status_t pto_model_descriptor_sha256(
    std::uint8_t *buffer, std::uint64_t *inout_size) {
    const auto &digest = pto::model::GeneratedDescriptorSha256();
    return CopyOut(digest.data(), digest.size(), false, buffer, inout_size);
}

extern "C" void pto_model_destroy(pto_model_t *model) { delete model; }

extern "C" pto_status_t pto_model_reset(
    pto_model_t *model,
    const pto_initial_state_t *initial_state) {
    if (model == nullptr || model->runtime == nullptr) {
        return PTO_STATUS_INVALID_ARGUMENT;
    }
    if (!ValidStruct(initial_state)) {
        return PTO_STATUS_ABI_MISMATCH;
    }
    if ((initial_state->pe0_gpr_valid_mask & 0xff000000U) != 0 ||
        initial_state->reserved0 != 0) {
        return PTO_STATUS_INVALID_ARGUMENT;
    }
    pto::model::InitialState initial;
    initial.entry_tpc = initial_state->entry_tpc;
    initial.pe0_gpr_valid_mask = initial_state->pe0_gpr_valid_mask;
    std::copy(std::begin(initial_state->pe0_gpr),
              std::end(initial_state->pe0_gpr), initial.pe0_gpr.begin());
    return model->runtime->Reset(initial);
}

extern "C" pto_status_t pto_model_step(pto_model_t *model,
                                       pto_step_result_t *out_result) {
    if (model == nullptr || model->runtime == nullptr) {
        return PTO_STATUS_INVALID_ARGUMENT;
    }
    if (!ValidStruct(out_result)) {
        return PTO_STATUS_ABI_MISMATCH;
    }
    const std::uint32_t abi_version = out_result->abi_version;
    const std::uint32_t struct_size = out_result->struct_size;
    std::memset(out_result, 0, sizeof(*out_result));
    out_result->abi_version = abi_version;
    out_result->struct_size = struct_size;
    out_result->step_state = PTO_STEP_UNSUPPORTED;

    pto::model::StepResult result;
    const pto_status_t status = model->runtime->Step(&result);
    out_result->step_state = result.state;
    out_result->instruction_status = result.instruction_status;
    out_result->length_bits = result.length_bits;
    out_result->fault_code = result.fault_code;
    out_result->fault_cause = result.fault_cause;
    out_result->origin_pe = result.origin_pe;
    out_result->request_type = result.request_type;
    out_result->sequence = result.sequence;
    out_result->pre_tpc = result.pre_tpc;
    out_result->post_tpc = result.post_tpc;
    out_result->pre_bpc = result.pre_bpc;
    out_result->post_bpc = result.post_bpc;
    out_result->raw_instruction_le = result.raw_instruction;
    out_result->fault_address = result.fault_address;
    out_result->request_token = result.request_token;
    out_result->request_argument0 = result.request_argument0;
    return status;
}

extern "C" pto_status_t pto_model_complete_host_request(
    pto_model_t *model,
    std::uint64_t request_token,
    const pto_host_response_t *response) {
    if (model == nullptr || model->runtime == nullptr) {
        return PTO_STATUS_INVALID_ARGUMENT;
    }
    if (!ValidStruct(response)) {
        return PTO_STATUS_ABI_MISMATCH;
    }
    return model->runtime->CompleteHostRequest(
        request_token, response->scalar_result);
}

extern "C" pto_status_t pto_model_last_error(pto_model_t *model,
                                             char *buffer,
                                             std::uint64_t *inout_size) {
    if (model == nullptr || model->runtime == nullptr || inout_size == nullptr) {
        return PTO_STATUS_INVALID_ARGUMENT;
    }
    const std::string error = model->runtime->last_error();
    const std::uint64_t required = error.size() + 1;
    if (buffer == nullptr || *inout_size < required) {
        *inout_size = required;
        return PTO_STATUS_BUFFER_TOO_SMALL;
    }
    std::copy(error.begin(), error.end(), buffer);
    buffer[error.size()] = '\0';
    *inout_size = required;
    return PTO_STATUS_OK;
}

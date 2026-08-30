#include "snapshot.h"

#include "pto_generated_descriptor.h"
#include "trace_digest.h"

#include <algorithm>
#include <array>
#include <cstring>
#include <limits>
#include <map>
#include <memory>
#include <utility>

namespace pto::model {
namespace {

constexpr std::array<std::uint8_t, 8> kSnapshotMagic = {'P', 'T', 'O', 'F',
                                                        'M', 'S', 'N', '1'};
constexpr std::array<std::uint8_t, 25> kBundleTileDomain = {
    'p', 't', 'o', '-', 'b', 'u', 'n', 'd', 'l', 'e', '-', 't', 'i',
    'l', 'e', '-', 's', 't', 'a', 't', 'e', '-', 'v', '1', '\0'};
constexpr std::uint64_t kMaximumItems = UINT64_C(1) << 20;
constexpr unsigned kMaximumDepth = 64;

enum class ValueTag : std::uint8_t {
  kBool = 1,
  kInteger = 2,
  kBits = 3,
  kEnum = 4,
  kTuple = 5,
  kRecord = 6,
  kArray = 7,
};

void SetError(std::string *error, std::string message) {
  if (error != nullptr)
    *error = std::move(message);
}

class Writer final {
public:
  explicit Writer(std::size_t maximum_size) : maximum_size_(maximum_size) {}

  bool U8(std::uint8_t value) { return Bytes(&value, 1); }

  bool U32(std::uint32_t value) {
    std::array<std::uint8_t, 4> bytes{};
    for (unsigned index = 0; index < bytes.size(); ++index)
      bytes[index] = static_cast<std::uint8_t>(value >> (index * 8U));
    return Bytes(bytes.data(), bytes.size());
  }

  bool U64(std::uint64_t value) {
    std::array<std::uint8_t, 8> bytes{};
    for (unsigned index = 0; index < bytes.size(); ++index)
      bytes[index] = static_cast<std::uint8_t>(value >> (index * 8U));
    return Bytes(bytes.data(), bytes.size());
  }

  bool Bytes(const std::uint8_t *bytes, std::size_t size) {
    if (size > maximum_size_ - data_.size())
      return false;
    data_.insert(data_.end(), bytes, bytes + size);
    return true;
  }

  const std::vector<std::uint8_t> &data() const { return data_; }
  std::vector<std::uint8_t> Take() { return std::move(data_); }

private:
  std::size_t maximum_size_;
  std::vector<std::uint8_t> data_;
};

class Reader final {
public:
  Reader(const std::uint8_t *data, std::size_t size)
      : data_(data), size_(size) {}

  bool U8(std::uint8_t *value) {
    if (value == nullptr || remaining() < 1)
      return false;
    *value = data_[offset_++];
    return true;
  }

  bool U32(std::uint32_t *value) {
    if (value == nullptr || remaining() < 4)
      return false;
    *value = 0;
    for (unsigned index = 0; index < 4; ++index)
      *value |= static_cast<std::uint32_t>(data_[offset_++]) << (index * 8U);
    return true;
  }

  bool U64(std::uint64_t *value) {
    if (value == nullptr || remaining() < 8)
      return false;
    *value = 0;
    for (unsigned index = 0; index < 8; ++index)
      *value |= static_cast<std::uint64_t>(data_[offset_++]) << (index * 8U);
    return true;
  }

  bool Bytes(std::uint8_t *bytes, std::size_t size) {
    if ((bytes == nullptr && size != 0) || size > remaining())
      return false;
    if (size != 0)
      std::copy_n(data_ + offset_, size, bytes);
    offset_ += size;
    return true;
  }

  bool Skip(std::size_t size) {
    if (size > remaining())
      return false;
    offset_ += size;
    return true;
  }

  const std::uint8_t *current() const { return data_ + offset_; }
  std::size_t remaining() const { return size_ - offset_; }
  std::size_t offset() const { return offset_; }

private:
  const std::uint8_t *data_;
  std::size_t size_;
  std::size_t offset_ = 0;
};

bool EncodeValue(const Value &value, Writer *writer, unsigned depth) {
  if (writer == nullptr || depth > kMaximumDepth)
    return false;
  const Value::Storage &storage = value.storage();
  if (const auto *boolean = std::get_if<bool>(&storage)) {
    return writer->U8(static_cast<std::uint8_t>(ValueTag::kBool)) &&
           writer->U8(*boolean ? 1 : 0);
  }
  if (const auto *integer = std::get_if<BigInteger>(&storage)) {
    if (integer->words().size() > kMaximumItems)
      return false;
    if (!writer->U8(static_cast<std::uint8_t>(ValueTag::kInteger)) ||
        !writer->U8(integer->negative() ? 1 : 0) ||
        !writer->U32(static_cast<std::uint32_t>(integer->words().size())))
      return false;
    for (std::uint32_t word : integer->words())
      if (!writer->U32(word))
        return false;
    return true;
  }
  if (const auto *bits = std::get_if<BitVector>(&storage)) {
    return writer->U8(static_cast<std::uint8_t>(ValueTag::kBits)) &&
           writer->U64(bits->width()) &&
           writer->Bytes(bits->bytes().data(), bits->bytes().size());
  }
  if (const auto *enumeration = std::get_if<EnumValue>(&storage)) {
    return writer->U8(static_cast<std::uint8_t>(ValueTag::kEnum)) &&
           writer->U32(enumeration->type_id) &&
           writer->U32(enumeration->member_id);
  }
  if (const auto *tuple = std::get_if<std::shared_ptr<TupleValue>>(&storage)) {
    if ((*tuple)->size() > kMaximumItems ||
        !writer->U8(static_cast<std::uint8_t>(ValueTag::kTuple)) ||
        !writer->U64((*tuple)->size()))
      return false;
    for (const Value &item : **tuple)
      if (!EncodeValue(item, writer, depth + 1))
        return false;
    return true;
  }
  if (const auto *record =
          std::get_if<std::shared_ptr<RecordValue>>(&storage)) {
    if ((*record)->size() > kMaximumItems ||
        !writer->U8(static_cast<std::uint8_t>(ValueTag::kRecord)) ||
        !writer->U64((*record)->size()))
      return false;
    for (const auto &[field, item] : **record)
      if (!writer->U32(field) || !EncodeValue(item, writer, depth + 1))
        return false;
    return true;
  }
  const auto *array = std::get_if<std::shared_ptr<PagedLazyArray>>(&storage);
  if (array == nullptr)
    return false;
  const auto entries = (*array)->CanonicalValues();
  if (entries.size() > kMaximumItems ||
      !writer->U8(static_cast<std::uint8_t>(ValueTag::kArray)) ||
      !writer->U64((*array)->length()) || !writer->U64(entries.size()))
    return false;
  for (const auto &[index, item] : entries)
    if (!writer->U64(index) || !EncodeValue(item, writer, depth + 1))
      return false;
  return true;
}

const Value *TuplePrototype(const Value *prototype, std::size_t index) {
  if (prototype == nullptr)
    return nullptr;
  const auto *tuple =
      std::get_if<std::shared_ptr<TupleValue>>(&prototype->storage());
  return tuple != nullptr && index < (*tuple)->size() ? &(*tuple)->at(index)
                                                      : nullptr;
}

const Value *RecordPrototype(const Value *prototype, std::uint32_t field) {
  if (prototype == nullptr)
    return nullptr;
  const auto *record =
      std::get_if<std::shared_ptr<RecordValue>>(&prototype->storage());
  if (record == nullptr)
    return nullptr;
  const auto found = (*record)->find(field);
  return found == (*record)->end() ? nullptr : &found->second;
}

bool DecodeValue(Reader *reader, const Value *prototype, Value *value,
                 unsigned depth) {
  if (reader == nullptr || value == nullptr || depth > kMaximumDepth)
    return false;
  std::uint8_t raw_tag = 0;
  if (!reader->U8(&raw_tag))
    return false;
  const ValueTag tag = static_cast<ValueTag>(raw_tag);
  if (tag == ValueTag::kBool) {
    std::uint8_t boolean = 0;
    if (!reader->U8(&boolean) || boolean > 1)
      return false;
    *value = Value(boolean != 0);
    return true;
  }
  if (tag == ValueTag::kInteger) {
    std::uint8_t negative = 0;
    std::uint32_t count = 0;
    if (!reader->U8(&negative) || negative > 1 || !reader->U32(&count) ||
        count > kMaximumItems)
      return false;
    std::vector<std::uint32_t> words(count);
    for (std::uint32_t &word : words)
      if (!reader->U32(&word))
        return false;
    *value =
        Value(BigInteger::FromSignedWords(negative != 0, std::move(words)));
    return true;
  }
  if (tag == ValueTag::kBits) {
    std::uint64_t width = 0;
    if (!reader->U64(&width) || width == 0 || width > kMaximumItems)
      return false;
    const std::uint64_t byte_count = (width + 7) / 8;
    if (byte_count > reader->remaining())
      return false;
    std::vector<std::uint8_t> bytes(static_cast<std::size_t>(byte_count));
    if (!reader->Bytes(bytes.data(), bytes.size()))
      return false;
    *value = Value(BitVector::FromBytes(static_cast<std::size_t>(width),
                                        std::move(bytes)));
    return true;
  }
  if (tag == ValueTag::kEnum) {
    EnumValue enumeration{};
    if (!reader->U32(&enumeration.type_id) ||
        !reader->U32(&enumeration.member_id))
      return false;
    *value = Value(enumeration);
    return true;
  }
  if (tag == ValueTag::kTuple) {
    std::uint64_t count = 0;
    if (!reader->U64(&count) || count > kMaximumItems)
      return false;
    TupleValue tuple;
    tuple.reserve(static_cast<std::size_t>(count));
    for (std::uint64_t index = 0; index < count; ++index) {
      Value item(false);
      if (!DecodeValue(reader, TuplePrototype(prototype, index), &item,
                       depth + 1))
        return false;
      tuple.push_back(std::move(item));
    }
    *value = Value(std::move(tuple));
    return true;
  }
  if (tag == ValueTag::kRecord) {
    std::uint64_t count = 0;
    if (!reader->U64(&count) || count > kMaximumItems)
      return false;
    RecordValue record;
    std::uint32_t previous = 0;
    for (std::uint64_t index = 0; index < count; ++index) {
      std::uint32_t field = 0;
      if (!reader->U32(&field) || (index != 0 && field <= previous))
        return false;
      previous = field;
      Value item(false);
      if (!DecodeValue(reader, RecordPrototype(prototype, field), &item,
                       depth + 1))
        return false;
      record.emplace(field, std::move(item));
    }
    *value = Value(std::move(record));
    return true;
  }
  if (tag != ValueTag::kArray || prototype == nullptr)
    return false;
  const auto *prototype_array =
      std::get_if<std::shared_ptr<PagedLazyArray>>(&prototype->storage());
  std::uint64_t length = 0;
  std::uint64_t count = 0;
  if (prototype_array == nullptr || !reader->U64(&length) ||
      length != (*prototype_array)->length() || !reader->U64(&count) ||
      count > kMaximumItems || count > length)
    return false;
  auto array = (*prototype_array)->EmptyClone();
  std::uint64_t previous = 0;
  for (std::uint64_t item_index = 0; item_index < count; ++item_index) {
    std::uint64_t index = 0;
    if (!reader->U64(&index) || index >= length ||
        (item_index != 0 && index <= previous))
      return false;
    previous = index;
    const Value item_prototype = array->Get(index);
    Value item(false);
    if (!DecodeValue(reader, &item_prototype, &item, depth + 1))
      return false;
    array->Set(index, std::move(item));
  }
  *value = Value(std::move(array));
  return true;
}

bool EncodeStatePayload(const RuntimeState &state, Writer *writer,
                        BindingId *failed_binding, BindingId *largest_binding,
                        std::size_t *largest_size) {
  if (!writer->U64(state.sequence) || !writer->U64(state.tpc) ||
      !writer->U64(state.bpc))
    return false;

  std::map<BindingId, std::uint64_t> globals(state.globals.begin(),
                                             state.globals.end());
  if (!writer->U64(globals.size()))
    return false;
  for (const auto &[binding, value] : globals)
    if (!writer->U32(binding) || !writer->U64(value))
      return false;

  std::map<BindingId, const Value *> typed;
  for (const auto &[binding, value] : state.typed_globals)
    typed.emplace(binding, &value);
  if (!writer->U64(typed.size()))
    return false;
  for (const auto &[binding, value] : typed) {
    const std::size_t before = writer->data().size();
    if (failed_binding != nullptr)
      *failed_binding = binding;
    if (!writer->U32(binding) || !EncodeValue(*value, writer, 0))
      return false;
    const std::size_t encoded_size = writer->data().size() - before;
    if (largest_binding != nullptr && largest_size != nullptr &&
        encoded_size > *largest_size) {
      *largest_binding = binding;
      *largest_size = encoded_size;
    }
  }
  return true;
}

bool DecodeStatePayload(Reader *reader, const RuntimeState &prototype,
                        RuntimeState *state) {
  RuntimeState candidate;
  if (!reader->U64(&candidate.sequence) || !reader->U64(&candidate.tpc) ||
      !reader->U64(&candidate.bpc))
    return false;

  std::uint64_t global_count = 0;
  if (!reader->U64(&global_count) || global_count > kMaximumItems)
    return false;
  BindingId previous_binding = 0;
  for (std::uint64_t index = 0; index < global_count; ++index) {
    BindingId binding = 0;
    std::uint64_t value = 0;
    if (!reader->U32(&binding) || (index != 0 && binding <= previous_binding) ||
        !reader->U64(&value))
      return false;
    previous_binding = binding;
    candidate.globals.emplace(binding, value);
  }

  std::uint64_t typed_count = 0;
  if (!reader->U64(&typed_count) ||
      typed_count != prototype.typed_globals.size())
    return false;
  previous_binding = 0;
  for (std::uint64_t index = 0; index < typed_count; ++index) {
    BindingId binding = 0;
    if (!reader->U32(&binding) || (index != 0 && binding <= previous_binding))
      return false;
    previous_binding = binding;
    const auto prototype_value = prototype.typed_globals.find(binding);
    if (prototype_value == prototype.typed_globals.end())
      return false;
    Value value(false);
    if (!DecodeValue(reader, &prototype_value->second, &value, 0))
      return false;
    candidate.typed_globals.emplace(binding, std::move(value));
  }
  if (reader->remaining() != 0)
    return false;
  *state = std::move(candidate);
  return true;
}

} // namespace

pto_status_t EncodeSnapshot(const RuntimeState &state,
                            std::vector<std::uint8_t> *snapshot,
                            std::string *error) {
  if (snapshot == nullptr)
    return PTO_STATUS_INVALID_ARGUMENT;
  Writer payload(kSnapshotMaximumSize - kSnapshotHeaderSize);
  BindingId failed_binding = 0;
  BindingId largest_binding = 0;
  std::size_t largest_size = 0;
  if (!EncodeStatePayload(state, &payload, &failed_binding, &largest_binding,
                          &largest_size)) {
    SetError(error, "model state exceeds snapshot limits at binding=" +
                        std::to_string(failed_binding) +
                        " bytes=" + std::to_string(payload.data().size()) +
                        " largest_binding=" + std::to_string(largest_binding) +
                        " largest_bytes=" + std::to_string(largest_size));
    return PTO_STATUS_RESOURCE_LIMIT;
  }
  const auto payload_digest =
      Sha256Bytes(payload.data().data(), payload.data().size());
  Writer envelope(kSnapshotMaximumSize);
  const std::uint64_t total_size = kSnapshotHeaderSize + payload.data().size();
  if (!envelope.Bytes(kSnapshotMagic.data(), kSnapshotMagic.size()) ||
      !envelope.U32(kSnapshotSchemaVersion) ||
      !envelope.U32(kSnapshotHeaderSize) || !envelope.U64(total_size) ||
      !envelope.U64(payload.data().size()) ||
      !envelope.Bytes(GeneratedDescriptorSha256().data(),
                      GeneratedDescriptorSha256().size()) ||
      !envelope.Bytes(payload_digest.data(), payload_digest.size()) ||
      !envelope.Bytes(payload.data().data(), payload.data().size())) {
    SetError(error, "snapshot envelope exceeds the model limit");
    return PTO_STATUS_RESOURCE_LIMIT;
  }
  *snapshot = envelope.Take();
  return PTO_STATUS_OK;
}

pto_status_t DecodeSnapshot(const std::uint8_t *snapshot,
                            std::size_t snapshot_size,
                            const RuntimeState &prototype, RuntimeState *state,
                            std::string *error) {
  if (snapshot == nullptr || state == nullptr ||
      snapshot_size < kSnapshotHeaderSize ||
      snapshot_size > kSnapshotMaximumSize) {
    SetError(error, "snapshot size is outside the model contract");
    return PTO_STATUS_SNAPSHOT_INVALID;
  }
  Reader reader(snapshot, snapshot_size);
  std::array<std::uint8_t, 8> magic{};
  std::uint32_t version = 0;
  std::uint32_t header_size = 0;
  std::uint64_t total_size = 0;
  std::uint64_t payload_size = 0;
  std::array<std::uint8_t, 32> descriptor_digest{};
  std::array<std::uint8_t, 32> payload_digest{};
  if (!reader.Bytes(magic.data(), magic.size()) || !reader.U32(&version) ||
      !reader.U32(&header_size) || !reader.U64(&total_size) ||
      !reader.U64(&payload_size) ||
      !reader.Bytes(descriptor_digest.data(), descriptor_digest.size()) ||
      !reader.Bytes(payload_digest.data(), payload_digest.size()) ||
      magic != kSnapshotMagic || version != kSnapshotSchemaVersion ||
      header_size != kSnapshotHeaderSize || total_size != snapshot_size ||
      payload_size != snapshot_size - kSnapshotHeaderSize) {
    SetError(error, "snapshot header is invalid");
    return PTO_STATUS_SNAPSHOT_INVALID;
  }
  if (descriptor_digest != GeneratedDescriptorSha256()) {
    SetError(error, "snapshot model descriptor is incompatible");
    return PTO_STATUS_SNAPSHOT_INCOMPATIBLE;
  }
  const auto actual_payload_digest =
      Sha256Bytes(reader.current(), static_cast<std::size_t>(payload_size));
  if (payload_digest != actual_payload_digest) {
    SetError(error, "snapshot payload digest mismatch");
    return PTO_STATUS_SNAPSHOT_INVALID;
  }
  Reader payload(reader.current(), static_cast<std::size_t>(payload_size));
  RuntimeState candidate;
  if (!DecodeStatePayload(&payload, prototype, &candidate)) {
    SetError(error, "snapshot payload is not canonical model state");
    return PTO_STATUS_SNAPSHOT_INVALID;
  }
  *state = std::move(candidate);
  return PTO_STATUS_OK;
}

pto_status_t DigestStateBindings(const RuntimeState &state,
                                 const std::vector<BindingId> &bindings,
                                 std::array<std::uint8_t, 32> *digest,
                                 std::string *error) {
  if (digest == nullptr)
    return PTO_STATUS_INVALID_ARGUMENT;
  Writer writer(kSnapshotMaximumSize);
  if (!writer.Bytes(kBundleTileDomain.data(), kBundleTileDomain.size()))
    return PTO_STATUS_RESOURCE_LIMIT;
  std::vector<BindingId> ordered = bindings;
  std::sort(ordered.begin(), ordered.end());
  ordered.erase(std::unique(ordered.begin(), ordered.end()), ordered.end());
  if (!writer.U64(ordered.size()))
    return PTO_STATUS_RESOURCE_LIMIT;
  for (BindingId binding : ordered) {
    const auto value = state.typed_globals.find(binding);
    if (value == state.typed_globals.end()) {
      SetError(error, "bundle/Tile summary binding is absent from model state");
      return PTO_STATUS_MIR_INVALID;
    }
    if (!writer.U32(binding) || !EncodeValue(value->second, &writer, 0)) {
      SetError(error, "bundle/Tile state exceeds summary limits");
      return PTO_STATUS_RESOURCE_LIMIT;
    }
  }
  *digest = Sha256Bytes(writer.data().data(), writer.data().size());
  return PTO_STATUS_OK;
}

} // namespace pto::model

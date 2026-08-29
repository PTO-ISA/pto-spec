#include "value.h"

#include <algorithm>
#include <limits>
#include <stdexcept>

namespace pto::model {

BigInteger::BigInteger() = default;

BigInteger::BigInteger(std::int64_t value) {
    negative_ = value < 0;
    std::uint64_t magnitude = negative_
        ? static_cast<std::uint64_t>(-(value + 1)) + 1
        : static_cast<std::uint64_t>(value);
    while (magnitude != 0) {
        words_.push_back(static_cast<std::uint32_t>(magnitude));
        magnitude >>= 32;
    }
}

BigInteger BigInteger::FromUnsignedWords(std::vector<std::uint32_t> words) {
    BigInteger result;
    result.words_ = std::move(words);
    result.Normalize();
    return result;
}

BigInteger BigInteger::Add(const BigInteger &other) const {
    BigInteger result;
    if (negative_ == other.negative_) {
        result.negative_ = negative_;
        const std::size_t count = std::max(words_.size(), other.words_.size());
        result.words_.resize(count);
        std::uint64_t carry = 0;
        for (std::size_t index = 0; index < count; ++index) {
            const std::uint64_t left =
                index < words_.size() ? words_[index] : 0;
            const std::uint64_t right =
                index < other.words_.size() ? other.words_[index] : 0;
            const std::uint64_t sum = left + right + carry;
            result.words_[index] = static_cast<std::uint32_t>(sum);
            carry = sum >> 32;
        }
        if (carry != 0) {
            result.words_.push_back(static_cast<std::uint32_t>(carry));
        }
        return result;
    }

    const auto compare_magnitude = [](const std::vector<std::uint32_t> &left,
                                      const std::vector<std::uint32_t> &right) {
        if (left.size() != right.size()) {
            return left.size() < right.size() ? -1 : 1;
        }
        for (std::size_t offset = 0; offset < left.size(); ++offset) {
            const std::size_t index = left.size() - offset - 1;
            if (left[index] != right[index]) {
                return left[index] < right[index] ? -1 : 1;
            }
        }
        return 0;
    };
    const int order = compare_magnitude(words_, other.words_);
    if (order == 0) {
        return result;
    }
    const auto &larger = order > 0 ? words_ : other.words_;
    const auto &smaller = order > 0 ? other.words_ : words_;
    result.negative_ = order > 0 ? negative_ : other.negative_;
    result.words_.resize(larger.size());
    std::uint64_t borrow = 0;
    for (std::size_t index = 0; index < larger.size(); ++index) {
        const std::uint64_t right =
            (index < smaller.size() ? smaller[index] : 0) + borrow;
        const std::uint64_t left = larger[index];
        result.words_[index] = static_cast<std::uint32_t>(left - right);
        borrow = left < right ? 1 : 0;
    }
    result.Normalize();
    return result;
}

BigInteger BigInteger::Negated() const {
    BigInteger result = *this;
    if (!result.words_.empty()) result.negative_ = !result.negative_;
    return result;
}

BigInteger BigInteger::Multiply(const BigInteger &other) const {
    BigInteger result;
    if (words_.empty() || other.words_.empty()) return result;
    result.negative_ = negative_ != other.negative_;
    result.words_.assign(words_.size() + other.words_.size(), 0);
    for (std::size_t left = 0; left < words_.size(); ++left) {
        std::uint64_t carry = 0;
        for (std::size_t right = 0; right < other.words_.size(); ++right) {
            const std::size_t index = left + right;
            const std::uint64_t product =
                static_cast<std::uint64_t>(words_[left]) * other.words_[right] +
                result.words_[index] + carry;
            result.words_[index] = static_cast<std::uint32_t>(product);
            carry = product >> 32;
        }
        result.words_[left + other.words_.size()] =
            static_cast<std::uint32_t>(carry);
    }
    result.Normalize();
    return result;
}

bool BigInteger::Divide(const BigInteger &other, BigInteger *quotient) const {
    if (quotient == nullptr || other.words_.empty()) return false;
    BigInteger dividend = *this;
    BigInteger divisor = other;
    dividend.negative_ = false;
    divisor.negative_ = false;
    BigInteger result;
    if (dividend.words_.empty() || dividend.Compare(divisor) < 0) {
        *quotient = result;
        return true;
    }
    const std::size_t top_word = dividend.words_.size() - 1;
    std::size_t bit_count = top_word * 32 + 32;
    while (bit_count > 0 &&
           ((dividend.words_[(bit_count - 1) / 32] >> ((bit_count - 1) % 32)) & 1U) == 0)
        --bit_count;
    result.words_.assign((bit_count + 31) / 32, 0);
    BigInteger remainder;
    for (std::size_t offset = 0; offset < bit_count; ++offset) {
        const std::size_t bit_index = bit_count - offset - 1;
        remainder = remainder.Add(remainder);
        if (((dividend.words_[bit_index / 32] >> (bit_index % 32)) & 1U) != 0)
            remainder = remainder.Add(BigInteger(1));
        if (remainder.Compare(divisor) >= 0) {
            remainder = remainder.Add(divisor.Negated());
            result.words_[bit_index / 32] |= UINT32_C(1) << (bit_index % 32);
        }
    }
    result.negative_ = negative_ != other.negative_;
    result.Normalize();
    *quotient = std::move(result);
    return true;
}

bool BigInteger::Modulo(const BigInteger &other, BigInteger *remainder) const {
    if (remainder == nullptr) return false;
    BigInteger quotient;
    if (!Divide(other, &quotient)) return false;
    *remainder = Add(quotient.Multiply(other).Negated());
    return true;
}

int BigInteger::Compare(const BigInteger &other) const {
    if (negative_ != other.negative_) return negative_ ? -1 : 1;
    int magnitude = 0;
    if (words_.size() != other.words_.size()) {
        magnitude = words_.size() < other.words_.size() ? -1 : 1;
    } else {
        for (std::size_t offset = 0; offset < words_.size(); ++offset) {
            const std::size_t index = words_.size() - offset - 1;
            if (words_[index] != other.words_[index]) {
                magnitude = words_[index] < other.words_[index] ? -1 : 1;
                break;
            }
        }
    }
    return negative_ ? -magnitude : magnitude;
}

bool BigInteger::IsZero() const { return words_.empty(); }

bool BigInteger::operator==(const BigInteger &other) const {
    return negative_ == other.negative_ && words_ == other.words_;
}

bool BigInteger::TryToU64(std::uint64_t *value) const {
    if (value == nullptr || negative_ || words_.size() > 2) {
        return false;
    }
    *value = words_.empty() ? 0 : words_[0];
    if (words_.size() == 2) {
        *value |= static_cast<std::uint64_t>(words_[1]) << 32;
    }
    return true;
}

std::string BigInteger::ToString() const {
    if (words_.empty()) {
        return "0";
    }
    if (words_.size() == 1) {
        const std::string value = std::to_string(words_.front());
        return negative_ ? "-" + value : value;
    }
    std::string result = negative_ ? "-0x" : "0x";
    static constexpr char digits[] = "0123456789abcdef";
    for (auto word = words_.rbegin(); word != words_.rend(); ++word) {
        for (int shift = 28; shift >= 0; shift -= 4) {
            result.push_back(digits[(*word >> shift) & 0xfU]);
        }
    }
    return result;
}

void BigInteger::Normalize() {
    while (!words_.empty() && words_.back() == 0) {
        words_.pop_back();
    }
    if (words_.empty()) {
        negative_ = false;
    }
}

BitVector::BitVector(std::size_t width)
    : width_(width), bytes_((width + 7) / 8, 0) {}

BitVector BitVector::FromU64(std::size_t width, std::uint64_t value) {
    BitVector result(width);
    const std::size_t count = std::min(result.bytes_.size(), sizeof(value));
    for (std::size_t index = 0; index < count; ++index) {
        result.bytes_[index] = static_cast<std::uint8_t>(value >> (index * 8));
    }
    if (width % 8 != 0) {
        result.bytes_.back() &= static_cast<std::uint8_t>((1U << (width % 8)) - 1U);
    }
    return result;
}

BigInteger BitVector::ToUnsignedInteger() const {
    std::vector<std::uint32_t> words((width_ + 31) / 32, 0);
    for (std::size_t index = 0; index < width_; ++index) {
        if (bit(index)) words[index / 32] |= UINT32_C(1) << (index % 32);
    }
    return BigInteger::FromUnsignedWords(std::move(words));
}

BigInteger BitVector::ToSignedInteger() const {
    BigInteger value = ToUnsignedInteger();
    if (!bit(width_ - 1)) return value;
    std::vector<std::uint32_t> power_words(width_ / 32 + 1, 0);
    power_words[width_ / 32] = UINT32_C(1) << (width_ % 32);
    return value.Add(
        BigInteger::FromUnsignedWords(std::move(power_words)).Negated());
}

std::size_t BitVector::width() const { return width_; }

bool BitVector::bit(std::size_t index) const {
    if (index >= width_) {
        throw std::out_of_range("bitvector index");
    }
    return ((bytes_[index / 8] >> (index % 8)) & 1U) != 0;
}

BitVector BitVector::Slice(std::size_t start, std::size_t width) const {
    if (width == 0 || start > width_ || width > width_ - start) {
        throw std::out_of_range("bitvector slice");
    }
    BitVector result(width);
    for (std::size_t index = 0; index < width; ++index) {
        if (bit(start + index)) {
            result.bytes_[index / 8] |=
                static_cast<std::uint8_t>(1U << (index % 8));
        }
    }
    return result;
}

void BitVector::SetSlice(std::size_t start,
                         std::size_t width,
                         const BitVector &replacement) {
    if (width == 0 || replacement.width_ != width || start > width_ ||
        width > width_ - start) {
        throw std::out_of_range("bitvector slice assignment");
    }
    for (std::size_t index = 0; index < width; ++index) {
        const std::size_t destination = start + index;
        const std::uint8_t mask =
            static_cast<std::uint8_t>(1U << (destination % 8));
        if (replacement.bit(index)) bytes_[destination / 8] |= mask;
        else bytes_[destination / 8] &= static_cast<std::uint8_t>(~mask);
    }
}

bool BitVector::TryToU64(std::uint64_t *value) const {
    if (value == nullptr || width_ > 64) {
        return false;
    }
    *value = 0;
    for (std::size_t index = 0; index < bytes_.size(); ++index) {
        *value |= static_cast<std::uint64_t>(bytes_[index]) << (index * 8);
    }
    return true;
}

BitVector BitVector::BitOr(const BitVector &other) const {
    if (width_ != other.width_) throw std::invalid_argument("bitvector OR width");
    BitVector result(width_);
    for (std::size_t index = 0; index < bytes_.size(); ++index)
        result.bytes_[index] = bytes_[index] | other.bytes_[index];
    return result;
}

BitVector BitVector::BitAnd(const BitVector &other) const {
    if (width_ != other.width_) throw std::invalid_argument("bitvector AND width");
    BitVector result(width_);
    for (std::size_t index = 0; index < bytes_.size(); ++index)
        result.bytes_[index] = bytes_[index] & other.bytes_[index];
    return result;
}

BitVector BitVector::BitXor(const BitVector &other) const {
    if (width_ != other.width_) throw std::invalid_argument("bitvector XOR width");
    BitVector result(width_);
    for (std::size_t index = 0; index < bytes_.size(); ++index)
        result.bytes_[index] = bytes_[index] ^ other.bytes_[index];
    return result;
}

BitVector BitVector::Concat(const BitVector &right) const {
    if (width_ > (UINT64_C(1) << 20) - right.width_)
        throw std::invalid_argument("bitvector concat width");
    BitVector result(width_ + right.width_);
    for (std::size_t index = 0; index < right.width_; ++index)
        if (right.bit(index)) result.bytes_[index / 8] |=
            static_cast<std::uint8_t>(1U << (index % 8));
    for (std::size_t index = 0; index < width_; ++index) {
        const std::size_t destination = right.width_ + index;
        if (bit(index)) result.bytes_[destination / 8] |=
            static_cast<std::uint8_t>(1U << (destination % 8));
    }
    return result;
}

BitVector BitVector::BitAdd(const BitVector &other) const {
    if (width_ != other.width_) throw std::invalid_argument("bitvector ADD width");
    BitVector result(width_);
    std::uint16_t carry = 0;
    for (std::size_t index = 0; index < bytes_.size(); ++index) {
        const std::uint16_t sum = static_cast<std::uint16_t>(bytes_[index]) +
                                  other.bytes_[index] + carry;
        result.bytes_[index] = static_cast<std::uint8_t>(sum);
        carry = sum >> 8;
    }
    if (width_ % 8 != 0 && !result.bytes_.empty())
        result.bytes_.back() &= static_cast<std::uint8_t>((1U << (width_ % 8)) - 1U);
    return result;
}

BitVector BitVector::BitNot() const {
    BitVector result = *this;
    for (std::uint8_t &byte : result.bytes_) byte = static_cast<std::uint8_t>(~byte);
    if (width_ % 8 != 0 && !result.bytes_.empty())
        result.bytes_.back() &= static_cast<std::uint8_t>((1U << (width_ % 8)) - 1U);
    return result;
}

bool BitVector::operator==(const BitVector &other) const {
    return width_ == other.width_ && bytes_ == other.bytes_;
}

Value::Value(bool value) : storage_(value) {}
Value::Value(BigInteger value) : storage_(std::move(value)) {}
Value::Value(BitVector value) : storage_(std::move(value)) {}
Value::Value(EnumValue value) : storage_(value) {}
Value::Value(TupleValue value)
    : storage_(std::make_shared<TupleValue>(std::move(value))) {}
Value::Value(RecordValue value)
    : storage_(std::make_shared<RecordValue>(std::move(value))) {}
Value::Value(std::shared_ptr<PagedLazyArray> value)
    : storage_(std::move(value)) {}
const Value::Storage &Value::storage() const { return storage_; }
Value::Storage &Value::mutable_storage() { return storage_; }

Value Value::Clone() const {
    if (const auto *value = std::get_if<bool>(&storage_)) return Value(*value);
    if (const auto *value = std::get_if<BigInteger>(&storage_)) return Value(*value);
    if (const auto *value = std::get_if<BitVector>(&storage_)) return Value(*value);
    if (const auto *value = std::get_if<EnumValue>(&storage_)) return Value(*value);
    if (const auto *value = std::get_if<std::shared_ptr<TupleValue>>(&storage_)) {
        TupleValue copy;
        for (const Value &item : **value) copy.push_back(item.Clone());
        return Value(std::move(copy));
    }
    if (const auto *value = std::get_if<std::shared_ptr<RecordValue>>(&storage_)) {
        RecordValue copy;
        for (const auto &[field, item] : **value) copy.emplace(field, item.Clone());
        return Value(std::move(copy));
    }
    const auto &array = std::get<std::shared_ptr<PagedLazyArray>>(storage_);
    return Value(std::make_shared<PagedLazyArray>(*array));
}

PagedLazyArray::PagedLazyArray(DefaultFactory default_factory)
    : default_factory_(std::move(default_factory)) {
    if (!default_factory_) {
        throw std::invalid_argument("array default factory is required");
    }
}

Value PagedLazyArray::Get(std::uint64_t index) const {
    const std::uint64_t page_index = index / kPageSize;
    const auto page = pages_.find(page_index);
    if (page == pages_.end()) {
        return default_factory_(index);
    }
    return page->second->at(static_cast<std::size_t>(index % kPageSize));
}

void PagedLazyArray::Set(std::uint64_t index, Value value) {
    const std::uint64_t page_index = index / kPageSize;
    auto &page = pages_[page_index];
    if (!page) {
        auto created = std::make_shared<Page>();
        created->reserve(kPageSize);
        for (std::uint64_t offset = 0; offset < kPageSize; ++offset) {
            created->push_back(default_factory_(page_index * kPageSize + offset));
        }
        page = std::move(created);
    } else if (page.use_count() != 1) {
        page = std::make_shared<Page>(*page);
    }
    page->at(static_cast<std::size_t>(index % kPageSize)) = std::move(value);
}

}  // namespace pto::model

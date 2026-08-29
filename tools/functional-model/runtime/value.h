#ifndef PTO_FUNCTIONAL_MODEL_VALUE_H
#define PTO_FUNCTIONAL_MODEL_VALUE_H

#include <cstddef>
#include <cstdint>
#include <functional>
#include <map>
#include <memory>
#include <string>
#include <variant>
#include <vector>

namespace pto::model {

class BigInteger {
  public:
    BigInteger();
    explicit BigInteger(std::int64_t value);
    static BigInteger FromUnsignedWords(std::vector<std::uint32_t> words);
    BigInteger Add(const BigInteger &other) const;
    BigInteger Multiply(const BigInteger &other) const;
    bool Divide(const BigInteger &other, BigInteger *quotient) const;
    BigInteger Negated() const;
    int Compare(const BigInteger &other) const;
    bool IsZero() const;
    bool TryToU64(std::uint64_t *value) const;
    bool operator==(const BigInteger &other) const;
    std::string ToString() const;

  private:
    bool negative_ = false;
    std::vector<std::uint32_t> words_;
    void Normalize();
};

class BitVector {
  public:
    explicit BitVector(std::size_t width);
    static BitVector FromU64(std::size_t width, std::uint64_t value);
    BigInteger ToUnsignedInteger() const;
    BigInteger ToSignedInteger() const;
    std::size_t width() const;
    bool bit(std::size_t index) const;
    BitVector Slice(std::size_t start, std::size_t width) const;
    void SetSlice(std::size_t start,
                  std::size_t width,
                  const BitVector &replacement);
    bool TryToU64(std::uint64_t *value) const;
    BitVector BitOr(const BitVector &other) const;
    BitVector BitAnd(const BitVector &other) const;
    BitVector BitXor(const BitVector &other) const;
    BitVector Concat(const BitVector &right) const;
    BitVector BitAdd(const BitVector &other) const;
    BitVector BitNot() const;
    bool operator==(const BitVector &other) const;

  private:
    std::size_t width_;
    std::vector<std::uint8_t> bytes_;
};

struct EnumValue {
    std::uint32_t type_id;
    std::uint32_t member_id;
    bool operator==(const EnumValue &other) const = default;
};

class PagedLazyArray;
class Value;
using TupleValue = std::vector<Value>;
using RecordValue = std::map<std::uint32_t, Value>;

class Value {
  public:
    using Storage = std::variant<bool,
                                 BigInteger,
                                 BitVector,
                                 EnumValue,
                                 std::shared_ptr<TupleValue>,
                                 std::shared_ptr<RecordValue>,
                                 std::shared_ptr<PagedLazyArray>>;

    explicit Value(bool value);
    explicit Value(BigInteger value);
    explicit Value(BitVector value);
    explicit Value(EnumValue value);
    explicit Value(TupleValue value);
    explicit Value(RecordValue value);
    explicit Value(std::shared_ptr<PagedLazyArray> value);
    const Storage &storage() const;
    Storage &mutable_storage();
    Value Clone() const;

  private:
    Storage storage_;
};

class PagedLazyArray {
  public:
    using DefaultFactory = std::function<Value(std::uint64_t)>;
    static constexpr std::uint64_t kPageSize = 64;

    explicit PagedLazyArray(DefaultFactory default_factory);
    Value Get(std::uint64_t index) const;
    void Set(std::uint64_t index, Value value);

  private:
    using Page = std::vector<Value>;
    DefaultFactory default_factory_;
    std::map<std::uint64_t, std::shared_ptr<Page>> pages_;
};

}  // namespace pto::model

#endif

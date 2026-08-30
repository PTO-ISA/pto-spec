#include "trace_digest.h"

#include <algorithm>
#include <array>
#include <cstddef>
#include <cstdint>

namespace pto::model {
namespace {

constexpr std::array<std::uint32_t, 64> kRoundConstants = {
    UINT32_C(0x428a2f98), UINT32_C(0x71374491), UINT32_C(0xb5c0fbcf),
    UINT32_C(0xe9b5dba5), UINT32_C(0x3956c25b), UINT32_C(0x59f111f1),
    UINT32_C(0x923f82a4), UINT32_C(0xab1c5ed5), UINT32_C(0xd807aa98),
    UINT32_C(0x12835b01), UINT32_C(0x243185be), UINT32_C(0x550c7dc3),
    UINT32_C(0x72be5d74), UINT32_C(0x80deb1fe), UINT32_C(0x9bdc06a7),
    UINT32_C(0xc19bf174), UINT32_C(0xe49b69c1), UINT32_C(0xefbe4786),
    UINT32_C(0x0fc19dc6), UINT32_C(0x240ca1cc), UINT32_C(0x2de92c6f),
    UINT32_C(0x4a7484aa), UINT32_C(0x5cb0a9dc), UINT32_C(0x76f988da),
    UINT32_C(0x983e5152), UINT32_C(0xa831c66d), UINT32_C(0xb00327c8),
    UINT32_C(0xbf597fc7), UINT32_C(0xc6e00bf3), UINT32_C(0xd5a79147),
    UINT32_C(0x06ca6351), UINT32_C(0x14292967), UINT32_C(0x27b70a85),
    UINT32_C(0x2e1b2138), UINT32_C(0x4d2c6dfc), UINT32_C(0x53380d13),
    UINT32_C(0x650a7354), UINT32_C(0x766a0abb), UINT32_C(0x81c2c92e),
    UINT32_C(0x92722c85), UINT32_C(0xa2bfe8a1), UINT32_C(0xa81a664b),
    UINT32_C(0xc24b8b70), UINT32_C(0xc76c51a3), UINT32_C(0xd192e819),
    UINT32_C(0xd6990624), UINT32_C(0xf40e3585), UINT32_C(0x106aa070),
    UINT32_C(0x19a4c116), UINT32_C(0x1e376c08), UINT32_C(0x2748774c),
    UINT32_C(0x34b0bcb5), UINT32_C(0x391c0cb3), UINT32_C(0x4ed8aa4a),
    UINT32_C(0x5b9cca4f), UINT32_C(0x682e6ff3), UINT32_C(0x748f82ee),
    UINT32_C(0x78a5636f), UINT32_C(0x84c87814), UINT32_C(0x8cc70208),
    UINT32_C(0x90befffa), UINT32_C(0xa4506ceb), UINT32_C(0xbef9a3f7),
    UINT32_C(0xc67178f2)};

constexpr std::uint32_t RotateRight(std::uint32_t value, unsigned amount) {
  return (value >> amount) | (value << (32U - amount));
}

class Sha256State final {
public:
  void Update(const std::uint8_t *data, std::size_t size) {
    total_size_ += size;
    while (size != 0) {
      const std::size_t chunk = std::min(size, block_.size() - block_size_);
      std::copy_n(data, chunk, block_.begin() + block_size_);
      block_size_ += chunk;
      data += chunk;
      size -= chunk;
      if (block_size_ == block_.size()) {
        Transform();
        block_size_ = 0;
      }
    }
  }

  std::array<std::uint8_t, 32> Final() {
    const std::uint64_t bit_size = total_size_ * UINT64_C(8);
    block_[block_size_++] = UINT8_C(0x80);
    if (block_size_ > 56) {
      std::fill(block_.begin() + block_size_, block_.end(), 0);
      Transform();
      block_size_ = 0;
    }
    std::fill(block_.begin() + block_size_, block_.begin() + 56, 0);
    for (unsigned index = 0; index < 8; ++index) {
      block_[56 + index] =
          static_cast<std::uint8_t>(bit_size >> ((7U - index) * 8U));
    }
    Transform();

    std::array<std::uint8_t, 32> digest{};
    for (std::size_t index = 0; index < state_.size(); ++index) {
      for (unsigned byte = 0; byte < 4; ++byte) {
        digest[index * 4 + byte] =
            static_cast<std::uint8_t>(state_[index] >> ((3U - byte) * 8U));
      }
    }
    return digest;
  }

private:
  void Transform() {
    std::array<std::uint32_t, 64> words{};
    for (std::size_t index = 0; index < 16; ++index) {
      words[index] =
          (static_cast<std::uint32_t>(block_[index * 4]) << 24U) |
          (static_cast<std::uint32_t>(block_[index * 4 + 1]) << 16U) |
          (static_cast<std::uint32_t>(block_[index * 4 + 2]) << 8U) |
          static_cast<std::uint32_t>(block_[index * 4 + 3]);
    }
    for (std::size_t index = 16; index < words.size(); ++index) {
      const std::uint32_t s0 = RotateRight(words[index - 15], 7) ^
                               RotateRight(words[index - 15], 18) ^
                               (words[index - 15] >> 3U);
      const std::uint32_t s1 = RotateRight(words[index - 2], 17) ^
                               RotateRight(words[index - 2], 19) ^
                               (words[index - 2] >> 10U);
      words[index] = words[index - 16] + s0 + words[index - 7] + s1;
    }

    std::uint32_t a = state_[0];
    std::uint32_t b = state_[1];
    std::uint32_t c = state_[2];
    std::uint32_t d = state_[3];
    std::uint32_t e = state_[4];
    std::uint32_t f = state_[5];
    std::uint32_t g = state_[6];
    std::uint32_t h = state_[7];
    for (std::size_t index = 0; index < words.size(); ++index) {
      const std::uint32_t sum1 =
          RotateRight(e, 6) ^ RotateRight(e, 11) ^ RotateRight(e, 25);
      const std::uint32_t choose = (e & f) ^ ((~e) & g);
      const std::uint32_t temporary1 =
          h + sum1 + choose + kRoundConstants[index] + words[index];
      const std::uint32_t sum0 =
          RotateRight(a, 2) ^ RotateRight(a, 13) ^ RotateRight(a, 22);
      const std::uint32_t majority = (a & b) ^ (a & c) ^ (b & c);
      const std::uint32_t temporary2 = sum0 + majority;
      h = g;
      g = f;
      f = e;
      e = d + temporary1;
      d = c;
      c = b;
      b = a;
      a = temporary1 + temporary2;
    }
    state_[0] += a;
    state_[1] += b;
    state_[2] += c;
    state_[3] += d;
    state_[4] += e;
    state_[5] += f;
    state_[6] += g;
    state_[7] += h;
  }

  std::array<std::uint32_t, 8> state_ = {
      UINT32_C(0x6a09e667), UINT32_C(0xbb67ae85), UINT32_C(0x3c6ef372),
      UINT32_C(0xa54ff53a), UINT32_C(0x510e527f), UINT32_C(0x9b05688c),
      UINT32_C(0x1f83d9ab), UINT32_C(0x5be0cd19)};
  std::array<std::uint8_t, 64> block_{};
  std::size_t block_size_ = 0;
  std::uint64_t total_size_ = 0;
};

void UpdateU64LE(Sha256State *digest, std::uint64_t value) {
  std::array<std::uint8_t, 8> bytes{};
  for (unsigned index = 0; index < bytes.size(); ++index) {
    bytes[index] = static_cast<std::uint8_t>(value >> (index * 8U));
  }
  digest->Update(bytes.data(), bytes.size());
}

} // namespace

std::array<std::uint8_t, 32> Sha256Bytes(const std::uint8_t *data,
                                         std::size_t size) {
  Sha256State digest;
  digest.Update(data, size);
  return digest.Final();
}

std::array<std::uint8_t, 32>
DigestMemoryWrites(const std::vector<MemoryWrite> &writes) {
  static constexpr std::array<std::uint8_t, 24> kDomain = {
      'p', 't', 'o', '-', 'm', 'e', 'm', 'o', 'r', 'y', '-', 'w',
      'r', 'i', 't', 'e', '-', 'l', 'o', 'g', '-', 'v', '1', '\0'};
  Sha256State digest;
  digest.Update(kDomain.data(), kDomain.size());
  UpdateU64LE(&digest, writes.size());
  for (const MemoryWrite &write : writes) {
    UpdateU64LE(&digest, write.address);
    digest.Update(&write.value, 1);
  }
  return digest.Final();
}

} // namespace pto::model

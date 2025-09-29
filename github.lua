-- github.lua (ComputerCraft SHA-256 module without external bitlib) modified with the help of ChatGPT.
-- Self-contained bit ops
-- Credit to OGabrieLima on github for the original script https://github.com/OGabrieLima/lua-sha256

local github = {}

-- Bit ops for CC:Tweaked or Lua 5.1 (pure Lua)
local function band(a, b)
  local result = 0
  for i = 0, 31 do
    local bit = 2^i
    if a % (bit * 2) >= bit and b % (bit * 2) >= bit then
      result = result + bit
    end
  end
  return result
end

local function bor(a, b)
  local result = 0
  for i = 0, 31 do
    local bit = 2^i
    if a % (bit * 2) >= bit or b % (bit * 2) >= bit then
      result = result + bit
    end
  end
  return result
end

local function bxor(a, b)
  local result = 0
  for i = 0, 31 do
    local bit = 2^i
    local abit = a % (bit * 2) >= bit
    local bbit = b % (bit * 2) >= bit
    if abit ~= bbit then
      result = result + bit
    end
  end
  return result
end

local function bnot(x)
  return 0xFFFFFFFF - x
end

local function rshift(x, n)
  return math.floor(x / 2^n)
end

local function lshift(x, n)
  return (x * 2^n) % 0x100000000
end

local function rrotate(x, n)
  return bor(rshift(x, n), lshift(x, 32 - n))
end

-- SHA-256 function
function github.sha256(message)
  local k = {
    0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
    0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3, 0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
    0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
    0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
    0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13, 0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
    0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
    0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
    0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208, 0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2
  }

  local function preprocess(msg)
    local len = #msg
    local bitLen = len * 8
    msg = msg .. string.char(0x80)

    local padLen = 64 - ((len + 9) % 64)
    msg = msg .. string.rep("\0", padLen)

    local high = math.floor(bitLen / 0x100000000)
    local low = bitLen % 0x100000000

    for i = 3, 0, -1 do msg = msg .. string.char(band(rshift(high, i * 8), 0xFF)) end
    for i = 3, 0, -1 do msg = msg .. string.char(band(rshift(low, i * 8), 0xFF)) end

    return msg
  end

  local function processChunk(chunk, hash)
    local w = {}
    for i = 1, 16 do
      local j = (i - 1) * 4 + 1
      w[i] = bor(
        lshift(string.byte(chunk, j), 24),
        lshift(string.byte(chunk, j + 1), 16),
        lshift(string.byte(chunk, j + 2), 8),
        string.byte(chunk, j + 3)
      )
    end

    for i = 17, 64 do
      local s0 = bxor(rrotate(w[i - 15], 7), rrotate(w[i - 15], 18), rshift(w[i - 15], 3))
      local s1 = bxor(rrotate(w[i - 2], 17), rrotate(w[i - 2], 19), rshift(w[i - 2], 10))
      w[i] = band(w[i - 16] + s0 + w[i - 7] + s1, 0xFFFFFFFF)
    end

    local a, b, c, d, e, f, g, h = table.unpack(hash)

    for i = 1, 64 do
      local S1 = bxor(rrotate(e, 6), rrotate(e, 11), rrotate(e, 25))
      local ch = bxor(band(e, f), band(bnot(e), g))
      local temp1 = band(h + S1 + ch + k[i] + w[i], 0xFFFFFFFF)
      local S0 = bxor(rrotate(a, 2), rrotate(a, 13), rrotate(a, 22))
      local maj = bxor(band(a, b), band(a, c), band(b, c))
      local temp2 = band(S0 + maj, 0xFFFFFFFF)

      h = g
      g = f
      f = e
      e = band(d + temp1, 0xFFFFFFFF)
      d = c
      c = b
      b = a
      a = band(temp1 + temp2, 0xFFFFFFFF)
    end

    return {
      band(hash[1] + a, 0xFFFFFFFF),
      band(hash[2] + b, 0xFFFFFFFF),
      band(hash[3] + c, 0xFFFFFFFF),
      band(hash[4] + d, 0xFFFFFFFF),
      band(hash[5] + e, 0xFFFFFFFF),
      band(hash[6] + f, 0xFFFFFFFF),
      band(hash[7] + g, 0xFFFFFFFF),
      band(hash[8] + h, 0xFFFFFFFF)
    }
  end

  message = preprocess(message)

  local hash = {
    0x6a09e667,
    0xbb67ae85,
    0x3c6ef372,
    0xa54ff53a,
    0x510e527f,
    0x9b05688c,
    0x1f83d9ab,
    0x5be0cd19
  }

  for i = 1, #message, 64 do
    local chunk = message:sub(i, i + 63)
    hash = processChunk(chunk, hash)
  end

  local result = ""
  for _, h in ipairs(hash) do
    result = result .. string.format("%08x", h)
  end
  return result
end

return github

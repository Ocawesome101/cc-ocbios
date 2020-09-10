-- A completely custom BIOS for CC: Tweaked. Loads OSes from disk. --

-- expect
do
  local type = type
  function _G.expect(n, have, ...)
    assert(type(n) == "number", "bad argument #1 to 'expect' (number expected, got "..type(n)..")")
    local function check(want, ...)
      if not want then
        return false
      else
        return have == want or check(...)
      end
    end
    if not check(...) then
      error(string.format("bad argument #%d (%s expected, got %s)", n, table.concat(table.pack(...), " or "), type(have)), 3)
    end
  end
end

-- Lua 5.2 maybe 5.3 things, remove loadstring
if _VERSION == "Lua 5.1" then
  local nload, nloadstr, nsfenv = load, loadstring, setfenv
  
  function load(x, name, mode, env)
    expect(1, x, "string", "function")
    expect(2, name, "string", "nil")
    expect(3, mode, "string", "nil")
    expect(4, env, "table", "nil")
    local res, err
    if type(x) == "string" then
      res, err = nloadstr(x)
    else
      res, err = nload(x, name)
    end
    if res then
      if env then
        env._ENV = env
        nsfenv(res, env)
      end
      return res
    else
      return nil, err
    end
  end
  
  table.unpack = table.unpack or unpack
  table.pack = table.pack or function(...) return {n = select("#", ...), ...} end
  
  getfenv, setfenv, loadstring, unpack, math.log10, table.maxn = nil, nil, nil, nil, nil, nil
  
  if bit then -- replace bit with bit32
    local nbit = bit
    _G.bit32 = {}
    bit32.arshift = nbit.brshift
    bit32.band = nbit.band
    bit32.bnot = nbit.bnot
    bit32.bor = nbit.bor
    bit32.btest = function(a, b) return nbit.band(a, b) ~= 0 end
    bit32.bxor = nbit.bxor
    bit32.lshift = nbit.blshift
    bit32.rshift = nbit.blogic_rshift
    _G.bit = nil
  end
end

-- I have chosen to omit os.* and globals

local function loadfile(f)
  local f = fs.open(filename, "r")
end

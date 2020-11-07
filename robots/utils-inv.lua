local inv = require("component").inventory_controller
local sides = require("sides")
local r = require("robot")
local s = require("serialization").serialize

assert(inv ~= nil, "inventory controller not found")

local function findItem(invSize, name, damage, f)
  for s=1, invSize do
    local i = f(s)
    if i ~= nil then
      if i.name == name then
        if damage ~= nil then
          if i.damage == damage then
            return s
          end
        else
          return s
        end
      end
    end
  end
  error("Failed to find item: " .. name .. "/" .. tostring(damage))
end

function findInternalItem(name, damage)
  assert(type(name) == "string")
  assert(damage == nil or type(damage) == "number")
  return findItem(r.inventorySize(), name, damage, inv.getStackInInternalSlot)
end

function findExternalItem(dir, name, damage)
  assert(type(dir) == "number")
  assert(type(name) == "string")
  assert(damage == nil or type(damage) == "number")
  local f = function(s) return inv.getStackInSlot(dir, s) end
  return findItem(inv.getInventorySize(dir), name, damage, f)
end

function stockUp(dir, targetLevels)
  assert(type(dir) == "string")
  assert(type(targetLevels) == "table")
  local dirNum = sides[dir]
  for _, t in pairs(targetLevels) do
    assert(t.name ~= nil)
    if t.count == nil then
      t.count = 1
    end
    if t.slot == nil then
      t.slot = findInternalItem(t.name)
    end
    r.select(t.slot)
    local need = t.count
    local item = inv.getStackInInternalSlot(t.slot)
    if item ~= nil then
      if item.name ~= t.name or t.damage ~= nil and item.damage ~= t.damage then
         r.drop() or r.dropDown()
      else
        need = t.count - item.size
      end
    end
    if need > 0 then
      local remoteSlot = findExternalItem(dirNum, t.name, t.damage)
      assert(remoteSlot ~= nil)
      inv.suckFromSlot(dirNum, remoteSlot, need)
      assert(inv.getStackInInternalSlot(t.slot).size >= t.count)
    end
  end
end

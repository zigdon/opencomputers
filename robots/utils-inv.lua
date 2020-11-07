local inv = require("component").inventory_controller
local r = require("robot")

assert(inv ~= nil, "inventory controller not found")

local target = {
  -- { name, [count], [slot], [damage]}
  { name="minecraft:iron_block", count=10, slot=1 },
  { name="minecraft:redstone",   count=20, slot=2 },
  { name="compactmachines3:wallbreakable", count=64, slot=3 },
  { name="compactmachines3:wallbreakable", count=64, slot=4 },
  { name="minecraft:emerald_block", slot=5 },
  { name="minecraft:ender_pearl", slot=6 },
}

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
  error("Failed to find item: " .. name .. "/" .. damage)
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
  local f = function(s) return inv.getStackInInventory(dir, s) end
  return findItem(inv.getInventorySize(dir), name, damage, f)
end

function stockUp(dir, targetLevels)
  assert(type(targetLevels) == "table")
  for _, t in pairs(targetLevels) do
    assert(t.name ~= nil)
    if t.count == nil then
      t.count = 1
    end
    if t.damage == nil then
      t.damage = 0
    end
    if t.slot == nil then
      t.slot = findInternalItem(t.name)
    end
    r.select(t.slot)
    local need = t.count
    local item = inv.getStackInInternalSlot(t.slot)
    if item ~= nil then
      if not (
         item.name == t.name and
         item.damage == t.damage
      ) then
         r.drop()
      end
      need = t.count - item.size
    end
    if need > 0 then
      local remoteSlot = findExternalItem(dir)
      inv.suckFromSlot(dir, remoteSlot, need)
      assert(inv.getStackInInternalSlot(t.slot).size >= t.count)
    end
  end
end

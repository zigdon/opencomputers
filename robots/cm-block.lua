require("utils-inv")
require("utils-nav")
r = require("robot")

local blockStock = {
  { name="minecraft:iron_block", count=10, slot=1 },
  { name="minecraft:redstone",   count=20, slot=2 },
}

local function build()
  r.select(1) -- iron block
  r.place()
  r.up()
  r.select(2) -- redstone
  r.place()
end

local function toss()
  r.select(2)
  r.drop(1)
end

local function collect()
  move("south", 4)
  move("west", 2)
  local waited = 0
  while waited < 5 do
    if r.suckDown() or r.suckUp() then
      return
    end
  end
  error("never found the blocks")
end

goToWaypoint("store")
turnTo("east")
stockUp("front", blockStock)

local args = {...}
local count = 1

if args[1] ~= nil then
  count = args[1]
end

for i=1,count do
  goToWaypoint("CM")
  turnTo("south")
  r.forward()
  r.down()
  build()
  r.back()
  toss()
  collect()
end

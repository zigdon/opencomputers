require("utils-nav")
r = require("robot")
s = require("serialization").serialize
nav = require("component").navigation
comp = require("computer")
sides = require("sides")

start = {locVal()}
facing = nav.getFacing()

local way = goToWaypoint("charger")
r.down()
turnTo("south")
r.use()
r.down()
local charging = true
local oldEnergy = comp.energy()
local maxEnergy = comp.maxEnergy()
while charging do
  os.sleep(0.1)
  local curEnergy = comp.energy()
  if curEnergy < oldEnergy then
    error("not charging!")
  end
  local level = curEnergy / maxEnergy
  charging = level < 0.95
  print("Charging... " .. level)
end
print("Charged!")
r.up()
r.use()
r.up()
print("backtracking: " .. s(way, 30))
backtrack(way)
turnTo(sides[facing])

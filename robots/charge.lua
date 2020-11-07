require("utils")
r = require("robot")
s = require("serialization").serialize
nav = require("component").navigation
comp = require("computer")
sides = require("sides")

start = {locVal()}
facing = nav.getFacing()

waypoint = getWaypoint("charger")
if waypoint == nil then
  print("Can't find charger!")
  os.exit(0)
end
print("Found charger at " .. s(waypoint))

local way = goTo(waypoint.position, true)
r.down()
turnTo("posz")
r.use()
r.down()
local charging = true
while charging do
  local level = comp.energy() / comp.maxEnergy()
  charging = level < 0.9
  print("Charging... " .. level)
end
print("Charged!")
r.up()
r.use()
r.up()
print("backtracking: " .. s(way, 30))
backtrack(way)
turnTo(sides[facing])

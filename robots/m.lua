local com = require("component")
local sides = require("sides")
r = com.robot
arg = {...}

aliases = {
  f="front",
  b="back",
  d="down",
  u="up",
  l="left",
  r="right",
}

count = 1
for _, d in pairs(arg) do
  if aliases[d] ~= nil then d = aliases[d] end
  if tonumber(d) ~= nil then
    count = tonumber(d)
  else
    for i=1, count do
      if d == "right" or d == "left" then
        r.turn(d == "right")
      else
        r.move(sides[d])
      end
    end
    count = 1
  end
end

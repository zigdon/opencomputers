local r = require("robot")
local serialization = require("serialization")
local sides = require("sides")

local nav = require("component").navigation
local serialize = serialization.serialize

assert(nav ~= nil, "no navigation module found.")

local logFile = nil
function setLog(name)
  logFile = io.open(name, "a")
end

function log(msg)
  print(msg)
  if logFile ~= nil then
    logFile:write(msg .. "\n")
  end
end

function locVal()
  x, y, z = nav.getPosition()
  return x - 0.5, y - 0.5, z - 0.5
end

function loc()
  return table.concat({locVal()}, "/")
end

function move(dir, distance)
  assert(type(dir) == "string", "move takes a string argument")
  log(distance .. " steps heading " .. dir)
  targetFace = sides[dir]
  if targetFace == nil then
    error("Bad direction to move: " .. dir)
  end

  if distance == nil then
    distance = 1
  end

  log("starting from " .. loc())
  turnTo(dir)

  went = 0
  go = r.forward
  if targetFace == sides.top then
    go = r.up
  elseif targetFace == sides.bottom then
    go = r.down
  end

  while went < distance do
    if go() then
      went = went + 1
    else
      log("Can't go further after " .. went .. " steps. Now at " .. loc())
      return went
    end
  end

  log("Now at " .. loc())
  return went
end

function turnTo(dir)
  assert(type(dir) == "string", "turnTo takes a string argument")
  target = sides[dir]
  if target == sides.up or target == sides.down then
    log("not turning " .. dir)
    return
  end
  log("turning to " .. sides[target] .. ", currently facing " .. sides[nav.getFacing()])
  spin = 0
  while nav.getFacing() ~= target and spin < 4 do
    r.turnLeft()
    spin = spin + 1
  end
  if spin == 4 then
    error("spinning trying to turn to " .. dir)
  end
end

function goTo(destination, relative)
  if relative == nil then
    relative = false
  end

  local delta
  local cur = {}
  local dest = {}

  if relative then
    cur.x, cur.y, cur.z = locVal()
    dest.x = cur.x + destination[1]
    dest.y = cur.y + destination[2]
    dest.z = cur.z + destination[3]
  else
    dest.x, dest.y, dest.z = destination[1], destination[2], destination[3]
  end
  log("going to " .. serialize(dest) .. " from " .. loc())
  local moving = true
  local path = {}
  while moving do
    moving = false
    cur.x, cur.y, cur.z = locVal()
    delta = {
      x = dest.x - cur.x,
      y = dest.y - cur.y,
      z = dest.z - cur.z,
    }
    log("delta: " .. serialize(delta))

    for _, k in pairs({"x", "y", "z"}) do
      local sign = nil
      if delta[k] > 0 then
        sign = "pos"
        dist = delta[k]
      elseif delta[k] < 0 then
        sign = "neg"
        dist = 0 - delta[k]
      end

      if sign ~= nil then
        log("moving " .. dist .. " in direction " .. sign .. k)
        moved = move(sign .. k, dist)
        moving = moving or (moved > 0)
        if moved > 0 then
          table.insert(path, {sign=sign, dim=k, steps=moved})
        end
        log("moved " .. moved .. ", now at " .. loc())
      end
    end
  end
  log("path: " .. serialize(path, 30))
  return path
end

function goToWaypoint(name)
  waypoint = getWaypoint(name)
  if waypoint == nil then
    error("Can't find waypoint: " .. name)
  end
  log("Found " .. name .. " at " .. s(waypoint))

  return goTo(waypoint.position, true)
end

function backtrack(path)
  assert(path ~= nil)
  while #path > 0 do
    local next = table.remove(path)
    log("Next step: " .. serialize(next))
    local sign = "pos"
    if next.sign == "pos" then
      sign = "neg"
    end
    assert(move(sign .. next.dim, next.steps) == next.steps)
  end
end

function getWaypoint(name, distance)
  if distance == nil then
    distance = 20
  end
  local waypoints = nav.findWaypoints(distance)
  for _, w in pairs(waypoints) do
    if type(w) ~= "table" then
      error("waypoints returned: " .. w)
    end
    if w.label == name then
      return w
    end
  end
  return nil
end

return true

require("utils-nav")
require("utils-inv")
local r = require("robot")
local com = require("component")
local inv = com.inventory_controller

local cubeStock = {
  { name="compactmachines3:wallbreakable", count=64, slot=3 },
  { name="compactmachines3:wallbreakable", count=64, slot=4 },
  { name="minecraft:emerald_block", slot=5 },
  { name="minecraft:ender_pearl", slot=6 },
}

local function toss(x)
  r.select(x)
  r.drop(1)
end

function placeBlock()
  local stack = 3
  if inv.getStackInInternalSlot(3) == nil then
    stack = 4
  end
  r.select(stack)
  r.placeDown()
end

function buildLine(l)
  for y=1, l do
    placeBlock()
    r.forward()
  end
end
local function cr()
  move("west")
  move("north", 5)
end

local function buildSolid()
  for x=1, 5 do
    buildLine(5)
    cr()
  end
  move("east", 5)
end

function buildBorder(extra)
  for s =1, 4 do
    buildLine(4)
    r.turnRight()
  end
  if extra then
    move("west", 2)
    move("south")
    placeBlock()
    r.forward()
    r.select(5)
    r.placeDown()
    r.back()
    r.swingDown()
    r.back()
    move("east", 2)
  end
end

goToWaypoint("store")
turnTo("east")
stockUp("front", cubeStock)
goToWaypoint("CM")
move("", 2)
buildSolid()
move("up")
buildBorder(false)
move("up")
buildBorder(true)
move("up")
buildBorder(false)
move("up")
buildSolid()
goToWaypoint("CM")
toss(6)

r = require("robot")

local function move(f)
  if f() then
    return
  end
  print("Couldn't move!")
  die()
end

local function approach()
  move(r.forward)
  move(r.down)
end

local function build()
  r.select(2) -- iron block
  r.place()
  r.up()
  r.select(1) -- redstone
  r.place()
end

local function toss()
  r.drop(1)
end

local args = {...}
local count = 1

if args[1] ~= nil then
  count = args[1]
end

for i=1,count do
  approach()
  build()
  r.back()
  toss()
  os.sleep(5)
end
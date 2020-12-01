local Block = Object:extend()
local entities = require "entities"
local bigmap = require "bigmap"
function Block:new(x, y, id, breakable)
    self.x = x
    self.y = y
    self.breakable = breakable
    self.width = 48
    self.height = 48
    self.isBlock = true
    self.id = id
    self.hp = 3
    self.t = math.floor((self.y + self.height/2)/-672) + 2
    self.xid = math.floor((self.x + self.width/2)/48) + 1
    self.yid = math.floor( ( (self.y + self.height/2) % 672) /48) + 1
    world:add(self, self.x, self.y, self.width, self.height)
end

function Block:update(dt)
    if self.hp <= 0 then
        self:updateBigMap()
        self:boom()
    end
end

function Block:updateBigMap()
    --print(bigmap[self.t].unit[self.yid][self.xid])
    bigmap[self.t].unit[self.yid][self.xid] = 1
end

function Block:boom()
    for i = #entities, 1, -1 do
        if entities[i] == self then
            world:remove(self)
            table.remove(entities, i)
        end
    end
end

function Block:draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(tileImgs, tileQuads[self.id], self.x + self.width/2, self.y + self.height/2, 0, 3, 3, 8, 8)
end

return Block
local SpikeBall = Object:extend()
local entities = require "entities"
function SpikeBall:new(x, y)
    self.x = x
    self.y = y
    self.width = 48
    self.height = 48
    self.isSpikeBall = true
    self.hp = 3
    self.scale = 2
    self.dead = false
    self.grid = anim8.newGrid(35, 36, 245, 36)
    self.anim = anim8.newAnimation(self.grid('1-7', 1), 0.05)
    self.t = math.floor((self.y + self.height/2)/-672) + 2
    self.xid = math.floor((self.x + self.width/2)/48) + 1
    self.yid = math.floor( ( (self.y + self.height/2) % 672) /48) + 1
    world:add(self, self.x, self.y, self.width, self.height)
end

function SpikeBall:updateBigMap()
    --print(bigmap[self.t].unit[self.yid][self.xid])
    bigmap[self.t].unit[self.yid][self.xid] = 1
end

function SpikeBall:update(dt)
    if self.dead == false then
        if self.scale > 2 then
            self.scale = self.scale - 0.1
        else
            self.scale = 2
        end
        if self.hp <= 0 then
            self:updateBigMap()
            self.dead = true
            explosionSound:stop()
            explosionSound:play()
            gemNum = gemNum + 1
            camera:shake(8, 1, 60)
        end
    else  
        self.anim:update(dt)
        if self.anim.position == 7 then
            self:boom()
        end
    end
end

function SpikeBall:boom()
    for i = #entities, 1, -1 do
        if entities[i] == self then
            world:remove(self)
            table.remove(entities, i)
        end
    end
end

function SpikeBall:draw()
    love.graphics.setColor(1, 1, 1)
    --love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
    if self.dead == false then
        love.graphics.draw(spikeBallImg, self.x + self.width/2, self.y + self.height/2, 0, self.scale, self.scale, 14, 14)
    else
        self.anim:draw(explosionImg, self.x + self.width/2, self.y + self.height/2, 0, 4, 4, 18, 17.5)
    end
end

return SpikeBall
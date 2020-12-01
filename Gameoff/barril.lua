local Barril = Object:extend()
local entities = require "entities"

function Barril:new(x, y)
    self.x = x
    self.y = y
    self.width = 48
    self.height = 48
    self.isBarril = true
    self.scale = 2
    self.hp = 10
    self.dead = false
    self.grid = anim8.newGrid(35, 36, 245, 36)
    self.anim = anim8.newAnimation(self.grid('1-7', 1), 0.05)
    self.t = math.floor((self.y + self.height/2)/-672) + 2
    self.xid = math.floor((self.x + self.width/2)/48) + 1
    self.yid = math.floor( ( (self.y + self.height/2) % 672) /48) + 1
    world:add(self, self.x, self.y, self.width, self.height)
end

function Barril:updateBigMap()
    --print(bigmap[self.t].unit[self.yid][self.xid])
    bigmap[self.t].unit[self.yid][self.xid] = 1
end

local function explosionFilter(item)
    if item.isBlock then
        return true
    elseif item.isPlayer then
        return true
    end
end

function Barril:update(dt)
    if self.dead == false then
        if self.scale > 2 then
            self.scale = self.scale - 0.1
        end
        if self.hp <= 0 then
            self:updateBigMap()
            self.dead = true
            gemNum = gemNum + 1
            camera:shake(8, 1, 60)
            explosionSound:stop()
            explosionSound:play()
            local items, len = world:queryRect(self.x + self.width/2 - 48*3/2,self.y + self.height/2 - 48*3/2,48*3,48*3, explosionFilter)
            for i = len, 1, -1 do
                if items[i].isBlock then
                    items[i].hp = items[i].hp - 5
                elseif items[i].isPlayer then
                    items[i].hp = items[i].hp - 1
                    hitSound:stop()
                    hitSound:play()
                    if gemNum >= 5 then
                        gemNum = gemNum - 5
                    end
                    camera:flash(0.2, {1, 0, 0, 0.5})
                end
            end
        end
    else
        self.anim:update(dt)
        if self.anim.position == 7 then
            self:boom()
        end
    end
end

function Barril:boom()
    for i = #entities, 1, -1 do
        if entities[i] == self then
            world:remove(self)
            table.remove(entities, i)
        end
    end
end
function Barril:draw()
    love.graphics.setColor(1, 1, 1)
    if self.dead == false then
        --love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
        love.graphics.draw(barrilImg, self.x + self.width/2, self.y + self.height/2, 0, self.scale, self.scale, 12.5, 12.5)
    else
        self.anim:draw(explosionImg, self.x + self.width/2, self.y + self.height/2, 0, 4, 4, 18, 17.5)
    end
end

return Barril
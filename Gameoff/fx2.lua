local Fx2 = Object:extend()
local entities = require "entities"
function Fx2:new(x, y)
    self.x = x
    self.y = y
    self.width = 34
    self.height = 34
    self.isFx2 = true
    self.grid = anim8.newGrid(34, 34, 204, 34)
    self.anim = anim8.newAnimation(self.grid('1-6', 1), 0.07)
end

function Fx2:update(dt)
    self.anim:update(dt)
    if self.anim.position == 6 then
        self:boom()
    end
end

function Fx2:boom()
    for i = #entities, 1, -1 do
        if entities[i] == self then
            table.remove(entities, i)
        end
    end
end

function Fx2:draw()
    love.graphics.setColor(1, 1, 0)
    self.anim:draw(fx2Img, self.x + self.width/2, self.y + self.height/2, 0, 1, 1, 17, 17)
end

return Fx2
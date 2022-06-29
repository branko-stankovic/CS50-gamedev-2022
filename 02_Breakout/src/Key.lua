--[[
    GD50
    Breakout Remake

    --  Key Class --

    Author: Branko Stankovic
    branko.stankovic@gmail.com

    Represents a key that if collides with a player paddle, unlocks a locked brick.
]]

Key = Class{}

function Key:init()
    self.width = 16
    self.height = 16

    self.dy = 0
    self.dx = 0

    self.x = love.math.random(0, VIRTUAL_WIDTH - 16)
    self.y = -16
end

function Key:reset()
    self.dy = 0
    self.dx = 0

    self.x = love.math.random(0, VIRTUAL_WIDTH - 16)
    self.y = -16
end

function Key:collides(target)
    if self.x > target.x + target.width or target.x > self.x + self.width then
        return false
    end

    if self.y > target.y + target.height or target.y > self.y + self.height then
        return false
    end

    return true
end

function Key:update(dt)
    self.x = self.x + self.dx * dt
    self.y = self.y + self.dy * dt

    if self.y > WINDOW_HEIGHT then
        key:reset()
    end
end

function Key:render()
    love.graphics.draw(gTextures['main'], gFrames['key'][1], self.x, self.y)
end

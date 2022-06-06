--[[
    PlayState Class
    Author: Colton Ogden
    cogden@cs50.harvard.edu
    The PlayState class is the bulk of the game, where the player actually controls the bird and
    avoids pipes. When the player collides with a pipe, we should go to the GameOver state, where
    we then go back to the main menu.
]]

PlayState = Class{__includes = BaseState}

PIPE_SPEED = 60
PIPE_WIDTH = 70
PIPE_HEIGHT = 288

BIRD_WIDTH = 38
BIRD_HEIGHT = 24

function PlayState:init()
    self.bird = Bird()
    self.pipePairs = {}
    self.timer = 0
    self.score = 0

    -- initialize our last recorded Y value for a gap placement to base other gaps off of
    self.lastY = -PIPE_HEIGHT + math.random(80) + 20

    -- randomizing the pipePair spawn interval
    --
    -- spawn interval is still random, but runs in cycles, getting progressively harder and
    -- harder, and when the cycle resets it gets easier once again at the beginning of the
    -- cycle, then getting harder and harder again
    self.nextPipeInterval = 2
    self.spawnCycleLength = 10
    self.minSpawnInterval = 1.5
    self.maxSpawnInterval = 11
end

function PlayState:update(dt)
    -- player can now pause the game
    if love.keyboard.wasPressed('p') then
        if paused then
            sounds['music']:play()
            paused = false
        else
            sounds['music']:pause()
            paused = true
        end
    end

    -- if the game has been paused, do not move anything on the screen
    if paused then
        return
    end

    -- update timer for pipe spawning
    self.timer = self.timer + dt

    -- spawn first pair of pipes after 2 seconds
    if self.timer > self.nextPipeInterval then
        -- set the next pipePair timing
        -- pipePair spawn interval is a random number between min and max spawn interval, minus the current player score
        -- so it gets harder and harder with score getting higher, but runs on a cycle via mod operator, so the player gets
        -- a break after a hard part of the level
        -- also, spawn interval is hard capped to be minimum of 2, so it doesn't get too close
        self.nextPipeInterval = math.max(self.minSpawnInterval, love.math.random(self.minSpawnInterval, self.maxSpawnInterval) - (self.score % self.spawnCycleLength))

        -- modify the last Y coordinate we placed so pipe gaps aren't too fat apart
        -- no higher than 10 pixels below the top edge of the screen,
        -- and no lower than a gap length (90 pixels) from the bottom
        local y = math.max(-PIPE_HEIGHT + 20, math.min(self.lastY + love.math.random(-20 - self.nextPipeInterval, 20 + self.nextPipeInterval), VIRTUAL_HEIGHT - 90 - PIPE_HEIGHT))
        self.lastY = y

        -- add a new pipe pair at the end of the screen at our new Y
        table.insert(self.pipePairs, PipePair(y))

        -- reset timer
        self.timer = 0
    end

    -- for every pair of pipes
    for k, pair in pairs(self.pipePairs) do
        -- score a point if the pipe has gone past the bird to the left all the way
        -- be sure to ignore it if it's already been scored
        if not pair.scored then
            if pair.x + PIPE_WIDTH < self.bird.x then
                self.score = self.score + 1
                pair.scored = true
                sounds['score']:play()
            end
        end

        -- update position of pair
        pair:update(dt)
    end

    -- we need this second loop, rather than deleting in the previous loop, because
    -- modifying the table in-place without explicit keys will result in skipping the
    -- next pipe, since all implicit keys (numerical indices) are automatically shifted
    -- down after a table removal
    for k, pair in pairs(self.pipePairs) do
        if pair.remove then
            table.remove(self.pipePairs, k)
        end
    end

    -- simple collision between bird and all pipes in pairs
    for k, pair in pairs(self.pipePairs) do
        for l, pipe in pairs(pair.pipes) do
            if self.bird:collides(pipe) then
                sounds['explosion']:play()
                sounds['hurt']:play()

                gStateMachine:change('score', {
                    score = self.score
                })
            end
        end
    end

    -- update bird based on gravity and input
    self.bird:update(dt)

    -- reset if we get to the ground
    if self.bird.y > VIRTUAL_HEIGHT - 15 then
        sounds['explosion']:play()
        sounds['hurt']:play()

        gStateMachine:change('score', {
            score = self.score
        })
    end
end

function PlayState:render()
    for k, pair in pairs(self.pipePairs) do
        pair:render()
    end

    love.graphics.setFont(flappyFont)
    love.graphics.print('Score: ' .. tostring(self.score), 8, 8)

    self.bird:render()

    if paused then
        love.graphics.setFont(flappyFont)
        love.graphics.printf('PAUSED', 0, 64, VIRTUAL_WIDTH, 'center')

        love.graphics.setFont(mediumFont)
        love.graphics.printf('Press P to unpause', 0, 100, VIRTUAL_WIDTH, 'center')
    end
end

--[[
    Called when this state is transitioned to from another state.
]]
function PlayState:enter()
    -- if we're coming from death, restart scrolling
    scrolling = true
end

--[[
    Called when this state changes to another state.
]]
function PlayState:exit()
    -- stop scrolling for the death/score screen
    scrolling = false
end

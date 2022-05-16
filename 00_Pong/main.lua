-- push is a library that will allow us to draw our game at a virtual
-- resolution, instead of howere large our window is; used to provide
-- a more retro aesthetic
--
-- https://github.com/Ulydev/push
push = require 'push'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

-- [[ Runs when the game first starts up ]]
function love.load()
    -- use nearest-neighbor filtering
    love.graphics.setDefaultFilter('nearest', 'nearest')

    smallFont = love.graphics.newFont('font.ttf', 8)

    love.graphics.setFont(smallFont)

    -- initialize our virtual resolution, which will be rendered within our
    -- actual window no matter its dimensions; replaces our love.window.setMode
    -- from last example
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = false,
        vsync = true
    })
end

-- [[ keyboard input handling, called each frame]]
function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    end
end

-- [[ called after update, used to draw anything on screen, updated or not ]]
function love.draw()
    -- begin rendering at virtual resolution
    push:apply('start')

    -- clear the screen with the specific color
    love.graphics.clear(0.15, 0.17, 0.2, 1)

    -- draw welcome text toward the top of the screen
    love.graphics.printf('Hello Pong!', 0, 20, VIRTUAL_WIDTH, 'center')

    --
    -- paddles are simply rectangles we draw on the screen at certain points,
    -- as is the ball
    --
    -- render first paddle (left side)
    love.graphics.rectangle('fill', 10, 30, 5, 20)

    -- render second paddle (right side)
    love.graphics.rectangle('fill', VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 50, 5, 20)

    -- render ball (center)
    love.graphics.rectangle('fill', VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)

    -- end rendering at virtual resolution
    push:apply('end')
end

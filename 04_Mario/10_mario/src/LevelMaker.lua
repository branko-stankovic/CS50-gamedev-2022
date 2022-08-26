--[[
    GD50
    Super Mario Bros. Remake

    -- LevelMaker Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

LevelMaker = Class{}

function LevelMaker.generate(width, height)
    local tiles = {}
    local entities = {}
    local objects = {}

    local tileID = TILE_ID_GROUND

    -- whether we should draw our tiles with toppers
    local topper = true
    local tileset = math.random(20)
    local topperset = math.random(20)

    -- insert blank tables into tiles for later access
    for x = 1, height do
        table.insert(tiles, {})
    end

    -- column by column generation instead of row; sometimes better for platformers
    for x = 1, width do
        local tileID = TILE_ID_EMPTY

        -- lay out the empty space
        for y = 1, 6 do
            table.insert(tiles[y], Tile(x, y, tileID, nil, tileset, topperset))
        end

        -- chance to just be emptiness
        if love.math.random(7) == 1 then
            for y = 7, height do
                table.insert(tiles[y], Tile(x, y, tileID, nil, tileset,topperset))
            end
        else
            tileID = TILE_ID_GROUND

            -- height at which we would spawn a potential jump block
            local blockHeight = 4

            for y = 7, height do
                table.insert(tiles[y], Tile(x, y, tileID, y == 7 and topper or nil, tileset, topperset))
            end

            -- chance to generate a pillar
            if math.random(8) == 1 then
                blockHeight = 2

                -- chance to generate bush on pillar
                if math.random(9) == 1 then
                    table.insert(objects,
                        GameObject {
                            texture = 'bushes',
                            x = (x - 1) * TILE_SIZE,
                            y = (4 - 1) * TILE_SIZE,
                            width = 16,
                            height = 16,

                            -- select random frame from bush_ids whitelist, then random row for variance
                            frame = BUSH_IDS[math.random(#BUSH_IDS)] + (math.random(4) - 1) * 7,
                            collidable = false
                        }
                    )
                end

                -- pillar tiles
                tiles[5][x] = Tile(x, 5, tileID, topper, tileset, topperset)
                tiles[6][x] = Tile(x, 6, tileID, nil, tileset, topperset)
                tiles[7][x].topper = nil
            -- chance to generate bushes
            elseif love.math.random(8) == 1 then
                table.insert(objects,
                    GameObject {
                        texture = 'bushes',
                        x = (x - 1) * TILE_SIZE,
                        y = (6 - 1) * TILE_SIZE,
                        width = 16,
                        height = 16,
                        frame = BUSH_IDS[math.random(#BUSH_IDS)] + (math.random(4) - 1) * 7,
                        collidable = false
                    }
                )
            end

            -- chance to spawn a block
            if math.random(8) == 1 then
                table.insert(objects,

                    -- jump block
                    GameObject {
                        texture = 'jump-blocks',
                        x = (x - 1) * TILE_SIZE,
                        y = (blockHeight - 1) * TILE_SIZE,
                        width = 16,
                        height = 16,

                        -- make it a random variant
                        frame = math.random(#JUMP_BLOCKS),
                        collidable = true,
                        hit = false,
                        solid = true,

                        -- collision function takes itself
                        onCollide = function(obj)

                            -- spawn a gem if we haven't already hit the block
                            if not obj.hit then

                                -- chance to spawn gem, not guaranteed
                                if math.random(4) == 1 then
                                    -- mantain reference so we can set it to nil
                                    local gem = GameObject {
                                        texture = 'gems',
                                        x = (x - 1) * TILE_SIZE,
                                        y = (blockHeight - 1) * TILE_SIZE - 4,
                                        width = 16,
                                        height = 16,
                                        frame = math.random(#GEMS),
                                        collidable = true,
                                        consumable = true,
                                        solid = false,

                                        -- gem has its own function to add to the player's score
                                        onConsume = function(player, object)
                                            gSounds['pickup']:play()
                                            player.score = player.score + 100
                                        end
                                    }

                                    -- make the gem move up from the block and play a sound
                                    Timer.tween(0.1, {
                                        [gem] = {y = (blockHeight - 2) * TILE_SIZE}
                                    })
                                    gSounds['powerup-reveal']:play()

                                    table.insert(objects, gem)
                                end

                                obj.hit = true
                            end

                            gSounds['empty-block']:play()
                        end
                    }
                )
            end
        end
    end

    local map = TileMap(width, height)
    map.tiles = tiles

    -- now we need to place the key and the lock on the map

    local coordX = love.math.random(1, width)
    local coordY = love.math.random(2, 5)

    local lockVariety = love.math.random(1, 4)

    -- find an empty tile
    while not (map.tiles[coordY][coordX].id == TILE_ID_EMPTY) do
        coordX = love.math.random(1, width)
        coordY = love.math.random(2, 4)
    end

    -- place a key on the empty tile
    local key = GameObject {
        texture = 'keys-and-locks',
        x = (coordX - 1) * TILE_SIZE,
        y = (coordY - 1) * TILE_SIZE,
        width = 16,
        height = 16,
        frame = lockVariety,
        collidable = true,
        consumable = true,
        solid = false,
        -- when player gets the key:
        onConsume = function(player, object)
            gSounds['pickup']:play()
            hasKey = true
        end
    }
    table.insert(objects, key)

    -- now spawn the lock of the same variety
    local coordX = love.math.random(1, width)
    local coordY = love.math.random(2, 4)

    while not (map.tiles[coordY][coordX].id == TILE_ID_EMPTY) do
        coordX = love.math.random(1, width)
        coordY = love.math.random(3, 6)
    end

    table.insert(objects,
        GameObject {
            texture = 'keys-and-locks',
            x = (coordX - 1) * TILE_SIZE,
            y = (coordY - 1) * TILE_SIZE,
            width = 16,
            height = 16,

            frame = lockVariety + 4,
            collidable = true,
            hit = false,
            solid = true,

            onCollide = function(obj)
                -- if we have the key then unlock the flag for the next level
                if hasKey then
                    isLevelLocked = false
                    gSounds['pickup']:play()
                end

                gSounds['empty-block']:play()
            end
        }
    )

    -- and finally spawn a pole and a flag on the end of the level
    local coordX = width - 1
    local coordY = 6

    -- find an empty tile to put the pole on, but with ground underneath it so it doesn't just hang in the air above the chasm
    while not (map.tiles[coordY][coordX].id == TILE_ID_EMPTY) and (map.tiles[coordY + 1][coordX] == TILE_ID_GROUND) do
        coordX = coordX - 1
    end

    table.insert(objects,
        GameObject {
            texture = 'poles',
            x = (coordX - 1) * TILE_SIZE,
            y = (coordY - 3) * TILE_SIZE,
            width = 16,
            height = 48,

            frame = love.math.random(1, 6),
            collidable = true,
            solid = false,

            onCollide = function(obj)
                local flag = GameObject {
                    texture = 'flags',
                    x = (coordX - 1) * TILE_SIZE + (TILE_SIZE / 2),
                    y = (coordY - 3) * TILE_SIZE,
                    width = 16,
                    height = 16,
                    frame = 9 * love.math.random(1, 4) - 2,
                    collidable = true,
                    consumable = true,
                    solid = false,
                    onConsume = function(player, object)
                        gStateMachine:change('play', {
                            score = player.score,
                            width = width + 10
                        })
                    end
                }
                table.insert(objects, flag)
            end
        }
    )

    -- table.insert(objects,
    --     GameObject {
    --         texture = 'flags',
    --         x = (coordX - 1) * TILE_SIZE + (TILE_SIZE / 2),
    --         y = (coordY - 3) * TILE_SIZE,
    --         width = 16,
    --         height = 16,

    --         frame = 9 * love.math.random(1, 4) - 2,
    --         collidable = true,
    --         hit = false,
    --         solid = true,

    --         onCollide = function(obj)
    --             if hasKey and (isLevelLocked == false) then
    --                 gStateMachine:change('play', {
    --                     score = self.player.score,
    --                     width = width + 10
    --                 })
    --                 hasKey = false
    --                 isLevelLocked = true
    --             end
    --         end
    --     }
    -- )

    return GameLevel(entities, objects, map)
end

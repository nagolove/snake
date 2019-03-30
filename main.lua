local inspect = require "inspect"
local lg = love.graphics

local snake = {}
local UPDATE_TIME = 1000
local FIELD_SIZE = 20 -- внимание: игровое поле индексируется с еденицы.

local DIRECTION_LEFT = 0
local DIRECTION_UP = 1
local DIRECTION_RIGHT = 2
local DIRECTION_DOWN = 3

local W, H = lg.getDimensions()
local CELL_WIDTH = H / FIELD_SIZE

local FIELD_X_POS, FIELD_Y_POS = (W - H) / 2, 0

function getRandomDirection()
    return math.random(0, 3)
end

function love.load(argv)
    direction = getRandomDirection()
    table.insert(snake, { x = math.random(1, FIELD_SIZE), y = math.random(1, FIELD_SIZE) })
    table.insert(snake, { x = snake[1].x, y = snake[1].y - 1 })
    table.insert(snake, { x = snake[2].x, y = snake[2].y - 1 })

    print("snake", inspect(snake))
end

function drawGrid()
    lg.setColor{0, 1, 0}
    lg.setLineWidth(3)
    local x, y = FIELD_X_POS, FIELD_Y_POS
    local x1, y1 = FIELD_X_POS, FIELD_Y_POS
    for i = 1, FIELD_SIZE + 1 do
        lg.line(x, y, x + H, y)
        y = y + CELL_WIDTH
        lg.line(x1, y1, x1, y1 + H)
        x1 = x1 + CELL_WIDTH
    end
    lg.setColor{1, 1, 1}
    lg.setLineWidth(1)
end

function drawSnake()
    lg.setColor{0.8, 0.8, 0.6}
    for k, v in pairs(snake) do
        lg.rectangle("fill", v.x * CELL_WIDTH + FIELD_X_POS, v.y * CELL_WIDTH + FIELD_Y_POS, CELL_WIDTH, CELL_WIDTH)
    end
end

function drawEat()
    lg.setColor{1, 0, 0}
    lg.rectangle("fill", eat.x * CELL_WIDTH + FIELD_X_POS, eat.y * CELL_WIDTH + FIELD_Y_POS, CELL_WIDTH, CELL_WIDTH)
end

function love.draw()
    drawGrid()
    drawSnake()
    --drawEat()
end

function getEat()
    local stop = true
    repeat
        eat.x = math.random(1, FIELD_SIZE)
        eat.y = math.random(1, FIELD_SIZE)
        for k, v in pairs(snake) do
            if eat.x == v.x and eat.y == v.y then
                stop = false
                break
            end
        end
    until stop
end

function love.keypressed(key, scancode)
    if key == "escape" then
        love.event.quit()
    end
end

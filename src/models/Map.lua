-- models/Map.lua : The model for game map

local Model = require('models/Model')
local model = Model:new()

local function table_has(table, value)
    for _, val in ipairs(table) do
        if val == value then
            return true
        end
    end
    return false
end

function model:load(mapName)
    self.mapName = mapName
    self.map = dofile('data/maps/' .. mapName .. '.lua')
    self.map.positions.user = {unpack(self.map.positions.start)}
end

function model:reset()
    self:load(self.mapName)
end

function model:getSize()
    return self.map.size
end

function model:getMap()
    return self.map
end

function model:getTile(x, y)
    return self.map.data[y][x]
end

function model:setTile(x, y, tile)
    if self:isTileOnMap(x, y) and self.map.components[tile] then
        self.map.data[y][x] = tile
    else
        error('No component for tile id "' .. tile .. '"')
    end
end

function model:isTileOnMap(x, y)
    return (x > 0 and y > 0
            and x <= self.map.size.width
            and y <= self.map.size.height)
end

function model:isTileMovable(x, y)
    return (self:isTileOnMap(x, y)
            and table_has({'grass', 'exit'},
                    self:getComponent(self:getTile(x, y))))
end

function model:isTileBreakable(x, y)
    return (self:isTileOnMap(x, y)
            and table_has({'box_closed'},
                    self:getComponent(self:getTile(x, y))))
end

function model:hasArtifact(x, y)
    return (self.isTileOnMap(x, y) and self.map.artifacts[y][x])
end

function model:getArtifact(x, y)
    if self:isTileOnMap(x, y) then
        if self.map.artifacts[y] and self.map.artifacts[y][x] then
            return self.map.artifacts[y][x]
        else
            return self.map.artifacts.default
        end
    end
    return nil
end

function model:getComponent(id)
    return self.map.components[id]
end

function model:getPosition(thing)
    if not self.map.positions[thing] then
        error('Map.setUserPosition: no thing "' .. thing .. '"')
    else
        return { self.map.positions[thing][1], self.map.positions[thing][2] }
    end
end

function model:setPosition(thing, position)
    local size = self.map.size
    if position[1] > size.width or position[2] > size.height then
        error('Map.setUserPosition: position bigger than map size')
    elseif position[1] < 1 and position[2] < 1 then
        error('Map.setUserPosition: position smaller than 1')
    elseif not self.map.positions[thing] then
        error('Map.setUserPosition: no thing "' .. thing .. '"')
    else
        self.map.positions[thing] = position
    end
end

model.console = require('models.Console'):new()

return model
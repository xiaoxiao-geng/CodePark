--------------------------------------------------------------------------------
-- This is a class to manage the resources.<br>
--------------------------------------------------------------------------------

local table = require("hp/lang/table")

local M = {}
local paths = {}

local SEPARETOR = "/"

--------------------------------------------------------------------------------
-- Add the resource directory path.
--------------------------------------------------------------------------------
function M:addPath(path)
    table.insertElement(paths, path)
end

--------------------------------------------------------------------------------
-- Remove the resource directory path.
--------------------------------------------------------------------------------
function M:removePath(path)
    return table.removeElement(paths, path)
end

--------------------------------------------------------------------------------
-- Clear the resource directory paths.
--------------------------------------------------------------------------------
function M:clearPaths()
    paths = {}
end

--------------------------------------------------------------------------------
-- Returns the filePath from fileName.
--------------------------------------------------------------------------------
function M:getFilePath(fileName, defaultPath)

    if MOAIFileSystem.checkFileExists(fileName) then
        return fileName
    end
    for i, path in ipairs(paths) do
        local filePath = path .. SEPARETOR .. fileName
        if MOAIFileSystem.checkFileExists(filePath) then
            return filePath
        end
    end

    --------------------------------------------------------------------------------
    -- 2013-10-11 ultralisk add begin
    -- 默认采用 empty.png
    -- 请不要合并给单机部。。。
    --------------------------------------------------------------------------------

    -- if not defaultPath then
    --     error("File not found error!")
    -- end
    -- gLog.warn( "File not found ! [" .. tostring( fileName ) .. "]" )
    
    defaultPath = defaultPath or RESOURCES.getPath( "empty.png" )

    --------------------------------------------------------------------------------
    -- 2013-10-11 ultralisk add end
    --------------------------------------------------------------------------------

    return defaultPath
end

--------------------------------------------------------------------------------
-- Returns the file data.
--------------------------------------------------------------------------------
function M:readFile(fileName)
    local path = self:getFilePath(fileName)
    local input = assert(io.input(path))
    local data = input:read("*a")
    input:close()
    return data
end


return M
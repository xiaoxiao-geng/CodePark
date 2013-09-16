--------------------------------------------------------------------------------
-- This is a class to manage the record.<br>
--------------------------------------------------------------------------------
local Logger                = require "hp/util/Logger"

local M = {}
local SEPARETOR = "/"

function M:initialize( fileName, initData)

    assert(fileName)

    local path = MOAIEnvironment["documentDirectory"] or ""
    local savePath = path .. SEPARETOR .. fileName
    self.savePath = savePath

    if MOAIFileSystem.checkFileExists( savePath ) then
        self.datas = dofile( savePath )
    elseif initData then
        self.datas = initData
        self:saveAllData()
        Logger.info("new record file:", savePath)
    end
end


function M:write( data, name )

    if data == nil or type(name) ~= "string" then 
        Logger.warn("record save fail!")
        return 
    end

    local datas     = self.datas
    local savePath  = self.savePath

    if not datas  and MOAIFileSystem.checkFileExists(savePath) then
        datas = dofile( savePath )
    end

    datas = datas or {}

    datas[ name ] = data

    self.datas = datas

    self:saveAllData()

end

function M:read( name )

    if not name then
        Logger.warn("record name invalid:", name)
        return nil
    end

    return self.datas and self.datas[ name ]

end

function M:saveAllData()

    if not self.datas then
        Logger.warn("record: save all data fail!")
        return
    end

    local serializer = MOAISerializer.new ()
    serializer:serialize ( self.datas )
    local strData = serializer:exportToString ()
    local compiled = string.dump ( loadstring ( strData, '' ) )

    local savePath = self.savePath
    local file = MOAIFileStream.new()
    file:open(savePath, MOAIFileStream.READ_WRITE_NEW)
    file:write( compiled )
    file:flush()
    file:close()

end


return M
--------------------------------------------------------------------------------
-- This class is for log output.
--------------------------------------------------------------------------------

local M = {}

-- Constraints
M.LEVEL_NONE = 0
M.LEVEL_INFO = 1
M.LEVEL_WARN = 2
M.LEVEL_ERROR = 3
M.LEVEL_DEBUG = 4
--cdsc add start
M.LEVEL_STACK_TRACE = 5
M.LEVEL_TABLE = 6
--cdsc add end
--------------------------------------------------------------------------------
-- A table to select whether to output the log.
--------------------------------------------------------------------------------
M.selector = {}
M.selector[M.LEVEL_INFO] = true
M.selector[M.LEVEL_WARN] = true
M.selector[M.LEVEL_ERROR] = true
M.selector[M.LEVEL_DEBUG] = true
--cdsc add start
M.selector[M.LEVEL_STACK_TRACE] = true
M.selector[M.LEVEL_TABLE]   = true
--cdsc add end

--cdsc add start
M.ENABLE_DUMP = true
function M.appDump(text)

	if not M.ENABLE_DUMP then
		return
	end

	if not text or text == "" then
		return
	end
	-- local str = string.format("[%s] %s\n",  os.date("%Y/%m/%d %H:%M:%S"), text)
	-- local f = io.open("__logger__.txt", "a")
	-- f:write(str)
	-- f:close()
end
--cdsc add end
--------------------------------------------------------------------------------
-- This is the log target.
-- Is the target output to the console.
--------------------------------------------------------------------------------
M.CONSOLE_TARGET = function(...)
    print(...)

    -- ul add begin
    if  _G.__DEBUG_CONSOLE_ENABLED and _G.__LOG_TO_CONSOLE then
        gDebugController:debug( ... )
    end
    -- ul add end
end

--------------------------------------------------------------------------------
-- This is the log target.
--------------------------------------------------------------------------------
M.logTarget = M.CONSOLE_TARGET

--------------------------------------------------------------------------------
-- The normal log output.
--------------------------------------------------------------------------------
function M.info(...)
    if M.selector[M.LEVEL_INFO] then
        M.logTarget("[info]", ...)
    end
end

--------------------------------------------------------------------------------
-- The warning log output.
--------------------------------------------------------------------------------
function M.warn(...)
    if M.selector[M.LEVEL_WARN] then
		M.appDump(string.format(...))
        M.logTarget("[warn]", ...)
    end
end

--------------------------------------------------------------------------------
-- The error log output.
--------------------------------------------------------------------------------
function M.error(...)
    if M.selector[M.LEVEL_ERROR] then
		M.appDump(string.format(...))
        M.logTarget("[error]", ...)
    end
end

--------------------------------------------------------------------------------
-- The debug log output.
--------------------------------------------------------------------------------
function M.debug(...)
    if M.selector[M.LEVEL_DEBUG] then
        M.logTarget("[debug]", ...)
    end
end

--cdsc add start

--------------------------------------------------------------------------------
-- print function call stack
--------------------------------------------------------------------------------
function M.stackTrace()
    if M.selector[M.LEVEL_STACK_TRACE] then
		local stack = debug.traceback()
		M.appDump(stack)
        M.logTarget(stack)
    end
end

--------------------------------------------------------------------------------
-- print whole table
--------------------------------------------------------------------------------
function M.printTable( tb , title)

    if not M.selector[M.LEVEL_TABLE] then
        return
    end
    
    local tabNum = 0
    local function stab(numTab)
        local str = ""
        for i = 1, numTab do
            str = str .. "    "
        end
        return str
    end

    local function _printTable( t )
        M.logTarget(stab(tabNum) .. "{")
        tabNum = tabNum + 1
        for k, v in pairs( t ) do
            local kk
            if type(k) == "string" then
                kk = "['" .. k .. "']"
            else
                kk = "[" .. k .. "]"
            end
            if type(v) == "table" then
                if type(k) == "string" then
                    M.logTarget(stab(tabNum) .. kk .. " = ")
                end
                _printTable( v )
            else
                local vv = ""
                if type(v) == "string" then
                    vv = string.format("\"%s\"", v)
                elseif type(v) == "number" or type(v) == "boolean" then
                    vv = tostring(v)
                else
                    vv = "[" .. type(v) .. "]"
                end

                if type(k) == "string" then
                    M.logTarget( string.format("%s%-18s = %s,", stab(tabNum), kk, vv) )
                    --M.logTarget(stab(tabNum) .. kk .. "\t= " .. vv .. ",")
                else
                    M.logTarget( string.format("%s%-4s = %s,", stab(tabNum), kk, vv) )
                    --M.logTarget( string.format("%s%s", stab(tabNum), vv) )
                end

            end
        end
        tabNum = tabNum - 1

        if tabNum == 0 then
            M.logTarget(stab(tabNum) .. "}")
        else
            M.logTarget(stab(tabNum) .. "},")
        end
    end
    

    local titleInfo = title or tb

    M.logTarget(string.format("\n----------begin[%s]----------", titleInfo) )
    if not tb or type(tb) ~= "table" then
        M.logTarget(tb)
    else
        _printTable( tb )
    end
    M.logTarget(string.format("----------end  [%s]----------\n", titleInfo))
    
end
--cdsc add end

return M
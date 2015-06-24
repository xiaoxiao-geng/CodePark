local function importMgr(name)
    local mgrClass = import("app.manager." .. name)
    local mgr = mgrClass:create()
    mvc.ManagerBase.saveMgrInstance(name, mgr)
    ul[name] = mgr
end

require("pack")
cc.exports.cjson	= require("cjson")
-- cc.exports.MD5		= import(".cocosExt.md5")

cc.exports.mvc = {}
mvc.AppBase		= import(".mvc.AppBase")
mvc.ViewBase	= import(".mvc.ViewBase")
mvc.ManagerBase	= import(".mvc.ManagerBase")

cc.exports.ul = {}

ul.Tools        = import(".cocosExt.Tools")
import(".cocosExt.stringExt")

-- import(".consts")
ul.FSMObject		= import(".cocosExt.FSMObject")
ul.FSMRoot			= import(".cocosExt.FSMRoot")
ul.SpriteDrawNode	= import(".cocosExt.SpriteDrawNode")
ul.CfgParser		= import(".cocosExt.CfgParser")
ul.MsgHandler		= import(".cocosExt.MsgHandler")
ul.ViewBaseEx		= import(".cocosExt.ViewBaseEx")
ul.StructBase		= import(".cocosExt.StructBase")
ul.Socket			= import(".cocosExt.Socket")
ul.ZZBase64			= import(".cocosExt.ZZBase64")

ul.sTerrainCell		= import(".struct.sTerrainCell")

ul.Terrain			= import(".model.Terrain")
ul.World			= import(".model.World")
ul.SystemBase		= import(".model.SystemBase")
ul.WaterSystem		= import(".model.WaterSystem")
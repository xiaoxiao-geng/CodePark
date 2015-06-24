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
ul.FSMObject			= import(".cocosExt.FSMObject")
ul.FSMRoot				= import(".cocosExt.FSMRoot")
ul.SpriteDrawNode		= import(".cocosExt.SpriteDrawNode")
ul.CfgParser			= import(".cocosExt.CfgParser")
ul.MsgHandler			= import(".cocosExt.MsgHandler")
ul.ViewBaseEx			= import(".cocosExt.ViewBaseEx")
ul.StructBase			= import(".cocosExt.StructBase")
ul.Socket				= import(".cocosExt.Socket")
ul.ZZBase64				= import(".cocosExt.ZZBase64")

-- ul.NetworkManager		= import(".cocosExt.network.NetworkManager")
-- ul.NetworkTask			= import(".cocosExt.network.NetworkTask")
-- ul.NetworkAdapterBase	= import(".cocosExt.network.NetworkAdapterBase")
-- ul.NetworkAdapterSocket	= import(".cocosExt.network.NetworkAdapterSocket")
-- ul.NetworkAdapterHttp	= import(".cocosExt.network.NetworkAdapterHttp")
-- ul.ProtoBuffer			= import(".cocosExt.network.ProtoBuffer")
-- ul.ProtoTools			= import(".cocosExt.network.ProtoTools")

-- ul.ItemStruct			= import(".struct.ItemStruct")
-- ul.sHamburgerMaterial	= import(".struct.sHamburgerMaterial")
-- ul.sHamburgerCustomer	= import(".struct.sHamburgerCustomer")
-- ul.sIceCreamCustomer	= import(".struct.sIceCreamCustomer")
-- ul.AchievementStruct	= import(".struct.AchievementStruct")



-- import managers
-- importMgr("mgrNative")
-- importMgr("mgrCfg")
-- importMgr("mgrWordFilter")
-- importMgr("mgrNetwork")
-- importMgr("mgrRecord")
-- importMgr("mgrSound")
-- importMgr("mgrDebug")
-- importMgr("mgrTip")
-- importMgr("mgrPlayer")
-- importMgr("mgrCook")
-- importMgr("mgrHamburger")
-- importMgr("mgrIceCream")
-- importMgr("mgrCake")
-- importMgr("mgrAchievement")
-- importMgr("mgrShop")
-- importMgr("mgrManicure")
-- importMgr("mgrStage")
-- importMgr("mgrModule")
-- importMgr("mgrCosmetic")
-- importMgr("mgrPayment")
-- importMgr("mgrCompetition")
-- importMgr("mgrComment")
-- importMgr("mgrAd")

--some base view
-- ul.Item             = import(".view.dialog.Item")
-- ul.ModalDialog      = import(".view.dialog.ModalDialog")
-- ul.MinDialog        = import(".view.dialog.MinDialog")
-- ul.MinItemsDialog        = import(".view.dialog.MinItemsDialog")
-- ul.ResultDialog     = import(".view.dialog.ResultDialog")
-- ul.SettingDialog     = import(".view.dialog.SettingDialog")

-- ul.PayDialogBase				= import(".view.dialog.PayDialogBase")
-- ul.PayDoubleGoldExpDialog     	= import(".view.dialog.PayDoubleGoldExpDialog")
-- ul.PayGoldDialog     			= import(".view.dialog.PayGoldDialog")
-- ul.PayDreamXiaoLan     			= import(".view.dialog.PayDreamXiaoLan")
-- ul.PayDreamMeiQi     			= import(".view.dialog.PayDreamMeiQi")
-- ul.PayDreamMeiXue     			= import(".view.dialog.PayDreamMeiXue")
-- ul.PayDreamBeiBei     			= import(".view.dialog.PayDreamBeiBei")
#!/bin/python
# -*- coding: utf-8 -*-

# 
#   游戏发布、打包、打补丁的配置文件
#   rootPath:   脚本运行的根目录 
#   prjectPath: 项目目录
#   srcPath:    游戏脚本目录
#   resPath:    游戏资源目录
#   srcReleasePath:   发布脚本目录
#   resReleasePath:   发布资源目录
#   verExportPath:    ver.json发布目录
#

import os
import sys

rootPath = os.path.join("..", "..")
prjectPathName = "client"

# 修改后需要boot的文件的正则表达式
bootReps = [
	r"^%s" % os.path.join("src", "updater", ".*"),
]

# 项目目录
prjectPath			= os.path.join(rootPath, prjectPathName)
# 脚本和源资源的路径
srcPath				= os.path.join(prjectPath, "src") 
resPath				= os.path.join(prjectPath, "res") 
# 压缩和编译后的路径
releasePath			= os.path.join(prjectPath, "_build", "release")
srcReleasePath		= os.path.join(prjectPath, "_build", "release", "src")
resReleasePath		= os.path.join(prjectPath, "_build", "release", "res")
# 补丁根目录
pathDataPath		= os.path.join(prjectPath, "_build", "patch_data")
# 打包根目录
packPath			= os.path.join(prjectPath, "_build", "pack")
# 打包patch_info存放路径
packPatchInfoPath	= os.path.join(prjectPath, "_build", "pack", "src")
# 补丁上传目录
patchUploadPath 	= os.path.join(rootPath, "..", "..", "ude2", "llzup", "cc_patch", "balala2")

# 加密用参数
xxteaSign = "XXTEA"
xxteaKey = "cn.ultralisk.gameapp.xxtea.key"


# 补丁下载相关的配置
# 下载patchUrl
HOST = "h005.ultralisk.cn:4022"
HOST_CDN = "h005.ultralisk.cn:4022"
# HOST_CDN = "h005up.ultralisk.cn"
# 补丁项目目录
APP  = "balala2"
# patchinfo文件名
PATCH_INFO_FILENAME = "patch_info.json"
# http://h005.ultralisk.cn:4022/cc_patch/balala2/devtest/patch_info.json
# http://HOST/PATCH_PATH/APP/CHANNEL
PATCH_PATH = "cc_patch"


# 版本信息，这部分内容需要根据channel有不同的变化

#大版本号 程序维护
B_ID = 0
# 版本号：运营版本号
VERSION = "1.0.0"

def updateDataByChannel(channel):
	global B_ID
	global VERSION

	if channel == "devtest":
		B_ID = 0
		VERSION = "1.0.0_5"

	elif channel == "channel2":
		pass

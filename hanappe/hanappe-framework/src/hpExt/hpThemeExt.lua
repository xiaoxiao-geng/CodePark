local M = {}

M.BlueButton = {
    normal = {
        skin = "base/Button04.png",
        skinClass = NinePatch,
        skinColor = {1, 1, 1, 1},
        textPadding = {10, 4, 10, 4},
        style = "bm20",
        textColor = {1, 1, 1, 1}
    },
    selected = {
        skinColor = {0.5, 0.5, 0.5, 1},
        textColor = {0.5, 0.5, 0.5, 1},
        -- skinColor = {1, 1, 0, 1},
     --    skin = "base/Button05.png",
    },
    over = {
    },
    disabled = {
        skinColor = {0.5, 0.5, 0.5, 1},
        textColor = {0.5, 0.5, 0.5, 1},
    },
}

M.ButtonLong = {
    normal = {
        skin = "test/btn2.png",
        skinClass = Sprite,
        skinColor = { 1, 1, 1, 1 },

        textPadding = {10, 4, 10, 4},
        style = "style16",
        textColor = {1, 1, 1, 1}
    },
}

M.ButtonShort = {
    normal = {
        skin = "test/btn1.png",
        skinClass = Sprite,
        skinColor = { 1, 1, 1, 1 },

        textPadding = {10, 4, 10, 4},
        style = "style16",
        textColor = {1, 1, 1, 1}
    },
}

M.ButtonTab = {
    normal = {
        skin = "test/btn3.png",
        skinClass = Sprite,
        skinColor = { 1, 1, 1, 1 },

        textPadding = {10, 4, 10, 4},
        style = "style16",
        textColor = {1, 1, 1, 1}
    },
}

M.EmptyButton = {
    normal = {
        skin = "empty.png",
        skinClass = Sprite,
        skinColor = {1, 1, 1, 1},
        textPadding = {10, 4, 10, 4},
        style = "style16",
        textColor = {1, 1, 1, 1}
    },
    selected = {
        skinColor = {0.5, 0.5, 0.5, 1},
        textColor = {0.5, 0.5, 0.5, 1},
    },
}

M.ButtonRemakeLock = {
    normal = {
        skin = "forge/ButtonLock.png",
        skinClass = NinePatch,
        skinColor = {1, 1, 1, 1},
        textPadding = {24, 4, 0, 4},
        style = "style16",
        textColor = {1, 1, 1, 1}
    },
}

M.ButtonRemakeUnlock = {
    normal = {
        skin = "forge/ButtonUnlock.png",
        skinClass = NinePatch,
        skinColor = {1, 1, 1, 1},
        textPadding = {24, 4, 0, 4},
        style = "style16",
        textColor = {1, 1, 1, 1}
    },
}

M.ShortcutsButton = {
    normal = {
        skin = "base/Button02.png",
        skinClass = Sprite,
        skinColor = {1, 1, 1, 1},

        textPadding = {10, 4, 10, 4},
        textColor = {1, 1, 1, 1},
        style = "style16",
    },
    selected = {
        skinColor = {1, 1, 0, 1},
        textColor = {1, 1, 0, 1},
    },
}

M.SkillButton = {
    normal = {
        skin = "ml/skill/SkillButton.png",
        skinClass = Sprite,
        skinColor = {1, 1, 1, 1},

        activeSkin = "ml/skill/SkillButtonActived.png",
        activeSkinClass = Sprite,
        activeColor = {1, 1, 1, 1},
        activeUseTextureSize = true,

        textPadding = {10, 4, 10, 4},
        textColor = {1, 1, 1, 1},
        style = "style16",
    },
    selected = {
        -- skinColor = {0.5, 0.5, 0.5, 1},
        -- textColor = { 1, 0, 0, 1 },
    },
}

M.SkillTypeButton = {
    normal = {
        skin = "empty.png",
        skinClass = Sprite,
        skinColor = {1, 1, 1, 1},

        activeSkin = "empty.png",
        activeSkinClass = Sprite,
        activeColor = {1, 1, 1, 1},

        textPadding = {10, 4, 10, 4},
        textColor = {1, 1, 1, 1},
        style = "style16",
    }
}

M.ItemButton = {
    normal = {
        skin = "empty.png",
        skinClass = Sprite,
        skinColor = {1, 1, 1, 1},

        activeSkin = "base/RadioBgFocus01.png",
        activeSkinClass = NinePatch,
        activeSkinColor = {1, 1, 1, 1},
        activeTextColor = {1, 1, 0, 1},

        textPadding = {10, 4, 10, 4},
        textColor = {1, 1, 1, 1},
        style = "style16",
    },
    selected = {
    },
}

M.ItemShowBox = {
    normal = {
        skin = "base/Frame02.png",
        skinClass = NinePatch,
        skinColor = {1, 1, 1, 1},

        activeSkin = "base/RadioBgFocus01.png",
        activeSkinClass = NinePatch,
        activeSkinColor = {1, 1, 1, 1},
        activeTextColor = {1, 1, 0, 1},

        textPadding = {10, 4, 10, 4},
        textColor = {1, 1, 1, 1},
        style = "style16",
    },
    selected = {
    },
}

M.SkillRuneButton = {
    normal = {
        skin = "ml/skill/RuneButton.png",
        skinClass = Sprite,
        skinColor = {1, 1, 1, 1},

        activeSkin = "ml/skill/RuneButtonActived.png",
        activeSkinClass = Sprite,
        activeColor = {1, 1, 1, 1},
        activeUseTextureSize = true,

        textPadding = {10, 4, 10, 4},
        textColor = {1, 1, 1, 1},
        style = "style16",
    },
}

M.TabButton = {
    normal = {
        skin = "base/Button05.png",
        skinClass = NinePatch,
        skinColor = {0.5, 0.5, 0.5, 1},

        -- activeSkin = "base/RadioBgFocus01.png",
        activeSkin = "empty.png",
        activeSkinClass = NinePatch,
        activeSkinColor = {1, 1, 1, 1},
        activeTextColor = {1, 1, 0, 1},

        textPadding = {10, 4, 10, 4},
        textColor = {0.5, 0.5, 0.5, 1},
        style = "style16",
    },
    selected = {
        -- skinColor = {0.25, 0.25, 0.25, 1},
        -- textColor = {0.25, 0.25, 0.25, 1},
    },
    over = {
    },
    disabled = {
        skinColor = {0.3, 0.3, 0.3, 1},
        textColor = {0.3, 0.3, 0.3, 1},
    },  
}

M.RadioButton = {
    normal = {
        skin = "base/Button05.png",
        skinClass = NinePatch,
        skinColor = {0.5, 0.5, 0.5, 1},

        activeSkin = "base/RadioBgFocus01.png",
        activeSkinClass = NinePatch,
        activeSkinColor = {1, 1, 1, 1},
        activeTextColor = {1, 1, 0, 1},

        textPadding = {10, 4, 10, 4},
        textColor = {0.5, 0.5, 0.5, 1},
        style = "style16",
    },
    selected = {
        -- skinColor = {0.25, 0.25, 0.25, 1},
        -- textColor = {0.25, 0.25, 0.25, 1},
    },
    over = {
    },
    disabled = {
        skinColor = {0.3, 0.3, 0.3, 1},
        textColor = {0.3, 0.3, 0.3, 1},
    },  
}



-- 主界面用的标签页样式
M.ButtonMainTab = {
    normal = {
        skin = "ml/base/Button03.png",
        skinClass = Sprite,
        skinColor = { 0.3, 0.3, 0.3, 1 },        

        activeSkin = "empty.png",
        activeSkinClass = Sprite,
        activeSkinColor = { 1, 1, 1, 1 },

        textPadding = {10, 4, 10, 4},
        style = "style16",
        textColor = {1, 1, 1, 1}
    },
}

M.EmptyRadioButton = {
    normal = {
        skin = "empty.png",
        skinClass = Sprite,
        skinColor = {0.5, 0.5, 0.5, 1},

        activeSkin = "empty.png",
        activeSkinClass = NinePatch,
        activeSkinColor = {1, 1, 1, 1},
        activeTextColor = {1, 1, 0, 1},

        textPadding = {10, 4, 10, 4},
        textColor = {0.5, 0.5, 0.5, 1},
        style = "style16",
    },
    selected = {
        skinColor = {0.25, 0.25, 0.25, 1},
        textColor = {0.25, 0.25, 0.25, 1},
    },
    over = {
    },
    disabled = {
        skinColor = {0.3, 0.3, 0.3, 1},
        textColor = {0.3, 0.3, 0.3, 1},
    },  
}

M.BlackButton = {
    normal = {
        skin = "base/Button05.png",
        skinClass = NinePatch,
        skinColor = {1, 1, 1, 1},
        textPadding = {10, 4, 10, 4},
        textColor = {1, 1, 1, 1},
        style = "style16",
    },
    selected = {
        -- skinColor = {0.5, 0.5, 0.5, 1},
        -- textColor = {0.5, 0.5, 0.5, 1},
    },
    over = {
    },
    disabled = {
        skinColor = {0.5, 0.5, 0.5, 1},
        textColor = {0.5, 0.5, 0.5, 1},
    },
}

M.WhiteButton = {
    normal = {
        skin = "rect.png",
        skinClass = Sprite,
        skinColor = { 0.5, 0.5, 0, 0.5 },
        textPadding = {10, 4, 10, 4},
        textColor = {1, 1, 1, 1},
        style = "style16",
    },
    selected = {
        skinColor = {0.7, 0.3, 0, 0.5},
        textColor = {1, 1, 0, 1},
    },
    over = {
    },
    disabled = {
        skinColor = {0.5, 0.5, 0.5, 1},
        textColor = {0.5, 0.5, 0.5, 1},
    },
}

M.EditBoxButton = {
    normal = {
        skin = "base/Input02.png",
        skinClass = NinePatch,
        skinColor = { 1, 1, 1, 1 },
        textPadding = {10, 4, 10, 4},
        textColor = {1, 1, 1, 1},
        style = "style16",
    },
    disabled = {
        skinColor = {0.5, 0.5, 0.5, 1},
        textColor = {0.5, 0.5, 0.5, 1},
    },
}


M.GrayPanel = {
    normal = {
        backgroundSkin = "base/Frame01.png",
        backgroundSkinClass = NinePatch,
        backgroundColor = {1, 1, 1, 0.9},
    },
    disabled = {
        backgroundColor = {0.5, 0.5, 0.5, 0.2},
    },
}

M.WhitePanel = {
    normal = {
        backgroundSkin = "rect.png",
        backgroundSkinClass = Sprite,
        backgroundColor = {0.1, 0, 0, 0.9},
    },
    disabled = {
        backgroundColor = {0.5, 0.5, 0.5, 0.9},
    },
}

-- 阴影层
M.ShadowPanel = {
    normal = {
        backgroundSkin = "rect.png",
        backgroundSkinClass = Sprite,
        backgroundColor = {0, 0, 0, 0.5},
    },
}

M.PanelFrame01 = {
    normal = {
        backgroundSkin = "ml/base/Frame01.png",
        backgroundSkinClass = NinePatch,
        backgroundColor = {1, 1, 1, 1},
    },
}

M.PanelFrame02 = {
    normal = {
        backgroundSkin = "ml/base/Frame02.png",
        backgroundSkinClass = NinePatch,
        backgroundColor = {1, 1, 1, 1},
    },
}

M.PanelBackground = {
    normal = {
        backgroundSkin = "ml/base/Background01.png",
        backgroundSkinClass = Sprite,
        backgroundColor = {1, 1, 1, 1},
    },
}

M.EmptyPanel = {
    normal = {
        backgroundSkin = "empty.png",
        backgroundSkinClass = Sprite,
        backgroundColor = {1, 1, 1, 1},
    },
}














-- 进度条
M.ProgressBar = {
    normal = {
        backgroundSkin = "ml/base/ProgressBackground.png",
        backgroundSkinClass = NinePatch,
        backgroundColor = { 1, 1, 1, 1 },
        barPadding = { 29, 7, 33, 7 },

        barSkin = "ml/base/ProgressBar.png",
        barSkinClass = NinePatch,
        barColor = { 1, 1, 1, 1 },

        -- maskSkin = "rect.png",
        -- maskSkinClass = Sprite,
        -- maskColor = { 0, 0, 0, 0.9 },

        textStyle = "number12",
        textFormat = "%d/%d",
    },
}

M.ProgressBarNum = {
    normal = {
        backgroundSkin = "ml/base/ProgressBackground.png",
        backgroundSkinClass = NinePatch,
        backgroundColor = { 1, 1, 1, 1 },
        barPadding = { 29, 7, 33, 7 },

        barSkin = "ml/base/ProgressBar.png",
        barSkinClass = NinePatch,
        barColor = { 1, 1, 1, 1 },

        textStyle = "number12",
        textFormat = "%d",
    },
}

M.GreenProgressBar = {
    normal = {
        barSkin = "test/green_bar.png",
        barSkinClass = NinePatch,
        maskSkin = "test/green_mask.png",
        maskSkinClass = NinePatch,

        textStyle = "style16",
    },
}

-- 设置默认值
M.Button = M.BlackButton
M.Panel = M.PanelFrame02

return M
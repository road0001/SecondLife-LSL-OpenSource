# 道具控制系统
道具控制系统整合其他脚本并实现主要功能。

## 使用方法
将所有依赖的脚本全部放入物品库存中，并写好相应的配置记事卡。然后点击此物件即可显示主菜单。主菜单整合了全部功能，下面将按顺序进行说明和介绍。

### 上锁/解锁（Lock）
将物件锁在身上/解锁。锁定后的物件将不可脱掉。默认情况下，上锁功能和RLV限制联动，即上锁时应用全部设定好的RLV限制，解锁时清除限制。
	- 您也可以使用“RLV.SET.CONNECT|0”来禁用此功能，“RLV.SET.CONNECT|1”来启用此功能。

### 牵绳（Leash）
牵绳菜单。可抓住对方的牵绳，或令对方跟随指定角色，或将对方拴在物体上。被牵住的玩家无法离开一定范围。可使用leash_main记事卡来配置初始的牵绳和链条配置，详情请见[	牵绳文档](README.Leash.md)。

### RLV
RLV菜单。设定RLV限制。RLV限制通过rlv_main记事卡配置，详情请见[RLV文档](README.RLV.md)。

### 计时器（Timer）
计时器菜单。可增加/减少时长、设置计时模式，当计时结束时，将自动解锁物件。详情请见[计时器文档](README.Timer.md)。

### 重命名器（Renamer）
重命名器菜单。设定重命名相关功能。详情请见[重命名器文档](README.Renamer.md)。

### 权限控制（Access）
权限控制菜单。设置根用户、主人、信任列表、黑名单、公开、群组、硬核模式等功能。可使用access_main记事卡来配置初始的权限数据，详情请见[权限文档](README.Access.md)。

### 动画系统（Animation）
动画控制菜单。让角色做出相应动作。可使用anim_main记事卡来配置初始的动画数据，详情请见[动画文档](README.Animation.md)。

### 挣扎系统（Struggle）
挣扎菜单。让角色进行挣扎以逃脱拘束。可使用struggle_main记事卡来配置初始的挣扎数据，详情请见[挣扎文档](README.Struggle.md)。

### 语言（Language）
语言选择菜单。可根据需要选择相应语言，语言设定后，即使重置脚本，仍然生效。可使用lan_语言名来配置语言数据，详情请见[语言文档](README.Language.md)。

# 道具控制系统主文档
脚本通过调用llMessageLink方法将指令传递到主脚本，即可实现相关功能。
###### 阅读本文档前，请先阅读[菜单文档](README.Menu.md)，此系统中的部分功能依赖菜单系统，并且指令格式与用法与菜单系统基本保持一致。

## 功能指令
- 通过调用llMessageLink方法传递指令。格式：llMessageLinked(LINK_SET, 指令ID, 指令字符串, 用户UUID)。
- 主脚本指令ID恒为9000。
- 主脚本指令字符串格式：指令标头 | 指令参数1 | 指令参数2 | 指令数据1; 指令数据2; ... | ...
- 主脚本指令字符串根据不同的指令会有所变化，详见下面指令介绍。
- 为了方便阅读，下面的指令和回调中的分隔符【|】、【;】、【&&】两边都添加了空格，实际执行时并不会添加此空格。

### 获取就绪状态
#### MAIN.GET.READY
- 获取就绪状态。当脚本初始化完成时，才会回调自己的就绪状态。
- 如果脚本未初始化完，则不会有任何回调。
```lsl
MAIN.GET.READY
// 回调：
MAIN.READY
```

### 注册功能模块
#### FEATURE.REG
- 注册第三方功能模块。
- 参数分别为：功能名 | 前一个功能名 | 菜单名 | 开关参数
  - 功能名：显示在菜单中的按钮名。此名称不得与已有的功能相同。
  - 前一个功能名：用于功能按钮排序，功能按钮将排在指定功能的后面。如果指定功能名不存在，则排在最后。
    - TOP：排在最前。
    - 整数：排在指定数字的位置。负数则为倒数排列。
    - 留空：不执行排序操作，按照脚本运行的顺序排列。
  - 菜单名：用于功能显示的子菜单位置。
    - mainMenu：显示在主菜单中。
    - appMenu：显示在App菜单中。
    - settingMenu：显示在设置菜单中。
    - 留空：默认为appMenu。
  - 开关参数：用于在按钮左侧显示开关标记（0、1）。留空或-1为禁用。
- 当需要变更开关状态时，只需要重复调用注册指令，传递相同的参数和不同的开关参数即可。
```lsl
FEATURE.REG | featureName | featurePrev | featureMenuName | featureBool
```

### 移除功能模块
#### FEATURE.REM
- 移除第三方功能模块。
- 只有成功匹配到正确的功能名和菜单名才会被移除。
```lsl
FEATURE.REM | featureName | featureMenuName
```

### 更改主菜单条目名称
MAIN.MENU.SET
- 根据需求，更改主菜单的条目名称。
- 只有已存在的主菜单功能才可使用此指令更改。
```lsl
MAIN.MENU.SET | MenuName | NewName
```

### 启用主菜单条目
MAIN.MENU.ENABLE
- 根据需求，显示或隐藏主菜单的指定条目。
- 只有已存在的主菜单功能才可使用此指令显示或隐藏。
```lsl
MAIN.MENU.ENABLE | MenuName | 1
```

### 上锁/解锁
MAIN.LOCK
- 将道具锁在身上，或解除锁定状态。
- 此功能必须配合RLV脚本才可生效。
- 锁定参数留空或为-1时，视为切换锁定状态。
```lsl
MAIN.LOCK | 1
```

### 显示菜单
#### MAIN.MENU
- 立即显示菜单。
- 参数为显示的具体菜单名。
  - mainMenu：主菜单。
  - appMenu：App菜单。
  - settingMenu：设置菜单。
  - 留空：视为默认主菜单。
```lsl
MAIN.MENU | mainMenu
```

# 消息传递
- 在主脚本运行以及和其他脚本配合运行时，以及一些事件触发时，会发送一些llMessageLink消息传递指令。
- 消息传递指令ID恒为9000。
- 消息传递指令字符串格式：指令标头 | 指令参数1 | 指令参数2 | 指令数据1; 指令数据2; ... | ...
- 消息传递指令字符串根据不同的指令会有所变化，详见下面指令介绍。
- 为了方便阅读，下面的消息传递指令中的分隔符【|】、【;】、【&&】两边都添加了空格，实际执行时并不会添加此空格。

### Changed事件
#### MAIN.CHANGED
- 当触发changed事件时，会传递此指令。
- 参数为changed事件发生时的参数值。
```lsl
MAIN.CHANGED | 1
```

### Attach事件
#### MAIN.ATTACH
- 当触发attach事件时，会传递此指令。
- 参数为attach事件发生时的参数值，即穿戴的目标用户UUID。
  - 如果是脱下物件时触发，则此UUID为NULL_KEY。
```lsl
MAIN.ATTACH | UUID
```

### Rez事件
#### MAIN.REZ
- 当触发rez事件时，会传递此指令。
- 参数为rez事件发生时的参数值，start_param。
```lsl
MAIN.REZ | start_param
```

### Touch事件
#### MAIN.TOUCH
- 当触发touch事件时，会传递此指令。
- 参数为touch事件发生时的参数值，num_detected。
```lsl
MAIN.TOUCH | num_detected
```

### Listen事件
#### MAIN.LISTEN
- 当触发listen事件时，会传递此指令。
- 只有收到监听频道消息时，才会传递此指令。
- 参数分别为：频道、名称、消息内容。
- llMessageLinked的id参数传递的是消息发起者的UUID。
```lsl
MAIN.LISTEN | 1 | Name | Content
```


# Renamer系统文档
脚本通过调用llMessageLink方法将Renamer指令传递到Renamer脚本，即可实现相关功能。Renamer的执行结果（如设置Renamer、Renamer执行结果等）也通过触发link_message返回。
###### 阅读本文档前，请先阅读[菜单文档](README.Menu.md)，此Renamer系统中的部分功能依赖菜单系统，并且指令格式与用法与菜单系统基本保持一致。

## Renamer功能指令
- 通过调用llMessageLink方法传递指令。格式：llMessageLinked(LINK_SET, Renamer指令ID, Renamer指令字符串, 用户UUID)。
- Renamer指令ID恒为10011。ID不为10011的消息将被全部忽略。
- Renamer指令字符串格式：指令标头 | 指令参数1 | 指令参数2 | 指令数据1; 指令数据2; ... | ...
- Renamer指令字符串根据不同的指令会有所变化，详见下面指令介绍。
- 为了方便阅读，下面的Renamer指令和回调中的分隔符【|】、【;】、【&&】两边都添加了空格，实际执行时并不会添加此空格。
	- 虽然Renamer系统能自动处理分割符两边的空格，但仍然不建议在拼接时加空格。

### 设置Renamer
#### RENAMER.SET
- 设置Renamer的启用、名字、混淆、声音等。
- 如果不需要改变其中某一项，请将其留空。
- 如果希望Renamer为玩家显示名，请使用“RENAMER_DISPLAY_NAME”。
- 如果希望Renamer为玩家账号名，请使用“RENAMER_USER_NAME”。
- 如果希望Renamer为玩家全名，请使用“RENAMER_FULL_NAME”。
- 如果希望Renamer为物品名，请使用“RENAMER_OBJECT_NAME”。
- 执行后，回调结果为Renamer启用状态、名字、混淆、声音等。
```lsl
RENAMER.SET | 开关; 名字; 混淆; 声音; Hive语音...
// 示例：
RENAMER.SET|1;Name;Confusion;Voice;Hive
RENAMER.SET|0
RENAMER.SET|1;;SomeConfusion
RENAMER.SET|1;Name;;Voice
// 回调：
RENAMER.EXEC | RENAMER.SET | 1; Name; Confusion; Voice; Hive
RENAMER.EXEC | RENAMER.SET | 0; Name; Confusion; Voice; Hive
```

### 设置Renamer混淆
#### RENAMER.SET.CONFUSION | EN | Conf1; Conf2; Conf3; ...
#### RENAMER.SET.CONFUSION | CN | Conf1; Conf2; Conf3; ...
- 设置Renamer混淆文字。
- 参数为EN时，设置仅限英文的混淆文字。
- 参数为CN时，设置中文（或其他Unicode字符）的混淆文字。
执行后，回调结果为Renamer混淆的文字列表。
```lsl
// 示例：
RENAMER.SET.CONFUSION | EN | Conf1; Conf2; Conf3; ...
RENAMER.SET.CONFUSION | CN | Conf1; Conf2; Conf3; ...
// 回调：
RENAMER.EXEC | RENAMER.SET.CONFUSION | EN | Conf1; Conf2; Conf3; ...
RENAMER.EXEC | RENAMER.SET.CONFUSION | CN | Conf1; Conf2; Conf3; ...
```

### 设置Renamer频道
#### RENAMER.SET.CHANNEL | 10086
- 设置Renamer的频道。
执行后，Renamer会重新启动，回调结果为Renamer的频道数。
```lsl
// 示例：
RENAMER.SET.CHANNEL | 10086
// 回调：
RENAMER.EXEC | RENAMER.SET.CHANNEL |10086
```

### 设置是否允许Hive语音
#### RENAMER.SET.ALLOWHIVE | 1
- 设置是否允许Hive语音。
回调结果为是否允许语音的数字值。
```lsl
// 示例：
RENAMER.SET.ALLOWHIVE | 1
// 回调：
RENAMER.EXEC | RENAMER.SET.ALLOWHIVE |1
```

### 设置RLV锁定和Renamer联动
#### RENAMER.SET.CONNECT
- 启用/禁用RLV锁定和Renamer联动，上锁时立即应用Renamer，解锁时清除。
```lsl
RENAMER.SET.CONNECT | 1
// 回调：
RENAMER.EXEC | RENAMER.SET.CONNECT | 1
```

### 获取Renamer状态
#### RENAMER.GET
- 获取Renamer的启用、名字、混淆、声音等状态。
- 执行后，回调结果为Renamer启用状态、名字、混淆、声音、Hive语音等状态值。
```lsl
RENAMER.GET
// 回调：
RENAMER.EXEC | RENAMER.GET | 1; Name; Confusion; Voice; Hive
```

### 获取就绪状态
#### RENAMER.GET.READY
- 获取就绪状态。当脚本存在且初始化完成时，回调自己的就绪状态。
```lsl
RENAMER.GET.READY
// 回调：
RENAMER.READY
```

### 获取Renamer混淆状态
#### RENAMER.GET.CONFUSION | EN
#### RENAMER.GET.CONFUSION | CN
- 获取Renamer混淆文字状态。
- 参数为EN时，获取仅限英文的混淆文字。
- 参数为CN时，获取中文（或其他Unicode字符）的混淆文字。
```lsl
// 示例：
RENAMER.GET.CONFUSION | EN
RENAMER.GET.CONFUSION | CN
// 回调：
RENAMER.EXEC | RENAMER.GET.CONFUSION | EN | Conf1; Conf2; Conf3; ...
RENAMER.EXEC | RENAMER.GET.CONFUSION | CN | Conf1; Conf2; Conf3; ...
```

### 获取Renamer频道
#### RENAMER.GET.CHANNEL
- 获取Renamer频道。
```lsl
// 示例：
RENAMER.GET.CHANNEL
// 回调：
RENAMER.EXEC | RENAMER.GET.CHANNEL |10086
```

### 获取是否允许Hive语音
#### RENAMER.GET.ALLOWHIVE
- 获取是否允许Hive语音。
```lsl
// 示例：
RENAMER.GET.ALLOWHIVE
// 回调：
RENAMER.EXEC | RENAMER.GET.ALLOWHIVE |1
```

### 获取RLV锁定和Renamer联动状态
#### RENAMER.GET.CONNECT
- 获取RLV锁定和Renamer联动状态。
```lsl
RENAMER.GET.CONNECT
// 回调：
RENAMER.EXEC | RENAMER.GET.CONNECT | 1
```

### 执行全部Renamer功能
#### RENAMER.RUN
- 立即执行所有Renamer功能。
```lsl
RENAMER.RUN
// 回调：
RENAMER.EXEC | RENAMER.RUN | 1
```

### 读取Renamer记事卡列表
#### RENAMER.LOAD.LIST
- 读取库存中renamer_开头的记事卡列表。
```lsl
RENAMER.LOAD.LIST
// 回调：
RENAMER.EXEC | RENAMER.LOAD.LIST | renamer_file1; renamer_file2; renamer_file3; ...
```

### 读取Renamer记事卡
#### RENAMER.LOAD
- 从rlv_开头的记事卡中获取Renamer数据。
  - 名字中不需要带renamer_前缀，如记事卡为renamer_main，则只需传递main。
- 执行后，将清空并覆盖现有的Renamer数据。
```lsl
RENAMER.LOAD | file1
// 回调：
RENAMER.EXEC | RENAMER.LOAD | 1
// 读取记事卡成功后的回调
RENAMER.LOAD.NOTECARD | file1 | 1
```

### 显示Renamer菜单
#### RENAMER.MENU
- 立即显示Renamer菜单。
```lsl
RENAMER.MENU | 上级菜单名
```

## 扩展用法
### 批量执行Renamer指令
- 可通过【&&】拼接多条Renamer指令，一次性执行完毕。执行完毕后，回调也是以同样的格式合并发送。
```lsl
RENAMER.SET | 1; Name && RENAMER.SET.CONNECT | 1
// 回调：
RENAMER.EXEC | RENAMER.SET | 1; Name; Confusion; Voice && RENAMER.EXEC | RENAMER.SET.CONNECT | 1
```

## Renamer配置文件格式
- Renamer配置文件名为renamer_开头的记事卡。
- Renamer配置文件格式为【配置名=配置值】这种形式，每行一条。
### 示例
renamer_normal
```lsl
# Renamer自动启用
renamerBool=1
# Renamer频道
renamerChannel=12345678
# Renamer名字
renamerName=RENAMER_FULL_NAME
# 英文混淆列表（使用,分隔）
confusionReplaceEn=f,h,m,n
# 中文（或其他Unicode字符）混淆列表（使用,分隔）
confusionReplaceCn=咕,呜,唔,姆
# 混淆等级（None, Loose, Middle, Strict, Muffle）
renamerConfusion=None
# 混淆时，OOC是否启用
renamerConfusionOOC=1
# 是否允许Hive功能
allowHive=0
# Hive语音是否自动启用
renamerHive=0
# Renamer音效（使用,分隔）
renamerVoice=Voice1,Voice2
# Renamer音效音量
renamerVolume=1.0
# Renamer类型（0: Say; 1: Whisper; 2: Shour; 3: RegionSay）
renamerType=0
```
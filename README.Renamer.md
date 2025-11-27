# 自动化Renamer系统文档
脚本通过调用llMessageLink方法将Renamer指令传递到Renamer脚本，即可实现相关功能。Renamer的执行结果（如设置Renamer、Renamer执行结果等）也通过触发link_message返回。
###### 阅读本文档前，请先阅读[菜单文档](README.Menu.md)，此Renamer系统中的部分功能依赖菜单系统，并且指令格式与用法与菜单系统基本保持一致。

## Renamer功能指令
- 通过调用llMessageLink方法传递指令。格式：llMessageLinked(LINK_SET, Renamer指令ID, Renamer指令字符串, 用户UUID)。
- Renamer指令ID恒为10011。ID不为10011的消息将被全部忽略。
- Renamer指令字符串格式：指令标头 | 指令参数1 | 指令参数2 | 指令数据1, 指令数据2, ... | ...
- Renamer指令字符串根据不同的指令会有所变化，详见下面指令介绍。
- 为了方便阅读，下面的Renamer指令和回调中的分隔符【|】、【,】、【&&】两边都添加了空格，实际执行时并不会添加此空格。
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
RENAMER.SET | 开关; 名字; 混淆; 声音; ...
// 示例：
RENAMER.SET|1;Name;Confusion;Voice
RENAMER.SET|0
RENAMER.SET|1;;SomeConfusion
RENAMER.SET|1;Name;;Voice
// 回调：
RENAMER.EXEC | RENAMER.SET | 1; Name; Confusion; Voice
RENAMER.EXEC | RENAMER.SET | 0; Name; Confusion; Voice
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
- 执行后，回调结果为Renamer启用状态、名字、混淆、声音等状态值。
```lsl
RENAMER.GET
// 回调：
RENAMER.EXEC | RENAMER.GET | 1; Name; Confusion; Voice
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
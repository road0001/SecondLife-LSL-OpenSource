# 抓捕系统文档
脚本通过调用llMessageLink方法将抓捕指令传递到抓捕脚本，即可实现相关功能。
###### 阅读本文档前，请先阅读[菜单文档](README.Menu.md)，此系统中的部分功能依赖菜单系统，并且指令格式与用法与菜单系统基本保持一致。

## 抓捕功能指令
- 通过调用llMessageLink方法传递指令。格式：llMessageLinked(LINK_SET, 抓捕指令ID, 抓捕指令字符串, 用户UUID)。
- 抓捕指令ID恒为1009。ID不为1009的消息将被全部忽略。
- 抓捕指令字符串格式：指令标头 | 指令参数1 | 指令参数2 | 指令数据1; 指令数据2; ... | ...
- 抓捕指令字符串根据不同的指令会有所变化，详见下面指令介绍。
- 为了方便阅读，下面的抓捕指令和回调中的分隔符【|】、【;】、【&&】两边都添加了空格，实际执行时并不会添加此空格。
	- 虽然抓捕系统能自动处理分割符两边的空格，但仍然不建议在拼接时加空格。

### 获取就绪状态
#### CAPTURE.GET.READY
- 获取就绪状态。当脚本存在且初始化完成时，回调自己的就绪状态。
```lsl
CAPTURE.GET.READY
// 回调：
CAPTURE.READY
```

### 设置/获取自动锁定
#### CAPTURE.SET.AUTOLOCK
#### CAPTURE.GET.AUTOLOCK
- 当玩家坐在道具上时，是否自动锁定。
```lsl
CAPTURE.SET.AUTOLOCK | 1
CAPTURE.GET.AUTOLOCK
// 回调：
CAPTURE.EXEC | CAPTURE.SET.AUTOLOCK | 1
CAPTURE.EXEC | CAPTURE.GET.AUTOLOCK | 1
```

### 设置/获取自动抓捕状态
#### CAPTURE.SET.AUTOTRAP
#### CAPTURE.GET.AUTOTRAP
- 当玩家与道具碰撞时，是否自动抓捕。
```lsl
CAPTURE.SET.AUTOTRAP | 1
CAPTURE.GET.AUTOTRAP
// 回调：
CAPTURE.EXEC | CAPTURE.SET.AUTOTRAP | 1
CAPTURE.EXEC | CAPTURE.GET.AUTOTRAP | 1
```

### 设置/获取扫描距离
#### CAPTURE.SET.DISTANCE
#### CAPTURE.GET.DISTANCE
- 抓捕菜单中，扫描距离内的玩家。
```lsl
CAPTURE.SET.DISTANCE | 96.0
CAPTURE.GET.DISTANCE
// 回调：
CAPTURE.EXEC | CAPTURE.SET.DISTANCE | 96.0
CAPTURE.EXEC | CAPTURE.GET.DISTANCE | 96.0
```

### 设置/获取是否显示文字
#### CAPTURE.SET.SHOWTEXT
#### CAPTURE.GET.SHOWTEXT
- 当玩家被捕获时，是否显示相关文字信息。
```lsl
CAPTURE.SET.SHOWTEXT | 1
CAPTURE.GET.SHOWTEXT
// 回调：
CAPTURE.EXEC | CAPTURE.SET.SHOWTEXT | 1
CAPTURE.EXEC | CAPTURE.GET.SHOWTEXT | 1
```

### 设置/获取抓捕超时
#### CAPTURE.SET.TIMEOUT
#### CAPTURE.GET.TIMEOUT
- 当抓捕玩家时，超时后停止抓捕。
- 当玩家站立时，期限内停止抓捕。
```lsl
CAPTURE.SET.TIMEOUT | 10.0
CAPTURE.GET.TIMEOUT
// 回调：
CAPTURE.EXEC | CAPTURE.SET.TIMEOUT | 10.0
CAPTURE.EXEC | CAPTURE.GET.TIMEOUT | 10.0
```

### 设置/获取最多扫描人数
#### CAPTURE.SET.MAXSENSOR
#### CAPTURE.GET.MAXSENSOR
- 抓捕菜单中，限制扫描玩家的数量。
- 请勿设置过大的数值，以免内存溢出。
```lsl
CAPTURE.SET.MAXSENSOR | 18
CAPTURE.GET.MAXSENSOR
// 回调：
CAPTURE.EXEC | CAPTURE.SET.MAXSENSOR | 18
CAPTURE.EXEC | CAPTURE.GET.MAXSENSOR | 18
```

### 设置/获取是否显示通知
#### CAPTURE.SET.NOTICE.SHOW
#### CAPTURE.GET.NOTICE.SHOW
- 当玩家被抓捕、站立、超时时，显示的通知。
```lsl
CAPTURE.SET.NOTICE.SHOW | 1
CAPTURE.GET.NOTICE.SHOW
// 回调：
CAPTURE.EXEC | CAPTURE.SET.NOTICE.SHOW | 1
CAPTURE.EXEC | CAPTURE.GET.NOTICE.SHOW | 1
```

### 设置/获取被抓捕通知文本
#### CAPTURE.SET.NOTICE.CAPTURE
#### CAPTURE.GET.NOTICE.CAPTURE
- 当玩家被抓捕时，显示的通知。
```lsl
CAPTURE.SET.NOTICE.CAPTURE | Text
CAPTURE.GET.NOTICE.CAPTURE
// 回调：
CAPTURE.EXEC | CAPTURE.SET.NOTICE.CAPTURE | Text
CAPTURE.EXEC | CAPTURE.GET.NOTICE.CAPTURE | Text
```

### 设置/获取起立通知文本
#### CAPTURE.SET.NOTICE.UNSIT
#### CAPTURE.GET.NOTICE.UNSIT
- 当玩家起立时，显示的通知。
```lsl
CAPTURE.SET.NOTICE.UNSIT | Text
CAPTURE.GET.NOTICE.UNSIT
// 回调：
CAPTURE.EXEC | CAPTURE.SET.NOTICE.UNSIT | Text
CAPTURE.EXEC | CAPTURE.GET.NOTICE.UNSIT | Text
```

### 设置/获取超时通知文本
#### CAPTURE.SET.NOTICE.TIMEOUT
#### CAPTURE.GET.NOTICE.TIMEOUT
- 当超时后，或陷阱恢复状态时，显示的通知。
```lsl
CAPTURE.SET.NOTICE.TIMEOUT | Text
CAPTURE.GET.NOTICE.TIMEOUT
// 回调：
CAPTURE.EXEC | CAPTURE.SET.NOTICE.TIMEOUT | Text
CAPTURE.EXEC | CAPTURE.GET.NOTICE.TIMEOUT | Text
```

### 抓捕玩家
#### CAPTURE.TRIGGER
- 主动抓捕指定UUID的玩家。
- llMessageLinked中，id字段为捕获的来源。
```lsl
CAPTURE.TRIGGER | UUID
// 无回调。
```

### 让玩家起立
#### CAPTURE.UNSIT
- 让坐在道具上的玩家起立。
```lsl
CAPTURE.UNSIT
// 无回调。
```

### 读取记事卡列表
#### CAPTURE.LOAD.LIST
- 读取库存中capture_开头的记事卡列表。
```lsl
CAPTURE.LOAD.LIST
// 回调：
CAPTURE.EXEC | CAPTURE.LOAD.LIST | capture_1; capture_2; capture_3; ...
```

### 读取记事卡
#### CAPTURE.LOAD
- 从capture_开头的记事卡中获取配置数据。
  - 名字中不需要带capture_前缀，如记事卡为capture_main，则只需传递main。
- 执行后，将清空并覆盖现有的配置数据。
```lsl
CAPTURE.LOAD | file1
// 回调：
CAPTURE.EXEC | CAPTURE.LOAD | 1
// 读取记事卡成功后的回调
CAPTURE.LOAD.NOTECARD | file1 | 1
// 读取记事卡失败后的回调
CAPTURE.LOAD.NOTECARD | file1 | 0
```

### 显示扫描菜单
#### CAPTURE.MENU.SENSOR
- 立即显示扫描玩家菜单。
```lsl
CAPTURE.MENU.SENSOR | 上级菜单名
```

### 显示设置菜单
#### CAPTURE.MENU.SETTING
- 立即显示设置菜单。
```lsl
CAPTURE.MENU.SETTING | 上级菜单名
```
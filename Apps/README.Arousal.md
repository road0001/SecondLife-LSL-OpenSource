# PA2唤起系统文档
脚本通过调用llMessageLink方法将指令传递到PA2唤起脚本，即可实现相关功能。
###### 阅读本文档前，请先阅读[菜单文档](README.Menu.md)，此系统中的部分功能依赖菜单系统，并且指令格式与用法与菜单系统基本保持一致。

## PA2唤起系统指令
- 通过调用llMessageLink方法传递指令。格式：llMessageLinked(LINK_SET, PA2唤起指令ID, PA2唤起指令字符串, 用户UUID)。
- PA2唤起指令ID恒为90001。ID不为90001的消息将被全部忽略。
- PA2唤起指令字符串格式：指令标头 | 指令参数1 | 指令参数2 | 指令数据1; 指令数据2; ... | ...
- PA2唤起指令字符串根据不同的指令会有所变化，详见下面指令介绍。
- PA2唤起依赖Project Arousal 2开发包。
- 为了方便阅读，下面的PA2唤起指令和回调中的分隔符【|】、【;】、【&&】两边都添加了空格，实际执行时并不会添加此空格。
	- 虽然PA2唤起系统能自动处理分割符两边的空格，但仍然不建议在拼接时加空格。

### 设置/获取唤起模式
#### AROUSAL.SET.MODE
#### AROUSAL.GET.MODE
- 设置/获取唤起模式
- 可取值：
  - A:Low, A:Medium, A:High, A:Tease, A:Random, A:Stop
```lsl
AROUSAL.SET.MODE | A:Stop
AROUSAL.GET.MODE
// 回调：
AROUSAL.EXEC | AROUSAL.SET.MODE | A:Stop
AROUSAL.EXEC | AROUSAL.GET.MODE | A:Stop
```

### 设置/获取寸止模式
#### AROUSAL.SET.EDGE
#### AROUSAL.GET.EDGE
- 设置/获取寸止模式
```lsl
AROUSAL.SET.EDGE | 1
AROUSAL.GET.EDGE
// 回调：
AROUSAL.EXEC | AROUSAL.SET.EDGE | 1
AROUSAL.EXEC | AROUSAL.GET.EDGE | 1
```

### 设置/获取是否允许PA2动画
#### AROUSAL.SET.ALLOW_ANIM
#### AROUSAL.GET.ALLOW_ANIM
- 设置/获取是否允许PA2动画
```lsl
AROUSAL.SET.ALLOW_ANIM | 1
AROUSAL.GET.ALLOW_ANIM
// 回调：
AROUSAL.EXEC | AROUSAL.SET.ALLOW_ANIM | 1
AROUSAL.EXEC | AROUSAL.GET.ALLOW_ANIM | 1
```

### 设置/获取寸止模式下限
#### AROUSAL.SET.EDGE_LOWER
#### AROUSAL.GET.EDGE_LOWER
- 设置/获取寸止模式下限
```lsl
AROUSAL.SET.EDGE_LOWER | 1
AROUSAL.GET.EDGE_LOWER
// 回调：
AROUSAL.EXEC | AROUSAL.SET.EDGE_LOWER | 1
AROUSAL.EXEC | AROUSAL.GET.EDGE_LOWER | 1
```

### 设置/获取寸止模式上限
#### AROUSAL.SET.EDGE_UPPER
#### AROUSAL.GET.EDGE_UPPER
- 设置/获取寸止模式上限
```lsl
AROUSAL.SET.EDGE_UPPER | 1
AROUSAL.GET.EDGE_UPPER
// 回调：
AROUSAL.EXEC | AROUSAL.SET.EDGE_UPPER | 1
AROUSAL.EXEC | AROUSAL.GET.EDGE_UPPER | 1
```

### 设置/获取玩家UUID
#### AROUSAL.SET.VICTIM_UUID
#### AROUSAL.GET.VICTIM_UUID
- 设置/获取寸止模式上限
```lsl
AROUSAL.SET.VICTIM_UUID | UUID
AROUSAL.GET.VICTIM_UUID
// 回调：
AROUSAL.EXEC | AROUSAL.SET.VICTIM_UUID | UUID
AROUSAL.EXEC | AROUSAL.GET.VICTIM_UUID | UUID
```

### 获取当前唤起状态
#### AROUSAL.GET.CURRENT
- 获取当前唤起状态
```lsl
AROUSAL.GET.CURRENT
// 回调：
AROUSAL.EXEC | AROUSAL.GET.CURRENT | 50
```

### 获取增量唤起值
#### AROUSAL.GET.VAL
- 获取增量唤起值
```lsl
AROUSAL.GET.VAL
// 回调：
AROUSAL.EXEC | AROUSAL.GET.VAL | 50
```

### 获取唤起触发延迟
#### AROUSAL.GET.DELAY
- 获取唤起触发延迟
```lsl
AROUSAL.GET.DELAY
// 回调：
AROUSAL.EXEC | AROUSAL.GET.DELAY | 2
```

### 获取是否处于寸止状态
#### AROUSAL.GET.IS_EDGED
- 获取是否处于寸止状态
```lsl
AROUSAL.GET.IS_EDGED
// 回调：
AROUSAL.EXEC | AROUSAL.GET.IS_EDGED | 2
```

### 应用唤起状态
#### AROUSAL.APPLY
- 应用唤起状态
```lsl
AROUSAL.APPLY
```

### 应用高潮状态
#### AROUSAL.APPLY.ORGASM
- 应用高潮状态
```lsl
AROUSAL.APPLY
```

### 打开PA2唤起菜单
#### AROUSAL.MENU
- 打开PA2唤起菜单
```lsl
AROUSAL.MENU
```
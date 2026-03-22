# 文字显示系统文档
脚本通过调用llMessageLink方法将文字显示指令传递到文字显示脚本，即可实现相关功能。
###### 阅读本文档前，请先阅读[菜单文档](README.Menu.md)，此系统中的部分功能依赖菜单系统，并且指令格式与用法与菜单系统基本保持一致。

## 文字显示功能指令
- 通过调用llMessageLink方法传递指令。格式：llMessageLinked(LINK_SET, 文字显示指令ID, 文字显示指令字符串, 用户UUID)。
- 文字显示指令ID恒为1008。ID不为1008的消息将被全部忽略。
- 文字显示指令字符串格式：指令标头 | 指令参数1 | 指令参数2 | 指令数据1; 指令数据2; ... | ...
- 文字显示指令字符串根据不同的指令会有所变化，详见下面指令介绍。
- 为了方便阅读，下面的文字显示指令和回调中的分隔符【|】、【;】、【&&】两边都添加了空格，实际执行时并不会添加此空格。
	- 虽然文字显示系统能自动处理分割符两边的空格，但仍然不建议在拼接时加空格。

### 获取就绪状态
#### TEXT.GET.READY
- 获取就绪状态。当脚本存在且初始化完成时，回调自己的就绪状态。
```lsl
TEXT.GET.READY
// 回调：
TEXT.READY
```

### 设置/获取显示文字
#### TEXT.SET
#### TEXT.GET
- 设置/获取显示的文字。
```lsl
TEXT.SET | Name | Content | Bool | Parent
TEXT.GET | Name
// 回调（存在/不存在）：
TEXT.EXEC | TEXT.GET | Name; Content; Bool; Parent
TEXT.EXEC | TEXT.GET |
```

### 获取所有文字
#### TEXT.GET.ALL
- 获取所有文字。
```lsl
TEXT.GET.ALL
// 回调：
TEXT.EXEC | TEXT.GET.ALL | Name1; Content1; Bool1; Parent1; Name2; Content2; Bool2; Parent2; ...
```

### 设置/获取显示状态
#### TEXT.SET.DISPLAY
#### TEXT.GET.DISPLAY
- 设置/获取文字的显示状态。
```lsl
TEXT.SET.DISPLAY | 1
TEXT.GET.DISPLAY
// 回调：
无回调
TEXT.EXEC | TEXT.GET.DISPLAY | 1
```

### 设置/获取显示颜色
#### TEXT.SET.COLOR
#### TEXT.GET.COLOR
- 设置/获取文字的显示状态。
```lsl
TEXT.SET.COLOR | <1.0, 1.0, 1.0>
TEXT.GET.COLOR
// 回调：
无回调
TEXT.EXEC | TEXT.GET.COLOR | <1.0, 1.0, 1.0>
```

### 设置/获取显示透明度
#### TEXT.SET.ALPHA
#### TEXT.GET.ALPHA
- 设置/获取文字的显示透明度。
```lsl
TEXT.SET.ALPHA | 1.0
TEXT.GET.ALPHA
// 回调：
无回调
TEXT.EXEC | TEXT.GET.COLOR | 1.0
```

### 删除显示文字
#### TEXT.REM
#### TEXT.REMOVE
- 删除指定名字的显示文字。
```lsl
TEXT.REM | Name
TEXT.REMOVE | Name
```
# 标题文字系统文档
脚本通过调用llMessageLink方法将指令传递到text显示文字脚本，即可实现相关功能。
###### 阅读本文档前，请先阅读[菜单文档](README.Menu.md)和[文字显示系统文档](README.Text.md)，此系统中的部分功能依赖菜单系统和文字显示系统，并且指令格式与用法与菜单系统基本保持一致。

## 标题系统指令
- 通过调用llMessageLink方法传递指令。格式：llMessageLinked(LINK_SET, 标题指令ID, 标题指令字符串, 用户UUID)。
- 标题指令ID恒为90002。ID不为90002的消息将被全部忽略。
- 标题指令字符串格式：指令标头 | 指令参数1 | 指令参数2 | 指令数据1; 指令数据2; ... | ...
- 标题指令字符串根据不同的指令会有所变化，详见下面指令介绍。
- 为了方便阅读，下面的标题指令和回调中的分隔符【|】、【;】、【&&】两边都添加了空格，实际执行时并不会添加此空格。
	- 虽然标题系统能自动处理分割符两边的空格，但仍然不建议在拼接时加空格。

### 设置/获取标题
#### TITLE.SET.TEXT
#### TITLE.GET.TEXT
- 设置/获取标题
```lsl
TITLE.SET.TEXT | Text
TITLE.GET.TEXT
// 回调：
TITLE.EXEC | TITLE.SET.TEXT | Text
TITLE.EXEC | TITLE.GET.TEXT | Text
```

### 设置/获取标题颜色
#### TITLE.SET.COLOR
#### TITLE.GET.COLOR
- 设置/获取标题颜色
```lsl
TITLE.SET.COLOR | <1.0, 1.0, 1.0>
TITLE.GET.COLOR
// 回调：
TITLE.EXEC | TITLE.SET.COLOR | <1.0, 1.0, 1.0>
TITLE.EXEC | TITLE.GET.COLOR | <1.0, 1.0, 1.0>
```

### 设置/获取标题透明度
#### TITLE.SET.ALPHA
#### TITLE.GET.ALPHA
- 设置/获取标题透明度
```lsl
TITLE.SET.ALPHA | 1.0
TITLE.GET.ALPHA
// 回调：
TITLE.EXEC | TITLE.SET.ALPHA | 1.0
TITLE.EXEC | TITLE.GET.ALPHA | 1.0
```

### 设置/获取标题是否显示
#### TITLE.SET.SHOW
#### TITLE.GET.SHOW
- 设置/获取标题是否显示
```lsl
TITLE.SET.SHOW | 1
TITLE.GET.SHOW
// 回调：
TITLE.EXEC | TITLE.SET.SHOW | 1
TITLE.EXEC | TITLE.GET.SHOW | 1
```

### 打开标题菜单
#### TITLE.MENU
- 打开标题菜单
```lsl
TITLE.MENU | Parent
```

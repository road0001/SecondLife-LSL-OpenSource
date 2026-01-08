# 自动化计时器系统文档
脚本通过调用llMessageLink方法将计时器指令传递到计时器脚本，即可实现相关功能。计时器的执行结果（如设置时间、计时中、计时结束等）也通过触发link_message返回。
###### 阅读本文档前，请先阅读[菜单文档](README.Menu.md)，此计时器系统中的部分功能依赖菜单系统，并且指令格式与用法与菜单系统基本保持一致。

## 计时器功能指令
- 通过调用llMessageLink方法传递指令。格式：llMessageLinked(LINK_SET, 计时器指令ID, 计时器指令字符串, 用户UUID)。
- 计时器指令ID恒为1004。ID不为1004的消息将被全部忽略。
- 计时器指令字符串格式：指令标头 | 指令参数1 | 指令参数2 | 指令数据1; 指令数据2; ... | ...
- 计时器指令字符串根据不同的指令会有所变化，详见下面指令介绍。
- 为了方便阅读，下面的计时器指令和回调中的分隔符【|】、【;】、【&&】两边都添加了空格，实际执行时并不会添加此空格。
	- 虽然计时器系统能自动处理分割符两边的空格，但仍然不建议在拼接时加空格。

### 设置计时器类型
#### TIMER.SET.TYPE
- 设置计时器的类型。
- 类型为数字，0=现实时间，1=在线时间。
```lsl
TIMER.SET.TYPE | 1
// 示例：
TIMER.SET.TYPE|1
TIMER.SET.TYPE|0
// 回调：
TIMER.EXEC | TIMER.SET.TYPE | 1
TIMER.EXEC | TIMER.SET.TYPE | 0
```

### 设置计时器时长
#### TIMER.SET
- 设置计时器的时长。
- 参数为≥0的整数，代表秒数。
- 设置此时长，将重置当前的计时状态。
```lsl
TIMER.SET | 60
// 示例：
TIMER.SET | 60
// 回调：
TIMER.EXEC | TIMER.SET | 60
```

### 设置计时器文字显示
#### TIMER.SET.TEXT.SHOW
- 设置计时器是否显示倒计时文字。
- 参数为数字，0=不显示，1=显示。
```lsl
TIMER.SET.TEXT.SHOW | 1
// 示例：
TIMER.SET.TEXT.SHOW|1
TIMER.SET.TEXT.SHOW|0
// 回调：
TIMER.EXEC | TIMER.SET.TEXT.SHOW | 1
TIMER.EXEC | TIMER.SET.TEXT.SHOW | 0
```

### 设置计时器文字颜色
#### TIMER.SET.TEXT.COLOR
- 设置计时器显示倒计时文字的颜色。
- 参数为向量，\<R, G, B\>分别代表红、绿、蓝三种颜色，每种颜色取值0~1的小数。
```lsl
TIMER.SET.TEXT.COLOR | <1.0, 1.0, 1.0>
// 示例：
TIMER.SET.TEXT.COLOR | <1.0, 1.0, 1.0>
// 回调：
TIMER.EXEC | TIMER.SET.TEXT.COLOR | <1.0, 1.0, 1.0>
```

### 设置计时器文字透明度
#### TIMER.SET.TEXT.ALPHA
- 设置计时器显示倒计时文字的透明度。
- 参数为0~1的小数。
```lsl
TIMER.SET.TEXT.ALPHA | 1.0
// 示例：
TIMER.SET.TEXT.ALPHA | 1.0
// 回调：
TIMER.EXEC | TIMER.SET.TEXT.ALPHA | 1.0
```

### 增加计时器时长
#### TIMER.ADD
- 为计时器增加时长。
- 参数为≥0的整数，代表秒数。
- 回调为计时器的总时长。
```lsl
TIMER.ADD | 60
// 示例：
TIMER.ADD | 60
// 回调：
TIMER.EXEC | TIMER.ADD | 120
```

### 获取计时器类型
#### TIMER.GET.TYPE
- 获取计时器的类型。
- 类型为数字，0=现实时间，1=在线时间。
```lsl
TIMER.GET.TYPE
// 回调：
TIMER.EXEC | TIMER.GET.TYPE | 1
```

### 获取计时器状态
#### TIMER.GET
- 获取计时器的状态。
- 获得的数据分别为：当前计时器状态；计时器类型；当前秒数；总体秒数。
	- 当前计时器状态：STOP=停止；RUNNING=正在计时；TIMEOUT=已超时
```lsl
TIMER.GET
// 回调：
TIMER.EXEC | TIMER.GET | STOPPED; 0; 60; 120
```

### 获取计时器文字显示状态
#### TIMER.GET.TEXT
- 设置计时器是否显示倒计时文字。
- 获得的数据分别为：是否显示文字；文字颜色；文字透明度
```lsl
TIMER.GET.TEXT
// 回调：
TIMER.EXEC | TIMER.GET.TEXT | 1; <1.0, 1.0, 1.0>, 1.0
```

### 暂停计时器
#### TIMER.PAUSE
- 设置计时器处于暂停状态。
```lsl
TIMER.PAUSE
// 回调：
TIMER.EXEC | TIMER.PAUSE | 0
```

### 恢复计时器
#### TIMER.RUN
- 设置计时器处于正常状态。
```lsl
TIMER.RUN
// 回调：
TIMER.EXEC | TIMER.RUN | 1
```

### 重启计时器
#### TIMER.RESTART
- 重置计时器状态并启动计时。
```lsl
TIMER.RESTART
// 回调：
TIMER.EXEC | TIMER.RESTART | 1
```

### 重置计时器
#### TIMER.CLEAR
- 重置计时器状态。
```lsl
TIMER.CLEAR
// 回调：
TIMER.EXEC | TIMER.CLEAR | 1
```

### 显示计时器菜单
#### TIMER.MENU
- 立即显示计时器菜单。
```lsl
TIMER.MENU | 上级菜单名
```

## 扩展用法
### 批量执行计时器指令
- 可通过【&&】拼接多条计时器指令，一次性执行完毕。执行完毕后，回调也是以同样的格式合并发送。
```lsl
TIMER.SET | 60 && TIMER.RUN
// 回调：
TIMER.EXEC | TIMER.SET | 60 && TIMER.EXEC | TIMER.RUN | 1
```
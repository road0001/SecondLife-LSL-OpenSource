# 挣扎系统文档
脚本通过调用llMessageLink方法将挣扎指令传递到挣扎脚本，即可实现相关功能。挣扎的执行结果（如设置属性、开始挣扎、停止挣扎等）也通过触发link_message返回。
###### 阅读本文档前，请先阅读[菜单文档](README.Menu.md)，此挣扎系统中的部分功能依赖菜单系统，并且指令格式与用法与菜单系统基本保持一致。

## 挣扎功能指令
- 通过调用llMessageLink方法传递指令。格式：llMessageLinked(LINK_SET, 挣扎指令ID, 挣扎指令字符串, 用户UUID)。
- 挣扎指令ID恒为1007。ID不为1007的消息将被全部忽略。
- 挣扎指令字符串格式：指令标头 | 指令参数1 | 指令参数2 | 指令数据1; 指令数据2; ... | ...
- 挣扎指令字符串根据不同的指令会有所变化，详见下面指令介绍。
- 为了方便阅读，下面的挣扎指令和回调中的分隔符【|】、【;】、【&&】两边都添加了空格，实际执行时并不会添加此空格。
	- 虽然挣扎系统能自动处理分割符两边的空格，但仍然不建议在拼接时加空格。

### 获取就绪状态
#### STRUGGLE.GET.READY
- 获取就绪状态。当脚本存在且初始化完成时，回调自己的就绪状态。
```lsl
STRUGGLE.GET.READY
// 回调：
STRUGGLE.READY
```

### 设置/获取挣扎类型
#### STRUGGLE.SET.TYPE
#### STRUGGLE.GET.TYPE
- 设置挣扎的类型。
- 类型为数字，0=概率成功，1=正确按键。
```lsl
STRUGGLE.SET.TYPE | 1
STRUGGLE.GET.TYPE
// 回调：
STRUGGLE.EXEC | STRUGGLE.SET.TYPE | 1
STRUGGLE.EXEC | STRUGGLE.GET.TYPE | 1
```

### 设置/获取挣扎难度
#### STRUGGLE.SET.DIFFICULTY
#### STRUGGLE.GET.DIFFICULTY
- 设置挣扎的难度。取值：1～10。
- 在概率模式下，难度越高，挣扎成功的概率越低。请勿超过10，否则将无法挣扎成功。
- 在正确按键模式下，难度越高，需要按到正确按键的数量越多。
```lsl
STRUGGLE.SET.DIFFICULTY | 5
STRUGGLE.GET.DIFFICULTY
// 回调：
STRUGGLE.EXEC | STRUGGLE.SET.DIFFICULTY | 5
STRUGGLE.EXEC | STRUGGLE.GET.DIFFICULTY | 5
```

### 设置/获取挣扎减益
#### STRUGGLE.SET.DEBUFF
#### STRUGGLE.GET.DEBUFF
- 设置挣扎的减益。
- 每计数N次，挣扎进度减1。此计数还和挣扎频率相关。
```lsl
STRUGGLE.SET.DEBUFF | 10
STRUGGLE.GET.DEBUFF
// 回调：
STRUGGLE.EXEC | STRUGGLE.SET.DEBUFF | 10
STRUGGLE.EXEC | STRUGGLE.GET.DEBUFF | 10
```

### 设置/获取挣扎频率
#### STRUGGLE.SET.INTERVAL
#### STRUGGLE.GET.INTERVAL
- 设置挣扎的频率（秒）。
- 每挣扎一次，需要间隔一段时间才能再次挣扎。
- 减益的计数也和挣扎频率相关。
```lsl
STRUGGLE.SET.INTERVAL | 0.5
STRUGGLE.GET.INTERVAL
// 回调：
STRUGGLE.EXEC | STRUGGLE.SET.INTERVAL | 0.5
STRUGGLE.EXEC | STRUGGLE.GET.INTERVAL | 0.5
```

### 设置/获取挣扎按键
#### STRUGGLE.SET.KEYS
#### STRUGGLE.GET.KEYS
- 设置允许挣扎的按键。
- 按键对应数字：
  - W=1；S=2；A=256；D=512；E=16；C=32；
```lsl
STRUGGLE.SET.KEYS | 1;2;256;512
STRUGGLE.GET.KEYS
// 回调：
STRUGGLE.EXEC | STRUGGLE.SET.KEYS | 1;2;256;512
STRUGGLE.EXEC | STRUGGLE.GET.KEYS | 1;2;256;512
```

### 设置/获取挣扎动画
#### STRUGGLE.SET.ANIMS
#### STRUGGLE.GET.ANIMS
- 设置挣扎的动画。
- 动画应与上方按键一一对应。
```lsl
STRUGGLE.SET.ANIMS | Anim1;Anim2;Anim3;Anim4
STRUGGLE.GET.ANIMS
// 回调：
STRUGGLE.EXEC | STRUGGLE.SET.ANIMS | Anim1;Anim2;Anim3;Anim4
STRUGGLE.EXEC | STRUGGLE.GET.ANIMS | Anim1;Anim2;Anim3;Anim4
```

### 设置/获取挣扎文字显示
#### STRUGGLE.SET.TEXT
#### STRUGGLE.GET.TEXT
- 设置挣扎时显示文字和进度条。
- 如果文字为空，则不显示任何内容（包括进度）。
```lsl
STRUGGLE.SET.TEXT | Struggling...
STRUGGLE.GET.TEXT
// 回调：
STRUGGLE.EXEC | STRUGGLE.SET.TEXT | Struggling...
STRUGGLE.EXEC | STRUGGLE.GET.TEXT | Struggling...
```

### 设置/获取挣扎文字颜色
#### STRUGGLE.SET.COLOR
#### STRUGGLE.GET.COLOR
- 设置挣扎显示文字的颜色。
- 参数为向量，\<R, G, B\>分别代表红、绿、蓝三种颜色，每种颜色取值0~1的小数。
```lsl
STRUGGLE.SET.COLOR | <1.0, 0.0, 0.0>
STRUGGLE.GET.COLOR
// 回调：
STRUGGLE.EXEC | STRUGGLE.SET.COLOR | <1.0, 0.0, 0.0>
STRUGGLE.EXEC | STRUGGLE.GET.COLOR | <1.0, 0.0, 0.0>
```

### 设置/获取挣扎文字透明度
#### STRUGGLE.SET.ALPHA
#### STRUGGLE.GET.ALPHA
- 设置挣扎显示文字的透明度。
- 参数为0~1的小数。
```lsl
STRUGGLE.SET.ALPHA | 1.0
STRUGGLE.GET.ALPHA
// 回调：
STRUGGLE.EXEC | STRUGGLE.SET.ALPHA | 1.0
STRUGGLE.EXEC | STRUGGLE.GET.ALPHA | 1.0
```


### 开始挣扎
#### STRUGGLE.BEGIN
```lsl
STRUGGLE.BEGIN
// 回调：
STRUGGLE.APPLY.BEGIN
```

### 停止挣扎
#### STRUGGLE.STOP
```lsl
STRUGGLE.STOP
// 回调：
STRUGGLE.APPLY.STOP
```

### 成功挣扎
#### STRUGGLE.SUCCESS
```lsl
STRUGGLE.SUCCESS
// 回调：
STRUGGLE.APPLY.SUCCESS
```

### 显示挣扎菜单
#### STRUGGLE.MENU
- 立即显示挣扎菜单。
```lsl
STRUGGLE.MENU | 上级菜单名
```

### 读取记事卡列表
#### STRUGGLE.LOAD.LIST
- 读取库存中struggle_开头的记事卡列表。
```lsl
STRUGGLE.LOAD.LIST
// 回调：
STRUGGLE.EXEC | STRUGGLE.LOAD.LIST | struggle_s1; struggle_s2; struggle_s3; ...
```

### 读取记事卡
#### STRUGGLE.LOAD
- 从struggle_开头的记事卡中获取配置数据。
  - 名字中不需要带struggle_前缀，如记事卡为struggle_main，则只需传递main。
```lsl
STRUGGLE.LOAD | file1
// 回调：
STRUGGLE.EXEC | STRUGGLE.LOAD | 1
// 读取记事卡成功后的回调
STRUGGLE.LOAD.NOTECARD | file1 | 1
// 记事卡不存在的回调
STRUGGLE.LOAD.NOTECARD | file1 | 0
```

## 挣扎状态通知
- 当挣扎开始、停止、成功时，会发送状态通知。
	- STRUGGLE.APPLY.BEGIN
	- STRUGGLE.APPLY.STOP
	- STRUGGLE.APPLY.SUCCESS

## 挣扎配置文件格式
- 挣扎配置文件名为struggle_开头的记事卡。
- 挣扎配置文件格式为【配置名=配置值】这种形式，每行一条。
### 示例
struggle_normal
```lsl
# 挣扎类型（0=概率成功，1=正确按键）
struggleType=1
# 挣扎难度
struggleDifficulty=5
# 挣扎减益
struggleDebuff=10
# 挣扎频率
struggleInterval=0.5
# 挣扎按键（W=1；S=2；A=256；D=512；E=16；C=32）
struggleKeys=1;2;256;512
# 挣扎动画（应与上方按键一一对应）
struggleAnims=Anim1;Anim2;Anim3;Anim4
# 挣扎文本
struggleText=Struggling
# 挣扎文本颜色
struggleTextColor=<1.0, 0.0, 0.0>
# 挣扎文本透明度
struggleTextAlpha=1.0
```
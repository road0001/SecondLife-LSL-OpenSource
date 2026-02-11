# 动画系统文档
脚本通过调用llMessageLink方法将动画相关指令传递到动画脚本，即可实现相关功能。动画系统的执行结果也通过触发link_message返回。
###### 阅读本文档前，请先阅读[菜单文档](README.Menu.md)，此系统中的部分功能依赖菜单系统，并且指令格式与用法与菜单系统基本保持一致。

## 动画功能指令
- 通过调用llMessageLink方法传递指令。格式：llMessageLinked(LINK_SET, 动画指令ID, 动画指令字符串, 用户UUID)。
- 动画指令ID恒为1006。ID不为1006的消息将被全部忽略。
- 动画指令字符串格式：指令标头 | 指令参数1 | 指令参数2 | 指令数据1; 指令数据2; ... | ...
- 动画指令字符串根据不同的指令会有所变化，详见下面指令介绍。
- 为了方便阅读，下面的动画指令和回调中的分隔符【|】、【;】、【&&】两边都添加了空格，实际执行时并不会添加此空格。
	- 虽然动画系统能自动处理分割符两边的空格，但仍然不建议在拼接时加空格。

### 添加动画
#### ANIM.SET
- 添加动画。
- 参数分别为动画名称、动画参数、动画所属类别、动画是否自动播放。
- 动画参数格式：动画文件名;动画重播时长（小数）;悬浮高度（小数）
- 动画类别如果不为空，将自动添加此类别，用于菜单中的分类显示。
- 动画是否自动播放为1时，在添加此动画后，立即自动播放。
- 动画已存在时，原有的数据将被覆盖。
```lsl
ANIM.SET | AnimName1 | AnimParams1 | AnimClassName1 | AnimAutoPlay1
// 回调：
ANIM.EXEC | ANIM.SET | 1
```

### 是否自动调整悬浮高度
#### ANIM.SET.AUTOHEIGHT
- 在播放动画时，使用RLV指令自动调整悬浮高度，仅在使用参数播放动画时生效。
- 此功能依赖客户端的RLV功能，在RLV开启时才能生效。
```lsl
ANIM.SET.AUTOHEIGHT | 1
// 回调：
ANIM.EXEC | ANIM.SET.AUTOHEIGHT | 1
```

### 是否允许停止动画
#### ANIM.SET.ALLOWSTOP
- 启用此功能时，会在菜单中添加一个\[STOP\]按钮来停止播放动画，禁用时隐藏。
```lsl
ANIM.SET.ALLOWSTOP | 1
// 回调：
ANIM.EXEC | ANIM.SET.ALLOWSTOP | 1
```

### 获取动画列表
#### ANIM.GET
- 获取当前拥有的动画列表。
```lsl
ANIM.GET
// 回调：
ANIM.EXEC | ANIM.GET | AnimName1 | AnimFile1;AnimInterval;AnimFloatHeight | AnimClassName1 | AnimAutoPlay1 | AnimName2 | ...
```

### 获取正在播放的动画名称
#### ANIM.GET.PLAYING
- 获取当前正在播放的动画名称。
- 使用参数或文件名播放时，此项为空。
```lsl
ANIM.GET.PLAYING
// 回调：
ANIM.EXEC | ANIM.GET.PLAYING | AnimName1
```

### 获取正在播放的动画名称
#### ANIM.GET.PLAYING.PARAMS
- 获取当前正在播放的动画参数。
- 使用文件名播放时，此项为空。
```lsl
ANIM.GET.PLAYING.PARAMS
// 回调：
ANIM.EXEC | ANIM.GET.PLAYING.PARAMS | AnimFile1;AnimInterval;AnimFloatHeight
```

### 获取正在播放的动画文件名
#### ANIM.GET.PLAYING.FILE
- 获取正在播放的动画文件名。
```lsl
ANIM.GET.PLAYING.FILE
// 回调：
ANIM.EXEC | ANIM.GET.PLAYING.FILE | AnimFile1
```

### 开始播放动画
#### ANIM.PLAY
- 开始播放动画。
- 如果动画配置不存在，则无法播放。请先配置动画数据。
```lsl
ANIM.PLAY | AnimName1
// 回调：
ANIM.EXEC | ANIM.PLAY | 1
```

### 开始播放动画（按参数）
#### ANIM.PLAY.PARAMS
- 按参数开始播放动画。
```lsl
ANIM.PLAY.PARAMS | AnimFile1;AnimInterval;AnimFloatHeight
// 回调：
ANIM.EXEC | ANIM.PLAY.PARAMS | 1
```

### 开始播放动画（按文件名）
#### ANIM.PLAY.FILE
- 按文件名开始播放动画。
```lsl
ANIM.PLAY.FILE | AnimFile1
// 回调：
ANIM.EXEC | ANIM.PLAY.FILE | 1
```

### 停止播放动画
#### ANIM.STOP
- 停止播放所有动画。
```lsl
ANIM.STOP
// 回调：
ANIM.EXEC | ANIM.STOP | 1
```

### 读取记事卡列表
#### ANIM.LOAD.LIST
- 读取库存中anim_开头的记事卡列表。
```lsl
ANIM.LOAD.LIST
// 回调：
ANIM.EXEC | ANIM.LOAD.LIST | anim_1; anim_2; anim_3; ...
```

### 读取记事卡
#### ANIM.LOAD
- 从anim_开头的记事卡中获取访问数据数据。
  - 名字中不需要带anim_前缀，如记事卡为anim_main，则只需传递main。
```lsl
ANIM.LOAD | file1
// 回调：
ANIM.EXEC | ANIM.LOAD | 1
// 读取记事卡成功后的回调
ANIM.LOAD.NOTECARD | file1 | 1
```

### 显示动画菜单
#### ANIM.MENU
- 立即显示牵绳菜单。
```lsl
ANIM.MENU | 上级菜单名
```

## 扩展用法
### 批量执行牵绳指令
- 可通过【&&】拼接多条牵绳指令，一次性执行完毕。执行完毕后，回调也是以同样的格式合并发送。
```lsl
ANIM.SET | AnimName1 | AnimParams1 | AnimClassName1 | AnimAutoPlay1 && ANIM.PLAY | AnimName1
// 回调：
ANIM.EXEC | ANIM.SET | 1 && ANIM.EXEC | ANIM.PLAY | 1
```

## 动画配置文件格式
- 动画配置文件名为anim_开头的记事卡。
- 动画配置文件格式为【动画名称=动画文件名;动画重播时长;动画悬浮高度】这种形式，每行一条。
- 可用\[动画类别\]来设定动画类别。
- 动画名称*号可使动画在初始化后自动播放此动画。
	- 配置文件中请勿添加多个*号，否则只有最后一个才能自动播放。
- 未注册的动画类别将自动注册。同名的懂类别中的动画配置组将被归类到同一菜单中。
- 如果只有一个动画类别，则菜单不再显示类别选择，而是直接显示此动画类别的子菜单。
### 示例
anim_main
```lsl
[Basics]
Run=runanim1;10;0
Walk=walkanim1;10;5
[Fly]
*Fly1=flyanim1;5;20
Fly2=flyanim2
```

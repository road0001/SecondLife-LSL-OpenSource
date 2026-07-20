# 声音系统文档
脚本通过调用llMessageLink方法将指令传递到脚本，即可实现相关功能。
###### 阅读本文档前，请先阅读[菜单文档](README.Menu.md)，此系统中的部分功能依赖菜单系统，并且指令格式与用法与菜单系统基本保持一致。

## 声音系统指令
- 通过调用llMessageLink方法传递指令。格式：llMessageLinked(LINK_SET, 声音指令ID, 声音指令字符串, 用户UUID)。
- 声音指令ID恒为90005。ID不为90005的消息将被全部忽略。
- 声音指令字符串格式：指令标头 | 指令参数1 | 指令参数2 | 指令数据1; 指令数据2; ... | ...
- 声音指令字符串根据不同的指令会有所变化，详见下面指令介绍。
- 为了方便阅读，下面的声音指令和回调中的分隔符【|】、【;】、【&&】两边都添加了空格，实际执行时并不会添加此空格。
	- 虽然声音系统能自动处理分割符两边的空格，但仍然不建议在拼接时加空格。

### 播放声音
#### SOUND.PLAY
- 参数：声音文件名/UUID，音量，是否启用，声音触发模式
- 除了文件名外，后续参数均可省略，使用默认值。
- 声音触发模式可取值：
	- 0：正常播放。
	- 1：Trigger模式播放。
	- 2：循环模式播放。
```lsl
SOUND.PLAY | soundName | 1.0 | 1 | 0
// 回调：
SOUND.EXEC | SOUND.PLAY | 1
```

### 停止播放声音
#### SOUND.STOP
```lsl
SOUND.STOP
// 回调：
SOUND.EXEC | SOUND.STOP | 1
```

### 设置/获取音量
#### SOUND.SET.VOLUME
#### SOUND.GET.VOLUME
```lsl
SOUND.SET.VOLUME | 1.0
SOUND.GET.VOLUME
// 回调：
SOUND.EXEC | SOUND.SET.VOLUME | 1.0
SOUND.EXEC | SOUND.GET.VOLUME | 1.0
```

### 播放行走声音
#### SOUND.WALK.PLAY
- 当其他脚本申请PERMISSION_TAKE_CONTROLS权限时，会覆盖本脚本的权限，导致行走声音无法播放。因此可通过此接口间接播放行走声音。
- 此行走声音的播放仍然受到CD限制。
```lsl
SOUND.WALK.PLAY
```

### 设置/获取行走声音音量
#### SOUND.WALK.SET.VOLUME
#### SOUND.WALK.GET.VOLUME
```lsl
SOUND.WALK.SET.VOLUME | 1.0
SOUND.WALK.GET.VOLUME
// 回调：
SOUND.EXEC | SOUND.WALK.SET.VOLUME | 1.0
SOUND.EXEC | SOUND.WALK.GET.VOLUME | 1.0
```

### 恢复行走声音播放
#### SOUND.WALK.RECOVER
- 当其他脚本申请PERMISSION_TAKE_CONTROLS权限时，会覆盖本脚本的权限，导致行走声音无法播放。因此当其他脚本使用完毕时，应主动调用此接口以恢复行走声音播放。
```lsl
SOUND.WALK.RECOVER
// 授权成功后回调：
SOUND.EXEC | SOUND.WALK.RECOVER | 1
```

### 打开声音菜单
#### SOUND.MENU
- 打开声音菜单
```lsl
SOUND.MENU | Parent
```
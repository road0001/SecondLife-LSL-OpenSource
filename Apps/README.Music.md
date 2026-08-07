# 音乐系统文档
脚本通过调用llMessageLink方法将指令传递到脚本，即可实现相关功能。
###### 阅读本文档前，请先阅读[菜单文档](README.Menu.md)，此系统中的部分功能依赖菜单系统，并且指令格式与用法与菜单系统基本保持一致。

## 音乐系统指令
- 通过调用llMessageLink方法传递指令。格式：llMessageLinked(LINK_SET, 音乐指令ID, 音乐指令字符串, 用户UUID)。
- 音乐指令ID恒为90006。ID不为90006的消息将被全部忽略。
- 音乐指令字符串格式：指令标头 | 指令参数1 | 指令参数2 | 指令数据1; 指令数据2; ... | ...
- 音乐指令字符串根据不同的指令会有所变化，详见下面指令介绍。
- 为了方便阅读，下面的音乐指令和回调中的分隔符【|】、【;】、【&&】两边都添加了空格，实际执行时并不会添加此空格。
	- 虽然音乐系统能自动处理分割符两边的空格，但仍然不建议在拼接时加空格。

### 初始化音乐
#### MUSIC.INIT
- 载入当前库存中的音乐配置数据。
```lsl
// 载入成功后回调：
MUSIC.READY | musicRealName1; musicRealName2; musicRealName3; ...
```

### 播放音乐
#### MUSIC.PLAY
- 参数：音乐名称
	- 此名称为记事卡中第一行配置的名字。
	- 此名称可省略，省略则为当前播放的音乐。
```lsl
MUSIC.PLAY | musicRealName
// 开始读取记事卡回调：
MUSIC.EXEC | MUSIC.LOAD | musicNotecardName
// 读取记事卡成功后回调：
MUSIC.EXEC | MUSIC.LOADED | musicNotecardName
// 处理完成后回调：
MUSIC.EXEC | MUSIC.PLAY | musicRealName | musicAuthor | musicAlbum | musicLength
// 正在播放和切换片段时回调：
MUSIC.EXEC | MUSIC.PLAYING | musicRealName | musicAuthor | musicAlbum | musicLength | musicSoundIndex
// musicSoundIndex为片段索引，从0开始，并以偶数递增，如：0、2、4、6……
```

### 停止播放音乐
#### MUSIC.STOP
```lsl
MUSIC.STOP
// 回调：
MUSIC.EXEC | MUSIC.STOP | 1
```

### 播放上一曲/下一曲
#### MUSIC.PREV
#### MUSIC.NEXT
```lsl
MUSIC.PREV
MUSIC.NEXT
```

### 设置/获取音量
#### MUSIC.SET.VOLUME
#### MUSIC.GET.VOLUME
```lsl
MUSIC.SET.VOLUME | 1.0
MUSIC.GET.VOLUME
// 回调：
MUSIC.EXEC | MUSIC.SET.VOLUME | 1.0
MUSIC.EXEC | MUSIC.GET.VOLUME | 1.0
```

### 设置/获取播放模式
#### MUSIC.SET.TYPE
#### MUSIC.GET.TYPE
- 播放模式分别为：-1：单曲循环  0：播放一次  1：顺序播放  2：倒序播放  3：随机播放
```lsl
MUSIC.SET.TYPE | 1
MUSIC.GET.TYPE
// 回调：
MUSIC.EXEC | MUSIC.SET.TYPE | 1
MUSIC.EXEC | MUSIC.GET.TYPE | 1
```

### 设置/获取循环播放模式
#### MUSIC.SET.LOOP
#### MUSIC.GET.LOOP
```lsl
MUSIC.SET.LOOP | 1
MUSIC.GET.LOOP
// 回调：
MUSIC.EXEC | MUSIC.SET.LOOP | 1
MUSIC.EXEC | MUSIC.GET.LOOP | 1
```

### 打开音乐菜单
#### MUSIC.MENU
- 打开音乐菜单
```lsl
MUSIC.MENU | Parent
```
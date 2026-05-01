# 惩罚文字系统文档
脚本通过调用llMessageLink方法将指令传递到text显示文字脚本，即可实现相关功能。
###### 阅读本文档前，请先阅读[菜单文档](README.Menu.md)，此系统中的部分功能依赖菜单系统，并且指令格式与用法与菜单系统基本保持一致。

## 惩罚系统指令
- 通过调用llMessageLink方法传递指令。格式：llMessageLinked(LINK_SET, 惩罚指令ID, 惩罚指令字符串, 用户UUID)。
- 惩罚指令ID恒为90004。ID不为90004的消息将被全部忽略。
- 惩罚指令字符串格式：指令标头 | 指令参数1 | 指令参数2 | 指令数据1; 指令数据2; ... | ...
- 惩罚指令字符串根据不同的指令会有所变化，详见下面指令介绍。
- 为了方便阅读，下面的惩罚指令和回调中的分隔符【|】、【;】、【&&】两边都添加了空格，实际执行时并不会添加此空格。
	- 虽然惩罚系统能自动处理分割符两边的空格，但仍然不建议在拼接时加空格。

### 触发惩罚/黑屏/恢复
### PUNISH.TRIGGER.PUNISH
### PUNISH.TRIGGER.BLACKOUT
### PUNISH.TRIGGER.RECOVERY
- 主动触发惩罚、黑屏、恢复。
- 参数：是否自动下一步（1/0）；持续时长（秒）。
- 自动下一步为1时，时长结束自动进行下一步。
- 持续时长为-1时，为默认的随机时长。
```lsl
// 惩罚
PUNISH.TRIGGER.PUNISH | 0
PUNISH.TRIGGER.PUNISH | 1
PUNISH.TRIGGER.PUNISH | 1 | 10
// 黑屏
PUNISH.TRIGGER.BLACKOUT | 0
PUNISH.TRIGGER.BLACKOUT | 1
PUNISH.TRIGGER.BLACKOUT | 1 | 10
// 恢复
PUNISH.TRIGGER.RECOVERY
```

### 设置/获取是否监听触发
#### PUNISH.SET.ENABLED
#### PUNISH.GET.ENABLED
```lsl
PUNISH.SET.ENABLED | 1
PUNISH.GET.ENABLED
// 回调：
PUNISH.EXEC | PUNISH.SET.ENABLED | 1
PUNISH.EXEC | PUNISH.GET.ENABLED | 1
```

### 设置/获取是否监听触发别人的发言
#### PUNISH.SET.ENABLED.OTHERS
#### PUNISH.GET.ENABLED.OTHERS
```lsl
PUNISH.SET.ENABLED.OTHERS | 1
PUNISH.GET.ENABLED.OTHERS
// 回调：
PUNISH.EXEC | PUNISH.SET.ENABLED.OTHERS | 1
PUNISH.EXEC | PUNISH.GET.ENABLED.OTHERS | 1
```

### 设置/获取是否启用高潮系统（需要PA2插件）
#### PUNISH.SET.ENABLED.AROUSAL
#### PUNISH.GET.ENABLED.AROUSAL
```lsl
PUNISH.SET.ENABLED.AROUSAL | 1
PUNISH.GET.ENABLED.AROUSAL
// 回调：
PUNISH.EXEC | PUNISH.SET.ENABLED.AROUSAL | 1
PUNISH.EXEC | PUNISH.GET.ENABLED.AROUSAL | 1
```

### 设置/获取高潮系统每帧增加值（需要PA2插件）
#### PUNISH.SET.AROUSAL.VALUE
#### PUNISH.GET.AROUSAL.VALUE
```lsl
PUNISH.SET.AROUSAL.VALUE | 10
PUNISH.GET.AROUSAL.VALUE
// 回调：
PUNISH.EXEC | PUNISH.SET.AROUSAL.VALUE | 1
PUNISH.EXEC | PUNISH.GET.AROUSAL.VALUE | 1
```

### 设置/获取惩罚动画列表
#### PUNISH.SET.PUNISH.ANIMS
#### PUNISH.GET.PUNISH.ANIMS
```lsl
PUNISH.SET.PUNISH.ANIMS | Anim1; Anim2; ...
PUNISH.GET.PUNISH.ANIMS
// 回调：
PUNISH.EXEC | PUNISH.SET.PUNISH.ANIMS | Anim1; Anim2; ...
PUNISH.EXEC | PUNISH.GET.PUNISH.ANIMS | Anim1; Anim2; ...
```

### 设置/获取惩罚粒子帧
#### PUNISH.SET.PUNISH.FRAMES
#### PUNISH.GET.PUNISH.FRAMES
```lsl
PUNISH.SET.PUNISH.FRAMES | Frame1; Frame2; ...
PUNISH.GET.PUNISH.FRAMES
// 回调：
PUNISH.EXEC | PUNISH.SET.PUNISH.FRAMES | Frame1; Frame2; ...
PUNISH.EXEC | PUNISH.GET.PUNISH.FRAMES | Frame1; Frame2; ...
```

### 设置/获取惩罚粒子帧率
#### PUNISH.SET.PUNISH.FRAMERATE
#### PUNISH.GET.PUNISH.FRAMERATE
```lsl
PUNISH.SET.PUNISH.FRAMERATE | 0.2
PUNISH.GET.PUNISH.FRAMERATE
// 回调：
PUNISH.EXEC | PUNISH.SET.PUNISH.FRAMERATE | 0.2
PUNISH.EXEC | PUNISH.GET.PUNISH.FRAMERATE | 0.2
```

### 设置/获取惩罚时长范围
#### PUNISH.SET.PUNISH.TIME
#### PUNISH.GET.PUNISH.TIME
```lsl
PUNISH.SET.PUNISH.TIME | 5 | 10
PUNISH.GET.PUNISH.TIME
// 回调：
PUNISH.EXEC | PUNISH.SET.PUNISH.TIME | 5 | 10
PUNISH.EXEC | PUNISH.GET.PUNISH.TIME | 5 | 10
```

### 设置/获取惩罚RLV限制
#### PUNISH.SET.PUNISH.RLV
#### PUNISH.GET.PUNISH.RLV
```lsl
PUNISH.SET.PUNISH.RLV | rlv1, rlv2, ...
PUNISH.GET.PUNISH.RLV
// 回调：
PUNISH.EXEC | PUNISH.SET.PUNISH.RLV | rlv1, rlv2, ...
PUNISH.EXEC | PUNISH.GET.PUNISH.RLV | rlv1, rlv2, ...
```

### 设置/获取禁用词
#### PUNISH.SET.PUNISH.BANNED
#### PUNISH.GET.PUNISH.BANNED
```lsl
PUNISH.SET.PUNISH.BANNED | word1, word2, ...
PUNISH.GET.PUNISH.BANNED
// 回调：
PUNISH.EXEC | PUNISH.SET.PUNISH.BANNED | word1, word2, ...
PUNISH.EXEC | PUNISH.GET.PUNISH.BANNED | word1, word2, ...
```

### 设置/获取必说词
#### PUNISH.SET.PUNISH.NEEDED
#### PUNISH.GET.PUNISH.NEEDED
```lsl
PUNISH.SET.PUNISH.NEEDED | word1, word2, ...
PUNISH.GET.PUNISH.NEEDED
// 回调：
PUNISH.EXEC | PUNISH.SET.PUNISH.NEEDED | word1, word2, ...
PUNISH.EXEC | PUNISH.GET.PUNISH.NEEDED | word1, word2, ...
```

### 设置/获取其他人触发关键词
#### PUNISH.SET.PUNISH.OTHERS
#### PUNISH.GET.PUNISH.OTHERS
```lsl
PUNISH.SET.PUNISH.OTHERS | word1, word2, ...
PUNISH.GET.PUNISH.OTHERS
// 回调：
PUNISH.EXEC | PUNISH.SET.PUNISH.OTHERS | word1, word2, ...
PUNISH.EXEC | PUNISH.GET.PUNISH.OTHERS | word1, word2, ...
```

### 设置/获取黑屏动画列表
#### PUNISH.SET.BLACKOUT.ANIMS
#### PUNISH.GET.BLACKOUT.ANIMS
```lsl
PUNISH.SET.BLACKOUT.ANIMS | Anim1, Anim2, ...
PUNISH.GET.BLACKOUT.ANIMS
// 回调：
PUNISH.EXEC | PUNISH.SET.BLACKOUT.ANIMS | Anim1, Anim2, ...
PUNISH.EXEC | PUNISH.GET.BLACKOUT.ANIMS | Anim1, Anim2, ...
```

### 设置/获取黑屏时长范围
#### PUNISH.SET.BLACKOUT.TIME
#### PUNISH.GET.BLACKOUT.TIME
```lsl
PUNISH.SET.BLACKOUT.TIME | 30 | 60
PUNISH.GET.BLACKOUT.TIME
// 回调：
PUNISH.EXEC | PUNISH.SET.BLACKOUT.TIME | 30 | 60
PUNISH.EXEC | PUNISH.GET.BLACKOUT.TIME | 30 | 60
```

### 设置/获取黑屏RLV限制
#### PUNISH.SET.BLACKOUT.RLV
#### PUNISH.GET.BLACKOUT.RLV
```lsl
PUNISH.SET.BLACKOUT.RLV | rlv1, rlv2, ...
PUNISH.GET.BLACKOUT.RLV
// 回调：
PUNISH.EXEC | PUNISH.SET.BLACKOUT.RLV | rlv1, rlv2, ...
PUNISH.EXEC | PUNISH.GET.BLACKOUT.RLV | rlv1, rlv2, ...
```

### 设置/获取声音列表
#### PUNISH.SET.SOUNDS
#### PUNISH.GET.SOUNDS
- 声音列表中，第一个声音是触发惩罚的声音，最后一个声音是恢复的声音，中间的是随机惩罚的声音。
```lsl
PUNISH.SET.SOUNDS | TriggerSound; PunishSound1; PunishSound2; ..., RecoverySound
PUNISH.GET.SOUNDS
// 回调：
PUNISH.EXEC | PUNISH.SET.SOUNDS | TriggerSound; PunishSound1; PunishSound2; ..., RecoverySound
PUNISH.EXEC | PUNISH.GET.SOUNDS | TriggerSound; PunishSound1; PunishSound2; ..., RecoverySound
```

### 设置/获取音量
#### PUNISH.SET.SOUNDS.VOLUME
#### PUNISH.GET.SOUNDS.VOLUME
```lsl
PUNISH.SET.SOUNDS.VOLUME | 1.0
PUNISH.GET.SOUNDS.VOLUME
// 回调：
PUNISH.EXEC | PUNISH.SET.SOUNDS.VOLUME | 1.0
PUNISH.EXEC | PUNISH.GET.SOUNDS.VOLUME | 1.0
```

### 打开惩罚菜单
#### PUNISH.MENU
- 打开惩罚菜单
```lsl
PUNISH.MENU | Parent
```

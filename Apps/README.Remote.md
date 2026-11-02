# 本地命令与遥控系统
脚本通过调用llMessageLink方法将指令传递到remote遥控脚本，即可实现相关功能。
###### 阅读本文档前，请先阅读[菜单文档](README.Menu.md)和[主控系统文档](README.Main.md)，此系统中的部分功能依赖菜单系统和文字显示系统，并且指令格式与用法与这些系统基本保持一致。

## 遥控系统指令
- 通过调用llMessageLink方法传递指令。格式：llMessageLinked(LINK_SET, 遥控指令ID, 遥控指令字符串, 用户UUID)。
- 遥控指令ID恒为90003。ID不为90003的消息将被全部忽略。
- 遥控指令字符串格式：指令标头 | 指令参数1 | 指令参数2 | 指令数据1; 指令数据2; ... | ...
- 遥控指令字符串根据不同的指令会有所变化，详见下面指令介绍。
- 为了方便阅读，下面的遥控指令和回调中的分隔符【|】、【;】、【&&】两边都添加了空格，实际执行时并不会添加此空格。
	- 虽然遥控系统能自动处理分割符两边的空格，但仍然不建议在拼接时加空格。

## 本地和频道聊天指令
- 通过本地聊天说话、指定频道（如/1）等方式，实现相关功能。

### 聊天配置格式
- 在initMain()函数中配置cmdList中的内容，即可通过聊天实现相关指令。
- cmdList为标准的LSL List格式，每一行为一条指令，最后用逗号（,）分隔，最后一行不能有逗号（,）。
- 转义字符用于将聊天内容中的信息转化为指令字符串：
	- %user%为说话者的用户UUID。
	- %param1%、%param2%……%paramN%为指令参数，N为数字，在指令中用空格分隔（如：jmcommand p1 p2 pN）。
```lsl
cmdList=[
	// 指令，功能指令ID，功能指令内容
	"menu", MAIN_MSG_NUM, "MAIN.MENU",
	"leash", LEASH_MSG_NUM, "LEASH.TO|%user%",
	"follow", LEASH_MSG_NUM, "LEASH.TO|%user%|0",
	"yank", LEASH_MSG_NUM, "LEASH.YANK|%user%",
	"unleash", LEASH_MSG_NUM, "LEASH.TO",
	"unfollow", LEASH_MSG_NUM, "LEASH.TO",
	"rlv", RLV_MSG_NUM, "RLV.APPLY|%param1%|%param2%"
];
```

### 聊天指令格式
- \<玩家用户名前两个字母（prefix）\>指令 参数1 参数2 ... 参数N
```lsl
示例1：
用户名：JMRY，指令：leash
聊天栏：jmleash
频道：/1 jmleash

示例2：
用户名：JMRY，指令：rlv Echo 1
聊天栏：jmrlv Echo 1
频道：/1 jmrlv Echo 1

```

## 遥控频道指令
- 通过llSay、llWhisper、llShout、llRegionSay、llRegionSayTo等方法将遥控指令发送到接收端频道，即可实现相关功能。
	- 使用llSay、llWhisper、llShout需要注意消息传递的距离。
- 遥控端（REMOTE_CONTROL_CHANNEL）频道为131793，接收端（REMOTE_OBJECT_CHANNEL）频道为131794。
- 遥控端、接收端指令格式与系统指令保持一致。

### 遥控端
- 发送指令到接收端（REMOTE_OBJECT_CHANNEL）频道131794。
- 接收端收到后处理，并将结果回馈到遥控端（REMOTE_CONTROL_CHANNEL）频道131793。
- 扫描指令使用llSay、llWhisper、llShout、llRegionSay等方式广播发送。
- 连接、控制等指令使用llRegionSay发送，目标UUID会在接收到道具回馈时得到。

#### 扫描可用道具
##### REMOTE.SCAN
- 遥控端发出扫描指令时，接收端如果开启了遥控功能，并有权限操作，则会回馈如下内容，否则不会有任何回应。
- 遥控端可根据回馈信息中的数据确定回馈的道具，并进行进一步处理。
```lsl
REMOTE.SCAN
// 接收端回馈：
REMOTE.REPLY
```

#### 连接道具
##### REMOTE.CONNECT
- 向指定道具发送连接指令。
```lsl
REMOTE.CONNECT
// 接收端回调：
REMOTE.CONNECTED
```

#### 打开主菜单
##### REMOTE.MENU
- 打开接收端的主菜单。
```lsl
REMOTE.MENU
// 接收端：为发送端持有者打开主菜单。
```

#### 功能控制
##### REMOTE.FEATURE
- 可发送任意指令到接收端，接收端若支持，就可以执行。
- 参数：功能指令ID；功能名；功能参数若干……
- 功能控制为单向发送，无回馈。
```lsl
REMOTE.FEATURE | 1005 | LEASH.TO | UUID
// 接收端：根据指令进行相关操作
```

#### 断开连接
##### REMOTE.DISCONNECT
- 断开指定道具的连接。
```lsl
REMOTE.DISCONNECT
// 接收端回调：
REMOTE.DISCONNECTED
```

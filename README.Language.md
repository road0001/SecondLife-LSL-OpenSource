# 语言系统文档
脚本通过调用llMessageLink方法将语言指令传递到语言脚本，即可实现相关功能。语言的执行结果（如语言数据读取、获取语言内容等）也通过触发link_message返回。
本语言系统的设计理念，旨在降低整个语言功能的使用难度，提升开发效率。由于采用触发link_message的形式广播异步结果，因此可在多脚本之间协作，也可以更好地组织代码，提升可读性与性能。
语言系统采用LinkSetData保存与管理语言数据，只需要在记事卡中写好语言数据，使用此脚本写入LinkSetData，即可在整个prim内共享。仅在语言数据发生变化时，才会重新读取语言数据。
其他脚本使用语言时，可直接复制粘贴本脚本中的相关函数，直接使用。

## 语言调用
通过调用llMessageLink方法显示菜单，格式：llMessageLinked(LINK_SET, 语言指令ID, 语言指令字符串, 用户UUID)。
语言指令ID恒为1003。ID不为1003的消息将被全部忽略。
语言指令字符串格式：指令标头 | 指令名 | 指令参数
语言指令字符串根据不同的指令会有所变化，详见下面指令介绍。

## 语言指令
- 通过调用llMessageLink方法传递指令。
- 为了方便调用，部分指令有多种别名，请在使用时保持指令一致性。如统一使用LAN或LANGUAGE。不同别名请勿混用。
- 为了方便阅读，下面的语言指令和回调中的分隔符【|】、【;】、【&&】两边都添加了空格，实际执行时并不会添加此空格。
	- 虽然语言系统能自动处理分割符两边的空格，但仍然不建议在拼接时加空格。

### 读取（更改）语言
#### LANGUAGE.CHANGE
#### LANGUAGE.LOAD
#### LAN.CHANGE
#### LAN.LOAD
- 读取指定语言记事卡并切换语言。调用后，将自动读取对应记事卡中的语言文本，并写入LinkSetData。
- 记事卡文件名为【lan_】开头的记事卡，后面字符串表示语言名。
- 如果记事卡不存在，则不会做任何事。
- 记事卡读取完毕后，会触发回调：LANGUAGE.ACTIVE。
```lsl
LANGUAGE.CHANGE | 语言名
LAN.LOAD | 语言名
// 示例：
// 记事卡文件名：lan_CN
LANGUAGE.CHANGE | CN
LAN.LOAD | EN
// 回调：
LANGUAGE.EXEC | LANGUAGE.CHANGE | CN
LANGUAGE.EXEC | LAN.LOAD | CN_NOT_FOUND
// 记事卡读取完毕后回调：
LANGUAGE.ACTIVE | CN
```

### 获取语言文本（正查）
#### LAN.GET
#### LANGUAGE.GET
- 获取指定语言KEY对应的语言文本。
- 可一次性获取多个语言文本，用【;】分隔每个KEY，回调结果也是同样的格式。
- 获取的是原始的语言文本，不会拼接变量。
- 执行后，将回调获取的语言文本结果。
- 参数为空时，回调结果为所有语言数据。
```lsl
LAN.GET | Key1; Key2; Key3
LANGUAGE.GET | Key1; Key2; Key3
LANGUAGE.GET
// 回调：
LANGUAGE.EXEC | LAN.GET | 文本1; 文本2; 文本3
LANGUAGE.EXEC | LANGUAGE.GET | 文本1; 文本2; 文本3
LANGUAGE.EXEC | LANGUAGE.GET | Key1; 文本1; Key2; 文本2; Key3; 文本3; ...
```

### 获取语言文本（拼接变量，正查）
#### LAN.GETV
#### LANGUAGE.GETV
- 获取指定语言KEY对应的语言文本。
- 可一次性获取多个语言文本，用【;】分隔每个KEY，回调结果也是同样的格式。
- 获取的是拼接变量后的文本。
- 执行后，将回调获取的语言文本结果。
```lsl
LAN.GETV | Key1; Key2; Key3
LANGUAGE.GETV | Key1; Key2; Key3
// 回调：
LANGUAGE.EXEC | LAN.GETV | 文本1; 文本2; 文本3
LANGUAGE.EXEC | LANGUAGE.GETV | 文本1; 文本2; 文本3
```

### 获取语言KEY（反查）
#### LAN.GETKEY
#### LANGUAGE.GETKEY
- 获取语言文本对应的语言KEY。
- 可一次性获取多个语言KEY，用【;】分隔每个KEY，回调结果也是同样的格式。
- 传入的语言文本必须是原始文本，不能拼接变量。
- 执行后，将回调获取的语言KEY结果。
```lsl
LAN.GETKEY | 文本1; 文本2; 文本3
LANGUAGE.GETKEY | 文本1; 文本2; 文本3
// 回调：
LANGUAGE.EXEC | LAN.GETKEY | Key1; Key2; Key3
LANGUAGE.EXEC | LANGUAGE.GETKEY | Key1; Key2; Key3
```

### 获取语言名称
#### LAN.GETNAME
#### LANGUAGE.GETNAME
- 获取当前使用的语言名称。
```lsl
LAN.GETNAME
LANGUAGE.GETNAME
// 回调：
LANGUAGE.EXEC | LAN.GETNAME | NAME
LANGUAGE.EXEC | LANGUAGE.GETNAME | NAME
```

### 输出文本内容
#### LAN.OUT.\<TYPE\>
#### LANGUAGE.OUTPUT.\<TYPE\>
- 按当前语言输出指定内容，格式与其他语言文本一致。
- 文本内容输出不执行回调。
- LAN.OUT为LANGUAGE.OUTPUT的简写。
```lsl
LAN.OUT | Your text here. // 使用llOwnerSay发送
LAN.OUT.OWNER | Your text here. // 使用llOwnerSay发送
LAN.OUT.SELF | Your text here. // 使用llOwnerSay发送
LAN.OUT.SAY | Your text here. | N // 使用llSay发送到频道N，频道可省略，默认为0
LAN.OUT.WHISPER | Your text here. | N // 使用llWhisper发送到频道N，频道可省略，默认为0
LAN.OUT.SHOUT | Your text here. | N // 使用llShout发送到频道N，频道可省略，默认为0
LAN.OUT.TO | Your text here. | N | UUID // 使用llRegionSayTo发送到指定用户的频道N，频道和用户不可省略
LAN.OUT.REGION | Your text here. | N // 使用llRegionSay发送到全sim用户的频道N，频道可省略，默认为0
```

### 显示语言菜单
#### LANGUAGE.MENU
#### LAN.MENU
- 立即显示语言菜单。
```lsl
LANGUAGE.MENU | 上级菜单名
LAN.MENU | 上级菜单名
```

## 语言回调

### 语言记事卡读取成功回调
#### LANGUAGE.ACTIVE
- 当成功读取完成记事卡时，将执行此回调。
```lsl
LANGUAGE.ACTIVE | 语言名
```

### 语言执行回调
#### LANGUAGE.EXEC
- 语言指令执行后，会向LINK_SET发送执行结果回调，其他脚本使用link_message监听并处理结果。
- 根据不同指令，回调结果有所不同。
```lsl
LANGUAGE.EXEC | 语言指令 | 处理结果
// 示例：
LANGUAGE.EXEC | LAN.GET | 语言1; 语言2; 语言3
LANGUAGE.EXEC | LAN.GETKEY | Key1; Key2; Key3
```

## 语言菜单
- 语言菜单依赖[自动化菜单系统](README.Menu.md)。
- 语言菜单可直接通过调用内置的菜单来查看、切换语言。使用时，请在您的菜单中加入名为“Language”的按钮，当用户点击此按钮时，即可调用语言菜单。
	- 当成功切换语言时，会触发LANGUAGE.ACTIVE回调，请在需要用到语言的脚本中，监听此回调并按需执行applyLanguage()。
### 调用示例
```lsl
// 调用菜单
llMessageLinked(LINK_SET, 1000, "MENU.REG.OPEN.RESET|mainMenu|This is main menu.|Button 1;Button 2;Button 3;Language");

// link_message事件
default{
	link_message(integer sender_num, integer num, string msg, key user){
		list msgList=llParseStringKeepNulls(msg, ["|"], [""]);
		if (llList2String(msgList, 0)=="LANGUAGE.ACTIVE") {
			applyLanguage();
		}
	}
}
```

## 语言文件格式
- 语言文件名为lan_开头的记事卡。
- 语言格式为【语言KEY=语言文本】这种形式，每行一条。
- 如果语言KEY或语言文本中有换行的情况，请用“\n”代替。
	- 请勿在语言文件中使用回车来换行文本，这样会导致语言格式识别错误。
- 语言KEY和语言文本均可拼接变量，变量使用%n（n表示传入变量的序号，从1开始）表示，传递时使用【原文%%;变量1;变量2;...】这种形式。%n不限制其位置，请根据语法调整。
	- 语言拼接的变量也可进行一次语言匹配。
	- 使用%bn（n表示传入变量的序号，从1开始）来显示开关符号。此时变量为0时，显示关闭符号，变量为1时显示打开符号，其他变量显示为空字符串。
- 开关符号采用【ButtonSwitch=关|开】表示，按钮将显示：【关 OFF】、【开 ON】。
- 推荐使用简短且不重复的英文短语和下划线来表示语言KEY，可令版面整洁、方便阅读并提升性能，如【BUTTON_MAIN=主按钮】、【MAIN_MENU_TEXT=这是主菜单文本】、【MY_PROFILE=我叫%1%，我%2%了，我是一名%3%。】。
### 示例
lan_CN
```lsl
ButtonSwitch=关|开
Button 1=按钮1
Switch 1=开关1
Switch 2=开关2
This is a %1%, it will be %2%.=这是%1%，它将会是%2%。
My name is %1%.\nMy age is %2%.\nMy job is %3%.=我的名字是%1%。\n我的年龄是%2%岁。我的工作是%3%。
Tom=汤姆
Programmer=程序猿
```
```lsl
传入：
Button 1
[1]Switch 1
[0]Switch 2
显示：
按钮1
开 开关1
关 开关2

传入：
This is a %1%, it will be %2%.%%;abc;def
显示：
这是abc，它将会是def。

传入：
My name is %1%.\nMy age is %2%.\nMy job is %3%.%%;Tom;26;Programmer
显示：
我的名字是汤姆。
我的年龄是26岁。
我的工作是程序猿。
```

## 扩展用法
### 批量执行菜单指令
- 可通过【&&】拼接多条菜单指令，一次性执行完毕。执行完毕后，回调也是以同样的格式合并发送。
- 更换语言无法批量执行，也无法批量回调。
```lsl
LAN.GET | Key1; Key2; Key3 && LAN.GETV | Key1; Key2; Key3
// 回调：
LANGUAGE.EXEC | LAN.GET | 文本1; 文本2; 文本3 && LANGUAGE.EXEC | LAN.GETV | 变量1; 变量2; 变量3
```
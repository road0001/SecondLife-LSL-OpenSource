# 自动化菜单系统文档
脚本通过调用llMessageLink方法将菜单指令传递到菜单脚本，即可实现相关功能。菜单的执行结果（如数据获取、菜单点击等）也通过触发link_message返回。
本菜单系统的设计理念，旨在降低菜单功能的使用难度，无须与反人类的llDialog斗智斗勇，提升开发效率。由于采用触发link_message的形式广播异步结果，因此可在多脚本之间协作，也可以更好地组织代码，提升可读性与性能。
菜单系统采用注册管理与显示分离的设计思路，菜单仅需注册一次，即可反复使用。仅在数据或状态发生变化时，才需要重新注册菜单。
菜单系统支持翻页与多语言，只需简单的配置即可使用。菜单文本支持拼接变量，变量也可以进行一次语言匹配。菜单按钮支持开关状态显示，并可自定义开关样式。
菜单文本和按钮仅用于展示，不可用于保存与判断状态。

## 菜单调用
通过调用llMessageLink方法显示菜单，格式：llMessageLinked(LINK_SET, 菜单指令ID, 菜单指令字符串, 用户UUID)。
菜单指令ID恒为1000。ID不为1000的消息将被全部忽略。
菜单指令字符串格式：指令标头 | 菜单名 | 菜单文本 | 菜单按钮1; 菜单按钮2; 菜单按钮3; ... | 上级菜单名
菜单指令字符串根据不同的指令会有所变化，详见下面指令介绍。
示例代码如下：
```lsl
integer MENU_MSG_NUM=1000;
integer isLocked=FALSE;
string owner="Test";
default{
	state_entry(){}
	touch_start(integer num_detected){
		key user=llDetectedKey(0); // 触发菜单的用户uuid
		string menuText="This is main menu.\nLocked: %1%\nOwner: %2%%%;"+(string)isLocked+";"+owner; // 菜单文本，使用\n换行，不得超过512字节。
		// 菜单按钮列表，按照正常顺序排序，每页显示9个，超出后可换行
		list mainMenu=[
			"["+(string)isLocked+"]Lock",
			"RLV",
			"Access",
			"Settings",
			"Language"
		];
		// 生成菜单注册和显示指令，此处将菜单按钮列表用分号【;】整合成字符串
		list menuLink=[
			"MENU.REG.OPEN.RESET",
			"mainMenu",
			menuText,
			llDumpList2String(mainMenu,";")
		];
		// 发送菜单注册显示的指令
		llMessageLinked(LINK_SET, MENU_MSG_NUM, llDumpList2String(menuLink,"|"), user);
	}
	link_message(integer sender_num, integer num, string str, key id){
		// 接收菜单的触发信息
		llRegionSayTo(id, 0, "LINK_MESSAGE: " + str);
		llRegionSayTo(id, 0, "OPERATER: " + (string)id);
	}
}
```

## 菜单指令
- 通过调用llMessageLink方法传递指令。
- 为了方便调用，部分指令有多种别名，请在使用时保持指令一致性。如统一使用REG、REM或REGIST、REMOVE。不同别名请勿混用。
- 为了方便阅读，下面的菜单指令和回调中的分隔符【|】、【;】、【&&】两边都添加了空格，实际执行时并不会添加此空格。
	- 虽然菜单系统能自动处理分割符两边的空格，但仍然不建议在拼接时加空格。
	- 建议使用拼接list的形式调用（llDumpList2String），而不是字符串拼接的方式，这样有助于代码的简洁和更好的性能。
	- ```lsl
		list subMenu=[
			"Lock",
			"RLV",
			"Access",
			"Settings",
			"Language"
		];
		list menuLink=[
			"MENU.REG.OPEN.RESET", // 注册菜单并打开，重置页数为1
			"subMenu", // 菜单名
			"This is sub menu.", // 菜单文本
			llDumpList2String(subMenu, ";"), // 菜单按钮（将subMenu进行拼合）
			"mainMenu" // 上级菜单（可选）
		];
		llMessageLinked(LINK_SET, 1000, llDumpList2String(menuLink, "|"), user); // 将上述list用“|”拼接为字符串并发送。
		// 将发送以下字符串：
		MENU.REG.OPEN.RESET|subMenu|This is main menu.|Lock;RLV;Access;Settings;Language|mainMenu
		// 菜单打开后，将执行如下回调：
		MENU.EXEC|MENU.REG.OPEN.RESET|1
		// 当点击菜单按钮（如Lock）后，将执行如下回调：
		MENU.ACTIVE|subMenu|Lock
		// 通过link_message监听并处理：
		link_message(integer sender_num, integer num, string str, key id){
			llRegionSayTo(id, 0, "LINK_MESSAGE: " + str);
			llRegionSayTo(id, 0, "OPERATER: " + (string)id);
		}
	```

### 注册菜单
#### MENU.REG
#### MENU.REGIST
- 将菜单注册到系统中以便后续调用。当菜单按钮数量超过9个时，会自动产生分页。
- 菜单名必须唯一，如果要注册的菜单名已存在，将覆盖现有的菜单数据。
- 菜单文本可拼接变量，格式：【This is a menu, var1: %1%, var2: %2%.%%;var1;var2】。%数字与%%;后面变量的位置一一对应，从1开始。
- 菜单按钮可拼接开关，格式：【[0]OFF】、【[1]ON】，按钮将显示：【◇ OFF】、【◆ ON】。
	- 可在语言文本中自定义开关样式，格式：【ButtonSwitch=关|开】，按钮将显示：【关 OFF】、【开 ON】。
- 如果没有上级菜单，菜单最下方将显示关闭按钮，点击即可关闭菜单并销毁监听。
- 如果有上级菜单，菜单最下方将显示返回按钮，点击即可返回上级菜单（必须是已注册的菜单）。
- 执行后，回调结果为TRUE。
```lsl
MENU.REGIST | 菜单名 | 菜单文本 | 菜单按钮1; 菜单按钮2; ... | 上级菜单（可选）
MENU.REG | 菜单名 | 菜单文本 | 菜单按钮1; 菜单按钮2; ... | 上级菜单（可选）
// 示例：
MENU.REGIST | mainMenu | Main menu desc | Button 1; Button 2; Button 3
MENU.REG | subMenu | Sub menu desc | Button 1; Button 2; Button 3 | mainMenu
// 回调：
MENU.EXEC | MENU.REG | 1
MENU.EXEC | MENU.REGIST | 0
```

### 注册并显示菜单
#### MENU.REG.OPEN
#### MENU.REG.OPEN.N
#### MENU.REG.OPEN.RESET
- 注册并显示菜单，格式和上面相同，注册后将自动显示刚刚注册的菜单。
- 指令第4位表示将要显示的菜单页面，如果为空，将显示上次停留的页面；如果为RESET，则显示第1页。
- 默认在点击按钮后，不会重新显示菜单，因此在需要重新显示菜单的场合，需要主动调用MENU.OPEN | 菜单名。如果需要更新菜单，也可以使用MENU.REG.OPEN，在重新注册后立即打开菜单。
- 执行后，回调结果为TRUE。
```lsl
MENU.REG.OPEN | subMenu | Sub menu desc | Button 1; Button 2; Button 3 | mainMenu
MENU.REG.OPEN.2 | subMenu | Sub menu desc | Button 1; Button 2; Button 3 | mainMenu
MENU.REG.OPEN.RESET | subMenu | Sub menu desc | Button 1; Button 2; Button 3 | mainMenu
// 回调：
MENU.EXEC | MENU.REG.OPEN | 1
MENU.EXEC | MENU.REG.OPEN.2 | 1
MENU.EXEC | MENU.REG.OPEN.RESET | 1
```

### 显示菜单
#### MENU.OPEN
#### MENU.OPEN.N
#### MENU.OPEN.RESET
- 立即显示已注册的菜单。
- 指令第3位表示将要显示的菜单页面，如果为空，将显示上次停留的页面；如果为RESET，则显示第1页。
- 默认在点击按钮后，不会重新显示菜单，因此在需要重新显示菜单的场合，需要主动调用MENU.OPEN | 菜单名。如果需要更新菜单，也可以使用MENU.REG.OPEN，在重新注册后立即打开菜单。
- 执行后，如果菜单已注册，则回调结果为TRUE。如果没有注册菜单，则回调结果为FALSE。
```lsl
MENU.OPEN
MENU.OPEN | 菜单名
MENU.OPEN.2 | 菜单名
MENU.OPEN.RESET | 菜单名
// 示例：
MENU.OPEN
MENU.OPEN | mainMenu
MENU.OPEN.2 | mainMenu
MENU.OPEN.RESET | subMenu
// 回调：
MENU.EXEC | MENU.OPEN | 1
MENU.EXEC | MENU.OPEN | 0
MENU.EXEC | MENU.OPEN.2 | 1
MENU.EXEC | MENU.OPEN.RESET | 0
```

### 简易菜单
#### MENU.CONFIRM
- 用于提示、确认事项等对话框的显示。
- 菜单按钮字段可留空，留空默认显示一个OK按钮。
```lsl
MENU.CONFIRM | 菜单名 | 菜单文本
MENU.CONFIRM | 菜单名 | 菜单文本 | 菜单按钮1; 菜单按钮2; ...
MENU.CONFIRM | 菜单名 | 菜单文本 | 菜单按钮1; 菜单按钮2; ... | 上级菜单（可选）
// 示例：
MENU.CONFIRM | confirmMenu | Are you confirm desc %1% %2% %%;val1;val2
MENU.CONFIRM | confirmMenu | Are you confirm desc %1% %2% %%;val1;val2 | OK; Wait; Cancel
MENU.CONFIRM | confirmMenu | Are you confirm desc %1% %2% %%;val1;val2 | OK; Wait; Cancel | mainMenu
// 回调：
MENU.EXEC | MENU.CONFIRM | 1
```

### 输入框
#### MENU.INPUT
- 显示输入框让用户输入内容。
```lsl
MENU.INPUT | 菜单名 | 菜单文本
// 示例：
MENU.INPUT | inputMenu | Please input something %1% %2% %%;val1;val2
// 回调：
MENU.EXEC | MENU.INPUT | 1
```

### 移除菜单
#### MENU.REM
#### MENU.REMOVE
- 移除已注册的菜单。及时移除不需要的菜单是节约有限内存的好习惯。
- 执行后，如果菜单已注册，则回调结果为TRUE。如果没有注册菜单，则回调结果为FALSE。
```lsl
MENU.REM | 菜单名
MENU.REMOVE | 菜单名
// 示例：
MENU.REM | subMenu
MENU.REMOVE | subMenu
// 回调：
MENU.EXEC | MENU.REM | 1
MENU.EXEC | MENU.REMOVE | 0
```

### 清空菜单
#### MENU.CLEAR
- 清空所有已注册的菜单。及时移除不需要的菜单是节约有限内存的好习惯，清空所有菜单也是如此。
- 执行后，回调结果为TRUE。
```lsl
MENU.CLEAR
// 回调：
MENU.EXEC | MENU.CLEAR | 1
```

## 菜单回调

### 菜单激活回调
#### MENU.ACTIVE
- 当点击菜单按钮或确认输入内容时，菜单系统监听随机负数端口获得按钮或输入文本，如果是按钮，则将其进行语言文本反查获得原始KEY，并向LINK_SET发送菜单名、按钮KEY和操作者的uuid。其他脚本使用link_message监听并处理结果。
- 对于有开关状态的按钮，回调时会自动将其去除，因此不能使用按钮名保存和判断开关状态。
- 对于输入文本，将进行trim处理后回调。
- 如果超过1分钟没有进行任何操作，菜单系统将超时并销毁菜单监听器。
```lsl
MENU.ACTIVE | 菜单名 | 按钮KEY
// 示例：
MENU.ACTIVE | mainMenu | Button1
// 监听示例：
link_message(integer sender_num, integer num, string str, key id){
	list menuActive=llParseString2List(str, ["|"], [""]);
	string menuCmd=llList2String(menuActive, 0);
	if(menuCmd=="MENU.ACTIVE"){
		string menuName=llList2String(menuActive, 1);
		string buttonName=llList2String(menuActive, 2);
		llRegionSayTo(id, 0, "Menu Name: " + menuName + " Button Name: " + buttonName);
		llRegionSayTo(id, 0, "OPERATER: "+(string)id);
	}
}
```

### 菜单执行回调
#### MENU.EXEC
- 菜单指令执行后，会向LINK_SET发送执行结果回调，其他脚本使用link_message监听并处理结果。
- 根据不同指令，回调结果有所不同。
```lsl
MENU.EXEC | 菜单指令 | 处理结果
// 示例：
MENU.EXEC | MENU.REG.OPEN | 1
MENU.EXEC | MENU.OPEN | 1
MENU.EXEC | MENU.REM | 1
MENU.EXEC | MENU.LAN.GET | 语言1; 语言2; 语言3
MENU.EXEC | MENU.LAN.GETKEY | Key1; Key2; Key3
```

## 扩展用法
### 批量执行菜单指令
- 可通过【&&】拼接多条菜单指令，一次性执行完毕。执行完毕后，回调也是以同样的格式合并发送。
- 菜单激活无法批量执行，也无法批量回调。
```lsl
MENU.REG | subMenu | Sub menu desc | Button 1; Button 2; Button 3 | mainMenu && MENU.OPEN | subMenu
// 回调：
MENU.EXEC | MENU.REG | 1 && MENU.EXEC | MENU.OPEN | 1
```
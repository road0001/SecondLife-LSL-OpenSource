# 自动化RLV系统文档
脚本通过调用llMessageLink方法将RLV指令传递到RLV脚本，即可实现相关功能。RLV的执行结果（如数据获取、RLV执行结果等）也通过触发link_message返回。
###### 阅读本文档前，请先阅读[菜单文档](README.Menu.md)，此RLV系统中的部分功能依赖菜单系统，并且指令格式与用法与菜单系统基本保持一致。

## RLV功能指令
- 通过调用llMessageLink方法传递指令。格式：llMessageLinked(LINK_SET, RLV指令ID, RLV指令字符串, 用户UUID)。
- RLV指令ID恒为1001。ID不为1001的消息将被全部忽略。
- RLV指令字符串格式：指令标头 | 指令参数1 | 指令参数2 | 指令数据1, 指令数据2, ... | ...
- RLV指令字符串根据不同的指令会有所变化，详见下面指令介绍。
- 为了方便调用，部分指令有多种别名，请在使用时保持指令一致性。如统一使用REG、REM或REGIST、REMOVE。不同别名请勿混用。
- 为了方便阅读，下面的RLV指令和回调中的分隔符【|】、【,】、【&&】两边都添加了空格，实际执行时并不会添加此空格。
	- 在菜单系统、权限系统等功能中，分隔数据使用分号【;】，但RLV指令中存在使用分号的情况，因此将分号改为逗号【,】，与RLV批量执行的分隔符保持一致。
	- 虽然RLV系统能自动处理分割符两边的空格，但仍然不建议在拼接时加空格。

### 注册RLV类别
#### RLV.REG.CLASS
#### RLV.REGIST.CLASS
- 将RLV类别注册到RLV系统中，以便在RLV菜单中展示分类。
- RLV类别名唯一，如果在列表中已存在同名的类别名，将不会产生任何效果。
- 执行后，如果添加成功，则回调结果为TRUE。如果类别名已存在，则回调结果为FALSE。
```lsl
RLV.REGIST.CLASS | 类别名1, 类别名2, 类别名3, ...
RLV.REG.CLASS | 类别名1, 类别名2, 类别名3, ...
// 示例：
RLV.REGIST.CLASS | RLVClass1, RLVClass2, RLVClass3
RLV.REG.CLASS | RLVClass1, RLVClass2, RLVClass3
// 回调：
RLV.EXEC | RLV.REGIST.CLASS | 1
RLV.EXEC | RLV.REG.CLASS | 0
```

### 移除RLV类别
#### RLV.REM.CLASS
#### RLV.REMOVE.CLASS
- 移除已注册的RLV类别。及时移除不需要的类别是节约有限内存的好习惯。
- 执行后，如果RLV类别已注册，则回调结果为TRUE。如果没有注册此RLV类别，则回调结果为FALSE。
```lsl
RLV.REM | 类别名
RLV.REMOVE | 类别名
// 示例：
RLV.REM | Vision
RLV.REMOVE | Vision
// 回调：
RLV.EXEC | RLV.REM | 1
RLV.EXEC | RLV.REMOVE | 0
```

### 获取RLV类别Index
#### RLV.GET.CLASS
- 获取RLV类别的索引。如果不存在此RLV类别，则返回-1。
```lsl
RLV.GET.CLASS | 类别名
// 示例：
RLV.GET.CLASS | ClassName
// 回调：
RLV.EXEC | RLV.GET.CLASS | 2
```

### 清空RLV类别
#### RLV.CLEAR.CLASS
- 清空所有RLV类别。
```lsl
RLV.CLEAR.CLASS
// 回调：
RLV.EXEC | RLV.CLEAR.CLASS | 1
```

### 注册RLV组
#### RLV.REG
#### RLV.REGIST
- 将一组RLV限制注册到RLV系统中，以便在RLV菜单中展示并一键应用所有限制。
- RLV组名称唯一，如果在列表中已存在同名的RLV组，则会覆盖此RLV组中的所有限制。
- 如果传入字段中包含RLV类别，则会自动创建同名RLV类别。如果没有此字段，则此RLV组将无法显示在菜单中（多用于临时调用或隐藏式调用）。
- RLV限制可自定义生效/不生效/扩展值，格式：【RLV指令 ? 生效值 ? 不生效值 ? 扩展值1 ? 扩展值2 ...】。
- 执行后，回调结果为TRUE。
```lsl
RLV.REG | RLV组名 | RLV限制1 ? 生效值 ? 失效值 ? 扩展值, RLV限制2, RLV限制3, ...
RLV.REGIST | RLV组名 | RLV限制1, RLV限制2, RLV限制3, ... | RLV类别名
// 示例（为了便于阅读，在分隔符中间加了空格，实际使用时不应加此空格）：
RLV.REG | RLVName | RLV1 ? n ? y, RLV2 ? add ?rem, RLV3 ? force ? rem ? ext, ...
RLV.REGIST | RLVName | RLV1, RLV2, RLV3, ... | Class 1
// 回调：
RLV.EXEC | RLV.REG | 1
RLV.EXEC | RLV.REGIST | 1
```

### 注册RLV组并应用
#### RLV.REG.APPLY
#### RLV.REGIST.APPLY
- 注册RLV组的同时立即应用。
- 格式与上面相同。
- RLV限制开关分别为-1（切换当前状态）、0（不生效）、1（生效）。
- 执行后，回调结果为RLV组中所有限制的应用状态（0、1）。
```lsl
RLV.REG.APPLY | RLV组名 | RLV限制1, RLV限制2, RLV限制3, ... | RLV限制开关
RLV.REGIST.APPLY | RLV组名 | RLV限制1, RLV限制2, RLV限制3, ... | RLV限制开关 | RLV类别名
// 示例：
RLV.REG.APPLY | RLVName | RLV1, RLV2, RLV3, ... | -1
RLV.REGIST.APPLY | RLVName | RLV1, RLV2, RLV3, ... | 1 | Class 1
// 回调：
RLV.EXEC | RLV.REG.APPLY | 0
RLV.EXEC | RLV.REGIST.APPLY | 1
```

### 应用已注册的RLV组
#### RLV.APPLY
- 立即应用已注册的RLV组。
- RLV限制开关分别为-1（切换当前状态）、0（不生效）、1（生效）。
- 执行后，回调结果为RLV组中所有限制的应用状态（0、1）。
```lsl
RLV.APPLY | RLV组名 | RLV限制开关
// 示例：
RLV.APPLY | RLVName | -1
RLV.APPLY | RLVName | 1
RLV.APPLY | RLVName | 0
// 回调：
RLV.EXEC | RLV.APPLY | 0
RLV.EXEC | RLV.APPLY | 1
RLV.EXEC | RLV.APPLY | 0
```

### 移除已注册的RLV组
#### RLV.REM
#### RLV.REMOVE
- 移除已注册的RLV组。
- 执行后，如果RLV组已注册，则回调结果为TRUE。如果没有注册此RLV组，则回调结果为FALSE。
```lsl
RLV.REM | RLV组名
RLV.REMOVE | RLV组名
// 示例：
RLV.REM | RLVName
RLV.REMOVE | RLVName
// 回调：
RLV.EXEC | RLV.REM | 1
RLV.EXEC | RLV.REMOVE | 0
```

### 清空RLV组
#### RLV.CLEAR
- 清空所有RLV组。
```lsl
RLV.CLEAR
// 回调：
RLV.EXEC | RLV.CLEAR | 1
```

### 获取RLV组中的RLV指令
#### RLV.GET
- 获取已注册的RLV组中所有的RLV限制。
```lsl
RLV.GET | RLV组名
// 示例：
RLV.GET | RLVName
// 回调：
RLV.EXEC | RLV.GET | RLV1, RLV2, RLV3
```

### 直接执行RLV指令
#### RLV.RUN
- 直接执行@开头的RLV指令，可以不加@，用逗号分隔多条指令，如@detach=n,fly=n,unsit=n。
- 不带参数时，一键执行当前存在的所有限制。
```lsl
RLV.RUN
RLV.RUN | RLV1, RLV2, RLV3, ...
// 回调：
RLV.EXEC | RLV.RUN | 1
```

### 获取RLV状态
#### RLV.GET.STATUS
- 获取RLV组或RLV的生效状态。
- 可传递多个RLV组或RLV指令。
```lsl
RLV.GET.STATUS | RLVName1, RLVName2, RLVName3
RLV.GET.STATUS | @RLV1, @RLV2, @RLV3
// 回调：
RLV.EXEC | RLV.GET.STATUS | 1, 1, 0 // RLV组中所有限制都为n或add时，返回1，否则返回0；多个组名批量返回
RLV.EXEC | RLV.GET.STATUS | 0, 0, 1 // 返回RLV指令的状态，多条指令批量返回
```

### 锁定/解锁
#### RLV.LOCK
- 物品穿在身上时，将发送@detach=n来将物品锁在身上。
- 物品放置在地上时，将发送@unsit=n来阻止玩家站立。
- 锁定参数分别为-1（切换当前状态）、0（不生效）、1（生效）。
- 执行后，回调结果为锁定执行后的状态（0、1）和操作用户。
```lsl
RLV.LOCK | -1
RLV.LOCK | 1
RLV.LOCK | 0
// 回调：
RLV.EXEC | RLV.LOCK | 1;UUID
RLV.EXEC | RLV.LOCK | 1;UUID
RLV.EXEC | RLV.LOCK | 0;UUID
```

### 获取锁定状态
#### RLV.GET.LOCK
- 获取当前锁定的状态（0、1）和操作用户。
```lsl
RLV.GET.LOCK
// 回调：
RLV.EXEC | RLV.GET.LOCK | 1;UUID
```

### 获取重命名器状态
#### RLV.GET.RENAMER
- 获取当前重命名器的状态（名字、频道、开关）。
```lsl
RLV.GET.RENAMER
// 回调：
RLV.EXEC | RLV.GET.RENAMER | 名字; 频道; 1
```

### 重命名器
#### RLV.RENAMER
- 开启/关闭/设定重命名器。
- 参数为SET时，将更改为指定名字。改名后，重命名器立即生效。
- 参数为-1（切换当前状态）、0（不生效）、1（生效）。
- 执行后，回调结果为重命名器执行后的名字和状态（0、1）。
```lsl
RLV.RENAMER | SET | 名字
RLV.RENAMER | -1
RLV.RENAMER | 0
RLV.RENAMER | 1
// 回调：
RLV.EXEC | RLV.RENAMER | 名字; 频道; 1
RLV.EXEC | RLV.RENAMER | 名字; 频道; 0
RLV.EXEC | RLV.RENAMER | 名字; 频道; 0
RLV.EXEC | RLV.RENAMER | 名字; 频道; 1
```

### 捕获玩家
#### RLV.CAPTURE
- 仅当物品放在地上时生效。
- 捕获指定UUID的玩家。
- 执行后，回调结果为捕获结果（0、1）。
  - 请先行指定Sit Target，否则RLV将无法正常工作。
  - 例如：llSitTarget(<0.0, 0.0, 0.1>, ZERO_ROTATION);
```lsl
RLV.CAPTURE | UUID
// 回调：
RLV.EXEC | RLV.CAPTURE | 1
```

### 获取捕获状态
#### RLV.GET.CAPTURE
- 获取指定UUID的玩家的捕获状态。
- 执行后，回调结果为捕获结果（0、1）。
```lsl
RLV.GET.CAPTURE | UUID
// 回调：
RLV.EXEC | RLV.GET.CAPTURE | 1
```

### 获取已捕获玩家的UUID
#### RLV.GET.CAPTUREID
- 获取被捕获玩家的UUID。
- 执行后，回调结果为玩家的UUID。如果没有玩家被捕获，则返回NULL_KEY。
```lsl
RLV.GET.CAPTUREID
// 回调：
RLV.EXEC | RLV.GET.CAPTUREID | UUID
RLV.EXEC | RLV.GET.CAPTUREID | 00000000-0000-0000-0000-000000000000
```

### 获取RLV锁定和限制联动状态
#### RLV.GET.CONNECT
- 获取RLV锁定和限制联动状态。
- 执行后，回调结果为联动状态。
```lsl
RLV.GET.CONNECT
// 回调：
RLV.EXEC | RLV.GET.CONNECT | 1
```

### 读取RLV记事卡列表
#### RLV.LOAD.LIST
- 读取库存中rlv_开头的记事卡列表。
```lsl
RLV.LOAD.LIST
// 回调：
RLV.EXEC | RLV.LOAD.LIST | rlv_rlv1, rlv_rlv2, rlv_rlv3, ...
```

### 读取RLV记事卡
#### RLV.LOAD
- 从rlv_开头的记事卡中获取RLV限制数据。
  - 名字中不需要带rlv_前缀，如记事卡为rlv_main，则只需传递main。
- 执行后，将清空并覆盖现有的RLV数据。
```lsl
RLV.LOAD | file1
// 回调：
RLV.EXEC | RLV.LOAD | 1
// 读取记事卡成功后的回调
RLV.LOAD.NOTECARD | 1
```

### RLV锁定和限制联动
#### RLV.SET.CONNECT
- 启用/禁用RLV锁定和限制联动，上锁时立即应用RLV限制，解锁时清除。
```lsl
RLV.SET.CONNECT
// 回调：
RLV.EXEC | RLV.SET.CONNECT | 1
```

### 显示RLV菜单
#### RLV.MENU
- 立即显示RLV菜单。
```lsl
RLV.MENU | 上级菜单名
```

## RLV回调
- 当执行RLV指令时，将回调执行结果。根据不同情况，结果的格式也有所不同。
```lsl
RLV.EXEC | RLV.REG.CLASS | 1
RLV.EXEC | RLV.APPLY | 0
RLV.EXEC | RLV.LOAD | 0
```

## RLV扩展指令
- 此脚本带有一些非RLV的扩展指令，旨在扩展其功能和用途。扩展指令不是RLV指令，但采用和RLV指令相同的格式，以便更加方便地进行处理。RLV扩展指令以@rext_开头，以便区分常规RLV指令。扩展指令开关统一写成n、y。

### 允许/禁止移动：@rext_move=\<y/n\>
- 当指令开关为n时，禁止移动，否则允许移动。

## 扩展用法
### 批量执行RLV指令
- 可通过【&&】拼接多条RLV指令，一次性执行完毕。执行完毕后，回调也是以同样的格式合并发送。
```lsl
RLV.REG.CLASS | RLVClass1, RLVClass2, RLVClass3 && RLV.REG | RLVName | RLV1, RLV2, RLV3 &&  RLV.APPLY | RLVName | 1
// 回调：
RLV.EXEC | RLV.REG.CLASS | 1 && RLV.EXEC | RLV.REG | 1 && RLV.EXEC | RLV.APPLY | 1
```

## RLV配置文件格式和RLV组指令格式
- RLV配置文件名为rlv_开头的记事卡。
- RLV配置文件格式为【RLV组=RLV1,RLV2,RLV3】这种形式，每行一条。
- 可用\[RLV类别\]来设定RLV类别。
- RLV组前加*号可使RLV在初始化后自动执行该组内所有RLV限制。
- RLV指令集可自定义生效/不生效/扩展值，格式：【RLV指令?生效值?不生效值?扩展值1?扩展值2...】。
- 未注册的RLV类别将自动注册。同名的RLV类别中的RLV限制组将被归类到同一菜单中。同名RLV组将会被后面的RLV限制覆盖。
### 示例
rlv_normal
```lsl
[Basics]
Run=alwaysrun?n?y,temprun
Fly=fly
[Touch]
*Far=fartouch?n?y
*World=touchworld
Me=touchme?add?rem
[Stand]
Unsit=unsit?force
```




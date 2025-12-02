# 自动化权限系统文档
脚本通过调用llMessageLink方法将权限指令传递到权限脚本，即可实现相关功能。权限的执行结果（如数据获取、执行结果等）也通过触发link_message返回。
###### 阅读本文档前，请先阅读[菜单文档](README.Menu.md)，此权限系统中的部分功能依赖菜单系统，并且指令格式与用法与菜单系统基本保持一致。

## 权限功能指令
- 通过调用llMessageLink方法传递指令。格式：llMessageLinked(LINK_SET, 权限指令ID, 权限指令字符串, 用户UUID)。
- 权限指令ID恒为1002。ID不为1002的消息将被全部忽略。
- 权限指令字符串格式：指令标头 | 指令参数1 | 指令参数2 | 指令数据1; 指令数据2; ... | ...
- 权限指令字符串根据不同的指令会有所变化，详见下面指令介绍。
- 为了方便调用，部分指令有多种别名，请在使用时保持指令一致性。如统一使用REM或REMOVE。不同别名请勿混用。
- 为了方便阅读，下面的权限指令和回调中的分隔符【|】、【;】、【&&】两边都添加了空格，实际执行时并不会添加此空格。
	- 虽然权限系统能自动处理分割符两边的空格，但仍然不建议在拼接时加空格。

### 设置根权限用户
#### ACCESS.SET.ROOT
- 将指定用户设置为根权限用户。
- 根权限用户初始为穿戴者自己，拥有最高级权限，在权限列表中恒为第0位。
- 根权限用户只能设置，不能移除。
- 执行后，回调结果为TRUE。
```lsl
ACCESS.SET.ROOT | UUID
// 示例：
ACCESS.SET.ROOT | 00000000-0000-0000-0000-000000000000
// 回调：
ACCESS.EXEC | ACCESS.SET.ROOT | 1
```

### 添加主人
#### ACCESS.ADD.OWNER
- 将指定用户添加为主人。
- 主人拥有的权限仅次于根权限用户。
- 主人只能查看和管理自己，不能查看或管理其他主人。
- 添加主人时，会自动从信任列表和黑名单中移除该用户。
- 执行后，如果添加成功，则回调结果为TRUE。如果主人已存在于列表中，则回调结果为FALSE。
```lsl
ACCESS.ADD.OWNER | UUID
// 示例：
ACCESS.ADD.OWNER | 00000000-0000-0000-0000-000000000000
ACCESS.ADD.OWNER | 00000000-0000-0000-0000-000000000000
// 回调：
ACCESS.EXEC | ACCESS.ADD.OWNER | 1
ACCESS.EXEC | ACCESS.ADD.OWNER | 0
```

### 删除主人
#### ACCESS.REM.OWNER
#### ACCESS.REMOVE.OWNER
- 将指定用户从主人列表中删除。
- 执行后，如果删除成功，则回调结果为TRUE。如果主人不存在于列表中，则回调结果为FALSE。
```lsl
ACCESS.REM.OWNER | UUID
ACCESS.REMOVE.OWNER | UUID
// 示例：
ACCESS.REM.OWNER | 00000000-0000-0000-0000-000000000000
ACCESS.REMOVE.OWNER | 00000000-0000-0000-0000-000000000000
// 回调：
ACCESS.EXEC | ACCESS.REM.OWNER | 1
ACCESS.EXEC | ACCESS.REMOVE.OWNER | 0
```

### 添加信任用户
#### ACCESS.ADD.TRUST
- 将指定用户添加为信任列表。
- 信任用户拥有的权限仅次于主人。
- 信任用户不能查看或管理权限列表。
- 用户已在主人列表时，将不会添加信任。
- 添加信任时，会自动从黑名单中移除该用户。
- 执行后，如果添加成功，则回调结果为TRUE。用户已在主人列表或信任列表时，则回调结果为FALSE。
```lsl
ACCESS.ADD.TRUST | UUID
// 示例：
ACCESS.ADD.TRUST | 00000000-0000-0000-0000-000000000000
ACCESS.ADD.TRUST | 00000000-0000-0000-0000-000000000000
// 回调：
ACCESS.EXEC | ACCESS.ADD.TRUST | 1
ACCESS.EXEC | ACCESS.ADD.TRUST | 0
```

### 删除信任用户
#### ACCESS.REM.TRUST
#### ACCESS.REMOVE.TRUST
- 将指定用户从信任列表删除。
- 执行后，如果删除成功，则回调结果为TRUE。用户不在信任列表时，则回调结果为FALSE。
```lsl
ACCESS.REM.TRUST | UUID
ACCESS.REMOVE.TRUST | UUID
// 示例：
ACCESS.REM.TRUST | 00000000-0000-0000-0000-000000000000
ACCESS.REMOVE.TRUST | 00000000-0000-0000-0000-000000000000
// 回调：
ACCESS.EXEC | ACCESS.REM.TRUST | 1
ACCESS.EXEC | ACCESS.REMOVE.TRUST | 0
```

### 添加黑名单用户
#### ACCESS.ADD.BLACK
- 将指定用户添加为黑名单。
- 黑名单用户拥有的权限最低。
- 用户已在主人列表或信任列表时，添加为黑名单将会自动从相应列表中移除他们。
- 根权限用户可被添加入黑名单，但不会产生任何作用（除非将根权限收回）。
- 执行后，如果添加成功，则回调结果为TRUE。用户已在黑名单时，则回调结果为FALSE。
```lsl
ACCESS.ADD.BLACK | UUID
// 示例：
ACCESS.ADD.BLACK | 00000000-0000-0000-0000-000000000000
ACCESS.ADD.BLACK | 00000000-0000-0000-0000-000000000000
// 回调：
ACCESS.EXEC | ACCESS.ADD.BLACK | 1
ACCESS.EXEC | ACCESS.ADD.BLACK | 0
```

### 删除黑名单用户
#### ACCESS.REM.BLACK
#### ACCESS.REMOVE.BLACK
- 将指定用户从黑名单删除。
- 执行后，如果删除成功，则回调结果为TRUE。用户不在黑名单时，则回调结果为FALSE。
```lsl
ACCESS.REM.BLACK | UUID
ACCESS.REMOVE.BLACK | UUID
// 示例：
ACCESS.REM.BLACK | 00000000-0000-0000-0000-000000000000
ACCESS.REMOVE.BLACK | 00000000-0000-0000-0000-000000000000
// 回调：
ACCESS.EXEC | ACCESS.REM.BLACK | 1
ACCESS.EXEC | ACCESS.REMOVE.BLACK | 0
```

### 获取当前/指定用户授权状态
#### ACCESS.GET
#### ACCESS.GET | UUID
- 不带UUID时，获取当前用户（触摸或使用者）的授权状态。
- 带UUID时，获取指定用户的授权状态。
- 执行后，将回调当前用户的授权状态码。
	- 0=ROOT
	- 1~n=主人index
	- -1000=群组
	- -2000=公开
	- -3000=信任
	- -4000=黑名单
	- -1=无权限
```lsl
ACCESS.GET
ACCESS.GET | UUID
// 回调：
ACCESS.EXEC | ACCESS.GET | -1000
ACCESS.EXEC | ACCESS.GET | -1
```

### 获取主人/信任/黑名单列表
#### ACCESS.GET.OWNER
#### ACCESS.GET.TRUST
#### ACCESS.GET.BLACK
- 获取主人/信任/黑名单列表。
- 执行后，将回调指定的列表。
```lsl
ACCESS.GET.OWNER
ACCESS.GET.TRUST
ACCESS.GET.BLACK
// 回调：
ACCESS.EXEC | ACCESS.GET.OWNER | UUID1; UUID2; UUID3; ...
ACCESS.EXEC | ACCESS.GET.TRUST | UUID1; UUID2; UUID3; ...
ACCESS.EXEC | ACCESS.GET.BLACK | UUID1; UUID2; UUID3; ...
```

### 获取公开/群组/硬核模式
#### ACCESS.GET.MODE
- 获取公开/群组/硬核模式的状态。
- 1为启用，0为禁用。
- 公开模式允许非授权用户访问。
- 群组模式允许相同群组的用户访问。
- 硬核模式禁用逃跑功能。
- 执行后，将回调当前设置的结果。
	- 如果不指定参数，则按顺序回调公开、群组、硬核模式的状态。
	- 如果指定参数，则回调指定模式的状态。
```lsl
ACCESS.GET.MODE
ACCESS.GET.MODE | PUBLIC
ACCESS.GET.MODE | GROUP
ACCESS.GET.MODE | HARDCORE
// 回调：
ACCESS.EXEC | ACCESS.GET.MODE | 1; 0; 0
ACCESS.EXEC | ACCESS.GET.MODE | 1
ACCESS.EXEC | ACCESS.GET.MODE | 0
ACCESS.EXEC | ACCESS.GET.MODE | 0
```

### 设置公开/群组/硬核模式
#### ACCESS.SET.PUBLIC
#### ACCESS.SET.GROUP
#### ACCESS.SET.HARDCORE
- 设置公开/群组/硬核模式。
- 1为启用，0为禁用。
- 公开模式允许非授权用户访问。
- 群组模式允许相同群组的用户访问。
- 硬核模式禁用逃跑功能。
- 执行后，将回调设置更改之后的结果。
```lsl
ACCESS.SET.PUBLIC | 1/0
ACCESS.SET.GROUP | 1/0
ACCESS.SET.HARDCORE | 1/0
// 回调：
ACCESS.EXEC | ACCESS.SET.PUBLIC | 1/0
ACCESS.EXEC | ACCESS.SET.GROUP | 1/0
ACCESS.EXEC | ACCESS.SET.HARDCORE | 1/0
```

### 逃跑（重置）
#### ACCESS.RESET
- 清除所有权限数据，重置权限脚本。
- 重新读取记事卡并设置默认数据。
- 硬核模式无法逃跑。
- 执行后，将回调重置结果，如果是硬核模式，则回调结果为FALSE。
```lsl
ACCESS.RESET
// 回调：
ACCESS.EXEC | ACCESS.RESET | 0
```

### 读取Access记事卡列表
#### ACCESS.LOAD.LIST
- 读取库存中access_开头的记事卡列表。
```lsl
ACCESS.LOAD.LIST
// 回调：
ACCESS.EXEC | ACCESS.LOAD.LIST | access_a1; access_a2; access_a3; ...
```

### 读取Access记事卡
#### ACCESS.LOAD
- 从access_开头的记事卡中获取访问数据数据。
  - 名字中不需要带access_前缀，如记事卡为access_main，则只需传递main。
- 执行后，将合并现有主人、信任和黑名单数据，并覆盖其余权限。
```lsl
ACCESS.LOAD | file1
// 回调：
ACCESS.EXEC | ACCESS.LOAD | 1
// 读取记事卡成功后的回调
ACCESS.LOAD.NOTECARD | file1 | 1
```

### 显示Access菜单
#### ACCESS.MENU
- 立即显示Access菜单。
```lsl
ACCESS.MENU | 上级菜单名
```

### 请求推送权限状态通知
#### ACCESS.GET.NOTIFY
- 将触发权限更新通知。权限通知将分别推送主人列表、信任列表、黑名单、公开/群组/硬核模式状态，其他脚本接收后，可自行进行处理。
- 当脚本重置、读取记事卡、通过菜单变更权限时，都会自动发送此通知。
- 使用权限指令调用脚本时，不会主动推送，请在操作完成后，调用此指令来推送权限状态。
- 权限通知将只推送，不进行回调。
```lsl
ACCESS.GET.NOTIFY
// 回调：
ACCESS.NOTIFY | OWNER | UUID1; UUID2; ...
ACCESS.NOTIFY | TRUST | UUID1; UUID2; ...
ACCESS.NOTIFY | BLACK | UUID1; UUID2; ...
ACCESS.NOTIFY | MODE | 1; 0; 0
```

## 权限执行回调
- 当执行权限指令时，将回调执行结果。根据不同情况，结果的格式也有所不同。
```lsl
ACCESS.EXEC | ACCESS.ADD.OWNER | 1
ACCESS.EXEC | ACCESS.SET.PUBLIC | 0
ACCESS.EXEC | ACCESS.GET.MODE | 1; 0; 0
```

## 扩展用法
### 批量执行权限指令
- 可通过【&&】拼接多条权限指令，一次性执行完毕。执行完毕后，回调也是以同样的格式合并发送。
```lsl
ACCESS.GET.OWNER && ACCESS.GET.TRUST && ACCESS.GET.BLACK
// 回调：
ACCESS.EXEC | ACCESS.GET.OWNER | UUID1; UUID2; UUID3; ... && ACCESS.EXEC | ACCESS.GET.TRUST | UUID1; UUID2; UUID3; ... && ACCESS.EXEC | ACCESS.GET.BLACK | UUID1; UUID2; UUID3; ...
```

## 权限配置文件格式
- 权限配置文件名为前缀为access_的记事卡。
- 主人列表、信任列表和黑名单会和现有的内容合并。
- 公开、群组、硬核模式将会被记事卡中的内容覆盖。
- 只有当根权限用户为穿戴者自己时，才会根据access中的root字段更新根权限用户。
- lock=1时，将在穿戴时自动上锁，防止脱下。
### 示例
access
```lsl
root=uuid
owner=uuid1;uuid2;uuid3;...
trust=uuid1;uuid2;uuid3;...
black=uuid1;uuid2;uuid3;...
public=1
group=0
hardcore=0
lock=1
```




# 牵绳系统文档
脚本通过调用llMessageLink方法将牵绳相关指令传递到牵绳脚本，即可实现相关功能。牵绳系统的执行结果也通过触发link_message返回。
###### 阅读本文档前，请先阅读[菜单文档](README.Menu.md)，此牵绳系统中的部分功能依赖菜单系统，并且指令格式与用法与菜单系统基本保持一致。

## 牵绳功能指令
- 通过调用llMessageLink方法传递指令。格式：llMessageLinked(LINK_SET, 牵绳指令ID, 牵绳指令字符串, 用户UUID)。
- 牵绳指令ID恒为1005。ID不为1005的消息将被全部忽略。
- 牵绳指令字符串格式：指令标头 | 指令参数1 | 指令参数2 | 指令数据1; 指令数据2; ... | ...
- 牵绳指令字符串根据不同的指令会有所变化，详见下面指令介绍。
- 为了方便阅读，下面的牵绳指令和回调中的分隔符【|】、【;】、【&&】两边都添加了空格，实际执行时并不会添加此空格。
	- 虽然牵绳系统能自动处理分割符两边的空格，但仍然不建议在拼接时加空格。

### 设置牵绳配置
#### LEASH.SET
- 配置牵绳的各项设置。
- 配置的键值详见下方记事卡配置。
```lsl
LEASH.SET | ConfigName | ConfigValue
// 回调：
LEASH.EXEC | LEASH.SET | ConfigValue
```

### 获取牵绳配置
#### LEASH.GET
- 获取牵绳的各项设置。
- ConfigName为空时，按顺序返回全部配置键值。
- 配置的键值详见下方记事卡配置。
```lsl
LEASH.GET | ConfigName
LEASH.GET
// 回调：
LEASH.EXEC | LEASH.GET | ConfigValue
LEASH.EXEC | LEASH.GET | ConfigName1; ConfigValue1; ConfigName2; ConfigValue2; ...
```

### 抓住牵绳
#### LEASH.TO
- 将牵绳系到对应玩家或物品上。
- 参数分别为玩家或物品的UUID和粒子效果开关。
- UUID为空时，则取消牵绳。
- 粒子效果开关为空时，则为配置中设置的粒子开关。
- 
```lsl
LEASH.TO | UUID | 1
LEASH.TO | UUID
LEASH.TO
// 回调：
LEASH.EXEC | LEASH.TO | UUID
```

### 拉到目标身边
#### LEASH.YANK
- 将玩家拉到目标身边。
- 参数为玩家或物品的UUID。
- 
```lsl
LEASH.YANK | UUID
// 回调：
LEASH.EXEC | LEASH.YANK | UUID
```

### 显示牵绳效果
#### LEASH.PARTICLE
- 显示彼此之间的牵绳效果。
- 参数为玩家或物品的UUID。
- 参数为空时，则取消牵绳效果。
- 此指令仅显示效果，并无牵引能力。
- 
```lsl
LEASH.PARTICLE | UUID
LEASH.PARTICLE
// 回调：
LEASH.EXEC | LEASH.PARTICLE | UUID
```

### 读取Leash记事卡列表
#### LEASH.LOAD.LIST
- 读取库存中leash_开头的记事卡列表。
```lsl
LEASH.LOAD.LIST
// 回调：
LEASH.EXEC | LEASH.LOAD.LIST | leash_1; leash_2; leash_3; ...
```

### 读取Leash记事卡
#### LEASH.LOAD
- 从leash_开头的记事卡中获取访问数据数据。
  - 名字中不需要带leash_前缀，如记事卡为leash_main，则只需传递main。
```lsl
LEASH.LOAD | file1
// 回调：
LEASH.EXEC | LEASH.LOAD | 1
// 读取记事卡成功后的回调
LEASH.LOAD.NOTECARD | file1 | 1
```

### 显示牵绳菜单
#### LEASH.MENU
- 立即显示牵绳菜单。
```lsl
LEASH.MENU | 上级菜单名
```

## 扩展用法
### 批量执行牵绳指令
- 可通过【&&】拼接多条牵绳指令，一次性执行完毕。执行完毕后，回调也是以同样的格式合并发送。
```lsl
LEASH.TO | UUID && LEASH.YANK | UUID
// 回调：
LEASH.EXEC | LEASH.TO | UUID && LEASH.EXEC | LEASH.YANK | UUID
```

### 牵引带（Leash Holder）
- 可将leash_holder.lsl放入牵引带中，即可生效。
- 在允许牵绳连接到牵引带时，请向Lock Meister（-8888）发送“LEASH_HOLDER_READY”指令，牵绳将自动连接至此牵引带。
- 在禁止牵绳连接到牵引带时，请向Lock Meister（-8888）发送“LEASH_HOLDER_EMBAR”指令，牵绳将自动连接至玩家本人。

## 牵绳配置文件格式
- 牵绳配置文件名为前缀为leash_的记事卡。
- 示例中的配置文件为默认状态，请根据自己的需求进行修改。
- #开头的行为注释行，不做任何处理。
### 示例
leash_main
```lsl
# 启用/禁用牵绳粒子效果
particleEnabled=1
# 粒子效果模式（可选：Ribbon, Chain, Leather, Rope, None）
particleMode=Ribbon
# 粒子最大生命周期
particleMaxAge=3.5
# 粒子颜色
particleColor=<1.0, 1.0, 1.0>
# 粒子大小
particleScale=<0.04, 0.04, 1.0>
# 粒子发射频率
particleBurstRate=0.0
# 粒子重量
particleGravity=<0.0,0.0,-1.0>
# 粒子数量
particleCount=1
# 粒子全亮模式
particleFullBright=1
# 粒子发光效果
particleGlow=0.2
# 各模式下粒子贴图
particleTexture=Ribbon;cdb7025a-9283-17d9-8d20-cee010f36e90;Chain;4cde01ac-4279-2742-71e1-47ff81cc3529;Leather;8f4c3616-46a4-1ed6-37dc-9705b754b7f1;Rope;9a342cda-d62a-ae1f-fc32-a77a24a85d73;None;8dcd4a48-2d37-4909-9f78-f7a9eb4ef903
# 粒子颜色列表（用于菜单中的Style选项）
particleColorList=White;<1.0, 1.0, 1.0>;Black;<0.0, 0.0, 0.0>;Gray;<0.5, 0.5, 0.5>;Red;<1.0, 0.0, 0.0>;Green;<0.0, 1.0, 0.0>;Blue;<0.0, 0.0, 1.0>;Yellow;<1.0, 1.0, 0.0>;Pink;<1.0, 0.5, 0.6>;Brown;<0.2, 0.1, 0.0>;Purple;<0.6, 0.2, 0.7>;Barbie;<0.9, 0.0, 0.3>;Orange;<0.9, 0.6, 0.0>;Toad;<0.2, 0.2, 0.0>;Khaki;<0.6, 0.5, 0.3>;Pool;<0.1, 0.8, 0.9>;Blood;<0.5, 0.0, 0.0>;Anthracite;<0.1, 0.1, 0.1>;Midnight;<0.0, 0.1, 0.2>
# 牵绳link名称
leashPointName=leashpoint
# 牵绳长度
leashLength=3
# 被牵引时是否自动转向
leashTurnMode=1
# 严格模式（RLV限制、自动跟随传送等）
leashStrictMode=0
# 位移刷新频率
leashAwait=0.2
# 最大检测距离
leashMaxRange=60
# 位置偏移
leashPosOffset=<0.0, 0.0, 0.0>
```

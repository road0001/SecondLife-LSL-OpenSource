# RLV和RLVa文档

## 引用来源

- RLV（RestraintedLove，Kokua）
  - https://wiki.secondlife.com/wiki/LSL_Protocol/RestrainedLoveAPI
  - http://realrestraint.blogspot.com/
- RLV Relay
  - https://wiki.secondlife.com/wiki/LSL_Protocol/Restrained_Love_Relay/Specification
- RLVa（Firestorm，Catznip，Alchemy）
  - https://wiki.catznip.com/index.php?title=Category:RLVa
  - https://wiki.catznip.com/index.php?title=Special:AllPages

## 版本检查

### 自动版本检查：@version=<channel_number>

- 支持RLV的客户端将在指定频道回复RLV API的版本。未开启RLV的客户端不会回复任何内容，因此需要设定超时时长并移除监听器。
- 警告：登录时，on_rez事件会在发送聊天信息之前触发，因此需要至少30秒~1分钟的时间等待并接收回复。

### 自动版本检查：@versionnew=<channel_number>

- 该命令是@version的新版本，@version是出于兼容性目的而保留的。该命令返回“RestrainedLoveviewer v...(SL...)”。

### 自动版本检查：@versionnum=<channel_number>

- 支持RLV的客户端将在指定频道回复RLV API的版本号。该命令比 @version 更方便，因为脚本不必解析响应文本，可以立即获取版本号。
- 版本号只是一个整数，表示 API 的版本。如果版本是 XYZP，则数字将为 X.10^6 + Y.10^4 + Z.10^2 + P。例如，1.21.1 将为 1210100。

### 手动版本检查：@version

- 此命令必须在 IM 中从化身发送给用户（不适用于对象）。查看器会自动在 IM 中向发送者回复其版本，但消息和答案都不会出现在用户的 IM 窗口中，因此通常是完全隐秘的。但是，某些查看器（例如 Firestorm）能够在有人开始向用户输入 IM 时发送自动回复消息。如果用户启用了该选项，则发件人键入@后，即时消息窗口将打开并显示自动回复，但不会显示其他内容。

## 黑名单处理

黑名单（在 v2.8 中实现）是查看器应忽略的 RLV 命令列表。它可以随时修改，但需要重新启动才能使更改生效。当发出命令且该命令属于黑名单的一部分时，RLV 将忽略它。修改黑名单不会清除现有的限制，但一旦发布，就需要重新启动。当收到命令时，无论命令是否实际被接受，都会向脚本发送肯定的确认。这样，如果等待通知的脚本无法处理拒绝，则它们不会中断。

### 自动版本号检查，后跟黑名单：@versionnumbl=<channel_number>

- 支持RLV的客户端将在指定频道回复RLV API的版本号，后跟【,】和黑名单的内容。
  - 举例：@versionnumbl=2222
  - 回复：2080000,sendim,recvim

### 获取黑名单的内容，使用过滤器：@getblacklist[:filter]=<channel_number>

- 支持RLV的客户端将在指定频道回复黑名单的内容，黑名单只存在包含过滤器的字段。

### 手动黑名单检查：@getblacklist

- 此命令必须在 IM 中从化身发送给用户（不适用于对象）。查看器会自动将其黑名单的内容回复给 IM 中的发件人，但消息和答案都不会出现在用户的 IM 窗口中，因此它通常是完全隐秘的，与上面在 @version 下提到的相同警告。

## 主要功能

### 在私人频道上启动/停止通知：@notify:<channel_number>[;word]=<rem/add>

- 使查看器自动重复在指定频道上添加或删除的任何限制，或仅重复名称包含分号（;）字符后指定单词的限制。私人频道 <channel_number> 上的响应前面带有斜杠（/），以避免头像在不知情的情况下向其他脚本发送命令，后跟等号（=）和“n”或“ y”根据是否分别应用或取消限制。 “@clear”命令不会添加等号。
- 举例：@notify:2222;detach=add
- 发送给2222：/detach=n
- 解锁给2222：/detach=y
- /accepted_in_rlv inv_offer <folder>
  - 该文件夹已被接受，现在可以在 #RLV 下使用。
- /accepted_in_inv inv_offer <folder>
  - 文件夹已被接受但未共享。
- /declined inv_offer <folder>
  - 文件夹已被拒绝和/或用户已按“阻止”（以前称为“静音”）。
- 其中 <folder> 是给定文件夹或项目的完整路径。例如，~MyCuffs。 “inv_offer”之前有一个空格，这是一个以易于为其设置通知的方式选择的令牌。如果您只想知道#RLV 文件夹中是否已接受名为“~MyCuffs”的文件夹，请发出“@notify:2222;accepted_in_rlv inv_offer ~MyCuffs=add”命令。如果您只想知道头像是否收到了某些内容，请发出简单的“@notify:2222;inv_offer=add”命令。
- /worn legally <layer>
  - 化身刚刚在指定层穿了一件衣服。
- /unworn legally <layer>
  - 化身刚刚从指定层脱下了一件衣服。
- /attached legally <attach_point_name>
  - 化身刚刚将一个对象附加到指定的附加点。
- /attached illegally <attach_point_name>
  - 化身刚刚将一个对象附加到指定的附加点，但不允许这样做（可能是脚本自动附加它），并且它将在几秒钟内分离。
- /detached legally <attach_point_name>
  - 化身刚刚从指定的附着点分离了一个对象。
- /detached illegally <attach_point_name>
  - 化身刚刚从指定的附着点分离了一个对象，但不允许这样做（可能是脚本将其踢掉），并且它将在几秒钟内重新附着。
- /sat object legally <object_UUID>
  - 化身刚刚坐在某个物体上，并提供了其 UUID。
- /unsat object legally <object_UUID>
  - 化身刚刚从物体上站起来，并提供了其 UUID。
- /unsat object illegally <object_UUID>
  - 化身刚刚从对象上站起来，并提供了其 UUID。但在这种情况下，化身受到 @unsit 限制并无论如何站起来（可能在 llUnSit() 调用之后）。
- /sat ground legally
  - 化身刚刚坐在地上。请注意，如果化身此时正在飞行，它很可能会悬浮，因为“坐在地上”更像是“锚定在我们所在的位置”。
- /unsat ground legally
  - 化身刚刚从地面站起来。
- /unsat ground illegally
  - 化身刚刚从地面站起来。但在这种情况下，化身受到 @unsit 限制并无论如何站起来（可能在 llUnSit() 调用之后）。

### 允许/拒绝宽容例外：@permissive=<y/n>

- 当被拒绝时，所有限制都会变成其“安全”对应项（如果有）。这意味着如果限制的异常不是由发出限制的同一对象发出的，则该限制的异常将被忽略。使用非安全限制（原始限制，如 @sendim、@recvim 等）而不使用 @permissive 允许头像从不同对象发出的异常中受益。
- 警告 ：使用此命令（或原始命令的任何安全版本）可能会默默地丢弃由不同对象发出的异常（这甚至是其主要目的），因此，在此限制生效期间，某些产品可能会停止工作。例如，允许头像始终能够向特定朋友发送 IM 的产品将无法克服另一个对象发送的 @sendim_sec 或 @permissive 命令，并且看起来像是已损坏。因此，请谨慎使用，并让用户意识到您自己的产品有多安全！

### 清除与对象绑定的所有规则：@clear

- **警告** ：默认情况下在分离时触发时，这可能会阻止 @defaultwear 处于活动状态时自动重新附加，因为 @clear 也会提升 @detach=n，因此查看者会认为该项目是通过 default-wear-action 意外分离的已解锁且不会重新连接。
- 可能的解决方法：
  - 仅解除您使用 @clear=<pattern> 添加的确切限制
  - 仅当您确定附件未锁定时才在分离时触发@clear
  - 完全不要在分离时触发@clear，并等待查看者解除设置的限制

### 清除与对象关联的规则子集：@clear=<string>

- 相关的所有限制和例外 此命令清除与名称包含 <string> 的特定UUID 。一个很好的例子是“@clear=tp”，它清除与该对象相关的所有 传送 限制和异常，而“@clear=tplure:”只会清除“teleport-by-friend”限制的异常

### 获取化身当前提交的限制列表：@getstatus[:<part_of_rule>[;<custom_separator>]]=<channel>

- 使查看者自动回答头像当前所遵循的规则列表，该列表仅包含发送此命令的对象发出的限制，立即在脚本可以侦听的聊天频道号<channel_number>上。回答是规则列表，用斜杠（/）或任何其他分隔符（如果指定）分隔。注意：从 v1.16 开始，字符串开头会添加斜杠。这不会混淆 llParseString2List() 调用，但会混淆 llParseStringKeepNulls() 调用！

- 如果指定<custom_separator>，它将用提供的分隔符替换斜杠 （/）。注意，选项部分必须存在，因此即使 <part_of_rule> 不存在，分号（;）之前也必须有一个冒号（:）。

- 示例：

- ```
  示例：如果头像位于 tploc、tplure、tplm 和 sattp 下，则脚本将得到以下内容：
  @getstatus=2222 => /tploc/tplure/tplm/sittp
  @getstatus:sittp=2222 => /sittp
  @getstatus:tpl=2222 => /tploc/tplure/tplm （因为“tpl”是“tploc”、“tplure”和“tplm”的一部分，但不是“sittp”的一部分）
  @getstatus:tpl;#=2222 => #tploc#tplure#tplm （因为“tpl”是“tploc”、“tplure”和“tplm”的一部分，但不是“sittp”的一部分，并且
                             指定分隔符为“#”）
  @getstatus:;#=2222 => #tploc#tplure#tplm#sittp（因为指定的分隔符是“#”）
  @getstatus:;=2222 => /tploc/tplure/tplm/sittp （因为指定的分隔符为空，所以默认为“/”）
  ```

### 获取化身当前提交的所有限制列表：@getstatusall[:<part_of_rule>[;<custom_separator>]]=<channel>

- 使查看者自动回答化身当前所遵循的规则列表，对于所有对象，无论其 UUID 为何，与 @getstatus 相反，立即在脚本可以侦听的聊天频道号码 <channel_number> 上。
- 答案是规则列表，用斜杠（/）或任何其他分隔符（如果指定）分隔。注意：从 v1.16 开始，字符串开头会添加斜杠。这不会混淆 llParseString2List() 调用，但会混淆 llParseStringKeepNulls() 调用！

## 移动

### 允许/阻止飞行：@fly=<y/n>

- 允许/阻止飞行。

### 允许/阻止通过双击方向键跑步：@temprun=<y/n>

- 当被阻止时，用户无法通过双击方向键来跑步。如果您想完全阻止用户跑步，则还必须使用@alwaysrun。

### 允许/阻止始终跑步：@alwaysrun=<y/n>

- 如果您想完全阻止用户跑步，则还必须使用@temprun。
- 当您想要强制用户在跑步前加速而不是一直跑步时（例如在战斗或体育比赛期间），此命令非常有用。

### 强制将化身旋转到设定方向：@setrot:<angle_in_radians>=force

- 强制化身从北向以弧度角度设定的方向旋转。请注意，此命令不是很精确，如果该操作尝试将头像旋转小于 10°（实验值，有人提到 6° 是最小值），也不会执行任何操作。换句话说，最好首先使用 llGetRot() 检查，或者让头像转动两次，首先 180° 加上所需的角度，然后再转动我们需要的角度。它不是很优雅，但很有效。

- 当在附件中使用时，此代码片段将头像的当前旋转转换为适合 @setrot 的弧度角度：

  - ```
    vector fwd = <1,0,0>*llGetRootRotation();
    float angle = llAtan2(fwd.x, fwd.y);
    ```

### 更改化身的悬浮高度：@adjustheight:<distance_pelvis_to_foot_in_meters>;<factor>[;delta_in_meters]=force

- 强制化身修改其“Z偏移”，即悬浮高度。该值已经可以通过大多数第三方查看器中的调试设置进行更改，该命令允许根据动画自动进行更改。

## 相机和视图

### 允许/防止使用Ctrl-0向前缩放太远：@camzoommax:<max_multiplier>=<y/n>

- 当激活时，此限制会阻止用户放大（使用 Ctrl-0 键）超过 <max_multiplier>，因为知道 1.0 是默认值。如果多个对象发出此限制，则查看器将保留所有对象中的最小值。

### 允许/防止使用Ctrl-8缩放得太远：@camzoommin:<min_multiplier>=<y/n>

- 当激活时，此限制可防止用户缩小（使用 Ctrl-8 键）超过 <min_multiplier>，因为知道 1.0 是默认值。如果多个对象发出此限制，则查看器保留所有对象中的最高值。

### 允许/防止使用Ctrl-0向前缩放太远：@setcam_fovmin:<min_fov_in_radians>=<y/n>

- 激活后，此限制可防止用户放大（使用 Ctrl-0 键）低于 <min_fov_in_radians>。如果多个对象发出此限制，则观看者保留所有对象中的最大价值。此命令类似于@camzoommax，但指定视野而不是缩放倍数。

### 允许/防止使用Ctrl-8缩放得太远：@setcam_fovmax:<max_fov_in_radians>=<y/n>

- 激活后，此限制可防止用户缩小（使用 Ctrl-8 键）高于 <max_fov_in_radians>。如果多个对象发出此限制，则查看器将保留所有对象中的最低值。此命令类似于@camzoommin，但指定视野而不是缩放倍数。

### 更改视野：@setcam_fov:<fov_in_radians>=force

- 此命令强制头像缩放到特定值，但不限制缩小（必须使用 @camzoomXXX 和 @setcam_fovXXX）。

### 允许/防止将相机移动到距头像太远的位置：@camdistmax:<max_distance>=<y/n>

#### @setcam_avdistmax:<max_distance>=<y/n>

- 激活后，此限制可防止用户使用鼠标滚轮或使用 Alt 键对焦时将相机移动到距头像太远的位置。如果 <max_distance> 设置为 0，此命令会强制头像停留在 Mouselook 中。如果多个对象发出此限制，则查看器将保留所有对象中的最小值。不过，这不会影响移动相机本身的脚本。

### 允许/防止将相机移动得太靠近头像：@camdistmin:<min_distance>=<y/n>

#### @setcam_avdistmin:<min_distance>=<y/n>

- 允许/防止将相机移动得太靠近头像。
- 激活后，此限制可防止用户使用鼠标滚轮或使用 Alt 键对焦时将相机移得太靠近头像。如果 <min_distance> 设置为大于 0 的值，则此命令会强制化身离开 Mouselook，并防止返回到该状态。如果多个对象发出此限制，则查看器保留所有对象中的最高值。不过，这不会影响移动相机本身的脚本。

### 部分或完全遮蔽头像：@camdrawmin:<min_distance>=<y/n>

#### @camdrawmax:<max_distance>=<y/n>

#### @camdrawalphamin:<min_alpha>=<y/n>

#### @camdrawalphamax:<max_alpha>=<y/n>

- 当激活时，这两个限制使观看者在头像周围绘制几个同心球体，不透明度从 <min_distance> 处的 <min_alpha> 到 <max_distance> 处的 <max_alpha> 逐渐增加。结果看起来就像雾随着距离的增加而逐渐变暗，如果@camdrawalphamax设置为1（默认值），它可以完全遮挡视图。
- 发布这些限制时需要考虑以下几个事项： - 仅当 @camdrawalphamin 和 @camdrawalphamax 都指定且不同时，才会出现雾（视图逐渐变暗）。如果省略其中任何一个，则仅渲染一个球体（这可能是脚本编写者想要的）。
- 要绘制的球体数量不是固定的，取决于查看器（例如，调试设置可以让用户决定，因为要堆叠的透明球体越多，渲染就越重）。
- 观看者这样做是为了使远处的物体仅被 @camdrawalphamax 遮挡（例如，如果 @camdrawalphamax 设置为 0.75，则远处的白色全亮墙将看起来为深灰色，RGB 64/64/64），无论要绘制的球体数量。
- 相机不能超出@camdrawmin，并且@camdrawmin不能设置为低于0.4（因为它的作用不是强制Mouselook，并且在该限制下观察者不会渲染球体）。
- 如果其中几个是由不同的对象发出的，则查看器保留的限制是最低最大值和最高最小值。 - 头像的姓名标签和世界中的悬停文本在 @camdrawmin 之外逐渐消失。

### 指定雾的颜色 ：@camdrawcolor:<red>;<green>;<blue>=<y/n>

- 当该命令发出时，@camdrawmin 和@camdrawmax 设计的雾的颜色设置为<red>、<green>、<blue>。这三个值介于 0.0 和 1.0 之间，默认值为黑色（0;0;0）。当多个对象发出此命令时，生成的颜色是所有对象的混合。

### 允许/阻止从头像解锁相机：@camunlock=<y/n>

#### @setcam_unlock=<y/n>

- 当激活时，此限制会阻止用户从化身解锁相机，这意味着用户无法使用 Alt 来聚焦或使相机绕着化身旋转。当相机被锁定时，模拟会强制它保持在虚拟人物的视线范围内，这意味着这种限制可以很好地防止看穿墙壁。

### 将所有头像转为超过一定距离的剪影：@camavdist:<distance>=<y/n>

- 当激活时，此限制使所有超出<距离>的化身看起来好像在视觉上是静音的，但颜色是漆黑的。

### 将所有纹理转为空白，除了头像：@camtextures[:texture_uuid]=<y/n>

#### @setcam_textures[:texture_uuid]=<y/n>

- 当激活时，这种限制使观看者忽略世界上的每一个纹理，除了化身所佩戴的附件以及他们的皮肤和衣服上的纹理。材质也未受影响，因此这种限制有利于模拟化身无法“看到”的事实，更不用说“读取”纹理，但仍然可以“感觉”周围的世界。
- 从 v2.9.20 开始，指定为参数的 uuid 用于在世界各地显示相应的纹理，而不是灰色纹理。

### 获取当前限制用户的最小相机距离：@getcam_avdistmin=<channel_number>

- 使观看者自动回答摄像机与虚拟人物之间的最小距离。

### 获取当前限制用户的最大相机距离：@getcam_avdistmax=<channel_number>

- 使观看者自动回答摄像机与虚拟人物之间的最大距离。

### 获取当前限制用户的最小视角：@getcam_fovmin=<channel_number>

- 使查看器自动回答用户可以放大的最小视野（以弧度为单位）。

### 获取用户当前限制的最大视角：@getcam_fovmax=<channel_number>

- 使查看器自动回答用户可以缩小到的最大视野（以弧度为单位）。

### 获取用户限制的当前最小缩放倍数：@getcam_zoommin=<channel_number>

- 使查看器自动回答用户可以缩小到的最小倍数。

### 获取用户缩放到的当前视野：@getcam_fov=<channel_number>

- 使查看器自动回答用户放大的当前视野值（以弧度为单位）。

## 聊天、表情和即时消息

### 允许/阻止发送聊天消息：@sendchat=<y/n>

- 当被阻止时，在 通道 0 上输入的所有内容都将被丢弃。但是，以斜杠（/）开头的表情和消息将通过，并分别被截断为 30 和 15 个字符长的字符串（稍后可能会更改）。带有特殊符号如 ()"-*=_^ 的消息是禁止的，并且将被丢弃。当出现句点（.）时，消息的其余部分将被丢弃。

### 允许/阻止喊叫：@chatshout=<y/n>

- 当被阻止时，即使用户试图喊叫，头像也会正常聊天。这不会以任何方式改变消息，只会改变其范围。

### 允许/阻止以正常音量聊天：@chatnormal=<y/n>

- 当被阻止时，即使用户试图正常喊叫或聊天，头像也会低声说话。这不会以任何方式改变消息，只会改变其范围。

### 允许/阻止窃窃私语：@chatwhisper=<y/n>

- 当被阻止时，即使用户试图窃窃私语，头像也会正常聊天。这不会以任何方式改变消息，只会改变其范围。

### 将公共聊天重定向到私人频道：@redirchat:<channel_number>=<rem/add>

- 当激活时，此限制会将用户在公共频道（/0）上所说的任何内容重定向到选项字段中提供的私人频道。如果发出多个重定向，聊天消息将被重定向到每个频道。
- 它不适用于表情，并且在说话时不会触发任何动画（键入开始、键入停止、点头）。
- 此限制不会取代@sendchannel。 
- 注意： 从 RLV v1.22.1 / RLVa 1.1.0 开始，它有一个错误，@redirchat 也会截断通道 0 上的表情。额外的 @emote=add 可以解决这个副作用。
- 此错误已在从 v1.22g 开始的 Cool VL 查看器中修复（但 Marine 的 RLV v1.23 仍然存在此错误）和 RLV v2.0（可以安全地假设从 v1.24 和 v2 开始的所有查看器中已修复此错误）。

### 允许/阻止接收聊天消息：@recvchat=<y/n>

#### 安全方式：@recvchat_sec=<y/n>

- 当被阻止时，除了表情之外，在公共聊天中听到的所有内容都将被丢弃。

### 删除/添加聊天消息接收例外：@recvchat:<UUID>=<rem/add>

- 添加例外时，用户可以听到 UUID 命令中指定 的发件人发送的聊天消息。这仅覆盖对此头像的预防（例外数量没有限制），当它过时时不要忘记将其删除。

### 允许/阻止接收来自特定某人的聊天消息：@recvchatfrom:<UUID>=<y/n>

- 如果被阻止，除了表情之外，在公共聊天中从指定头像听到的所有内容都将被丢弃。

### 允许/阻止触发手势：@sendgesture=<y/n>

- 当被阻止时，用户无法发送任何手势（聊天、动画、声音）。

### 删除/添加上述表情截断的例外：@emote=<rem/add>

- 添加此例外时，表情不再被截断（但是，特殊符号仍会丢弃消息）。

### 将公共表情重定向到私人频道：@rediremote:<channel_number>=<rem/add>

- 当激活时，此限制会将用户在公共频道（/0）上所说的任何表情重定向到选项字段中提供的私人频道。如果发出多个重定向，表情将被重定向到每个频道。

### 允许/阻止看到表情：@recvemote=<y/n>

- 如果被阻止，公共聊天中看到的所有表情都将被丢弃。

### 允许/阻止接收特定某人在公共聊天中看到的表情：@recvemotefrom:<UUID>=<y/n>

#### 安全方式：@recvemote_sec=<y/n>

- 当被阻止时，在公共聊天中看到的指定头像的所有表情都将被丢弃。

### 删除/添加表情看到预防的例外：@recvemote:<UUID>=<rem/add>

- 添加例外时，用户可以看到 UUID 来自命令中指定 的发送者的表情。这仅覆盖对此头像的预防（例外数量没有限制），当它过时时不要忘记将其删除。

### 允许/阻止使用除某些频道之外的任何聊天频道：@sendchannel[:<channel>]=<y/n>

#### 安全方式：@sendchannel_sec[:<channel>]=<y/n>

- 作为 @sendchat 的补充，此命令可防止用户在非公共聊天频道上发送消息。
- 如果指定了通道，则它成为上述限制的例外（那么最好分别使用“rem”或“add”而不是“y”或“n”）。它不会阻止查看者自动回复，例如 @version=nnnn、@getstatus=nnnn 等。

### 允许/阻止使用特定聊天频道：@sendchannel_except:<channel>=<y/n>

- 当此规则处于活动状态时，用户无法在指定频道上发送私人聊天消息（这是对 @sendchannel 的补充命令）。

### 允许/阻止发送即时消息：@sendim=<y/n>

#### 安全方式：@sendim_sec=<y/n>

- 一旦被阻止，在 IM 中输入的所有内容都将被丢弃，并向接收者发送一条虚假消息。
- 安全方式：此特定命令仅接受从同一对象发出的异常，而不是接受来自任何对象的异常的非安全方式。

### 删除/添加即时消息发送阻止的例外：@sendim:<UUID_or_group_name>=<rem/add>

- 添加例外时，用户可以向 UUID 命令中指定 的接收者发送即时消息。这仅覆盖对此头像的预防（例外数量没有限制），当它过时时不要忘记将其删除。
- 从 2.9.29 开始，您可以指定组名称而不是 UUID。如果您改为写“allgroups”，则所有组都受到关注。

### 允许/阻止向特定的某人发送即时消息：@sendimto:<UUID_or_group_name>=<y/n>

- 当被阻止时，在 IM 中输入到指定头像的所有内容都将被丢弃，并且将发送一条虚假消息。
- 从 2.9.29 开始，您可以指定组名称而不是 UUID。如果您改为写“allgroups”，则所有组都受到关注。

### 允许/阻止与任何人开始 IM 会话：@startim=<y/n>

- 如果被阻止，用户将无法与任何人启动 IM 会话。不过，已经开放的会话不受影响。

### 删除/添加 IM 会话启动预防的例外：@startim:<UUID>=<rem/add>

- 添加例外时，用户可以与 UUID 命令中指定 的接收者启动 IM 会话。这仅覆盖对此头像的预防（例外数量没有限制），当它过时时不要忘记将其删除。

### 允许/阻止与特定某人启动 IM 会话：@startimto:<UUID>=<y/n>

- 如果被阻止，用户将无法与该人启动 IM 会话。不过，已经开放的会话不受影响。

### 允许/阻止接收即时消息：@recvim=<y/n>

#### 安全方式：@recvim_sec=<y/n>

- 当被阻止时，每个传入的即时消息都将被丢弃，并且发件人将被通知用户无法阅读它们。

### 删除/添加即时消息接收预防例外：@recvim:<UUID_or_group_name>=<rem/add>

- 添加例外时，用户可以读取 UUID 命令中指定 的发件人的即时消息。这仅覆盖对此头像的预防（例外数量没有限制），当它过时时不要忘记将其删除。
- 从 2.9.29 开始，您可以指定组名称而不是 UUID。如果您改为写“allgroups”，则所有组都受到关注。

### 允许/阻止接收来自特定某人的即时消息：@recvimfrom:<UUID_or_group_name>=<y/n>

- 当被阻止时，从指定头像收到的每条即时消息都将被丢弃，并且发送者将被通知用户无法阅读它们。
- 从 2.9.29 开始，您可以指定组名称而不是 UUID。如果您改为写“allgroups”，则所有组都受到关注。

## 传送

### 允许/阻止本地传送：@tplocal[:max_distance]=<y/n>

- 当被阻止时，用户无法 传送 通过双击 到同一区域，除非它在指定的最大距离内。

### 允许/阻止传送到地标：@tplm=<y/n>

- 当被阻止时，用户无法使用 地标 、镐或任何其他预设位置来 传送 到那里。

### 允许/阻止传送到某个位置：@tploc=<y/n>

- 当被阻止时，用户无法 来传送 到坐标 通过使用地图 等 。

### 允许/阻止好友传送：@tplure=<y/n>

#### 安全方式：@tplure_sec=<y/n>

- 当被阻止时，用户会自动放弃任何 传送 提议，并通知发起提议的化身。

### 删除/添加好友传送预防例外：@tplure:<UUID>=<rem/add>

- 添加例外时，可以通过 UUID 命令中指定 的头像来传送用户。这仅覆盖对此头像的预防（例外数量没有限制），当它过时时不要忘记将其删除。

### 无限/限制sat-tp：@sittp[:max_distance]=<y/n>

- 受到限制时， 虚拟人物无法坐在prim 除非距离小于 1.5 m，否则 上。这可以保证笼子的安全，防止化身通过墙壁扭曲其位置（除非原形太近）。
- 从 v2.9.20 开始，您可以指定自定义距离，如果发出多个此类命令，查看器将限制为所有命令中的最小距离。

### 允许/阻止在与我们坐下的位置不同的位置站立：@standtp=<y/n>

- 当此限制处于活动状态并且化身站起来时，它会自动传送回最初坐下的位置。
- 请注意，发出限制时，“最后站立位置”也会被存储，因此这对于抢夺者等来说不会成为问题，他们让受害者坐下，然后将其移动到发出限制的牢房内，并且然后让他们坐下。在这种情况下，化身将留在单元格中。

### 强制传送用户：@tpto:<X>/<Y>/<Z>=force (*)

- 该命令强制化身传送到指定的坐标。

- 请注意，这些坐标始终是 全局的 ，因此调用此命令的脚本并不简单。

- 此外，如果目的地包含电话集线器或着陆点，则用户将着陆在那里而不是期望的点。这是 SL 限制。

- 另请记住，@tpto 会被 @tploc=n 抑制，从 v1.15 及更高版本开始，@unsit 也会被抑制。

- 这是正确调用该命令的示例代码：

- ```lsl
  // FORCE TELEPORT EXAMPLE
  // Listens on channel 4 for local coordinates and a sim name
  // and tells your viewer to teleport you there.
  //
  // By Marine Kelley 2008-08-26
  // RLV version required : 1.12 and above
  //
  // HOW TO USE :
  //   * Create a script inside a box
  //   * Overwrite the contents of the script with this one
  //   * Wear the box
  //   * Say the destination coords Region/X/Y/Z on channel 4 :
  //     Example : /4 Help Island Public/128/128/50
  
  key kRequestHandle; // UUID of the dataserver request
  vector vLocalPos;   // local position extracted from the
  
  Init () {
    kRequestHandle = NULL_KEY;
    llListen (4, "", llGetOwner (), "");
  }
  
  
  default
  {
    state_entry () {
      Init ();
    }
    
    on_rez(integer start_param) {
      Init ();
    }
    
    listen(integer channel, string name, key id, string message) {
      list tokens = llParseString2List (message, ["/"], []);
      integer L = llGetListLength (tokens);
  
      if (L==4) {
        // Extract local X, Y and Z
        vLocalPos.x = llList2Float (tokens, 1);
        vLocalPos.y = llList2Float (tokens, 2);
        vLocalPos.z = llList2Float (tokens, 3);
  
        // Request info about the sim
        kRequestHandle=llRequestSimulatorData (llList2String (tokens, 0), DATA_SIM_POS);
      }
    }
    
    dataserver(key queryid, string data) {
      if (queryid == kRequestHandle) {
        // Parse the dataserver response (it is a vector cast to a string)
        list tokens = llParseString2List (data, ["<", ",", ">"], []);
        string pos_str = "";
        vector global_pos;
  
        // The coordinates given by the dataserver are the ones of the
        // South-West corner of this sim
        // => offset with the specified local coordinates
        global_pos.x = llList2Float (tokens, 0);
        global_pos.y = llList2Float (tokens, 1);
        global_pos.z = llList2Float (tokens, 2);
        global_pos += vLocalPos;
  
        // Build the command
        pos_str =      (string)((integer)global_pos.x)
                  +"/"+(string)((integer)global_pos.y)
                  +"/"+(string)((integer)global_pos.z);
        llOwnerSay ("Global position : "+(string)pos_str); // Debug purposes
  
        // Fire !
        llOwnerSay ("@tpto:"+pos_str+"=force");
      }
    }
  }
  ```

### 强制传送用户，用户友好的方式：@tpto:<region_name>/<X_local>/<Y_local>/<Z_local>[;lookat]=force (*)

- 此命令强制头像传送到指定区域内指定的本地坐标。
- 请注意，与之前的版本不同，这些坐标是 区域的本地坐标 。
- 请注意，如果目的地包含电话集线器或着陆点，则用户将着陆在那里而不是所需的点。这是 SL 限制。
- 另请记住，@tpto 会被 @tploc=n 抑制，从 v1.15 及更高版本开始，@unsit 也会被抑制。

### 删除/添加来自特定头像的自动接受传送例外：@accepttp[:<UUID>]=<rem/add>

- 添加此规则将使用户自动接受来自键为 <UUID> 的头像的任何传送提议，就像该头像是 Linden 一样（没有确认框，没有消息，没有取消按钮）。
- 此规则不会取代或弃用@tpto，因为前者传送到某人，而后者传送到任意位置。
- 注意：在 v1.16 中，UUID 变为可选，这意味着 @accepttp=add 将强制用户接受任何人的传送提议！谨慎使用！

### 删除/添加来自特定头像的自动接受传送请求：@accepttprequest[:<UUID>]=<rem/add>

- 添加此规则将使用户自动接受来自密钥为 <UUID> 的头像或任何人（如果省略 UUID）的任何传送请求（因此自动发送传送提议）。

### 允许/阻止接收来自人员的传送提议：@tprequest=<y/n>

#### 安全方式：@tprequest_sec=<y/n>

- 当被阻止时，用户无法接收来自其他用户的“用户想要传送到您的位置”请求，并且该其他用户如果尝试的话会收到一条消息。

### 删除/添加接收传送例外：@tprequest:<UUID>=<rem/add>

- 添加例外时，用户可以 UUID 从命令中指定 的头像接收传送提议。这仅覆盖对此头像的预防（例外数量没有限制），当它过时时不要忘记将其删除。

## 库存、编辑和放置物品

### 允许/阻止使用库存：@showinv=<y/n>

- 强制 库存 窗口关闭并保持关闭状态。

### 允许/阻止阅读记事卡：@viewnote=<y/n>

- 阻止打开 记事卡 ，但不关闭已打开的记事卡。

### 允许/阻止打开脚本：@viewscript=<y/n>

- 阻止打开 脚本 ，但不关闭已打开的脚本。

### 允许/阻止打开纹理：@viewtexture=<y/n>

- 防止打开 纹理 （和快照），但不关闭已打开的纹理。

### 允许/阻止编辑对象：@edit=<y/n>

- 当无法编辑和打开对象时，“构建和编辑”窗口将拒绝打开。

### 删除/添加编辑例外：@edit:<UUID>=<rem/add>

- 添加例外时，用户可以特别编辑或打开该对象。

### 允许/阻止放置物品：@rez=<y/n>

- 当阻止 放置物品 内容、创建和删除对象、从清单中拖放和删除附件时，将会失败。

### 允许/阻止编辑特定对象：@editobj:<UUID>=<y/n>

- 如果被阻止，“构建和编辑”窗口将在尝试编辑或打开指定对象时拒绝打开。

### 允许/阻止编辑世界中的对象：@editworld=<y/n>

- 如果被阻止，用户将无法编辑任何不是附件的对象。

### 允许/阻止编辑附件：@editattach=<y/n>

- 当被阻止时，用户无法编辑任何未在世界中重新调整且不是 HUD 的对象。

### 允许/阻止向人们提供库存：@share=<y/n>

#### 安全方式：@share_sec=<y/n>

- 当被阻止时，用户无法与任何人共享任何内容（对象、记事卡...）。

### 删除/添加共享例外：@share:<UUID>=<rem/add>

- 当添加例外时，用户可以特别与该化身共享库存。

## 坐下

### 允许/阻止站立：@unsit=<y/n>

- 隐藏站立按钮。从 v1.15 开始，它还阻止传送，这是一种站立的方式。

### 强制坐在物体上：@sit:<UUID>=force (*)

- 如果用户无法坐下且距离超过 1.5 米，或者无法离开，则不起作用。
- 请注意：正版 RLV 查看器（Cool VL Viewer v1.26.20.28 及更高版本除外）要求座椅定义坐目标（llSitTarget() LSL 函数），否则强制坐会失败，并显示“没有合适的表面可供坐”来自 SL 服务器的错误消息。
- RLVa观看者将成功将虚拟人物坐在无坐目标的座位上，条件是虚拟人物与座位之间的距离小于8m。

### 获取头像所在物体的UUID：@getsitid=<channel_number>

- 使观看者自动回答头像当前所坐物体的 UUID，如果没有坐，则返回 NULL_KEY。

### 强制取消坐：@unsit=force (*)

- 不言自明，但由于某种原因它会随机失败 (**)，所以现在不要依赖它。需要进一步测试。
- (**) 实际上，失败是由于竞争条件造成的：不要将 @unsit=force 和 @sit:<seat_uuid>=force 组合在同一命令行 (llOwnerSay()) 中，并且始终允许至少一秒的暂停在发送此类相反的命令之前，否则您很可能会遇到失败，特别是对于海外居民（查看器和服务器之间的“ping”时间为 250 毫秒或更长，这意味着 @sit/@unsit 至少需要 500 毫秒才能完成）有效）和/或当模拟延迟很高时。

### 允许/阻止坐下：@sit=<y/n>

- 防止用户坐在任何东西上，包括 @sit:<UUID>=force。

### 强制坐在地上：@sitground=force

- 迫使化身坐在其站立的地面上。更具体地说，它将化身固定在它所在的位置，所以如果它当时正在飞行，它就会坐在空中。
- 如果头像受到 @sit 限制，此命令将失败。

## 服装和附件

### 渲染对象可分离/不可分离：@detach=<y/n>

- 当使用“n”选项调用时，发送此消息的对象（必须是附件）将变得不可分离。当调用“y”选项时，它可以再次分离。

### 解锁/锁定连接点：@detach:<attach_point_name>=<y/n>

- 当使用“n”选项调用时，名称为<attach_point_name>的连接点将被锁定为完整（如果当时被对象占用）或空（如果没有）。发出限制时占据此点的任何对象都将被视为不可分离，就像它本身发出“@detach=n”命令一样。
- 如果该点为空，它将保持这种状态，没有任何项目能够附加到那里，并且 llAttachToAvatar() 调用将失败（对象将被附加，然后立即分离）。

### 解锁/锁定空连接点：@addattach[:<attach_point_name>]=<y/n>

- 当使用“n”选项调用时，名称为 <attach_point_name> 的连接点将被锁定为空。当发出限制时，任何占据该点的对象都可以被分离，但不能在那里附加任何东西。
- 如果该点为空，它将保持这种状态，没有任何项目能够附加到那里，并且 llAttachToAvatar() 调用将失败（对象将被附加，然后立即分离）。
- 如果未指定<attach_point_name>，则将涉及所有附着点。此命令与 @addoutfit 相对应，用于附件。

### 解锁/锁定完整的连接点：@remattach[:<attach_point_name>]=<y/n>

- 当使用“n”选项调用时，名称为 <attach_point_name> 的连接点将被完全锁定。当发出限制时，任何占据该点的对象都将变得不可分离。
- 如果该点为空，它将允许用户佩戴某些东西，但该对象也将变得不可拆卸，没有项目能够替换它，并且 llAttachToAvatar() 调用将失败（该对象将被附加，然后立即分离）。
- 如果未指定<attach_point_name>，则将涉及所有附着点。此命令与 @remoutfit 相对应，用于附件。

### 允许/拒绝“穿戴”上下文菜单：@defaultwear=<y/n>

- 如果允许，用户始终能够在清单的上下文菜单上选择“穿戴”命令，即使对象被锁定在其头像上也是如此。
- 这存在踢出锁定对象的风险，但它会在 5 秒内自动重新附加（并且每秒连续锁定对象，直到没有任何东西可以重新附加）。
- 然而，某些对象的脚本编写方式可能会在分离时放弃其限制，或者根本没有考虑到即使是锁定的对象也可以在使用 RLV 时分离的事实。
- 因此，将此命令与“n”选项一起使用将抑制此命令，但它仍然可用于名称中或其父文件夹名称中包含目标附加点的对象，与 1.21 RLV 之前的版本完全相同。这对用户来说不太友好，但在确保不会意外分离锁定的对象时更安全。

### 强制脱下附件：@detach[:attachpt]=force (*)

#### @remattach[:attachpt 或 :uuid]=force (*)

- 其中部位是：

- ```lsl
  chest|skull|left shoulder|right shoulder|left hand|right hand|left foot|right foot|spine|
  pelvis|mouth|chin|left ear|right ear|left eyeball|right eyeball|nose|r upper arm|r forearm|
  l upper arm|l forearm|right hip|r upper leg|r lower leg|left hip|l upper leg|l lower leg|stomach|left pec|
  right pec|center 2|top right|top|top left|center|bottom left|bottom|bottom right|neck|root
  ```

- 如果未指定部分，则脱下所有内容。

### 允许/阻止穿衣服：@addoutfit[:<part>]=<y/n>

- 其中部位是：

- ```lsl
  gloves|jacket|pants|shirt|shoes|skirt|socks|underpants|undershirt|skin|eyes|hair|shape|alpha|tattoo|physics
  ```

- 如果未指定部位，则防止穿着超出头像已穿着的任何物品。

### 允许/阻止脱掉衣服：@remoutfit[:<part>]=<y/n>

- 其中部位是：

- ```lsl
  gloves|jacket|pants|shirt|shoes|skirt|socks|underpants|undershirt|skin|eyes|hair|shape|alpha|tattoo|physics
  ```

- ```lsl
  underpants|undershirt为青少年保留
  ```

- 如果未指定部位，则会阻止移除头像所穿着的任何东西。

### 强制脱掉衣服：@remoutfit[:<part>]=force (*)

- 其中部位是：

- ```lsl
  gloves|jacket|pants|shirt|shoes|skirt|socks|underpants|undershirt|alpha|tattoo|physics
  ```

- ```lsl
  青少年不能脱下underpants|undershirt
  ```

- 如果未指定部位，则删除所有内容。

- 注意： 自 Viewer 2.0 发布以来，出现了两个新的头像皮肤层：纹身和头像透明蒙版。 Alpha 和 Tattoo 层仅受实现新 Viewer 2.0 功能的 RLV 兼容查看器支持。

- 注意： 皮肤、形状、眼睛和头发无法移除，因为它们是身体部位（移除任何部分都会导致头像无法还原）。

### 获取穿过的衣服列表：@getoutfit[:part]=<channel_number>

- 使观看者立即在脚本可以监听的聊天频道号 <channel_number> 上自动以 0（空）和 1（占用）的列表形式回答当前服装层的占用情况。始终使用非零整数。请记住，普通观众根本不会回答任何问题，因此请在超时后删除侦听器。

- 0 和 1 的列表对应于：

- ```lsl
  gloves,jacket,pants,shirt,shoes,skirt,socks,underpants,undershirt,skin,eyes,hair,shape
  ```

- 如果指定了某个部分，则回答与该部分对应的单个 0（空）或 1（占用）。

- ```lsl
  Ex 1 : @getoutfit=2222 => "0011000111" => 头像穿着裤子、衬衫、内裤和背心，当然还有皮肤。
  Ex 2 : @getoutfit:socks=2222 => "0" => 头像没有穿袜子。
  ```

- 注意： 对于实现 Viewer 2.0 新功能的查看器，列表为：

- ```lsl
  gloves,jacket,pants,shirt,shoes,skirt,socks,underpants,undershirt,skin,eyes,hair,shape,alpha,tattoo
  ```

### 获取穿戴附件列表：@getattach[:attachpt]=<channel_number>

- 使查看器立即在脚本可以侦听的聊天频道号 <channel_number> 上自动以 0（空）和 1（已占用）列表的形式回答当前附着点的占用情况。始终使用非零整数。请记住，普通观众根本不会回答任何问题，因此请在超时后删除侦听器。

- 0 和 1 的列表对应于：

- ```lsl
  none,chest,skull,left shoulder,right shoulder,left hand,right hand,left foot,right foot,spine,
  pelvis,mouth,chin,left ear,right ear,left eyeball,right eyeball,nose,r upper arm,r forearm,
  l upper arm,l forearm,right hip,r upper leg,r lower leg,left hip,l upper leg,l lower leg,stomach,left pec,
  right pec,center 2,top right,top,top left,center,bottom left,bottom,bottom right,neck,root
  ```

- 如果指定了连接点，则回答与该点对应的单个 0（空）或 1（占用）。

- ```lsl
  例如 1 : @getattach=2222 => "011000011010000000000000100100000000101" => 头像佩戴附件 
  胸部、头骨、左脚和右脚、骨盆、左小腿和右小腿、HUD 左下和 HUD 右下。
  Ex 2 : @getattach:chest=2222 => "1" => 头像胸前穿了一些东西。
  ```

- 注意 ：第一个字符（none）始终为“0”，因此字符串中每个附加点的索引 完全等于 LSL 中相应的 ATTACH_* 宏。例如，字符串中的索引 9 是 ATTACH_BACK（表示spine）。请记住，索引从零开始。

### 强制查看器自动接受附加并获取控制权限请求：@acceptpermission=<rem/add>

- 当被阻止时，所有附加和获取控制权限请求都会自动拒绝，甚至不显示对话框。由于它造成了极大的烦恼，并且因为自 v1.16.1 以来锁定的对象会自动重新附加自身，因此该命令现已弃用，请勿使用它！

### 强制分离项目：@detachme=force (*)

- 该命令强制发出该命令的对象将其自身与化身分离。这是为了方便在调用 @clear 然后调用llDetachFromAvatar()时避免竞争条件，有时该对象可能会在清除其限制之前自行分离，使其在一段时间后自动重新附加。
- 使用此命令，可以发出@clear,detachme=force以确保首先执行 @clear。

## 服装和附件（共享文件夹）

### 允许/阻止穿着不属于#RLV文件夹的衣服和附件：@unsharedwear=<y/n>

- 当被阻止时，任何物体、衣服或身体部位都不能被穿戴，除非它是#RLV文件夹的一部分（即“共享”）。

### 允许/阻止移除不属于#RLV文件夹的衣服和附件：@unsharedunwear=<y/n>

- 当被阻止时，任何物体、衣服或身体部位都不能从化身中移除，除非它是#RLV文件夹的一部分（即“共享”）。

### 允许/阻止穿着#RLV文件夹中的衣服和附件：@sharedwear=<y/n>

- 当被阻止时，如果属于#RLV文件夹（即“共享”）的一部分，则不能穿戴任何物体、衣服或身体部位。

### 允许/阻止删除#RLV文件夹中的衣服和附件：@sharedunwear=<y/n>

- 当被阻止时，如果是 #RLV 文件夹的一部分（即“共享”），则任何物体、衣服或身体部位都不能从化身中移除。

### 获取头像清单中的共享文件夹列表：@getinv[:folder1/.../folderN]=<channel_number>

- 使查看器立即在脚本可以侦听的聊天频道号 <channel_number> 上自动应答名为“#RLV”的文件夹（如果存在）中包含的文件夹列表。
- 如果指定了文件夹，它将给出位于该路径而不是共享根目录的文件夹中包含的子文件夹列表（例如：@getinv:Restraints/Leather cuffs/Arms=2222）。
- 始终使用非零整数。请记住，普通观众根本不会回答任何问题，因此请在超时后删除侦听器。
- 答案是一个名称列表，以逗号（,）分隔。名称以点（.）开头的文件夹将被忽略。

### 获取头像库存中的共享文件夹列表，其中包含有关穿戴物品的信息：@getinvworn[:folder1/.../folderN]=<channel_number>

- 使查看器立即在脚本可以侦听的聊天频道号 <channel_number> 上自动应答名为“#RLV”的文件夹（如果存在）中包含的文件夹列表。

- 如果指定了文件夹，它将给出位于该路径而不是共享根目录的文件夹中包含的子文件夹列表（例如：@getinvworn:Restraints/Leather cuffs/Arms=2222）。

- 始终使用非零整数。请记住，普通观众根本不会回答任何问题，因此请在超时后删除侦听器。

- 答案是一个以逗号分隔的名称列表，每个名称后跟一个竖线（|）和两个数字。当前文件夹被放在第一个位置（与@getinv相反，显然它不显示当前文件夹），但没有名称，只有管道和两位数字。

- ```lsl
  Object : "@getinvworn:Restraints/Leather cuffs=2222"
  Viewer : "|02,Arms|30,Legs|10"
  ```

- 名称以点（“.”）开头的文件夹将被忽略。这两位数字的计算方法如下：

  - 第一个数字：相应文件夹中穿戴的物品的比例（包括无模组物品）。在这个例子中，“30”中的“3”表示“Arms”文件夹中的所有项目当前都已穿戴，而“10”中的“1”表示“Legs”文件夹中当前没有任何项目被穿戴，但有是可穿戴的物品”。
  - 第二位数字：相应文件夹内包含的所有文件夹中全局磨损的物品的比例。在此示例中，“02”中的“2”表示“某些物品佩戴在“皮革袖口”中包含的某些文件夹中。
  - 由 0 到 3 组成的数字具有以下含义：
    - 0：该文件夹中不存在任何项目
    - 1：该文件夹中存在一些物品，但没有一件物品被穿戴
    - 2：该文件夹中存在一些物品，其中一些已穿戴
    - 3：该文件夹中存在一些物品，并且所有物品均已穿戴

### 通过给出搜索条件来获取共享文件夹的路径：@findfolder:part1[&&...&&partN]=<channel_number>

- 使查看器自动回答第一个名称包含 <part1> 和 <part2> 以及 ... 和 <partN> 的共享文件夹的路径，紧邻脚本可以侦听的聊天频道号码 <channel_number>。
- 首先是深度搜索，注意分隔符“&&”，就像“and”一样。始终使用非零整数。
- 请记住，普通观众根本不会回答任何问题，因此请在超时后删除侦听器。
- 它不考虑禁用的文件夹（名称以点“.”开头的文件夹），也不考虑名称以波形符（~）开头的文件夹。答案是一个文件夹列表，用斜杠（/）分隔。

### 通过给出搜索条件来获取多个共享文件夹的路径：@findfolders:part1\[&&...&&partN\][;output_separator]=<channel_number>

- 使查看器立即在脚本可以监听的聊天频道号 <channel_number> 上自动回答名称包含 <part1> 和 <part2> 以及 ... 和 <partN> 的共享文件夹的路径。
- 如果指定了输出分隔符，则在有多个路径时将使用它来分隔路径，否则使用逗号（','）。首先进行深度搜索，注意输入分隔符，它是“&&”，就像“and”一样。
- 始终使用非零整数。请记住，普通观众根本不会回答任何问题，因此请在超时后删除侦听器。
- 它不考虑禁用的文件夹（名称以点“.”开头的文件夹），也不考虑名称以波形符（~）开头的文件夹。答案是一个文件夹列表，用斜杠（/）分隔。

### 强制附加共享文件夹中包含的项目：@attach:<folder1/.../folderN>=force (*)

#### @attachoverorreplace:<folder1/.../folderN>=force (*)

- 强制查看者附加每个对象并穿上位于指定路径（必须位于“#RLV”下）的文件夹内包含的每件衣服。对象名称 必须 包含其目标附加点的名称，否则它们将不会被附加。每个不可修改对象 必须 包含在一个文件夹内（每个文件夹一个对象），该名称包含其目标附加点的名称，因为它无法重命名。名称不能以点（.）开头，因为此类文件夹对脚本不可见。
- 附着点名称与“附着到”子菜单中包含的名称相同：“头骨”、“胸部”、“l 前臂”...
- 注 1：文件夹名称 可以 包含斜杠，并且会在可能的情况下优先选择（例如，如果发出“@attach:Restraints/cuffs=force”，则将在“cuffs”之前选择“Restraints/cuffs”文件夹）包含在“约束”父文件夹内的文件夹。
- 注2：如果文件夹名称以加号（+）开头，则此命令的作用与@attachover 完全相同。可以通过使用“RestrainedLoveStackWhenFolderBeginsWith”调试设置来更改此规则。
- 注意 ：此命令将来可能会更改，以恢复到其在版本 1.x 中的行为方式，即如果目标附着点已被占用，则永远不会添加对象，而是替换旧对象。当前的行为旨在通过 @attachoverorreplace 及其派生物来确保。
- 目前，@attachoverorreplace 是@attach 的同义词，但情况并非总是如此。换句话说，如果您想让脚本在附加新附件时始终替换现有附件，请使用@attach。
- 如果您希望脚本始终使附件堆叠，请使用@attachover。如果您想让用户通过文件夹名称进行选择（如上所述，默认情况下在名称前添加“+”号），请使用@attachover或replace。

### 强制附加共享文件夹中包含的项目，而不替换已穿戴的项目：@attachover:<folder1/.../folderN>=force (*)

- 该命令的工作方式与上面描述的 @attach 完全相同，只是它不会踢已经穿着的物体和衣服。

### 强制附加共享文件夹及其子文件夹中包含的项目：@attachall:<folder1/.../folderN>=force (*)

#### @attachalloverorreplace:<folder1/.../folderN>=force (*)

- 此命令的工作方式与上面描述的 @attach 完全相同，但也会附加子文件夹中包含的所有内容。

### 强制附加共享文件夹及其子文件夹中包含的项目，而不替换已穿戴的内容：@attachallover:<folder1/.../folderN>=force (*)

- 该命令的工作方式与上面描述的 @attachall 完全相同，只是它不会踢已经穿着的物体和衣服。

### 强制分离共享文件夹中包含的项目：@detach:<folder_name>=force (*)

- 强制观看者分离 <folder_name>（必须位于“#RLV”正下方）内的所有物体并脱下每件衣服。如果“@detach”与附着点名称（头骨、骨盆...见上文）一起使用，则它优先于这种分离方式，因为它是相同的命令。

### 递归地强制分离共享文件夹及其子文件夹中包含的项目：@detachall:<folder1/.../folderN>=force (*)

- 此命令的工作方式与上面描述的 @detach 完全相同，但也会分离子文件夹中包含的所有内容。

### 获取包含在某个点上穿戴的特定对象/服装的共享文件夹的路径：@getpath[:<attachpt> 或 <clothing_layer> 或 <uuid>]=<channel_number>

- 使查看器自动回答包含以下项目的共享文件夹的路径：
  - 如果未设置选项，则发出此命令
  - 附加在选项字段中提供的附加点上，例如：@getpath:spine=2222 =>“约束/项圈”
  - 穿在选项字段中提供的服装层上，例如：@getpath:pants=2222 =>“休闲/牛仔裤/紧身”
  - 将 uuid 指定为参数
- 始终使用非零整数。请记住，普通观众根本不会回答任何问题，因此请在超时后删除侦听器。
- 它不考虑禁用的文件夹（名称以点“.”开头的文件夹）。答案是一个文件夹列表，用斜杠（/）分隔。
- 请注意：由于版本 1.40.4 现已在主网格上运行，现在可以在同一附着点上佩戴多个物体。因此，该命令不再有多大意义，因为它只能响应一个文件夹，而多个对象可能属于多个文件夹。因此，最好使用@getpathnew，因为随着越来越多的用户切换到2.1及更高版本，@getpath将慢慢被弃用。

### 获取包含在某个点上穿着的对象/服装的共享文件夹的所有路径：@getpathnew[:<attachpt> 或 <clothing_layer> 或 <uuid>]=<channel_number>

- 添加此命令是为了替换 @getpath，因为在 2.1 中可以将多个对象佩戴在同一附着点上。

### 强制附加包含特定对象/服装的共享文件夹中包含的项目：@attachthis[:<attachpt> 或 <clothing_layer>]=force (*)

#### @attachthisoverorreplace[:<attachpt> 或 <clothing_layer>]=force (*)

- 此命令是 @getpath 后跟 @attach 命令的快捷方式（这可以节省侦听器和超时）。

### 强制附加共享文件夹中包含的项目，而不替换已穿戴的项目：@attachthisover[:<attachpt> 或 <clothing_layer>]=force (*)

- 该命令的工作方式与上面描述的 @attachthis 完全相同，只是它不会踢已经穿着的物体和衣服。

### 强制附加包含特定对象/服装及其子文件夹的共享文件夹中包含的项目 ：@attachallthis[:<attachpt> 或 <clothing_layer>]=force (*)

#### @attachallthisoverorreplace[:<attachpt> 或 <clothing_layer>]=force (*)

- 此命令是 @getpath 后跟 @attachall 命令的快捷方式（这可以节省侦听器和超时）。

### 强制附加共享文件夹中包含的项目，而不替换已穿戴的项目：@attachallthisover[:<attachpt> 或 <clothing_layer>]=force (*)

- 该命令的工作方式与上面描述的 @attachallthis 完全相同，只是它不会踢已经穿着的物体和衣服。

### 强制分离包含特定对象/服装的共享文件夹中包含的项目：@detachthis[:<attachpt> 或 <clothing_layer> 或 <uuid>]=force (*)

- 此命令是 @getpath 后跟 @detach 命令的快捷方式（这可以节省侦听器和超时）。

### 强制分离包含特定对象/服装及其子文件夹的共享文件夹中包含的项目：@detachallthis[:<attachpt> 或 <clothing_layer>]=force (*)

- 此命令是 @getpath 后跟 @detachall 命令的快捷方式（这可以节省侦听器和超时）。

### 允许/阻止脱下某些文件夹：@detachthis[:<layer>|<attachpt>|<path_to_folder>]=<y/n>

- 当被阻止时，如果满足以下任一条件，用户将无法脱下文件夹：
  - 未指定任何选项，并且该文件夹包含发出此限制的对象
  - 设置“图层”选项（衬衫、裤子...）并且文件夹包含在此图层上穿的一件衣服
  - 设置“attachpt”选项（l 前臂、脊柱...）并且文件夹包含佩戴在该点上的附件
  - 设置了“path_to_folder”选项并且文件夹对应于该位置
- 此外，此文件夹或这些文件夹无法重命名、移动、删除或修改。

### 允许/阻止删除某些文件夹及其子文件夹：@detachallthis[:<layer>|<attachpt>|<path_to_folder>]=<y/n>

- 这些命令的作用与 @detachthis 完全相同，但也递归地应用于其子文件夹。

### 允许/阻止佩戴某些文件夹：@attachthis:<layer>|<attachpt>|<path_to_folder>=<y/n>

- 当被阻止时，如果满足以下任一条件，用户将无法附加文件夹：
  - 设置“层”选项（衬衫、裤子...）并且文件夹包含一件要穿在该层上的衣服
  - 设置了“attachpt”选项（l 前臂、脊柱...）并且文件夹包含一个要戴在该点上的附件
  - 设置了“path_to_folder”选项并且文件夹对应于该位置
- 此外，此文件夹或这些文件夹无法重命名、移动、删除或修改。

### 允许/阻止佩戴某些文件夹及其子文件夹 ：@attachallthis[:<layer>|<attachpt>|<path_to_folder>]=<y/n>

- 这些命令的作用与@attachthis 完全相同，但也递归地应用于其子文件夹。

### 删除/添加 detachallthis 限制的例外情况，仅适用于一个文件夹：@detachthis_ except:<folder>=<rem/add>

- 添加例外时，用户可以删除指定文件夹中包含的项目。

### 对于一个文件夹及其子文件夹，删除/添加 detachallthis 限制的例外：@detachallthis_ except:<folder>=<rem/add>

- 添加例外时，用户可以删除指定文件夹或其任何子文件夹中包含的项目。

### 删除/添加 Attachallthis 限制的例外，仅适用于一个文件夹：@attachthis_ except:<folder>=<rem/add>

- 添加例外时，用户可以佩戴指定文件夹中包含的项目。

### 对于一个文件夹及其子文件夹，删除/添加 Attachallthis 限制的例外：@attachallthis_ except:<folder>=<rem/add>

- 添加例外时，用户可以佩戴指定文件夹或其任何子文件夹中包含的项目。

- 发出的限制 注意：这些例外仅适用于同一对象 ，您不能将此类例外置于另一个对象发出的限制中。

- 注意：

  - 查看器检查哪个例外或限制是文件夹层次结构中与用户尝试佩戴或删除的文件夹“最接近的父级”。如果最接近的是 @attach[all]this_except 或 @detach[all]this_except 异常，则可以分别磨损或删除该文件夹。
  - 如果最接近的是 @attach[all]this 或 @detach[all]this 限制，则无论有多少异常指向该文件夹的父文件夹，该文件夹都会被锁定。

- 例子 ：

  - ```lsl
    A script issues a @attachallthis:=n restriction, preventing the whole #RLV folder and its children from being attached. It also issues a
    @detachallthis:=n restriction, preventing the whole #RLV folder and its children from being removed as well.
    Therefore the #RLV folder is now completely frozen.
    ```

  - ```lsl
    However, the same object issues a @attachallthis:Jewelry/Gold=add exception, then a @detachallthis:Jewelry/Gold=add one, making the Jewelry/Gold
    folder available for wearing and removing.
    Finally, it issues a @attachallthis:Jewelry/Gold/Watch=n restriction followed by a @detachallthis:Jewelry/Gold/Watch=n restriction.
    As a result, the user can wear and remove only what is contained inside the Jewelry/Gold folder, except what is in Jewelry/Gold/Watch, and the
    rest is out of reach.
    ```

## 触摸

### 允许/阻止触摸距离头像 1.5 米以外的物体 ：@fartouch[:max_distance]=<y/n>

#### @touchfar[:max_distance]=<y/n>

- 当被阻止时，化身无法触摸/抓取 1.5 m 以外的物体，此命令使约束更加真实，因为化身几乎必须压在物体上才能单击它。
- 从 v2.9.20 开始，您可以指定自定义距离，如果发出多个此类命令，查看器将限制为所有命令中的最小距离。

### 允许/阻止触摸任何物体 ：@touchall=<y/n>

- 当被阻止时，化身无法触摸/抓住任何物体和附件。这不适用于 HUD。

### 允许/阻止触摸世界中的物体 ：@touchworld=<y/n>

- 当被阻止时，化身无法触摸/抓取世界中重新出现的物体，即附件和HUD。

### 删除/添加 touchworld 的例外：@touchworld:<UUID>=<rem/add>

- 添加例外时，用户可以特别触摸该对象。

### 允许/阻止特别触摸一个对象 ：@touchthis:<UUID>=<rem/add>

- 当被阻止时，化身无法触摸/抓取 UUID 与命令中指定的对象相对应的对象。

### 仅针对一个对象删除/添加触摸*的例外 ：@touchme=<rem/add>

- 当添加这样的例外时，用户可以特别触摸该对象。

### 允许/阻止触摸附件 ：@touchattach=<y/n>

- 当被阻止时，化身无法触摸附件（他们的和其他化身的），但这不适用于 HUD。

### 允许/阻止触摸附件 ：@touchattachself=<y/n>

- 当被阻止时，化身无法触摸他们自己的附件（他们的，但可以触摸其他人的），但这不适用于HUD。

### 允许/阻止触摸其他人的附件 ：@touchattachother=<y/n>

- 当被阻止时，化身无法触摸其他人的附件（但他们可以触摸自己的附件）。这不适用于 HUD。

### 允许/阻止触摸特定头像的附件 ：@touchattachother:<UUID>=<y/n>

- 当被阻止时，化身无法触摸指定化身的附件。

### 允许/阻止触摸 HUD : @touchhud[:<UUID>]=<y/n>

- 当被阻止时，化身无法触摸任何 HUD。如果与 UUID 一起发送，则将阻止头像仅触摸 UUID 指示的 HUD。

### 允许/阻止触摸对象或附件、编辑或重新调整 ：@interact=<y/n>

- 当被阻止时，化身无法触摸任何物体、附件或HUD，无法编辑或调整，也无法坐在物体上。

## 地点

### 允许/阻止查看世界地图 ：@showworldmap=<y/n>

- 当被阻止时，化身将无法查看世界地图，并且当限制生效时，如果它是打开的，它会关闭。

### 允许/阻止查看迷你地图 ：@showminimap=<y/n>

- 如果被阻止，头像将无法查看小地图，并且如果在限制生效时打开小地图，小地图也会关闭。

### 允许/阻止知道当前位置 ：@showloc=<y/n>

- 当被阻止时，用户无法知道他们在哪里：世界地图被隐藏，顶部菜单栏上的地块和区域名称被隐藏，他们无法创建地标，也无法购买土地，也无法查看他们刚刚拥有的土地传送后离开，也看不到“关于”框中的位置，甚至系统和对象消息如果包含区域名称和/或地块名称，也会被混淆。
- 然而， llOwnerSay 调用 不会 被混淆，因此雷达 仍然可以 工作（以及 RL 命令）。

## 名称标签和悬停文本

### 允许/阻止看到周围人的名字 ：@shownames[: except_uuid]=<y/n>

#### 安全方式：@shownames_sec[: except_uuid]=<y/n>

- 如果被阻止，用户将无法看到除了指定为参数的名称之外的任何名称（包括他们自己的名称）。
- 名称不会显示在屏幕上，聊天中的名称被“虚拟”名称替换，例如“某人”、“居民”，工具提示被隐藏，饼图菜单几乎无用，因此用户无法使用直接获取个人资料等。
- 安全方式：此特定命令仅接受从同一对象发出的异常，而不是接受来自任何对象的异常的非安全方式。

### 允许/阻止查看周围人的名字，不受审查 ：@shownametags=<y/n>

- 此限制与 @shownames 相同，只是它不会审查使用虚拟名称的聊天。然而，周围的头像不会显示他们的名字，雷达会被隐藏，右键单击周围的头像不会透露他们的名字，等等。

### 允许/阻止在“附近”窗口中看到人员 ：@shownearby=<y/n>

- 当被阻止时，“人物”窗口的“附近”选项卡中的名称将被隐藏，并在小地图本身中被审查。

### 允许/阻止查看所有悬停文本 ：@showhovertextall=<y/n>

- 当被阻止时，用户将无法阅读任何悬停文本（漂浮在某些 prims 上方的 2D 文本）。

### 允许/阻止看到一个悬停文本 ：@showhovertext:<UUID>=<y/n>

- 当被阻止时，用户将无法读取 id 为 UUID 的 prim 上方浮动的悬停文本。这样做是为了让另一个对象可以对一个对象发出限制（与 @detach 不同，它只能对自身设置此限制）。

### 允许/阻止在用户的 HUD 上看到悬停文本 ：@showhovertexthud=<y/n>

- 当被阻止时，用户无法读取其 HUD 对象上显示的任何悬停文本，但能够看到世界中的对象。

### 允许/阻止看到世界中的悬停文本 ：@showhovertextworld=<y/n>

- 当被阻止时，用户无法读取显示在其现实世界对象上的任何悬停文本，但能够在其 HUD 上看到这些悬停文本。

## 群组

### 强制代理更改活动组 ：@setgroup:<group_name>=force

- 强制代理将活动组更改为指定组。当然，他们必须已经是这个群体的成员。如果 <group_name> 为“none”，则代理将停用当前组并且根本不显示任何组标签。
- 注意：RLVa 1.4+ 支持 <group_key> 以及 <group_name>。

### 允许/阻止激活组 ：@setgroup=<y/n>

- 如果被阻止，用户将无法更改活动组。

### 获取活动组的名称 ：@getgroup=<channel_number>

- 使查看者立即在脚本可以收听的聊天频道号 <channel_number> 上自动回答当前活动组的名称。始终使用非零整数。
- 请记住，普通观众根本不会回答任何问题，因此请在超时后删除侦听器。如果当时没有活跃的群组，答案就是“无”。
- 请注意，无法获取组的 UUID，只能获取名称。

## 查看器控制

### 允许/阻止更改某些调试设置 ：@setdebug=<y/n>

- 如果被阻止，用户将无法更改某些查看器调试设置（高级 > 调试设置）。由于大多数调试设置要么无用，要么对用户体验至关重要，因此采用白名单方法：仅锁定少数调试设置，其他调试设置始终可用且不受影响。

### 强制更改调试设置 ：@setdebug_<setting>:<value>=force (*)

- 强制查看器更改特定调试设置并将其设置为 <值>。该命令实际上是许多子命令的包，这些子命令被重新组合在“@setdebug_...”下，例如“@setdebug_avatarsex:0=force”、“@setdebug_renderresolutiondivisor:64=force”等。
- 可以更改的调试设置有：
  - AvatarSex（0：女性，1：男性）：创建时头像的性别。
  - RenderResolutionDivisor (1 -> ...) ：屏幕的“模糊度”。结合巧妙的@setenv命令，可以模拟出不错的效果。
    - 注意：renderresolutiondivisor 是 Windlight 独有的选项（必须在图形首选项中启用基本着色器），因此在 v1.19.0.5 或更早版本的查看器中不可用。

### 获取调试设置的值 ：@getdebug_<setting>=<channel_number>

- 使查看器立即在脚本可以侦听的聊天频道号 <channel_number> 上自动回答调试设置的值。始终使用非零整数。
- 请记住，普通观众根本不会回答任何问题，因此请在超时后删除侦听器。
- 答案是使用匹配 @setdebug 命令的 <setting> 部分或手动设置的值。
- 可以更改的调试设置有：
  - AvatarSex（0：女性，1：男性）：创建时头像的性别。
  - RenderResolutionDivisor (1 -> ...) ：屏幕的“模糊度”。结合巧妙的@setenv命令，可以模拟出不错的效果。
    - 注意：enderresolutiondivisor 是 Windlight 独有的选项（必须在图形首选项中启用基本着色器），因此在 v1.19.0.5 或更早版本的查看器中不可用。
  - RestrainedLoveForbidGiveToRLV (0/1) ：设置为 1 时，RLV 不会将临时文件夹（名称以“~”开头的文件夹）直接放入“#RLV”文件夹中，而是放在“Inventory”下。
  - RestrainedLoveNoSetEnv (0/1) ：当设置为 1 时，@setenv 命令将被忽略。
  - WindLightUseAtmosShaders (0/1)：设置为 1 时，启用 Windlight 大气着色器。

### 允许/阻止更改环境设置 ：@setenv=<y/n>

- 当被阻止时，用户无法更改查看器环境设置（世界>环境设置>日出/中午/日落/午夜/恢复到区域默认/环境编辑器均被锁定）。

### 强制更改环境设置 ：@setenv_<setting>:<value>=force (*)

- 强制查看者更改特定环境设置（一天中的时间或 Windlight）并将其设置为 <值>。该命令实际上是许多子命令的包，这些子命令重新组合在“@setenv_...”下，例如“@setenv_daytime:0.5=force”、“@setenv_bluehorizonr:0.21=force”等。

- 如果设置了相应的限制（此处为“@setenv”），则此命令（与任何其他“force”命令一样）将被默默丢弃，但在这种情况下，如果更改是从创建它的对象发出的，则该限制将被忽略。换句话说，项圈可以限制环境变化，但又会自行强制改变，而另一个物体则无法做到这一点，直到项圈解除限制。

- 尽管为每个值指定了一个范围，但在查看器中不会进行任何检查，因此脚本可以执行 UI 无法执行的操作，以获得有趣的效果。不过，使用风险自负。此处指示的范围仅仅是环境编辑器滑块上可用的范围，仅供参考。

- 每个特定子命令的工作方式如下（选择的名称尽可能接近查看器的 Windlight 面板）：

- | @setenv_XXX:<value>=force | <value> range   | Sets...                                                      |
  | ------------------------- | --------------- | ------------------------------------------------------------ |
  | daytime                   | 0.0-1.0  and <0 | 一天中的时间（日出：0.25，中午：0.567，日落：0.75，午夜：0.0，设置回区域默认值：<0）。 **注意，重置所有其他 Windlight 参数** （注意：自 v2.9.27 起大部分已弃用，请参阅下面的注释  2） |
  | preset                    | String          | 预设环境，例如 Gelatto、Foggy。 **注意，加载预设对观看者来说很重，可能会在短时间内减慢速度，不要每秒都这样做** （注意：自 v2.9.27 以来发生了很大变化，请参阅下面的注释 3） |
  | asset                     | String          | “preset”的同义词                                             |
  | reset                     | -               | “daytime:-1”的同义词                                         |
  | ambientr                  | 0.0-1.0         | 环境光，红色通道                                             |
  | ambientg                  | 0.0-1.0         | 环境光、绿色通道                                             |
  | ambientb                  | 0.0-1.0         | 环境光，蓝色通道                                             |
  | ambienti                  | 0.0-1.0         | 环境光、强度                                                 |
  | ambient                   | 0-1;0-1;0-1     | 矢量格式的环境光（R；G；B）                                  |
  | bluedensityr              | 0.0-1.0         | 蓝色密度，红色通道                                           |
  | bluedensityg              | 0.0-1.0         | 蓝色密度，绿色通道                                           |
  | bluedensityb              | 0.0-1.0         | 蓝色密度，蓝色通道                                           |
  | bluedensityi              | 0.0-1.0         | 蓝色密度、强度                                               |
  | bluedensity               | 0-1;0-1;0-1     | 矢量格式的蓝色密度（R；G；B）                                |
  | bluehorizonr              | 0.0-1.0         | 蓝色地平线，红色通道                                         |
  | bluehorizong              | 0.0-1.0         | 蓝色地平线、绿色通道                                         |
  | bluehorizonb              | 0.0-1.0         | 蓝色地平线、蓝色通道                                         |
  | bluehorizoni              | 0.0-1.0         | 蓝色地平线，强度                                             |
  | bluehorizon               | 0-1;0-1;0-1     | 矢量格式的蓝色地平线 (R;G;B)                                 |
  | cloudcolorr               | 0.0-1.0         | 云色，红色通道                                               |
  | cloudcolorg               | 0.0-1.0         | 云色、绿色通道                                               |
  | cloudcolorb               | 0.0-1.0         | 云色，蓝色通道                                               |
  | cloudcolori               | 0.0-1.0         | 云的颜色、强度                                               |
  | cloudcolor                | 0-1;0-1;0-1     | 矢量格式的云颜色（R；G；B）                                  |
  | cloudcoverage             | 0.0-1.0         | 云覆盖                                                       |
  | cloudx                    | 0.0-1.0         | 云偏移 X                                                     |
  | cloudy                    | 0.0-1.0         | 云偏移 Y                                                     |
  | cloudd                    | 0.0-1.0         | 云密度                                                       |
  | cloud                     | 0-1;0-1;0-1     | 矢量格式的云偏移和密度 (X;Y;D)                               |
  | clouddetailx              | 0.0-1.0         | 云细节X                                                      |
  | clouddetaily              | 0.0-1.0         | 云细节 Y                                                     |
  | clouddetaild              | 0.0-1.0         | 云细节密度                                                   |
  | clouddetail               | 0-1;0-1;0-1     | 矢量格式的云细节 (X;Y;D)                                     |
  | cloudimage                | UUID            | 云图                                                         |
  | cloudscale                | 0.0-1.0         | 云规模                                                       |
  | cloudscrollx              | 0.0-1.0         | 云卷轴X                                                      |
  | cloudscrolly              | 0.0-1.0         | 云卷轴Y                                                      |
  | cloudscroll               | 0-1;0-1         | 矢量格式的云滚动 (X;Y)                                       |
  | cloudvariance             | 0.0-1.0         | 云方差                                                       |
  | densitymultiplier         | 0.0-0.9         | 雾的密度乘数                                                 |
  | distancemultiplier        | 0.0-100.0       | 雾的距离倍数                                                 |
  | dropletradius             | 0.0-1.0         | 液滴半径                                                     |
  | eastangle                 | 0.0-1.0         | 东边位置，0.0为正常                                          |
  | icelevel                  | 0.0-1.0         | 冰位                                                         |
  | hazedensity               | 0.0-1.0         | 雾霾的密度                                                   |
  | hazehorizon               | 0.0-1.0         | 地平线上的阴霾                                               |
  | maxaltitude               | 0.0-4000.0      | 雾的最大高度                                                 |
  | moisturelevel             | 0.0-1.0         | 水分含量                                                     |
  | moonazim                  | 0.0-PI*2        | 以弧度为单位的月球方位角（0 为东，逆时针方向）。             |
  | moonnbrightness           | 0.0-1.0         | 月亮亮度                                                     |
  | moonelev                  | -PI/2-PI/2      | 以弧度为单位的月球仰角（0 为地平线）。                       |
  | moonimage                 | UUID            | 月亮图像                                                     |
  | moonscale                 | 0.0-1.0         | 月亮刻度                                                     |
  | scenegamma                | 0.0-10.0        | 整体gamma，1.0为正常                                         |
  | starbrightness            | 0.0-2.0         | 星星的亮度                                                   |
  | sunglowfocus              | 0.0-0.5         | 太阳光的焦点                                                 |
  | sunazim                   | 0.0-PI*2        | 太阳方位角（以弧度表示）（0 为东，逆时针方向）。             |
  | sunelev                   | -PI/2-PI/2      | 太阳仰角（以弧度为单位）（0 为地平线）。                     |
  | sunglowsize               | 1.0-2.0         | 太阳光辉的大小                                               |
  | sunimage                  | UUID            | 太阳图片                                                     |
  | sunmooncolorr             | 0.0-1.0         | 太阳和月亮，红色通道                                         |
  | sunmooncolorg             | 0.0-1.0         | 日月、绿色通道                                               |
  | sunmooncolorb             | 0.0-1.0         | 太阳和月亮，蓝色通道                                         |
  | sunmooncolori             | 0.0-1.0         | 太阳和月亮，强度                                             |
  | sunmooncolor              | 0-1;0-1;0-1     | 矢量格式的太阳和月亮（R；G；B）                              |
  | sunmoonposition           | 0.0-1.0         | 太阳/月亮的位置，与“白天”不同， 加载预设后用它来设置明显的阳光 |
  | sunscale                  | 0.0-1.0         | 太阳秤                                                       |

- 注意：从上述设置来看，实现 RestrainedLove v1.14 及更高版本的 v1.19.0（或更早版本）观看者仅支持“daytime”观看者。其他设置将被忽略。这是因为这些查看器没有实现 Windlight 渲染器。

- 注 2：自 RLV v2.9.27（包括 EEP 更改的第一个版本）开始，@getenv_daytime 已被废弃，如果太阳低于地平线则返回 0，如果太阳高于地平线则返回 1，如果当前设置为 -1设置为区域设置。

- 注 3：自 RLV v2.9.27 起，@setenv_preset 能够应用清单中包含的资产中的预设（它们必须位于环境文件夹中），因为环境设置已成为 EEP 中的清单资产。这不会改变命令的写入方式或响应的形状，只是更改和读取数据的位置。

- 注 4：自 RLV v2.9.29 起，以下命令是同义词：

  - asset = preset

  - suntexture = sunimage

  - sunazimuth = sunazim

  - sunelevation = sunelev

  - moontexture = moonimage

  - moonazimuth = moonazim

  - moonelevation = moonelev

  - sunlightcolor = sunmooncolor


### 获取环境设置的值 ：@getenv_<setting>=<channel_number>

- 使查看者立即在脚本可以收听的聊天频道号 <channel_number> 上自动回答环境设置的值。始终使用非零整数。
- 请记住，普通观众根本不会回答任何问题，因此请在超时后删除侦听器。
- 答案是使用匹配 @setenv 命令的 <setting> 部分或手动设置的值。有关设置列表，请参阅上表。
- 注意：实现 RestrainedLove v1.15 及更高版本的 v1.19.0（或更早版本，即非 Windlight）查看器仅支持 @getenv_daytime。

## 非官方命令

某些观看者使用基于 RestrainedLove API 的不同限制系统，其中包括许多额外的命令。这些额外的命令 不是 RestrainedLove API 规范的一部分，但为了方便起见记录在此处。不应依赖这些命令，因为只有某些查看者才能处理它们。

### 允许/阻止禁用自动离开/AFK 指示器 ：@allowidle=<y/n>

- 如果被阻止，则无法禁用在头像不活动一段时间后自动激活离开状态指示器的功能。如果空闲超时持续时间已设置为零，则将使用默认超时 30 分钟。

## 脚注

(*) 如果相应的限制阻止用户这样做，则静默丢弃。这是故意的。

例如：如果对象不可分离，则强制分离将不起作用。如果阻止用户脱衣服，则强制脱衣服将不起作用。

## 关于 sendchat 等全局行为的重要说明

此类行为是全局的，这意味着它们不依赖于特定对象。但是，它们是由具有可更改的设置 UUID ，这些行为将被存储多次 的对象触发的，并且多个对象可以添加相同的行为，由于UUID 不同 。

这有一个很好的副作用：当佩戴两个阻止聊天的锁定设备时，必须将它们解锁才能再次聊天。但它也有一个令人讨厌的副作用：如果该项目更改了 UUID （例如，它被取消并再次重新调整），并且它不允许事先聊天，那么用户将不得不等待一小会儿，因为规则仍然存在“孤立”（其 UUID 已失效），直到 垃圾收集器 启动。

请注意：自 1.16.1 起，任何以任何方式启动的锁定对象（例如 llAttachToAvatar）将在几秒钟后由查看器自动重新附加。这意味着在分离时调用@clear实际上会解锁该对象，该对象在重新附加后必须重新锁定。因此，与 1.16.1 之前的版本相比，不再建议在分离时调用 @clear。

## 共享文件夹

从 v1.11 开始，查看者可以在世界中使用脚本“共享”您的一些项目，以便让它们强制您附加、分离和列出您共享的内容。

“分享”并不意味着它们会被其他人拿走（无论如何，有些物品可能是不可转让的），而只是意味着它们可以通过使用脚本强迫您随意佩戴/脱下它们你的限制包含。它们将保留在您的库存中。事实上，这个功能最好命名为“公开文件夹”。

为此：

- 直接在“我的库存”下创建一个名为“#RLV”（不带引号）的文件夹（右键单击“我的库存”，选择“新建文件夹”）。我们将此文件夹称为“共享根”。
- 将包含约束或其他附件的文件夹直接移至此新文件夹中。
- 穿上那个文件夹的内容，就是这样！

所以它看起来像这样：

```lsl
My Inventory
|- #RLV
|  |- cuffs
|  |  |- left cuff (l forearm)   (no copy)
|  |  \- right cuff (r forearm)   (no copy)
|  \- gag
|     \- gag (mouth)   (no copy)
|- Animations
|- Body Parts
.
.
.
```

例如：如果您拥有一套 RR Straps 并希望共享它们，只需将文件夹“Straps BOXED”移动到共享根目录下即可。

要么佩戴您刚刚移动的文件夹中的所有项目（一次一个文件夹！），要么自己重命名您的项目，以便每个项目名称都包含目标附着点的名称。例如：“左袖口（l前臂）”、“右脚踝袖口（r小腿）”。请注意，不可修改的项目共享起来有点复杂，因为您或查看者都无法重命名它们。下面详细介绍一下。

附着点名称与您在库存的“附着到”菜单中找到的名称相同，并且不区分大小写（例如：“胸部”、“头骨”、“胃”、“左耳”、“r”）上臂”...）。如果您在没有先重命名该物品的情况下佩戴该物品，它会自动重命名，但前提是它位于共享文件夹中，并且已不包含任何附着点名称，并且是 mod。如果您想将其佩戴在另一个连接点上，则需要先手动对其进行重命名。

衣服的处理方式完全相同（事实上，它们甚至可以放入一组约束装置的文件夹中，并按照相同的命令穿戴）。例如，鞋子是混合服装的一个很好的例子：一些附件和鞋子层。衣服在穿着时不会自动重命名，因为它们的类型决定了它们的穿着位置（裙子、夹克、汗衫......）。

如何共享未修改的项目： 如您所知，无模组物品无法重命名，因此技术有点复杂。在服装文件夹内创建一个子文件夹（例如上例中的“cuffs”），在其中放入一个不可修改的项目。佩戴该物品时，您会看到文件夹本身被重命名（这就是为什么您不能在其中放入多个物品）。因此，如果你的服装包含多个 no-mod 对象，则需要创建尽可能多的文件夹并将 no-mod 对象放入其中，每个文件夹一个。

未修改鞋子的示例：

```lsl
My Inventory
|- #RLV
|  \- shoes
|     |- left shoe (left foot)
|     |  \- left shoe   (no modify) (no transfer)  <-- no-mod object
|     |- right shoe (right foot)
|     |  \- right shoe   (no modify) (no transfer) <-- no-mod object
|     \- shoe base   (no modify) (no transfer)     <-- this is not an object
|- Animations
|- Body Parts
.
.
.
```

陷阱：

- 不要在共享根目录下的文件夹名称中添加逗号（','），否则列表会混乱。
- 不要忘记重命名共享文件夹中的项目（或者至少佩戴这些项目一次以使它们自动重命名），否则强制附加命令将看起来根本不执行任何操作。
- 避免共享根目录中包含许多文件夹，因为某些脚本可能依赖于通过 @getinv 命令获取的列表，并且聊天消息的长度限制为 1023 个字符。明智地选择并使用简称。但是，如果每个文件夹名称平均有 9 个字符，则预计会有大约 100 个可用文件夹。
- 请记住将不可修改的项目放入子文件夹中，每个子文件夹中一个，以便查看者可以使用它们的名称来找出将它们附加到的位置。它们不能像修改项目一样共享，因为它们不能重命名，并且服装文件夹本身也不会被重命名（因为它包含多个项目）。

### ***接受通过 llGiveInventoryList() 给定的子文件夹到共享文件夹中*** ：

从 RestrainedLove v1.16.2 开始，您可以向受害者提供一个项目列表，并将它们存储为 #RLV 文件夹内的子文件夹（从而允许您稍后 @attach 给定的项目）。

在脚本中发出 llGiveInventoryList(victim_id, "#RLV/~subfolder_name", list_of_stuff) 命令会使标准的保留/丢弃/静音对话框出现在受害者的查看器中（密钥为victim_id 的头像）。

如果受害者接受该提议，则 list_of_stuff 项目将被放入 #RLV 文件夹的新子文件夹中。该子文件夹的名称为“~subfolder_name”（脚本编写者有责任使用唯一的子文件夹名称：如果该名称与现有子文件夹相同，则两个同名的子文件夹将出现在#RLV 文件夹）。

请注意，波浪号字符*必须*用作子文件夹名称的第一个字符（这样受害者就可以轻松地发现以这种方式提供给他们的任何子文件夹，并且这样的子文件夹名称出现在 #RLV 文件夹的最后）。

另请注意，用户可以禁用此功能（通过将 RestrainedLoveForbidGiveToRLV 调试设置设置为 TRUE）：在这种情况下，给定的项目将放入清单根目录中名为“#RLV/~subfolder_name”的文件夹中，而不是放入#RLV 文件夹内。

由于用户可能会拒绝该提议或在其查看器中禁用该功能，并且由于 SL 可能需要相当长的时间才能在延迟的日子里执行对象的实际传输，因此您必须检查给定的文件夹是否存在（使用 @getinv )，然后尝试@attach给定的对象。

## 供你参考

以下是它的内部工作原理，以便更好地理解您可能遇到的问题：

- 每个命令都被解析为 行为 （例如：“remoutfit”）、 选项 （例如：“衬衫”）和 参数 （例如：“force”），并且来自 UUID （发出对象的唯一标识符）。
- 有两种类型的命令： 一次性 命令（Param 为“force”的命令和 Param 为数字（例如“version”调用的通道号）和 规则命令 （Param 为“y”、“ n”、“添加”或“rem”）。 “clear”很特殊，但可以被视为一次性命令。
- 当命令采用频道编号时，该编号可以严格为正数，也可以（对于 RestrainedLove v1.23a (@versionnum = 1230001) 及更高版本）严格为负数。不允许使用通道 0。请注意，RestrainedLove 在负面频道上最多可以发送 255 个字符，而在正面频道上最多可以发送 1023 个字符。负通道对于防止用户作弊很有用，例如在请求 @versionnum 时（因为用户可以使用非 RestrainedLove 查看器，并通过欺骗版本命令的回复，使 RestrainedLove 设备相信它们在 RestrainedLove 查看器中运行在积极的渠道上，他们不能在消极的渠道上做到这一点）。正通道最适合用于可能返回较大回复字符串的命令（例如@getpath）。
- 参数“n”和“add”完全相同 ， 并且处理 方式完全相同 ，它们只是 同义词 。 “y”和“rem”也是如此。唯一的目的是为了清楚起见，区分脚本中的规则（“sendchannel=n”）和异常（“sendchannel:8=add”）。
- 规则存储在一个表中，该表将 发射器的UUID 链接到规则本身。 它们 添加 当接收到“n”/“add”参数时。 ，并在接收“y”/“rem”参数时删除它们。

如果 UUID1 是项圈， UUID2 是堵嘴：

UUID1 => 分离、tploc、tplm、tplure、sittp

UUID2 => 分离、sendim、sendim:(密钥持有者)

这两条规则意味着用户只能向其密钥持有者发送 IM，并且根本不能发送 TP。这两个项目是不可拆卸的。现在，如果项圈发送“@sendim=n”，则表格变为：

UUID1 => 分离、tploc、tplm、tplure、sittp、sendim

UUID2 => 分离、sendim、sendim:(密钥持有者)

如果它第二次发送“@sendim=n”，则不会发生任何变化，因为在添加它之前会检查它的存在。如果堵头被解锁并分离，它要么发送“@clear”，要么垃圾收集器启动，以便链接到 UUID2 的 规则消失。然而，化身仍然无法向其密钥持有者发送即时消息，因为异常也消失了。这是因为链接到一个对象的规则不会与链接到另一对象的规则冲突。

- 另一方面，一次性命令是即时执行的并且不存储。
- 登录时，头像在一段时间内保持不可操作（无法聊天、无法移动），而用户会看到进度条。然而，磨损的脚本对象 重新审视 同时 并开始发送规则和命令，然后查看者才能执行它们。因此，它将它们存储在缓冲区中，并且仅当用户获得控制权时（当进度条消失时）才执行它们。
- 规则 UUID 的 查看器定期（每 N 秒）检查其所有规则并删除链接到不再存在的 （“垃圾收集器”）。这意味着 其他地方，由未佩戴的 一旦化身 传送到 拥有的物体发出的规则将被丢弃。

# RLV Relay协议

## 观众

本文档适用于想要创建或修改 **虚拟世界对象** 的功能的 [以使用其他人的RestrainedLove 查看器 ](http://realrestraint.blogspot.com/)人员，这些对象通常是 **笼子** 和 **家具** ，根据定义，这些通常不属于该人。

## 介绍

仅RestrainedLove观察器执行通过llOwnerSay () 消息发出的命令。因此，为了向使用该观察器但并非其所有者的用户发出命令，该用户必须佩戴一个附件，该附件可在经过安全检查后转发命令。

## 为什么是这个规格？

许多笼子和家具创建者都对使用其功能感兴趣，例如坐下、装备、TP 等。这些物品可能在公共场所找到，也可能属于朋友……但由于它们通常不属于用户，因此中继必须实施一些基本的安全措施，以避免恶意破坏 。最重要的是，用户不希望在前往下一件家具时被迫切换到另一个中继。

本规范的目的是：制定通用规则，使所有实现该规范的中继器都能与所有实现该规范的家具兼容。如果没有这样的规范，一个笼子/家具就只能与专门为其设计的中继器通信，仅此而已，最终导致创建者无法使用，因为人们更愿意使用标准对象，而不是专有的封闭对象。

## 基本原理

以下是一个示例用例：

1. 用户佩戴接力
2. 用户进入公共区域的笼子
3. Cage 在已知的私人频道上发送聊天消息（例如“@tploc=n”）
4. Relay 收到消息，决定向用户重复命令，并使用 [llOwnerSay ](https://wiki.secondlife.com/wiki/LlOwnerSay)（“@tploc=n”）阻止他们从地图传送的能力；
5. 一段时间后，用户被允许离开，笼子发出“!release”命令

如果没有中继，笼子就无法阻止用户传送，因为它不属于用户。

## 要求

以下是接力赛的非正式要求（正式要求如下）。

### 安全

如果中继监听的通道中没有实施安全措施，任何通过该通道发送命令的对象都可能对用户造成伤害。例如，可以rez一个对象，该对象通过聊天通道发送“@remoutfit=force”命令，以强制虚拟形象在所有人面前脱光衣服，且不会发出任何警告。当然没人希望这样，所以需要基本的安全措施。

### 用户友好性

安全通常意味着控制（访问列表、开关、权限……），因此必须赋予用户一些基本控制权，以确定允许哪些类型的对象发出命令。

### 多功能性

有些用户喜欢佩戴专用附件，可以随时取下；有些用户则需要将中继锁定在身上，这样他们就无法取下；还有些用户只需要脚本……在决定中继的权限时，牢记这些差异很重要。但是，选择最适合自己需求的中继是用户的责任。

### 许可

根据中继的复杂程度和支持程度，创建者可以免费提供（开放/闭源）或出售它，只要它满足所有正式要求。

## 常见问题

### 实现这样的规范有多难？

这取决于你做什么。家具/笼子制造商会发现这很容易，因为它只需要通过聊天频道发送命令并获得反馈。中继制造商会发现这更难，但另一方面，这取决于他们希望提供的安全性和用户友好性水平。但不要误会，中继几乎完成了所有的工作（连同观众），因为家具和笼子的种类比中继多得多。

### 为什么其他人需要写这样的中继？

你不能自己写并出版吗？

当然可以，在 [参考实现 ](https://wiki.secondlife.com/wiki/LSL_Protocol/Restrained_Love_Relay/Reference_Implementation)中甚至有一个基本中继的工作代码。但是：

- 该协议可能会得到改进，因为没有人预见到未来
- 单一的物体无法满足所有人的需求
- 在所有情况下，它都必须实现完美的安全性和完美的用户友好性
- 当然，它必须有完美的脚本，不能有任何错误

安全性和用户友好性是这里的关键部分。有些用户希望避免受到 [恶意破坏 ](https://wiki.secondlife.com/wiki/Griefing)，有些用户则希望拥有良好的用户界面，有些用户则喜欢许多功能，有些用户则希望将脚本移到其他地方……每个人都有自己的喜好，因此不可能存在一刀切的中继。

## 协议

虚拟世界中的物体通过一个通道（每个中继器和家具都共用）发送聊天消息，中继器可能会确认或不确认。如果该消息是正确的命令并且通过了中继器实施的任何安全检查，则中继器会将其重复为 [llOwnerSay ](https://wiki.secondlife.com/wiki/LlOwnerSay)()。

当会话结束时（可能经过多次重新登录），对象将清除对用户施加的所有限制。

### 例子

```lsl
当其他人触碰物品时，强制对方坐在物品上并禁止站立
collision_start(integer num){
    llSay(-1812221819,"CmdCollision,"+(string)llDetectedKey(0)+",@sit:"+(string)llGetKey()+"=force|@unsit=n");
}
// 指令结构：llSay(-1812221819,"识别名,对方uuid,@RLV指令1|@RLV指令2|...");
// CmdCollision：此为识别名，可使用任意英文字母和数字
// llDetectedKey(0)：获取触碰物品角色的uuid
// llGetKey()：获取此物品的uuid
```

以下是头像（id“9213...”）与世界对象（id“7adf...”）之间交换消息的基本示例：

```
对象：CmdTest,9213f69a-ed7d-4a70-907a-7dba88c8831a,@tploc=n
中继执行llOwnerSay("@tploc=n");
中继：CmdTest,7adf6218-ab26-8566-8387-660133840794,@tploc=n,ok
 
对象：BunchoCommands,9213f69a-ed7d-4a70-907a-7dba88c8831a,@tploc=n|@tplm=n|@tplure=n|@remoutfit:shoes=force
中继执行llOwnerSay("@tploc=n");
中继执行llOwnerSay("@tplm=n");
中继执行llOwnerSay("@tplure=n");
中继：BunchoCommands,7adf6218-ab26-8566-8387-660133840794,@tploc=n,ok
中继：BunchoCommands,7adf6218-ab26-8566-8387-660133840794,@tplm=n,ok
中继：BunchoCommands,7adf6218-ab26-8566-8387-660133840794,@tplure=n,ok
中继：BunchoCommands,7adf6218-ab26-8566-8387-660133840794,@remoutfit:shoes=force,ko
 
重新登录后：
中继：ping,7adf6218-ab26-8566-8387-660133840794,ping,ping
对象：ping,9213f69a-ed7d-4a70-907a-7dba88c8831a,!pong（使用 llGetOwnerKey(id)找到的 UUID，其中 id 是侦听事件的发送方参数）
 
```

## 形式要求

### 对中继和虚拟世界对象的共同要求

- 中继站和虚拟世界物体使用的聊天频道都是 **-1812221819** 。这是“RLVRS”（“RestrainedLove Viewer Relay Script”）从字母翻译成数字。

- 频道上的消息以伪 [巴科斯范式 ](http://en.wikipedia.org/wiki/Backus-Naur_form)描述如下：

- - **从世界对象到中继的消息（3 个令牌）：**
    - *消息* ::= <cmd_name> **,** <user_uuid> **,** <list_of_commands>
    - *list_of_commands* ::= <command>[ **|** <list_of_commands>] （list_of_commands 是 *小写*）
    - *命令* ::= <rl_command> 或 <meta-command>
    - *rl_command* ::= **@behav** [ **:** 选项][ **=** 参数]
    - *元命令* ::= **!version** 或 **!release** 或 **!pong** 或 **!implversion** 或 **!handover/** <hand-over 参数> 或 **!who/** <who 参数>

- - **从中继到世界内对象的消息（4 个令牌）：**
    - *message* ::= <cmd_name> **,** <object_uuid> **,** \<command\> **,** \<reply\> （cmd_name 等于传入消息中的那个）
    - *回复* ::= **ok** 或 **ko** 或 **ping** 或 <协议版本> 或 <实现版本>
    - *protocol_version* 的版本 *::= 整数（它是规范* ，而不是脚本的版本）

- “!release”元命令的效果是消除发送它的对象发出的所有限制。
- “!version”元命令的作用是发送 Relay 实现的协议版本。见下文。
- 中继向对象发送“ping”消息的作用是检查后者是否仍然可用。如果不可用，则释放用户以避免出现孤立规则。
- 请注意，确认不适用于命令列表，而仅适用于一个命令。因此，N 个命令列表会返回 N 条确认消息（最多）。

**用简单的英语来说：**

- <cmd_name> 是命令的名称，由对象决定。它将用于找出哪个命令已被确认，因此必须 **由中继准确** 重复该命令（不改变其大小写）。<cmd_name> 标记自由选择的一个例外是“ping”保留名称，见下文。
- <user_uuid> 是拥有 Relay**的头像**的UUID。
- <object_uuid> 是**世界内对象**的UUID。请注意，我们永远不需要UUID ，因为它通常是一个附件，每次重新登录后其 ID 都容易发生变化。
- <list_of_commands> 是 RLV 命令列表，以竖线（“|”）分隔。它可以是单个命令（表示不存在竖线）。
- <command> 可以是常规 RLV 命令 (@behav:option=param)，也可以是针对 Relay 本身的元命令 (!version、!release 和 !pong)
- 此处的命令由竖线（“|”）分隔，但如果必须将它们发送到同一个 [llOwnerSay ](https://wiki.secondlife.com/wiki/LlOwnerSay)中，则必须用逗号（“,”）分隔，并且整个消息的开头只有一个“ **@”** 符号。这是故意的，以强制 Relay 解析它们并逐一检查它们，以及方便解析来自虚拟世界对象的整个消息。
- 在中继频道上监听的每个人都必须拥有足够的脚本内存来处理限制为 1,000 个字符（2,000 字节 + 处理）的完整聊天消息。

#### “!release” 元命令

- 此元命令旨在使中继清除与发出此命令的对象相关的所有限制。最好使用它，而不是发出“反命令”来逐一解除所有限制，而不会忘记任何限制。
- 如果中继取消活动会话（例如由于调用了安全词），则它必须发送！release,ok 消息。

#### “!version” 元命令

- 当收到此元命令时，中继必须发送一个特殊的确认，其中包含 *协议* 它所实现的 **的版本，共4 位数字** 。此数字必须是一个整数，等于此规范的版本，写在此页标题后面，乘以 1000。例如，“1.120”将转换为“1120”。这使得比较版本变得更容易，而不必担心将浮点数转换为字符串再转换为浮点数会丢失信息。
- 不要将 *协议* 的版本（@version） *的版本与查看器* 的版本 *或脚本* （！implversion）混淆。

#### “ping” 中继消息和“!pong” 对象元命令

- 登录时，中继将重新应用所有存储的限制，但只有当虚拟世界对象仍然存在且可供使用时，这才有意义。当主要用户离线时，它可能已被重置、崩溃或被其他人使用。因此，让中继应用限制是没有意义的。这就是为什么中继必须询问对象是否仍然存在且可用，如果没有及时收到适当的答案，那么它必须解除之前发布的所有限制，以便重新开始。请注意，“ping”是一个简单的词（与“ok”和“ko”保持一致），而“!pong”是一个元命令。

中继消息必须是“ping,<object_uuid>,ping,ping”，而对象消息必须是“ping,<user_uuid>,!pong”。这允许对象使用静态过滤器保持监听器打开，以减少延迟。<user_uuid> 可以通过 [llGetOwnerKey ](https://wiki.secondlife.com/wiki/LlGetOwnerKey)() 调用来检索。

### 其他元命令

以下元命令被视为“可选”命令，继电器无需实现这些命令即可被视为符合 RLV 标准。它们主要与特定家具需要查询的特定继电器的具体实现相关。家具不得依赖任何这些命令的实现来工作。

##### “!implversion” 元命令

- 中继 *实现* 应该用字符串来标识自己。
- 与 !version 类似，不同之处在于 !implversion 不是关于 *协议* 的，而是关于协议的实现的，并且可能包含一个字符串
- 此版本字符串不用于自动检查，但有助于调试问题
- 将其视为特定中继的签名
- 字符串不得包含任何“,”或“!”字符

### 已弃用的元命令

以下元命令曾经属于该规范，但未经太多讨论和许可。它们在这里被提及以供参考，但绝不是该规范的一部分。如果它们证明自己有用，它们可能会在某一天恢复，但在撰写本文时，如果中继没有实现这些元命令，那么认为它不符合规范是没有意义的。

##### “!who” 元命令

- 语法： !who/<UUID>
- 这是来自世界的一条信息消息，告诉中继器哪个化身正在控制它。
- 受害者自动触发的陷阱应该使用受害者的 UUID，而不是设置陷阱的人的 UUID（可能是几个小时前）
- 00000000-0000-0000-0000-000000000000 (NULL_KEY) 有效，表示未知头像
- 注意：此消息的内容显然只有在世界对象可信的情况下才可信

*Marine 的注释：此元命令可能旨在检查操作对象的化身，以使恶意破坏变得更加困难……但如果此命令的可信度仅与对象一样高，那么我认为在安全方面这并不是一项改进。否则，这个想法还是有可取之处的。*

##### “!handover” 元命令

- 语法：!handover/<key>/<type>
- 允许一个世界对象告诉中继器它应该接受来自另一个世界对象的命令，而不必再次请求权限。（例如，绑架者对象可能会强制 tpto 到另一个模拟，而另一个世界对象正在等待受害者。
  - (key) 是目标对象的 id
  - (类型) ：0 解除源对象的所有限制，1 保留它们，目标对象有责任记住它们
- 中继必须忽略进一步的“/”参数以便将来扩展命令。
- 中继必须忽略同一聊天行上的任何后续命令
- 源对象应该发送!handover/(key)/(type)|!release，这样不支持!handover 的中继将释放限制并且下一个对象可以正常启动。
- 中继必须通过 !ping 机制确保目标对象可用。
- 但是，目标对象可能无法看到 ping：例如，由于模拟传送速度较慢。在这种情况下，目标对象无论如何都必须在受害者到达时发送 !pong。

*Marine 的注释：这个元命令特别有趣，将来可能会进入“其他元命令”部分，甚至进入主规范。不过，首先需要彻底设计它。我认为它不需要那么复杂，但肯定需要一些检查。*

### 中继要求

- 中发送精确的 @behav:option=param 部分 [在llOwnerSay ](https://wiki.secondlife.com/wiki/LlOwnerSay)()
- 保留用户重新登录时的限制及其来源列表。
- 如果重新登录时无法退出，则强制退出。
- 重新登录时，发送“ping”消息（见上文）以检查虚拟世界对象是否仍然可用。如果几秒后没有消息（不一定是“!pong”，任何针对中继的消息都可以），则释放链接到此对象的规则。
- 用户必须能够访问规范的版本和实现的版本（对话框、消息、对象名称……）以检查一切是否正常运行。
- 中继必须默默地忽略删除不存在的限制的命令，而不会用毫无意义的“请求权限对话框”向用户发送垃圾邮件
- 即使世界对象超出范围，中继也必须接受！释放。
- 如果中继取消活动会话（例如由于安全词），则必须发送 !release,ok
- 中继必须确保其保留命令的顺序。例如：如果限制在 Ask-dialog 中排队，则除非 ask-dialog-queue 中的待处理限制也被移除，否则不得立即执行解除限制的操作。

### 游戏世界中的物体要求

- 如果世界对象发送了任何限制，它必须使用 !release 结束会话，即使中继没有响应“ok”，除非所有命令都已被“ko”。中继可能已延迟执行以征求用户的许可，而用户可能会在会话结束后确认这些许可
- 当从中继接收到“ping”消息时，使用针对拥有它的化身的“！pong”消息（如上所述）进行回复，前提是它们仍然受到对象的限制。
- 永远不要依赖来自中继的答复，请求可以被默默拒绝，中继可以被卸下，头像可以 TP 出或崩溃... => 使用超时。
- 不要轮询 [数据服务器的 ](https://wiki.secondlife.com/wiki/Dataserver)在线状态，中继将负责重新记录部分。
- 世界对象不应该向中继通道发送垃圾邮件。例如：每分钟查询附近每个人的中继版本，尽管没有人表现出任何实际使用该对象的迹象。

# RLVa补充部分

## RLVa / RLV 差异

RLVa 是 Marine Kelly 对 RLV API 的替代实现和扩展。 RLVa 对某些事物的解释略有不同（通常以侵入性较小的方式），并且具有许多超出 Marine 规范的扩展。本 wiki 详细介绍了适用于 Catznip、Firestorm 和其他 RLVa 查看器的 RLVa 规范。 RLVa 自 2009 年以来一直得到广泛使用，大多数用户体验为或等同于 RLV，尽管这指的是不同的规范和实现。

RLVa 与 Marine Kelly 的 RLV 实现不共享任何代码，虽然我们致力于维护与其规范精神的功能兼容性，但我们没有义务实施每项更改或添加。同样，她也不应反映 RLVa 规范 中出现的所有内容。也就是说，RLVa 和 RLV 在历史上遵循了非常接近的共同路径，其中一个的添加最终会出现在另一个中，反之亦然。 （有时通过 同义词 ）。

### 共享穿着

SharedWear 内容的组织 显着简化了#RLV 文件夹 无需使用附件点名称创建或重命名附件，从而 特定行为的更新 。这是对之前RLVa ，它将自动为您创建所需的文件夹名称。

### 调试工具

RLVa 具有 活动命令 浮动窗口和许多 调试工具 ，可以更轻松地查看脚本正在执行的操作以及正在执行的命令。可以选择启用断言失败，突出显示潜在的 SL 服务错误。

### 赋予 #RLV 文件夹深度和 #RLV 文件夹创建

从 Catznip R9 和 Firestorm 4.6 开始， #RLV 文件夹 当库存报价使用时，会自动创建 给#RLV 。以前版本的 RLVa 和所有版本的 RLV 都需要在使用前手动创建该文件夹。

此外， #RLV 文件夹 库存优惠最多可达 3 个子文件夹深度 (#RLV/~Level1/Level2/Level3)，并根据需要创建所有父文件夹。 请参阅 捐赠给#RLV 有关详细信息。

### 正频道数

许多命令需要指定频道号，以便将信息从查看器转发到脚本。由于 LSL 消息大小的差异，RLVa 要求该值为正整数。负通道只能包含长度为 256 字节的字符串，正通道最多可以包含 1024 字节。

这样做是为了防止 RLVa 命令由于不明显的原因而输出被截断的数据。

## RLV 同义词

RLV 中选定数量的命令通过同义词在 RLVa 中实现，这是为了涵盖命名方案中的差异以及有时命令行为/实现中的差异。出于礼貌而提供同义词，以提供最低级别的跨 API 兼容性。强烈建议使用 RLVa 规范中详细说明的命令，因为实现差异很容易转化为不明显的不需要的行为。

### @camunlock = < n|y >

- 映射到 @setcam_unlock = < n|y > 。进行了更改以适应其余的 @setcam 控件。

## RLVa 命令差异

有些命令具有相同的命名，但操作方式明显不同，或者具有可选的额外参数。

### @detach [: <attachment_point> |<attachment> ] = < n |y >|force

- 可选择通过 UUID 锁定或删除附件

### @detachthis [: <attachment_point> | <clothing_layer> | <attachment> ] = force

- 可以选择通过 UUID 删除附件

### @fartouch [:< 距离 >] = < n|y >

- 可以指定可选距离，如果省略，则返回默认值 1.5m。

### @remattach [:< 附件点 >|< 附件 >] = force

- 可以选择通过 UUID 删除附件

### @shownames [:< 代理 >] = < n|y >

- 提供例外时指定的可选代理 UUID。

### @shownametags [:< 代理 >] = < n|y >

- 提供例外时指定的可选代理 UUID。

### @sittp [:< 距离 >] = < n|y >

- 可以指定可选距离，如果省略，则返回默认值 1.5m。

### @tpto [:<区域>/] <位置> [;<查看>] = force

- 可以通过区域名称和局部坐标来指定目的地，而不需要基于脚本的往返来获取全局坐标。观察矢量可选择设置头像到达时所面对的方向。

## 头像命令

### @adjustheight:<value>\[;<factor>\]\[;<distance>\]=force

- 设置升高或降低头像的垂直偏移，范围大致为 -200 到 200。

- 头像 Z 偏移 = ( <值> * [<系数>] ) + [< 距离 >]

- [<factor>] 可选因子默认为 0.01

- [<distance>] 可选距离，通常不需要。

- ```lsl
  @adjustheight:3=force
  @adjustheight:0.03;1=force
  ```

### @edit=<n|y>

- 防止编辑在世界中重新设置并附加到用户的对象
  - 任何活动的选择都将被删除。
  - 编辑浮动窗口将保持打开状态，但切换到构建选项卡。
  - 可以放置新对象（从库存和通过构建），但选择会立即下降。
  - 地形仍然可以编辑（地形改造和地块划分）。
  - 购买物品不受影响。

### @fartouch[:<distance>]=<n|y>

- 将触摸限制在距用户中心指定的半径内。如果设置多次，则最小距离有效。
  - [<distance> ] 可选 参数，允许指定距离，如果省略则默认为 1.5m
  - 用户将无法触摸、移动或编辑超出距离的对象。
  - 鼠标光标不会改变以指示超出范围的对象可以通过触摸进行交互。
  - 当对象超出范围时，编辑选择将会下降。
  - 如果省略距离，可防止用户更多地触摸物体
  - 注意：距离也不例外，因此不要使用 @fartouch = n 后跟 @fartouch :20 = n， 因为这会将 fartouch 距离设置为默认的 1.5m，而不是预期的 20m

## 传送命令

### @tplocal[:<distance>]=<n|y>

- 通过双击传送或在地址栏或世界地图中输入坐标来防止本地传送。
- 基于位置的传送现在根据用户当前位置和目的地之间的距离分为“本地”和“远程”。如果目的地距离超过 256m，则传送被视为远程并受 @tploc 约束；如果它低于 256m 那么它是本地的并受 @tplocal 的约束。
- 请注意，RLVa 中的双击传送始终受 @sittp 约束，并且情况仍然如此（即 @sittp 暗示 @tplocal ）；这只是使本地传送正式化，并提供了一种在不影响坐距的情况下阻止本地传送的方法。

### @tpto:[<region>/]<position>[;<lookat>]=force

- 将用户传送到全局坐标或区域坐标中的特定位置。

  - <position> 如果仅提供一个位置，则它必须位于全局坐标中，这需要一些脚本在调用命令之前执行数据服务器查询。

  - [<region>;] <position> 如果提供了区域和位置，则查看器将处理到全局坐标的转换，而无需脚本化数据服务器事件。

  - [<lookat>] 可选择设置头像到达时所面对的方向。 （目前无法进行区域间传送）

  - 示例命令 使用[<region>;] <position> 将用户直接发送到区域 Kara, 128,128,10 的 。

  - ```lsl
    @tpto:Kara/128/128/10=force
    ```

## 定位命令

### @showloc=<n|y>

- 主要用于向用户隐藏当前地块和区域位置信息，通常将其替换为“（隐藏地块）、（隐藏区域）”。
  - 防止创建地标。
  - 防止打开“地点简介”、“关于土地”和“地区/庄园”浮动广告。
  - 删除“你在这里！”任何开放的地方概况或地标的贴纸。
  - 如果“关于土地”和“地区/庄园”浮动广告板打开，请将其关闭。
  - 用户可以打开世界地图和小地图，但区域名称被删除。
  - 除非目标代理拥有用户的地图权限，否则用户不得提供传送。
  - 在传入传送请求时向用户显示的位置会受到审查。
  - 包含该位置的对象聊天将被有条件地审查。

## 本地聊天命令

### @sendgesture=<n|y>

- 阻止用户玩手势。

### @sendchannel_except:<channel>=<n|y>

- 类似 与@sendchannel ，这限制了用户可以聊天的频道。设置后，用户可以在除列为例外的频道之外的所有频道上聊天。有严格版本 @sendchannel_ except_sec 。

## 即时消息命令

### @startim=<n|y>

- 防止与其他用户开始/打开新的 IM 对话。
  - 应用此命令时已打开的 IM 对话将保持打开状态。
  - 传入的 Teleport 优惠和库存将起作用，但不会打开新的 IM 窗口。
  - 用户发送的传送提议/请求所附加的消息将被审查。
  - 尝试启动 IM 会话将向用户显示“第二人生：由于 RLV 限制，无法启动与 <target_user> 的 IM 会话”
- 注意： RLVa 不可能、也永远不可能读取 IM 消息的内容。

## 坐下命令

### @sittp[:<distance>]=<n|y>

- 将坐在距离用户中心指定半径范围内的物体上。如果设置多次，则最小距离有效。
  - [<distance> ] 可选 参数，允许指定距离，如果省略则默认为 1.5m
  - 注意：距离也不例外，因此不要使用 @sittp = n， 然后 使用@sittp 20 = n， 因为这会将坐传送距离设置为默认的1.5m，而不是预期的20m

## 服装和附件命令

### @detach[:<attachment_point>]=<n|y>

- 防止附件被分离（哪个附件取决于它的调用方式）并删除特定附件（取决于它的调用方式！）请参阅下面的示例。

- 如果没有参数，包含调用脚本的特定附件将被锁定。

- ```lsl
  @detach=n
  ```

- 指定可选的附件点名称将导致该点被锁定，该点上的任何附件都将被锁定，并且不能向其中添加其他附件。

- 调用该命令 使用y 可解锁包含脚本的附件。

- ```lsl
  @detach=y
  ```

### @detach[:<attachment_point>|<attachment>]=force

- 使用 强制功能 可通过点名称或 UUID 删除附件。

- ```lsl
  @detachhead=force
  ```

- ```lsl
  @detachb7d41859-a37a-4989-9796-1056e72766ab=force
  ```

- 单独使用武力将移除所有未锁定的附件。

- ```lsl
  @detach=force
  ```

- 附件 使用Nostrip 无法通过脚本命令删除，这是设计使然，并为用户提供手动覆盖，适用于头发、尾巴或网格物体等项目。

### @detachthis[:<attachment_point>|<clothing_layer>|<attachment>]=force

### @remattach[:<attachment_point>|<attachment>]=force

- 按点或名称删除附件。 同义词：@detach[:<attachment_point>|<attachment>]=force

### 附着点组

```lsl
head, torso, arms, legs, hud
```

```lsl
头、躯干、手臂、腿、HUD
```

### 连接点名称

```lsl
head, nose, mouth, tongue, chin, jaw, left ear, right ear, left ear (extended), right ear (extended), left eye, right eye, left eye (extended), right eye (extended), neck, left shoulder, right shoulder, left upper arm, right upper arm, left lower arm, right lower arm, left hand, right hand, left ring finger, right ring finger, left wing, right wing, chest/sternum, left pectoral, right pectoral, belly/stomach/tummy, back, tail base, tail tip, avatar center/root, pelvis, groin, left hip, right hip, left upper leg, right upper leg, right lower leg, left lower leg, left foot, right foot, left hind foot, right hind foot, HUD, HUD Center 2, HUD Top Right, HUD Top, HUD Top Left, HUD Center, HUD Bottom Left, HUD Bottom, HUD Bottom Right
```

```lsl
头、鼻子、嘴、舌头、下巴、下巴、左耳、右耳、左耳（延长）、右耳（延长）、左眼、右眼、左眼（延长）、右眼（延长）、颈部、左肩、右肩、左上臂、右上臂、左下臂、右下臂、左手、右手、左无名指、右无名指、左翼、右翼、胸部/胸骨、左胸肌、右胸饰，腹部/胃/肚子、背部、尾根部、尾尖、头像中心/根部、骨盆、腹股沟、左臀部、右臀部、左大腿、右大腿、右小腿、左小腿、左脚、右脚、左后脚、右后脚、HUD、HUD 中心 2、HUD 右上、HUD 顶部、HUD 左上、HUD 中心、HUD 左下、HUD 底部、HUD 右下
```

### 服装层名称

```lsl
alpha, tattoo, shoe base, physics, socks, gloves, undershirt, underpants, shirt, pants, jacket, skirt
```

```lsl
alpha、纹身、鞋底、物理、袜子、手套、汗衫、内裤、衬衫、裤子、夹克、裙子
```

## 相机命令

### @setcam=<n|y>

- 相同的概念 在给定时间只有一个对象可以保持此行为，遵循与@setenv ，其中单个对象可以独占锁定控制。在后续尝试中，调试输出将显示“已锁定”作为失败消息。
- 当一个对象持有锁时，来自所有其他对象的所有相机命令都将被忽略；当对象释放锁定时，所有其他相机行为都将恢复。

### @setcam_eyeoffset[:<vector3>]=force

- 调试设置相同的方式更改默认相机偏移 以与更改CameraOffsetRearView （调试设置未更改）。

### @setcam_focus<agent|object|position>[;<distance>;<direction>]=force

- 将相机和焦点移动到指定位置（之后用户仍可以更改焦点）。

  - <agent>  | <object> |<position> 对象的 UUID 或要聚焦的代理或位置向量（在区域坐标中）

  - [<distance> ] 可选 （如果省略则根据物体大小计算）相机到焦点的距离

  - [<direction>] 可选（如果省略则在当前相机上计算）归一化方向向量

  - 使用您之前的相机方向，聚焦 20m 外的代理（获取您自己的 UUID）。

  - ```lsl
    @setcam_focus:<uuid>;20;=force
    ```

  - 聚焦在一个物体上（为此调整一个 prim 并获取其 UUID），这将导致相机沿着负 X 方向观察胶合板立方体（填充屏幕）。

  - ```lsl
    @setcam_focus:<uuid>;;1/0/0=force
    ```

  - 现在调整 prim 的大小 (20x20x20m) 并重试该命令。您会注意到胶合板立方体仍然充满屏幕。如果省略距离，RLVa 将根据比例进行计算，以便对象始终完全处于视野中。

  - 聚焦于某个位置。将相机移至<128, 128, 75>，俯视地面。

  - ```lsl
    @setcam_focus:128/128/75;;0/0/1=force
    ```

### @setcam_focusoffset[:<vector3>]=force

- 调试设置相同的方式更改默认相机焦点偏移 以与更改FocusOffsetRearView （调试设置未更改）。

### @setcam_fov:<angle>=force

- 将相机的垂直视野更改为指定值（以弧度表示的角度）。

### @setcam_fovmin:<angle>=<n|y>

- 将用户的视野角度限制为最小值（以弧度表示的角度）。 设置 将@setcam_fovmin 和 @setcam_fovmax 为相同的值会锁定该值。

  - 将最小 FOV 设置为 45°

  - ```lsl
    @setcam_fovmin0.780=n
    ```

### @setcam_fovmax:<angle>=<n|y>

- 将用户的 fov 角度限制为最大值（以弧度表示的角度）。 设置 将@setcam_fovmin 和 @setcam_fovmax 为相同的值会锁定该值。

  - 将最大 FOV 设置为 90°

  - ```lsl
    @setcam_fovmax:1.57=n
    ```

  - 

### @setcam_unlock=<n|y>

- 强制相机始终聚焦在用户的头像上，实际上，使他们成为世界的固定中心。以前是 RLV 命令 @camunlock 。
- 可能的变化：当前通过 LSL 控制时仍然允许自由摄像机移动，还需要处理和阻挡吗？

### 相机控制示例

#### 更改第三人称相机位置和视角

基本相机位置（如 Penny Patton 的《透视问题 命令来完成， 》中详细介绍）可以通过@setcam_eyeoffset 和 @setcam_focusoffset 调试设置相同的方式影响相机 这些命令以与CameraOffsetRearView 和 FocusOffsetRearView 。

情况下使用这些 注意：如果您在没有@setcam的 ，请在完成后手动恢复默认值；否则 @setcam = y 将负责清理并将内容恢复到用户的默认值

```lsl
@setcam_eyeoffset:-2/-0.4/-0.2=force
```

```lsl
@setcam_focusoffset:0.9/-0.7/0.2=force
```

#### 恢复默认的第三人称相机位置和视角

```lsl
@setcam_eyeoffset=force
```

```lsl
@setcam_focusoffset=force
```

## RLVa RFC setsphere

### 概述

@setsphere 是一种视觉效果，应用于世界渲染的最后一步，并作用于其影响范围内的像素。

例如，当使用混合模式时，屏幕上球体包含的每个像素将根据线性增加（或减少）的混合值与球体的颜色混合。

如果您在视觉上遇到问题：想象一下站在一片漆黑中，戴着灯泡帽，它均匀地照亮了您周围的区域。您所站立的确切位置处于正常亮度，但 5m 之外的所有事物都只有 50% 的亮度，而在 10m 之外（及更远），您只能看到完全黑暗。 （请注意，@setsphere 实际上并不发射 - 或以任何方式影响 - 光）

如果您熟悉“视觉领域”，下面的第一个屏幕截图应该与这些屏幕截图相同。但请记住，@setsphere 只与与你的头像周围的假想球体相交的像素交互，因此从外向内看时实际上不会遮挡任何东西。

为了说明这一点，如果您在上一个示例中将相机向后移动，您将看到下面的第二个屏幕截图。即使相机牢牢位于“全黑”区域，您仍然可以看到头像站在其“明亮”区域，并且可见区域之外的物体（例如图像中心的树）仍然可以被视为轮廓。

![Setsphere_overview_1.png](https://wiki.catznip.com/images/7/77/Setsphere_overview_1.png)

![Setsphere_overview_2.png](https://wiki.catznip.com/images/5/5b/Setsphere_overview_2.png)

### 征求意见

@setsphere 的当前实现（以及本页上记录或讨论的任何内容）绝不是最终的。第一个实现的目的是与脚本创建者就所需内容展开对话，并希望激发关于除了简单地将某人的 SL 体验减少到其头像周围 2m 的无聊之外的可能性的想法和想法。

所有意见和建议都将被考虑。然而，请记住，一旦将其合并到 Firestorm 中，事情就将一成不变。

我特别希望得到反馈的事情：

- 目前，可以同时激活的球体效果数量没有限制（将来可能会限制为 4 个）

- 效果可能不会按照预测的顺序相互影响（可能它们创建的顺序会影响最终结果） - 如果您发现任何奇怪的情况，请告诉我

- 即使您可以通过将最小/最大距离保留为 0 来将效果应用于整个屏幕，请告诉我您是否只想将特定效果应用于全屏，因为这样可以更有效地完成

- 目前没有对 valuemin 和 valuemax 的值进行验证，因此您可以设置负 alpha 值来增强颜色（或特定颜色分量）。然而，这种情况将来可能会改变。请随意尝试，但如果您发现 @setsphere 修饰符表中列出的值之外的用途，请告诉我，否则如果没有人告诉我，您可能会发现它在将来不再起作用

- 类似地，没有规则规定 valuemin 必须小于 valuemax（例如，尝试以下方法将 20m 球体从纯黑色混合到正常颜色）

- ```lsl
  @clear,setsphere=n,setsphere_distmax:20=force,setsphere_valuemax:0=force
  ```

- 目前高斯模糊半径和像素化块大小以像素为单位测量。然而，1920 像素宽查看器窗口上的 1 像素与 640 像素宽查看器窗口上的 1 像素不同。因此，我可能会切换到与分辨率无关的单元。如果您有任何想法或意见（或者如果您认为保留像素单位有价值），请告诉我。

### 隐含限制

@setsphere 只是视觉效果，因此不施加任何限制。如果您想限制相机距离，可以使用适当的 @setcam_XXX 限制来实现。

为了帮助您创造自己独特的体验，我们将添加一些新的限制，并修改一些现有的限制：

- @viewtransparent=[n|y] - 防止用户突出显示透明纹理
- @viewwireframe=[n|y] - 如果@setsphere 设置为视觉限制，则线框可能被视为作弊。这将阻止用户切换到线框渲染
- @shownametags:<distance> - TODO（尚未实现）
- @edit:<距离> - TODO（尚未实现）

如果您认为创建所需体验还需要其他限制，请告诉我。

### 兼容性

虽然最初的意图是，但目前无法为 @camdraw[min|max] 构建兼容层。 @camdrawmin 和 @camdrawmax 各自采用一个距离值，并且应该将球体颜色与实际颜色混合，但内部距离处的下降几乎是瞬时的。

下面是一个混合球体的示例，从 5m（alpha 0）开始，到 25m（alpha 1）结束。每 5m 放置一次全亮白色棱光，突出显示亮度应下降 25% 的点（呈线性分布）。

使用 @camdrawmin/camdrawmax 时，只有第一个 prim（仍在不受影响的半径内）可见，并且超过 5m 的下降非常紧密，甚至根本看不到 10m 处的第一个 prim。 使用@setsphere，您可以看到 5m 处的内部 prim，以及 10m、15m 和 20m 处的接下来 3 个 prim，亮度逐渐降低，最后是 25m 处的完全黑色且实际上不可见的 prim。

*@camdrawmin:5=n,camdrawmax:25=n,camdrawalphamin:0=n,camdrawalphamax:1=n*

![Setsphere_camdraxminmax_rlv.png](https://wiki.catznip.com/images/d/de/Setsphere_camdraxminmax_rlv.png)

*@camdrawmin:5=n,camdrawmax:25=n,camdrawalphamin:0=n,camdrawalphamax:1=n*

![Setsphere_camdraxminmax_rlva.png](https://wiki.catznip.com/images/4/43/Setsphere_camdraxminmax_rlva.png)

@setsphere=n,setsphere_distmin:5=force,setsphere_distmax:25=force,setsphere_valuemin:0=force,setsphere_valuemax:1=force

为了模拟 @setsphere 下从 5m 到 25m 的可见内容，@camdrawmax 值必须增加到 90。如果在任何时候都可以将 @camdraw[min|max] 的距离值计算回米，我将添加支持对于他们来说。然而，考虑到脚本创建者可能会根据特定实现定制其值，因此最好在 RLVa 中不提供支持，而不是支持看起来与 RLV 完全不同的东西，反之亦然。

### @setsphere

@setsphere 是球体效果的主要（也是唯一）限制。就像@setoverlay（或@setenv）一样，您需要发出一系列强制命令来根据您的喜好更改限制的外观和/或行为。

修改器命令的格式为 @setsphere_<modifier>:<param>=force 并且仅适用于发出它们的对象。如果多个对象有自己的球体，它们可以改变自己的效果，但不会影响另一个对象的效果。多个球体的最终结果将是累积的（例如，对于混合颜色，将混合低于 1.0 的 alpha）。 如果您想取消设置修饰符值，您可以发出force命令而不指定vlue（例如@setsphere_param=force）。

| 修饰符               | 输入范围          | 默认值      | 描述                                                         |
| -------------------- | ----------------- | ----------- | ------------------------------------------------------------ |
| setsphere_mode       | 0 - 4             | 0 (=blend)  | 应用的效果类型（请参阅下面的文档）<br/>0 - 混合<br/>1 - 模糊<br/>2 - 模糊 (2)<br/>3 - 色差<br/>4 - 像素化 |
| setsphere_origin     | 0 - 1             | 0 (=avatar) | 圆环的由来<br/>0 - 球体以用户头像为中心<br/>1 - 球体以用户相机为中心 |
| setsphere_distmin    | 0  - ∞            | 0           | 距球体原点的距离。确定效果开始的位置（以 valuemin 强度）     |
| setsphere_distmax    | 0 - ∞             | 0           | 距球体原点的距离。确定效果结束的位置（以 valuemax 强度）<br />可选 - 如果未指定（或指定的值小于 distmin），这将设置为 distmin |
| setsphere_distextend | 0  - 3            | 1           | 距球体原点的距离。确定效果结束的位置（以 valuemax 强度）     |
| setsphere_param      | 4个浮点数的向量   | 0/0/0/0     | 配置效果的基本外观（有关更多信息，请参阅有关要使用的模式的文档） |
| setsphere_valuemin   | 0.0  - 1.0        | 1           | 设置 distmin 的效果强度                                      |
| setsphere_valuemax   | 0.0  - 1.0        | 1           | 将效果强度设置为 distmax                                     |
| setsphere_tween      | Time (in seconds) | 0           | 当设置为非零值时，修改器更改不再是即时的，而是需要 X 秒才能逐渐达到新值。设置后，所有后续修改器更改都将进行补间。<br/>如果您想再次立即进行更改，请设置回 0。<br/>'distmax'、'distmin'、'param'、'valuemax' 和 'valuemin' 受此影响。 |

#### 笔记

- 每种模式的示例旨在从 RLV 控制台使用

### @setsphere_distextend

'distextend' 修饰符指定球体两侧的区域应如何运作。

| 价值 | 描述                                                         |
| ---- | ------------------------------------------------------------ |
| 0    | 该效果仅适用于最小和最大距离内的像素。在此范围之外的像素将正常渲染。 |
| 1    | 效果向外延伸，因此比最大距离更远的像素将具有效果强度“valuemax”（默认） |
| 2    | 效果向内延伸，因此比最小距离更近的像素将具有效果强度“valuemin” |
| 3    | 效果向内和向外延伸                                           |

如果上面的内容还不清楚，希望下面的四张图片会让你更清楚。纯黑色像素表示不受该效果影响的区域；任何灰色阴影都表示效果强度介于 0（= 黑色/根本没有）和 1（= 白色/全亮）之间的区域。 （如果您有 Photoshop 经验，请将图像视为混合蒙版）

0 - 该效果仅适用于 distmin < distance < distmax

![750px-Setsphere_distextend_0.png](https://wiki.catznip.com/images/thumb/4/4c/Setsphere_distextend_0.png/750px-Setsphere_distextend_0.png)

1 - 效果向外延伸超过 distmax

![750px-Setsphere_distextend_1.png](https://wiki.catznip.com/images/thumb/f/f6/Setsphere_distextend_1.png/750px-Setsphere_distextend_1.png)

2 - 效果在 distmin 之前向内延伸

![750px-Setsphere_distextend_2.png](https://wiki.catznip.com/images/thumb/6/6f/Setsphere_distextend_2.png/750px-Setsphere_distextend_2.png)

3 - 效果向内和向外延伸

![750px-Setsphere_distextend_3.png](https://wiki.catznip.com/images/thumb/c/c9/Setsphere_distextend_3.png/750px-Setsphere_distextend_3.png)

请注意，并非所有模式都支持全部 4 个选项（有关更多详细信息，请参阅相应的文档）

### 模式：混合

| 命令                 | 值                     | 描述                                                         |
| -------------------- | ---------------------- | ------------------------------------------------------------ |
| setsphere_mode       | 0                      | 将  @setsphere 切换到“混合”模式（默认）                      |
| setsphere_param      | <red>/<green>/<blue>/0 | 前三个数字分别指定球体颜色的红色、绿色和蓝色值（0 到 1 之间）。第4个参数未使用（设置为0） |
| setsphere_distmin    | <distance>             | 设置效果开始的距离（以米为单位）                             |
| setsphere_distmax    | <distance>             | 设置效果应结束的距离（以米为单位）                           |
| setsphere_distextend | 0, 1, 2 or 3           | 请参阅上面的文档                                             |
| setsphere_valuemin   | <float>                | 设置 distmin 处的效果强度（有用的范围值取决于内核大小参数）  |
| setsphere_valuemax   | <float>                | 设置 distmax 处的效果强度（有用的范围值取决于内核大小参数）  |

#### 例子

（打开 RLV 控制台并一一复制/粘贴限制 - 如果中途关闭 RLV 控制台，则必须重新从步骤 1 开始）

1. 清除所有修改器并将 @setsphere 切换到“混合”模式，其中包含 2.5m 的排除球体区域，超出该区域的所有内容均为纯黑色（=默认球体颜色）

   ```lsl
   @clear,setsphere=n,setsphere_distmin:2.5=force
   ```

   ![750px-Setsphere_blend_1.png](https://wiki.catznip.com/images/thumb/e/eb/Setsphere_blend_1.png/750px-Setsphere_blend_1.png)

2. 将球体的外半径设置为 20m，并在 0m 处以 0.0 alpha 值开始（并以最大 1.0 alpha 值结束，这是默认值）

   ```lsl
   @setsphere_distmax:20=force,setsphere_valuemin:0=force
   ```

   ![750px-Setsphere_blend_2.png](https://wiki.catznip.com/images/thumb/8/8e/Setsphere_blend_2.png/750px-Setsphere_blend_2.png)

3. 将远边缘效果的 Alpha 切换至 95%，让您仍然可以看到远处的物体，并将颜色切换为深灰色

   ```lsl
   @setsphere_valuemax:0.95=force,setsphere_param:0.35/0.35/0.35/0=force
   ```

   ![750px-Setsphere_blend_3.png](https://wiki.catznip.com/images/thumb/4/41/Setsphere_blend_3.png/750px-Setsphere_blend_3.png)

4. 将球体的外半径设置为 50m，以获得更令人满意的视觉最终结果

   ```lsl
   @setsphere_distmax:50=force
   ```

   ![750px-Setsphere_blend_4.png](https://wiki.catznip.com/images/thumb/a/a8/Setsphere_blend_4.png/750px-Setsphere_blend_4.png)

### 模式：模糊（固定）

| 命令                 | 值           | 描述                                          |
| -------------------- | ------------ | --------------------------------------------- |
| setsphere_mode       | 1            | 将  @setsphere 切换到“固定 (13) 内核模糊”模式 |
| setsphere_param      | -            | 未使用                                        |
| setsphere_distmin    | <distance>   | 设置效果开始的距离（以米为单位）              |
| setsphere_distmax    | <distance>   | 设置效果应结束的距离（以米为单位）            |
| setsphere_distextend | 0, 1, 2 or 3 | 请参阅上面的文档                              |
| setsphere_valuemin   | 0.0 - 4.0    | 设置 distmin 的效果强度                       |
| setsphere_valuemax   | 0.0 - 4.0    | 将效果强度设置为 distmax                      |

#### 笔记

- 此模式的强度值决定了采样像素的距离。例如，对于值为 1 的值，左侧、右侧、上方和下方的 3 个像素都会对最终结果产生影响。
- 虽然您可以超过 4.0 的值，但越高，您就会看到越来越多的方形图案出现，因为您跳过了图像中越来越大的部分；如果您需要更极端的模糊，请尝试可变模糊。

#### 例子

（打开 RLV 控制台并一一复制/粘贴限制 - 如果中途关闭 RLV 控制台，则必须重新从步骤 1 开始）

1. 清除所有修改器并将 @setsphere 切换到“固定模糊”模式

   ```lsl
   @clear,setsphere=n,setsphere_mode:1=force
   ```

2. 将模糊半径切换为 2 像素

   ```lsl
   @setsphere_valuemax:2=force
   ```

   ![750px-Setsphere_blur_1.png](https://wiki.catznip.com/images/thumb/9/96/Setsphere_blur_1.png/750px-Setsphere_blur_1.png)

3. 设置2m的排除范围

   ```lsl
   @setsphere_distmin:2=force
   ```

   ![750px-Setsphere_blur_2.png](https://wiki.catznip.com/images/thumb/b/b8/Setsphere_blur_2.png/750px-Setsphere_blur_2.png)

4. 增加外半径（2m到20m之间的东西会逐渐变得不那么锋利）

   ```lsl
   @setsphere_distmax:20=force
   ```

   ![750px-Setsphere_blur_3.png](https://wiki.catznip.com/images/thumb/f/f1/Setsphere_blur_3.png/750px-Setsphere_blur_3.png)

5. 再次增大外半径（2m到200m之间的东西会逐渐变得不那么锋利）

   ```lsl
   @setsphere_distmax:200=force
   ```

   ![750px-Setsphere_blur_4.png](https://wiki.catznip.com/images/thumb/e/e8/Setsphere_blur_4.png/750px-Setsphere_blur_4.png)

### 模式：模糊（2）

| 命令                 | 值                  | 描述                                                         |
| -------------------- | ------------------- | ------------------------------------------------------------ |
| setsphere_mode       | 2                   | 将 @setsphere  切换到“可变内核模糊”模式                      |
| setsphere_param      | <kernel size>/0/0/0 | 第一个数字指定高斯模糊的内核大小（需要与 valuemin/valuemax  结合设置） |
| setsphere_distmin    | <distance>          | 设置效果开始的距离（以米为单位）                             |
| setsphere_distmax    | <distance>          | 设置效果应结束的距离（以米为单位）                           |
| setsphere_distextend | 0, 1, 2 or 3        | 请参阅上面的文档                                             |
| setsphere_valuemin   | <float>             | 设置 distmin 处的效果强度（有用的范围值取决于内核大小参数）  |
| setsphere_valuemax   | <float>             | 设置 distmax 处的效果强度（有用的范围值取决于内核大小参数）  |

#### 笔记

- 内核大小决定了采样多少个相邻像素。较高的内核大小将导致更模糊的最终结果（取决于最小/最大值中的西格玛值）
- 避免对内核使用较大的值，因为一旦确定对 FPS 的影响，将来可能会限制该值

#### 例子

1. 清除所有修改器并将 @setsphere 切换到“可变模糊”模式

   ```lsl
   @clear,setsphere=n,setsphere_mode:2=force
   ```

2. 将内核大小设置为 15，将 sigma 值设置为 5

   ```lsl
   @setsphere_param:15/0/0/0=force,setsphere_valuemax:5=force
   ```

   ![750px-Setsphere_blur2_1.png](https://wiki.catznip.com/images/thumb/2/24/Setsphere_blur2_1.png/750px-Setsphere_blur2_1.png)

3. 仅当距离 >=2m 时才强制执行效果（只有 >2m 的对象才会看起来模糊）

   ```lsl
   @setsphere_distmin:2=force
   ```

   ![750px-Setsphere_blur2_2.png](https://wiki.catznip.com/images/thumb/b/b3/Setsphere_blur2_2.png/750px-Setsphere_blur2_2.png)

### 模式：色差

| 命令                 | 值                                          | 描述                                                     |
| -------------------- | ------------------------------------------- | -------------------------------------------------------- |
| setsphere_mode       | 3                                           | 将  @setsphere 切换到“色差”模式                          |
| setsphere_param      | <水平红移>/<垂直红移>/<水平蓝移>/<垂直蓝移> | 前 2 个数字指定红色分量的偏移量；最后2个绿色分量的偏移量 |
| setsphere_distmin    | <distance>                                  | 设置效果开始的距离（以米为单位）                         |
| setsphere_distmax    | <distance>                                  | 设置效果应结束的距离（以米为单位）                       |
| setsphere_distextend | 0, 1, 2 or 3                                | 请参阅上面的文档                                         |
| setsphere_valuemin   | 0.0-1.0                                     | 设置 distmin 的效果强度                                  |
| setsphere_valuemax   | 0.0-1.0                                     | 将效果强度设置为 distmax                                 |

#### 笔记

- 如果两个值（valuemin 和 valuemax）和两个距离（distmin 和 distmax）都不同，那么 - 就像混合模式一样 - 每个像素的颜色分量的偏移量将根据距离逐渐增加（或减少）

#### 例子

1. 清除所有修饰符并将 @setsphere 切换到“色差”模式

   ```lsl
   @clear,setsphere=n,setsphere_mode:3=force
   ```

2. 将红色通道向左移动 8 个像素，将蓝色通道向右移动 8 个像素

   ```lsl
   @setsphere_param:8/0/-8/0=force
   ```

   ![750px-Setsphere_ca_1.png](https://wiki.catznip.com/images/thumb/0/05/Setsphere_ca_1.png/750px-Setsphere_ca_1.png)

3. 增加颜色偏移，但以 50% 的比例与原始颜色混合（在 5 秒内以动画方式呈现变化）

   ```lsl
   @setsphere_tween:5=force,setsphere_param:0/-25/0/25=force,setsphere_valuemax:0.5=force,setsphere_tween=force
   ```

   ![750px-Setsphere_ca_2.png](https://wiki.catznip.com/images/thumb/e/ee/Setsphere_ca_2.png/750px-Setsphere_ca_2.png)

4. 仅当距离 >=10m 时才强制执行该效果（仅距离 >10m 的对象才会受到影响）

   ```lsl
   @setsphere_distmin:10=force
   ```

   ![750px-Setsphere_ca_3.png](https://wiki.catznip.com/images/thumb/0/04/Setsphere_ca_3.png/750px-Setsphere_ca_3.png)

### 模式：像素化

| 命令                 | 值                   | 描述                                                         |
| -------------------- | -------------------- | ------------------------------------------------------------ |
| setsphere_mode       | 4                    | 将  @setsphere 切换到像素化模式                              |
| setsphere_param      | <width>/<height>/0/0 | 指定像素化块大小（以像素为单位） - 此模式未使用最后 2 个参数 |
| setsphere_distmin    | <distance>           | 设置效果开始的距离（以米为单位）                             |
| setsphere_distmax    | <distance>           | 设置效果应结束的距离（以米为单位）                           |
| setsphere_distextend | 1  or 0              | 指定 1（默认）将效果延伸超过最大距离，或指定 0 结束效果      |
| setsphere_valuemin   | -                    | 未使用                                                       |
| setsphere_valuemax   | -                    | 未使用                                                       |

#### 笔记

- 在此模式下，请勿将 @setsphere_distextend:1=force 与最小/最大距离值一起使用；只需设置 distmin 就足够了（参见示例）

#### 例子

1. 清除所有修改器并将 @setsphere 切换到“像素化”模式

   ```lsl
   @clear,setsphere=n,setsphere_mode:4=force
   ```

2. 将块大小设置为 10x10（一切都是像素化的）

   ```lsl
   @setsphere_param:10/10/0/0=force
   ```

   ![750px-Setsphere_pixelate_1.png](https://wiki.catznip.com/images/thumb/4/43/Setsphere_pixelate_1.png/750px-Setsphere_pixelate_1.png)

3. 仅当距离 >=10m 时才强制执行效果（仅距离 >10m 的对象才会出现像素化）

   ```lsl
   @setsphere_distmin:10=force
   ```

   ![750px-Setsphere_pixelate_2.png](https://wiki.catznip.com/images/thumb/b/b6/Setsphere_pixelate_2.png/750px-Setsphere_pixelate_2.png)

4. 在 15 秒内补间到 25x25 的块大小（然后重置以下命令的补间持续时间）

   ```lsl
   @setsphere_tween:15=force,setsphere_param:25/25/0/0=force,setsphere_tween=force
   ```

   ![750px-Setsphere_pixelate_3.png](https://wiki.catznip.com/images/thumb/a/a3/Setsphere_pixelate_3.png/750px-Setsphere_pixelate_3.png)

## #RLV文件夹

\#RLV 允许将专门命名的库存优惠直接放入您的 #RLV 文件夹 中，而不是库存的根目录中。其目的通常是通过脚本将项目附加到您的头像（例如，转换您的头像的对象），一些脚本编写者已使用它来创建自动执行所有必需设置的产品安装程序。

一个化身可以将库存直接提供给另一化身的 #RLV文件夹 。如果目标化身的库存受到限制，或者您希望在尽可能少地参与的情况下附加一个物品，这可能特别有用。将项目放置在名为“#RLV/~folder_name”的文件夹中，并将该文件夹传递给目标。如果他们接受，它将出现在他们的 #RLV 文件夹中，准备通过附件（例如项圈）附加。

将项目文件夹直接传递到目标头像的 #RLV 文件夹中 可以使用llGiveInventoryList 。从 RLVa 1.4.10（Catznip R9 和 Firestorm 4.6）开始，如果 #RLV 文件夹不存在，将会创建它，请参阅 @version 了解如何确定这一点。

```lsl
llGiveInventoryList(id, "#RLV/~folder_name",items);
```

RLVa 1.4.10 的另一个变化是，可以提供最多 3 层深度的文件夹（从 #RLV 根开始），并根据需要创建所有前面的子文件夹。

```lsl
llGiveInventoryList(id, "#RLV/~Level1/Level2/Level3",items);
```

最佳实践注意： 建议 强烈 检查是否接受 您在每次库存报价后使用@notify ，否则可能会创建重复的子文件夹。请参阅示例脚本 Give_to_#RLV\_(LSL)。

### \#RLV (LSL)

此示例脚本演示了向脚本所有者 #RLV 文件夹 提供一个文件夹并检查是否成功接受。

### 指示

- 重新启动 prim 并添加以下脚本。
- 触摸古板。
- 您将获得一个包含脚本副本的文件夹，该脚本使用 Give to #RLV 将内容直接放入 #RLV 文件夹 中。
- @notify 用于在库存被接受时通知脚本。
- 如果您不接受，脚本将超时并发出通知。

### 笔记

- 才能发出命令的成品（例如变形玩具）中使用 该脚本不适合在需要访问RLV 继电器 ，但足以演示您自己所需的技术。
- 为了方便起见，脚本提供了自身的副本，这是唯一肯定会出现在 prim 中的东西，并且您不能提供空文件夹。在实际使用中，你可能不想这样做。

```lsl
// Example Script - Give to #RLV with @notify
// Copyright (C) 2014 Catznip Viewer (http://catznip.com)
// Released under the MIT Licence (http://opensource.org/licenses/MIT)

// Documentation
// http://catznip.com/index.php/Give_to_♯RLV_(LSL)


// Constants
string  FOLDER_NAME = "~TestFolder";
integer NOTIFY_CHANNEL = 12345;

// Global variables
integer ListenHandle = 0;

// Functions
CleanupInventoryOffer()
{
    // Remove the RLV notification (if you have multiple @notify you don't want to use clear)
    llOwnerSay("@clear=notify");

    // Clean up the listen and mark it as unused so we can process another inventory offer
    llListenRemove(ListenHandle);
    ListenHandle = 0;
    
    // Stop our time
    llSetTimerEvent(0.0);
}

default
{
    state_entry()
    {
    }

    touch_start(integer total_number)
    {
        // This is a simple script and we'll only handle one inventory offer at a time
        if (ListenHandle != 0)
        {
            llSay(0, "Waiting for previous offer to be accepted. Try again later");
            return;
        }
        
        // Get the key of the (first) avatar who touched us
        key avKey = llDetectedKey(0);
        // For demo purposes we'll only allow you to touch; normally you'll need to go through the toucher's relay
        if (avKey != llGetOwner())
        {
            llSay(0, "Only the owner of this prim can try this demo.");
            return;
        }
        
        // Set up the listen so we'll know when the avatar accepts/rejects the folder
        ListenHandle = llListen(NOTIFY_CHANNEL, "", avKey, "");
        // Time-out waiting for user to accept the folder after 2 minutes
        llSetTimerEvent(120);
        // Set up an RLV notfication to monitor folder messages
        llOwnerSay("@notify:" + (string)NOTIFY_CHANNEL + ";inv_offer=add");
        
        llSay(0, "Offering folder " + FOLDER_NAME + " to secondlife:///app/agent/" + (string)avKey + "/about");
        
        // Actually offer the folder (with only this script for contents)
        llGiveInventoryList(avKey, "#RLV/" + FOLDER_NAME, [ llGetScriptName() ]);
    }
    
    listen(integer channel, string name, key id, string message)
    {
        // Check if this response came in on the RLV listen channel
        if (NOTIFY_CHANNEL == channel)
        {
            list response = llParseString2List(message, [ " " ], []);
            
            string behaviour = llList2String(response, 0);
            if ("/accepted_in_rlv" == behaviour)
            {
                llSay(0, "User accepted the folder in their #RLV folder");
                CleanupInventoryOffer();
            }
            else if ("/accepted_in_inv" == behaviour)
            {
                llSay(0, "User accepted the folder in their regular inventory (Forbid Give-to-#RLV is enabled)");
                CleanupInventoryOffer();
            }
            else if ("/declined" == behaviour)
            {
                llSay(0, "User declined the offered inventory");
                CleanupInventoryOffer();
            }
        }
    }
    
    timer()
    {
        if (ListenHandle != 0)
        {
            llSay(0, "User did not accept or decline the inventory offer in a timely fashion");
            CleanupInventoryOffer();
            return;
        }
    }
}
```

## RLVa 草稿页

https://wiki.catznip.com/index.php?title=RLVa_Scratch_Page

### @findfolders:<匹配>[;<分隔符>]=<通道>

- 以逗号分隔列表的形式返回共享 #RLV 根下与指定文本匹配的所有文件夹。

### @interact< n|y >

- 阻止所有世界交互，包括但不限于选择或右键单击世界中的对象或人物、附件（自身或其他），并绕过所有编辑或触摸异常。
- 它不会妨碍自身上下文菜单、使用键盘+鼠标、鼠标转向或将库存拖放到附近的化身（但不包括物体）上来定位/移动/聚焦相机控制。
- 预期效果类似于覆盖透明 HUD 的全屏，z 位置将其放置在所有其他 HUD 后面。

### @sharedwear< n|y > / @sharedunwear< n|y >

- 阻止任何事情（通过用户操作或来自任何脚本对象）分别佩戴或脱下共享 #RLV 根中包含的任何物品。

### @touchhud[:<uuid>]< n|y >

- 阻止接触任何磨损的 HUD 附件，但通过 @touchhud:<uuid> 或 @touchme:<uuid> 特别豁免的附件除外。
- 注意：例外仅在根 prim 上有效；例如，不可能阻止对 HUD 上除一个按钮之外的所有按钮的访问。

### @tprequest[:<代理>]< n|y >

- 阻止用户请求传送，除非特别豁免（有严格变体）。有关详细信息，请参阅@tplure[:<agent>]=<n|y>。

### @accepttprequest[:<代理>]< n|y >

- 当没有选项使用时，所有传入的传送请求都将被自动接受；当与特定键一起使用时，只有该人传入的传送请求才会被自动接受（有严格的变体）。有关详细信息，请参阅@accepttp[:<agent>]=<n|y>。

### @sendgestures< n|y >

- 防止用户播放或触发任何活动手势。

## RLVa 2.0 发行说明

https://wiki.catznip.com/index.php?title=RLVa_2.0_Release_Notes

### 旧版 RLVa 命令形式化

以下所有命令在以前版本的 RLVa 中都可用，但从未真正正式记录。它们的行为现已最终确定，不再需要更改，可以安全地在产品中使用（如果您需要知道特定命令的可用时间，请发送 IM Kitty Barnett）。

- 类似 @findfolders:<filter>=<channel> - 与@@findfolders ，但将返回所有匹配项，而不是仅返回第一个匹配项
  - 示例：@findfolders:gag=0 将列出与“gag”匹配的所有文件夹
- @getcommand[:<behaviour>[;<type>[;<separator>]]]=<channel> - 可用于查询命令是否受支持且当前已启用（有关更多详细信息，请参阅文档）
  - 示例：@getcommand:setcam;force=0 列出所有@setcam强制命令
- @getdebug - 可用于查询（但不能设置）以下附加调试设置： RestrainedLoveforbidGiveToRLV 、 RestrainedLoveNoSetEnv 和 WindLightUseAtmosShaders 。
- @interact = < n|y > - 阻止世界交互，但允许拖放、相机工具、鼠标转向和访问“自身”上下文菜单
- @sharedwear = < n|y > - @unsharedwearwear 的对应部分锁定共享 ♯RLV 文件夹
- @unsharedwear = < n|y > - @unsharedunwear 的对应项删除锁定共享 ♯RLV 文件夹
- @touchhud [:< object >] = < n|y > - 防止用户触摸其磨损的 HUD 附件（有例外）
- @tprequest [: <agent> ] = < n|y > - 阻止用户向除例外列表中的用户之外的任何人请求传送（具有严格变体）
- @accepttprequest [: <agent> ] = < n|y > - 当不带选项使用时，所有传入的传送请求将被自动接受；当与特定键一起使用时，该人传入的传送请求将被自动接受（有严格的变体）

### 新命令

- @sendgesture = < n|y > - 阻止用户发送/播放手势
- @sendchannel_ except [:<channel>] = < n|y > 类似 - 与@sendchannel [:<channel>] ，允许用户在除定义为例外的频道之外的所有频道上聊天（与 @sendchannel 累积）
- @showself = < n|y > - 隐藏用户的头像及其所有附件（仅在屏幕上）；旨在与相机原点锁定一起使用
- @showselfhead = < n|y > - 仅隐藏用户头像的头部及其所有附件（仅在屏幕上）；旨在与相机原点锁定一起使用
- @tplocal = < n|y > - 限制本地传送（通过双击或位置传送）而不影响坐距

### 命令扩展

- @detachthis:<uuid>=force - 通过 UUID 强制分离附件（及其包含的文件夹）（如果它包含在共享 #RLV 文件夹下）
- @fartouch:<dist>=n|y - @fartouch 将用户限制在指定的距离（而不是默认的 1.5m）
  - 示例：@fartouch:20=n - 将触摸限制在用户的 20m 半径范围内
- @remattach:<uuid>=force - 通过 UUID 强制分离附件
- @sendchannel_except[:<channel>]=n|y - 仅阻止使用指定的通道（与 @sendchannel 相反 - 两个限制同时起作用）
- @sittp:<dist>=n|y - @sittp 用指定的距离限制用户（而不是默认的 1.5m）
- @shownames:<uuid>=n|y - 允许 @shownames 例外（除例外列表中的名称外，所有名称均匿名）
- @shownametags:<uuid>=n|y - 允许 @shownametags 例外（除了例外列表中的标签外，所有标签均被隐藏）
- @shownearby=n|y - 从查看器 UI 中删除附近头像存在的可见性（清空“附近的人”选项卡 - 雷达 - 语音浮动框并从所有悬停文本中删除（匿名）提及附近的头像）
- @tplocal:<dist>=n|y - 仅允许在指定距离内进行本地传送（默认为 256m）
- @tpto:<position>;<lookat>=force - 将用户传送到指定的全局坐标，并在到达时以指定的旋转（以弧度为单位）
- @tpto:<region>/<vector3>[;<lookat>]=force - 将用户传送到区域上的指定坐标（替代提供全局坐标）
  - 示例：@tpto:Kara/128/128/50;-1.57=force - 传送到 Kara 128,128,50（朝南）

（似乎在接下来的 3 个版本中，在最初编写这些内容和在发布时进行测试之间存在一个错误，因此不同地区的人们总是会被阻止，因此这些目前仅在设置了最小距离的情况下无法使用 - 将在下一个版本中修复）

- @recvim:<min-dist>[;<max-dist>]=n|y - 用户只能接收来自指定范围内的人的 IM（请参阅文档以获取示例）
  - 示例：@recvim:0,20=n - 用户只能接收聊天范围内 (20m) 内的人发来的 IM
- @sendim:<min-dist>[;<max-dist>]=n|y - 用户只能向指定范围内的人员发送 IM（有关示例，请参阅文档）
  - 示例：@sendim:256=n - 用户只能向至少一个区域之外 (256m) 的人发送 IM
- @startim:<min-dist>[;<max-dist>]=n|y - 用户只能与指定范围内的人员启动 IM 会话（有关示例，请参阅文档）
  - 示例：@startim:0,256=n - 用户只能向位于同一区域的人启动 IM（0moh oh 到 256m 之间）

### 相机命令

- **[@setcam ](https://wiki.catznip.com/index.php?title=Camera_Commands#setcam)= < n|y >** - 赋予对象对相机的独占控制（仅执行该对象的限制或限制）

- **@setcam_avdistmin [:< distance >] = < n|y >** - 强制相机位置和用户头像之间的最小距离（以米为单位）

- **@setcam_avdistmax [:< distance >] = < n|y >** - 强制相机位置和用户头像之间的最大距离（以米为单位）

- **@setcam_origindistmin [:< distance >] = < n|y >** - 强制（默认）相机原点和相机位置之间的最小距离（请参阅文档）

- **@setcam_origindistmax [:< distance >] = < n|y >** - 强制（默认）相机原点和相机位置之间的最大距离（请参阅文档

- **[@setcam_eyeoffset ](https://wiki.catznip.com/index.php?title=Camera_Commands#setcam_eyeoffset)[:<vector3>] = force** - 设置当前相机原点偏移（请参阅文档）

- **[@setcam_eyeoffset ](https://wiki.catznip.com/index.php?title=Camera_Commands#setcam_eyeoffset)[:<vector3>] = < n|y >** - 设置默认相机原点偏移（请参阅文档）

- **[@setcam_focusoffset ](https://wiki.catznip.com/index.php?title=Camera_Commands#setcam_focusoffset)[:<vector3>] = force** - 设置当前相机焦点偏移（请参阅文档）

- **[@setcam_focusoffset ](https://wiki.catznip.com/index.php?title=Camera_Commands#setcam_focusoffset)[:<vector3>] = < n|y >** - 设置默认相机焦点偏移（请参阅文档）

- [@setcam_focus ](https://wiki.catznip.com/index.php?title=Camera_Commands#setcam_focus):<uuid>|<position> [;<dist> [;<direction>] ] = force 

- 将相机焦点和原点移动到指定位置（通过对象/头像 UUID 或坐标） - 有关更多信息，请参阅文档

  - 示例： @setcam_focus:<uuid>;20;=force - 根据您之前的相机方向，聚焦于 20m 外的代理（获取您自己的 UUID）
  - @setcam_focus:<uuid>;;1/0/0=force - 聚焦在一个对象上（为此重新设置 prim 并获取其 UUID），这将导致相机沿着负片查看胶合板立方体（填充屏幕） X
  - （请通过单击上面的链接阅读有关此文档的完整文档 - 焦点锁定未及时完成，但将在下一版本中以相同的方式工作）

- **[@setcam_fov ](https://wiki.catznip.com/index.php?title=Camera_Commands#setcam_fov)[:< 角度 >] = 力** - 将相机的（垂直）视野设置为指定角度（以弧度为单位）

- **[@setcam_fovmin ](https://wiki.catznip.com/index.php?title=Camera_Commands#setcam_fovmin)[:<angle> ] = < n |y >** - 强制相机（垂直）视野的最小角度（以弧度为单位）

- **[@setcam_fovmax ](https://wiki.catznip.com/index.php?title=Camera_Commands#setcam_fovmax)[:< angle >] = < n|y >** - 强制相机（垂直）视野的最大角度（以弧度为单位）

- **@setcam_mode [:<mouselook>|<thirdperson>|<reset>] = force** - 将当前模式切换为 mouselook、第三人称或将其重置为默认视图（与用户点击 <esc> 相同）

- **@setcam_mouselook = < n|y >** - 防止用户进入 mouselook

- @setcam_textures [:<uuid>] = < n|y > 

  - 用指定的纹理替换所有纹理（如果未指定，则替换默认的灰色纹理）

  - 示例： @setcam_textures:796a4bef-e44d-3a5e-26ba-05cfd1e1634d=n

- @setcam_unlock=n - 将相机原点锁定到用户的头像（与 @setcam_origin:<uuid>=n 相同）

- @getcam_avdistmin=<频道> ; @getcam_avdistmax=<通道> ; @getcam_fovmin=<通道> ; @getcam_fovmax=<通道> 和 @getcam_textures=<通道> - 返回相应主动施加的限制（如果没有限制则返回空白）
- @getcam_avdist=<channel> - 返回相机位置和用户头像之间的当前距离（以米为单位）
- @getcam_fov=<channel> - 返回相机当前（垂直）场（以弧度为单位）

插图： 人们多次要求提供一些 RLVa 特定相机命令（特别是眼睛/焦点偏移命令）的示例，以给出如何使用它们的一些想法。下面将创建一个快速而粗糙的强制鼠标外观第三人称视角，具有凄凉的世界观和锁定到头像的相机（使用鼠标滚轮向上/向下查看）。

将以下内容作为一行复制/粘贴到 RLVa 控制台中：

```lsl
@setenv=n,setenv_preset:[TOR] FOGGY - Silent heck=force,setcam=n,setcam_textures:796a4bef-e44d-3a5e-26ba-05cfd1e1634d=n,setcam_fovmin:0.727=n,setcam_fovmax:0.727=n,showself=n,setcam_unlock=n,setcam_eyeoffset:-0.2/0.0/-0.3=n,setcam_focusoffset:0.0/0.0/0.9=n
```

### 兼容性垫片（@setcam_xxx 变体是首选）

- @camdistmin 映射到 @setcam_avdistmin
- @camdistmax 映射到 @setcam_avdistmax
- @camtextures 映射到 @setcam_textures
- @camunlock 映射到 @setcam_unlock
- @camzoommin 映射到 @setcam_fovmin ，角度 = 60° / 乘数
- @camzoommax 映射到 @setcam_fovmax ，角度 = 60° / 乘数

## RLVa 2.2 发行说明

### 新命令

- **@jump = < n|y >** 和 **@fly [:<true or false>] = force** （发布对象豁免）

- **@setgroup :<uuid>|<name>;<role> = 强制** ，因为兔子让我这么做

  - （使用新命令的保险杠的实际示例： https://i.imgur.com/9UmzRGB.gifv ）

- **@setoverlay** 某只邪恶小猫的命令集

  - （请注意，所有 setoverlay 修改命令都是强制命令，而不是 y|n 命令，以避免不必要地填充活动限制列表，而且还因为它在补间时没有意义 - 见下文）

- **@setoverlay = < n|y >** – 主命令；设置后，发出的对象对纹理覆盖具有独占控制权（如果另一个对象已经拥有控制权，则这将不执行任何操作，类似于 setenv/setdebug/setcam 的工作方式）

- **@setoverlay_texture :<uuid> = force** – 用指定的纹理覆盖整个屏幕。纹理的左上角将显示在屏幕的左上角，纹理的右下角将显示在屏幕的右下角。长宽比将是观看者世界视图的长宽比（当前无法设置重复值）并且纹理将始终渲染在所有 HUD 下方）

- **@setoverlay_tint :<颜色向量> = force** – 使用指定的颜色为覆盖纹理着色（即@setoverlay_tint:1/0/0=force 会将覆盖纹理着色为红色）

- **@setoverlay_alpha :<0..1> = force** – 使用指定的 alpha 值绘制覆盖纹理（不影响触摸 – 见下文）

- **@setoverlay_tween : [<alpha>] ; [<tint>] ;<duration> = force** – 在 <duration> 秒内将 Alpha 和/或色调从当前值动画化为特定值。

  - 例如：

  - ```lsl
    @setoverlay=n,setoverlay_texture:<uuid>=force,setoverlay_alpha:0=force,setoverlay_tween:1;;30=force
    将设置一个最初不可见的覆盖纹理（alpha 0），并在接下来的 30 秒内在用户屏幕上淡入。
    ```

  - 多次发出此命令将使用当前值

- @setoverlay_touch = < n|y > – 控制用户是否可以通过纹理的 Alpha 部分触摸世界。默认情况下，覆盖层根本不会阻止世界交互（尽管用户可能无法看到他们正在触摸/选择的内容）。使用此命令集，所有（几乎）完全透明的像素将允许世界交互。

  - 在以下示例中，用户将能够与他们可以看到的世界（框架的中心部分）进行交互，但如果他们左/右键单击框架边框上的任意位置，则该单击将被忽略。
  - ![RlvaSetOverlayTouch.png](https://wiki.catznip.com/images/5/5d/RlvaSetOverlayTouch.png)

- 现有的命令（集）是固定的，但随着人们建议或想到新的/有趣的/不同的用途，未来的版本中将会添加一些内容。

## RLVa 2.3 发行说明

### 新命令

- **@buy = < n|y >** 防止购买设置为“待售”的对象或支付脚本对象（例如供应商）
- **@pay = < n|y >** 防止直接通过“支付”上下文菜单向另一个头像付款
- @versionnum:impl=<channel> 允许您将活动的 RLV 实现版本查询为 <major>\<minor:02\>\<patch:02\><implementation id:02>

由于新命令已经有一段时间没有与特定规范版本绑定了，所以检查用户正在使用的实际 RLV 实现而不是规范版本更有意义（如果您有兴趣检查此类内容）。自此版本起，RLVa 返回 2030013。

### 相机

- **@setcam_eyeoffsetscale :<multiplier> = < n|y >** 和 **@setcam_eyeoffsetscale :<multiplier> = force** 是根据新的 Linden Lab 相机预设功能添加的（有关说明，请参阅官方查看器文档）
- 取得相机的所有权（通过 **[@setcam ](https://wiki.catznip.com/index.php?title=Camera_Commands#setcam)= < n|y >** ）现在将保留当前相机偏移、相机偏移比例和焦点偏移，并恢复用户在释放时的偏好
- 释放 **[@setcam_eyeoffset ](https://wiki.catznip.com/index.php?title=Camera_Commands#setcam_eyeoffset)**、 **@setcam_eyeoffsetscale** 或 **[@setcam_focusoffset ](https://wiki.catznip.com/index.php?title=Camera_Commands#setcam_focusoffset)**（不释放其他）会将该修改器重置为发出第一个眼睛/焦点限制命令时的值（因此始终一起设置和释放这三个；另请参阅下面的注释） 。
- 许多相机命令已经毕业，不再具有实验标签（这意味着它们不会消失或功能随机改变）：
  - @setcam_eyeoffset（两个版本）
  - @setcam_eyeoffsetscale（两个版本）
  - @setcam_focusoffset（两个版本）

**注意** ：相机预设功能现在使用户更有可能拥有非默认相机，因此请始终设置@setcam_eyeoffset **和** @setcam_focusoffset（以及新的@setcam_eyeoffsetscale）。

### 风灯/EEP

作为 EEP 的一部分添加的新 Windlight 设置都有自己的命令：

- **@setenv_asset :<日周期/天空/水资产 uuid> = 强制**
- **@setenv_cloudtexture :<uuid> = 强制** 和 **@getenv_cloudtexture**
- **@setenv_cloudvariance :< float > = 强制** 和 **@getenv_cloudvariance**
- **@setenv_sunscale :< float > = 强制** 和 **@getenv_sunscale**
- **@setenv_suntexture :<uuid> = 强制** 和 **@getenv_suntexture**
- **@setenv_sunazimuth :<弧度> = 力** 和 **@getenv_sunazimuth**
- **@setenv_sunelevation :<弧度> = 力** 和 **@getenv_sunelevation**
- **@setenv_moonbrightness :< float > = 力** 和 **@getenv_moonbrightness**
- **@setenv_moonscale :< float > = 强制** 和 **@getenv_moonscale**
- **@setenv_moontexture :<uuid> = 强制** 和 **@getenv_moontexture**
- **@setenv_moonazimuth :<弧度> = 力** 和 **@getenv_moonazimuth**
- **@setenv_moonelevation :<弧度> = 力** 和 **@getenv_moonelevatio**
- **@setenv_dropletradius :< float > = 强制** 和 **@getenv_dropletradius**
- **@setenv_icelevel :< float > = 强制** 和 **@getenv_icelevel**
- **@setenv_moisturelevel :< float > = 力** 和 **@getenv_moisturelevel**

继续使用 **@setcam_preset** 和 **@setcam_daycycle** 如果可能的话，应该避免 。过去随查看器一起提供的 Windlight 预设现在存储在查看器的库清单文件夹中，但用户可以选择阻止该库，即使该库可用，在您发出命令时也可能尚未（完全）获取该库。此外，如果 Linden Lab 移动了文件夹，或者决定更改默认提供的预设，您的脚本同样会开始出现故障。也就是说，它将继续像以前一样工作，只是现在命令的选项是出现在该特定库文件夹下的任何环境设置（您不必包含文件夹名称，只需包含预设名称）。

**@setenv_asset :<asset uuid> = force** 将允许您切换到您选择的任何 Windlight 环境（并添加水作为附带好处），并且具有将 40 个 RLV @setenv_XXX 命令的序列简化为单个命令的主要好处，如果您只需创建一个新的 Windlight 环境，然后使用 @setenv_asset:my_uuid_here=force 即可。

**@setenv_eastangle** 和 **@setenv_sunmoonpos** 已替换为 **@setenv_sunazimuth :<radians> = 力** 和 **@setenv_sunelevation :<radians> = 力** （以及 **@setenv_moonazimuth :<radians> = 力** 和 **@setenv_moonelevation :<radians> = 力** 月球 ）。在 EEP 之前，太阳的位置由两个旋转角度决定，每个旋转角度的范围为 360°，这意味着太阳的位置实际上总是可以用 2 种方式表示：如果东角为 A，sunmoonpos 为 B，则东角为 A - 0.25 (-90 °) 和 B - 0.50 (-180°) 的 sunmoonpos 将太阳置于同一位置。

在 EEP 中，太阳的位置是四元数，因此不再总是能够恢复旧的 eastangle 和 sunmoonpos，或者设置它们可能会将太阳置于与您预期不同的位置，具体取决于您使用的值。继续前进，应该使用方位角/仰角命令，只需将方位角视为将太阳/月亮置于所需风向（NESW）的角度，然后仰角将决定太阳/月亮在天空中出现的高度（或将值翻转为负数以将它们置于地平线以下）。

如果 sunmoonpos 位于 -PI/2 到 PI/2 范围内，则旧值将正确报告，而当 sunmoonpos > PI/2 时，旧值将不正确。同样，设置 sunmoonpos/eastangle 时：

- sunmoonpos 没有 eastangle (=0) => 始终正确
- eastangle 没有 sunmoonpos (=0) => 始终正确
- sunmoonpos 之前的 eastangle => 始终正确
- sunmoonpos 位于 eastangle 之前 => 对于 -0.25 <= sunmoonpos <= 0.25 正确，对于 0.75 > sunmoonpos > 0.25 错误

如果有任何不清楚的地方，请给我一个机会，我会尽力使它更清楚。同时：使用 Windlight 漂浮物将太阳移动到您希望它出现的位置，然后发出 @getenv_[sun|moon][azimuth|elevation] 来获取脚本的值。

最后，为了减少设置颜色和基于矢量的值所需的命令量，添加了以下简写子命令：

- **@setenv_ambient :<向量> = 力** 和 **@getenv_ambient**

- **@setenv_blue密度 :<向量> = 力** 和 **@getenv_blue密度**

- **@setenv_bluehorizo n :<向量> = 力** 和 **@getenv_bluehorizon**

- **@setenv_cloudcolor :<向量> = 力** 和 **@getenv_cloudcolor**

- **@setenv_cloud Density :<向量> = 力** 和 **@getenv_cloudDensity** （替换云）

- **@setenv_clouddetail :<向量> = 强制** 和 **@getenv_clouddetail**

- **@setenv_cloudscroll :<向量> = 强制** 和 **@getenv_cloudscroll**

- **@setenv_sunlightcolor :<向量> = 强制** 和 **@getenv_sunlightcolor** （替换 sunmooncolor）

- 示例：

  - ```lsl
    @setenv_bluedensityr:0.5=force,setenv_bluedensityg:0.75=force,setenv_bluedensityb:0.1=force
    现在可被替换为：
    @setenv_bluedensity:0.5/0.75/0.1=force
    ```

## RLVa 2.4 1 发行说明

### 新命令

（这使 RLVa 与海军陆战队最近添加到 RLV 的一些命令保持同步）

- **@editattach = < n|y >** 防止编辑附件
- **@editworld = < n|y >** 防止编辑重新调整/世界中的对象
- **@share = < n|y >** 防止将库存掉落到其他化身（但不包括物体）上/与其他化身共享库存
- **@share :<uuid> = < add|rem [\* ](https://wiki.catznip.com/index.php?title=Deep_Notes#ny)>** 添加例外以允许与指定的 avater 共享库存
- **@touchattachother :<uuid> = < add|rem [\* ](https://wiki.catznip.com/index.php?title=Deep_Notes#ny)>** 防止触摸特定头像的附件

- **@sitground = force** 强制头像坐地（RLVa 中已经可用， **@sit = force** 将继续工作）

- @notify 已扩展为用户坐下或站立时发出警报的脚本

- ```lsl
  /sat ground legally (Right-clicked ground / Sit)
  /unsat ground legally (Clicked Stand Up)
  /sat object legally 8ede3ff4-3a35-b386-0820-ff5be4bb3a83 (Sat on a prim)
  /unsat object legally 8ede3ff4-3a35-b386-0820-ff5be4bb3a83 (Clicked Stand Up)
  /unsat object illegally 8ede3ff4-3a35-b386-0820-ff5be4bb3a83 (llDie() on the sat prim while @unsit=n restricted)
  ```

### 变化

- @setoverlay 现在基于每个对象而不是基于每个 prim 工作。
  - 这意味着您可以在同一个对象中堆叠多个覆盖（顺序是固定的，由每个覆盖 prim 的链接号确定）。每个单独的叠加层都可以独立于任何其他活动叠加层运行活动补间和/或块触摸。
- **@sit = force** 现在强制用户站起来，然后强制他们在已经坐着的情况下坐在地面上（以前用户会继续坐着，但什么也没有发生）
  - 这样做是为了与 **@sitground = force保持一致**
- RLVa 控制台输入更改为扩展文本输入（类似于附近聊天和 IM 聊天输入的工作方式）


























































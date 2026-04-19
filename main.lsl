initMain(){
    // Init Config
    sitPos=<0.0, 0.0, -0.2>;
    sitRot=ZERO_ROTATION;
    sitAutoLock=FALSE;
    sitAutoTrap=FALSE;
    sitText="";
    showText=TRUE;
    lockSound="lock";
    unlockSound="unlock";
    touchSound="touch";
    soundVolume=1.0;
    allowPermaLock=FALSE;
    // Init Config End

    RLV_READY=FALSE;
    RENAMER_READY=FALSE;
    ACCESS_READY=FALSE;
    TIMER_READY=FALSE;
    LEASH_READY=FALSE;
    ANIM_READY=FALSE;
    STRUGGLE_READY=FALSE;
    TEXT_READY=FALSE;
    hasLanguage=FALSE;

    llOwnerSay("Begin Initialize...");
    list initMessageLinkChain=[
        MAIN_MSG_NUM, "MAIN.INIT", 0.25,
        RLV_MSG_NUM, "RLV.RUN.TEMP|detach=n", 0.25, // 首次初始化时，先将道具上锁，待初始化完（Access、RLV）后，根据结果更改上锁状态
        RLV_MSG_NUM, "RLV.LOAD|main", 0,
        RENAMER_MSG_NUM, "RENAMER.LOAD|main", 0,
        ACCESS_MSG_NUM, "ACCESS.LOAD|main", 0,
        LAN_MSG_NUM, "LANGUAGE.INIT", 0,
        TIMER_MSG_NUM, "TIMER.LOAD|main", 0,
        LEASH_MSG_NUM, "LEASH.LOAD|main", 0,
        ANIM_MSG_NUM, "ANIM.LOAD|main", 0,
        STRUGGLE_MSG_NUM, "STRUGGLE.LOAD|main", 0,
        TEXT_MSG_NUM, "TEXT.GET.READY", 0
    ];
    integer i;
    for(i=0; i<llGetListLength(initMessageLinkChain); i+=3){
        llMessageLinked(LINK_SET, llList2Integer(initMessageLinkChain, i), llList2String(initMessageLinkChain, i+1), NULL_KEY);
        llSleep(llList2Float(initMessageLinkChain, i+2));
    }
    // llMessageLinked(LINK_SET, LAN_MSG_NUM, "LANGUAGE.INIT", llGetOwner()); // 得到语言系统初始化确认时，将hasLanguage置为TRUE。
    if(llGetAttached()){
        llRequestPermissions(llGetOwner(), PERMISSION_ATTACH);
    }
    llSitTarget(sitPos, sitRot);
    llSetSitText(sitText);
    listenHandle=llListen(cmdChannel, "", NULL_KEY, "");
    // llSleep(0);
    // llOwnerSay("Initialize Complete, Enjoy!");
}

triggerFeature(string featureName, string text, key user){
    if(featureName=="ATTACH"){
        if(user!=NULL_KEY){
            if(RLV_READY==FALSE){ // 穿戴时，如果未成功初始化数据，则重新读取
                initMain();
                llSetTimerEvent(initRetryTimer);
            }
            // if(autoLock==TRUE){
            //     if(lockUser!=NULL_KEY){
            //         setLock(TRUE, lockUser, FALSE);
            //     }else if(llGetListLength(owner)>=1){
            //         setLock(TRUE, llList2Key(owner, 0), FALSE);
            //     }
            // }
            attachFlag=TRUE;
            llRequestPermissions(user, PERMISSION_ATTACH);
            listenHandle=llListen(cmdChannel, "", NULL_KEY, "");
        }else{
            llListenRemove(listenHandle);
        }
    }
    else if(featureName=="TOUCH"){
        showMenu("mainMenu", llDetectedKey(0));
        if(touchSound!="" && (llGetInventoryType(touchSound)==INVENTORY_SOUND || llStringLength(touchSound)==36)){
            llPlaySound(touchSound, soundVolume);
        }
    }
    else if(featureName=="COLLISION"){
        if(REZ_MODE==TRUE && sitAutoTrap==TRUE && VICTIM_UUID == NULL_KEY){
            key victim=llDetectedKey(0);
            llMessageLinked(LINK_SET, RLV_MSG_NUM, "RLV.CAPTURE|"+(string)victim+"|1", NULL_KEY);
        }
    }
    else if(featureName=="CHANGE"){
        if((integer)text & CHANGED_INVENTORY){
            initMain();
        }
        if ((integer)text & CHANGED_LINK) {
            if (user != NULL_KEY){
                VICTIM_UUID=user;
                if(sitAutoLock==TRUE){
                    // 自动上锁时，APPLY.ALL交给LockConnect完成
                    if(captureByUser!=NULL_KEY){
                        setLock(TRUE, captureByUser, FALSE);
                        captureByUser=NULL_KEY;
                    }else{
                        setLock(TRUE, llList2Key(owner, 0), FALSE);
                    }
                }else{
                    llMessageLinked(LINK_SET, RLV_MSG_NUM, "RLV.APPLY.ALL", NULL_KEY);
                }
                if(showText==TRUE && VICTIM_UUID!=NULL_KEY){
                    llMessageLinked(LINK_SET, TEXT_MSG_NUM, "TEXT.SET|Victim|"+llGetDisplayName(VICTIM_UUID)+" ("+llGetUsername(VICTIM_UUID)+")|"+(string)showText+"|TOP", NULL_KEY);
                    llMessageLinked(LINK_SET, TEXT_MSG_NUM, "TEXT.SET|Locked|%b1%Locked%%;"+(string)isLocked+"|1|Victim", NULL_KEY);
                    // llMessageLinked(LINK_SET, TEXT_MSG_NUM, "TEXT.SET|Victim|%1%\n%b2%Locked%%;"+llGetDisplayName(VICTIM_UUID)+" ("+llGetUsername(VICTIM_UUID)+");"+(string)isLocked+"|1", NULL_KEY);
                }else{
                    llMessageLinked(LINK_SET, TEXT_MSG_NUM, "TEXT.REM|Victim", NULL_KEY);
                    llMessageLinked(LINK_SET, TEXT_MSG_NUM, "TEXT.REM|Locked", NULL_KEY);
                }
            }else{
                setLock(FALSE, NULL_KEY, FALSE);
                VICTIM_UUID=NULL_KEY;
                llMessageLinked(LINK_SET, TEXT_MSG_NUM, "TEXT.REM|Victim", NULL_KEY);
                llMessageLinked(LINK_SET, TEXT_MSG_NUM, "TEXT.REM|Locked", NULL_KEY);
                llSleep(1.0);
            }
        }
    }
    else if(featureName=="mainMenu"){
    }
}
triggerListen(integer channel, string name, key id, string message){
    if(channel==cmdChannel){
        string prefix=llGetSubString(llGetUsername(llGetOwner()), 0, 1);
        if(llGetSubString(message, 0, 1) == prefix){
            key user=llGetOwnerKey(id); // 支持使用物品发出命令。user为说话者的uuid，因此需要获取它的所有者uuid。
            if(!allowOperate(user)){
                return;
            }
            // /1 xxmenu, /1 xxleash
            string msgBody=llToLower(llGetSubString(message, 2, -1));
            list msgList=llParseStringKeepNulls(msgBody,[" "],[""]);
            string msgCmd1=llList2String(msgList, 0);
            string msgCmd2=llList2String(msgList, 1);
            string msgCmd3=llList2String(msgList, 2);

            if(msgCmd1=="menu"){
                showMenu("mainMenu", user);
            }
            else if(msgCmd1=="leash"){
                llMessageLinked(LINK_SET, LEASH_MSG_NUM, "LEASH.TO|"+(string)user, user);
            }
            else if(msgCmd1=="follow"){
                llMessageLinked(LINK_SET, LEASH_MSG_NUM, "LEASH.TO|"+(string)user+"|0", user);
            }
            else if(msgCmd1=="yank"){
                llMessageLinked(LINK_SET, LEASH_MSG_NUM, "LEASH.YANK|"+(string)user, user);
            }
            else if(msgCmd1=="unleash" || msgCmd1=="unfollow"){
                llMessageLinked(LINK_SET, LEASH_MSG_NUM, "LEASH.TO|", user);
            }
        }
        // llOwnerSay("NAME: "+name+" MSG: "+message);
    }
}
triggerLinkMessage(integer sender_num, integer num, string str, key user){
}
list getMenuFeature(string menuName, key user){
    list menuList;
    if(menuName=="mainMenu"){
        integer curTime=llGetUnixTime();
        string lockTimeDist=getTimeDistStr(lockTime, curTime);
        if(lockTimeDist!=""){
            lockTimeDist="\n"+getLanguageVar("Time: %1%%%;"+lockTimeDist);
        }

        menuList=[
            "Locked: %1% %2%\nOwner: %3%\nPublic: %b4%\nGroup: %b5%\nHardcore: %b6%%%;"+
            userInfo(lockUser)+";"+
            lockTimeDist+";"+
            userInfo(llList2String(owner, 0))+";"+
            // llDumpList2String(getOwnerNameList(), ", ")+";"+
            (string)public+";"+
            (string)group+";"+
            (string)hardcore
        ];

        if(RLV_READY){
            string lockStr="["+(string)isLocked+"]Lock";
            if(allowPermaLock==TRUE && isPermaLocked==TRUE){
                lockStr="PermaLocked";
            }
            if(REZ_MODE==TRUE){
                string captureStr="Capture";
                if(VICTIM_UUID!=NULL_KEY){
                    captureStr="Unsit";
                }
                menuList+=[lockStr, captureStr, "RLV"];
            }else{
                menuList+=[lockStr, "RLV"];
            }
        }
        if(LEASH_READY && REZ_MODE==FALSE){
            menuList=llListInsertList(menuList, ["Leash"], 2); // 0: desc, 1: Lock, 2: Leash
        }
        if(TIMER_READY){
            menuList+=["Timer"];
        }
        if(RENAMER_READY){
            menuList+=["Renamer"];
        }
        if(ANIM_READY){
            menuList+=["Animation"];
        }
        if(ACCESS_READY){
            menuList+=["Access"];
        }
        if(llGetListLength(featureList)>0 && ~llListFindList(featureList, ["appMenu"])){
            menuList+=["Apps"];
        }
        menuList+=["Settings"];
        if(llGetListLength(featureList)>0 && ~llListFindList(featureList, ["mainMenu"])){
            menuList=applyFeatureList(menuName, menuList, featureList);
        }
    }

    else if(menuName=="appMenu"){
        menuList=applyFeatureList(menuName, ["This is apps menu."], featureList);
    }

    else if(menuName=="settingMenu"){
        menuList=["This is settings menu."];
        if(hasLanguage){
            menuList+=["Language"];
        }
        if(REZ_MODE==TRUE && RLV_READY){
            menuList+=["["+(string)sitAutoLock+"]AutoLock", "["+(string)sitAutoTrap+"]AutoTrap"];
            if(TEXT_READY){
                menuList+=["["+(string)showText+"]ShowText"];
            }
        }

        if(allowPermaLock==TRUE && isPermaLocked==FALSE && isLocked==TRUE && lockUser==user && ~llListFindList(owner, [(string)user]) && hardcore==TRUE && REZ_MODE==FALSE && RLV_READY){
            // 允许永久锁定 && 未被永久锁定 && 已上锁 && 操作者为上锁者 && 操作者在主人列表中 && 非REZ模式 && RLV就绪
            menuList+=["PermaLock"];
        }
        menuList=applyFeatureList(menuName, menuList, featureList);
    }
    return menuList;
}
/*CONFIG END*/
/*
Name: Main
Author: JMRY
Description: A main controller for restraint items.

***更新记录***
- 1.1.14 20260420
    - 修复主菜单主人显示不正常的bug。

- 1.1.13 20260419
    - 加入\NL不进行语言匹配功能。
    - 优化ShowText的显示逻辑。

- 1.1.12 20260416
    - 修复周围没有玩家时，无法弹出选择玩家对话框的bug。
    - 修复使用uuid作为声音时，无法播放的bug。

- 1.1.11 20260406
    - - 优化REZ模式下的各种处理逻辑。

- 1.1.10 20260404
    - 加入永久锁定功能。
    - 优化设置菜单显示内容。

- 1.1.9 20260402
    - 自定义菜单功能支持注册在不同菜单中。
    - 加入默认音频并自动检测是否存在。
    - 修复REZ模式下，无人时上锁判断错误的bug。

- 1.1.8 20260324
    - 加入自定义“坐在这里”文本功能。

- 1.1.7 20260321
    - 加入REZ模式下的文字显示。
    - 优化代码结构。

- 1.1.6 20260319
    - 加入音效的音量参数。
    - 加入计时器读取记事卡功能。

- 1.1.5 20260313
    - 优化REZ模式下，权限错误的bug。

- 1.1.4 20260311
    - 加入设置菜单。
    - 加入APP菜单。
    - 优化初始化流程。
    - 修复主菜单自定义功能失效的bug。

- 1.1.3 20260310
    - 加入脚本识别功能。
    - 优化脚本架构。

- 1.1.2 20260302
    - 加入REZ模式的菜单和捕获功能。

- 1.1.1 20260301
    - 加入自定义菜单功能的配置。

- 1.1 20260228
    - 优化代码结构，防止碎片化。
    - 优化挣扎系统判定条件，只有自己才能挣扎。

- 1.0.21 20260226
    - 加入挣扎功能。

- 1.0.20 20260213
    - 加入倒计时且锁定时，禁止访问菜单功能。

- 1.0.19 20260212
    - 优化初始化逻辑，加入启动监听的功能。

- 1.0.18 20260211
    - 优化内存占用。
    - 优化操作锁逻辑，操作锁关闭时，新的操作者会覆盖原来的操作响应。
    - 修复逃跑时，不能重置状态的bug。

- 1.0.17 20260208
    - 修复向频道1发送消息时，提示不可操作的bug。

- 1.0.16 20260203
    - 加入操作锁。

- 1.0.15 20260121
    - 加入配置脚本触发功能（仅示例）。
    - 优化内存占用。

- 1.0.14 20260119
    - 修复语言系统回调判定错误的bug。

- 1.0.13 20260118
    - 加入穿戴时，初始化先上锁功能。
    - 加入Access记事卡读取状态检测功能。

- 1.0.12 20260116
    - 优化初始化逻辑，防止丢失部分初始化项目。
    - 调整初始化重试时间为30秒。

- 1.0.11 20260115
    - 加入动画菜单入口。
    - 加入物品发出命令的监听支持。

- 1.0.10 20260109
    - 加入牵绳功能入口。
    - 加入本地聊天命令功能。

- 1.0.9 20260106
    - 加入计时器和自动解锁功能。

- 1.0.8 20251206
    - 加入锁定时间的展示。
    - 修复在Access逃跑后，可能打开双重菜单的bug。

- 1.0.7 20251204
    - 加入逃跑后，自动解锁功能。
    - 修复上锁后，无法逃跑的bug。

- 1.0.6 20251202
    - 优化主脚本初始化和RLV数据读取机制，提升重置后读取成功率。

- 1.0.5 20251129
    - 加入菜单项注册功能。

- 1.0.4 20251128
    - 加入Renamer菜单。

- 1.0.3 20251127
    - 开放语言菜单。

- 1.0.2 20251122
    - 优化RLV记事卡的读取机制，防止重复读取。

- 1.0.1 20251120
    - 加入库存变化时重新读取RLV脚本功能。

- 1.0 20251115
    - 完成主要功能。
***更新记录***
*/

string userInfo(key user){
    return "secondlife:///app/agent/"+(string)user+"/about";
}

integer includes(string src, string target){
    integer startPos = llSubStringIndex(src, target);
    if(~startPos){
        return TRUE;
    }else{
        return FALSE;
    }
}

list strSplit(string m, string sp){
    list pl=llParseStringKeepNulls(m,[sp],[""]);
    list temp=[];
    integer i;
    for(i=0; i<llGetListLength(pl); i++){
        temp+=[llStringTrim(llList2String(pl, i), STRING_TRIM)];
    }
    return temp;
}

integer hasLanguage=FALSE;
string lanLinkHeader="LAN_";
string getLanguage(string k){
    if(!hasLanguage){
        return llReplaceSubString(k, "\\NL", "", 0);
    }
    if(llGetSubString(k, 0, 2)=="\\NL"){
		return llReplaceSubString(k, "\\NL", "", 0);
	}
    k=llReplaceSubString(llReplaceSubString(k,"\\n","\n",0),"\n","\\n",0); // 替换换行符\n。将转义的\\n替换回去再替换
    string curVal=llLinksetDataRead(lanLinkHeader+k);
    if(curVal){
        return llReplaceSubString(curVal,"\\n","\n",0);
    }else{
        return llReplaceSubString(k,"\\n","\n",0);
    }
}

string getLanguageVar(string k){ // 拼接字符串方法，用于首尾拼接变量等内容。格式：Text text %1 %2.%%var1;var2
    list ksp=llParseStringKeepNulls(k, ["%%;"], [""]); // ["Text text %1 %2.", "var1;var2"]
    string text=getLanguage(llStringTrim(llList2String(ksp, 0), STRING_TRIM));
    list var=strSplit(llList2String(ksp, 1), ";"); // ["var1", "var2"]
    integer i;
    for(i=0; i<llGetListLength(var); i++){
        integer vi=i+1;
        text=llReplaceSubString(text, "%"+(string)vi+"%", getLanguage(llList2String(var, i)), 0);
        text=llReplaceSubString(text, "%b"+(string)vi+"%", getLanguageBool(llList2String(var, i)), 0);
    }
    return text;
}

string defaultBoolStrList="◇|◆";
string boolStrList=defaultBoolStrList;
string getLanguageBool(string k){ // 拼接字符串方法之开关，根据传入字符串来判断开关并显示。格式：[0/1]BUTTON_NAME，返回：◇ 按钮名 / ◆ 按钮名
    //return getLanguageVar(k, LVPOS_BEFORE, llList2String(boolStrList,bool));
    list boolList=strSplit(boolStrList, "|");
    integer bool=FALSE;
    if(includes(k, "[1]")){
        bool=TRUE;
    }else if(includes(k, "[0]")){
        bool=FALSE;
    }else{
        bool=-1;
    }
    if(~bool){
        return llList2String(boolList, bool) + " " + getLanguage(llReplaceSubString(llReplaceSubString(k, "[1]", "", 0), "[0]", "", 0));
    }else{
        return getLanguage(k);
    }
}

integer applyLanguage(){
    string switchStr=getLanguage("ButtonSwitch"); // 更改开关样式。格式：关|开
    if(switchStr=="ButtonSwitch"){ // 如果返回的是buttonSwitch（即不存在此字段，则应用默认样式）
        boolStrList=defaultBoolStrList;
    }else{
        boolStrList=switchStr;
    }
    return TRUE;
}

integer allowOperate(key user){
    // 先判断禁止操作的情况，锁定状态，计时器状态，触摸者
    // 穿戴模式
    if(REZ_MODE==FALSE){
        if(
            isLocked==TRUE /*锁定状态*/ &&
            timeoutRunning==TRUE /*倒计时状态*/ &&
            user==llGetOwner() /*自己触摸*/
        ){
            llMessageLinked(LINK_SET, MENU_MSG_NUM, "MENU.OUT.TO|You're locked by %1% and timer is running, not allow to operate it!%%;"+userInfo(lockUser), user);
            // llRegionSayTo(user, 0, getLanguageVar("You're locked by %1% and timer is running, not allow to operate it!%%;"+userInfo(lockUser)));
            return FALSE;
        }
        else if(
            isLocked==TRUE /*锁定状态*/ && 
            lockUser!=llGetOwner() /*非自锁*/ && 
            user==llGetOwner() /*自己触摸*/
        ){
            llMessageLinked(LINK_SET, MENU_MSG_NUM, "MENU.OUT.TO|You're locked by %1% and not allow to operate it!%%;"+userInfo(lockUser), user);
            // llRegionSayTo(user, 0, getLanguageVar("You're locked by %1% and not allow to operate it!%%;"+userInfo(lockUser)));
            return -1; // 为了让Escape功能有效，因此返回-1而不是FALSE
        }
    }
    // REZ模式
    else if(REZ_MODE==TRUE){
        if(
            isLocked==TRUE /*锁定状态*/ && 
            timeoutRunning==TRUE /*倒计时状态*/ &&
            user==VICTIM_UUID /*被困者触摸*/
        ){
            llMessageLinked(LINK_SET, MENU_MSG_NUM, "MENU.OUT.TO|You're locked by %1% and timer is running, not allow to operate it!%%;"+userInfo(lockUser), user);
            // llRegionSayTo(user, 0, getLanguageVar("You're locked and not allow to operate it!%%;"+userInfo(lockUser)));
            return FALSE;
        }
        else if(
            isLocked==TRUE /*锁定状态*/ && 
            lockUser!=VICTIM_UUID /*非自锁*/ && // REZ模式下，自锁也不允许解锁
            user==VICTIM_UUID /*被困者触摸*/
        ){
            llMessageLinked(LINK_SET, MENU_MSG_NUM, "MENU.OUT.TO|You're locked by %1% and not allow to operate it!%%;"+userInfo(lockUser), user);
            // llRegionSayTo(user, 0, getLanguageVar("You're locked and not allow to operate it!%%;"+userInfo(lockUser)));
            return -1; // 为了让Escape功能有效，因此返回-1而不是FALSE
        }
    }
    // 再判断授权关系，主人、信任、黑名单、公开、群组
    if(
        user!=llGetOwner() /*非自己触摸*/ && 
        !checkRelationship(user, "owner") /*非主人*/ && 
        !checkRelationship(user, "trust") /*非信任*/ && 
        !checkRelationship(user, "public") /*非公开*/ && 
        !checkRelationship(user, "group") /*群组模式下，非同群组*/ || 
        checkRelationship(user, "black") /*在黑名单中，优先级高*/
    ){
        if(isLocked){
            llMessageLinked(LINK_SET, MENU_MSG_NUM, "MENU.OUT.TO|This %1% is locked by %2%, you don't have permission to operate it!%%;"+llGetObjectName()+";"+userInfo(lockUser), user);
            // llRegionSayTo(user, 0, getLanguageVar("This %1% is locked by %2%, you don't have permission to operate it!%%;"+llGetObjectName()+";"+userInfo(lockUser)));
        }
        return FALSE;
    }
    else{
        return TRUE;
    }
}

integer isLocked=FALSE;
integer isPermaLocked=FALSE;
key lockUser=NULL_KEY;
key captureByUser=NULL_KEY;
integer lockTime=0;
string lockSound;
string unlockSound;
float soundVolume;
integer setLock(integer lock, key user, integer isShowMenu){
    // if(!allowOperate(user)){
    //     return isLocked;
    // }
    if(REZ_MODE==TRUE && VICTIM_UUID==NULL_KEY && (lock==TRUE || lock==-1)){
        llMessageLinked(LINK_SET, MENU_MSG_NUM, "MENU.OUT.TO|No victims to lock!", user);
        // llRegionSayTo(user, 0, getLanguageVar("No victims to lock!"));
        return FALSE;
    }
    if(lock<0){
        if(!isLocked){
            isLocked=TRUE;
        }else{
            isLocked=FALSE;
        }
    }else{
        isLocked=lock;
    }
    llMessageLinked(LINK_SET, RLV_MSG_NUM, "RLV.LOCK|"+(string)isLocked, user);
    integer tempLockTime=lockTime;

    string lockedStatus;
    if(isLocked==TRUE){
        lockUser=user;
        lockTime=llGetUnixTime();
        lockedStatus="locked";
    }else{
        lockUser=NULL_KEY;
        lockTime=0;
        lockedStatus="unlocked";
    }
    if(user!=NULL_KEY && user != llGetOwner()){
        string usedTime="";
        if(tempLockTime>0){
            usedTime=getLanguageVar("Total locked time: %1%%%;"+getTimeDistStr(tempLockTime, llGetUnixTime()));
        }
        llMessageLinked(LINK_SET, MENU_MSG_NUM, "MENU.OUT.TO|You're %1% by %2%. %3%%%;"+lockedStatus+";"+userInfo(user)+";"+usedTime, VICTIM_UUID);
        llMessageLinked(LINK_SET, MENU_MSG_NUM, "MENU.OUT.TO|You %1% %2%'s %3%. %4%%%;"+lockedStatus+";"+userInfo(llGetOwner())+";"+llGetObjectName()+";"+usedTime, user);

        // llRegionSayTo(llGetOwner(), 0, getLanguageVar("You're %1% by %2%. %3%%%;"+lockedStatus+";"+userInfo(user)+";"+usedTime));
        // llRegionSayTo(user, 0, getLanguageVar("You %1% %2%'s %3%. %4%%%;"+lockedStatus+";"+userInfo(llGetOwner())+";"+llGetObjectName()+";"+usedTime));
    }
    if(isShowMenu){
        showMenu("mainMenu", user); // 防止出现打开双重菜单的bug，无必要不showMenu，尤其在Access逃跑或RLV锁定变更时。
    }
    if(isLocked==TRUE && lockSound!="" && (llGetInventoryType(lockSound)==INVENTORY_SOUND || llStringLength(lockSound)==36)){
        llPlaySound(lockSound, soundVolume);
    }else if(unlockSound!="" && (llGetInventoryType(unlockSound)==INVENTORY_SOUND || llStringLength(unlockSound)==36)){
        llPlaySound(unlockSound, soundVolume);
    }
    if(REZ_MODE==TRUE && showText==TRUE){
        llMessageLinked(LINK_SET, TEXT_MSG_NUM, "TEXT.SET|Locked|%b1%Locked%%;"+(string)isLocked+"|1|Victim", NULL_KEY);
    }
    return isLocked;
}

integer checkRelationship(key user, string type){
    integer index=-1;
    if(type=="owner"){
        index=llListFindList(owner, [(string)user]); // 从link_message接收的list被直接转化为了string的list而没转成key，因此要将key转成string再判断。
    }
    else if(type=="trust"){
        index=llListFindList(trust, [(string)user]);
    }
    else if(type=="black"){
        index=llListFindList(black, [(string)user]);
    }
    else if(type=="public"){
        if(checkRelationship(user, "black")){
            return FALSE;
        }else if(public==TRUE){
            return TRUE;
        }else{
            return FALSE;
        }
    }
    else if(type=="group"){
        if(group==TRUE){
            return llSameGroup(user);
        }else{
            return FALSE;
        }
    }
    if(~index){
        return TRUE;
    }else{
        return FALSE;
    }
}

// list getOwnerNameList(){
//     list ownerNameList=[];
//     integer i=0;
//     for(i=0; i<llGetListLength(owner); i++){
//         if(i>=5){
//             ownerNameList+="...";
//             jump finish;
//         }
//         ownerNameList+="secondlife:///app/agent/"+llList2String(owner, i)+"/about";
//     }
//     @finish;
//     return ownerNameList;
// }

list featureList=[]; // name, parent, menuName
integer featureLen=3;
list registFeature(string name, string parent, string menuName){
    integer i;
    for(i=0; i<llGetListLength(featureList); i+=featureLen){
        if(llList2String(featureList, i) == name){
            return featureList; // 已存在时，直接返回list
        }
    }
    featureList+=[name, parent, menuName];
    return featureList;
}

list applyFeatureList(string menuName, list origin, list feature){
    integer i;
    for(i=0; i<llGetListLength(feature); i+=featureLen){
        string featureName=llList2String(feature, i);
        string featureParent=llList2String(feature, i+1);
        string featureMenuName=llList2String(feature, i+2);
        if(featureMenuName == menuName){
            if(featureParent=="TOP"){
                origin=[featureName]+origin;
            }else{
                integer parentIndex=llListFindList(origin, [featureParent]);
                if(~parentIndex){
                    origin=llListInsertList(origin, [featureName], parentIndex+1);
                }else{
                    origin+=[featureName];
                }
            }
        }
    }
    return origin;
}

string getTimeDistStr(integer baseTime, integer curTime){
    integer total=curTime - baseTime;
    string totalStr="";
    if(total!=curTime){
        string timeStr="";
        integer days = total / 86400;
        total = total % 86400;

        integer hours = total / 3600;
        total = total % 3600;

        integer minutes = total / 60;
        integer seconds = total % 60;

        timeStr=llGetSubString("00" + (string)hours, -2, -1) + ":" +llGetSubString("00" + (string)minutes, -2, -1) + ":" +llGetSubString("00" + (string)seconds, -2, -1);

        string daysStr="";
        if(days>0){
            daysStr=getLanguageVar("%1% days%%;"+(string)days);
        }

        totalStr=daysStr+timeStr;
    }
    return totalStr;
}

integer menuOperateLock=FALSE;
key curMenuUser=NULL_KEY;
showMenu(string menuName, key user){
    integer isAllow=allowOperate(user);
    if(!isAllow){
        return;
    }
    if(menuOperateLock==TRUE){
        if(curMenuUser==NULL_KEY || curMenuUser==user || user==llGetOwner()){
            curMenuUser=user;
            timerFlag=1;
            llSetTimerEvent(60);
        }else{
            llMessageLinked(LINK_SET, MENU_MSG_NUM, "MENU.OUT.TO|Sorry, the menu of %1% is using by %2%.%%;"+llGetObjectName()+";"+userInfo(curMenuUser)+"|0|"+(string)user, user);
            return;
        }
    }else{
        curMenuUser=user;
    }
    string menuCmd="MENU.REG.OPEN";
    string menuText;
    string menuParent;
    list mainMenu=getMenuFeature(menuName, user);
    if(menuName=="mainMenu"){
        llMessageLinked(LINK_SET, MENU_MSG_NUM, "MENU.CLEAR", user);
        // mainMenu=applyFeatureList(menuName, getMenuFeature(menuName, user), featureList);
        if(isAllow==-1){ // 对于被锁住的情况，允许访问Escape逃跑功能
            mainMenu=[llList2String(mainMenu, 0)];
            if(STRUGGLE_READY==TRUE && user==llGetOwner()){
                mainMenu+=["Struggle"];
            }
            if(!hardcore && !REZ_MODE){ // 硬核模式未开启时，仅显示Escape按钮，菜单名使用AccessMenu以确保功能生效
                mainMenu+=["Access"];
            }else{ // 硬核模式开启时，不显示菜单。
            }
            if(llGetListLength(mainMenu)<=1){
                return;
            }
        }
        menuParent="";
    }
    else if(menuName=="appMenu" || menuName=="settingMenu"){
        menuParent="mainMenu";
    }
    else if(menuName=="permaLockMenu"){
        mainMenu=[
            "%1% is requesting to PERMANENT LOCK your %2%, are you sure to be PERMANENT LOCKED?\nOnce confirmed, you will be permanently locked out and unable to unlock!%%;"+userInfo(user)+";"+llGetObjectName(),
            "YES", "NO"
        ];
        menuCmd="MENU.CONFIRM";
        menuParent="settingMenu";
        user=llGetOwner(); // 必须重写user，让佩戴者弹出菜单，而不是操作者
    }
    
    // getMenuFeature第0位为菜单文本，从1~末尾是菜单按钮内容，因此要将它们分开
    menuText=llList2String(mainMenu, 0);
    mainMenu=llList2List(mainMenu, 1, -1);
    llMessageLinked(LINK_SET, MENU_MSG_NUM, menuCmd+"|"+menuName+"|"+menuText+"|"+llDumpList2String(mainMenu, ";")+"|"+menuParent, user);
    return;
    // if( 
    //     (checkOwner(user) || checkTrust(user) || checkPublic(user) || checkGroup(user)) && 
    //     !checkBlack(user)
    // ){
    //     string menuText="This is main menu.\nLocked: %b1%\nOwner: %2%\nPublic: %b3%%%;"+(string)isLocked+";"+llDumpList2String(getOwnerNameList(), ", ")+";"+(string)public;
    //     list mainMenu=["["+(string)isLocked+"]Lock","RLV","Access"];
    //     list menuLink=[
    //         "MENU.REG.OPEN.RESET",
    //         "mainMenu",
    //         menuText,
    //         llDumpList2String(mainMenu,";")
    //     ];
    //     llMessageLinked(LINK_SET, 1000, llDumpList2String(menuLink,"|"), user);
    // }else{
    //     if(isLocked){
    //         llRegionSayTo(user, 0, getLanguageVar("This %1% is locked by %2%.%%;"+llGetObjectName()+";"+userInfo(lockUser)));
    //     }else{
    //         llRegionSayTo(user, 0, getLanguageVar("You don't have permission to operate %1%!%%;"+llGetObjectName()));
    //     }
    // }
}

list sensorUserList;
showSensorMenu(string type, key user){
    string menuText="Select user to %1%.%%;"+type;
    list buttonList=[];
    integer i;
    for(i=0; i<llGetListLength(sensorUserList); i++){
        key uk=llList2Key(sensorUserList, i);
        if(uk){
            buttonList+=[llGetSubString((string)(i+1) + ". " + llGetUsername(uk), 0, 23)];
        }
    }
    string parent="";
    if(type=="Capture"){
        parent="mainMenu";
    }
    llMessageLinked(LINK_SET, MENU_MSG_NUM, "MENU.REG.OPEN.RESET|"+type+"Menu"+"|"+menuText+"|"+llDumpList2String(buttonList,";")+"|"+parent, user);
}

integer MAIN_MSG_NUM=9000;
integer CONF_MSG_NUM=8000;
integer MENU_MSG_NUM=1000;
integer RLV_MSG_NUM=1001;
integer RENAMER_MSG_NUM=10011;
integer RLVEXT_MSG_NUM=10012;
integer ACCESS_MSG_NUM=1002;
integer LAN_MSG_NUM=1003;
integer TIMER_MSG_NUM=1004;
integer LEASH_MSG_NUM=1005;
integer ANIM_MSG_NUM=1006;
integer STRUGGLE_MSG_NUM=1007;
integer TEXT_MSG_NUM=1008;

integer RLV_READY=FALSE;
integer RENAMER_READY=FALSE;
integer ACCESS_READY=FALSE;
integer TIMER_READY=FALSE;
integer LEASH_READY=FALSE;
integer ANIM_READY=FALSE;
integer STRUGGLE_READY=FALSE;
integer TEXT_READY=FALSE;

list owner=[];
list trust=[];
list black=[];
integer public=1;
integer group=0;
integer hardcore=0;
integer autoLock=0;
integer allowPermaLock=FALSE;

vector sitPos;
rotation sitRot;
integer sitAutoLock;
integer sitAutoTrap;
string sitText="";
integer showText;
string touchSound;

integer REZ_MODE=FALSE;
key VICTIM_UUID;

integer attachFlag=TRUE;

integer timeoutRunning=FALSE;
integer timerFlag=0; // 0: None; 1: Menu timeout flag
integer initRetryTimer=30;
integer cmdChannel=1;
integer listenHandle;
string curSensorType; // Capture
integer maxSensor=18;
default{
    state_entry(){
        initMain();
        if(llGetAttached()){
            REZ_MODE=FALSE;
            VICTIM_UUID=llGetOwner();
        }else{
            REZ_MODE=TRUE;
            VICTIM_UUID=NULL_KEY;
        }
        llSetTimerEvent(initRetryTimer); // 重置时，设置计时器，5秒后重新初始化，防止初始化失败
    }
    changed(integer change){
        if(change & CHANGED_OWNER){ // 物品易主时，重置脚本
            llResetScript();
        }
        if (change & CHANGED_LINK) {
            llSleep(0.1);
            REZ_MODE=TRUE;
            triggerFeature("CHANGE", (string)change, llAvatarOnSitTarget());
        }else{
            triggerFeature("CHANGE", (string)change, NULL_KEY);
        }
    }
    attach(key user){
        REZ_MODE=FALSE;
        VICTIM_UUID=llGetOwner();
        triggerFeature("ATTACH", "", user);
        llMessageLinked(LINK_SET, MAIN_MSG_NUM, "MAIN.ATTACH|"+(string)user, NULL_KEY);
        // llMessageLinked(LINK_SET, STRUGGLE_MSG_NUM, "STRUGGLE.GET.READY", NULL_KEY);
    }
    on_rez(integer start_param){
        // 登录、穿戴时也会触发on_rez，并且比attach更早触发。有时候登录时不触发attach，因此将attach的部分也添加到这里。
        integer attached=llGetAttached();
        if(attached){
            REZ_MODE=FALSE;
            VICTIM_UUID=llGetOwner();
        }else{
            REZ_MODE=TRUE;
            VICTIM_UUID=NULL_KEY;
        }
    }
    object_rez(key id){
        REZ_MODE=TRUE;
        VICTIM_UUID=NULL_KEY;
        triggerFeature("REZ", "", id);
    }
    collision_start(integer num){
        triggerFeature("COLLISION", (string)num, llDetectedKey(0));
    }
    collision_end(integer num){
        triggerFeature("COLLISION_END", (string)num, llDetectedKey(0));
    }
    timer(){
        if(RLV_READY==FALSE){ // 如果未成功初始化数据，则每5秒重新读取一次，直到读取成功
            initMain();
        }else if(timerFlag==1){
            curMenuUser=NULL_KEY;
            timerFlag=0;
            llSetTimerEvent(0);
        }else{
            llSetTimerEvent(0);
        }
    }
    touch_start(integer num_detected){
        triggerFeature("TOUCH", (string)num_detected, llDetectedKey(0));
        //string json="[9,\"<1,1,1>\",false,{\"A\":8,\"Z\":9}]";
        //llJsonSetValue(json, ["test1"], "testv1");
        //llJsonSetValue(json, ["test2"], "testv2");
        //llOwnerSay("JSON: "+json);
        //llOwnerSay(llJsonGetValue(json,["test1"]));
    }
    touch_end(integer num_detected){
        triggerFeature("TOUCH_END", (string)num_detected, llDetectedKey(0));
    }
    listen(integer channel, string name, key id, string message){
        triggerListen(channel, name, id, message);
    }
    link_message(integer sender_num, integer num, string str, key user){
        if(num==MAIN_MSG_NUM){
            // 主系统功能监听
            list mainCmdList=strSplit(str, "|");
            string mainCmdStr=llList2String(mainCmdList, 0);
            string mainName=llList2String(mainCmdList, 1);
            string mainText=llList2String(mainCmdList, 2);
            string mainMenuName=llList2String(mainCmdList, 3);
            if(mainCmdStr=="FEATURE.REG"){ // FEATURE.REG | featureName | featureParent | featureMenuName
                if(mainMenuName==""){
                    mainMenuName="appMenu";
                }
                registFeature(mainName, mainText, mainMenuName);
            }
        }
        else if(num==MENU_MSG_NUM){
            // 主菜单功能监听
            list menuCmdList=strSplit(str, "|");
            string menuCmdStr=llList2String(menuCmdList, 0);
            string menuName=llList2String(menuCmdList, 1);
            string menuText=llList2String(menuCmdList, 2);
            if(menuCmdStr=="MENU.ACTIVE"){
                // llOwnerSay(menuName+" -> "+menuText);
                if(menuName=="mainMenu"){
                    if(menuText == "Lock"){
                        setLock(-1, user, TRUE);
                    }
                    else if(menuText=="PermaLocked"){
                        llMessageLinked(LINK_SET, MENU_MSG_NUM, "MENU.OUT.SAY|%1% is PERMANENT LOCKED by %2%!%%;"+userInfo(llGetOwner())+";"+userInfo(lockUser), NULL_KEY);
                    }
                    else if(menuText=="Capture"){
                        curSensorType=menuText;
                        llSensor("", NULL_KEY, AGENT, 96.0, PI);
                    }
                    else if(menuText=="Unsit"){
                        // setLock(FALSE, NULL_KEY, FALSE);
                        captureByUser=NULL_KEY;
                        llUnSit(llAvatarOnSitTarget());
                    }
                    else if(menuText=="Apps"){
                        showMenu("appMenu", user);
                    }
                    else if(menuText=="Settings"){
                        showMenu("settingMenu", user);
                    }
                }
                else if(menuName=="settingMenu"){
                    if(menuText=="AutoLock"){
                        sitAutoLock=!sitAutoLock;
                        showMenu("settingMenu", user);
                    }
                    else if(menuText=="AutoTrap"){
                        sitAutoTrap=!sitAutoTrap;
                        showMenu("settingMenu", user);
                    }
                    else if(menuText=="ShowText"){
                        showText=!showText;
                        showMenu("settingMenu", user);
                    }
                    else if(menuText=="PermaLock"){
                        showMenu("permaLockMenu", user);
                    }
                }
                else if(menuName=="permaLockMenu"){
                    if(user != llGetOwner()){
                        return;
                    }
                    if(menuText=="YES"){
                        isPermaLocked=TRUE;
                        llMessageLinked(LINK_SET, MENU_MSG_NUM, "MENU.OUT.TO|You are permanent locked by %1%!%%;"+userInfo(lockUser), llGetOwner());
                        llMessageLinked(LINK_SET, MENU_MSG_NUM, "MENU.OUT.TO|You permanent locked %1%!%%;"+userInfo(lockUser), lockUser);
                        llMessageLinked(LINK_SET, MAIN_MSG_NUM, "MAIN.SET.PERMALOCK|"+(string)isPermaLocked, lockUser);
                    }
                    else if(menuText=="NO"){
                        llMessageLinked(LINK_SET, MENU_MSG_NUM, "MENU.OUT.TO|%1% refused to accept your permanent lock request!%%;"+userInfo(lockUser), lockUser);
                    }
                    return;
                }
                else if(menuName=="CaptureMenu"){
                    list buList=llParseStringKeepNulls(menuText,[". "],[""]);
                    integer buIndex=llList2Integer(buList,0);
                    key buUser=llList2Key(sensorUserList, ((integer)(buIndex-1)));
                    if(buUser!=NULL_KEY){
                        llMessageLinked(LINK_SET, RLV_MSG_NUM, "RLV.CAPTURE|"+(string)buUser+"|1", user);
                        captureByUser=user;
                    }
                    sensorUserList=[];
                }
                triggerFeature(menuName, menuText, user);
            }
            else if(menuCmdStr=="MENU.CLOSE"){
                curMenuUser=NULL_KEY;
                timerFlag=0;
                llSetTimerEvent(0);
            }
        }
        else if(num==RLV_MSG_NUM){
            list rlvCmdList=strSplit(str, "|");
            string rlvCmdStr=llList2String(rlvCmdList, 0);
            string rlvCmdName=llList2String(rlvCmdList, 1);
            string rlvCmdText=llList2String(rlvCmdList, 2);
            list rlvCmdData=strSplit(llList2String(rlvCmdList, 2), ";");

            if(rlvCmdStr=="RLV.EXEC"){
                if(rlvCmdName=="RLV.GET.LOCK" || rlvCmdName=="RLV.LOCK"){
                    isLocked=llList2Integer(rlvCmdData, 0);
                    lockUser=llList2Key(rlvCmdData, 1);
                    string lockStr="detach";
                    if(REZ_MODE==1){
                        lockStr="unsit";
                    }
                    if(isLocked){
                        lockTime=llGetUnixTime();
                        llMessageLinked(LINK_SET, RLV_MSG_NUM, "RLV.RUN.TEMP|"+lockStr+"=n", NULL_KEY);
                    }else{
                        lockTime=0;
                        llMessageLinked(LINK_SET, RLV_MSG_NUM, "RLV.RUN.TEMP|"+lockStr+"=y", NULL_KEY);
                    }
                    // llMessageLinked(LINK_SET, STRUGGLE_MSG_NUM, "STRUGGLE.GET.READY", NULL_KEY);
                }
            }
            if(rlvCmdStr=="RLV.LOAD.NOTECARD"){
                RLV_READY=(integer)rlvCmdText; // 处理RLV读取记事卡的逻辑，读取完成后不再重新读取
                llMessageLinked(LINK_SET, RLV_MSG_NUM, "RLV.GET.LOCK", NULL_KEY);
            }
        }
        else if(num==RENAMER_MSG_NUM){
            if(includes(str, "RENAMER.LOAD.NOTECARD")){
                RENAMER_READY=TRUE;
            }
        }
        else if(num==ACCESS_MSG_NUM){
            // 权限功能监听
            list accessCmdList=strSplit(str, "|");
            string accessCmdStr=llList2String(accessCmdList, 0);
            string accessName=llList2String(accessCmdList, 1);
            list accessData=strSplit(llList2String(accessCmdList, 2), ";");

            if(accessCmdStr=="ACCESS.NOTIFY"){
                if(accessName=="OWNER"){ // ACCESS.NOTIFY | OWNER | UUID1; UUID2; UUID3; ...
                    owner=accessData; // 接收到并写入的用户列表为string，判断时要将key转换为string再判断
                }
                if(accessName=="TRUST"){ // ACCESS.NOTIFY | TRUST | UUID1; UUID2; UUID3; ...
                    trust=accessData;
                }
                if(accessName=="BLACK"){ // ACCESS.NOTIFY | BLACK | UUID1; UUID2; UUID3; ...
                    black=accessData;
                }
                if(accessName=="MODE"){ // ACCESS.NOTIFY | MODE | PUBLIC; GROUP; HARDCORE
                    public=llList2Integer(accessData, 0);
                    group=llList2Integer(accessData, 1);
                    hardcore=llList2Integer(accessData, 2);
                    autoLock=llList2Integer(accessData, 3);
                }
                // llOwnerSay("Access updated. Owner: "+list2Data(owner)+" Trust: "+list2Data(trust)+" Black: "+list2Data(black)+" Public: "+(string)public+" Group: "+(string)group+" Hardcore: "+(string)hardcore);
            }else if(accessCmdStr=="ACCESS.EXEC"){
                if(accessName=="ACCESS.RESET" && llList2Integer(accessData, 0)==TRUE){ // Access重置（逃跑）时，解锁
                    setLock(FALSE, NULL_KEY, FALSE);
                }
            }else if(accessCmdStr=="ACCESS.LOAD.NOTECARD"){
                ACCESS_READY=TRUE;
                llMessageLinked(LINK_SET, RLV_MSG_NUM, "RLV.GET.LOCK", NULL_KEY);
            }
        }
        else if(num==LAN_MSG_NUM){
            // 语言功能监听
            // if (llGetSubString(str, 0, 2) == "LAN" && includes(str, "INIT")) { // 接收语言系统INIT回调，并启用语言功能
            if (includes(str, "LANGUAGE.EXEC") && includes(str, "INIT")) { // 接收语言系统INIT回调，并启用语言功能
                hasLanguage=TRUE;
            }
            else if (llGetSubString(str, 0, 2) == "LAN" && includes(str, "ACTIVE")) { // 接收语言系统ACTIVE回调，并应用语言数据
                applyLanguage();
            }
        }
        else if(num==TIMER_MSG_NUM){
            // 计时器功能监听
            if(includes(str, "TIMER.LOAD.NOTECARD")){
                TIMER_READY=TRUE;
            }
            else if (includes(str, "TIMER.TIMEOUT")) { // 接收计时器系统回调
                timeoutRunning=FALSE;
                if(isLocked){
                    setLock(FALSE, NULL_KEY, FALSE); // 计时结束时，解锁
                }
            }
            else if (includes(str, "TIMER.RUNNING")) { // 接收计时器系统回调
                timeoutRunning=TRUE;
            }
            else if (includes(str, "TIMER.SETRUNNING")) { // 接收计时器系统回调
                timeoutRunning=FALSE;
            }
        }
        else if(num==LEASH_MSG_NUM){
            if(includes(str, "LEASH.LOAD.NOTECARD")){
                LEASH_READY=TRUE;
            }
        }
        else if(num==ANIM_MSG_NUM){
            if(includes(str, "ANIM.LOAD.NOTECARD")){
                ANIM_READY=TRUE;
            }
        }
        else if(num==STRUGGLE_MSG_NUM){
            if(includes(str, "STRUGGLE.LOAD.NOTECARD")){
                STRUGGLE_READY=TRUE;
            }
            // if(includes(str, "STRUGGLE.READY")){
            //     STRUGGLE_READY=TRUE;
            // }
            // 挣扎功能监听
            if (includes(str, "STRUGGLE.APPLY.SUCCESS")) { // 接收挣扎系统回调
                if(isLocked){
                    setLock(FALSE, NULL_KEY, FALSE); // 挣扎成功时，解锁
                }
            }
        }
        else if(num==TEXT_MSG_NUM){
            if(includes(str, "TEXT.READY")){
                TEXT_READY=TRUE;
            }
        }
        triggerLinkMessage(sender_num, num, str, user);
        // llOwnerSay("LINK_MESSAGE: "+str);
        //llOwnerSay("OPERATER: "+(string)user);
        // llSleep(0.01);
        // llOwnerSay("Main Memory Used: "+(string)llGetUsedMemory()+"/"+(string)(65536-llGetUsedMemory())+" Free: "+(string)llGetFreeMemory());
    }
    
    run_time_permissions(integer perm){
        if (perm & PERMISSION_ATTACH){
            if(attachFlag==FALSE){
                llDetachFromAvatar();
            }
        }
    }

    sensor(integer detected) {
        sensorUserList=[];
        if(REZ_MODE==FALSE){
            sensorUserList+=[llGetOwner()]; // 穿在身上时，添加自己
        }
        integer i;
        for (i = 0; i < detected && i<maxSensor; i++) {
            key uuid = llDetectedKey(i);
            sensorUserList+=uuid;
        }
        showSensorMenu(curSensorType, curMenuUser);
    }
    no_sensor(){
        sensorUserList=[];
        if(REZ_MODE==FALSE){
            sensorUserList+=[llGetOwner()]; // 穿在身上时，添加自己
        }
        showSensorMenu(curSensorType, curMenuUser);
    }
}
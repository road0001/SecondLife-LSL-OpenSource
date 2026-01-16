/*
Name: Main
Author: JMRY
Description: A main controller for restraint items.

***更新记录***
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

string replace(string src, string target, string replacement) {
    return llReplaceSubString(src, target, replacement, 0);
}

integer includes(string src, string target){
    integer startPos = llSubStringIndex(src, target);
    if(~startPos){
        return TRUE;
    }else{
        return FALSE;
    }
}

string trim(string k){
    return llStringTrim(k, STRING_TRIM);
}

list strSplit(string m, string sp){
    list pl=llParseStringKeepNulls(m,[sp],[""]);
    list temp=[];
    integer i;
    for(i=0; i<llGetListLength(pl); i++){
        temp+=[trim(llList2String(pl, i))];
    }
    return temp;
}
string strJoin(list m, string sp){
    return llDumpList2String(m, sp);
}

string bundleSplit="&&";
list bundle2List(string b){
    return strSplit(b, bundleSplit);
}
string list2Bundle(list b){
    return strJoin(b, bundleSplit);
}

string messageSplit="|";
list msg2List(string m){
    return strSplit(m, messageSplit);
}
string list2Msg(list m){
    return strJoin(m, messageSplit);
}

string dataSplit=";";
list data2List(string d){
    return strSplit(d, dataSplit);
}
string list2Data(list d){
    return strJoin(d, dataSplit);
}

integer hasLanguage=FALSE;
initLanguage(){
    hasLanguage=FALSE;
    llMessageLinked(LINK_SET, LAN_MSG_NUM, "LANGUAGE.INIT", llGetOwner()); // 得到语言系统初始化确认时，将hasLanguage置为TRUE。
}

string lanLinkHeader="LAN_";
list clearLanguage(){
    return llLinksetDataDeleteFound(lanLinkHeader, "");
}

integer setLanguage(string k, string v){
    return llLinksetDataWrite(lanLinkHeader+k, v);
}

string getLanguage(string k){
    if(!hasLanguage){
        return k;
    }
    k=replace(replace(k,"\\n","\n"),"\n","\\n"); // 替换换行符\n。将转义的\\n替换回去再替换
    string curVal=llLinksetDataRead(lanLinkHeader+k);
    if(curVal){
        return replace(curVal,"\\n","\n");
    }else{
        return replace(k,"\\n","\n");
    }
}

string getLanguageKey(string v){
    if(!hasLanguage){
        return v;
    }
    list lanKeyList=llLinksetDataFindKeys(lanLinkHeader, 0, 0);
    integer i;
    for(i=0; i<llGetListLength(lanKeyList); i++){
        string curKey=llList2String(lanKeyList, i);
        string curVal=llLinksetDataRead(curKey);
        if(curVal==v){
            return replace(curKey, lanLinkHeader, "");
        }
    }
    return v;
}

string getLanguageVar(string k){ // 拼接字符串方法，用于首尾拼接变量等内容。格式：Text text %1 %2.%%var1;var2
    list ksp=llParseStringKeepNulls(k, ["%%;"], [""]); // ["Text text %1 %2.", "var1;var2"]
    string text=getLanguage(trim(llList2String(ksp, 0)));
    list var=data2List(llList2String(ksp, 1)); // ["var1", "var2"]
    integer i;
    for(i=0; i<llGetListLength(var); i++){
        integer vi=i+1;
        text=replace(text, "%"+(string)vi+"%", getLanguage(llList2String(var, i)));
        text=replace(text, "%b"+(string)vi+"%", getLanguageBool(llList2String(var, i)));
    }
    return text;
}

string defaultBoolStrList="◇|◆";
string boolStrList=defaultBoolStrList;
string getLanguageBool(string k){ // 拼接字符串方法之开关，根据传入字符串来判断开关并显示。格式：[0/1]BUTTON_NAME，返回：◇ 按钮名 / ◆ 按钮名
    //return getLanguageVar(k, LVPOS_BEFORE, llList2String(boolStrList,bool));
    list boolList=msg2List(boolStrList);
    integer bool=FALSE;
    if(includes(k, "[1]")){
        bool=TRUE;
    }else if(includes(k, "[0]")){
        bool=FALSE;
    }else{
        bool=-1;
    }
    if(~bool){
        return llList2String(boolList, bool) + " " + getLanguage(replace(replace(k, "[1]", ""), "[0]", ""));
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
    if(
        isLocked==TRUE /*锁定状态*/ && 
        lockUser!=llGetOwner() /*非自锁*/ && 
        user==llGetOwner() /*自己触摸*/
    ){
        llRegionSayTo(user, 0, getLanguageVar("You're locked by %1% and not allow to operate it!%%;"+userInfo(lockUser)));
        return -1; // 为了让Escape功能有效，因此返回-1而不是FALSE
    }else if(
        user!=llGetOwner() /*非自己触摸*/ && 
        !checkOwner(user) /*非主人*/ && 
        !checkTrust(user) /*非信任*/ && 
        !checkPublic(user) /*非公开*/ && 
        !checkGroup(user) /*群组模式下，非同群组*/ || 
        checkBlack(user) /*在黑名单中，优先级高*/
    ){
        if(isLocked){
            llRegionSayTo(user, 0, getLanguageVar("This %1% is locked by %2%, you don't have permission to operate it!%%;"+llGetObjectName()+";"+userInfo(lockUser)));
        }
        return FALSE;
    }else{
        return TRUE;
    }
}

integer isLocked=FALSE;
key lockUser=NULL_KEY;
integer lockTime=0;
integer setLock(integer lock, key user, integer isShowMenu){
    if(!allowOperate(user)){
        return isLocked;
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
    list lockLink=[
        "RLV.LOCK",
        (string)isLocked
    ];
    llMessageLinked(LINK_SET, RLV_MSG_NUM, llDumpList2String(lockLink,"|"), user);

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
        llRegionSayTo(llGetOwner(), 0, getLanguageVar("You're %1% by %2%. %3%%%;"+lockedStatus+";"+userInfo(user)+";"+usedTime));
        llRegionSayTo(user, 0, getLanguageVar("You %1% %2%'s %3%. %4%%%;"+lockedStatus+";"+userInfo(llGetOwner())+";"+llGetObjectName()+";"+usedTime));
    }
    if(isShowMenu){
        showMenu(user); // 防止出现打开双重菜单的bug，无必要不showMenu，尤其在Access逃跑或RLV锁定变更时。
    }
    return isLocked;
}

integer checkOwner(key user){
    integer index=llListFindList(owner, [(string)user]); // 从link_message接收的list被直接转化为了string的list而没转成key，因此要将key转成string再判断。
    if(~index){
        return TRUE;
    }else{
        return FALSE;
    }
}

integer checkTrust(key user){
    integer index=llListFindList(trust, [(string)user]);
    if(~index){
        return TRUE;
    }else{
        return FALSE;
    }
}

integer checkBlack(key user){
    integer index=llListFindList(black, [(string)user]);
    if(~index){
        return TRUE;
    }else{
        return FALSE;
    }
}

integer checkPublic(key user){
    if(checkBlack(user)){
        return FALSE;
    }else if(public==TRUE){
        return TRUE;
    }else{
        return FALSE;
    }
}
integer checkGroup(key user){
    if(group==TRUE){
        return llSameGroup(user);
    }else{
        return FALSE;
    }
}

list getOwnerNameList(){
    list ownerNameList=[];
    integer i=0;
    for(i=0; i<llGetListLength(owner); i++){
        if(i>=5){
            ownerNameList+="...";
            jump finish;
        }
        ownerNameList+="secondlife:///app/agent/"+llList2String(owner, i)+"/about";
    }
    @finish;
    return ownerNameList;
}

list featureList=[];
integer featureLen=2;
list registFeature(string name, string parent){
    integer i;
    for(i=0; i<llGetListLength(featureList); i+=featureLen){
        if(llList2String(featureList, i) == name){
            return featureList; // 已存在时，直接返回list
        }
    }
    featureList+=[name, parent];
    return featureList;
}

list applyFeatureList(list origin, list feature){
    integer i;
    for(i=0; i<llGetListLength(feature); i+=featureLen){
        string featureName=llList2String(feature, i);
        string featureParent=llList2String(feature, i+1);
        integer parentIndex=llListFindList(origin, [featureParent]);
        if(~parentIndex){
            origin=llListInsertList(origin, [featureName], parentIndex+1);
        }else{
            origin+=[featureName];
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

showMenu(key user){
    integer isAllow=allowOperate(user);
    if(!isAllow){
        return;
    }
    integer curTime=llGetUnixTime();
    string lockTimeDist=getTimeDistStr(lockTime, curTime);
    if(lockTimeDist!=""){
        lockTimeDist="\n"+getLanguageVar("Time: %1%%%;"+lockTimeDist);
    }
    string menuName="mainMenu";
    string menuText="Locked: %1% %2%\nOwner: %3%\nPublic: %b4%\nGroup: %b5%\nHardcore: %b6%%%;"+
        userInfo(lockUser)+";"+
        lockTimeDist+";"+
        strJoin(getOwnerNameList(), ", ")+";"+
        (string)public+";"+
        (string)group+";"+
        (string)hardcore;
    list mainMenu=applyFeatureList([
        "["+(string)isLocked+"]Lock","Leash","RLV",
        "Timer","Renamer","Animation",
        "Access",
        "Language"
    ], featureList);
    if(isAllow==-1){ // 对于被锁住的情况，允许访问Escape逃跑功能
        if(!hardcore){ // 硬核模式未开启时，仅显示Escape按钮，菜单名使用AccessMenu以确保功能生效
            mainMenu=["Access"];
        }else{ // 硬核模式开启时，不显示菜单。
            return;
        }
    }
    list menuLink=[
        "MENU.REG.OPEN.RESET",
        menuName,
        menuText,
        llDumpList2String(mainMenu,";")
    ];
    llMessageLinked(LINK_SET, 1000, llDumpList2String(menuLink,"|"), user);
    // if( 
    //     (checkOwner(user) || checkTrust(user) || checkPublic(user) || checkGroup(user)) && 
    //     !checkBlack(user)
    // ){
    //     string menuText="This is main menu.\nLocked: %b1%\nOwner: %2%\nPublic: %b3%%%;"+(string)isLocked+";"+strJoin(getOwnerNameList(), ", ")+";"+(string)public;
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

integer MAIN_MSG_NUM=9000;
integer MENU_MSG_NUM=1000;
integer RLV_MSG_NUM=1001;
integer RENAMER_MSG_NUM=10011;
integer RLVEXT_MSG_NUM=10012;
integer ACCESS_MSG_NUM=1002;
integer LAN_MSG_NUM=1003;
integer TIMER_MSG_NUM=1004;
integer LEASH_MSG_NUM=1005;
integer ANIM_MSG_NUM=1006;

list owner=[];
list trust=[];
list black=[];
integer public=1;
integer group=0;
integer hardcore=0;

integer mainInited=FALSE;
initMain(){
    llOwnerSay("Begin Initialize...");
    list initMessageLinkChain=[
        MAIN_MSG_NUM, "MAIN.INIT", 0,
        RLV_MSG_NUM, "RLV.LOAD|main", 0,
        RLV_MSG_NUM, "RLV.GET.LOCK", 0,
        ACCESS_MSG_NUM, "ACCESS.LOAD|main", 0,
        ACCESS_MSG_NUM, "ACCESS.GET.NOTIFY", 0,
        LEASH_MSG_NUM, "LEASH.LOAD|main", 0,
        ANIM_MSG_NUM, "ANIM.LOAD|main", 0
    ];
    integer i;
    for(i=0; i<llGetListLength(initMessageLinkChain); i+=3){
        llMessageLinked(LINK_SET, llList2Integer(initMessageLinkChain, i), llList2String(initMessageLinkChain, i+1), NULL_KEY);
        llSleep(llList2Float(initMessageLinkChain, i+2));
    }
    initLanguage();
    llSleep(0);
    // llOwnerSay("Initialize Complete, Enjoy!");
}

integer initRetryTimer=30;
integer cmdChannel=1;
integer listenHandle;
default{
    state_entry(){
        initMain();
        llSetTimerEvent(initRetryTimer); // 重置时，设置计时器，5秒后重新初始化，防止初始化失败
    }
    changed(integer change){
        if(change & CHANGED_OWNER){ // 物品易主时，重置脚本
            llResetScript();
        }
        if(change & CHANGED_INVENTORY){ // 库存变更，初始化语言和RLV
            initMain();
        }
    }
    attach(key user){
        llMessageLinked(LINK_SET, MAIN_MSG_NUM, "MAIN.ATTACH|"+(string)user, NULL_KEY);
        if(user!=NULL_KEY){
            if(mainInited==FALSE){ // 穿戴时，如果未成功初始化数据，则重新读取
                initMain();
                llSetTimerEvent(initRetryTimer);
            }
            listenHandle=llListen(cmdChannel, "", NULL_KEY, "");
        }else{
            llListenRemove(listenHandle);
        }
    }
    timer(){
        if(mainInited==FALSE){ // 如果未成功初始化数据，则每5秒重新读取一次，直到读取成功
            initMain();
        }else{
            llSetTimerEvent(0);
        }
    }
    touch_start(integer num_detected)
    {
        key user=llDetectedKey(0);
        showMenu(user);
        
        
        //string json="[9,\"<1,1,1>\",false,{\"A\":8,\"Z\":9}]";
        //llJsonSetValue(json, ["test1"], "testv1");
        //llJsonSetValue(json, ["test2"], "testv2");
        //llOwnerSay("JSON: "+json);
        //llOwnerSay(llJsonGetValue(json,["test1"]));
    }
    listen(integer channel, string name, key id, string message){
        if(channel==cmdChannel){
            key user=llGetOwnerKey(id); // 支持使用物品发出命令。user为说话者的uuid，因此需要获取它的所有者uuid。
            if(!allowOperate(user)){
                return;
            }
            string prefix=llGetSubString(llGetUsername(llGetOwner()), 0, 1);
            if(llGetSubString(message, 0, 1) == prefix){
                // /1 xxmenu, /1 xxleash
                string msgBody=llToLower(llGetSubString(message, 2, -1));
                list msgList=llParseStringKeepNulls(msgBody,[" "],[""]);
                string msgCmd1=llList2String(msgList, 0);
                string msgCmd2=llList2String(msgList, 1);
                string msgCmd3=llList2String(msgList, 2);

                if(msgCmd1=="menu"){
                    showMenu(user);
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
    link_message(integer sender_num, integer num, string str, key user){
        if(num==MAIN_MSG_NUM){
            // 主系统功能监听
            list mainCmdList=msg2List(str);
            string mainCmdStr=llList2String(mainCmdList, 0);
            string mainName=llList2String(mainCmdList, 1);
            string mainText=llList2String(mainCmdList, 2);
            if(mainCmdStr=="FEATURE.REG"){ // FEATURE.REG | featureName | featureParent
                registFeature(mainName, mainText);
            }
        }
        else if(num==MENU_MSG_NUM){
            // 主菜单功能监听
            list menuCmdList=msg2List(str);
            string menuCmdStr=llList2String(menuCmdList, 0);
            string menuName=llList2String(menuCmdList, 1);
            string menuText=llList2String(menuCmdList, 2);
            if(menuCmdStr=="MENU.ACTIVE"){
                // llOwnerSay(menuName+" -> "+menuText);

                if(menuText == "Lock"){
                    setLock(-1, user, TRUE);
                }
            }
        }
        else if(num==ACCESS_MSG_NUM){
            // 权限功能监听
            list accessCmdList=msg2List(str);
            string accessCmdStr=llList2String(accessCmdList, 0);
            string accessName=llList2String(accessCmdList, 1);
            list accessData=data2List(llList2String(accessCmdList, 2));

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
                }
                // llOwnerSay("Access updated. Owner: "+list2Data(owner)+" Trust: "+list2Data(trust)+" Black: "+list2Data(black)+" Public: "+(string)public+" Group: "+(string)group+" Hardcore: "+(string)hardcore);
            }else if(accessCmdStr=="ACCESS.EXEC"){
                if(accessName=="ACCESS.RESET" && llList2Integer(accessData, 0)==TRUE){ // Access重置（逃跑）时，解锁
                    setLock(FALSE, NULL_KEY, FALSE);
                }
            }
        }
        else if(num==RLV_MSG_NUM){
            list rlvCmdList=msg2List(str);
            string rlvCmdStr=llList2String(rlvCmdList, 0);
            string rlvCmdName=llList2String(rlvCmdList, 1);
            string rlvCmdText=llList2String(rlvCmdList, 2);
            list rlvCmdData=data2List(llList2String(rlvCmdList, 2));

            if(rlvCmdStr=="RLV.EXEC"){
                if(rlvCmdName=="RLV.GET.LOCK" || rlvCmdName=="RLV.LOCK"){
                    isLocked=llList2Integer(rlvCmdData, 0);
                    lockUser=llList2Key(rlvCmdData, 1);
                    if(isLocked){
                        lockTime=llGetUnixTime();
                    }else{
                        lockTime=0;
                    }
                }
            }
            if(rlvCmdStr=="RLV.LOAD.NOTECARD"){
                mainInited=(integer)rlvCmdText; // 处理RLV读取记事卡的逻辑，读取完成后不再重新读取
            }
        }
        else if(num==LAN_MSG_NUM){
            // 语言功能监听
            if (llGetSubString(str, 0, 2) == "LAN" && includes(str, "INIT")) { // 接收语言系统INIT回调，并启用语言功能
                hasLanguage=TRUE;
            }
            else if (llGetSubString(str, 0, 2) == "LAN" && includes(str, "ACTIVE")) { // 接收语言系统ACTIVE回调，并应用语言数据
                applyLanguage();
            }
        }
        else if(num==TIMER_MSG_NUM){
            // 语言功能监听
            if (includes(str, "TIMER.TIMEOUT")) { // 接收计时器系统回调
                if(isLocked){
                    setLock(FALSE, NULL_KEY, FALSE); // 计时结束时，解锁
                }
            }
        }
        // llOwnerSay("LINK_MESSAGE: "+str);
        //llOwnerSay("OPERATER: "+(string)user);
    }
}
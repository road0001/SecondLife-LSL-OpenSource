/*
Name: Main
Author: JMRY
Description: A main controller for restraint items.

***更新记录***
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
    if(isLocked==TRUE /*锁定状态*/ && lockUser!=llGetOwner() /*非自锁*/ && user==llGetOwner() /*自己触摸*/){
        llRegionSayTo(user, 0, getLanguageVar("You're locked by %1% and not allow to operate it!%%;"+userInfo(lockUser)));
        return FALSE;
    }else if(user!=llGetOwner() && !checkOwner(user) && !checkTrust(user) && !checkPublic(user) && !checkGroup(user) || checkBlack(user)){
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
integer setLock(integer lock, key user){
    if(!allowOperate(user)){
        return isLocked;
    }
    string lockedStatus;
    if(lock<0){
        if(!isLocked){
            isLocked=TRUE;
            lockedStatus="locked";
        }else{
            isLocked=FALSE;
            lockedStatus="unlocked";
        }
    }else{
        isLocked=lock;
    }
    list lockLink=[
        "RLV.LOCK",
        (string)isLocked
    ];
    llMessageLinked(LINK_SET, RLV_MSG_NUM, llDumpList2String(lockLink,"|"), user);
    if(isLocked==TRUE){
        lockUser=user;
    }else{
        lockUser=NULL_KEY;
    }
    if(user != llGetOwner()){
        llRegionSayTo(llGetOwner(), 0, getLanguageVar("You're %1% by %2%.%%;"+lockedStatus+";"+userInfo(user)));
        llRegionSayTo(user, 0, getLanguageVar("You %1% %2%'s %3%.%%;"+lockedStatus+";"+userInfo(llGetOwner())+";"+llGetObjectName()));
    }
    showMenu(user);
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

showMenu(key user){
    if(!allowOperate(user)){
        return;
    }
    string menuText="Locked: %1%\nOwner: %2%\nPublic: %b3%\nGroup: %b4%\nHardcore: %b5%%%;"+userInfo(lockUser)+";"+strJoin(getOwnerNameList(), ", ")+";"+(string)public+";"+(string)group+";"+(string)hardcore;
    list mainMenu=["["+(string)isLocked+"]Lock","RLV","Access"];
    list menuLink=[
        "MENU.REG.OPEN.RESET",
        "mainMenu",
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

integer MENU_MSG_NUM=1000;
integer RLV_MSG_NUM=1001;
integer ACCESS_MSG_NUM=1002;
integer LAN_MSG_NUM=1003;

list owner=[];
list trust=[];
list black=[];
integer public=0;
integer group=0;
integer hardcore=0;

string operator;
default{
    state_entry(){
        llMessageLinked(LINK_SET, RLV_MSG_NUM, "RLV.LOAD|main", NULL_KEY);
        llMessageLinked(LINK_SET, RLV_MSG_NUM, "RLV.GET.LOCK", NULL_KEY);
        llMessageLinked(LINK_SET, ACCESS_MSG_NUM, "ACCESS.GET.NOTIFY", NULL_KEY);
    }
    changed(integer change){
        if(change & CHANGED_OWNER){
            llResetScript();
        }
        if(change & CHANGED_INVENTORY){
            initLanguage();
            llMessageLinked(LINK_SET, RLV_MSG_NUM, "RLV.LOAD|main", NULL_KEY);
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
    link_message(integer sender_num, integer num, string str, key user){
        if(num==MENU_MSG_NUM){
            // 主菜单功能监听
            list menuCmdList=msg2List(str);
            string menuCmdStr=llList2String(menuCmdList, 0);
            string menuName=llList2String(menuCmdList, 1);
            string menuText=llList2String(menuCmdList, 2);
            if(menuCmdStr=="MENU.ACTIVE"){
                // llOwnerSay(menuName+" -> "+menuText);

                if(menuText == "Lock"){
                    setLock(-1, user);
                }

                if(menuText=="Input"){
                    list menuLink=[
                        "MENU.INPUT",
                        "testInput",
                        "Input something you want..."
                    ];
                    llMessageLinked(LINK_SET, MENU_MSG_NUM, llDumpList2String(menuLink,"|"), user);
                }
            }
        }
        if(num==ACCESS_MSG_NUM){
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
            }
        }
        else if(num==RLV_MSG_NUM){
            list rlvCmdList=msg2List(str);
            string rlvCmdStr=llList2String(rlvCmdList, 0);
            string rlvCmdName=llList2String(rlvCmdList, 1);
            list rlvCmdData=data2List(llList2String(rlvCmdList, 2));

            if(rlvCmdStr=="RLV.EXEC"){
                if(rlvCmdName=="RLV.GET.LOCK" || rlvCmdName=="RLV.LOCK"){
                    isLocked=llList2Integer(rlvCmdData, 0);
                    lockUser=llList2Key(rlvCmdData, 1);
                }
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
        //llOwnerSay("LINK_MESSAGE: "+str);
        //llOwnerSay("OPERATER: "+(string)user);
    }
}
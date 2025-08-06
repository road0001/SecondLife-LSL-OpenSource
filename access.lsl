/*
Name: Access
Author: JMRY
Description: A better access permission control system, use link_message to operate permissions.

***更新记录***
- 1.0.4 20250806
    - 优化内存占用。

- 1.0.3 20250117
	- 调整公开、群组、硬核模式函数返回结果为更新后的结果。

- 1.0.2 20250115
	- 加入配置文件中忽略#注释功能。

- 1.0.1 20250112
	- 优化检测玩家的逻辑。
	- 优化添加删除owner、trust、black的逻辑。
	- 修复逻辑和菜单的bugs。

- 1.0 20250109
    - 完成管理菜单功能。

- 1.0 20250108
    - 完成功能接口。

- 1.0 20250102
    - 完成各功能模式、黑白名单管理功能。
    - 完成根据uuid获取权限结果功能。

- 1.0 20241231
    - 初步完成权限控制管理功能。
***更新记录***
*/

/*
TODO:
- ~~root和owner功能~~
- ~~所有者的增删改查功能~~
- ~~公开、群组、自我访问功能~~
- ~~黑白名单功能~~
- ~~管理菜单~~
- ~~各功能接口~~
    - ~~返回各种list~~
    - ~~权限管理和控制~~
    - ~~权限变更时广播~~
- ~~记事卡预载入配置（除非重置脚本，否则记事卡发生变化时，将与与现有内容合并）~~
- 内存和性能优化
*/

/*
基础功能依赖函数
*/
/*
根据用户UUID获取用户信息URL。
返回：带链接的 显示名称(用户名)
*/
string userInfo(key user){
    return "secondlife:///app/agent/"+(string)user+"/about";
}
string userName(key user, integer type){
    string username=llGetUsername(user);
    string displayname=llGetDisplayName(user);
    if(type==1){
        return username;
    }else if(type==2){
        return displayname;
    }else{
        return displayname+" ("+username+")";
    }
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

// string bundleSplit="&&";
list bundle2List(string b){
    return strSplit(b, "&&");
}
string list2Bundle(list b){
    return strJoin(b, "&&");
}

// string messageSplit="|";
list msg2List(string m){
    return strSplit(m, "|");
}
string list2Msg(list m){
    return strJoin(m, "|");
}

// string dataSplit=";";
list data2List(string d){
    return strSplit(d, ";");
}
string list2Data(list d){
    return strJoin(d, ";");
}

/*
授权操作的基础函数，不能直接调用，后面要判断权限
*/
/*
设置root
root不能为空，state_entry时，如果为空，则自动添加owner为root
*/
list ownerList=[]; // 第0个元素始终为root，从1开始为owner
integer setRootOwner(key user){
    if(user==NULL_KEY){
        user=llGetOwner();
    }
    if(llGetListLength(ownerList)==0){
        ownerList+=[user];
    }else{
        integer oIndex=findOwner(user);
        if(oIndex>0){ // 大于0表示该用户存在于owner列表，因此要先删掉，再加root，防止重复
            removeOwner(user);
        }
        ownerList=llListReplaceList(ownerList, [user], 0, 0);
    }
    return TRUE;
}
/*
查找owner，-1为不存在，0为root，大于0为owner
*/
integer findOwner(key user){
    return llListFindList(ownerList, [user]);
}
/*
添加owner，列表中用户唯一，因此root和owner互斥不能共存
*/
integer addOwner(key user){
    integer oIndex=findOwner(user);
    if(!~oIndex){ // 未找到key时，插入并返回TRUE
        removeTrust(user); // 添加主人时，移除信任和黑名单
        removeBlack(user);
        ownerList+=[user];
        return TRUE;
    }else{ // 找到key时，返回FALSE，包括root
        return FALSE;
    }
}
integer removeOwner(key user){
    integer oIndex=findOwner(user);
    if(oIndex<=0){ // 0不可以移除，-1未找到，都返回FALSE
        return FALSE;
    }else{
        ownerList=llDeleteSubList(ownerList, oIndex, oIndex);
        return TRUE;
    }
}

/*
信任列表
*/
list trustList=[];
integer findTrust(key user){
    return llListFindList(trustList, [user]);
}
integer addTrust(key user){
    integer oIndex=findOwner(user);
    if(~oIndex){
        return FALSE; // 已添加owner时，不能添加trust
    }
    integer tIndex=findTrust(user);
    if(!~tIndex){ // 未找到key时，插入并返回TRUE
        trustList+=[user];
        removeBlack(user); // 加入信任列表时，移除黑名单
        return TRUE;
    }else{ // 找到key时，返回FALSE
        return FALSE;
    }
}
integer removeTrust(key user){
    integer tIndex=findTrust(user);
    if(!~tIndex){
        return FALSE;
    }else{
        trustList=llDeleteSubList(trustList, tIndex, tIndex);
        return TRUE;
    }
}

/*
黑名单
*/
list blackList=[];
integer findBlack(key user){
    return llListFindList(blackList, [user]);
}
integer addBlack(key user){
    integer bIndex=findBlack(user);
    if(!~bIndex){ // 未找到key时，插入并返回TRUE
        blackList+=[user];
        removeOwner(user); // 加入黑名单时，移除owner权限
        removeTrust(user); // 加入黑名单时，移除信任权限
        return TRUE;
    }else{ // 找到key时，返回FALSE
        return FALSE;
    }
}
integer removeBlack(key user){
    integer bIndex=findBlack(user);
    if(!~bIndex){
        return FALSE;
    }else{
        blackList=llDeleteSubList(blackList, bIndex, bIndex);
        return TRUE;
    }
}

/*
公开模式管理
*/
integer publicMode=TRUE;
integer setPublicMode(integer bool){
    if(bool==-1){
        if(publicMode==FALSE){
            bool=TRUE;
        }else{
            bool=FALSE;
        }
    }
    publicMode=bool;
    return bool;
}
integer getPublicMode(){
    return publicMode;
}

/*
群组模式管理
*/
integer groupMode=FALSE;
integer setGroupMode(integer bool){
    if(bool==-1){
        if(groupMode==FALSE){
            bool=TRUE;
        }else{
            bool=FALSE;
        }
    }
    groupMode=bool;
    return bool;
}
integer getGroupMode(){
    return groupMode;
}

/*
安全词系统和硬核模式
*/
integer hardcore=FALSE;
integer setHardcoreMode(integer bool){
    if(bool==-1){
        if(hardcore==FALSE){
            bool=TRUE;
        }else{
            bool=FALSE;
        }
    }
    hardcore=bool;
    return bool;
}
integer getHardcoreMode(){
    return hardcore;
}
integer clearAll(){
    if(getHardcoreMode()){
        return FALSE;
    }else{
        llResetScript();
        return TRUE;
    }
}

/*
获取授权状态
传入：用户uuid
返回：对应权限
*/
integer ACCESS_NONE=-1;
integer ACCESS_ROOT=0;
integer ACCESS_GROUP=-1000;
integer ACCESS_PUBLIC=-2000;
integer ACCESS_TRUST=-3000;
integer ACCESS_BLACK=-4000;
integer getAccess(key user){
    if(user==NULL_KEY){
        return ACCESS_NONE;
    }else{
        integer owneri=findOwner(user);
        if(~owneri){
            return owneri;
        }else if(~findTrust(user)){
            return ACCESS_TRUST;
        }else if(~findBlack(user)){
            return ACCESS_BLACK;
        }else if(getPublicMode()==TRUE){
            return ACCESS_PUBLIC;
        }else if(getGroupMode()==TRUE && llSameGroup(user)==TRUE){
            return ACCESS_GROUP;
        }else{
            return ACCESS_NONE;
        }
    }
}

/*
发送访问列表通知，其他脚本接收到后，根据列表处理权限状态
分别发送主人列表、信任列表、黑名单、模式列表
*/
integer notifyAccess(){
    list ownerNotify=[
        "ACCESS.NOTIFY",
        "OWNER",
        list2Data(ownerList)
    ];
    list trustNotify=[
        "ACCESS.NOTIFY",
        "TRUST",
        list2Data(trustList)
    ];
    list blackNotify=[
        "ACCESS.NOTIFY",
        "BLACK",
        list2Data(blackList)
    ];
    list modeList=[publicMode, groupMode, hardcore];
    list modeNotify=[
        "ACCESS.NOTIFY",
        "MODE",
        list2Data(modeList)
    ];
    llMessageLinked(LINK_SET, ACCESS_MSG_NUM, list2Msg(ownerNotify), "");
    llMessageLinked(LINK_SET, ACCESS_MSG_NUM, list2Msg(trustNotify), "");
    llMessageLinked(LINK_SET, ACCESS_MSG_NUM, list2Msg(blackNotify), "");
    llMessageLinked(LINK_SET, ACCESS_MSG_NUM, list2Msg(modeNotify),  "");
    return TRUE;
}


key readAccessQuery=NULL_KEY;
integer readAccessLine=0;
string readAccessName="access";
string curAccessName="";
integer readAccessNotecards(string aname){
    readAccessLine=0;
    curAccessName=aname;
    readAccessName=aname;
    if (llGetInventoryType(readAccessName) == INVENTORY_NOTECARD) {
        // llRegionSayTo(showMenuUser, 0, "Begin reading language "+aname+".");
        //llRegionSayTo(showMenuUser, 0, glv("Begin reading language %1.%%"+aname));
        readAccessQuery=llGetNotecardLine(readAccessName, readAccessLine); // 通过给readAccessQuery赋llGetNotecardLine的key，从而触发datasever事件
        // 后续功能交给下方datasever处理
        return TRUE;
    }else{
        return FALSE;
    }
}

/*
权限菜单控制
*/
string accessMenuText="Access";
string accessMenuName="AccessMenu";
string accessParentMenuName="";
showAccessMenu(string parent, key user){
    accessParentMenuName=parent;
    integer userPerm=getAccess(user);
    list buttonList=[];
    /*
    ROOT WEARER:
    Root        AccessList    Escape
    Owner        Trust        Black
    []Public    []Group        []Hardcore

    ROOT OTHER:
    Root        AccessList    *
    Owner        Trust        Black
    []Public    []Group        []Hardcore

    OWNER WEARER:
    *            AccessList    Escape
    Owner        Trust        Black
    []Public    []Group        []Hardcore

    OWNER:
    Owner        Trust        Black
    []Public    []Group        []Hardcore

    WEARER:
    *            AccessList    Escape
    */
    if(userPerm==ACCESS_ROOT){
        buttonList+=["Root"];
    }else if(user==llGetOwner()){
        buttonList+=[" "];
    }
    if(userPerm==ACCESS_ROOT || user==llGetOwner()){
        buttonList+=["AccessList"];
    }
    if(user==llGetOwner()){
        if(getHardcoreMode()==FALSE){
            buttonList+=["Escape"];
        }else{
            buttonList+=[" "];
        }
    }else{
		buttonList+=[" "];
	}
    
    if(userPerm>=ACCESS_ROOT){
        string publicBu="["+(string)getPublicMode()+"]Public";
        string groupBu="["+(string)getGroupMode()+"]Group";
        string hardcoreBu="["+(string)getHardcoreMode()+"]Hardcore";
        if(userPerm>ACCESS_ROOT){
            hardcoreBu=" "; // 只有root才能修改硬核模式
        }
        buttonList+=["Owner", "Trust", "Black", publicBu, groupBu, hardcoreBu];
    }

    list menuText=[
        "This is access menu, you can manage who can access %1%'s %2%.\nPublic mode: %3%\nGroup mode: %4%\nHardcore mode: %5%%%",
        userInfo(llGetOwner()),
        llGetObjectName(),
        getPublicMode(),
        getGroupMode(),
        getHardcoreMode()
    ];

    list accMenuList=[
        "MENU.REG.OPEN",
        accessMenuName,
        list2Data(menuText),
        list2Data(buttonList),
        parent
    ];
    llMessageLinked(LINK_SET, MENU_MSG_NUM, list2Msg(accMenuList), user);
}

string accessSubMenuName="AccessSubMenu";
showAccessSubMenu(string button, key user){
    integer userPerm=getAccess(user);
    if(userPerm<0 && user!=llGetOwner()){
        return;
    }
    list menuText=[];
    list buttonList=[];

    if(button=="Root" && userPerm==ACCESS_ROOT){
        menuText=[
            "Current Root: %1%. Click SetRoot to set new Root owner, click Restore to reset Root owner to wearer.%%",
            userInfo(llList2Key(ownerList, 0))
        ];
        buttonList+=["SetRoot", "Restore"];
    }
    else if(button=="Owner"){
        string rootText="Click AddOwner to add owner.\n";
        string ownerText="Click RemoveOwner to remove owner.";
        if(userPerm==ACCESS_ROOT){
            buttonList+=["AddOwner"];
        }else{
            rootText="";
        }
        buttonList+=["RemoveOwner"];
        menuText=[
            "%1%%2%%%",rootText,ownerText
        ];
    }
    else if(button=="Trust"){
        if(userPerm>=ACCESS_ROOT){
            buttonList+=["AddTrust", "RemoveTrust"];
        }
        menuText=["Click AddTrust to add trust user.\nClick RemoveTrust to remove trust user."];
    }
    else if(button=="Black"){
        if(userPerm>=ACCESS_ROOT){
            buttonList+=["AddBlack", "RemoveBlack"];
        }
        menuText=["Click AddBlack to add black user.\nClick RemoveBlack to remove black user."];
    }
    else if(button=="Public"){
        setPublicMode(-1);
		notifyAccess();
        llOwnerSay("Your public mode is set to "+(string)getPublicMode());
        showAccessMenu(accessParentMenuName, user);
        return;
    }
    else if(button=="Group"){
        setGroupMode(-1);
		notifyAccess();
        llOwnerSay("Your group mode is set to "+(string)getGroupMode());
        showAccessMenu(accessParentMenuName, user);
        return;
    }
    else if(button=="Hardcore"){
        setHardcoreMode(-1);
		notifyAccess();
        llOwnerSay("Your hardcore mode is set to "+(string)getHardcoreMode());
        showAccessMenu(accessParentMenuName, user);
        return;
    }
    else if(button=="Escape"){
        list escapeMsgList=[
            "MENU.CONFIRM",
            "AccessEscape",
            "Are you sure to escape? This will clear all of your access data, and restore Root to yourself.",
            list2Data(["Yes", "No"])
        ];
        llMessageLinked(LINK_SET, MENU_MSG_NUM, list2Msg(escapeMsgList), user);
        return;
    }
    else if(button=="AccessList"){
        integer i;
        llRegionSayTo(user, 0, "Root:");
        for(i=0; i<llGetListLength(ownerList); i++){
            llRegionSayTo(user, 0, userInfo(llList2Key(ownerList, i)));
            if(i==0){
                llRegionSayTo(user, 0, "Owners:");
            }
        }
        llRegionSayTo(user, 0, "Trust:");
        for(i=0; i<llGetListLength(trustList); i++){
            llRegionSayTo(user, 0, userInfo(llList2Key(trustList, i)));
        }
        llRegionSayTo(user, 0, "Black:");
        for(i=0; i<llGetListLength(blackList); i++){
            llRegionSayTo(user, 0, userInfo(llList2Key(blackList, i)));
        }
        llRegionSayTo(user, 0, "Public mode: "+(string)getPublicMode());
        llRegionSayTo(user, 0, "Group mode: "+(string)getGroupMode());
        llRegionSayTo(user, 0, "Hardcore mode: "+(string)getHardcoreMode());
        showAccessMenu(accessParentMenuName, user);
        return;
    }

    list accSubMenuList=[
        "MENU.REG.OPEN",
        accessSubMenuName,
        list2Data(menuText),
        list2Data(buttonList),
        accessMenuName
    ];
    llMessageLinked(LINK_SET, MENU_MSG_NUM, list2Msg(accSubMenuList), user);
}

string accessActiveMenuName="AccessActiveMenu";
string accessActiveFlag="";
showAccessActiveMenu(string button, key user){
    integer userPerm=getAccess(user);
    if(userPerm<0){
        return;
    }
    accessActiveFlag=button;
    list menuText=[];
    list buttonList=[];
    if(button=="SetRoot" || button=="AddOwner" || button=="AddTrust" || button=="AddBlack"){
        menuText=["Select user to %1%.%%",button];
        // list userList=[];
        integer i;
        for(i=0; i<9; i++){
            key uk=llList2Key(sensorUserList, i);
            if(uk){
                string un=userName(uk,1);
                // userList+=[(string)(i+1) + ". " + un];
                buttonList+=[(string)i + ". " + un];
            }
        }
        // menuText+=[llDumpList2String(userList, "\n")];
    }
    else if(button=="RemoveOwner" || button=="RemoveTrust" || button=="RemoveBlack"){
        menuText=["Select user to %1%.%%",button];
        list dataList=[];
        integer i=0;
        if(button=="RemoveOwner"){
			if(user==llList2Key(ownerList, 0)){
				dataList=llDeleteSubList(ownerList,0,0);
			}else{
				dataList=[user];
			}
        }else if(button=="RemoveTrust"){
            dataList=trustList;
        }else if(button=="RemoveBlack"){
            dataList=blackList;
        }
        
        for(i=0; i<llGetListLength(dataList); i++){
            key uk=llList2Key(dataList, i);
            if(uk!=NULL_KEY){
                string un=userName(uk,1);
                buttonList+=[(string)(i+1) + ". " + un];
            }
        }
    }
    else if(button=="Restore"){
        setRootOwner(llGetOwner());
        showAccessMenu(accessParentMenuName, user);
        return;
    }

    list accActiveMenuList=[
        "MENU.REG.OPEN",
        accessActiveMenuName,
        list2Data(menuText),
        list2Data(buttonList),
        accessSubMenuName
    ];
    llMessageLinked(LINK_SET, MENU_MSG_NUM, list2Msg(accActiveMenuList), user);
}

integer REZ_MODE=FALSE;
integer MENU_MSG_NUM=1000;
integer RLV_MSG_NUM=1001;
integer ACCESS_MSG_NUM=1002;
list sensorUserList=[];
default{
    state_entry(){
        if(llGetListLength(ownerList)==0){
            setRootOwner(llGetOwner()); // 初始化时，设置玩家为root
        }
        readAccessNotecards(readAccessName);
    }
    changed(integer change){
        if(change & CHANGED_INVENTORY){
            readAccessNotecards(readAccessName);
        }
        else if(change & CHANGED_OWNER){
            llResetScript();
        }
    }
    attach(key user) {
		REZ_MODE=FALSE;
        if(user==llGetOwner()){
            notifyAccess();
        }
    }
    on_rez(integer start_param){
		REZ_MODE=TRUE;
        notifyAccess();
    }
    link_message(integer sender_num, integer num, string msg, key user){
        if(num!=ACCESS_MSG_NUM && num!=MENU_MSG_NUM && num!=RLV_MSG_NUM){
            return;
        }

        list msgList=bundle2List(msg);
        list resultList=[];
        integer msgCount=llGetListLength(msgList);
        integer mi;
        for(mi=0; mi<msgCount; mi++){
            string str=llList2String(msgList, mi);
            if (llGetSubString(str, 0, 6) == "ACCESS." && !includes(str, "EXEC")) {
                list accessMsgList=msg2List(str);
                string accessMsgStr=llList2String(accessMsgList, 0);
                list accessMsgGroup=llParseStringKeepNulls(accessMsgStr, ["."], [""]);

                string accessMsg=llList2String(accessMsgGroup, 0);
                string accessMsgSub=llList2String(accessMsgGroup, 1);
                string accessMsgExt=llList2String(accessMsgGroup, 2);

                string accessMsgName=llList2String(accessMsgList, 1);
                string accessMsgCmd=llList2String(accessMsgList, 2);

                string result="";
                if(accessMsgSub=="ADD"){
                    /*
                    添加主人：ACCESS.ADD.OWNER | UUID
                    添加信任列表：ACCESS.ADD.TRUST | UUID
                    添加黑名单：ACCESS.ADD.BLACK | UUID
                    */
                    if(accessMsgExt=="OWNER"){
                        result=(string)addOwner((key)accessMsgName);
                    }
                    else if(accessMsgExt=="TRUST"){
                        result=(string)addTrust((key)accessMsgName);
                    }
                    else if(accessMsgExt=="BLACK"){
                        result=(string)addBlack((key)accessMsgName);
                    }
                }
                else if(accessMsgSub=="REM" || accessMsgSub=="REMOVE"){
                    /*
                    删除主人
                    ACCESS.REM.OWNER | UUID
                    ACCESS.REMOVE.OWNER | UUID
                    删除信任列表
                    ACCESS.REM.TRUST | UUID
                    ACCESS.REMOVE.TRUST | UUID
                    删除黑名单
                    ACCESS.REM.BLACK | UUID
                    ACCESS.REMOVE.BLACK | UUID
                    */
                    if(accessMsgExt=="OWNER"){
                        result=(string)removeOwner((key)accessMsgName);
                    }
                    else if(accessMsgExt=="TRUST"){
                        result=(string)removeTrust((key)accessMsgName);
                    }
                    else if(accessMsgExt=="BLACK"){
                        result=(string)removeBlack((key)accessMsgName);
                    }
                }
                else if(accessMsgSub=="GET"){
                    /*
                    获取当前用户授权状态
                    ACCESS.GET
                    返回：
                    ACCESS.EXEC | ACCESS.GET | 状态码
                    状态码：0=ROOT；1~n=主人index；-1000=群组；-2000=公开；-3000=信任；-4000=黑名单；-1=无权限
                    获取指定用户授权状态
                    ACCESS.GET | UUID
                    返回：
                    ACCESS.EXEC | ACCESS.GET | 状态码
                    状态码：0=ROOT；1~n=主人index；-1000=群组；-2000=公开；-3000=信任；-4000=黑名单；-1=无权限
                    获取主人、信任、黑名单列表
                    ACCESS.GET.OWNER
                    ACCESS.GET.TRUST
                    ACCESS.GET.BLACK
                    返回：
                    ACCESS.EXEC | ACCESS.GET.OWNER | UUID1; UUID2; ...
                    ACCESS.EXEC | ACCESS.GET.TRUST | UUID1; UUID2; ...
                    ACCESS.EXEC | ACCESS.GET.BLACK | UUID1; UUID2; ...
                    请求访问数据通知
                    ACCESS.GET.NOTIFY
                    返回：
                    ACCESS.NOTIFY | OWNER | UUID1; UUID2; ...
                    ACCESS.NOTIFY | TRUST | UUID1; UUID2; ...
                    ACCESS.NOTIFY | BLACK | UUID1; UUID2; ...
                    ACCESS.NOTIFY | MODE | PUBLIC; GROUP; HARDCORE
                    获取公开、群组、硬核模式状态
                    ACCESS.GET.MODE
                    ACCESS.GET.MODE | PUBLIC
                    ACCESS.GET.MODE | GROUP
                    ACCESS.GET.MODE | HARDCORE
                    返回：
                    ACCESS.EXEC | ACCESS.GET.MODE | PUBLIC; GROUP; HARDCORE
                    ACCESS.EXEC | ACCESS.GET.MODE | PUBLIC
                    ACCESS.EXEC | ACCESS.GET.MODE | GROUP
                    ACCESS.EXEC | ACCESS.GET.MODE | HARDCORE
                    */
                    if(accessMsgExt==""){
                        if(accessMsgName==""){
                            accessMsgName=(string)user;
                        }
                        result=(string)getAccess((key)accessMsgName);
                    }
                    else if(accessMsgExt=="OWNER"){
                        result=list2Data(ownerList);
                    }
                    else if(accessMsgExt=="TRUST"){
                        result=list2Data(trustList);
                    }
                    else if(accessMsgExt=="BLACK"){
                        result=list2Data(blackList);
                    }
                    else if(accessMsgExt=="NOTIFY"){
                        notifyAccess();
                    }
                    else if(accessMsgExt=="MODE"){
                        if(accessMsgName==""){
                            list modes=[
                                getPublicMode(),
                                getGroupMode(),
                                getHardcoreMode()
                            ];
                            result=list2Data(modes);
                        }
                        else if(accessMsgName=="PUBLIC"){
                            result=(string)getPublicMode();
                        }
                        else if(accessMsgName=="GROUP"){
                            result=(string)getGroupMode();
                        }
                        else if(accessMsgName=="HARDCORE"){
                            result=(string)getHardcoreMode();
                        }
                    }
                }
                else if(accessMsgSub=="SET"){
                    /*
                    设置ROOT主人，格式：标头 | UUID
                    ACCESS.SET.ROOT | UUID
                    设置公开、群组、硬核模式
                    ACCESS.SET.MODE | PUBLIC | 1/0
                    ACCESS.SET.MODE | GROUP | 1/0
                    ACCESS.SET.MODE | HARDCORE | 1/0
                    */
                    if(accessMsgExt=="ROOT"){
                        result=(string)setRootOwner((key)accessMsgName);
                    }
                    else if(accessMsgExt=="MODE"){
                        if(accessMsgName=="PUBLIC"){
                            result=(string)setPublicMode((integer)accessMsgCmd);
                        }
                        if(accessMsgName=="GROUP"){
                            result=(string)setGroupMode((integer)accessMsgCmd);
                        }
                        if(accessMsgName=="HARDCORE"){
                            result=(string)setHardcoreMode((integer)accessMsgCmd);
                        }
                    }
                }
                else if(accessMsgSub=="RESET"){
                    /*
                    重置（逃跑）
                    ACCESS.RESET
                    */
                    result=(string)clearAll();
                }
				if(result!=""){
                    list accessExeResult=[
                        "ACCESS.EXEC", accessMsgStr, result
                    ];
                    resultList+=[list2Msg(accessExeResult)];
                }
            }
            else if(llGetSubString(str, 0, 4) == "MENU." && includes(str, "ACTIVE")) {
                // MENU.ACTIVE | mainMenu | Access
                list menuCmdList=msg2List(str);
                string menuCmdStr=llList2String(menuCmdList, 0);
                list menuCmdGroup=llParseStringKeepNulls(menuCmdStr, ["."], [""]);
    
                string menuCmd=llList2String(menuCmdGroup, 0);
                string menuCmdSub=llList2String(menuCmdGroup, 1);
    
                string menuName=llList2String(menuCmdList, 1);
                string menuButton=llList2String(menuCmdList, 2);

                if(menuButton==accessMenuText){
                    llSensor("", NULL_KEY, AGENT, 96.0, PI);
                    showAccessMenu(menuName, user);
                }
                else if(menuName==accessMenuName && menuButton!=""){
                    llSensor("", NULL_KEY, AGENT, 96.0, PI);
                    showAccessSubMenu(menuButton, user);
                }
                else if(menuName==accessSubMenuName && menuButton!=""){
                    showAccessActiveMenu(menuButton, user);
                }
                else if(menuName==accessActiveMenuName && menuButton!=""){
					integer menuActiveFlag=-999;
                    list buList=llParseStringKeepNulls(menuButton,[". "],[""]);
                    integer buIndex=llList2Integer(buList,0);
                    string buName=llList2String(buList,1);
                    if(accessActiveFlag=="SetRoot"){
                        key u=llList2Key(sensorUserList, ((integer)buIndex));
                        menuActiveFlag=setRootOwner(u);
                    }
                    else if(accessActiveFlag=="AddOwner"){
                        key u=llList2Key(sensorUserList, ((integer)buIndex));
                        menuActiveFlag=addOwner(u);
                    }
                    else if(accessActiveFlag=="AddTrust"){
                        key u=llList2Key(sensorUserList, ((integer)buIndex));
                        menuActiveFlag=addTrust(u);
                    }
                    else if(accessActiveFlag=="AddBlack"){
                        key u=llList2Key(sensorUserList, ((integer)buIndex));
                        menuActiveFlag=addBlack(u);
                    }
                    else if(accessActiveFlag=="RemoveOwner"){
                        //key u=llList2Key(ownerList, (integer)buIndex); // Owner从1开始，第0个是root，因此不减1
                        //removeOwner(u);
                        // owner只能删除自己，因此从ownerList中找到用户名并删除
                        integer u;
                        for(u=1; u<llGetListLength(ownerList); u++){
                            key cu=llList2Key(ownerList, u);
                            string name=userName(cu,1);
                            if(name==buName){
                                menuActiveFlag=removeOwner(cu);
                            }
                        }
                    }
                    else if(accessActiveFlag=="RemoveTrust"){
                        key u=llList2Key(trustList, ((integer)buIndex)-1);
                        menuActiveFlag=removeTrust(u);
                    }
                    else if(accessActiveFlag=="RemoveBlack"){
                        key u=llList2Key(blackList, ((integer)buIndex)-1);
                        menuActiveFlag=removeBlack(u);
                    }
                    showAccessMenu(accessParentMenuName, user);
					if(menuActiveFlag!=-999){
						notifyAccess();
					}
                }
                else if(menuName=="AccessEscape" && menuButton=="Yes"){
                    if(menuButton=="Yes"){
                        clearAll();
                        llOwnerSay("You have escaped successful.");
                    }else{
                        showAccessMenu(accessParentMenuName, user);
                    }
                }
            }
        }
        if(llGetListLength(resultList)>0){
            llMessageLinked(LINK_SET, ACCESS_MSG_NUM, list2Bundle(resultList), user); // 处理完成后的回调
			notifyAccess();
        }
		llOwnerSay("Access Memory Used: "+(string)llGetUsedMemory()+" Free: "+(string)llGetFreeMemory());
    }

    sensor(integer detected) {
        sensorUserList=[];
		if(REZ_MODE==FALSE){
			sensorUserList+=[llGetOwner()]; // 穿在身上时，添加自己
		}
        integer i;
        for (i = 0; i < detected; i++) {
            key uuid = llDetectedKey(i);
            sensorUserList+=uuid;
        }
    }

    dataserver(key query_id, string data){
        if (query_id == readAccessQuery) { // 通过readAccessNotecards触发读取记事卡事件，按行读取配置并应用。
            if (data == EOF) {
                llOwnerSay("Finished reading access config: "+curAccessName);
                notifyAccess();
                readAccessQuery=NULL_KEY;
            } else {
                /*
                root=uuid
                owner=uuid1;uuid2;uuid3;...
                trust=uuid1;uuid2;uuid3;...
                black=uuid1;uuid2;uuid3;...
                public=1
                group=0
                hardcore=0
                lock=1
                */
                if(data!="" && llGetSubString(data,0,0)!="#"){
					list accStrSp=llParseStringKeepNulls(data, ["="], []);
					string accName=llList2String(accStrSp,0);
					list accData=data2List(llList2String(accStrSp,1));

					if(accName=="root"){
						// 当库存发生变化时，会读取access文件。为了防止修改其他数据影响rootOwner，因此只有在脚本重置后，root为玩家自己时，才应用此项
						if(llList2Key(ownerList, 0) == NULL_KEY || llList2Key(ownerList, 0) == llGetOwner()){
							setRootOwner(llList2Key(accData, 0));
						}
					}
					else if(accName=="owner"){
						integer i;
						for(i=0; i<llGetListLength(accData); i++){
							addOwner(llList2Key(accData, i));
						}
					}
					else if(accName=="trust"){
						integer i;
						for(i=0; i<llGetListLength(accData); i++){
							addTrust(llList2Key(accData, i));
						}
					}
					else if(accName=="black"){
						integer i;
						for(i=0; i<llGetListLength(accData); i++){
							addBlack(llList2Key(accData, i));
						}
					}
					else if(accName=="public"){
						setPublicMode(llList2Integer(accData, 0));
					}
					else if(accName=="group"){
						setGroupMode(llList2Integer(accData, 0));
					}
					else if(accName=="hardcore"){
						setHardcoreMode(llList2Integer(accData, 0));
					}
					else if(accName=="lock"){
						list lockMsg=[
							"RLV.LOCK",
							llList2Integer(accData, 0)
						];
						llMessageLinked(LINK_SET, RLV_MSG_NUM, list2Msg(lockMsg), llGetOwner());
					}
				}

                // increment line count
                ++readAccessLine;
                //request next line of notecard.
                readAccessQuery=llGetNotecardLine(readAccessName, readAccessLine);
            }
        }
    }
}
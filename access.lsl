initConfig(){
    ownerList=[]; // 第0个元素始终为root，从1开始为owner
    trustList=[];
    blackList=[];
    publicMode=TRUE;
    groupMode=FALSE;
    hardcore=FALSE;
    autoLock=FALSE;
}
/*CONFIG END*/
/*
Name: Access
Author: JMRY
Description: A better access permission control system, use link_message to operate permissions.

***更新记录***
- 1.0.19 20260211
    - 优化代码结构。
    - 修复重置无效的bug。

- 1.0.18 20260207
    - 优化文本提示。

- 1.0.17 20260204
    - 优化人物扫描逻辑。

- 1.0.16 20260203
    - 优化记事卡读取的回调逻辑，在没有记事卡时直接回调。

- 1.0.15 20260128
    - 优化内存占用。

- 1.0.14 20260121
    - 优化内存占用。
    - 优化RLV例外触发机制，提升性能。
    - 限制检测周围玩家的数量。

- 1.0.13 20260120
    - 加入自动锁定机制。

- 1.0.12 20260116
    - 优化RLV指令检测逻辑，自动重应用RLV例外。

- 1.0.11 20260111
    - 加入root和owner的RLV例外。

- 1.0.10 20260108
    - 加入权限变更时的文本通知。
    - 加入权限文本匹配语言功能。

- 1.0.9 20251204
    - 加入重置（逃跑）的通知。
    - 修复脚本重置后未发送权限变更通知的bug。

- 1.0.8 20251202
    - 加入主动读取记事卡的接口。
    - 修复读取记事卡错误的bug。

- 1.0.7 20251128
    - 加入指令显示菜单功能。

- 1.0.6 20251119
    - 优化菜单文本中权限状态的显示效果。
    - 修复owner菜单中有个空白按钮的bug。
    - 修复逃跑后未推送权限变更通知的bug。

- 1.0.5 20251118
    - 加入恢复Root权限时的权限变更通知。

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
// string userName(key user, integer type){
//     string username=llGetUsername(user);
//     string displayname=llGetDisplayName(user);
//     if(type==1){
//         return username;
//     }else if(type==2){
//         return displayname;
//     }else{
//         return displayname+" ("+username+")";
//     }
// }

// string replace(string src, string target, string replacement) {
//     return llReplaceSubString(src, target, replacement, 0);
// }

integer includes(string src, string target){
    integer startPos = llSubStringIndex(src, target);
    if(~startPos){
        return TRUE;
    }else{
        return FALSE;
    }
}

// string trim(string k){
//     return llStringTrim(k, STRING_TRIM);
// }

list strSplit(string m, string sp){
    list pl=llParseStringKeepNulls(m,[sp],[""]);
    list temp=[];
    integer i;
    for(i=0; i<llGetListLength(pl); i++){
        temp+=[llStringTrim(llList2String(pl, i), STRING_TRIM)];
    }
    return temp;
}
// string strJoin(list m, string sp){
//     return llDumpList2String(m, sp);
// }

// string messageSplit="|";
// list msg2List(string m){
//     return strSplit(m, "|");
// }
// string list2Msg(list m){
//     return strJoin(m, "|");
// }

// string dataSplit=";";
// list data2List(string d){
//     return strSplit(d, ";");
// }
string list2Data(list d){
    return llDumpList2String(d, ";");
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
        applyRLVExcepts(FALSE, llList2Key(ownerList, 0)); // 移除当前Root的RLV例外
        integer oIndex=llListFindList(ownerList, [user]);
        if(oIndex>0){ // 大于0表示该用户存在于owner列表，因此要先删掉，再加root，防止重复
            addOwner(user, FALSE);
        }
        ownerList=llListReplaceList(ownerList, [user], 0, 0);
    }
    return TRUE;
}
/*
查找owner，-1为不存在，0为root，大于0为owner
*/
// integer findOwner(key user){
//     return llListFindList(ownerList, [user]);
// }
/*
添加owner，列表中用户唯一，因此root和owner互斥不能共存
*/
integer addOwner(key user, integer bool){
    if(bool==TRUE){
        integer oIndex=llListFindList(ownerList, [user]);
        if(!~oIndex){ // 未找到key时，插入并返回TRUE
            addTrust(user, FALSE); // 添加主人时，移除信任和黑名单
            addBlack(user, FALSE);
            ownerList+=[user];
            return TRUE;
        }else{ // 找到key时，返回FALSE，包括root
            return FALSE;
        }
    }else{
        integer oIndex=llListFindList(ownerList, [user]);
        if(oIndex<=0){ // 0不可以移除，-1未找到，都返回FALSE
            return FALSE;
        }else{
            applyRLVExcepts(FALSE, llList2Key(ownerList, oIndex));
            ownerList=llDeleteSubList(ownerList, oIndex, oIndex);
            return TRUE;
        }
    }
}
// integer removeOwner(key user){
//     integer oIndex=llListFindList(ownerList, [user]);
//     if(oIndex<=0){ // 0不可以移除，-1未找到，都返回FALSE
//         return FALSE;
//     }else{
//         applyRLVExcepts(FALSE, llList2Key(ownerList, oIndex));
//         ownerList=llDeleteSubList(ownerList, oIndex, oIndex);
//         return TRUE;
//     }
// }

/*
信任列表
*/
list trustList=[];
// integer findTrust(key user){
//     return llListFindList(trustList, [user]);
// }
integer addTrust(key user, integer bool){
    if(bool==TRUE){
        integer oIndex=llListFindList(ownerList, [user]);
        if(~oIndex){
            return FALSE; // 已添加owner时，不能添加trust
        }
        integer tIndex=llListFindList(trustList, [user]);
        if(!~tIndex){ // 未找到key时，插入并返回TRUE
            trustList+=[user];
            addBlack(user, FALSE); // 加入信任列表时，移除黑名单
            return TRUE;
        }else{ // 找到key时，返回FALSE
            return FALSE;
        }
    }else{
        integer tIndex=llListFindList(trustList, [user]);
        if(!~tIndex){
            return FALSE;
        }else{
            trustList=llDeleteSubList(trustList, tIndex, tIndex);
            return TRUE;
        }
    }
}
// integer removeTrust(key user){
//     integer tIndex=llListFindList(trustList, [user]);
//     if(!~tIndex){
//         return FALSE;
//     }else{
//         trustList=llDeleteSubList(trustList, tIndex, tIndex);
//         return TRUE;
//     }
// }

/*
黑名单
*/
list blackList=[];
// integer findBlack(key user){
//     return llListFindList(blackList, [user]);
// }
integer addBlack(key user, integer bool){
    if(bool==TRUE){
        integer bIndex=llListFindList(blackList, [user]);
        if(!~bIndex){ // 未找到key时，插入并返回TRUE
            blackList+=[user];
            addOwner(user, FALSE); // 加入黑名单时，移除owner权限
            addTrust(user, FALSE); // 加入黑名单时，移除信任权限
            return TRUE;
        }else{ // 找到key时，返回FALSE
            return FALSE;
        }
    }else{
        integer bIndex=llListFindList(blackList, [user]);
        if(!~bIndex){
            return FALSE;
        }else{
            blackList=llDeleteSubList(blackList, bIndex, bIndex);
            return TRUE;
        }
    }
}
// integer removeBlack(key user){
//     integer bIndex=llListFindList(blackList, [user]);
//     if(!~bIndex){
//         return FALSE;
//     }else{
//         blackList=llDeleteSubList(blackList, bIndex, bIndex);
//         return TRUE;
//     }
// }

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
integer clearAll(){
    if(hardcore==TRUE){
        return FALSE;
    }else{
        llMessageLinked(LINK_SET, ACCESS_MSG_NUM, "ACCESS.EXEC|ACCESS.RESET|1", NULL_KEY);
        // llResetScript();
        ownerList=[llGetOwner()];
        setAutoLockMode(FALSE);
        notifyAccess();
        return TRUE;
    }
}

/*
自动锁定系统
*/
integer autoLock=FALSE;
integer setAutoLockMode(integer bool){
    if(bool==-1){
        if(autoLock==FALSE){
            bool=TRUE;
        }else{
            bool=FALSE;
        }
    }
    autoLock=bool;
    llMessageLinked(LINK_SET, RLV_MSG_NUM, "RLV.LOCK|"+(string)autoLock, llList2Key(ownerList, 0)); // 发送RLV锁定指令，其锁定者为root
    return bool;
}

/*
RLV例外
*/
list rlvExcepts=["startim","sendim","recvim","recvchat","recvemote","tplure","accepttp"];
applyRLVExcepts(integer bool, key user){
    if(bool==TRUE){
        integer i;
        integer r;
        for(i=0; i<llGetListLength(ownerList); i++){
            for(r=0; r<llGetListLength(rlvExcepts); r++){
                string curOwner=llList2String(ownerList, i);
                if(curOwner!=llGetOwner()){ // 自己本人不需要例外，因此过滤掉
                    llOwnerSay("@"+llList2String(rlvExcepts, r)+":"+curOwner+"=add");
                }
            }
        }
    }else{
        integer r;
        for(r=0; r<llGetListLength(rlvExcepts); r++){
            llOwnerSay("@"+llList2String(rlvExcepts, r)+":"+(string)user+"=rem");
        }
    }
}
// removeRLVExcepts(key user){
//     integer r;
//     for(r=0; r<llGetListLength(rlvExcepts); r++){
//         llOwnerSay("@"+llList2String(rlvExcepts, r)+":"+(string)user+"=rem");
//     }
// }

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
        integer owneri=llListFindList(ownerList, [user]);
        if(~owneri){
            return owneri;
        }else if(~llListFindList(trustList, [user])){
            return ACCESS_TRUST;
        }else if(~llListFindList(blackList, [user])){
            return ACCESS_BLACK;
        }else if(publicMode==TRUE){
            return ACCESS_PUBLIC;
        }else if(groupMode==TRUE && llSameGroup(user)==TRUE){
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
    llMessageLinked(LINK_SET, ACCESS_MSG_NUM, "ACCESS.NOTIFY|OWNER|"+list2Data(ownerList), "");
    llMessageLinked(LINK_SET, ACCESS_MSG_NUM, "ACCESS.NOTIFY|TRUST|"+list2Data(trustList), "");
    llMessageLinked(LINK_SET, ACCESS_MSG_NUM, "ACCESS.NOTIFY|BLACK|"+list2Data(blackList), "");
    llMessageLinked(LINK_SET, ACCESS_MSG_NUM, "ACCESS.NOTIFY|MODE|" +list2Data([publicMode, groupMode, hardcore, autoLock]),  "");
    applyRLVExcepts(TRUE, NULL_KEY);
    return TRUE;
}


key readAccessQuery=NULL_KEY;
integer readAccessLine=0;
string accessHeader="access_";
string readAccessName="";
string curAccessName="";
// integer readAccessNotecards(string aname){
//     readAccessLine=0;
//     curAccessName=aname;
//     readAccessName=accessHeader+aname;
//     if (llGetInventoryType(readAccessName) == INVENTORY_NOTECARD) {
//         llOwnerSay("Begin reading access settings: "+aname);
//         readAccessQuery=llGetNotecardLine(readAccessName, readAccessLine); // 通过给readAccessQuery赋llGetNotecardLine的key，从而触发datasever事件
//         // 后续功能交给下方datasever处理
//         return TRUE;
//     }else{
//         notifyAccess(); // 文件不存在时，直接发送权限变更通知
//         return FALSE;
//     }
// }

// list getAccessNotecards(){
//     list accessList=[];
//     integer count = llGetInventoryNumber(INVENTORY_NOTECARD);
//     integer i;
//     for (i=0; i<count; i++){
//         string notecardName = llGetInventoryName(INVENTORY_NOTECARD, i);
//         if(llGetSubString(notecardName, 0, llStringLength(accessHeader)-1)==accessHeader){
//             accessList+=[llGetSubString(notecardName, llStringLength(accessHeader), -1)];
//         }
//     }
//     return accessList;
// }

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
        if(hardcore==FALSE){
            buttonList+=["Escape"];
        }else{
            buttonList+=[" "];
        }
    }
    
    if(userPerm>=ACCESS_ROOT){
        string publicBu="["+(string)publicMode+"]Public";
        string groupBu="["+(string)groupMode+"]Group";
        string hardcoreBu="["+(string)hardcore+"]Hardcore";
        if(userPerm>ACCESS_ROOT){
            hardcoreBu=" "; // 只有root才能修改硬核模式
        }
        buttonList+=["Owner", "Trust", "Black", publicBu, groupBu, hardcoreBu];
    }

    string menuText="This is access menu, you can manage who can access %1%'s %2%.\nPublic mode: %b3%\nGroup mode: %b4%\nHardcore mode: %b5%%%;"+
        userInfo(llGetOwner())+";"+
        llGetObjectName()+";"+
        (string)publicMode+";"+
        (string)groupMode+";"+
        (string)hardcore;
    llMessageLinked(LINK_SET, MENU_MSG_NUM, "MENU.REG.OPEN|"+accessMenuName+"|"+menuText+"|"+list2Data(buttonList)+"|"+parent, user);
}

string accessSubMenuName="AccessSubMenu";
showAccessSubMenu(string button, key user){
    integer userPerm=getAccess(user);
    if(userPerm<0 && user!=llGetOwner()){
        return;
    }
    string menuText="";
    list buttonList=[];

    if(button=="Root" && userPerm==ACCESS_ROOT){
        menuText="Current Root: %1%. Click SetRoot to set new Root owner, click Restore to reset Root owner to wearer.%%;"+userInfo(llList2Key(ownerList, 0));
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
        menuText="%1%%2%%%;"+rootText+";"+ownerText;
    }
    else if(button=="Trust"){
        if(userPerm>=ACCESS_ROOT){
            buttonList+=["AddTrust", "RemoveTrust"];
        }
        menuText="Click AddTrust to add trust user.\nClick RemoveTrust to remove trust user.";
    }
    else if(button=="Black"){
        if(userPerm>=ACCESS_ROOT){
            buttonList+=["AddBlack", "RemoveBlack"];
        }
        menuText="Click AddBlack to add black user.\nClick RemoveBlack to remove black user.";
    }
    else if(button=="Public"){
        setPublicMode(-1);
        notifyAccess();
        // llOwnerSay("Your public mode is set to "+(string)publicMode);
        llMessageLinked(LINK_SET, MENU_MSG_NUM, "MENU.OUT|Your public mode is set to %1%.%%;"+(string)publicMode, user);
        showAccessMenu(accessParentMenuName, user);
        return;
    }
    else if(button=="Group"){
        setGroupMode(-1);
        notifyAccess();
        // llOwnerSay("Your group mode is set to "+(string)groupMode);
        llMessageLinked(LINK_SET, MENU_MSG_NUM, "MENU.OUT|Your group mode is set to %1%.%%;"+(string)groupMode, user);
        showAccessMenu(accessParentMenuName, user);
        return;
    }
    else if(button=="Hardcore"){
        setHardcoreMode(-1);
        notifyAccess();
        // llOwnerSay("Your hardcore mode is set to "+(string)hardcore);
        llMessageLinked(LINK_SET, MENU_MSG_NUM, "MENU.OUT|Your hardcore mode is set to %1%.%%;"+(string)hardcore, user);
        showAccessMenu(accessParentMenuName, user);
        return;
    }
    else if(button=="Escape"){
        llMessageLinked(LINK_SET, MENU_MSG_NUM, "MENU.CONFIRM|AccessEscape|Are you sure to escape? This will clear all of your access data, and restore Root to yourself.|"+list2Data(["Yes", "No"]), user);
        return;
    }
    else if(button=="AccessList"){
        integer i;
        // llRegionSayTo(user, 0, "Root:");
        llMessageLinked(LINK_SET, MENU_MSG_NUM, "MENU.OUT.TO|Root:|0|"+(string)user, user);
        for(i=0; i<llGetListLength(ownerList); i++){
            // llRegionSayTo(user, 0, userInfo(llList2Key(ownerList, i)));
            llMessageLinked(LINK_SET, MENU_MSG_NUM, "MENU.OUT.TO|"+userInfo(llList2Key(ownerList, i))+"|0|"+(string)user, user);
            if(i==0){
                // llRegionSayTo(user, 0, "Owners:");
                llMessageLinked(LINK_SET, MENU_MSG_NUM, "MENU.OUT.TO|Owners:|0|"+(string)user, user);
            }
        }
        // llRegionSayTo(user, 0, "Trust:");
        llMessageLinked(LINK_SET, MENU_MSG_NUM, "MENU.OUT.TO|Trust:|0|"+(string)user, user);
        for(i=0; i<llGetListLength(trustList); i++){
            // llRegionSayTo(user, 0, userInfo(llList2Key(trustList, i)));
            llMessageLinked(LINK_SET, MENU_MSG_NUM, "MENU.OUT.TO|"+userInfo(llList2Key(trustList, i))+"|0|"+(string)user, user);
        }
        // llRegionSayTo(user, 0, "Black:");
        llMessageLinked(LINK_SET, MENU_MSG_NUM, "MENU.OUT.TO|Black:|0|"+(string)user, user);
        for(i=0; i<llGetListLength(blackList); i++){
            // llRegionSayTo(user, 0, userInfo(llList2Key(blackList, i)));
            llMessageLinked(LINK_SET, MENU_MSG_NUM, "MENU.OUT.TO|"+userInfo(llList2Key(blackList, i))+"|0|"+(string)user, user);
        }
        // llRegionSayTo(user, 0, "Public mode: "+(string)publicMode);
        // llRegionSayTo(user, 0, "Group mode: "+(string)groupMode);
        // llRegionSayTo(user, 0, "Hardcore mode: "+(string)hardcore);
        llMessageLinked(LINK_SET, MENU_MSG_NUM, "MENU.OUT.TO|Public mode: %1%%%;"+(string)publicMode+"|0|"+(string)user, user);
        llMessageLinked(LINK_SET, MENU_MSG_NUM, "MENU.OUT.TO|Group mode: %1%%%;"+(string)groupMode+"|0|"+(string)user, user);
        llMessageLinked(LINK_SET, MENU_MSG_NUM, "MENU.OUT.TO|Hardcore mode: %1%%%;"+(string)hardcore+"|0|"+(string)user, user);
        showAccessMenu(accessParentMenuName, user);
        return;
    }
    llMessageLinked(LINK_SET, MENU_MSG_NUM, "MENU.REG.OPEN|"+accessSubMenuName+"|"+menuText+"|"+list2Data(buttonList)+"|"+accessMenuName, user);
}

string accessActiveMenuName="AccessActiveMenu";
string accessActiveFlag="";
key accessCurUser=NULL_KEY;
showAccessActiveMenu(string button, key user){
    integer userPerm=getAccess(user);
    if(userPerm<0){
        return;
    }
    accessActiveFlag=button;
    string menuText="";
    list buttonList=[];
    if(button=="SetRoot" || button=="AddOwner" || button=="AddTrust" || button=="AddBlack"){
        menuText="Select user to %1%.%%;"+button;
        // list userList=[];
        integer i;
        for(i=0; i<9; i++){
            key uk=llList2Key(sensorUserList, i);
            if(uk){
                // string un=userName(uk,1);
                string un=llGetUsername(uk);
                // userList+=[(string)(i+1) + ". " + un];
                buttonList+=[(string)i + ". " + un];
            }
        }
        // menuText+=[llDumpList2String(userList, "\n")];
    }
    else if(button=="RemoveOwner" || button=="RemoveTrust" || button=="RemoveBlack"){
        menuText="Select user to %1%.%%;"+button;
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
                // string un=userName(uk,1);
                string un=llGetUsername(uk);
                buttonList+=[(string)(i+1) + ". " + un];
            }
        }
    }
    else if(button=="Restore"){
        setRootOwner(llGetOwner());
        notifyAccess();
        showAccessMenu(accessParentMenuName, user);
        return;
    }
    llMessageLinked(LINK_SET, MENU_MSG_NUM, "MENU.REG.OPEN|"+accessActiveMenuName+"|"+menuText+"|"+list2Data(buttonList)+"|"+accessSubMenuName, user);
}

integer REZ_MODE=FALSE;
integer MENU_MSG_NUM=1000;
integer RLV_MSG_NUM=1001;
integer ACCESS_MSG_NUM=1002;
list sensorUserList=[];
integer maxSensor=18;
default{
    state_entry(){
        initConfig();
        if(llGetListLength(ownerList)==0){
            setRootOwner(llGetOwner()); // 初始化时，设置玩家为root
        }
        setAutoLockMode(autoLock);
        notifyAccess();
        // if(curAccessName!="" && readAccessName!=""){
        //     readAccessNotecards(readAccessName); // 读取记事卡应用权限
        // }
    }
    changed(integer change){
        // if(change & CHANGED_INVENTORY){
        //     if(curAccessName!="" && readAccessName!=""){
        //         readAccessNotecards(readAccessName);
        //     }
        // }
        if(change & CHANGED_OWNER){
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

        list msgList=strSplit(msg, "&&");
        list resultList=[];
        integer msgCount=llGetListLength(msgList);
        integer mi;
        for(mi=0; mi<msgCount; mi++){
            string str=llList2String(msgList, mi);
            if (llGetSubString(str, 0, 6) == "ACCESS." && !includes(str, "EXEC")) {
                list accessMsgList=strSplit(str, "|");
                string accessMsgStr=llList2String(accessMsgList, 0);
                list accessMsgGroup=llParseStringKeepNulls(accessMsgStr, ["."], [""]);

                string accessMsg=llList2String(accessMsgGroup, 0);
                string accessMsgSub=llList2String(accessMsgGroup, 1);
                string accessMsgExt=llList2String(accessMsgGroup, 2);
                string accessMsgExt2=llList2String(accessMsgGroup, 3);

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
                        result=(string)addOwner((key)accessMsgName, TRUE);
                    }
                    else if(accessMsgExt=="TRUST"){
                        result=(string)addTrust((key)accessMsgName, TRUE);
                    }
                    else if(accessMsgExt=="BLACK"){
                        result=(string)addBlack((key)accessMsgName, TRUE);
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
                        result=(string)addOwner((key)accessMsgName, FALSE);
                    }
                    else if(accessMsgExt=="TRUST"){
                        result=(string)addTrust((key)accessMsgName, FALSE);
                    }
                    else if(accessMsgExt=="BLACK"){
                        result=(string)addBlack((key)accessMsgName, FALSE);
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
                                publicMode,
                                groupMode,
                                hardcore,
                                autoLock
                            ];
                            result=list2Data(modes);
                        }
                        else if(accessMsgName=="PUBLIC"){
                            result=(string)publicMode;
                        }
                        else if(accessMsgName=="GROUP"){
                            result=(string)groupMode;
                        }
                        else if(accessMsgName=="HARDCORE"){
                            result=(string)hardcore;
                        }
                        else if(accessMsgName=="AUTOLOCK"){
                            result=(string)autoLock;
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
                        if(accessMsgExt2==""){
                            result=(string)setRootOwner((key)accessMsgName);
                        }
                        else if(accessMsgExt2=="KEEP"){
                            if(llList2Key(ownerList, 0) == NULL_KEY || llList2Key(ownerList, 0) == llGetOwner()){
                                result=(string)setRootOwner((key)accessMsgName);
                            }
                        }
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
                        if(accessMsgName=="AUTOLOCK"){
                            result=(string)setAutoLockMode((integer)accessMsgCmd);
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
                else if(accessMsgSub=="LOAD"){
                    /*
                    读取Access记事卡
                    ACCESS.LOAD | file1
                    回调：
                    ACCESS.EXEC | ACCESS.LOAD | 1
                    读取记事卡成功后的回调
                    ACCESS.LOAD.NOTECARD | file1 | 1
                    */
                    if(accessMsgExt==""){
                        // result=(string)readAccessNotecards(accessMsgName);
                        readAccessLine=0;
                        curAccessName=accessMsgName;
                        readAccessName=accessHeader+accessMsgName;
                        if (llGetInventoryType(readAccessName) == INVENTORY_NOTECARD) {
                            llOwnerSay("Begin reading access settings: "+accessMsgName);
                            readAccessQuery=llGetNotecardLine(readAccessName, readAccessLine); // 通过给readAccessQuery赋llGetNotecardLine的key，从而触发datasever事件
                            // 后续功能交给下方datasever处理
                            result="1";
                        }else{
                            llMessageLinked(LINK_SET, ACCESS_MSG_NUM, "ACCESS.LOAD.NOTECARD|"+accessMsgName+"|0", NULL_KEY);
                            notifyAccess(); // 文件不存在时，直接发送权限变更通知
                            result="0";
                        }
                    }
                    /*
                    读取Access记事卡列表
                    ACCESS.LOAD.LIST
                    回调：
                    ACCESS.EXEC | ACCESS.LOAD.LIST | access_a1, access_a2, access_a3, ...
                    */
                    if(accessMsgExt=="LIST"){
                        // result=(string)list2Data(getAccessNotecards());
                        list accessList=[];
                        integer count = llGetInventoryNumber(INVENTORY_NOTECARD);
                        integer i;
                        for (i=0; i<count; i++){
                            string notecardName = llGetInventoryName(INVENTORY_NOTECARD, i);
                            if(llGetSubString(notecardName, 0, llStringLength(accessHeader)-1)==accessHeader){
                                accessList+=[llGetSubString(notecardName, llStringLength(accessHeader), -1)];
                            }
                        }
                        result=list2Data(accessList);
                    }
                }
                else if(accessMsgSub=="MENU"){
                    /*
                    显示菜单
                    ACCESS.MENU | 上级菜单名
                    */
                    showAccessMenu(accessMsgName, user);
                }
                if(result!=""){
                    list accessExeResult=[
                        "ACCESS.EXEC", accessMsgStr, result
                    ];
                    resultList+=[llDumpList2String(accessExeResult, "|")];
                }
            }
            else if(llGetSubString(str, 0, 4) == "MENU." && includes(str, "ACTIVE")) {
                // MENU.ACTIVE | mainMenu | Access
                list menuCmdList=strSplit(str, "|");
                string menuCmdStr=llList2String(menuCmdList, 0);
                list menuCmdGroup=llParseStringKeepNulls(menuCmdStr, ["."], [""]);
    
                string menuCmd=llList2String(menuCmdGroup, 0);
                string menuCmdSub=llList2String(menuCmdGroup, 1);
    
                string menuName=llList2String(menuCmdList, 1);
                string menuButton=llList2String(menuCmdList, 2);

                if(menuButton==accessMenuText){
                    // llSensor("", NULL_KEY, AGENT, 96.0, PI);
                    showAccessMenu(menuName, user);
                }
                else if(menuName==accessMenuName && menuButton!=""){
                    // llSensor("", NULL_KEY, AGENT, 96.0, PI);
                    showAccessSubMenu(menuButton, user);
                }
                else if(menuName==accessSubMenuName && menuButton!=""){
                    // 设置主人、信任、黑名单时，先扫描再打开菜单
                    if(menuButton=="SetRoot" || menuButton=="AddOwner" || menuButton=="AddTrust" || menuButton=="AddBlack"){
                        accessActiveFlag=menuButton;
                        accessCurUser=user;
                        llSensor("", NULL_KEY, AGENT, 96.0, PI);
                    }else{
                        showAccessActiveMenu(menuButton, user);
                    }
                }
                else if(menuName==accessActiveMenuName && menuButton!=""){
                    integer menuActiveFlag=-999;
                    list buList=llParseStringKeepNulls(menuButton,[". "],[""]);
                    integer buIndex=llList2Integer(buList,0);
                    string buName=llList2String(buList,1);
                    key buUser=NULL_KEY;
                    if(accessActiveFlag=="SetRoot"){
                        buUser=llList2Key(sensorUserList, ((integer)buIndex));
                        menuActiveFlag=setRootOwner(buUser);
                        sensorUserList=[];
                    }
                    else if(accessActiveFlag=="AddOwner"){
                        buUser=llList2Key(sensorUserList, ((integer)buIndex));
                        menuActiveFlag=addOwner(buUser, TRUE);
                        sensorUserList=[];
                    }
                    else if(accessActiveFlag=="AddTrust"){
                        buUser=llList2Key(sensorUserList, ((integer)buIndex));
                        menuActiveFlag=addTrust(buUser, TRUE);
                        sensorUserList=[];
                    }
                    else if(accessActiveFlag=="AddBlack"){
                        buUser=llList2Key(sensorUserList, ((integer)buIndex));
                        menuActiveFlag=addBlack(buUser, TRUE);
                        sensorUserList=[];
                    }
                    else if(accessActiveFlag=="RemoveOwner"){
                        //key u=llList2Key(ownerList, (integer)buIndex); // Owner从1开始，第0个是root，因此不减1
                        //removeOwner(u);
                        // owner只能删除自己，因此从ownerList中找到用户名并删除
                        integer u;
                        for(u=1; u<llGetListLength(ownerList); u++){
                            buUser=llList2Key(ownerList, u);
                            // string name=userName(buUser,1);
                            string name=llGetUsername(buUser);
                            if(name==buName){
                                menuActiveFlag=addOwner(buUser, FALSE);
                            }
                        }
                    }
                    else if(accessActiveFlag=="RemoveTrust"){
                        buUser=llList2Key(trustList, ((integer)buIndex)-1);
                        menuActiveFlag=addTrust(buUser, FALSE);
                    }
                    else if(accessActiveFlag=="RemoveBlack"){
                        buUser=llList2Key(blackList, ((integer)buIndex)-1);
                        menuActiveFlag=addBlack(buUser, FALSE);
                    }
                    showAccessMenu(accessParentMenuName, user);
                    if(menuActiveFlag!=-999){
                        string buUserName="";
                        if(buUser!=NULL_KEY){
                            buUserName=" "+userInfo(buUser);
                        }
                        llMessageLinked(LINK_SET, MENU_MSG_NUM, "MENU.OUT|%1% %2% success!%%;"+accessActiveFlag+";"+buUserName, user);
                        notifyAccess();
                    }
                }
                else if(menuName=="AccessEscape"){
                    if(menuButton=="Yes"){
                        // llOwnerSay("You have escaped successful.");
                        llMessageLinked(LINK_SET, MENU_MSG_NUM, "MENU.OUT|You have escaped successful.", user);
                        clearAll();
                    }else{
                        showAccessMenu(accessParentMenuName, user);
                    }
                }
            }
            /*
            接收到RLV清空的通知时，重写RLV例外，防止例外失效
            */
            else if (llGetSubString(str, 0, 3) == "RLV." && includes(str, "EXEC") && (includes(str, "CLEAR") || includes(str, "APPLY.ALL"))) {
                applyRLVExcepts(TRUE, NULL_KEY);
            }
        }
        if(llGetListLength(resultList)>0){
            llMessageLinked(LINK_SET, ACCESS_MSG_NUM, llDumpList2String(resultList, "&&"), user); // 处理完成后的回调
            notifyAccess();
        }
        // llSleep(0.01);
        // llOwnerSay("Access Memory Used: "+(string)llGetUsedMemory()+"/"+(string)(65536-llGetUsedMemory())+" Free: "+(string)llGetFreeMemory());
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
        showAccessActiveMenu(accessActiveFlag, accessCurUser);
    }

    dataserver(key query_id, string data){
        if (query_id == readAccessQuery) { // 通过readAccessNotecards触发读取记事卡事件，按行读取配置并应用。
            if (data == EOF) {
                llOwnerSay("Finished reading access config: "+curAccessName);
                llMessageLinked(LINK_SET, ACCESS_MSG_NUM, "ACCESS.LOAD.NOTECARD|"+curAccessName+"|1", NULL_KEY); // 成功读取记事卡后回调
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
                    list accData=strSplit(llList2String(accStrSp,1), ";");

                    if(accName=="root"){
                        // 当库存发生变化时，会读取access文件。为了防止修改其他数据影响rootOwner，因此只有在脚本重置后，root为玩家自己时，才应用此项
                        if(llList2Key(ownerList, 0) == NULL_KEY || llList2Key(ownerList, 0) == llGetOwner()){
                            setRootOwner(llList2Key(accData, 0));
                        }
                    }
                    else if(accName=="owner"){
                        integer i;
                        for(i=0; i<llGetListLength(accData); i++){
                            addOwner(llList2Key(accData, i), TRUE);
                        }
                    }
                    else if(accName=="trust"){
                        integer i;
                        for(i=0; i<llGetListLength(accData); i++){
                            addTrust(llList2Key(accData, i), TRUE);
                        }
                    }
                    else if(accName=="black"){
                        integer i;
                        for(i=0; i<llGetListLength(accData); i++){
                            addBlack(llList2Key(accData, i), TRUE);
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
                        setAutoLockMode(llList2Integer(accData, 0));
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
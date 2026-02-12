initConfig(){
    rlvCmdList=[
        "Echo","_blind,rext_echoview","Vision",0,
        "LightBlind","_blind,setsphere,setsphere_distmin:10?force,setsphere_distmax:15?force,setsphere_valuemin:0?force","Vision",0,
        "HeavyBlind","_blind,camdistmax:5,setsphere,setsphere_distmin:5?force,setsphere_distmax:5?force,setsphere_valuemin:0?force,setcam_unlock,shownames_sec,shownametags,shownearby,showhovertextall,showworldmap,showminimap,showloc","Vision",0,
        "Camera","camdistmax:5,setcam_unlock","Vision",0,
        "Name","shownames_sec,shownametags","Vision",0,
        "Near","shownearby","Vision",0,
        "TextWorld","showhovertextworld","Vision",0,
        "TextHUD","showhovertexthud","Vision",0,
        "TextAll","showhovertextall","Vision",0,

        "Far","fartouch?n?y","Touch",0,
        "World","touchworld","Touch",0,
        "Me","touchme","Touch",0,
        "Attach","touchattach","Touch",0,
        "SelfAttach","touchattachself","Touch",0,
        "OtherAttach","touchattachother","Touch",0,
        "HUD","touchhud","Touch",0,
        "All","touchall","Touch",0,
        "Interact","interact","Touch",0,

        "Inventory","showinv","Inventory",0,
        "Note","viewnote","Inventory",0,
        "Script","viewscript","Inventory",0,
        "Texture","viewtexture","Inventory",0,
        "Edit","edit,editworld,editattach","Inventory",0,
        "Rez","rez","Inventory",0,
        "Share","share_sec","Inventory",0,

        "Run","alwaysrun?n?y,temprun","Move",0,
        "Fly","fly","Move",0,
        "Sit","sit","Move",0,
        "Jump","jump","Move",0,
        "Slow","rext_speed:0","Move",0,
        "MoveTurn","rext_move,rext_turn","Move",0,

        "SendChat","sendchat,chatshout,chatnormal,chatwhisper","Chat",0,
        "RecvChat","recvchat","Chat",0,
        "SendGesture","sendgesture","Chat",0,
        "RecvGesture","recvemote_sec","Chat",0,
        "StartIM","startim","Chat",0,
        "SendIM","sendim_sec","Chat",0,
        "RecvIM","recvim_sec","Chat",0,

        "TPLocal","tplocal,sittp,standtp","Location",0,
        "TPLM","tplm","Location",0,
        "TPLocation","tploc","Location",0,
        "TPLure","tplure_sec","Location",0,
        "TPRequest","tprequest_sec","Location",0,
        "WorldMap","showworldmap","Location",0,
        "MiniMap","showminimap","Location",0,
        "Location","showloc","Location",0,

        "Add","addattach,addoutfit,unsharedwear,sharedwear","Attach",0,
        "Remove","remattach,remoutfit,unsharedunwear,sharedunwear","Attach",0
    ]; // name, rlvs, class, enabled
}
/*CONFIG END*/
/*
Name: RLV
Author: JMRY
Description: A better RLV management system, use link_message to operate RLV restraints.

***更新记录***
- 2.0.6 20260213
    - 优化RLV捕获功能的逻辑。

- 2.0.5 20260212
    - 优化初始化和应用全部RLV限制的逻辑。
    - 修复RLV执行顺序先后导致的失效bug。

- 2.0.4 20260211
    - 加入内置RLV限制。
    - 优化代码结构。
    - 修复清空RLV组时，仍然会触发@clear清空指令的bug。
    - 修复RLV返回锁定状态错误的bug。

- 2.0.3 20260207
    - 优化只有一个Class时，菜单注册的逻辑。
    - 优化应用全部RLV限制的逻辑，修复互斥锁导致的无法全关的bug。

- 2.0.2 20260203
    - 优化记事卡读取的回调逻辑，在没有记事卡时直接回调。

- 2.0.1 20260202
    - 优化互斥组禁用的逻辑。

- 2.0 20260131
    -重构RLV脚本。

- 1.1.12 20260130
    - 优化RLV组的执行性能。
    - 优化Rez模式下RLV的执行效果。
    - 修复在Rez模式下，输出异常指令的bug。

- 1.1.11 20260128
    - 优化内存占用。

- 1.1.10 20260127
    - 修复使用指令打开菜单时，未能直接打开子菜单的bug。

- 1.1.9 20260126
    - 加入一键应用当前RLV类别中的全部RLV组功能。
    - 调整RLV菜单打开方式，当只有一个RLV类别时，直接打开子菜单。

- 1.1.8 20260121
    - 优化内存占用。

- 1.1.7 20260116
    - 加入RLV组执行结果通知。

- 1.1.6 20260115
    - 优化设置RLV限制时的文本描述。

- 1.1.5 20260113
    - 分离RLV Ext模块。
    - 优化RLV Ext的处理逻辑和内存占用。

- 1.1.4 20260111
    - 加入清空RLV限制（@clear）时的消息通知。
    - 优化内存占用。

- 1.1.3 20260108
    - 加入RLV状态变更的文本通知。

- 1.1.2 20251202
    - 修复RLV.LOAD.LIST返回格式错误的bug。

- 1.1.1 20251128
    - 加入指令显示菜单功能。
    - 加入禁止转向的扩展指令。
    - 加入配置指定RLV默认开启功能。
    - 优化扩展指令的算法，使其支持更灵活的配置。
    - 分离Renamer到单独的脚本。

- 1.1 20251127
    - 加入RLV扩展指令。
    - 加入Renamer菜单。
    - 优化内存占用。

- 1.0.18 20251122
    - 加入锁定和RLV联动。
    - 优化RLV命令索引机制。

- 1.0.17 20251119
    - RLV获取锁定状态加入返回锁定用户。

- 1.0.16 20251114
    - 修复RLV功能菜单显示错误的bug。
    -修复REZ模式RLV失效的bug。

- 1.0.15 20251018
    - 加入Renamer表情标签。
    - 加入Renamer返回频道状态。

- 1.0.14 20250926
    - 修复编译时报错的bug。

- 1.0.13 20250806
    - 优化内存占用。

- 1.0.12 20250703
    - 修复rez的RLV道具回复消息中uuid错误的bug。

- 1.0.11 20250120
    - 优化锁定逻辑，修复锁定时无法从家具上站起来的bug。

- 1.0.10 20250118
    - 优化穿戴时RLV执行的逻辑。
    - 优化放置物体时，模式判断的逻辑。
    - 修复批量执行RLV时，结束条件错误导致后续指令无法执行的bug。

- 1.0.9 20250115
    - 调整配置文件格式。

- 1.0.8 20250114
    - 优化内存占用。
    - 修复修改配置文件时重置脚本的bug。

- 1.0.7 20250113
    - 修复RLV判断逻辑的bug。
    - 修复bugs。

- 1.0.6 20250108
    - 为RLV功能添加消息识别ID。
    - 调整RLV消息指令处理逻辑。

- 1.0.5 20250103
    - 加入读取记事卡导入RLV数据功能。
    - 修复部分bug，优化处理逻辑。

- 1.0.4 20241231
    - 加入重命名功能。
    - 优化捕获功能逻辑。

- 1.0.3 20241230
    - 加入RLV捕获功能。
    - 加入RLV消息回复监听功能。
    - 加入直接运行RLV指令字符串功能。
    - 调整RLV.RUN指令传递内容和运行方式。
    - 调整RLV执行入口以兼容REZ模式的RLV指令。

- 1.0.2 20241228
    - 修复bugs。

- 1.0.1 20241227
    - 初步完成RLV、管理、功能和菜单。

- 1.0 20241226
    - 初步完成RLV数据化管理。
***更新记录***
*/

/*
TODO:
- ~~应用RLV限制~~
- ~~RLV菜单~~
    - ~~可自定义的RLV主分类~~
    - ~~可自定义的RLV主分类下的子菜单~~
    - ~~根据子菜单注册的指令集一键应用RLV限制，并更新状态~~
- ~~锁定和解锁功能~~
- ~~穿戴时重新应用RLV功能~~
- ~~Rez时，RLV捕获和限制功能~~
- ~~RLV指定频道回复监听功能~~
- 获取#RLV文件夹内容并穿脱功能
- 内存和性能优化
- 分离Rez模式的RLV
*/

/*
基础功能依赖函数
*/
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

// string dataSplit=",";
list data2RlvList(string d){
    return strSplit(d, ",");
}
string list2RlvData(list d){
    return llDumpList2String(d, ",");
}

string list2Data(list d){
    return llDumpList2String(d, ";");
}

/*
设置RLV，参数：RLV指令，RLV值
*/
integer RLVRS=-1812221819; // default relay channel
integer RLV_MODE=0; // 0： wear mode；1：rez mode say；2：rez mode whisper；3：rez mode shout；else：rez mode regionSayTo
integer rlvWorldListenHandle;
key VICTIM_UUID=NULL_KEY; // victim uuid in rez mode

/*
执行RLV，参数：RLV指令，是否持久化
RLV指令为ALL时，执行所有记忆中的RLV限制
RLV指令为HAS:开头的RLV指令时，判断组内全部RLV限制是否生效（格式：HAS:@rlv1=n,rlv2=add,...）
_开头的RLV指令为互斥组标记，不执行。
*/
string RLVExtHeader="rext_";
list executeRLVList=[];
integer executeRLV(string rlv, integer bool){
    // rlv: @rlv=n/y    bool: isEnduring
    rlv=llReplaceSubString(rlv, "@", "", 0); // 去除@开头
    integer i;
    if(rlv=="ALL"){ // executeRLV("ALL", TRUE/FALSE)
        for(i=0; i<llGetListLength(executeRLVList); i++){
            executeRLV(llList2String(executeRLVList, i), FALSE);
        }
        return bool;
    }
    else if(includes(rlv, "HAS:")){ // executeRLV("HAS:@rlv1=n,rlv2=n", TRUE/FALSE);
        list rlvList=data2RlvList(llList2String(llParseStringKeepNulls(rlv, [":"], [""]), 1));
        if(llGetListLength(rlvList)<1){
            return FALSE;
        }
        for(i=0; i<llGetListLength(rlvList); i++){
            integer rIndex=llListFindList(executeRLVList, [llList2String(rlvList, i)]);
            if(!~rIndex){
                return FALSE;
            }
        }
        return TRUE;
    }
    if(includes(rlv, ",")){ // 有多个RLV指令时，批量递归执行
        list rlvList=data2RlvList(rlv);
        for(i=0; i<llGetListLength(rlvList); i++){
            executeRLV(llList2String(rlvList, i), bool);
        }
        return bool;
    }
    if(llGetSubString(rlv, 0, 0)=="_"){ // _开头的为互斥组标记，不执行
        return FALSE;
    }
    if(bool==TRUE){ // bool为TRUE时，记忆RLV指令，以便恢复状态。否则不进行任何记录
        if(rlv=="clear"){
            executeRLVList=[];
        }else{
            integer rIndex=llListFindList(executeRLVList, [getRLVValue(rlv, TRUE)]); // executeRLVList中的值恒为n、add、force，因此传入替换后的生效值
            if(includes(rlv, "=n") || includes(rlv, "=add") || includes(rlv, "=force")){
                if(!~rIndex){ // RLV生效时，如果列表中没有，则添加
                    executeRLVList+=[rlv];
                }
            }else{
                if(~rIndex){ // RLV失效时，如果列表中有，则删除
                    executeRLVList=llDeleteSubList(executeRLVList, rIndex, rIndex);
                }
            }
        }
    }
    llListenRemove(rlvWorldListenHandle);

    rlv="@"+rlv;
    if(RLV_MODE==0){
        llOwnerSay(rlv);
    }else{
        string rlvExecStr="RLV_EXECUTE_"+llGetObjectName()+","+(string)VICTIM_UUID+","+rlv;
        if(RLV_MODE==1){
            llSay(RLVRS,rlvExecStr);
        }else if(RLV_MODE==2){
            llWhisper(RLVRS,rlvExecStr);
        }else if(RLV_MODE==3){
            llShout(RLVRS,rlvExecStr);
        }else{
            llRegionSay(RLVRS,rlvExecStr);
        }
        rlvWorldListenHandle=llListen(RLVRS, "", NULL_KEY, "");
    }

    if(rlv=="@clear"){ // clear时，遍历list清除RLV扩展限制
        llMessageLinked(LINK_SET, RLVEXT_MSG_NUM, "RLVEXT.RUN|clear", NULL_KEY);
        llMessageLinked(LINK_SET, RLV_MSG_NUM, "RLV.EXEC|RLV.CLEAR|1", NULL_KEY);
    }
    if(llGetSubString(rlv, 1, llStringLength(RLVExtHeader)) == RLVExtHeader){ // @rext_move=n
        // Execute RLV Ext
        llMessageLinked(LINK_SET, RLVEXT_MSG_NUM, "RLVEXT.RUN|"+rlv, NULL_KEY);
    }
    return bool;
}

string getRLVValue(string rlv, integer bool){
    if(bool==TRUE){
        return llReplaceSubString(llReplaceSubString(rlv, "=rem", "=add", 0), "=y", "=n", 0);
    }else{
        return llReplaceSubString(llReplaceSubString(llReplaceSubString(rlv, "=add", "=rem", 0), "=n", "=y", 0), "=force", "=rem", 0);
    }
}

list rlvCmdList=[]; // name, rlvs, class, enabled
integer rlvCmdLength=4;
// integer rlvClassCount=0;
integer setRLVCmd(string name, string k, string class, integer enabled){
    integer rIndex;
    integer notFound=TRUE;
    for(rIndex=0; rIndex<llGetListLength(rlvCmdList); rIndex+=rlvCmdLength){
        string curRlvCmdName=llList2String(rlvCmdList, rIndex);
        if(curRlvCmdName == name){
            rlvCmdList=llListReplaceList(rlvCmdList,[k, class, enabled],rIndex+1,rIndex+rlvCmdLength-1);
            notFound=FALSE;
        }
    }
    if(notFound==TRUE){
        rlvCmdList+=[name, k, class, enabled];
    }
    // rlvClassCount=0;
    // string curClass="";
    // for(rIndex=0; rIndex<llGetListLength(rlvCmdList); rIndex+=rlvCmdLength){
    //     if(curClass != llList2String(rlvCmdList, rIndex+2)){
    //         curClass=llList2String(rlvCmdList, rIndex+2);
    //         rlvClassCount++;
    //     }
    // }
    return TRUE;
}

integer removeRLVCmd(string name){
    integer i;
    for(i=0; i<llGetListLength(rlvCmdList); i+=rlvCmdLength){
        string curRlvCmdName=llList2String(rlvCmdList, i);
        if(curRlvCmdName == name){
            rlvCmdList=llDeleteSubList(rlvCmdList,i,i+rlvCmdLength-1);
            return TRUE;
        }
    }
    return FALSE;
}

list getRLVCmd(string name, integer includesIndex){
    integer i;
    for(i=0; i<llGetListLength(rlvCmdList); i+=rlvCmdLength){
        string curRlvCmdName=llList2String(rlvCmdList, i);
        if(curRlvCmdName == name){
            if(includesIndex==TRUE){
                return [llList2String(rlvCmdList, i), llList2String(rlvCmdList, i+1), llList2String(rlvCmdList, i+2), llList2Integer(rlvCmdList, i+3), i];
            }else{
                return [llList2String(rlvCmdList, i), llList2String(rlvCmdList, i+1), llList2String(rlvCmdList, i+2), llList2Integer(rlvCmdList, i+3)];
            }
        }
    }
    return [];
}

integer applyRLVCmd(string name, integer bool){
    list curRlvCmd=getRLVCmd(name, TRUE); // [name, rlvs, class, enabled, index]
    if(llGetListLength(curRlvCmd)>0){
        list curRlvList=data2RlvList(llList2String(curRlvCmd, 1));
        integer curBool=llList2Integer(curRlvCmd, 3);
        integer curIndex=llList2Integer(curRlvCmd, 4);
        if(bool<0){
            if(curBool==TRUE){
                bool=FALSE;
            }else{
                bool=TRUE;
            }
        }
        integer r;
        for(r=0; r<llGetListLength(curRlvList); r++){
            list curRlvSp=llParseStringKeepNulls(llList2String(curRlvList, r),["?"],[""]);
            string curRlv=llList2String(curRlvSp, 0);
            string curRlvEnable =llList2String(curRlvSp, 1);
            string curRlvDisable=llList2String(curRlvSp, 2);
            if(curRlvEnable==""){
                curRlvEnable="n";
            }
            if(curRlvDisable==""){
                if(curRlvEnable=="n"){
                    curRlvDisable="y";
                }else if(curRlvEnable=="add" || curRlvEnable=="force"){
                    curRlvDisable="rem";
                }else{
                    curRlvDisable="y";
                }
            }
            if(bool==TRUE){
                // 互斥组禁用（检测RLV首个_开头的互斥组标记，并将同组其他RLV禁用）
                if(llGetSubString(curRlv, 0, 0)=="_"){
                    integer i;
                    for(i=1; i<llGetListLength(rlvCmdList); i+=rlvCmdLength){ // name, >rlvs<, class, enabled
                        if(includes(llList2String(rlvCmdList, i), curRlv) && llList2Integer(rlvCmdList, i+2)==TRUE){
                            applyRLVCmd(llList2String(rlvCmdList, i-1), FALSE);
                        }
                    }
                }
                executeRLV(curRlv+"="+curRlvEnable,  TRUE);
            }else{
                executeRLV(curRlv+"="+curRlvDisable, TRUE);
            }
        }
        rlvCmdList=llListReplaceList(rlvCmdList,[bool],curIndex+3,curIndex+3);
        llMessageLinked(LINK_SET, RLV_MSG_NUM, "RLV.EXEC|RLV.APPLY|"+name+"|"+(string)bool, NULL_KEY);
        return bool;
    }
    return FALSE;
}

integer applyAllRLVCmd(){
    integer i;
    for(i=0; i<llGetListLength(rlvCmdList); i+=rlvCmdLength){
        string curRlvCmdName=llList2String(rlvCmdList, i);
        integer curRlvEnabled=llList2Integer(rlvCmdList, i+3);
        if(curRlvEnabled==TRUE){
            applyRLVCmd(curRlvCmdName, curRlvEnabled);
        }
    }
    llMessageLinked(LINK_SET, RLV_MSG_NUM, "RLV.EXEC|RLV.APPLY.ALL|1", NULL_KEY);
    return TRUE;
}

integer isLocked=FALSE;
key lockUser=NULL_KEY;
integer lockRLVConnect=TRUE;
integer setLock(integer bool, key user){
    if(bool==-1){
        if(isLocked==FALSE){
            bool=TRUE;
        }else{
            bool=FALSE;
        }
    }
    string lockStr="@detach";
    if(RLV_MODE>0){
        lockStr="@unsit";
    }
    if(bool==0){
        executeRLV(lockStr+"=y", TRUE);
        lockUser=NULL_KEY;
        if(lockRLVConnect==TRUE){ // 锁和RLV联动时，解锁清空所有限制，但保留RLV状态（hasRLV优先读取记录的状态）
            executeRLV("@clear", TRUE);
        }
    }else{
        executeRLV(lockStr+"=n", TRUE);
        lockUser=user;
        if(lockRLVConnect==TRUE){ // 锁和RLV联动时，锁定即应用之前的限制
            applyAllRLVCmd();
        }
    }
    isLocked=bool;
    return bool;
}
integer getLock(){
    if(executeRLV("HAS:@detach", FALSE) || executeRLV("HAS:@unsit", FALSE)){
        return TRUE;
    }else{
        return FALSE;
    }
}

/*
RLV菜单控制
*/
string rlvMenuText="RLV";
string rlvMenuName="RLVMenu";
showRLVMenu(string parent, key user){
    list rlvClass=[];
    string curClass="";
    integer i;
    for(i=0; i<llGetListLength(rlvCmdList); i+=rlvCmdLength){
        string class=llList2String(rlvCmdList, i+2);
        if(class!="" && curClass != class){
            rlvClass+=[class];
            curClass=class;
        }
    }
    if(llGetListLength(rlvClass)<=1){
        showRLVSubMenu(parent, curClass, user);
    }else{
        llMessageLinked(LINK_SET, MENU_MSG_NUM, "MENU.REG.OPEN|"+rlvMenuName+"|"+"RLV Menu"+"|"+list2Data(rlvClass)+"|"+parent, user);
    }
}

string rlvSubMenuName="RLVSubMenu";
string rlvParentMenuName="";
string curRlvSubMenu="";
showRLVSubMenu(string parent, string class, key user){
    rlvParentMenuName=parent;
    curRlvSubMenu=class;
    string rlvSubDesc="This is RLV %1% menu.%%;"+class;
    list rlvList=["[ALL]"];
    string rlvSubMenuList;
    integer rlvCmdCount=llGetListLength(rlvCmdList);
    integer i;
    for(i=0; i<rlvCmdCount; i+=rlvCmdLength){
        string curName=llList2String(rlvCmdList, i);
        string curClass=llList2String(rlvCmdList, i+2);
        integer curEnabled=llList2Integer(rlvCmdList, i+3);
        if(curClass==class){
            rlvList+=["["+(string)curEnabled+"]"+curName];
        }
    }
    rlvSubMenuList="MENU.REG.OPEN|"+rlvSubMenuName+"|"+rlvSubDesc+"|"+list2Data(rlvList)+"|"+parent;
    llMessageLinked(LINK_SET, MENU_MSG_NUM, rlvSubMenuList, user);
}


string rlvHeader="rlv_"; // 语言文件名记事卡前缀rlv_语言名（英文），如：rlv_1, rlv_2等
key readRLVQuery=NULL_KEY;
integer readRLVLine=0;
string readRLVName="";
string curRLVName="";
string curRLVClass="";

integer MENU_MSG_NUM=1000;
integer RLV_MSG_NUM=1001;
integer RENAMER_MSG_NUM=10011;
integer RLVEXT_MSG_NUM=10012;
default{
    state_entry(){
        initConfig();
        // llSleep(1);
        // if(llGetAttached()){
        //     applyAllRLVCmd();
        // }
    }
    changed(integer change){
        if(change & CHANGED_OWNER){
            llResetScript();
        }
        if (change & CHANGED_LINK) {
            key avatar = llAvatarOnSitTarget();
            if (avatar != NULL_KEY){
                RLV_MODE=1;
                VICTIM_UUID=avatar;
                applyAllRLVCmd();
            }else{
                executeRLV("sit:"+(string)llGetKey()+"=rem", TRUE);
                VICTIM_UUID=NULL_KEY;
            }
        }
    }

    listen(integer channel, string name, key user, string message){
        // Rez模式与Relay的交互
        if(RLV_MODE>0 && channel==RLVRS){
            list dataList=data2RlvList(message); // header,uuid,main,ext
            string cmdHeader=llList2String(dataList, 0);
            key    cmdUuid=llList2Key(dataList, 1);
            string cmdMain=llList2String(dataList, 2);
            string cmdExt =llList2String(dataList, 3);

            list replyList=[];
            // Relay:  ping,VICTIM_UUID,ping,ping
            // Object: ping,OBJECT_UUID,!pong
            if(cmdMain=="ping" && cmdExt=="ping" && cmdUuid==llGetKey()){ // Relay发送ping,ping，道具回复!pong
                replyList=[cmdHeader, llGetKey(), "!pong"];
            }
            // Relay:  BunchoCommands,VICTIM_UUID,!release
            // Object: BunchoCommands,OBJECT_UUID,!release,ok
            else if(cmdMain=="!release"){ // Relay发送释放指令，道具回复ok
                executeRLV("@clear", TRUE);
                VICTIM_UUID=NULL_KEY;
                replyList=[cmdHeader, llGetKey(), cmdMain, "ok"];
            }
            // Object: BunchoCommands,VICTIM_UUID,@remoutfit:shoes=force
            // Relay:  BunchoCommands,OBJECT_UUID,@remoutfit:shoes=force,ko
            // Object: BunchoCommands,VICTIM_UUID,@remoutfit:shoes=force
            else if(cmdExt=="ko"){ // Relay发送RLV执行结果为ko，则重新执行一次RLV指令
                executeRLV(cmdMain, FALSE);
            }

            if(llGetListLength(replyList)>0){
                llSay(RLVRS,list2RlvData(replyList));
            }
        }
    }

    attach(key user) {
        RLV_MODE=0;
        if(user!=NULL_KEY){
            executeRLV("ALL", FALSE);
        }else{
            executeRLV("@clear", FALSE); // 脱下时，仅清除RLV状态，不清空列表，下次穿戴时重新应用
        }
    }
    on_rez(integer start_param){
        // 登录、穿戴时也会触发on_rez，并且比attach更早触发。有时候登录时不触发attach，因此将attach的部分也添加到这里。
        integer attached=llGetAttached();
        if(attached!=0){
            RLV_MODE=0;
            executeRLV("ALL", FALSE);
        }else{
            RLV_MODE=1;
        }
    }
    object_rez(key user){
        RLV_MODE=1;
    }
    link_message(integer sender_num, integer num, string msg, key user){
        if(num!=RLV_MSG_NUM && num!=MENU_MSG_NUM){
            return;
        }
        list bundleMsgList=strSplit(msg, "&&");
        list resultList=[];
        integer bundleMsgCount=llGetListLength(bundleMsgList);
        integer mi;
        for(mi=0; mi<bundleMsgCount; mi++){
            string str=llList2String(bundleMsgList, mi);
            if(!includes(str, "RLV") && !includes(str, "MENU.ACTIVE")){
                return;
            }
            list msgList=strSplit(str, "|");
            string msgHeader=llList2String(msgList, 0);
            list msgHeaderGroup=llParseStringKeepNulls(msgHeader, ["."], [""]);

            string headerMain=llList2String(msgHeaderGroup, 0);
            string headerSub=llList2String(msgHeaderGroup, 1);
            string headerExt=llList2String(msgHeaderGroup, 2);

            string msgName=llList2String(msgList, 1);
            string msgSub=llList2String(msgList, 2);
            string msgExt=llList2String(msgList, 3);
            string msgExt2=llList2String(msgList, 3);

            if(headerMain=="RLV" && headerSub!="EXEC"){
                string result="";
                /*
                注册RLV组，格式：标头 | RLV名 | RLV1, RLV2, ... | RLV类别（可选） | 是否自动启用
                如果RLV类别为空，则注册为野RLV组，不会出现在菜单中。
                RLV.REG | RLVName | RLV1, RLV2, RLV3, ...
                RLV.REGIST | RLVName | RLV1, RLV2, RLV3, ... | Class 1
                RLV.REGIST | RLVName | RLV1, RLV2, RLV3, ... | Class 1 | 0
                RLV.REGIST | RLVName | RLV1, RLV2, RLV3, ... | Class 1 | 1
                RLV执行后，会发送执行结果回调，格式：
                RLV.EXEC | RLV.REG.APPLY | 1 // 1=成功，0=失败，或其他结果字符串
                */
                if(headerSub=="REG" || headerSub=="REGIST"){
                    result=(string)setRLVCmd(msgName, msgSub, msgExt, (integer)msgExt2);
                    if((integer)msgExt2==TRUE){
                        applyRLVCmd(msgName, (integer)msgExt2);
                    }
                }
                /*
                应用已注册的RLV组
                RLV.APPLY | RLVName | -1
                RLV.APPLY | RLVName | 1
                RLV.APPLY | RLVName | 0
                */
                else if(headerSub=="APPLY"){
                    result=(string)applyRLVCmd(msgName, (integer)msgSub);
                }
                /*
                应用全部的RLV组
                RLV.APPLY.ALL
                */
                else if(headerSub=="APPLYALL"){
                    result=(string)applyAllRLVCmd();
                }
                /*
                移除RLV组
                移除RLV组时，还会取消此组内的RLV限制。
                RLV.REM | RLVName
                RLV.REMOVE | RLVName
                */
                else if(headerSub=="REM" || headerSub=="REMOVE"){
                    applyRLVCmd(msgName, FALSE);
                    result=(string)removeRLVCmd(msgName);
                }
                else if(headerSub=="CLEAR"){
                    /*
                    清空所有RLV组
                    RLV.CLEAR
                    */
                    if(headerExt==""){
                        rlvCmdList=[];
                        result="";
                    }
                }
                else if(headerSub=="LOCK"){
                    /*
                    锁定/解锁
                    RLV.LOCK | -1
                    RLV.LOCK | 1
                    RLV.LOCK | 0
                    */
                    setLock((integer)msgName, user);
                    result=list2Data([isLocked, lockUser]);
                }
                /*
                捕获玩家
                RLV.CAPTURE | UUID | 1
                */
                else if(headerSub=="CAPTURE"){
                    // result=(string)captureVictim((key)msgName);
                    if(RLV_MODE<=0){
                        result=(string)FALSE;
                    }else{
                        VICTIM_UUID=(key)msgName;
                        if((integer)msgSub==TRUE){
                            executeRLV("sit:"+(string)llGetKey()+"=force", TRUE);
                        }
                        applyAllRLVCmd()
                        result=(string)TRUE;
                    }
                }
                else if(headerSub=="LOAD"){
                    /*
                    读取RLV记事卡（将覆盖现有的RLV数据）
                    RLV.LOAD | rlv1
                    返回：
                    RLV.EXEC | RLV.LOAD | 1
                    */
                    if(headerExt==""){
                        // result=(string)readRLVNotecards(msgName);
                        readRLVLine=0;
                        curRLVName=msgName;
                        readRLVName=rlvHeader+msgName;
                        curRLVClass="";
                        if (llGetInventoryType(readRLVName) == INVENTORY_NOTECARD) {
                            llOwnerSay("Begin reading RLV restraints: "+msgName);
                            rlvCmdList=[];
                            readRLVQuery=llGetNotecardLine(readRLVName, readRLVLine); // 通过给readRLVQuery赋llGetNotecardLine的key，从而触发datasever事件
                            // 后续功能交给下方datasever处理
                            result=(string)TRUE;
                        }else{
                            llMessageLinked(LINK_SET, RLV_MSG_NUM, "RLV.LOAD.NOTECARD|"+msgName+"|"+(string)llGetListLength(rlvCmdList), NULL_KEY); // RLV成功读取记事卡后回调
                            if(llGetAttached()){
                                applyAllRLVCmd();
                            }
                            result=(string)FALSE;
                        }
                    }
                    /*
                    读取RLV记事卡列表
                    RLV.LOAD.LIST
                    返回：
                    RLV.EXEC | RLV.LOAD.LIST | rlv1; rlv2; rlv3; ...
                    */
                    else if(headerExt=="LIST"){
                        // result=(string)list2RlvData(getRLVNotecards());
                        list rlvList=[];
                        integer count = llGetInventoryNumber(INVENTORY_NOTECARD);
                        integer i;
                        for (i=0; i<count; i++){
                            string notecardName = llGetInventoryName(INVENTORY_NOTECARD, i);
                            if(llGetSubString(notecardName, 0, 3)==rlvHeader){
                                rlvList+=[llGetSubString(notecardName, 4, -1)];
                            }
                        }
                        result=(string)list2Data(rlvList);
                    }
                }
                else if(headerSub=="GET"){
                    /*
                    获取RLV组中的RLV指令
                    RLV.GET | RLVName
                    返回：
                    RLV.EXEC | RLV.GET | RLVName; RLV1, RLV2, RLV3; RLVClass; RLVEnabled
                    */
                    if(headerExt==""){
                        result=list2Data(getRLVCmd(msgName, FALSE));
                    }
                    /*
                    获取锁定状态
                    RLV.GET.LOCK
                    返回：
                    RLV.EXEC | RLV.GET.LOCK | 1; UUID
                    */
                    else if(headerExt=="LOCK"){
                        result=list2Data([isLocked, lockUser]);
                    }
                    /*
                    获取捕获状态
                    RLV.GET.CAPTURE | UUID
                    */
                    else if(headerExt=="CAPTURE"){
                        // result=(string)isCaptureVictim((key)msgName);
                        if(VICTIM_UUID==NULL_KEY){
                            result=(string)FALSE;
                        }
                        if(VICTIM_UUID == (key)msgName && executeRLV("HAS:sit:"+(string)llGetKey()+"=force", FALSE)){
                            result=(string)TRUE;
                        }else{
                            result=(string)FALSE;
                        }
                    }
                    /*
                    获取已捕获玩家的UUID
                    RLV.GET.CAPTUREID
                    */
                    else if(headerExt=="CAPTUREID"){
                        // result=(string)getCaptureVictim();
                        if(VICTIM_UUID != NULL_KEY && executeRLV("HAS:sit:"+(string)llGetKey()+"=force", FALSE)){
                            result=(string)VICTIM_UUID;
                        }else{
                            result=(string)NULL_KEY;
                        }
                    }
                    /*
                    获取RLV状态（RLV指令或当前RLV限制）
                    RLV.GET.STATUS | @RLV1, @RLV2, @RLV3
                    RLV.GET.STATUS
                    返回：
                    RLV.EXEC | RLV.GET.STATUS | 1
                    RLV.EXEC | RLV.GET.STATUS | rlv1=n, rlv2=n
                    */
                    else if(headerExt=="STATUS"){
                        if(msgName==""){
                            result=list2RlvData(executeRLVList);
                        }else{
                            result=(string)executeRLV("HAS:"+msgName, FALSE);
                        }
                    }
                    /*
                    获取RLV锁与限制联动状态
                    RLV.GET.CONNECT
                    返回：
                    RLV.EXEC | RLV.GET.CONNECT | 1
                    */
                    else if(headerExt=="CONNECT"){
                        result=(string)lockRLVConnect;
                    }
                }
                else if(headerSub=="SET"){
                    /*
                    设置RLV锁与限制联动状态
                    RLV.SET.CONNECT | 1
                    */
                    if(headerExt=="CONNECT"){
                        lockRLVConnect=(integer)msgName;
                        result=(string)lockRLVConnect;
                    }
                }
                /*
                直接执行RLV指令（@开头的RLV指令，可以不加@，用逗号分隔多条指令，如@detach=n,fly=n,unsit=n）
                不带参数时，一键执行当前存在的所有限制（runRLV()）
                RLV.RUN.TEMP为临时执行RLV指令（不记录）
                RLV.RUN
                RLV.RUN | RLV1, RLV2, RLV3, ...
                RLV.RUN.TEMP | RLV1, RLV2, RLV3, ...
                */
                else if(headerSub=="RUN"){
                    if(headerExt==""){
                        if(msgName!=""){
                            result=(string)executeRLV(msgName, TRUE);
                        }else{
                            result=(string)executeRLV("ALL", FALSE);
                        }
                    }
                    else if(headerExt=="TEMP"){
                        if(msgName!=""){
                            result=(string)executeRLV(msgName, FALSE);
                        }
                    }
                }
                /*
                显示RLV菜单
                RLV.MENU | 上级菜单名
                无返回
                */
                else if(headerSub=="MENU"){
                    showRLVMenu(msgName, user);
                    // if(rlvClassCount<=1){
                    //     showRLVSubMenu(msgName, llList2String(rlvCmdList, 2), user);
                    // }else{
                    //     showRLVMenu(msgName, user);
                    // }
                }
                if(result!=""){
                    list rlvExeResult=[
                        "RLV.EXEC", msgHeader, result
                    ];
                    resultList+=[llDumpList2String(rlvExeResult, "|")];
                }
            }
            else if(llGetSubString(str, 0, 4) == "MENU." && includes(str, "ACTIVE")) {
                if(msgSub==rlvMenuText){
                    showRLVMenu(msgName, user);
                    // if(rlvClassCount<=1){
                    //     showRLVSubMenu(msgName, llList2String(rlvCmdList, 2), user);
                    // }else{
                    //     showRLVMenu(msgName, user);
                    // }
                }
                else if(msgName==rlvMenuName && msgSub!=""){ // MENU.ACTIVE | Class | Class1
                    showRLVSubMenu(rlvMenuName, msgSub, user);
                }
                else if(msgName==rlvSubMenuName && msgSub!=""){ // MENU.ACTIVE | Class1 | [1]RLV1
                    integer applyResult;
                    if(msgSub=="[ALL]"){
                        integer i;
                        integer allEnabled=FALSE;
                        for(i=0; i<llGetListLength(rlvCmdList); i+=rlvCmdLength){ // 第一次循环，确定开关状态。只要有一个开着，那就是开，否则就是关。主要是解决互斥锁导致的ALL只能开不能关的bug
                            if(llList2String(rlvCmdList, i+2) == curRlvSubMenu){
                                if(allEnabled==FALSE){
                                    allEnabled=llList2Integer(rlvCmdList, i+3);
                                }
                            }
                        }
                        for(i=0; i<llGetListLength(rlvCmdList); i+=rlvCmdLength){ // 第二次循环，执行全部开关限制
                            if(llList2String(rlvCmdList, i+2) == curRlvSubMenu){
                                applyResult=applyRLVCmd(llList2String(rlvCmdList, i), !allEnabled);
                            }
                        }
                    }else{
                        applyResult=applyRLVCmd(msgSub, -1);
                    }
                    string onOff="OFF";
                    if(applyResult>=1){
                        onOff="ON";
                    }
                    resultList+=[applyResult];
                    llMessageLinked(LINK_SET, MENU_MSG_NUM, "MENU.OUT|Your %1% - %2% restrictions is set to %3%.%%;"+curRlvSubMenu+";"+msgSub+";"+onOff, user);
                    showRLVSubMenu(rlvParentMenuName, curRlvSubMenu, user);
                }
            }
        }
        if(llGetListLength(resultList)>0){
            llMessageLinked(LINK_SET, RLV_MSG_NUM, llDumpList2String(resultList, "&&"), user); // RLV处理完成后的回调
        }
        // llSleep(0.01);
        // llOwnerSay("RLV Memory Used: "+(string)llGetUsedMemory()+"/"+(string)(65536-llGetUsedMemory())+" Free: "+(string)llGetFreeMemory());
    }

    dataserver(key query_id, string data){
        if (query_id == readRLVQuery) { // 通过readRLVNotecards触发读取记事卡事件，按行读取指定RLV（readRLVQuery）并设置相关数据。
            if (data == EOF) {
                llOwnerSay("Finished reading RLV restraints: "+curRLVName);
                llMessageLinked(LINK_SET, RLV_MSG_NUM, "RLV.LOAD.NOTECARD|"+curRLVName+"|1", NULL_KEY); // RLV成功读取记事卡后回调
                readRLVQuery=NULL_KEY;
                if(llGetAttached()){
                    applyAllRLVCmd();
                }
            } else {
                /*
                [RLVClass1]
                RLVName1=rlv1,rlv2,rlv3,...
                RLVName2=rlv1,rlv2,rlv3,...
                [RLVClass2]
                RLVName3=rlv1,rlv2,rlv3,...
                RLVName4=rlv1,rlv2,rlv3,...
                */
                if(data!="" && llGetSubString(data,0,0)!="#"){
                    if(llGetSubString(data,0,0)=="[" && llGetSubString(data,-1,-1)=="]"){
                        curRLVClass=llGetSubString(data,1,-2);
                    }else{
                        list rlvStrSp=llParseStringKeepNulls(data, ["="], []);
                        string rlvName=llList2String(rlvStrSp,0);
                        integer rlvDefaultEnabled=FALSE;
                        if(llGetSubString(rlvName, 0, 0)=="*"){
                            rlvDefaultEnabled=TRUE;
                            rlvName=llGetSubString(rlvName, 1, -1);
                        }
                        string rlvData=llList2String(rlvStrSp,1);

                        setRLVCmd(rlvName, rlvData, curRLVClass, rlvDefaultEnabled);
                    }
                }

                // increment line count
                ++readRLVLine;
                //request next line of notecard.
                readRLVQuery=llGetNotecardLine(readRLVName, readRLVLine);
            }
        }
    }
}
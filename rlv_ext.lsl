/*
Name: RLV Ext
Author: JMRY
Description: A better RLV Extension management system, use link_message to operate RLV Extension restraints.

***更新记录***
- 1.0.1 20260114
    - 调整echo视觉指令名为echoview。
    - 优化RLV扩展执行算法，提升性能。

- 1.0 20260113
    - 拆分RLV扩展指令。
    - 加入echo视觉功能（ping一次，限时观察一定范围）。
***更新记录***
*/

/*
TODO:
- 移速控制
- 重力控制
- 限制移动范围
- 角色隐形
- 角色附身
*/

/*
基础功能依赖函数
*/
/*
根据用户UUID获取用户信息URL。
返回：带链接的 显示名称(用户名)
*/
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

// string dataSplit=",";
list data2List(string d){
    return strSplit(d, ",");
}
string list2Data(list d){
    return strJoin(d, ",");
}

// string mdataSplit=";";
list menuData2List(string d){
    return strSplit(d, ";");
}
string list2MenuData(list d){
    return strJoin(d, ";");
}

integer RLVRS=-1812221819; // default relay channel
executeRLVTemp(list rlvList, integer bool){
    string rlvStr=list2Data(rlvList);
    rlvStr=replace(replace(replace(rlvStr,"=n","=y"),"=add","=rem"),"=force","=rem");
    llOwnerSay("@"+rlvStr);
    // llMessageLinked(LINK_SET, RLV_MSG_NUM, "RLV.RUN.TEMP|"+list2Data(rlvList), NULL_KEY);
}

/*
RLV扩展指令，参数：@rext_开头的RLV指令
*/
string RLVExtHeader="rext_";
list RLVExtList=[
    "move",
    "turn",
    "echoview"
];
/*
RLV扩展指令执行接口
*/
integer executeRLVExt(string rname, string rval, string rparams){
    integer isAllow;
    if(rval=="n" || rval=="rem"){
        isAllow=FALSE;
    }else{
        isAllow=TRUE;
    }
    if(rname==llList2String(RLVExtList, 0) || rname==llList2String(RLVExtList, 1)){ // move or turn
        return setMoveTurn(isAllow, rname);
    }
    else if(rname==llList2String(RLVExtList, 2)){ // echo
        return setEchoView(isAllow, rparams);
    }
    return isAllow;
}

list takeControlList=[];
integer setMoveTurn(integer isAllow, string rname){
    llRequestPermissions(llGetOwner(), PERMISSION_TAKE_CONTROLS);
    // 将传入的指令写入takeControlList
    integer tindex=llListFindList(takeControlList, [rname]);
    if(isAllow==FALSE){
        if(!~tindex){
            takeControlList+=[rname];
        }
    }else{
        if(~tindex){
            takeControlList=llDeleteSubList(takeControlList,tindex,tindex);
        }
    }
    // 遍历takeControlList获取开关状态并按位OR
    integer controlVal=0;
    integer i;
    for(i=0; i<llGetListLength(takeControlList); i++){
        if(llList2String(takeControlList, i) == llList2String(RLVExtList, 0)){ // move
            controlVal=controlVal | CONTROL_FWD | CONTROL_BACK | CONTROL_LEFT | CONTROL_RIGHT | CONTROL_UP | CONTROL_DOWN | CONTROL_LBUTTON | CONTROL_ML_LBUTTON;
        }
        if(llList2String(takeControlList, i) == llList2String(RLVExtList, 1)){ // turn
            controlVal=controlVal | CONTROL_ROT_LEFT | CONTROL_ROT_RIGHT;
        }
    }
    if(controlVal==0){
        // controlVal==0说明没有任何控制，释放之
        // 使用llReleaseControls()会撤销PERMISSION_TAKE_CONTROLS，因此在撤销后要重新申请一次。
        // controlVal=CONTROL_FWD | CONTROL_BACK | CONTROL_LEFT | CONTROL_RIGHT | CONTROL_UP | CONTROL_DOWN | CONTROL_ROT_LEFT | CONTROL_ROT_RIGHT | CONTROL_LBUTTON | CONTROL_ML_LBUTTON;
        // llTakeControls(controlVal,TRUE,TRUE);
        llReleaseControls();
        llRequestPermissions(llGetOwner(), PERMISSION_TAKE_CONTROLS);
    }else{
        llTakeControls(controlVal,TRUE,FALSE);
    }
    return isAllow;
}

list echoViewRLV=[ // different echo RLVs
    "camdrawmin:5=y",
    "camdrawmax:15=y",
    "camdrawalphamin:5=y",
    "camdrawalphamax:5=y",
    "camdrawmin:1=y",
    "camdrawmax:5=y",
    "camdrawalphamin:1=y",
    "camdrawmin:10=y",
    "camdrawmax:25=y",
    "camdrawalphamin:10=y",
    "camdrawalphamax:25=y",
    "setsphere=n",
    "setsphere_valuemin:0=force",
    "setsphere_valuemax:1=force",
    "setsphere_tween:1=force"
];
list echoViewRLV_normal=[];
list echoViewRLV_echo=[];
string echoPing="echo";
float echoKeepTime=5;
integer echoTimerFlag=FALSE;
integer echoViewListenHandle;
integer setEchoView(integer isAllow, string params){
    llListenRemove(echoViewListenHandle);
    executeRLVTemp(echoViewRLV+echoViewRLV_normal+echoViewRLV_echo, FALSE);
    // llMessageLinked(LINK_SET, RLV_MSG_NUM, "RLV.RUN", NULL_KEY);
    if(isAllow){
        return isAllow;
    }
    llOwnerSay((string)isAllow);
    float echoDistMinNormal=1.4;
    float echoDistMaxNormal=2;
    float echoDistAlphaNormal=1;
    float echoDistMin=10.5;
    float echoDistMax=15;
    float echoDistAlpha=5;
    float echoTween=5;
    if(params!=""){
        list paramsList=menuData2List(params); // echo:ping;5;1.4;2;10.5;15;5=n
        if(llList2String(paramsList, 0)!=""){
            echoPing=llList2String(paramsList, 0);
        }
        if(llList2String(paramsList, 1)!=""){
            echoKeepTime=llList2Float(paramsList, 1);
        }
        if(llList2String(paramsList, 2)!=""){
            echoDistMinNormal=llList2Float(paramsList, 2);
        }
        if(llList2String(paramsList, 3)!=""){
            echoDistMaxNormal=llList2Float(paramsList, 3);
        }
        if(llList2String(paramsList, 4)!=""){
            echoDistMin=llList2Float(paramsList, 4);
        }
        if(llList2String(paramsList, 5)!=""){
            echoDistMax=llList2Float(paramsList, 5);
        }
        if(llList2String(paramsList, 6)!=""){
            echoTween=llList2Float(paramsList, 6);
        }
    }
    echoViewRLV_normal=[
        "camdrawalphamax:"+(string)echoDistAlphaNormal+"=y",
        "setsphere_distmin:"+(string)echoDistMinNormal+"=force",
        "setsphere_distmax:"+(string)echoDistMaxNormal+"=force"
    ];
    echoViewRLV_echo=[
        "camdrawalphamax:"+(string)echoDistAlpha+"=y",
        "setsphere_distmin:"+(string)echoDistMin+"=force",
        "setsphere_distmax:"+(string)echoDistMax+"=force",
        "setsphere_tween:"+(string)echoTween+"=force"
    ];
    executeRLVTemp(echoViewRLV+echoViewRLV_normal, TRUE);
    echoViewListenHandle=llListen(1, "", llGetOwner(), "");
    return isAllow;
}

integer MENU_MSG_NUM=1000;
integer RLV_MSG_NUM=1001;
integer RLVEXT_MSG_NUM=10012;
default{
    state_entry(){
        llRequestPermissions(llGetOwner(), PERMISSION_TAKE_CONTROLS);
    }
    changed(integer change){
        if(change & CHANGED_OWNER){
            llResetScript();
        }
    }
    attach(key user) {
        if(user!=NULL_KEY){
            llRequestPermissions(user, PERMISSION_TAKE_CONTROLS);
        }
    }
    on_rez(integer start_param){
        // 登录、穿戴时也会触发on_rez，并且比attach更早触发。有时候登录时不触发attach，因此将attach的部分也添加到这里。
        integer attached=llGetAttached();
        if(attached>0){
            llRequestPermissions(llGetOwner(), PERMISSION_TAKE_CONTROLS);
        }
    }

    control(key id, integer level, integer edge){
    }

    listen(integer channel, string name, key user, string message){
        if(channel==1 && message==echoPing){
            executeRLVTemp(echoViewRLV+echoViewRLV_echo, TRUE);
            echoTimerFlag=TRUE;
            llSetTimerEvent(echoKeepTime);
        }
    }

    timer(){
        if(echoTimerFlag==TRUE){
            executeRLVTemp(echoViewRLV+echoViewRLV_normal, TRUE);
            echoTimerFlag=FALSE;
        }
    }
    link_message(integer sender_num, integer num, string msg, key user){
        if(num!=RLVEXT_MSG_NUM && num!=RLV_MSG_NUM && num!=MENU_MSG_NUM){
            return;
        }
        list msgList=bundle2List(msg);
        list resultList=[];
        integer msgCount=llGetListLength(msgList);
        integer mi;
        for(mi=0; mi<msgCount; mi++){
            string str=llList2String(msgList, mi);
            if (llGetSubString(str, 0, 6) == "RLVEXT." && !includes(str, "EXEC")) {
                list rlvMsgList=msg2List(str);
                string rlvMsgStr=llList2String(rlvMsgList, 0);
                list rlvMsgGroup=llParseStringKeepNulls(rlvMsgStr, ["."], [""]);

                string rlvMsg=llList2String(rlvMsgGroup, 0);
                string rlvMsgSub=llList2String(rlvMsgGroup, 1);
                string rlvMsgExt=llList2String(rlvMsgGroup, 2);
                string rlvMsgExt2=llList2String(rlvMsgGroup, 3);

                string rlvMsgName=llList2String(rlvMsgList, 1);
                string rlvMsgCmd=llList2String(rlvMsgList, 2);
                string rlvMsgClass=llList2String(rlvMsgList, 3);
                string rlvMsgClass2=llList2String(rlvMsgList, 4);

                string result="";
                if(rlvMsgSub=="RUN"){
                    if(rlvMsgName=="clear"){
                        integer i;
                        for(i=0; i<llGetListLength(RLVExtList); i++){
                            result=(string)executeRLVExt(llList2String(RLVExtList, i), "y", "");
                        }
                    }else{
                        list rsp=llParseStringKeepNulls(rlvMsgName,["="],[""]);
                        string rkey=llList2String(rsp, 0);
                        string rval=llList2String(rsp, 1);
                        string rname=llList2String(llParseStringKeepNulls(rkey,["_"],[""]), 1);
                        string rparams=llList2String(llParseStringKeepNulls(rname, [":"], [""]), 1); // @rext_cmd:args=n => cmd:args, n => cmd, args, n
                        rname=llList2String(llParseStringKeepNulls(rname, [":"], []), 0);
                        integer rindex=llListFindList(RLVExtList,[rname]);
                        if(~rindex){
                            result=(string)executeRLVExt(rname,rval,rparams);
                        }
                    }
                }
                if(result!=""){
                    list rlvExeResult=[
                        "RLVEXT.EXEC", rlvMsgStr, result
                    ];
                    resultList+=[list2Msg(rlvExeResult)];
                }
            }
        }
        if(llGetListLength(resultList)>0){
            llMessageLinked(LINK_SET, RLV_MSG_NUM, list2Bundle(resultList), user); // RLV处理完成后的回调
        }
        // llOwnerSay("RLV Ext Memory Used: "+(string)llGetUsedMemory()+" Free: "+(string)llGetFreeMemory());
    }
}
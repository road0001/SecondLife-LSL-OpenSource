/*
Name: Renamer
Author: JMRY
Description: A better RLV Renamer management system, use link_message to operate Renamer restraints.

***更新记录***
- 1.0.1 20251203
    - 加入说话时触发音效功能和菜单。

- 1.0 20241226
    - 从RLV迁移Renamer功能。
***更新记录***
*/

/*
TODO:
- 混淆模式
- Renamer触发声音
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

// string mdataSplit=";";
list data2List(string d){
    return strSplit(d, ";");
}
list rlvData2List(string d){
    return strSplit(d, ",");
}
string list2Data(list d){
    return strJoin(d, ";");
}
string list2RLVData(list d){
    return strJoin(d, ",");
}

/*
设置RLV，参数：RLV指令，RLV值
*/
integer RLVRS=-1812221819; // default relay channel
integer RLV_MODE=0; // 0： wear mode；1：rez mode say；2：rez mode whisper；3：rez mode shout；else：rez mode regionSayTo
integer rlvWorldListenHandle;
key VICTIM_UUID=NULL_KEY;

integer executeRLV(string rlv){
    llListenRemove(rlvWorldListenHandle);
    if(RLV_MODE==0){
        llOwnerSay(rlv);
    }else{
        string rlvCmdName="RENAMER_EXECUTE_" + llGetObjectName();
        list rlvExecList =[rlvCmdName, VICTIM_UUID, replace(rlv,",","|")];
        string rlvExecStr=list2RLVData(rlvExecList);
        llOwnerSay(rlvExecStr);
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
    return RLV_MODE;
}

list rlvListKeyVal=[];
// list rlvListKey=[];
// list rlvListVal=[];
integer rlvChannel;
integer rlvListenHandle;
integer setRLV(string k, string v){
    if(k=="clear" && v==""){
        rlvListKeyVal=[];
        executeRLV("@clear");
        return TRUE;
    }
    rlvChannel=(integer)v;
    integer kIndex=llListFindList(rlvListKeyVal, [k]);
    if(!~kIndex && (v!="y" || v!="rem") && rlvChannel==0){ // ~var表示该变量!=-1，此处判断代表此key不存在，向后插入
        rlvListKeyVal+=[k,v];
    }else if(v=="y" || v=="rem" || rlvChannel!=0){ // v表示RLV生效状态，为y或rem时表示解除，因此从list中删除
        rlvListKeyVal=llDeleteSubList(rlvListKeyVal, kIndex, kIndex+1);
    }else{ // >=0代表此key存在，则不修改key，直接替换val值
        rlvListKeyVal=llListReplaceList(rlvListKeyVal,[v],kIndex+1,kIndex+1);
    }
    if(llGetSubString(k,0,0)!="_"){ // 以_开头的key作为标识符，不执行，例如：_LightBlind
        executeRLV("@"+k+"="+v);
    }
    llListenRemove(rlvListenHandle);
    llSetTimerEvent(0);
    if(v!="0"){
        rlvListenHandle=llListen(rlvChannel, "", currentUser, "");
    }
    llSetTimerEvent(60);
    return TRUE;
}

/*
执行RLV限制。在重新登录、穿戴时触发。按照每10条执行一次的方式执行。
*/
integer runRLV(){
    if(llGetListLength(rlvListKeyVal)<=0){
        return FALSE;
    }
    list rlvList=[];
    integer i=0;
    integer j=0;
    integer count=llGetListLength(rlvListKeyVal);
    for(i=0; i<count; i+=2){
        string rkey=llList2String(rlvListKeyVal,i);
        string rval=llList2String(rlvListKeyVal,i+1);
        string rlv=rkey+"="+rval;
        if(llStringLength(rlv)>36){ // rlv指令超过36个字母时，防止超长，直接输出，跳过队列；RLV扩展指令跳过队列直接执行
            executeRLV("@"+rlv);
        }else{
            rlvList+=[rlv];
            j++;
        }
        if(j%10==0 || i==count-2){ // j仅在插入list时+1。每记录10条，输出一次并清空list。最后一次循环将剩余部分全部输出。
            // 每10条或i等于总长-1时，输出rlv信息，并清空list
            executeRLV("@"+llDumpList2String(rlvList,","));
            rlvList=[];
        }
    }
    return TRUE;
}

integer isLocked=FALSE;
key lockUser=NULL_KEY;
integer lockRLVConnect=TRUE;
integer curRenamerBool;
integer setLock(integer bool, key user){
    if(bool==-1){
        if(isLocked==FALSE){
            bool=TRUE;
        }else{
            bool=FALSE;
        }
    }
    if(bool==0){
        lockUser=NULL_KEY;
        if(lockRLVConnect==TRUE){ // 锁和Renamer联动时，解锁清空所有限制，但保留Renamer状态
            curRenamerBool=renamerBool;
            renamerEnabled(FALSE, NULL_KEY);
        }
    }else{
        lockUser=user;
        if(lockRLVConnect==TRUE){ // 锁和RLV联动时，锁定即应用之前的Renamer
            renamerEnabled(curRenamerBool, lockUser);
        }
    }
    isLocked=bool;
    return bool;
}

/*
Renamer功能
*/
integer renamerChannel;
integer renamerListenHandle;
integer renamerBool;
integer renamerEnabled(integer bool, key user){
    if(bool==-1){
        if(renamerBool==FALSE){
            bool=TRUE;
        }else{
            bool=FALSE;
        }
    }
    if(bool==TRUE){
        renamerListenHandle=llListen(renamerChannel, "", NULL_KEY, "");
        setRLV("redirchat:"+(string)renamerChannel,"add");
        setRLV("rediremote:"+(string)renamerChannel,"add");
        setRLV("emote","add");
    }else{
        setRLV("redirchat:"+(string)renamerChannel,"rem");
        setRLV("rediremote:"+(string)renamerChannel,"rem");
        setRLV("emote","rem");
        llListenRemove(renamerListenHandle);
    }
    renamerBool=bool;
    return bool;
}

string RENAMER_DISPLAY_NAME="RENAMER_DISPLAY_NAME";
string RENAMER_FULL_NAME="RENAMER_FULL_NAME";
string RENAMER_USER_NAME="RENAMER_USER_NAME";
string RENAMER_OBJECT_NAME="RENAMER_OBJECT_NAME";

string objectName=":";
string renamerName="";
string renamerConfusion=""; // TODO: 重命名器混淆功能，待开发
string renamerVoice=""; // TODO: 重命名器声音功能，待开发
float renamerVolume=1.0;
integer renamerSay(string name, string msg, integer type) {
    if(renamerVoice!=""){
        list voiceList=rlvData2List(renamerVoice);
        integer rand = (integer)llFrand(llGetListLength(voiceList));
        llTriggerSound(llList2String(voiceList, rand), renamerVolume); // 使用TriggerSound兼容hud时的音效可在世界播放。缺点：无法跟踪人物实时定位
    }

    string oname = llGetObjectName();
    if(name==RENAMER_DISPLAY_NAME){
        if(VICTIM_UUID!=NULL_KEY){
            name=llGetDisplayName(VICTIM_UUID);
        }else{
            name=llGetDisplayName(llGetOwner());
        }
    }
    if(name==RENAMER_FULL_NAME){
        if(VICTIM_UUID!=NULL_KEY){
            name=userInfo(VICTIM_UUID);
        }else{
            name=userInfo(llGetOwner());
        }
    }
    else if(name==RENAMER_USER_NAME){
        if(VICTIM_UUID!=NULL_KEY){
            name=llKey2Name(VICTIM_UUID);
        }else{
            name=llKey2Name(llGetOwner());
        }
    }
    else if(name==RENAMER_OBJECT_NAME){
        name=oname;
    }
    
    llSetObjectName(objectName); // llSetObjectName不支持中文，因此将remaer名字拼接到字符串中来显示。
    string renamerMsg;
    if(llGetSubString(msg, 0, 2) == "/me"){
        renamerMsg="/me "+name+" "+llStringTrim(llGetSubString(msg,3,-1), STRING_TRIM);
    }else{
        renamerMsg=name+": "+msg;
    }
    
    if(type==0){
        llSay(0,renamerMsg);
    }else if(type==1){
        llWhisper(0,renamerMsg);
    }else{
        llShout(0,renamerMsg);
    }
    llSetObjectName(oname);
    return TRUE;
}

/*
RLV菜单控制
*/
string renamerMenuText="Renamer";
string renamerMenuName="RLVRenamerMenu";
string curRenamerSubMenu="";
showRenamerMenu(string parent, key user){
    curRenamerSubMenu=parent;
    list renamerMenuList=[
        "MENU.REG.OPEN",
        renamerMenuName,
        "This is Renamer menu.\nCurrent name: %1%%%;"+renamerName,
        list2Data([
            "["+(string)renamerBool+"]Enabled",
            "SetName",
            renamerVoiceMenuText
        ]),
        parent
    ];
    llMessageLinked(LINK_SET, MENU_MSG_NUM, list2Msg(renamerMenuList), user);
}

string renamerVoiceMenuText="Voice";
string renamerVoiceMenuName="RLVRenamerVoiceMenu";
showRenamerVoiceMenu(string parent, key user){
    curRenamerSubMenu=parent;

    list invVoiceList=[];
    integer count = llGetInventoryNumber(INVENTORY_SOUND);
    integer i;
    for (i=0; i<count; i++){
        invVoiceList+=[llGetInventoryName(INVENTORY_SOUND, i)];
    }

    string mText="This is Renamer voice menu.\nCurrent voice: %1%, volume: %2%.%%;";
    if(renamerVoice==""){ // None
        mText+="None"+";"+(string)renamerVolume;
    }else if(includes(renamerVoice, ",")){ // multiple voices using , separate
        mText+="Multiple random"+";"+(string)renamerVolume;
    }else if(llStringLength((key)renamerVoice)>=36){ // uuid and too long voice
        mText+="Too long"+";"+(string)renamerVolume;
    }else{
        mText+=renamerVoice+";"+(string)renamerVolume;
    }

    list renamerVoiceMenuList=[
        "MENU.REG.OPEN",
        renamerVoiceMenuName,
        mText,
        list2Data([
            "None",
            "Volume",
            "Input"
        ]+invVoiceList),
        parent
    ];
    llMessageLinked(LINK_SET, MENU_MSG_NUM, list2Msg(renamerVoiceMenuList), user);
}

float switchRenamerVolume(){
    renamerVolume+=0.1;
    if(renamerVolume>=1.1){
        renamerVolume=0;
    }
    return renamerVolume;
}

integer MENU_MSG_NUM=1000;
integer RLV_MSG_NUM=1001;
integer RENAMER_MSG_NUM=10011;
key currentUser=NULL_KEY;
default{
    state_entry(){
        renamerChannel=(integer)(99999999 - llFrand(10000000));
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
            }else{
                VICTIM_UUID=NULL_KEY;
            }
        }
    }

    control(key id, integer level, integer edge){

    }

    listen(integer channel, string name, key user, string message){
        if(channel==rlvChannel){ // 监听RLV返回数据并发送消息
            list msgList=["RENAMER.EXEC","CALLBACK",message];
            llMessageLinked(LINK_SET, RENAMER_MSG_NUM, list2Msg(msgList), user);
            llListenRemove(rlvListenHandle);
            llSetTimerEvent(0);
        }
        if(channel==renamerChannel){
            renamerSay(renamerName, message, FALSE);
        }
    }

    timer(){ // 超时关闭RLV监听并重置
        llListenRemove(rlvListenHandle);
        llSetTimerEvent(0);
    }

    attach(key user) {
        RLV_MODE=0;
        if(user!=NULL_KEY){
            runRLV();
        }else{
            executeRLV("@clear"); // 脱下时，仅清除RLV状态，不清空列表，下次穿戴时重新应用
        }
    }
    on_rez(integer start_param){
        // 登录、穿戴时也会触发on_rez，并且比attach更早触发。有时候登录时不触发attach，因此将attach的部分也添加到这里。
        integer attached=llGetAttached();
        if(attached>0){
            RLV_MODE=0;
            runRLV();
        }else{
            RLV_MODE=1;
        }
    }
    object_rez(key user){
        RLV_MODE=1;
    }
    link_message(integer sender_num, integer num, string msg, key user){
        if(num!=RENAMER_MSG_NUM && num!=RLV_MSG_NUM && num!=MENU_MSG_NUM){
            return;
        }

        currentUser=user;
        list msgList=bundle2List(msg);
        list resultList=[];
        integer msgCount=llGetListLength(msgList);
        integer mi;
        for(mi=0; mi<msgCount; mi++){
            string str=llList2String(msgList, mi);
            if (llGetSubString(str, 0, 8) == "RENAMER." && !includes(str, "EXEC")) {
                list renamerMsgList=msg2List(str);
                string renamerMsgStr=llList2String(renamerMsgList, 0);
                list renamerMsgGroup=llParseStringKeepNulls(renamerMsgStr, ["."], [""]);

                string renamerMsg=llList2String(renamerMsgGroup, 0);
                string renamerMsgSub=llList2String(renamerMsgGroup, 1);
                string renamerMsgExt=llList2String(renamerMsgGroup, 2);

                string renamerMsgData=llList2String(renamerMsgList, 1);
                list renamerMsgDataList=data2List(renamerMsgData);
                
                string renamerMsgEnabled=llList2String(renamerMsgDataList, 2);
                string renamerMsgName=llList2String(renamerMsgDataList, 2);
                string renamerMsgConfusion=llList2String(renamerMsgDataList, 3);
                string renamerMsgVoice=llList2String(renamerMsgDataList, 4);

                string result="";
                if(renamerMsgSub=="SET"){
                    /*
                    重命名器
                    RENAMER.SET | 1 | Name | Confusion | Voice
                    RENAMER.SET | 0
                    返回：
                    RENAMER.EXEC | RENAMER.SET | 1; channel; name; confusion; voice // 1=启用，0=关闭
                    */
                    if(renamerMsgExt==""){
                        if(renamerMsgEnabled!=""){
                            renamerEnabled((integer)renamerMsgData,user);
                        }
                        if(renamerMsgName!=""){
                            renamerName=renamerMsgName;
                        }
                        if(renamerMsgConfusion!=""){
                            renamerConfusion=renamerMsgConfusion;
                        }
                        if(renamerMsgVoice!=""){
                            renamerVoice=renamerMsgVoice;
                        }
                        result=list2Data([renamerBool, renamerChannel, renamerName, renamerConfusion, renamerVoice]);
                    }
                    /*
                    重命名器与RLV锁联动
                    RENAMER.SET.CONNECT | 1
                    RENAMER.SET.CONNECT | 0
                    返回：
                    RENAMER.EXEC | RENAMER.SET.CONNECT | 1
                    */
                    else if(renamerMsgExt=="CONNECT"){
                        lockRLVConnect=(integer)renamerMsgData;
                        result=(string)lockRLVConnect;
                    }
                }
                else if(renamerMsgSub=="GET"){
                    /*
                    获取重命名器状态
                    RENAMER.GET
                    返回：
                    RENAMER.EXEC | RENAMER.GET | 1; Name; channel; 1
                    */
                    if(renamerMsgExt==""){
                        result=list2Data([renamerBool, renamerChannel, renamerName, renamerConfusion, renamerVoice]);
                    }
                    /*
                    获取重命名器与RLV锁联动状态
                    RENAMER.GET.CONNECT
                    返回：
                    RENAMER.EXEC | RENAMER.GET.CONNECT | 1
                    */
                    else if(renamerMsgExt=="CONNECT"){
                        result=(string)lockRLVConnect;
                    }
                }
                else if(renamerMsgSub=="RUN"){
                    /*
                    执行全部Renamer限制
                    RENAMER.RUN
                    返回：
                    RENAMER.EXEC | RENAMER.RUN | 1
                    */
                    result=(string)runRLV();
                }
                else if(renamerMsgSub=="MENU"){
                    /*
                    显示Renamer菜单
                    RENAMER.MENU | 上级菜单名
                    */
                    showRenamerMenu(renamerMsgData, user);
                }
                if(result!=""){
                    list renamerExeResult=[
                        "RENAMER.EXEC", renamerMsgStr, result
                    ];
                    resultList+=[list2Msg(renamerExeResult)];
                }
            }
            else if (llGetSubString(str, 0, 3) == "RLV." && includes(str, "EXEC")) {
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

                if(rlvMsgName=="RLV.LOCK"){
                    /*
                    从RLV回调接收RLV锁状态
                    RLV.EXEC | RLV.LOCK | 1
                    */
                    setLock((integer)rlvMsgCmd, user);
                }
            }
            else if(llGetSubString(str, 0, 4) == "MENU." && includes(str, "ACTIVE")) {
                list menuCmdList=msg2List(str);
                string menuCmdStr=llList2String(menuCmdList, 0);
                list menuCmdGroup=llParseStringKeepNulls(menuCmdStr, ["."], [""]);
    
                string menuCmd=llList2String(menuCmdGroup, 0);
                string menuCmdSub=llList2String(menuCmdGroup, 1);
    
                string menuName=llList2String(menuCmdList, 1);
                string menuButton=llList2String(menuCmdList, 2);

                if(menuButton==renamerMenuText){
                    /*
                    菜单按钮激活
                    MENU.ACTIVE | 菜单名 | Renamer
                    */
                    showRenamerMenu(menuName, user);
                }
                
                if(menuName==renamerMenuName && menuButton!=""){ // MENU.ACTIVE | RLVRenamerMenu | Button1
                    if(menuButton=="Enabled"){
                        renamerEnabled(-1,user);
                        showRenamerMenu(curRenamerSubMenu, user);
                    }
                    else if(menuButton=="SetName"){
                        llMessageLinked(LINK_SET, MENU_MSG_NUM, "MENU.INPUT|RenamerInput|Input Renamer name:", user);
                        // 后续交由RenamerInput处理
                    }
                    else if(menuButton=="Confusion"){
                        // TODO: Confusion Menu
                    }
                    else if(menuButton==renamerVoiceMenuText){
                        showRenamerVoiceMenu(renamerMenuName, user);
                    }
                }
                else if(menuName==renamerVoiceMenuName && menuButton!=""){
                    if(menuButton=="None"){ // 无声
                        renamerVoice="";
                    }
                    else if(menuButton=="Volume"){ // 音量（切换）
                        switchRenamerVolume();
                    }
                    else if(menuButton=="Input"){ // 输入文件名或uuid
                        llMessageLinked(LINK_SET, MENU_MSG_NUM, "MENU.INPUT|RenamerVoiceInput|Input voice name or uuid, multiple voices using [,] to separate:", user);
                        // 后续交由RenamerVoiceInput处理
                        return;
                    }else{ // 选择检测到的声音文件（不能超过20个字符）
                        renamerVoice=menuButton;
                    }
                    showRenamerVoiceMenu(curRenamerSubMenu, user);
                }
                else if(menuName=="RenamerInput"){ // MENU.ACTIVE | RenamerInput | Renamer
                    if(menuButton!=""){
                        renamerName=menuButton;
                    }else{
                        // 留空时不改名
                        // renamerName=RENAMER_DISPLAY_NAME; // 设置空名字时，默认为玩家的显示名
                    }
                    showRenamerMenu(curRenamerSubMenu, user);
                }
                else if(menuName=="RenamerVoiceInput"){ // MENU.ACTIVE | RenamerVoiceInput | Name
                    if(menuButton!=""){
                        renamerVoice=menuButton;
                    }else{
                        // 留空时不改名
                    }
                    showRenamerVoiceMenu(curRenamerSubMenu, user);
                }
            }
        }
        if(llGetListLength(resultList)>0){
            llMessageLinked(LINK_SET, RENAMER_MSG_NUM, list2Bundle(resultList), user); // RLV处理完成后的回调
        }
        // llOwnerSay("Renamer Memory Used: "+(string)llGetUsedMemory()+" Free: "+(string)llGetFreeMemory());
    }
}
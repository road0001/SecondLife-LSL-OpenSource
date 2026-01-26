/*
Name: Timer
Author: JMRY
Description: A better timer control system, use link_message to operate timers.

***更新记录***
- 1.0.4 20260127
    - 修复初始化时显示错误计时的bug。

- 1.0.3 20260119
    - 修复语言系统回调判定错误的bug。

- 1.0.2 2260114
	- 优化计时器状态通知格式。
	- 修复计时器启动时显示负数时间的bug。

- 1.0.1 20260106
    - 优化TIMER.GET返回的内容。
    - 优化性能和修复bugs。

- 1.0 20260106
    - 初步完成计时器功能。
***更新记录***
*/

/*
TODO:
*/

/*
基础功能依赖函数
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

integer str2Num(string d){
    return (integer)replace(d,"+","");
}

string formatTime(integer seconds){
    string totalStr="";
    string timeStr="";
        integer days = seconds / 86400;
        seconds = seconds % 86400;

        integer hours = seconds / 3600;
        seconds = seconds % 3600;

        integer minutes = seconds / 60;
        integer seconds = seconds % 60;

        timeStr=llGetSubString("00" + (string)hours, -2, -1) + ":" +llGetSubString("00" + (string)minutes, -2, -1) + ":" +llGetSubString("00" + (string)seconds, -2, -1);

        string daysStr="";
        if(days>0){
            daysStr=getLanguageVar("%1% days%%;"+(string)days);
        }

        totalStr=daysStr+timeStr;
    return totalStr;
}

string lanLinkHeader="LAN_";
integer hasLanguage=FALSE;

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

string getLanguageVar(string k){ // 拼接字符串方法，用于首尾拼接变量等内容。格式：Text text %1 %2.%%var1;var2
    list ksp=llParseStringKeepNulls(k, ["%%;"], [""]); // ["Text text %1 %2.", "var1;var2"]
    string text=getLanguage(trim(llList2String(ksp, 0)));
    list var=data2List(llList2String(ksp, 1)); // ["var1", "var2"]
    integer i;
    for(i=0; i<llGetListLength(var); i++){
        integer vi=i+1;
        text=replace(text, "%"+(string)vi+"%", getLanguage(llList2String(var, i)));
    }
    return text;
}

integer TIMER_TYPE_REAL=0;
integer TIMER_TYPE_ONLINE=1;
integer timerType=TIMER_TYPE_REAL; // 计时器类型：0=真实时间，1=在线时间
integer setTimerType(integer type){
    timerType=type;
    return timerType;
}

integer timerLength=0; // 计时时长（秒）
integer timerCurrent=0; // 当前计时状态
integer setTimer(integer second){
    timerCurrent=0; // 设置计时器会清空当前计时，增加时长不会
    timerStamp=0; // 设置计时器会清空当前时间戳
    timerLength=second;
    if(timerLength<0){
        timerLength=0;
    }
    return timerLength;
}

integer addTimer(integer second){
    timerLength+=second;
    if(timerLength<0){
        timerLength=0;
    }
    return timerLength;
}

integer timerRunning=FALSE;
string timerStatus="";
integer timerStamp=0;
integer setTimerRunning(integer bool){ // 0=Pause, 1=Running, 2=Reset and Running
    if(bool==-1){
        if(timerRunning==TRUE){
            bool=FALSE;
        }else{
            bool=TRUE;
        }
    }
    timerRunning=bool;
    if(timerRunning>=TRUE && timerStamp<=0){
        timerStamp=llGetUnixTime();
    }
    if(timerRunning==2){
        timerStamp=llGetUnixTime();
        timerCurrent=0;
        timerRunning=TRUE;
    }
    if(timerRunning==TRUE){
        timerStatus="RUNNING";
    }else{
        timerStatus="STOP";
    }
    llMessageLinked(LINK_SET, TIMER_MSG_NUM, "TIMER.SETRUNNING|"+(string)timerType+"|"+(string)timerRunning+"|"+(string)timerLength, NULL_KEY); // 发送状态变化消息
    return timerRunning;
}

/*
timer每秒执行一次，脚本启用时即一直执行
*/
integer timerTextBool=TRUE;
vector timerTextColor=<1.0, 0.0, 0.0>;
float timerTextAlpha=1.0;
timerRunningEvent(){
    if(timerRunning>=TRUE){
        if(timerType==TIMER_TYPE_REAL){ // 现实时间
            timerCurrent=llGetUnixTime() - timerStamp; // 当前时间-记录时间=计时
        }else if(timerType==TIMER_TYPE_ONLINE){ // 在线时间
            timerCurrent++;
        }
        if(timerTextBool==TRUE){
            llSetText(formatTime(timerLength - timerCurrent), timerTextColor, timerTextAlpha);
        }else{
            llSetText("",ZERO_VECTOR,0);
        }
        if(timerCurrent>=timerLength){
            llMessageLinked(LINK_SET, TIMER_MSG_NUM, "TIMER.TIMEOUT|"+(string)timerType+"|"+(string)timerCurrent+"|"+(string)timerLength, NULL_KEY); // 发送计时结束消息
            setTimerRunning(FALSE);
            timerStatus="TIMEOUT";
            timerCurrent=0;
            timerStamp=0;
        }else{
            llMessageLinked(LINK_SET, TIMER_MSG_NUM, "TIMER.RUNNING|"+(string)timerType+"|"+(string)timerCurrent+"|"+(string)timerLength, NULL_KEY); // 发送计时消息
            timerStatus="RUNNING";
        }
    }else{
        llSetText("",ZERO_VECTOR,0);
        if(timerType==TIMER_TYPE_REAL && timerStamp>0){
            timerStamp++; // Sync timestamp for pause
        }
    }
}

string timerMenuText="Timer";
string timerMenuName="TimerMenu";
string timerParentMenuName="";
showTimerMenu(string parent, key user){
    timerParentMenuName=parent;

    string tType="";
    if(timerType==TIMER_TYPE_REAL){
        tType="RealTime";
    }else if(timerType==TIMER_TYPE_ONLINE){
        tType="OnlineTime";
    }

    string tRunning="";
    if(timerRunning==FALSE){
        tRunning="Stopped";
    }else if(timerRunning>=TRUE){
        tRunning="Running";
    }

    string timerLengthStr=formatTime(timerLength);
    string timerCurrentStr=formatTime(timerCurrent);
    string timerRemainingStr=formatTime(timerLength - timerCurrent);

    list menuText=[
        "This is timer menu, you can manage timer.\nTimer mode: %1%\nTimer total: %2%\nTimer current: %3%\nTimer remaining: %4%\nTimer status: %5%%%",
        tType,
        timerLengthStr,
        timerCurrentStr,
        timerRemainingStr,
        tRunning
    ];

    list timerMenuList=[
        "["+(string)timerTextBool+"]ShowText", "BACK", "Clear",
        tType, "["+(string)timerRunning+"]Running", "Restart",
        "+5 Minute", "+30 Minute", "+1 Hour",
        "-5 Minute", "-30 Minute", "-1 Hour"
    ];

    llMessageLinked(LINK_SET, MENU_MSG_NUM, "MENU.CONFIRM|"+timerMenuName+"|"+list2Data(menuText)+"|"+list2Data(timerMenuList)+"|"+parent, user);
}

integer MENU_MSG_NUM=1000;
integer LAN_MSG_NUM=1003;
integer TIMER_MSG_NUM=1004;
default{
    state_entry(){
        llSetTimerEvent(1);
    }
    changed(integer change){
        if(change & CHANGED_OWNER){
            llResetScript();
        }
    }
    attach(key user){
        llSetTimerEvent(1);
    }
    object_rez(key user){
        llSetTimerEvent(1);
    }
    timer(){
        timerRunningEvent();
    }
    link_message(integer sender_num, integer num, string msg, key user){
        if(num!=TIMER_MSG_NUM && num!=MENU_MSG_NUM && num!=LAN_MSG_NUM){
            return;
        }

        list msgList=bundle2List(msg);
        list resultList=[];
        integer msgCount=llGetListLength(msgList);
        integer mi;
        for(mi=0; mi<msgCount; mi++){
            string str=llList2String(msgList, mi);
            if (llGetSubString(str, 0, 5) == "TIMER." && !includes(str, "EXEC")) {
                list timerMsgList=msg2List(str);
                string timerMsgStr=llList2String(timerMsgList, 0);
                list timerMsgGroup=llParseStringKeepNulls(timerMsgStr, ["."], [""]);

                string timerMsg=llList2String(timerMsgGroup, 0);
                string timerMsgSub=llList2String(timerMsgGroup, 1);
                string timerMsgExt=llList2String(timerMsgGroup, 2);
                string timerMsgExt2=llList2String(timerMsgGroup, 3);

                string timerMsgName=llList2String(timerMsgList, 1);
                string timerMsgCmd=llList2String(timerMsgList, 2);

                string result="";
                if(timerMsgSub=="ADD"){
                    /*
                    添加时长：TIMER.ADD | SECONDS
                    */
                    result=(string)addTimer((integer)timerMsgName);
                }
                else if(timerMsgSub=="SET"){
                    if(timerMsgExt=="TYPE"){
                        /*
                        设置计时器类型：TIMER.SET.TYPE | 0
                        类型：0=现实时间；1=在线时间
                        */
                        result=(string)setTimerType((integer)timerMsgName);
                    }
                    else if(timerMsgExt=="TEXT"){
                        if(timerMsgExt2=="SHOW"){
                            /*
                            设置计时器文字显示：TIMER.SET.TEXT.SHOW | BOOL
                            */
                            timerTextBool=(integer)timerMsgName;
                            result=(string)timerTextBool;
                        }
                        else if(timerMsgExt2=="COLOR"){
                            /*
                            设置计时器文字颜色：TIMER.SET.TEXT.COLOR | <R, G, B>
                            */
                            timerTextColor=(vector)timerMsgName;
                            result=(string)timerTextColor;
                        }
                        else if(timerMsgExt2=="ALPHA"){
                            /*
                            设置计时器文字透明度：TIMER.SET.TEXT.ALPHA | 1.0
                            */
                            timerTextAlpha=(float)timerMsgName;
                            result=(string)timerTextAlpha;
                        }
                    }
                    else{
                        /*
                        设置时长：TIMER.SET | SECONDS
                        */
                        result=(string)setTimer((integer)timerMsgName);
                    }
                }
                else if(timerMsgSub=="GET"){
                    if(timerMsgExt=="TYPE"){
                        /*
                        获取计时器类型：TIMER.GET.TYPE
                        返回：TIMER.EXEC | TIMER.GET.TYPE | 0
                        类型：0=现实时间；1=在线时间
                        */
                        result=(string)timerType;
                    }
                    else if(timerMsgExt=="TEXT"){
                        /*
                        获取计时器文字状态：TIMER.GET.TEXT
                        返回：TIMER.EXEC | TIMER.GET.TEXT | BOOL; COLOR; ALPHA
                        类型：0=现实时间；1=在线时间
                        */
                        result=list2Data([timerTextBool, timerTextColor, timerTextAlpha]);
                    }
                    else{
                        /*
                        获取计时器时长：TIMER.GET
                        返回：TIMER.EXEC | TIMER.GET | STATUS; TYPE; CURRENT; TOTAL
                        */
                        result=list2Data([timerStatus, timerType, timerCurrent, timerLength]);
                    }
                }
                else if(timerMsgSub=="PAUSE"){
                    /*
                    暂停计时器：TIMER.PAUSE
                    */
                    result=(string)setTimerRunning(0);
                }
                else if(timerMsgSub=="RUN"){
                    /*
                    恢复计时器：TIMER.RUN
                    */
                    result=(string)setTimerRunning(1);
                }
                else if(timerMsgSub=="RESTART"){
                    /*
                    重置并开始计时器：TIMER.RESTART
                    */
                    result=(string)setTimerRunning(2);
                }
                else if(timerMsgSub=="CLEAR"){
                    /*
                    重置计时器：TIMER.CLEAR
                    */
                    setTimer(0);
                    setTimerRunning(FALSE);
                    result="1";
                }
                else if(timerMsgSub=="MENU"){
                    /*
                    显示菜单
                    TIMER.MENU | 上级菜单名
                    */
                    showTimerMenu(timerMsgName, user);
                }

                if(result!=""){
                    list timerExeResult=[
                        "TIMER.EXEC", timerMsgStr, result
                    ];
                    resultList+=[list2Msg(timerExeResult)];
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

                if(menuButton==timerMenuText){
                    showTimerMenu(menuName, user);
                }
                else if(menuName==timerMenuName && menuButton!=""){
                    if(menuButton=="RealTime"){
                        timerType=TIMER_TYPE_ONLINE;
                    }
                    else if(menuButton=="OnlineTime"){
                        timerType=TIMER_TYPE_REAL;
                    }
                    else if(menuButton=="Running"){
                        setTimerRunning(-1);
                    }
                    else if(menuButton=="Restart"){
                        setTimerRunning(2);
                    }
                    else if(menuButton=="ShowText"){
                        if(timerTextBool==TRUE){
                            timerTextBool=FALSE;
                        }else{
                            timerTextBool=TRUE;
                        }
                    }
                    else if(menuButton=="Clear"){
                        setTimer(0);
                        setTimerRunning(FALSE);
                    }
                    else if(includes(menuButton, "+") || includes(menuButton, "-")){
                        list timerAddParams=llParseStringKeepNulls(menuButton,[" "],[""]);
                        integer timerNumber=str2Num(llList2String(timerAddParams, 0));
                        integer timerIncrease=1;
                        string timerUnit=llList2String(timerAddParams, 1);
                        if(timerUnit=="Second"){
                            timerIncrease=1;
                        }else if(timerUnit=="Minute"){
                            timerIncrease=60;
                        }else if(timerUnit=="Hour"){
                            timerIncrease=3600;
                        }else if(timerUnit=="Day"){
                            timerIncrease=86400;
                        }
                        addTimer(timerNumber * timerIncrease);
                    }
                    showTimerMenu(timerParentMenuName, user);
                }
            }
            else if(num==LAN_MSG_NUM){
                // 语言功能监听
                if (includes(str, "LANGUAGE.EXEC") && includes(str, "INIT")) { // 接收语言系统INIT回调，并启用语言功能
                    hasLanguage=TRUE;
                }
            }
        }
        if(llGetListLength(resultList)>0){
            llMessageLinked(LINK_SET, TIMER_MSG_NUM, list2Bundle(resultList), user); // 处理完成后的回调
        }

        
    }
}
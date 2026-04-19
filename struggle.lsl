initConfig(){
    struggleType=0; // 0: Struggle with random prob; 1: Struggle with random list
    struggleDifficulty=5; // 0~10
    struggleDebuff=10;
    struggleInterval=0.5;
    struggleKeys=[CONTROL_FWD, CONTROL_BACK, CONTROL_ROT_LEFT, CONTROL_ROT_RIGHT];
    struggleAnims=[];
    struggleText="Struggling...";
    struggleTextColor=<1.0,0.0,0.0>;
    struggleTextAlpha=1.0;
}
/*CONFIG END*/
/*
Name: Struggle
Author: JMRY
Description: A struggle system, use link_message to operate struggle things.

***更新记录***
- 1.0.7 20260419
    - 加入\NL不进行语言匹配功能。

- 1.0.6 20260406
    - 优化REZ模式下，玩家UUID的识别效果。

- 1.0.5 20260324
    - 优化初始化逻辑。

- 1.0.4 20260322
    - 适配文本显示脚本。

- 1.0.3 20260311
    - 优化记事卡读取速度。

- 1.0.2 20260301
	- 优化初始化时，REZ模式的判定逻辑。

- 1.0.1 20260228
	- 修复挣扎结束（停止、成功）后，动画仍在播放的bug。
	- 修复挣扎停止后，仍然显示文字的bug。

- 1.0 20260226
    - 初步完成挣扎功能。
***更新记录***
*/

/*
TODO:
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

list strSplit(string m, string sp){
    list pl=llParseStringKeepNulls(m,[sp],[""]);
    list temp=[];
    integer i;
    for(i=0; i<llGetListLength(pl); i++){
        temp+=[llStringTrim(llList2String(pl, i), STRING_TRIM)];
    }
    return temp;
}
string list2Data(list d){
    return llDumpList2String(d, ";");
}

string lanLinkHeader="LAN_";
integer hasLanguage=FALSE;

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
        text=llReplaceSubString(text, "%"+(string)vi+"%", getLanguage(llList2String(var, i)),0);
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

integer struggleType; // 0: Struggle with random prob; 1: Struggle with random list
integer struggleDifficulty; // 0~10
integer struggleDebuff;
float struggleInterval;
list struggleKeys;
list struggleAnims;
string struggleText;
vector struggleTextColor;
float struggleTextAlpha;


integer struggleStatus;
integer controlVal;
integer struggleProcess; // 0~10
float struggleProb;
list struggleKeyList;
integer beginStruggle(integer bool){
	struggleStatus=bool;
    controlVal=0;
    struggleTimerCount=0;
    if(bool==TRUE){ // Begin struggle
        integer i;
        struggleProcess=0;
        if(struggleType==0){
            struggleProb=(float)struggleDifficulty / 10;
        }
        else if(struggleType==1){
            struggleKeyList=[];
            for(i=0; i<struggleDifficulty; i++){
                integer randKey=(integer)llFrand(llGetListLength(struggleKeys));
                struggleKeyList+=[llList2Integer(struggleKeys, randKey)];
            }
        }
        for(i=0; i<llGetListLength(struggleKeys); i++){
            controlVal = controlVal | llList2Integer(struggleKeys, i);
        }
        llSetTimerEvent(struggleInterval);
        llMessageLinked(LINK_THIS, STRUGGLE_MSG_NUM, "STRUGGLE.APPLY.BEGIN", NULL_KEY);
    }
    else if(bool==2){ // Struggle success
        llSetTimerEvent(0);
        stopStruggleAnim();
        applyStruggleText(FALSE);
        llMessageLinked(LINK_THIS, STRUGGLE_MSG_NUM, "STRUGGLE.APPLY.SUCCESS", NULL_KEY);
    }
    else{ // Struggle stop
        llSetTimerEvent(0);
        stopStruggleAnim();
        applyStruggleText(FALSE);
        llMessageLinked(LINK_THIS, STRUGGLE_MSG_NUM, "STRUGGLE.APPLY.STOP", NULL_KEY);
    }
    llRequestPermissions(strugglePlayer, PERMISSION_TAKE_CONTROLS | PERMISSION_TRIGGER_ANIMATION);
    return bool;
}

string curPlayAnim;
string lastPlayAnim;
integer playAnimFlag=-1;
playStruggleAnim(integer keyId, integer index){
    if(strugglePlayer==NULL_KEY){
        return;
    }
    // stopStruggleAnim();
    string animName=llList2String(struggleAnims, index);
    if(animName!=""){
        curPlayAnim=animName;
        playAnimFlag=TRUE;
        llRequestPermissions(strugglePlayer,PERMISSION_TRIGGER_ANIMATION);
    }
}
stopStruggleAnim(){
    if(strugglePlayer==NULL_KEY){
        return;
    }
    if(lastPlayAnim!=""){
        playAnimFlag=FALSE;
        llRequestPermissions(strugglePlayer,PERMISSION_TRIGGER_ANIMATION);
    }
}

integer TEXT_READY=FALSE;
applyStruggleText(integer bool){
    if(struggleText==""){
        return;
    }
    if(bool){
        string struggleDisplayText=getLanguage(struggleText)+"\n";
        integer i;
        integer max;
        if(struggleType==0){
            max=10;
        }
        else if(struggleType==1){
            max=llGetListLength(struggleKeyList);
        }
        for(i=1; i<=max; i++){
            if(i <= struggleProcess){
                struggleDisplayText+=getLanguageBool("[1]");
            }else{
                struggleDisplayText+=getLanguageBool("[0]");
            }
        }
        if(TEXT_READY==TRUE){
            llMessageLinked(LINK_SET, TEXT_MSG_NUM, "TEXT.SET|Struggle|"+struggleDisplayText+"1|Timer", NULL_KEY);
        }else{
            llSetText(struggleDisplayText, struggleTextColor, struggleTextAlpha);
        }
    }else{
        if(TEXT_READY==TRUE){
            llMessageLinked(LINK_SET, TEXT_MSG_NUM, "TEXT.REM|Struggle", NULL_KEY);
        }else{
            llSetText("", ZERO_VECTOR, 0.0);
        }
    }
}

string struggleMenuText="Struggle";
string struggleMenuName="StruggleMenu";
showStruggleMenu(string parent, key user){
    string struggleTypeText="";
    if(struggleType==0){
        struggleTypeText="Random key";
    }
    else if(struggleType==1){
        struggleTypeText="Correct key";
    }
    string struggleMenuText="This is struggle menu.\nStruggle type: %1%%%;"+struggleTypeText;
    list struggleMenuList=["Struggle!", "Stop!"];
    llMessageLinked(LINK_SET, MENU_MSG_NUM, "MENU.REG.OPEN|"+struggleMenuName+"|"+struggleMenuText+"|"+list2Data(struggleMenuList)+"|"+parent, user);
}

string notecardHeader="struggle_";
key readNotecardQuery=NULL_KEY;
integer readNotecardLine=0;
string readNotecardName="";
string curNotecardName="";

integer MENU_MSG_NUM=1000;
integer STRUGGLE_MSG_NUM=1007;
integer LAN_MSG_NUM=1003;
integer TEXT_MSG_NUM=1008;

integer struggleLastKey=-1;
integer struggleTimerCount=0;
key strugglePlayer=NULL_KEY;
default{
    state_entry(){
        initConfig();
		if(llGetAttached()){
            strugglePlayer=llGetOwner();
        }else{
            strugglePlayer=NULL_KEY;
        }
        applyStruggleText(FALSE);
        llMessageLinked(LINK_THIS, TEXT_MSG_NUM, "TEXT.GET.READY", NULL_KEY);
        llMessageLinked(LINK_THIS, STRUGGLE_MSG_NUM, "STRUGGLE.READY", NULL_KEY);
    }
    changed(integer change){
        if(change & CHANGED_OWNER){
            llResetScript();
        }
        if(change & CHANGED_LINK){
            llSleep(0.01);
            strugglePlayer=llAvatarOnSitTarget();
        }
    }
    attach(key user){
        strugglePlayer=user;
        if(user!=NULL_KEY){
            llMessageLinked(LINK_THIS, STRUGGLE_MSG_NUM, "STRUGGLE.READY", NULL_KEY);
        }
    }
    object_rez(key user){
        strugglePlayer=NULL_KEY;
        llMessageLinked(LINK_THIS, STRUGGLE_MSG_NUM, "STRUGGLE.READY", NULL_KEY);
    }
    run_time_permissions(integer perm){
        if(perm & PERMISSION_TRIGGER_ANIMATION){
			if(struggleStatus==FALSE || struggleStatus==2){
				playAnimFlag=FALSE;
			}
            if(playAnimFlag==TRUE){
                if(lastPlayAnim!=""){
                    llStopAnimation(lastPlayAnim);
                }
                if(curPlayAnim==""){
                    return;
                }
                lastPlayAnim=curPlayAnim;
                llStartAnimation(curPlayAnim);
            }
            else if(playAnimFlag==FALSE){
                if(lastPlayAnim==""){
                    return;
                }
                llStopAnimation(lastPlayAnim);
            }
        }
        if(perm & PERMISSION_TAKE_CONTROLS){
            if(controlVal==0){
                llReleaseControls();
				stopStruggleAnim();
                // if(strugglePlayer!=NULL_KEY){
                //     llRequestPermissions(strugglePlayer,PERMISSION_TRIGGER_ANIMATION);
                // }
            }else{
                llTakeControls(controlVal,TRUE,FALSE);
            }
        }
    }
    control(key id, integer level, integer edge){
        if(struggleStatus==FALSE || struggleStatus==2){
			stopStruggleAnim();
			return;
		}
		if(level<=0 && edge>0){
            stopStruggleAnim();
        }
        integer i;
        for(i=0; i<llGetListLength(struggleKeys); i++){
            integer curKey=llList2Integer(struggleKeys, i);
            if(level & curKey){
                playStruggleAnim(curKey, i);
                if(struggleType==0){
					if(curKey!=struggleLastKey){
						struggleLastKey=curKey;
						float curProb=llFrand(1);
						if(curProb >= struggleProb){
							struggleProcess++;
							if(struggleProcess>=10){
								beginStruggle(2);
							}else{
								applyStruggleText(TRUE);
								jump sleep;
							}
						}
					}
                }
                else if(struggleType==1){
                    integer curNeedKey=llList2Integer(struggleKeyList, struggleProcess);
                    if(curNeedKey == curKey){
                        struggleProcess++;
                        struggleTimerCount=0;
                        if(struggleProcess>=llGetListLength(struggleKeyList)){
                            beginStruggle(2);
                        }else{
                            applyStruggleText(TRUE);
                            jump sleep;
                        }
                    }
                }
            }
        }
        @sleep;
        llSleep(struggleInterval);
    }
    timer(){
		applyStruggleText(TRUE);
        if(struggleTimerCount>0 && struggleDebuff>0 && struggleTimerCount%struggleDebuff==0){
            struggleProcess--;
            if(struggleProcess<0){
                struggleProcess=0;
                beginStruggle(FALSE);
            }
        }
        struggleTimerCount++;
    }
    link_message(integer sender_num, integer num, string msg, key user){
        if(num!=STRUGGLE_MSG_NUM && num!=MENU_MSG_NUM && num!=LAN_MSG_NUM && num!=TEXT_MSG_NUM){
            return;
        }
        list msgList=strSplit(msg, "|");
        string msgHeader=llList2String(msgList, 0);
        list msgHeaderGroup=llParseStringKeepNulls(msgHeader, ["."], [""]);

        string headerMain=llList2String(msgHeaderGroup, 0);
        string headerSub=llList2String(msgHeaderGroup, 1);
        string headerExt=llList2String(msgHeaderGroup, 2);

        string msg1=llList2String(msgList, 1);
        string msg2=llList2String(msgList, 2);

        if(headerMain=="STRUGGLE" && headerSub!="EXEC"){
            string result="";
            if(headerSub=="SET"){
                /*
                设置挣扎类型
                STRUGGLE.SET.TYPE | 1
                设置挣扎难度
                STRUGGLE.SET.DIFFICULTY | 5
                设置挣扎减益
                STRUGGLE.SET.DEBUFF | 2
                设置挣扎频率
                STRUGGLE.SET.INTERVAL | 0.5
                设置挣扎按键
                STRUGGLE.SET.KEYS | 1;2;4;8;256;512;16;32
                设置挣扎文字
                STRUGGLE.SET.TEXT | Struggling...
                设置挣扎文字颜色
                STRUGGLE.SET.COLOR | <1.0, 0.0, 0.0>
                设置挣扎文字透明度
                STRUGGLE.SET.ALPHA | 1.0
                */
                if(headerExt=="TYPE"){
                    struggleType=(integer)msg1;
                    result=(string)struggleType;
                }
                else if(headerExt=="DIFFICULTY"){
                    struggleDifficulty=(integer)msg1;
                    result=(string)struggleDifficulty;
                }
                else if(headerExt=="DEBUFF"){
                    struggleDebuff=(integer)msg1;
                    result=(string)struggleDebuff;
                }
                else if(headerExt=="INTERVAL"){
                    struggleInterval=(float)msg1;
                    result=(string)struggleInterval;
                }
                else if(headerExt=="KEYS"){
                    struggleKeys=strSplit(msg1, ";");
                    result=list2Data(struggleKeys);
                }
                else if(headerExt=="ANIMS"){
                    struggleAnims=strSplit(msg1, ";");
                    result=list2Data(struggleAnims);
                }
                else if(headerExt=="TEXT"){
                    struggleText=msg1;
                    result=(string)struggleText;
                }
                else if(headerExt=="COLOR"){
                    struggleTextColor=(vector)msg1;
                    result=(string)struggleTextColor;
                }
                else if(headerExt=="ALPHA"){
                    struggleTextAlpha=(float)msg1;
                    result=(string)struggleTextAlpha;
                }
            }
            else if(headerSub=="GET"){
                /*
                设置挣扎类型
                STRUGGLE.GET.TYPE
                设置挣扎难度
                STRUGGLE.GET.DIFFICULTY
                设置挣扎减益
                STRUGGLE.GET.DEBUFF
                设置挣扎频率
                STRUGGLE.GET.INTERVAL
                设置挣扎按键
                STRUGGLE.GET.KEYS
                设置挣扎文字
                STRUGGLE.GET.TEXT
                设置挣扎文字颜色
                STRUGGLE.GET.COLOR
                设置挣扎文字透明度
                STRUGGLE.GET.ALPHA
                */
                if(headerExt=="READY"){
                    llMessageLinked(LINK_THIS, STRUGGLE_MSG_NUM, "STRUGGLE.READY", NULL_KEY);
                }
                if(headerExt=="TYPE"){
                    result=(string)struggleType;
                }
                else if(headerExt=="DIFFICULTY"){
                    result=(string)struggleDifficulty;
                }
                else if(headerExt=="DEBUFF"){
                    result=(string)struggleDebuff;
                }
                else if(headerExt=="INTERVAL"){
                    result=(string)struggleInterval;
                }
                else if(headerExt=="KEYS"){
                    result=list2Data(struggleKeys);
                }
                else if(headerExt=="ANIMS"){
                    result=list2Data(struggleAnims);
                }
                else if(headerExt=="TEXT"){
                    result=(string)struggleText;
                }
                else if(headerExt=="COLOR"){
                    result=(string)struggleTextColor;
                }
                else if(headerExt=="ALPHA"){
                    result=(string)struggleTextAlpha;
                }
            }
            /*
            开始挣扎
            STRUGGLE.BEGIN
            停止挣扎
            STRUGGLE.STOP
            挣扎成功
            STRUGGLE.SUCCESS
            */
            else if(headerSub=="BEGIN"){
                beginStruggle(TRUE);
            }
            else if(headerSub=="STOP"){
                beginStruggle(FALSE);
            }
            else if(headerSub=="SUCCESS"){
                beginStruggle(2);
            }
            else if(headerSub=="LOAD"){
                /*
                读取记事卡（将覆盖现有的Notecard数据）
                STRUGGLE.LOAD | file1
                返回：
                STRUGGLE.EXEC | STRUGGLE.LOAD | 1
                */
                if(headerExt==""){
                    readNotecardLine=0;
                    curNotecardName=msg1;
                    readNotecardName=notecardHeader+msg1;
                    if (llGetInventoryType(readNotecardName) == INVENTORY_NOTECARD) {
                        llOwnerSay("Begin reading Struggle settings: "+msg1);
                        readNotecardQuery=llGetNotecardLine(readNotecardName, readNotecardLine); // 通过给readNotecardQuery赋llGetNotecardLine的key，从而触发datasever事件
                        // 后续功能交给下方datasever处理
                        result=(string)TRUE;
                    }else{
                        llMessageLinked(LINK_SET, STRUGGLE_MSG_NUM, "STRUGGLE.LOAD.NOTECARD|"+msg1+"|0", NULL_KEY); // Notecard成功读取记事卡后回调
                        result=(string)FALSE;
                    }
                }
                /*
                读取记事卡列表
                STRUGGLE.LOAD.LIST
                返回：
                STRUGGLE.EXEC | STRUGGLE.LOAD.LIST | file1; file2; file3 ...
                */
                else if(headerExt=="LIST"){
                    list notecardList=[];
                    integer count = llGetInventoryNumber(INVENTORY_NOTECARD);
                    integer i;
                    for (i=0; i<count; i++){
                        string notecardName = llGetInventoryName(INVENTORY_NOTECARD, i);
                        if(llGetSubString(notecardName, 0, 9)==notecardHeader){
                            notecardList+=[llGetSubString(notecardName, 10, -1)];
                        }
                    }
                    result=(string)list2Data(notecardList);
                }
            }
            /*
            显示菜单
            STRUGGLE.MENU | 上级菜单名
            */
            else if(headerSub=="MENU"){
                showStruggleMenu(msg1, user);
            }
            if(result!=""){
                llMessageLinked(LINK_SET, STRUGGLE_MSG_NUM, "STRUGGLE.EXEC|"+msgHeader+"|"+result, user);
            }
        }
        else if(headerMain=="MENU" && headerSub=="ACTIVE"){
            if(msg2==struggleMenuText){
                showStruggleMenu(msg1, user);
            }
            else if(msg1==struggleMenuName && msg2!=""){ // MENU.ACTIVE | Class | Class1
                if(msg2=="Struggle!"){
                    beginStruggle(TRUE);
                }
                else if(msg2=="Stop!"){
                    beginStruggle(FALSE);
                }
            }
        }
        else if(headerMain=="LANGUAGE" &&headerSub=="EXEC"){
            // 语言功能监听
            if(includes(msg, "INIT")){ // 接收语言系统INIT回调，并启用语言功能
                hasLanguage=TRUE;
            }
        }
        else if(headerMain=="TEXT" &&headerSub=="READY"){
            TEXT_READY=TRUE;
        }
    }
    dataserver(key query_id, string data){
        if (query_id == readNotecardQuery) { // 通过readRLVNotecards触发读取记事卡事件，按行读取指定RLV（readRLVQuery）并设置相关数据。
            while(TRUE){
                string temp=llGetNotecardLineSync(readNotecardName, readNotecardLine);
                if(temp!=NAK){
                    data=temp;
                }
                if (data == EOF) {
                    llOwnerSay("Finished reading Struggle settings: "+curNotecardName);
                    llMessageLinked(LINK_SET, STRUGGLE_MSG_NUM, "STRUGGLE.LOAD.NOTECARD|"+curNotecardName+"|1", NULL_KEY); // RLV成功读取记事卡后回调
                    readNotecardQuery=NULL_KEY;
                    jump end;
                } else {
                    /*
                    configName=configValue
                    */
                    if(data!="" && llGetSubString(data,0,0)!="#"){
                        list notecardStrSp=llParseStringKeepNulls(data, ["="], []);
                        string notecardName=llList2String(notecardStrSp,0);
                        string notecardData=llList2String(notecardStrSp,1);

                        if(notecardName=="struggleType"){struggleType=(integer)notecardData;}
                        else if(notecardName=="struggleDifficulty"){struggleDifficulty=(integer)notecardData;}
                        else if(notecardName=="struggleDebuff"){struggleDebuff=(integer)notecardData;}
                        else if(notecardName=="struggleInterval"){struggleInterval=(float)notecardData;}
                        else if(notecardName=="struggleKeys"){struggleKeys=strSplit(notecardData, ";");}
                        else if(notecardName=="struggleAnims"){struggleAnims=strSplit(notecardData, ";");}
                        else if(notecardName=="struggleText"){struggleText=notecardData;}
                        else if(notecardName=="struggleTextColor"){struggleTextColor=(vector)notecardData;}
                        else if(notecardName=="struggleTextAlpha"){struggleTextAlpha=(float)notecardData;}
                    }

                    // increment line count
                    ++readNotecardLine;
                    //request next line of notecard.
                    if(temp==NAK){
                        readNotecardQuery=llGetNotecardLine(readNotecardName, readNotecardLine);
                        jump end;
                    }
                }
            }
            @end;
        }
    }
}
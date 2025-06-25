/*
Name: Language
Author: JMRY
Description: A better language management system, use link_message to operate languages.

***更新记录***
- 1.0 20250625
    - 从菜单模块迁移语言功能。
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
    string t=k;
    integer i;
    list boolList=llParseStringKeepNulls(boolStrList,["|"],[""]);
    for(i=0; i<llGetListLength(boolList); i++){
        t=replace(t,llList2String(boolList, i)+" ", "");
    }
    return llStringTrim(t, STRING_TRIM);
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

/*
多语言通用方法。
设置语言（文字KEY，文字值），返回：当前语言的KEY对应文字
获取语言（文字KEY），返回：当前语言的KEY对应文字
*/

/*
请将如下脚本复制到需要语言功能的场合，并在语言发生变更（LANGUAGE.ACTIVE | CN）时调用applyLanguage
*/
string lanLinkHeader="LAN_";
integer clearLanguage(){
    return llLinksetDataDeleteFound(lanLinkHeader, "");
}

integer setLanguage(string k, string v){
	return llLinksetDataWrite(lanLinkHeader+k, v);
}

string getLanguage(string k){
	k=replace(replace(k,"\\n","\n"),"\n","\\n"); // 替换换行符\n。将转义的\\n替换回去再替换
	string curVal=llLinksetDataRead(lanLinkHeader+k);
	if(curVal){
		return replace(curVal,"\\n","\n");
	}else{
		return replace(k,"\\n","\n");
	}
}

string getLanguageKey(string v){
	list lanKeyList=llLinksetDataFindKeys(lanLinkHeader, 0, 0);
	integer i;
	for(i=0; i<llGetListLength(lanKeyList); i++){
		string curKey=llList2String(lanKeyList, i);
		string curVal=llLinksetDataRead(curKey);
		if(curVal==v){
			return curKey;
		}
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
/*
请将如上脚本复制到需要语言功能的场合，并在语言发生变更（LANGUAGE.ACTIVE | CN）时调用applyLanguage
*/

/*
读取语言记事卡通用方法
*/
string lanHeader="lan_"; // 语言文件名记事卡前缀lan_语言名（英文），如：lan_CN，lan_EN，lan_JP等
list getLanguageNotecards(){
    list lanList=[];
    integer count = llGetInventoryNumber(INVENTORY_NOTECARD);
    integer i;
    for (i=0; i<count; i++){
        string notecardName = llGetInventoryName(INVENTORY_NOTECARD, i);
        if(llGetSubString(notecardName, 0, 3)==lanHeader){
            lanList+=[llGetSubString(notecardName, 4, -1)];
        }
    }
    return lanList;
}

key readLanQuery=NULL_KEY;
integer readLanLine=0;
string readLanName="";
string curLanName="";
key curLanUser=NULL_KEY;
string readLanguageNotecards(string lname, key user){
    readLanLine=0;
    curLanName=lname;
    readLanName=lanHeader+lname;
	curLanUser=user;
    if (llGetInventoryType(readLanName) == INVENTORY_NOTECARD) {
        // llRegionSayTo(showMenuUser, 0, "Begin reading language "+lname+".");
        llRegionSayTo(curLanUser, 0, getLanguageVar("Begin reading language %1.%%;"+lname));
        clearLanguage();
        readLanQuery=llGetNotecardLine(readLanName, readLanLine); // 通过给readLanQuery赋llGetNotecardLine的key，从而触发datasever事件
        // 后续功能交给下方datasever处理
        return lname;
    }else{
        return lname+"_NOT_FOUND";
    }
}

string languageMenu="languageMenu";
showLanguageMenu(string parent, key user){
    string menuName=languageMenu;
    string menuText="Set menu language, current: %1.%%;"+llGetSubString(readLanName, 4, -1);
    list menuList=getLanguageNotecards();
    string menuParent=parent;
	llMessageLinked(LINK_SET, MENU_MSG_NUM, "MENU.REG.OPEN.RESET|"+menuName+"|"+menuText+"|"+list2Msg(menuList)+"|"+menuParent, user);
    // registMenu(menuName, menuText, menuList, menuParent);
    // executeMenu(menuName, TRUE, user);
}

integer MENU_MSG_NUM=1000;
integer LAN_MSG_NUM=1003;
default{
    state_entry(){
    }
	changed(integer change){
        if(change & CHANGED_OWNER){
            llResetScript();
        }
		if(change & CHANGED_INVENTORY){
			if(!curLanName) return;
			key user=llGetOwner();
			list lanChanList=[
				"LAN.CHANGE",
				curLanName
			];
			llMessageLinked(LINK_SET, LAN_MSG_NUM, list2Msg(lanChanList), user);
		}
    }
	link_message(integer sender_num, integer num, string msg, key user){
        if(num!=LAN_MSG_NUM && num!=MENU_MSG_NUM){
            return;
        }
		/*
		加载语言
		LAN.LOAD | CN
		LANGUAGE.LOAD | CN
		切换语言
        LAN.CHANGE | CN
        LANGUAGE.CHANGE | CN
        获取语言文本
        LAN.GET | Key1; Key2; Key3
        LAN.GETV | Key1; Key2; Key3
        LANGUAGE.GET | Key1; Key2; Key3
        LANGUAGE.GETV | Key1; Key2; Key3
        LANGUAGE.GETKEY | Lan1; Lan2; Lan3
        LANGUAGE.GETNAME
		语言功能回调
		LANGUAGE.EXEC | LAN.LOAD | 0
        LANGUAGE.EXEC | LAN.LAN.GET | Lan1; Lan2; Lan3
        LANGUAGE.EXEC | LAN.LAN.GETV | Lan1; Lan2; Lan3
        LANGUAGE.EXEC | LAN.LAN.GETKEY | Key1; Key2; Key3
        LANGUAGE.EXEC | LAN.LAN.GETNAME | CN
		语言加载完毕回调
		LANGUAGE.ACTIVE | CN
		*/
		list msgList=bundle2List(msg);
        list resultList=[];
        integer msgCount=llGetListLength(msgList);
        integer mi;
        for(mi=0; mi<msgCount; mi++){
			string str=llList2String(msgList, mi);
			if (llGetSubString(str, 0, 2) == "LAN" && !includes(str, "EXEC")) {
				list lanCmdList=msg2List(str);
                string lanCmdStr=llList2String(lanCmdList, 0);
                list lanCmdGroup=llParseStringKeepNulls(lanCmdStr, ["."], [""]);
    
                string lanCmd=llList2String(lanCmdGroup, 0);
                string lanCmdSub=llList2String(lanCmdGroup, 1);
                string lanCmdExt=llList2String(lanCmdGroup, 2);

				string lanName=llList2String(lanCmdList, 1);
                string lanText=llList2String(lanCmdList, 2);

				string result="";

				if(lanCmd=="LAN" || lanCmd=="LANGUAGE"){
                    if(lanCmdSub=="LOAD" || lanCmdSub=="CHANGE"){
                        result=(string)readLanguageNotecards(lanName, user);
                    }
                    else if(lanCmdSub=="GET"){
                        list kList=data2List(lanName);
                        integer count=llGetListLength(kList);
                        if(count>0){
                            list lList=[];
                            integer i;
                            for(i=0; i<count; i++){
                                lList+=getLanguage(llList2String(kList,i)); // 此处获取的是原始的语言文本，不能拼接变量，因此用gl而不是glv
                            }
                            result=list2Data(lList);
                        }else{
                            result=list2Data(lanKeyValList); // GET参数为空时，返回所有语言key、val的list
                        }
                    }
                    else if(lanCmdSub=="GETV"){
                        list kList=data2List(lanName);
                        list lList=[];
                        integer count=llGetListLength(kList);
                        integer i;
                        for(i=0; i<count; i++){
                            lList+=getLanguageVar(llList2String(kList,i)); // 此处获取的是拼接变量的语言文本
                        }
                        result=list2Data(lList);
                    }
                    else if(lanCmdSub=="GETKEY"){
                        list lList=data2List(lanName);
                        list kList=[];
                        integer count=llGetListLength(kList);
                        integer i;
                        for(i=0; i<count; i++){
                            kList+=getLanguageKey(llList2String(lList,i));
                        }
                        result=list2Data(kList);
                    }
                    else if(lanCmdSub=="GETNAME"){
                        result=curLanName;
                    }
                }

				if(result!=""){
                    list lanExeResult=[
                        "LANGUAGE.EXEC", lanCmdStr, result
                    ];
                    resultList+=[list2Msg(lanExeResult)];
                    //llMessageLinked(LINK_SET, 0, list2Msg(menuExeResult), user); // 菜单处理完成后的回调
                }
			}
			else if (includes(str, "MENU.ACTIVE")) {
				list menuCmdList=msg2List(str);
				string menuName=llList2String(menuCmdList, 1);
                string menuText=llList2String(menuCmdList, 2);

				if(menuText=="Language"){
					showLanguageMenu(menuName, user);
				}else if(menuName=="languageMenu" && menuText!=""){
					//readLanguageNotecards(menuText); // 由于需要语言的执行回调LANGUAGE.EXEC，因此不允许直接调用
					list lanChanList=[
						"LAN.CHANGE",
						menuText
					];
					llMessageLinked(LINK_SET, LAN_MSG_NUM, list2Msg(lanChanList), user);
				}
			}
		}

		if(llGetListLength(resultList)>0){
            llMessageLinked(LINK_SET, LAN_MSG_NUM, list2Bundle(resultList), user); // 菜单处理完成后的回调
        }
	}
	dataserver(key query_id, string data){
        if (query_id == readLanQuery) { // 通过readLanguageNotecards触发读取记事卡事件，按行读取指定语言文本（readLanName）并设置语言。
			if(data != EOF){
				// data: language key=language value
                list lanStrSp=llParseStringKeepNulls(data, ["="], []);
                string lanKey=llList2String(lanStrSp,0);
                string lanVal=llList2String(lanStrSp,1);
                setLanguage(lanKey, lanVal);
                // increment line count
                ++readLanLine;
                //request next line of notecard.
                readLanQuery=llGetNotecardLine(readLanName, readLanLine);
			}else{
 				// llRegionSayTo(showMenuUser, 0, "Finished reading language "+readLanName+".");
                llRegionSayTo(curLanUser, 0, getLanguageVar("Finished reading language %1.%%;"+curLanName));
                applyLanguage();
				llMessageLinked(LINK_SET, LAN_MSG_NUM, "LANGUAGE.ACTIVE|"+curLanName, curLanUser);
                readLanQuery=NULL_KEY;
				curLanUser=NULL_KEY;
			}
        }
    }
}
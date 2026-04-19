initConfig(){
    textColor=<1.0,0.0,0.0>;
    textAlpha=1.0;
	textDisplay=TRUE;
	textLinkName="floattext";
}
/*CONFIG END*/
/*
Name: Text
Author: JMRY
Description: A text system, use link_message to operate text things.

***更新记录***
- 1.0.3 20260419
	- 加入\NL不进行语言匹配功能。

- 1.0.2 20260402
	- 加入指定显示文本的Prim功能。

- 1.0.1 20260322
	- 加入获取文字参数的功能。
	- 优化参数传递结构。

- 1.0 20260321
    - 初步完成显示文字功能。
***更新记录***
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

integer getLinkByName(string name){
    name=llToLower(llStringTrim(name,STRING_TRIM));
    integer linkCount=llGetNumberOfPrims();
    integer i;
    for (i=-1; i<=linkCount;++i){
        string curPrimName = llToLower(llStringTrim(llList2String(llGetLinkPrimitiveParams(i,[PRIM_NAME]),0),STRING_TRIM));
        if(curPrimName==name){
            return i;
        }
    }
    return 0;
}

/*
请将如下脚本复制到需要语言功能的场合，并在语言发生变更（LANGUAGE.ACTIVE | LAN_NAME）时调用applyLanguage
*/
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
            return llReplaceSubString(curKey, lanLinkHeader, "", 0);
        }
    }
    return v;
}

string getLanguageVar(string k){ // 拼接字符串方法，用于首尾拼接变量等内容。格式：Text text %1 %2.%%var1;var2
    list ksp=llParseStringKeepNulls(k, ["%%;"], [""]); // ["Text text %1 %2.", "var1;var2"]
    string text=getLanguage(llStringTrim(llList2String(ksp, 0), STRING_TRIM));
    list var=strSplit(llList2String(ksp, 1), ";"); // ["var1", "var2"]
    integer i;
    for(i=0; i<llGetListLength(var); i++){
        integer vi=i+1;
        text=llReplaceSubString(text, "%"+(string)vi+"%", getLanguage(llList2String(var, i)), 0);
        text=llReplaceSubString(text, "%b"+(string)vi+"%", getLanguageBool("["+llList2String(var, i)+"]"), 0);
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
/*
请将如上脚本复制到需要语言功能的场合，并在语言发生变更（LANGUAGE.ACTIVE | CN）时调用applyLanguage
*/


list textList=[]; // name, content, bool, parent
integer textDataLength=4;
string textNameHeader="TEXTH_";
integer addText(string name, string content, integer bool, string parent){
	if(name==""){
		return FALSE;
	}
	removeText(name);

	name=textNameHeader+name;
	parent=textNameHeader+parent;

	if(parent=="TEXTH_TOP"){
		textList=[name, content, bool, parent]+textList;
	}else{
		integer parentIndex=llListFindList(textList, [parent]);
		if(~parentIndex){
			textList=llListInsertList(textList, [name, content, bool, parent], parentIndex+textDataLength);
		}else{
			textList+=[name, content, bool, parent];
		}
	}

	// integer index=llListFindList(textList, [name]);
	// if(~index){
	// 	textList=llListReplaceList(textList, [content, bool], index+1, index+textDataLength-1);
	// }else{
	// 	if(parent=="TEXTH_TOP"){
	// 		textList=[name, content, bool]+textList;
	// 	}else{
	// 		integer parentIndex=llListFindList(textList, [parent]);
	// 		if(~parentIndex){
	// 			textList=llListInsertList(textList, [name, content, bool], parentIndex+textDataLength);
	// 		}else{
	// 			textList+=[name, content, bool];
	// 		}
	// 	}
	// }
	return TRUE;
}

list getText(string name){
	if(name==""){
		return [];
	}
	name=textNameHeader+name;
	integer index=llListFindList(textList, [name]);
	if(~index){
		return llList2List(textList, index, index+textDataLength-1);
	}else{
		return [];
	}
}

integer removeText(string name){
	if(name==""){
		return FALSE;
	}
	name=textNameHeader+name;
	integer index=llListFindList(textList, [name]);
	if(~index){
		textList=llDeleteSubList(textList, index, index+textDataLength-1);
		return TRUE;
	}
	return FALSE;
}

vector textColor=<1.0, 1.0, 1.0>;
float textAlpha=1.0;
integer textDisplay=TRUE;
string textLinkName="floattext";
displayText(){
	list displayTextList=[];
	integer textLink=getLinkByName(textLinkName);
	if(textDisplay==TRUE){
		integer i;
		for(i=1; i<llGetListLength(textList); i+=textDataLength){
			if(llList2Integer(textList, i+1)==TRUE){
				displayTextList+=getLanguageVar(llList2String(textList, i));
			}
		}
		if(textLink>0){
			llSetLinkPrimitiveParamsFast(textLink, [PRIM_TEXT, llDumpList2String(displayTextList, "\n"), textColor, textAlpha]);
		}else{
			llSetText(llDumpList2String(displayTextList, "\n"), textColor, textAlpha);
		}
	}else{
		if(textLink>0){
			llSetLinkPrimitiveParamsFast(textLink, [PRIM_TEXT, "", ZERO_VECTOR, 0.0]);
		}else{
			llSetText("", ZERO_VECTOR, 0.0);
		}
	}
}

integer MENU_MSG_NUM=1000;
integer LAN_MSG_NUM=1003;
integer TEXT_MSG_NUM=1008;

default{
	state_entry(){
		initConfig();
		llSetText("", ZERO_VECTOR, 0.0);
	}
	changed(integer change){
        if(change & CHANGED_OWNER){
            llResetScript();
        }
    }
	link_message(integer sender_num, integer num, string msg, key user){
		if(num!=TEXT_MSG_NUM && num!=MENU_MSG_NUM && num!=LAN_MSG_NUM){
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
        string msg3=llList2String(msgList, 3);
        string msg4=llList2String(msgList, 4);

		if(headerMain=="TEXT" && headerSub!="EXEC"){
			string result="";
			if(headerSub=="SET"){
				if(headerExt==""){
					/*
					显示文本
					TEXT.SET | Name | Content | Bool | Parent
					*/
					if(msg1!=""){
						if(msg3==""){ // Bool为空时，默认为显示
							msg3="1";
						}
						addText(msg1, msg2, (integer)msg3, msg4);
					}
				}
				else if(headerExt=="DISPLAY"){
					/*
					显示文本开关
					TEXT.SET.DISPLAY | 1
					*/
					textDisplay=(integer)msg1;
				}
				else if(headerExt=="COLOR"){
					/*
					显示文本颜色
					TEXT.SET.COLOR | <1.0, 1.0, 1.0>
					*/
					textColor=(vector)msg1;
				}
				else if(headerExt=="ALPHA"){
					/*
					显示文本透明度
					TEXT.SET.ALPHA | 1.0
					*/
					textAlpha=(float)msg1;
				}
				displayText();
			}
			else if(headerSub=="GET"){
				if(headerExt==""){
					/*
					获取显示文本
					TEXT.GET | Name
					返回：
					TEXT.EXEC | TEXT.GET | Name; Content; Bool; Parent
					*/
					result=llDumpList2String(getText(msg1), ";");
				}
				else if(headerExt=="ALL"){
					/*
					获取所有文本
					TEXT.GET.ALL
					返回：
					TEXT.EXEC | TEXT.GET.ALL | Name1; Content1; Bool1; Parent1; Name2; Content2; Bool2; Parent2; ...
					*/
					result=llDumpList2String(textList, ";");
				}
				else if(headerExt=="READY"){
					/*
					文本系统就绪
					TEXT.GET.READY
					返回：
					TEXT.READY
					*/
					llMessageLinked(LINK_THIS, TEXT_MSG_NUM, "TEXT.READY", NULL_KEY);
				}
				else if(headerExt=="DISPLAY"){
					/*
					显示文本开关
					TEXT.GET.DISPLAY
					返回：
					TEXT.EXEC | TEXT.GET.DISPLAY | 1
					*/
					result=(string)textDisplay;
				}
				else if(headerExt=="COLOR"){
					/*
					显示文本颜色
					TEXT.GET.COLOR
					返回：
					TEXT.EXEC | TEXT.GET.COLOR | <1.0, 1.0, 1.0>
					*/
					result=(string)textColor;
				}
				else if(headerExt=="ALPHA"){
					/*
					显示文本透明度
					TEXT.GET.ALPHA
					返回：
					TEXT.EXEC | TEXT.GET.ALPHA | 1.0
					*/
					result=(string)textAlpha;
				}
			}
			else if(headerSub=="REM" || headerSub=="REMOVE"){
				/*
                移除文本
                TEXT.REM | Name
                TEXT.REMOVE | Name
                */
				if(msg1!=""){
					removeText(msg1);
				}
				displayText();
			}
			if(result!=""){
                llMessageLinked(LINK_SET, TEXT_MSG_NUM, "TEXT.EXEC|"+msgHeader+"|"+result, user);
            }
		}
		else if(headerMain=="LANGUAGE" && headerSub=="EXEC"){
            // 语言功能监听
            if(includes(msg, "INIT")){ // 接收语言系统INIT回调，并启用语言功能
                hasLanguage=TRUE;
            }
        }
	}
}
initMain(){
	REMOTE_CONTROL_CHANNEL=131793;
	REMOTE_OBJECT_CHANNEL=131794;
	textColor=<1.0, 1.0, 1.0>;
	textAlpha=1.0;
	buttonAvailableBlackList=[
		"Menu",
		"Leash",
		"Shock"
	];
}
/*CONFIG END*/

/*
Name: Remote
Author: JMRY
Description: A remote controller for restraint items.

***更新记录***
- 1.0 20260428
    - 完成主要功能。
***更新记录***
*/

string userInfo(key user){
    if(llGetAgentSize(user) != ZERO_VECTOR){
        return "secondlife:///app/agent/"+(string)user+"/about";
    }else{
        list objDetails=llGetObjectDetails(user, [OBJECT_NAME, OBJECT_OWNER]);
        return "secondlife:///app/objectim/"+(string)user+"?name="+llEscapeURL(llList2String(objDetails, 0))+"&owner="+llList2String(objDetails, 1);
    }
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

list userObjectList=[];
integer userObjectLength=2; // [ObjectKey, User]
addUserObject(key object, key user){
	integer i;
	for(i=0; i<llGetListLength(userObjectList); i+=userObjectLength){
		if(llList2Key(userObjectList, i) == object){
			return;
		}
	}
	userObjectList+=[object, user];
}

list getUserList(){
	list usersList=[];
	integer i;
	for(i=1; i<llGetListLength(userObjectList); i+=userObjectLength){
		if(!~llListFindList(usersList, [llList2Key(userObjectList, i)])){
			usersList+=llList2Key(userObjectList, i);
		}
	}
	return usersList;
}

list getUserObjectList(key user){
	list objectsList=[];
	integer i;
	for(i=0; i<llGetListLength(userObjectList); i+=userObjectLength){
		if(llList2Key(userObjectList, i+1) == user){
			objectsList+=[llList2Key(userObjectList, i)];
		}
	}
	return objectsList;
}

integer openCollarMode=FALSE;
showSettingsMenu(key user){
	list menuList=["Language", "["+(string)openCollarMode+"]OpenCollarMode"];
	llMessageLinked(LINK_THIS, MENU_MSG_NUM, "MENU.CLEAR", user);
	llMessageLinked(LINK_THIS, MENU_MSG_NUM, "MENU.REG.OPEN.RESET|settingsMenu|This is settings menu.|"+llDumpList2String(menuList, ";"), user);
}

integer userLimit=18;
list userList=[];
showScanMenu(key user){
	userList=getUserList();
	list menuUserList=["[Disconnect]"];
	integer i;
	for(i=0; i<llGetListLength(userList) && i<userLimit; i++){
		menuUserList+=[llGetSubString((string)(i+1)+". "+llGetUsername(llList2Key(userList, i)), 0, 23)];
	}
	llMessageLinked(LINK_THIS, MENU_MSG_NUM, "MENU.CLEAR", user);
	llMessageLinked(LINK_THIS, MENU_MSG_NUM, "MENU.REG.OPEN.RESET|scanMenu|Select a user to connect:|"+llDumpList2String(menuUserList, ";"), user);
}

list objectList=[];
showObjectMenu(key target, key user){
	objectList=getUserObjectList(target);
	list menuObjectList=["[Disconnect]"];
	integer i;
	for(i=0; i<llGetListLength(objectList) && i<userLimit; i++){
		menuObjectList+=[llGetSubString((string)(i+1)+". "+llKey2Name(llList2Key(objectList, i)), 0, 23)];
	}
	llMessageLinked(LINK_THIS, MENU_MSG_NUM, "MENU.REG.OPEN.RESET|objectMenu|Select %1% 's object to connect:%%;"+userInfo(target)+"|"+llDumpList2String(menuObjectList, ";")+"|scanMenu", user);
}

list buttonAvailableBlackList=[];
setButtonsAvailable(integer bool){
	integer i;
	for(i=1; i<=llGetNumberOfPrims(); i++){
		string curPrimName = llList2String(llGetLinkPrimitiveParams(i,[PRIM_NAME]),0);
		if(~llListFindList(buttonAvailableBlackList, [curPrimName])){
			if(bool==TRUE){
				llSetLinkAlpha(i, 1.0, ALL_SIDES);
			}else{
				llSetLinkAlpha(i, 0.5, ALL_SIDES);
			}
		}
	}
}


integer REMOTE_CONTROL_CHANNEL=131793;
integer REMOTE_OBJECT_CHANNEL=131794;

key CONNECT_UUID=NULL_KEY;
key CONNECT_USER=NULL_KEY;

integer MENU_MSG_NUM=1000;
integer LAN_MSG_NUM=1003;

string timerEventFlag="";
vector textColor=<1.0, 1.0, 1.0>;
float textAlpha=1.0;

default{
	state_entry(){
		initMain();
		setButtonsAvailable(FALSE);
		llListen(REMOTE_CONTROL_CHANNEL, "", "", "");
		llMessageLinked(LINK_SET, LAN_MSG_NUM, "LANGUAGE.INIT", NULL_KEY);
	}
	timer(){
		if(timerEventFlag=="scan"){
			showScanMenu(llGetOwner());
			llSetTimerEvent(0);
		}
	}
	listen(integer channel, string name, key id, string message){
		key user=llGetOwnerKey(id);
		if(channel==REMOTE_CONTROL_CHANNEL){
			list msgList=strSplit(message, "|");
			string msgHeader=llList2String(msgList, 0);
			list msgHeaderGroup=llParseStringKeepNulls(msgHeader, ["."], [""]);

			string headerMain=llList2String(msgHeaderGroup, 0);
			string headerSub=llList2String(msgHeaderGroup, 1);
			string headerExt=llList2String(msgHeaderGroup, 2);

			string msg1=llList2String(msgList, 1);
			string msg2=llList2String(msgList, 2);
			string msg3=llList2String(msgList, 3);
			string msg4=llList2String(msgList, 4);

			// REMOTE.REPLY | ObjectKey
			if(headerMain=="REMOTE"){
				if(headerSub=="REPLY"){
					addUserObject(id, user);
				}
				else if(headerSub=="CONNECTED"){
					CONNECT_UUID=id;
					CONNECT_USER=llGetOwnerKey(id);
					llMessageLinked(LINK_SET, MENU_MSG_NUM, "MENU.OUT.TO|You connected to %1% 's %2% .%%;"+userInfo(CONNECT_USER)+";"+userInfo(CONNECT_UUID), llGetOwner());
					llSetText(llKey2Name(CONNECT_UUID)+"\n"+llGetUsername(CONNECT_USER), textColor, textAlpha);
					setButtonsAvailable(TRUE);
				}
				else if(headerSub=="DISCONNECTED"){
					CONNECT_UUID=NULL_KEY;
					CONNECT_USER=NULL_KEY;
					llSetText("", textColor, textAlpha);
					setButtonsAvailable(FALSE);
				}
			}
		}
	}
	link_message(integer sender_num, integer num, string msg, key user){
        list msgList=strSplit(msg, "|");
        string msgHeader=llList2String(msgList, 0);
        list msgHeaderGroup=llParseStringKeepNulls(msgHeader, ["."], [""]);

        string headerMain=llList2String(msgHeaderGroup, 0);
        string headerSub=llList2String(msgHeaderGroup, 1);
        string headerExt=llList2String(msgHeaderGroup, 2);

        string msg1=llList2String(msgList, 1);
        string msg2=llList2String(msgList, 2);
        string msg3=llList2String(msgList, 3);
        
        if(headerMain=="BUTTON"){ // BUTTON | ButtonName
            if(msg1=="Menu"){
				if(CONNECT_UUID!=NULL_KEY && CONNECT_USER!=NULL_KEY){
					if(openCollarMode){
						llSay(1, llGetSubString(llGetUsername(CONNECT_USER), 0, 1)+"menu");
					}else{
						llSay(REMOTE_OBJECT_CHANNEL, "REMOTE.MENU");
					}
				}
			}
            else if(msg1=="Settings"){
				showSettingsMenu(user);
			}
			else if(msg1=="Connect"){
				userObjectList=[];
				llSay(REMOTE_OBJECT_CHANNEL, "REMOTE.SCAN");
				timerEventFlag="scan";
				llSetTimerEvent(1);
				llMessageLinked(LINK_SET, MENU_MSG_NUM, "MENU.OUT|Scanning available objects...", llGetOwner());
			}
        }
		else if(headerMain=="FEATURE"){ // FEATURE | FEATER_MSG_NUM | FEATURE.NAME | FeaterParams1 | FeatureParams2 | ...
			if(CONNECT_UUID!=NULL_KEY && CONNECT_USER!=NULL_KEY){
				if(openCollarMode){
					if(includes(msg, "LEASH")){
						llSay(1, llGetSubString(llGetUsername(CONNECT_USER), 0, 1)+"leash");
					}
				}else{
					llSay(REMOTE_OBJECT_CHANNEL, "REMOTE.FEATURE|"+llDumpList2String(llList2List(msgList, 1, -1), "|"));
				}
			}
		}
		else if(headerMain=="MENU" && headerSub=="ACTIVE"){
			if(msg1=="scanMenu"){
				if(msg2=="[Disconnect]"){
					llSay(REMOTE_OBJECT_CHANNEL, "REMOTE.DISCONNECT");
					setButtonsAvailable(FALSE);
				}else{
					list buList=llParseStringKeepNulls(msg2,[". "],[""]);
					integer buIndex=llList2Integer(buList,0);
					key buUser=llList2Key(userList, ((integer)(buIndex-1)));
					if(buUser!=NULL_KEY){
						showObjectMenu(buUser, user);
					}
				}
			}
			else if(msg1=="objectMenu"){
				if(msg2=="[Disconnect]"){
					llSay(REMOTE_OBJECT_CHANNEL, "REMOTE.DISCONNECT");
					setButtonsAvailable(FALSE);
				}else{
					list buList=llParseStringKeepNulls(msg2,[". "],[""]);
					integer buIndex=llList2Integer(buList,0);
					key buObject=llList2Key(objectList, ((integer)(buIndex-1)));
					if(buObject!=NULL_KEY){
						llSay(REMOTE_OBJECT_CHANNEL, "REMOTE.CONNECT|"+(string)buObject);
					}
				}
			}
			else if(msg1=="settingsMenu"){
				if(msg2=="OpenCollarMode"){
					openCollarMode=!openCollarMode;
					showSettingsMenu(user);
				}
			}
		}
    }
}
initMain(){
	REMOTE_CONTROL_CHANNEL=131793;
	REMOTE_OBJECT_CHANNEL=131794;
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

string lanLinkHeader="LAN_";
string getLanguage(string k){
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

integer isLocked=FALSE;
key lockUser=NULL_KEY;
integer timeoutRunning=FALSE;
integer allowOperate(key user){
    // 先判断禁止操作的情况，锁定状态，计时器状态，触摸者
    // 穿戴模式
    if(REZ_MODE==FALSE){
        if(
            isLocked==TRUE /*锁定状态*/ &&
            timeoutRunning==TRUE /*倒计时状态*/ &&
            user==llGetOwner() /*自己触摸*/
        ){
            return FALSE;
        }
        else if(
            isLocked==TRUE /*锁定状态*/ && 
            lockUser!=llGetOwner() /*非自锁*/ && 
            user==llGetOwner() /*自己触摸*/
        ){
            return -1; // 为了让Escape功能有效，因此返回-1而不是FALSE
        }
    }
    // REZ模式
    else if(REZ_MODE==TRUE){
        if(
            isLocked==TRUE /*锁定状态*/ && 
            timeoutRunning==TRUE /*倒计时状态*/ &&
            user==VICTIM_UUID /*被困者触摸*/
        ){
            return FALSE;
        }
        else if(
            isLocked==TRUE /*锁定状态*/ && 
            lockUser!=VICTIM_UUID /*非自锁*/ && // REZ模式下，自锁也不允许解锁
            user==VICTIM_UUID /*被困者触摸*/
        ){
            return -1; // 为了让Escape功能有效，因此返回-1而不是FALSE
        }
    }
    // 再判断授权关系，主人、信任、黑名单、公开、群组
    if(
        user!=llGetOwner() /*非自己触摸*/ && 
        !checkRelationship(user, "owner") /*非主人*/ && 
        !checkRelationship(user, "trust") /*非信任*/ && 
        !checkRelationship(user, "public") /*非公开*/ && 
        !checkRelationship(user, "group") /*群组模式下，非同群组*/ || 
        checkRelationship(user, "black") /*在黑名单中，优先级高*/
    ){
        return FALSE;
    }
    else{
        return TRUE;
    }
}

// list owner=[];
// list trust=[];
// list black=[];
integer public=1;
integer group=0;
integer hardcore=0;
integer autoLock=0;
list relationshipList=[];
integer checkRelationship(key user, string type){
    integer index=-1;
    if(type=="owner" || type=="trust" || type=="black"){
        index=llListFindList(getRelationship(type), [(string)user]); // 从link_message接收的list被直接转化为了string的list而没转成key，因此要将key转成string再判断。
    }
    else if(type=="public"){
        if(checkRelationship(user, "black")){
            return FALSE;
        }else if(public==TRUE){
            return TRUE;
        }else{
            return FALSE;
        }
    }
    else if(type=="group"){
        if(checkRelationship(user, "black")){
            return FALSE;
        }else if(group==TRUE){
            return llSameGroup(user);
        }else{
            return FALSE;
        }
    }
    if(~index){
        return TRUE;
    }else{
        return FALSE;
    }
}
list getRelationship(string type){
    integer rIndex=llListFindList(relationshipList, [type]);
    if(~rIndex){
        return strSplit(llList2String(relationshipList, rIndex+1), ";");
    }else{
        return [];
    }
}

integer remoteEnabled=TRUE;
setRemoteEnabled(integer bool){
	remoteEnabled=bool;
	llListenRemove(listenHandle);
	llSleep(0.1);
	if(remoteEnabled==TRUE){
		listenHandle=llListen(REMOTE_OBJECT_CHANNEL, "", NULL_KEY, "");
	}
}

string appName="Remote";
string menuName="RemoteMenu";
string menuParent="";
showMenu(string parent, key user){
    menuParent=parent;
    string menuText="This is Remote menu.";
    list menuList=[
        "["+(string)remoteEnabled+"]R:EnableRemote"
    ];
    llMessageLinked(LINK_SET, MENU_MSG_NUM, "MENU.REG.OPEN|"+menuName+"|"+menuText+"|"+llDumpList2String(menuList, ";")+"|"+parent, user);
}


integer REMOTE_CONTROL_CHANNEL=131793;
integer REMOTE_OBJECT_CHANNEL=131794;

integer MENU_MSG_NUM=1000;
integer RLV_MSG_NUM=1001;
integer ACCESS_MSG_NUM=1002;
integer TIMER_MSG_NUM=1004;
integer MAIN_MSG_NUM=9000;
integer REMOTE_MSG_NUM=90003;
integer listenHandle;

integer REZ_MODE=FALSE;
key VICTIM_UUID=NULL_KEY;
key CONTROL_UUID=NULL_KEY;
key CONNECT_UUID=NULL_KEY;

default{
    state_entry(){
        initMain();
		setRemoteEnabled(remoteEnabled);
		if(llGetAttached()){
            REZ_MODE=FALSE;
            VICTIM_UUID=llGetOwner();
        }else{
            REZ_MODE=TRUE;
            VICTIM_UUID=NULL_KEY;
        }
    }
	changed(integer change){
        if(change & CHANGED_OWNER){
            llResetScript();
        }
		if (change & CHANGED_LINK) {
            llSleep(0.1);
            REZ_MODE=TRUE;
			VICTIM_UUID=llAvatarOnSitTarget();
        }
    }
	attach(key user){
		REZ_MODE=FALSE;
		if(user!=NULL_KEY){
			setRemoteEnabled(remoteEnabled);
			VICTIM_UUID=llGetOwner();
		}
	}
	on_rez(integer start_param){
		setRemoteEnabled(remoteEnabled);
		integer attached=llGetAttached();
        if(attached){
            REZ_MODE=FALSE;
            VICTIM_UUID=llGetOwner();
        }else{
            REZ_MODE=TRUE;
            VICTIM_UUID=NULL_KEY;
        }
	}
	object_rez(key id){
        REZ_MODE=TRUE;
        VICTIM_UUID=NULL_KEY;
    }
	listen(integer channel, string name, key id, string message){
		key user=llGetOwnerKey(id);
		if(!allowOperate(user)){
			return;
		}
		if(channel==REMOTE_OBJECT_CHANNEL){
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

			
			if(headerMain=="REMOTE"){
				// Remote Control -> REMOTE.SCAN
				// Object <- REMOTE.REPLY
				if(headerSub=="SCAN"){
					llSay(REMOTE_CONTROL_CHANNEL, "REMOTE.REPLY");
				}
				// Remote Control -> REMOTE.CONNECT | TargetKey | RemoteControlKey
				// Object <- Output connect target
				else if(headerSub=="CONNECT"){
					if((key)msg1 == llGetKey()){
						CONTROL_UUID=id;
						CONNECT_UUID=user;
						if(user!=NULL_KEY){
							llMessageLinked(LINK_SET, MENU_MSG_NUM, "MENU.OUT.TO|You're controlled by %1% 's %2% .%%;"+userInfo(CONNECT_UUID)+";"+userInfo(CONTROL_UUID), VICTIM_UUID);
							llSay(REMOTE_CONTROL_CHANNEL, "REMOTE.CONNECTED");
						}
					}
				}
				// Remote Control -> REMOTE.DISCONNECT
				// Object <- Output connect target
				else if(headerSub=="DISCONNECT"){
					if(CONTROL_UUID == id && CONNECT_UUID == user){
						CONTROL_UUID=NULL_KEY;
						CONNECT_UUID=NULL_KEY;
						llSay(REMOTE_CONTROL_CHANNEL, "REMOTE.DISCONNECTED");
					}
				}
				// Remote Control -> REMOTE.MENU
				// Object <- mainMenu
				else if(headerSub=="MENU"){
					if(CONTROL_UUID == id && CONNECT_UUID == user){
						llMessageLinked(LINK_THIS, MAIN_MSG_NUM, "MAIN.MENU", user);
					}
				}
				// Remote Control -> REMOTE.FEATURE | FEATER_MSG_NUM | FEATURE.NAME | FeaterParams1 | FeatureParams2 | ...
				// Object <- Features
				else if(headerSub=="FEATURE"){
					if(CONTROL_UUID == id && CONNECT_UUID == user){
						integer FEATER_MSG_NUM=(integer)msg1;
						llMessageLinked(LINK_THIS, FEATER_MSG_NUM, llDumpList2String(llList2List(msgList, 2, -1), "|"), user);
					}
				}
			}
		}
	}
    link_message(integer sender_num, integer num, string msg, key user){
        if(num!=MAIN_MSG_NUM && num!=MENU_MSG_NUM && num!=RLV_MSG_NUM && num!=ACCESS_MSG_NUM && num!=REMOTE_MSG_NUM){
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

        if(headerMain=="REMOTE" && headerSub!="EXEC"){
			string result="";
			if(result!=""){
                llMessageLinked(LINK_THIS, REMOTE_MSG_NUM, "REMOTE.EXEC|"+msgHeader+"|"+result, user);
            }
        }
        else if(headerMain=="MAIN" && headerSub=="INIT"){
            llMessageLinked(LINK_THIS, MAIN_MSG_NUM, "FEATURE.REG|"+appName, user);
        }
        else if(headerMain=="MENU" && headerSub=="ACTIVE"){
            // MENU.ACTIVE | MenuName | MenuButton
            if(msg1=="appMenu" && msg2==appName){
                showMenu(msg1,user);
            }
			else if(msg1==menuName && msg2!=""){
				if(msg2=="R:EnableRemote"){
					remoteEnabled=!remoteEnabled;
					setRemoteEnabled(remoteEnabled);
					showMenu(menuParent,user);
				}
			}
        }
		else if(num==RLV_MSG_NUM){
            list rlvCmdList=strSplit(msg, "|");
            string rlvCmdStr=llList2String(rlvCmdList, 0);
            string rlvCmdName=llList2String(rlvCmdList, 1);
            string rlvCmdText=llList2String(rlvCmdList, 2);
            list rlvCmdData=strSplit(llList2String(rlvCmdList, 2), ";");

            if(rlvCmdStr=="RLV.EXEC"){
                if(rlvCmdName=="RLV.GET.LOCK" || rlvCmdName=="RLV.LOCK"){
                    isLocked=llList2Integer(rlvCmdData, 0);
                    lockUser=llList2Key(rlvCmdData, 1);
                }
            }
        }
		else if(num==ACCESS_MSG_NUM){
            // 权限功能监听
            list accessCmdList=strSplit(msg, "|");
            string accessCmdStr=llList2String(accessCmdList, 0);
            string accessName=llList2String(accessCmdList, 1);

            if(accessCmdStr=="ACCESS.NOTIFY"){
                if(accessName=="OWNER" || accessName=="TRUST" || accessName=="BLACK"){
                    integer accessIndex=llListFindList(relationshipList, [llToLower(accessName)]);
                    if(~accessIndex){
                        relationshipList=llListReplaceList(relationshipList, [llList2String(accessCmdList, 2)], accessIndex+1, accessIndex+1);
                    }else{
                        relationshipList+=[llToLower(accessName), llList2String(accessCmdList, 2)]; // ["owner", "uuid1;uuid2;...", "trust", "uuid1;uuid2;...", "black", "uuid1;uuid2;..."]
                    }
                }
                // if(accessName=="OWNER"){ // ACCESS.NOTIFY | OWNER | UUID1; UUID2; UUID3; ...
                //     owner=accessData; // 接收到并写入的用户列表为string，判断时要将key转换为string再判断
                // }
                // if(accessName=="TRUST"){ // ACCESS.NOTIFY | TRUST | UUID1; UUID2; UUID3; ...
                //     trust=accessData;
                // }
                // if(accessName=="BLACK"){ // ACCESS.NOTIFY | BLACK | UUID1; UUID2; UUID3; ...
                //     black=accessData;
                // }
                else if(accessName=="MODE"){ // ACCESS.NOTIFY | MODE | PUBLIC; GROUP; HARDCORE
                    list accessData=strSplit(llList2String(accessCmdList, 2), ";");
                    public=llList2Integer(accessData, 0);
                    group=llList2Integer(accessData, 1);
                    hardcore=llList2Integer(accessData, 2);
                    autoLock=llList2Integer(accessData, 3);
                }
                // llOwnerSay("Access updated. Owner: "+list2Data(owner)+" Trust: "+list2Data(trust)+" Black: "+list2Data(black)+" Public: "+(string)public+" Group: "+(string)group+" Hardcore: "+(string)hardcore);
            }else if(accessCmdStr=="ACCESS.EXEC"){
                list accessData=strSplit(llList2String(accessCmdList, 2), ";");
                if(accessName=="ACCESS.RESET" && llList2Integer(accessData, 0)==TRUE){ // Access重置（逃跑）时，解锁
                    relationshipList=[];
                }
            }
        }
		else if(num==TIMER_MSG_NUM){
			if (includes(msg, "TIMER.TIMEOUT")) { // 接收计时器系统回调
                timeoutRunning=FALSE;
            }
            else if (includes(msg, "TIMER.RUNNING")) { // 接收计时器系统回调
                timeoutRunning=TRUE;
            }
            else if (includes(msg, "TIMER.SETRUNNING")) { // 接收计时器系统回调
                timeoutRunning=FALSE;
            }
        }
    }
}
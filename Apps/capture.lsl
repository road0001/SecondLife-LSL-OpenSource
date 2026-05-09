initMain(){
	sitAutoLock=FALSE;
	sitAutoTrap=FALSE;
	scanDistance=96.0;
	standalone=FALSE;
	showText=TRUE;
	captureTimeout=10;
	maxSensor=18;
}
/*CONFIG END*/

/*
Name: Capture
Author: JMRY
Description: A capture feature for restraint items.

***更新记录***
- 1.0 20260509
	- 完成主要功能。
***更新记录***
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

integer isLocked=FALSE;
setLock(integer lock, key user){
	if(lock<0){
        if(!isLocked){
            isLocked=TRUE;
        }else{
            isLocked=FALSE;
        }
    }else{
        isLocked=lock;
    }
	// llMessageLinked(LINK_SET, RLV_MSG_NUM, "RLV.LOCK|"+(string)isLocked, user);
	if(isLocked==TRUE){
        lockUser=user;
    }else{
        lockUser=NULL_KEY;
    }
	applyCaptureText(VICTIM_UUID!=NULL_KEY);
}


integer sitAutoLock=FALSE;
integer sitAutoTrap=FALSE;
integer showText=TRUE;
float scanDistance=96;
triggerCapture(key victim, key originUser){
	captureByUser=originUser;
	llMessageLinked(LINK_SET, RLV_MSG_NUM, "RLV.CAPTURE|"+(string)VICTIM_UUID+"|1", NULL_KEY);
	llSetTimerEvent(captureTimeout);
	// applyCaptureStatus(TRUE);
	// 后续操作由changed承接处理
}

list owner=[];
applyCaptureStatus(integer captured){
	if(captured==TRUE){
		if(sitAutoLock==TRUE){
			// 自动上锁时，APPLY.ALL交给LockConnect完成
			if(captureByUser!=NULL_KEY){ // 主动抓人时的情况
				setLock(TRUE, captureByUser);
				captureByUser=NULL_KEY;
			}else if(llGetListLength(owner)>0){ // 被捕且主人列表不为空的情况
				setLock(TRUE, llList2Key(owner, 0));
			}else{ // 主人列表为空的情况
				setLock(TRUE, llGetOwner());
			}
		}else{
			setLock(FALSE, NULL_KEY);
			llMessageLinked(LINK_SET, RLV_MSG_NUM, "RLV.APPLY.ALL", NULL_KEY);
		}
		// 显示文字部分
	}else{
		setLock(FALSE, NULL_KEY);
		llSleep(1.0);
	}
}

applyCaptureText(integer captured){
	regMainCapture(captured);
	if(captured==TRUE){
		if(showText==TRUE && VICTIM_UUID!=NULL_KEY){
			llMessageLinked(LINK_SET, TEXT_MSG_NUM, "TEXT.SET|Victim|"+llGetDisplayName(VICTIM_UUID)+" ("+llGetUsername(VICTIM_UUID)+")|"+(string)showText+"|TOP", NULL_KEY);
			llMessageLinked(LINK_SET, TEXT_MSG_NUM, "TEXT.SET|Locked|%b1%Locked%%;"+(string)isLocked+"|1|Victim", NULL_KEY);
			if(lockUser!=NULL_KEY){
				llMessageLinked(LINK_SET, TEXT_MSG_NUM, "TEXT.SET|LockUser|%1%%%;"+llGetDisplayName(lockUser)+" ("+llGetUsername(lockUser)+"|1|Locked", NULL_KEY);
			}else{
				llMessageLinked(LINK_SET, TEXT_MSG_NUM, "TEXT.REM|LockUser", NULL_KEY);
			}
		}else{
			llMessageLinked(LINK_SET, TEXT_MSG_NUM, "TEXT.REM|Victim", NULL_KEY);
			llMessageLinked(LINK_SET, TEXT_MSG_NUM, "TEXT.REM|Locked", NULL_KEY);
			llMessageLinked(LINK_SET, TEXT_MSG_NUM, "TEXT.REM|LockUser", NULL_KEY);
		}
	}else{
		llMessageLinked(LINK_SET, TEXT_MSG_NUM, "TEXT.REM|Victim", NULL_KEY);
		llMessageLinked(LINK_SET, TEXT_MSG_NUM, "TEXT.REM|Locked", NULL_KEY);
		llMessageLinked(LINK_SET, TEXT_MSG_NUM, "TEXT.REM|LockUser", NULL_KEY);
	}
}

regMainCapture(integer captured){
	if(captured==TRUE){
		llMessageLinked(LINK_SET, MAIN_MSG_NUM, "FEATURE.REM|"+appName+"|Lock|mainMenu", NULL_KEY);
		llMessageLinked(LINK_SET, MAIN_MSG_NUM, "FEATURE.REG|"+appNameUnsit+"|Lock|mainMenu", NULL_KEY);
	}else{
		llMessageLinked(LINK_SET, MAIN_MSG_NUM, "FEATURE.REM|"+appNameUnsit+"|Lock|mainMenu", NULL_KEY);
		llMessageLinked(LINK_SET, MAIN_MSG_NUM, "FEATURE.REG|"+appName+"|Lock|mainMenu", NULL_KEY);
	}
}


float captureTimeout=10.0;
list sensorUserList=[];
integer maxSensor=18;

key curMenuUser=NULL_KEY;
showSensorMenu(string parent, key user){
	string menuText="Select user to %1%.%%;"+appName;
	list menuList=[];
	integer i;
	for(i=0; i<llGetListLength(sensorUserList); i++){
		key uk=llList2Key(sensorUserList, i);
		if(uk){
			menuList+=[llGetSubString((string)(i+1) + ". " + llGetUsername(uk), 0, 23)];
		}
	}
	llMessageLinked(LINK_SET, MENU_MSG_NUM, "MENU.REG.OPEN.RESET|CaptureSensorMenu|"+menuText+"|"+llDumpList2String(menuList, ";")+"|"+parent, user);
}

string appName="Capture";
string appNameUnsit="Unsit";
string menuName="CaptureMenu";
string menuParent="";
showMenu(string parent, key user){
    menuParent=parent;
    string menuText="This is "+appName+" menu.\nScan distance: %1%%%;"+(string)scanDistance;
    list menuList=[
		"["+(string)sitAutoLock+"]C:AutoLock", "["+(string)sitAutoTrap+"]C:AutoTrap", "["+(string)showText+"]C:ShowText",
		"C:ScanDistance"
	];
    llMessageLinked(LINK_SET, MENU_MSG_NUM, "MENU.REG.OPEN|"+menuName+"|"+menuText+"|"+llDumpList2String(menuList, ";")+"|"+parent, user);
}


integer MENU_MSG_NUM=1000;
integer RLV_MSG_NUM=1001;
integer ACCESS_MSG_NUM=1002;
integer TEXT_MSG_NUM=1008;
integer MAIN_MSG_NUM=9000;
integer CAPTURE_MSG_NUM=90006;

integer REZ_MODE=FALSE;
key VICTIM_UUID=NULL_KEY;
key captureByUser=NULL_KEY;
key lockUser=NULL_KEY;

integer standalone=FALSE;

default{
	state_entry() {
		initMain();
		if(llGetAttached()){
            REZ_MODE=FALSE;
        }else{
            REZ_MODE=TRUE;
        }
	}
	changed(integer change){
        if(change & CHANGED_OWNER){ // 物品易主时，重置脚本
            llResetScript();
        }
        if (change & CHANGED_LINK) {
            llSleep(0.1);
            REZ_MODE=TRUE;
			VICTIM_UUID=llAvatarOnSitTarget();
			applyCaptureStatus(VICTIM_UUID!=NULL_KEY);
        }
    }
	attach(key user){
        REZ_MODE=FALSE;
        VICTIM_UUID=NULL_KEY;
    }
	on_rez(integer start_param){
        // 登录、穿戴时也会触发on_rez，并且比attach更早触发。有时候登录时不触发attach，因此将attach的部分也添加到这里。
        integer attached=llGetAttached();
		VICTIM_UUID=NULL_KEY;
        if(attached){
            REZ_MODE=FALSE;
        }else{
            REZ_MODE=TRUE;
        }
    }
	timer(){
		// 抓取玩家超时
		if(llAvatarOnSitTarget()==NULL_KEY){
			VICTIM_UUID=NULL_KEY;
			captureByUser=NULL_KEY;
			applyCaptureStatus(FALSE);
		}
	}
	touch_start(integer num_detected){
		if(standalone==TRUE){
			showMenu("", llDetectedKey(0));
		}
	}
	collision_start(integer num){
        if(REZ_MODE==TRUE && sitAutoTrap==TRUE && VICTIM_UUID == NULL_KEY){
            triggerCapture(llDetectedKey(0), NULL_KEY);
        }
    }
	link_message(integer sender_num, integer num, string msg, key user){
		if(num!=MAIN_MSG_NUM && num!=MENU_MSG_NUM && num!=CAPTURE_MSG_NUM && num!=RLV_MSG_NUM){
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

		if(headerMain=="MAIN" && headerSub=="INIT"){
			standalone=FALSE;
			if(REZ_MODE==TRUE){
				regMainCapture(FALSE);
				llMessageLinked(LINK_SET, MAIN_MSG_NUM, "FEATURE.REG|"+appName+"||settingMenu", user);
			}
		}
		else if(headerMain=="MENU" && headerSub=="ACTIVE"){
			// MENU.ACTIVE | MenuName | MenuButton
            if(msg1=="mainMenu" && msg2==appName){
				curMenuUser=user;
                llSensor("", NULL_KEY, AGENT, scanDistance, PI);
            }
			else if(msg1=="CaptureSensorMenu" && msg2!=""){
				list buList=llParseStringKeepNulls(msg2,[". "],[""]);
				integer buIndex=llList2Integer(buList,0);
				key buUser=llList2Key(sensorUserList, ((integer)(buIndex-1)));
				if(buUser!=NULL_KEY){
					triggerCapture(buUser, user);
				}
				sensorUserList=[];
			}
			else if(msg1==menuName && msg2!=""){
				if(msg2=="C:AutoLock"){
					sitAutoLock=!sitAutoLock;
					showMenu(menuParent,user);
				}
				else if(msg2=="C:AutoTrap"){
					sitAutoTrap=!sitAutoTrap;
					showMenu(menuParent,user);
				}
				else if(msg2=="C:ShowText"){
					showText=!showText;
					showMenu(menuParent,user);
				}
				else if(msg2=="C:scanDistance"){
					llMessageLinked(LINK_SET, MENU_MSG_NUM, "MENU.INPUT|CaptureInput_"+msg2+"|Input %1% (0.0~100.0), blank to return (Current: %2%):%%;"+msg2+";"+(string)scanDistance, user);
				}
			}
			else if(includes(msg1, "CaptureInput")){
				string punishInputType=llGetSubString(msg1, llStringLength("CaptureInput_"), -1);
				if(punishInputType=="C:scanDistance"){
					if(msg2!=""){
						scanDistance=(float)msg2;
						if(scanDistance<0) scanDistance=0;
						if(scanDistance>100) scanDistance=100;
					}
				}
				showMenu(menuParent,user);
			}
		}
		else if(num==RLV_MSG_NUM){
            if(msgHeader=="RLV.EXEC"){
                if(msg1=="RLV.GET.LOCK" || msg1=="RLV.LOCK"){
                    isLocked=(integer)msg2;
                    lockUser=(key)msg3;
                    applyCaptureText(VICTIM_UUID!=NULL_KEY);
					regMainCapture(VICTIM_UUID!=NULL_KEY);
                }
            }
        }
		else if(num==ACCESS_MSG_NUM){
            // 权限功能监听
            if(msgHeader=="ACCESS.NOTIFY"){
                if(msg1=="OWNER"){
                    owner=strSplit(msg2, ";");
                }
            }else if(msgHeader=="ACCESS.EXEC"){
                if(msg1=="ACCESS.RESET" && msg2=="1"){ // Access重置（逃跑）时，解锁
                    owner=[];
                    setLock(FALSE, NULL_KEY);
                }
            }
        }
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
        showSensorMenu("mainMenu", curMenuUser);
    }
    no_sensor(){
        sensorUserList=[];
        if(REZ_MODE==FALSE){
            sensorUserList+=[llGetOwner()]; // 穿在身上时，添加自己
        }
        showSensorMenu("mainMenu", curMenuUser);
    }
}
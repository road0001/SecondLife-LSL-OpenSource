initMain(){
	lockSound="lock";
	unlockSound="unlock";
	touchSound="touch";
	menuSound="click";
	touchSoundEnabled=TRUE;
	menuSoundEnabled=TRUE;
	lockSoundEnabled=TRUE;
	soundVolume=1.0;
	standalone=FALSE;
	soundActive=FALSE;
}
/*CONFIG END*/

/*
Name: Sound
Author: JMRY
Description: A sound effects for restraint items.

***更新记录***
- 1.0.1 20260514
	- 加入声音初始化前禁用的功能。

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

string lockSound;
string unlockSound;
string touchSound;
string menuSound;

integer touchSoundEnabled=FALSE;
integer menuSoundEnabled=FALSE;
integer lockSoundEnabled=FALSE;

float soundVolume=1.0;

integer checkSoundAvailable(string name){
	if(name!="" && (llGetInventoryType(name)==INVENTORY_SOUND || llStringLength(name)==36)){
		return TRUE;
	}else{
		return FALSE;
	}
}

playSound(string name, float volume, integer bool){
	if(!bool || !soundActive){
		return;
	}
	if(checkSoundAvailable(name)){
		llPlaySound(name, volume);
	}
}

string appName="Sound";
string menuName="SoundMenu";
string menuParent="";
showMenu(string parent, key user){
    menuParent=parent;
    string menuText="This is "+appName+" menu.";
    list menuList=[];
	if(checkSoundAvailable(touchSound)==TRUE){
		menuList+="["+(string)touchSoundEnabled+"]S:TouchSound";
	}
	if(checkSoundAvailable(menuSound)==TRUE){
		menuList+="["+(string)menuSoundEnabled+"]S:MenuSound";
	}
	if(checkSoundAvailable(lockSound)==TRUE || checkSoundAvailable(unlockSound)==TRUE){
		menuList+="["+(string)lockSoundEnabled+"]S:LockSound";
	}
    llMessageLinked(LINK_SET, MENU_MSG_NUM, "MENU.REG.OPEN|"+menuName+"|"+menuText+"|"+llDumpList2String(menuList, ";")+"|"+parent, user);
}


integer MENU_MSG_NUM=1000;
integer RLV_MSG_NUM=1001;
integer MAIN_MSG_NUM=9000;
integer SOUND_MSG_NUM=90005;
integer standalone=FALSE;
integer soundActive=FALSE;

default{
	state_entry(){
		initMain();
	}
	changed(integer change){
        if(change & CHANGED_OWNER){ // 物品易主时，重置脚本
            llResetScript();
        }
    }
	touch_start(integer num_detected){
		playSound(touchSound, soundVolume, touchSoundEnabled);
		if(standalone==TRUE){
			showMenu("", llDetectedKey(0));
		}
	}
	link_message(integer sender_num, integer num, string msg, key user){
		if(num!=MAIN_MSG_NUM && num!=MENU_MSG_NUM && num!=SOUND_MSG_NUM && num!=RLV_MSG_NUM){
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
			soundActive=TRUE;
			if(checkSoundAvailable(touchSound) || checkSoundAvailable(lockSound) || checkSoundAvailable(unlockSound) || checkSoundAvailable(menuSound)){
				llMessageLinked(LINK_SET, MAIN_MSG_NUM, "FEATURE.REG|"+appName+"||settingMenu", user);
			}
		}
		else if(headerMain=="MENU" && headerSub=="ACTIVE"){
			playSound(menuSound, soundVolume, menuSoundEnabled);
			// MENU.ACTIVE | MenuName | MenuButton
            if(msg1=="settingMenu" && msg2==appName){
                showMenu(msg1,user);
            }
			else if(msg1==menuName && msg2!=""){
				if(msg2=="S:TouchSound"){
					touchSoundEnabled=!touchSoundEnabled;
					showMenu(menuParent,user);
				}
				else if(msg2=="S:MenuSound"){
					menuSoundEnabled=!menuSoundEnabled;
					showMenu(menuParent,user);
				}
				else if(msg2=="S:LockSound"){
					lockSoundEnabled=!lockSoundEnabled;
					showMenu(menuParent,user);
				}
			}
		}
		else if(headerMain=="RLV" && headerSub=="LOCK"){
			if(msg1=="1"){
				playSound(lockSound, soundVolume, lockSoundEnabled);
			}else if(msg1=="0"){
				playSound(unlockSound, soundVolume, lockSoundEnabled);
			}
		}
	}
}
initMain(){
	lockSound="lock";
	unlockSound="unlock";
	touchSound="touch";
	menuSound="click";
	walkSoundList=[];
	walkSoundCooldown=2.0;
	touchSoundEnabled=TRUE;
	menuSoundEnabled=TRUE;
	lockSoundEnabled=TRUE;
	walkSoundEnabled=TRUE;
	soundVolume=1.0;
	soundVolume_Walk=1.0;
	standalone=FALSE;
	soundActive=FALSE;
	setWalkSound(llList2String(walkSoundList, 0));
}
/*CONFIG END*/

/*
Name: Sound
Author: JMRY
Description: A sound effects for restraint items.

***更新记录***
- 1.0.4 20260806
	- 优化行走声音权限申请逻辑，REZ模式时不申请权限。

- 1.0.3 20260721
	- 优化行走声音列表逻辑算法。
	- 调整菜单排列。

- 1.0.2 20260720
	- 加入声音控制接口。
	- 加入行走声音功能。
	- 加入主动播放声音功能。

- 1.0.1 20260514
	- 加入声音初始化前禁用的功能。
	- 加入音量设置功能。

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
integer walkSoundEnabled=FALSE;

float soundVolume=1.0;
float soundVolume_Walk=1.0;

integer checkSoundAvailable(string name){
	if(name!="" && (llGetInventoryType(name)==INVENTORY_SOUND || (llStringLength(name)==36 && (key)name!=NULL_KEY))){
		return TRUE;
	}else{
		return FALSE;
	}
}

playSound(string name, float volume, integer bool, integer trigger){
	if(!bool || !soundActive){
		return;
	}
	name=translateSound(name);
	if(checkSoundAvailable(name)){
		if(trigger==0){
			llPlaySound(name, volume);
		}else if(trigger==1){
			llTriggerSound(name, volume);
		}else if(trigger==2){
			llLoopSound(name, volume);
		}
	}
}

float walkSoundCooldown=1.0;
float walkSoundLastTime=0;
playSound_Walk(){
	if(llGetTime() - walkSoundLastTime >= walkSoundCooldown){
		playSound(walkSound, soundVolume_Walk, walkSoundEnabled, FALSE);
		walkSoundLastTime=llGetTime();
	}
}

string walkSound;
list walkSoundList;
integer walkSoundDataLength=3;
setWalkSound(string name){
	integer index=llListFindList(walkSoundList, [name]);
	if(~index){
		walkSound=llList2String(walkSoundList, index);
		walkSoundCooldown=llList2Float(walkSoundList, index+2);
	}else{
		walkSound="";
		walkSoundCooldown=0;
	}
	walkSoundLastTime=0;
}

string translateSound(string name){
	integer index=llListFindList(walkSoundList, [name]);
	if(~index){
		string walkSoundFileName=llList2String(walkSoundList, index+1);
		if(walkSoundFileName==""){
			return name;
		}else{
			return walkSoundFileName;
		}
	}else{
		return name;
	}
}

string appName="Sound";
string menuName="SoundMenu";
string menuParent="";
showMenu(string type, string parent, key user){
	if(type=="Main"){
		menuParent=parent;
		string menuText="This is %1% menu.\nVolume: %2%\nWalk sound volume: %3%%%;"+appName+";"+(string)soundVolume+";"+(string)soundVolume_Walk;
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
		menuList+=["S:Volume"];

		if(llGetListLength(walkSoundList) > 0){
			menuList+="["+(string)walkSoundEnabled+"]S:WalkSound";
			menuList+="S:SetWalkSound";
			menuList+="S:VolumeWalkSound";
		}

		llMessageLinked(LINK_SET, MENU_MSG_NUM, "MENU.REG.OPEN|"+menuName+"|"+menuText+"|"+llDumpList2String(menuList, ";")+"|"+parent, user);
	}
	else if(type=="Walk"){
		string menuText="This is %1% menu.\nCurrent: %2%%%;"+"S:SetWalkSound"+";"+"\\NL"+walkSound;
		list menuList=[];
		integer i;
		for(i=0; i<llGetListLength(walkSoundList); i+=walkSoundDataLength){ // 处理声音列表，加\\NL标记，禁止匹配语言
			menuList+="\\NL"+llList2String(walkSoundList, i);
		}
		llMessageLinked(LINK_SET, MENU_MSG_NUM, "MENU.REG.OPEN|"+menuName+"_"+type+"|"+menuText+"|"+llDumpList2String(menuList, ";")+"|"+parent, user);
	}
}


integer MENU_MSG_NUM=1000;
integer RLV_MSG_NUM=1001;
integer MAIN_MSG_NUM=9000;
integer SOUND_MSG_NUM=90005;
integer standalone=FALSE;
integer soundActive=FALSE;
integer REZ_MODE=FALSE;

default{
	state_entry(){
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
    }
	attach(key user){
        REZ_MODE=FALSE;
    }
	object_rez(key user){
        if(llGetAttached()){
            REZ_MODE=FALSE;
        }else{
            REZ_MODE=TRUE;
        }
    }
	on_rez(integer start_param) {
		if(REZ_MODE==FALSE){
			if(walkSoundEnabled){
				llRequestPermissions(llGetOwner(),PERMISSION_TAKE_CONTROLS);
			}else{
				llReleaseControls();
			}
		}
	}
	touch_start(integer num_detected){
		playSound(touchSound, soundVolume, touchSoundEnabled, FALSE);
		if(standalone==TRUE){
			showMenu("Main", "", llDetectedKey(0));
		}
	}
	run_time_permissions(integer perm) {
        if(perm & PERMISSION_TAKE_CONTROLS){
			llTakeControls(CONTROL_FWD | CONTROL_BACK | CONTROL_LEFT | CONTROL_RIGHT | CONTROL_UP | CONTROL_DOWN | CONTROL_ROT_LEFT | CONTROL_ROT_RIGHT, TRUE, TRUE);
			llMessageLinked(LINK_SET, SOUND_MSG_NUM, "SOUND.EXEC|SOUND.WALK.RECOVER|1", NULL_KEY);
        }
    }
	control(key id, integer held, integer change){
        if(!walkSoundEnabled){
			return;
		}
		// 按下按键时，触发声音
		if(change & (CONTROL_LEFT | CONTROL_RIGHT | CONTROL_DOWN | CONTROL_UP | CONTROL_FWD | CONTROL_BACK)){
			playSound_Walk();
		}
		// 按住按键并奔跑时，触发声音
		if(held & (CONTROL_FWD | CONTROL_BACK)){
			playSound_Walk();
		}
		// 按住按键并奔跑时，触发声音
		// if(
		// 	(held & (CONTROL_FWD | CONTROL_BACK)) && 
		// 	(llGetAgentInfo(llGetOwner()) & AGENT_ALWAYS_RUN)
		// ){
		// 	playSound_Walk();
		// }
    }
	collision_start(integer num) {
        if(walkSoundEnabled){
			playSound_Walk();
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
		string headerExt2=llList2String(msgHeaderGroup, 3);

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
			if(walkSoundEnabled && !REZ_MODE){
				llRequestPermissions(llGetOwner(),PERMISSION_TAKE_CONTROLS);
			}
		}
		else if(headerMain=="MENU" && headerSub=="ACTIVE"){
			playSound(menuSound, soundVolume, menuSoundEnabled, FALSE);
			// MENU.ACTIVE | MenuName | MenuButton
            if(msg1=="settingMenu" && msg2==appName){
                showMenu("Main", msg1,user);
            }
			// 主菜单
			else if(msg1==menuName && msg2!=""){
				if(msg2=="S:TouchSound"){
					touchSoundEnabled=!touchSoundEnabled;
					showMenu("Main", menuParent,user);
				}
				else if(msg2=="S:MenuSound"){
					menuSoundEnabled=!menuSoundEnabled;
					showMenu("Main", menuParent,user);
				}
				else if(msg2=="S:LockSound"){
					lockSoundEnabled=!lockSoundEnabled;
					showMenu("Main", menuParent,user);
				}
				else if(msg2=="S:WalkSound"){
					walkSoundEnabled=!walkSoundEnabled;
					if(REZ_MODE==FALSE){
						if(walkSoundEnabled){
							llRequestPermissions(llGetOwner(),PERMISSION_TAKE_CONTROLS);
						}else{
							llReleaseControls();
						}
					}
					showMenu("Main", menuParent,user);
				}
				else if(msg2=="S:SetWalkSound"){
					showMenu("Walk",menuName,user);
				}
				else if(msg2=="S:Volume"){
					llMessageLinked(LINK_SET, MENU_MSG_NUM, "MENU.INPUT|SoundInput_"+msg2+"|Input %1% (0~1), blank to return (Current: %2%):%%;"+msg2+";"+(string)soundVolume, user);
				}
				else if(msg2=="S:VolumeWalkSound"){
					llMessageLinked(LINK_SET, MENU_MSG_NUM, "MENU.INPUT|SoundInput_"+msg2+"|Input %1% (0~1), blank to return (Current: %2%):%%;"+msg2+";"+(string)soundVolume_Walk, user);
				}
			}
			// 行走声音菜单
			else if(msg1==menuName+"_Walk" && msg2!=""){
				setWalkSound(msg2);
				showMenu("Walk",menuName,user);
			}
			// 修改音量输入框
			else if(includes(msg1, "SoundInput")){
				string inputType=llGetSubString(msg1, llStringLength("SoundInput_"), -1);
				if(inputType=="S:Volume"){
					if(msg2!=""){
						soundVolume=(float)msg2;
						if(soundVolume<0) soundVolume=0;
						if(soundVolume>1) soundVolume=1;
					}
				}
				else if(inputType=="S:VolumeWalkSound"){
					if(msg2!=""){
						soundVolume_Walk=(float)msg2;
						if(soundVolume_Walk<0) soundVolume_Walk=0;
						if(soundVolume_Walk>1) soundVolume_Walk=1;
					}
				}
				showMenu("Main", menuParent,user);
			}
		}
		else if(headerMain=="RLV" && headerSub=="LOCK"){
			if(msg1=="1"){
				playSound(lockSound, soundVolume, lockSoundEnabled, FALSE);
			}else if(msg1=="0"){
				playSound(unlockSound, soundVolume, lockSoundEnabled, FALSE);
			}
		}
		else if(headerMain=="SOUND" && headerSub!="EXEC"){
			string result="";
			/*
			SOUND.PLAY | soundName | soundVolume | soundEnabled | soundTrigger
			立即播放声音。
			*/
			if(headerSub=="PLAY"){
				if(msg2==""){
					msg2=(string)soundVolume;
				}
				if(msg3==""){
					msg3="1";
				}
				if(msg4==""){
					msg4="0";
				}
				playSound(msg1, (float)msg2, (integer)msg3, (integer)msg4);
				result="1";
			}
			/*
			SOUND.STOP
			停止播放声音。
			*/
			else if(headerSub=="STOP"){
				llStopSound();
				result="1";
			}
			else if(headerSub=="GET"){
				/*
				SOUND.GET.VOLUME
				获取当前音量
				*/
				if(headerExt=="VOLUME"){
					result=(string)soundVolume;
				}
			}
			else if(headerSub=="SET"){
				/*
				SOUND.SET.VOLUME
				设置声音音量
				*/
				if(headerExt=="VOLUME"){
					soundVolume=(float)msg1;
					result=(string)soundVolume;
					llAdjustSoundVolume(soundVolume);
				}
			}
			else if(headerSub=="WALK"){
				/*
				SOUND.WALK.RECOVER
				当其他脚本申请PERMISSION_TAKE_CONTROLS权限时，此处的权限会被覆盖。因此其他脚本处理完，需要主动通知Sound脚本重新申请权限。
				*/
				if(headerExt=="RECOVER"){
					if(REZ_MODE==FALSE){
						llRequestPermissions(llGetOwner(), PERMISSION_TAKE_CONTROLS);
					}
				}
				/*
				SOUND.WALK.PLAY
				主动播放行走声音。此功能仍受到行走声音CD限制。
				*/
				else if(headerExt=="PLAY"){
					playSound_Walk();
				}
				else if(headerExt=="GET"){
					/*
					SOUND.WALK.GET.VOLUME
					调整行走声音音量。
					*/
					if(headerExt2=="VOLUME"){
						result=(string)soundVolume_Walk;
					}
				}
				else if(headerExt=="SET"){
					/*
					SOUND.WALK.SET.VOLUME
					调整行走声音音量。
					*/
					if(headerExt2=="VOLUME"){
						soundVolume_Walk=(float)msg1;
						result=(string)soundVolume_Walk;
						llAdjustSoundVolume(soundVolume);
					}
				}
			}
			else if(headerSub=="MENU"){
				showMenu("Main", msg1, user);
			}
			if(result!=""){
                llMessageLinked(LINK_SET, SOUND_MSG_NUM, "SOUND.EXEC|"+msgHeader+"|"+result, user);
            }
		}
	}
}
initMain(){
	standalone=FALSE;
	punishEnabledBanned=TRUE;
	punishEnabledNeeded=TRUE;
	punishEnabledOthers=FALSE;
	punishEnabledOutput=TRUE;
	punishArousalEnabled=TRUE;
	punishArousalValue=1;
	punishAnim=[];
	blackoutAnim=[];
	punishSounds=[];
	punishFrames=[];
	punishSoundsVolume=1.0;
	punishTimeMin=5;
	punishTimeMax=10;
	punishBlackoutTimeMin=30;
	punishBlackoutTimeMax=60;
	punishBlackoutTimeLimit=240;
	punishFrameRate=0.2;
	punishRLV="camdistmax:5=n,setsphere=n,setsphere_tween:1=force,setsphere_distmin:0.5=force,setsphere_distmax:1=force,setsphere_valuemin:0=force,shownames_sec=n,shownametags=n,shownearby=n,showhovertextworld=n,touchworld=n,alwaysrun=n,temprun=n,sendchat=n,chatshout=n,chatnormal=n,chatwhisper=n,recvchat=n,showworldmap=n,showminimap=n,showloc=n";
	blackoutRLV=punishRLV;
	punishBannedWords=[];
	punishNeededWords=[];
	punishOthersWords=[];
	particleParams=[
		PSYS_PART_FLAGS, PSYS_PART_EMISSIVE_MASK | PSYS_PART_FOLLOW_SRC_MASK,
		PSYS_SRC_PATTERN, PSYS_SRC_PATTERN_DROP,
		PSYS_PART_START_SCALE, <0.05, 0.05, 0.0>,
		PSYS_PART_START_GLOW, 0.1,
		PSYS_PART_MAX_AGE, 1.0,
		PSYS_SRC_BURST_RATE, 0.0,
		PSYS_SRC_BURST_PART_COUNT, 1
	];
	particleLinkName="";
}
/*CONFIG END*/

/*
Name: Punish
Author: JMRY
Description: A punish system for restraint items.
Require: menu, rlv (optional), language (optional), ProjectArousal (optional)

***更新记录***
- 1.0.1 20260501
	- 加入手动打开菜单功能。
	- 优化执行流程的逻辑。

- 1.0 20260429
    - 完成主要功能。
***更新记录***
*/
string userInfo(key user){
    return "secondlife:///app/agent/"+(string)user+"/inspect";
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

list getLinksByName(string name){
	if(name==""){
		return [];
	}
    name=llToLower(llStringTrim(name,STRING_TRIM));
    list linkList=[];
    integer linkCount=llGetNumberOfPrims();
    integer i;
    for (i=-1; i<=linkCount;++i){
        string curPrimName = llToLower(llStringTrim(llList2String(llGetLinkPrimitiveParams(i,[PRIM_NAME]),0),STRING_TRIM));
        if(curPrimName==name){
            linkList+=[i];
        }
    }
    return linkList;
}

integer randomInt(integer min, integer max) {
    if (min > max) return min; // 或交换
    return min + (integer)llFrand(max - min + 1);
}

integer RLVRS=-1812221819; // default relay channel
executeRLV(string rlvStr, integer bool){
	rlvStr=llReplaceSubString(rlvStr,"@","", 0);
    if(bool==FALSE){
        rlvStr=llReplaceSubString(llReplaceSubString(llReplaceSubString(rlvStr,"=n","=y", 0),"=add","=rem", 0),"=force","=rem", 0);
    }
    if(rlvStr!=""){
        if(REZ_MODE==FALSE){
            llOwnerSay("@"+rlvStr);
        }else{
            string rlvCmdName="PUNISH_EXECUTE_" + llGetObjectName();
            list rlvExecList =[rlvCmdName, VICTIM_UUID, llReplaceSubString("@"+rlvStr,",","|",0)];
            string rlvExecStr=llDumpList2String(rlvExecList, ",");
			llSay(RLVRS,rlvExecStr);
        }
    }
}

list punishAnim=[]; // 惩罚动画随机播放列表
list punishSounds=[]; // 惩罚音效随机播放列表（起始音效，随机1，随机2，……，倒下音效，终止音效）
float punishSoundsVolume=1.0; // 惩罚音量
list punishFrames=[]; // 粒子帧列表
integer punishTimeMin=0; // 惩罚最短持续时长
integer punishTimeMax=0; // 惩罚最长持续时长
float punishFrameRate=0.2; // 惩罚动画帧频率
string punishRLV=""; // 惩罚RLV限制
string blackoutRLV=""; // 黑屏RLV限制
list punishBannedWords=[]; // 禁说词
list punishNeededWords=[]; // 必说词
list punishOthersWords=[]; // 其他人触发词
float punishArousalValue=1; // 惩罚时唤起增量（每帧增加）

integer curSoundIndex=-1;
integer curPunishTime=-1;
integer curAnimPlaying=FALSE;
triggerPunish(integer bool, integer time, integer blackout){
	executeRLV(punishRLV, TRUE);
	// 随机惩罚动画
	integer curAnimIndex=(integer)llFrand(llGetListLength(punishAnim));
	curPlayingAnimName=llList2String(punishAnim, curAnimIndex);
	curAnimPlaying=TRUE;
	if(VICTIM_UUID!=NULL_KEY){
		llRequestPermissions(VICTIM_UUID,PERMISSION_TRIGGER_ANIMATION);
	}
	// 播放触发声音
	string curSound=llList2String(punishSounds, 0);
	if(curSound!=""){
		llTriggerSound(curSound, punishSoundsVolume);
	}
	// 随机播放惩罚声音
	curSoundIndex=randomInt(1, llGetListLength(punishSounds)-3);
	curSound=llList2String(punishSounds, curSoundIndex);
	if(curSound!=""){
		llLoopSound(curSound, punishSoundsVolume);
	}
	// 启动计时器，播放帧动画
	playPunishParticle(llList2String(punishFrames, 0));
	curPunishFrame=1; // 从1开始，因为触发时会预播放第0帧
	timerCount=0;
	timerFlag="punish";
	llResetTime();
	if(bool==TRUE){
		if(~time){
			curPunishTime=time;
		}else{
			curPunishTime=randomInt(punishTimeMin, punishTimeMax);
		}
		if(~blackout){
			if(curBlackoutTime<0){
				curBlackoutTime=0;
			}
			curBlackoutTime+=blackout;
			if(curBlackoutTime > punishBlackoutTimeLimit){
				curBlackoutTime = punishBlackoutTimeLimit;
			}
		}
	}else{
		curPunishTime=-1;
	}
	llSetTimerEvent(punishFrameRate);
	// 结束交给计时器
}

list blackoutAnim=[]; // 黑屏动画随机播放列表
integer punishBlackoutTimeMin=0; // 黑屏最短持续时长
integer punishBlackoutTimeMax=0; // 黑屏最长持续时长
integer punishBlackoutTimeLimit=240;
integer curBlackoutTime=-1;
triggerBlackout(integer bool, integer time){
	llSetTimerEvent(0);
	playPunishParticle("");
	executeRLV(blackoutRLV, TRUE);
	// 播放倒下音效
	llStopSound();
	string curSound=llList2String(punishSounds, -2);
	if(curSound!=""){
		llTriggerSound(curSound, punishSoundsVolume);
	}
	// 随机惩罚动画
	integer curAnimIndex=(integer)llFrand(llGetListLength(blackoutAnim));
	curPlayingAnimName=llList2String(blackoutAnim, curAnimIndex);
	curAnimPlaying=TRUE;
	if(VICTIM_UUID!=NULL_KEY){
		llRequestPermissions(VICTIM_UUID,PERMISSION_TRIGGER_ANIMATION);
	}
	// 启动计时器，等待黑屏结束
	timerCount=0;
	timerFlag="blackout";
	
	if(bool==TRUE){
		if(~time){
			curBlackoutTime=time; // 顺序调用时，前面已经加过，这里不能再加一次
		}else{
			curBlackoutTime+=randomInt(punishBlackoutTimeMin, punishBlackoutTimeMax);
		}
		if(curBlackoutTime > punishBlackoutTimeLimit){
			curBlackoutTime = punishBlackoutTimeLimit;
		}
	}else{
		curBlackoutTime=-1;
	}
	llSetTimerEvent(1);
	// 结束交给计时器
}

triggerRecovery(){
	playPunishParticle("");
	executeRLV(punishRLV, FALSE);
	executeRLV(blackoutRLV, FALSE);
	llMessageLinked(LINK_THIS, RLV_MSG_NUM, "RLV.RUN", NULL_KEY); // 恢复RLV原有限制
	curAnimPlaying=FALSE;
	if(VICTIM_UUID!=NULL_KEY){
		llRequestPermissions(VICTIM_UUID,PERMISSION_TRIGGER_ANIMATION);
	}
	// 播放恢复音效
	llStopSound();
	string curSound=llList2String(punishSounds, -1);
	if(curSound!=""){
		llTriggerSound(curSound, punishSoundsVolume);
	}
	// 停止计时器并清理现场
	curPunishTime=-1;
	curBlackoutTime=-1;
	timerCount=0;
	timerFlag="";
	llSetTimerEvent(0);
}

integer curPunishFrame=0;
string particleLinkName="";
list particleParams=[];
playPunishParticle(string name){
	// 处理Particle的uuid（particle参数中禁止添加uuid）
	list curParticleParams=particleParams+[PSYS_SRC_TEXTURE, name];
	// 获取prim列表
	list particlePrims=getLinksByName(particleLinkName);
	if(llGetListLength(particlePrims)<=0){
		particlePrims+=[LINK_THIS];
	}
	integer i;
	for(i=0; i<llGetListLength(particlePrims); i++){
		if(name!=""){
			llLinkParticleSystem(llList2Integer(particlePrims, i), curParticleParams);
		}else{
			llLinkParticleSystem(llList2Integer(particlePrims, i), []);
		}
	}
}


string menuName="PunishMenu";
string menuParent="";
showMenu(string parent, key user){
    menuParent=parent;
    string menuText="This is Punish menu.\nPunishment for self banned speaking: %b1%\nPunishment for self necessary speaking: %b2%\nPunishment for other's banned speaking: %b3%\nArousal enabled: %b4%, each increase value: %5%\nCurrent banned words: %6%\nCurrent needed words: %7%\nCurrent others words: %8%\nCurrent volume: %9%\nCurrent punish time range: %10%~%11%s\nCurrent blackout time range: %12%~%13%s%%;"+
		(string)punishEnabledBanned+";"+
		(string)punishEnabledNeeded+";"+
		(string)punishEnabledOthers+";"+
		(string)punishArousalEnabled+";"+
		(string)punishArousalValue+";"+

		llDumpList2String(punishBannedWords,", ")+";"+
		llDumpList2String(punishNeededWords,", ")+";"+
		llDumpList2String(punishOthersWords,", ")+";"+

		(string)punishSoundsVolume+";"+
		(string)punishTimeMin+";"+
		(string)punishTimeMax+";"+
		(string)punishBlackoutTimeMin+";"+
		(string)punishBlackoutTimeMax+";"
	;
    list menuList=[
		"P:Punish", "P:Blackout", "P:Recovery",
		"P:BannedWords", "P:NecessaryWords", "P:OthersWords",
		"["+(string)punishEnabledBanned+"]P:EnableBanned", "["+(string)punishEnabledNeeded+"]P:EnableNecessary", "["+(string)punishEnabledOthers+"]P:EnableOthers",
		"["+(string)punishEnabledOutput+"]P:EnableOutput", "["+(string)punishArousalEnabled+"]P:EnableArousal", "P:ArousalValue",
		"P:Volume", "P:PunishTime", "P:BlackoutTime"
    ];
    llMessageLinked(LINK_SET, MENU_MSG_NUM, "MENU.REG.OPEN|"+menuName+"|"+menuText+"|"+llDumpList2String(menuList, ";")+"|"+parent, user);
}

integer MENU_MSG_NUM=1000;
integer RLV_MSG_NUM=1001;
integer MAIN_MSG_NUM=9000;
integer PUNISH_MSG_NUM=90004;

integer REZ_MODE=FALSE;
key VICTIM_UUID=NULL_KEY;

string lastPlayingAnimName="";
string curPlayingAnimName="";
string timerFlag="";
integer timerCount=0;
integer listenHandle;
integer listenCmdHandle;

integer punishEnabledBanned=TRUE;
integer punishEnabledNeeded=TRUE;
integer punishEnabledOthers=FALSE;
integer punishEnabledOutput=TRUE;
integer punishArousalEnabled=TRUE;

integer standalone=FALSE;
integer allowCmdMenu=FALSE;
default{
    state_entry(){
        initMain();
		if(llGetAttached()){
            REZ_MODE=FALSE;
            VICTIM_UUID=llGetOwner();
			llListenRemove(listenHandle);
			llListenRemove(listenCmdHandle);
			llSleep(0.1);
			listenHandle=llListen(0, "", NULL_KEY, "");
			listenCmdHandle=llListen(1, "", NULL_KEY, "");
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
			llListenRemove(listenHandle);
			llListenRemove(listenCmdHandle);
			llSleep(0.1);
			listenHandle=llListen(0, "", NULL_KEY, "");
			listenCmdHandle=llListen(1, "", NULL_KEY, "");
        }
    }
	attach(key user){
		REZ_MODE=FALSE;
		if(user!=NULL_KEY){
			VICTIM_UUID=llGetOwner();
		}
	}
	on_rez(integer start_param){
		integer attached=llGetAttached();
        if(attached){
            REZ_MODE=FALSE;
            VICTIM_UUID=llGetOwner();
        }else{
            REZ_MODE=TRUE;
            VICTIM_UUID=NULL_KEY;
        }
		llListenRemove(listenHandle);
		llListenRemove(listenCmdHandle);
		llSleep(0.1);
		listenHandle=llListen(0, "", NULL_KEY, "");
		listenCmdHandle=llListen(1, "", NULL_KEY, "");
	}
	object_rez(key id){
        REZ_MODE=TRUE;
        VICTIM_UUID=NULL_KEY;
    }
	touch_start(integer num_detected){
		if(standalone==TRUE){
			showMenu("", llDetectedKey(0));
		}
	}
	listen(integer channel, string name, key id, string message){
		key user=llGetOwnerKey(id);
		// 公屏监听
		if(channel==0){
			integer i;
			if(user == VICTIM_UUID){
				if(punishEnabledBanned == TRUE){
					// 禁说词
					for(i=0; i<llGetListLength(punishBannedWords); i++){
						if(includes(llToLower(message), llToLower(llList2String(punishBannedWords, i)))){
							integer randomBlackoutTime=randomInt(punishBlackoutTimeMin, punishBlackoutTimeMax);
							if(punishEnabledOutput==TRUE) llMessageLinked(LINK_SET, MENU_MSG_NUM, "MENU.OUT.WHISPER|Detected %1% said banned words. Punishment has been triggered! Added punishment time %2%s!%%;"+userInfo(VICTIM_UUID)+";"+(string)randomBlackoutTime, user);
							triggerPunish(TRUE, -1, randomBlackoutTime);
							if(punishEnabledOutput==TRUE) llMessageLinked(LINK_SET, MENU_MSG_NUM, "MENU.OUT.WHISPER|Remaining time: %1%s!%%;"+(string)curBlackoutTime, user);
							return;
						}
					}
				}
				if(punishEnabledNeeded==TRUE){
					// 必说词
					for(i=0; i<llGetListLength(punishNeededWords); i++){
						if(!includes(llToLower(message), llToLower(llList2String(punishNeededWords, i)))){
							integer randomBlackoutTime=randomInt(punishBlackoutTimeMin, punishBlackoutTimeMax);
							if(punishEnabledOutput==TRUE) llMessageLinked(LINK_SET, MENU_MSG_NUM, "MENU.OUT.WHISPER|Detected %1% did not say the required words. Punishment has been triggered! Added punishment time %2%s!%%;"+userInfo(VICTIM_UUID)+";"+(string)randomBlackoutTime, user);
							triggerPunish(TRUE, -1, randomBlackoutTime);
							if(punishEnabledOutput==TRUE) llMessageLinked(LINK_SET, MENU_MSG_NUM, "MENU.OUT.WHISPER|Remaining time: %1%s!%%;"+(string)curBlackoutTime, user);
							return;
						}
					}
				}
			}else if(punishEnabledOthers == TRUE){
				// 其他人触发
				for(i=0; i<llGetListLength(punishOthersWords); i++){
					if(includes(llToLower(message), llToLower(llList2String(punishOthersWords, i)))){
						integer randomBlackoutTime=randomInt(punishBlackoutTimeMin, punishBlackoutTimeMax);
						if(punishEnabledOutput==TRUE) llMessageLinked(LINK_SET, MENU_MSG_NUM, "MENU.OUT.WHISPER|Detected %1% said banned words from %2% 's list. Punishment has been triggered for %2% ! Added punishment time %3%s!%%;"+userInfo(user)+";"+userInfo(VICTIM_UUID)+";"+(string)randomBlackoutTime, user);
						triggerPunish(TRUE, -1, randomBlackoutTime);
						if(punishEnabledOutput==TRUE) llMessageLinked(LINK_SET, MENU_MSG_NUM, "MENU.OUT.WHISPER|Remaining time: %1%s!%%;"+(string)curBlackoutTime, user);
						return;
					}
				}
			}
		}
		// 命令频道监听
		else if(channel==1){
			string namePrifix=llGetSubString(llGetUsername(VICTIM_UUID), 0, 1);
			if(allowCmdMenu==TRUE && message == namePrifix+"punishmenu" && user==llGetOwner()){
				showMenu("", user);
			}
			if(message == namePrifix+"auto"){
				triggerPunish(TRUE, -1, -1);
			}
			if(message == namePrifix+"punish"){
				triggerPunish(FALSE, -1, -1);
			}
			else if(message == namePrifix+"blackout"){
				triggerBlackout(FALSE, -1);
			}
			else if(message == namePrifix+"recovery"){
				triggerRecovery();
			}
		}
	}
	timer(){
		// 惩罚状态（执行帧）
		if(timerFlag=="punish"){
			playPunishParticle(llList2String(punishFrames, curPunishFrame));
			if(curPunishFrame >= llGetListLength(punishFrames)-1){
				curPunishFrame=0;
			}else{
				curPunishFrame++;
			}
			// 唤起功能
			if(punishArousalEnabled==TRUE){
				llMessageLinked(LINK_THIS, 0, "caeilarousalup|"+(string)VICTIM_UUID+"|"+(string)punishArousalValue, "");
			}
			// 计算停止条件
			// 计算从llResetTime()到现在的时长
			if(~curPunishTime && llGetTime() >= curPunishTime){
				triggerBlackout(TRUE, curBlackoutTime);
				// llSetTimerEvent(0);
			}
		}
		// 黑屏状态（等待时长）
		else if(timerFlag=="blackout"){
			if(~curBlackoutTime){
				if(curBlackoutTime>0){
					curBlackoutTime--;
				}else{
					triggerRecovery();
					llSetTimerEvent(0);
				}
			}
		}
		timerCount++;
	}
	run_time_permissions(integer perm) {
        if(perm & PERMISSION_TRIGGER_ANIMATION){
			// 先停止当前动画
			if(lastPlayingAnimName!=""){
				llStopAnimation(lastPlayingAnimName);
				lastPlayingAnimName="";
			}
			// 播放新动画
			if(curPlayingAnimName!=""){
				if(curAnimPlaying==TRUE){
					llStartAnimation(curPlayingAnimName);
					lastPlayingAnimName=curPlayingAnimName;
				}else{
					llStopAnimation(curPlayingAnimName);
					lastPlayingAnimName="";
				}
			}
        }
    }
    link_message(integer sender_num, integer num, string msg, key user){
        if(num!=MAIN_MSG_NUM && num!=MENU_MSG_NUM && num!=PUNISH_MSG_NUM){
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

        if(headerMain=="PUNISH" && headerSub!="EXEC"){
			string result="";
			if(headerSub=="TRIGGER"){
				/*
				触发惩罚
				PUNISH.TRIGGER.PUNISH | 1 | -1
				*/
				if(headerExt=="PUNISH"){
					if(msg2==""){
						msg2="-1";
					}
					if(msg3==""){
						msg3="-1";
					}
					triggerPunish((integer)msg1, (integer)msg2, (integer)msg3);
					result="1";
				}
				/*
				触发黑屏
				PUNISH.TRIGGER.BLACKOUT | 1 | -1
				*/
				if(headerExt=="BLACKOUT"){
					if(msg2==""){
						msg2="-1";
					}
					triggerBlackout((integer)msg1, (integer)msg2);
					result="1";
				}
				/*
				触发恢复
				PUNISH.TRIGGER.RECOVERY
				*/
				if(headerExt=="RECOVERY"){
					triggerRecovery();
					result="1";
				}
			}
			else if(headerSub=="GET"){
				if(headerExt=="ENABLED"){
					/*
					是否启用监听触发
					PUNISH.GET.ENABLED
					*/
					if(headerExt2==""){
						result=(string)punishEnabledBanned;
					}
					/*
					是否启用监听触发别人的发言
					PUNISH.GET.ENABLED.OTHERS
					*/
					else if(headerExt2=="OTHERS"){
						result=(string)punishEnabledOthers;
					}
					/*
					是否启用高潮系统（需要PA2插件）
					PUNISH.GET.ENABLED.AROUSAL
					*/
					else if(headerExt2=="AROUSAL"){
						result=(string)punishArousalEnabled;
					}
				}
				else if(headerExt=="AROUSAL"){
					/*
					高潮系统每帧增加值（需要PA2插件）
					PUNISH.GET.AROUSAL.VALUE
					*/
					if(headerExt2=="VALUE"){
						result=(string)punishArousalValue;
					}
				}
				else if(headerExt=="PUNISH"){
					/*
					惩罚动画列表
					PUNISH.GET.PUNISH.ANIMS
					*/
					if(headerExt2=="ANIMS"){
						result=(string)llDumpList2String(punishAnim, ";");
					}
					/*
					惩罚粒子帧
					PUNISH.GET.PUNISH.FRAMES
					*/
					else if(headerExt2=="FRAMES"){
						result=(string)llDumpList2String(punishFrames, ";");
					}
					/*
					惩罚粒子帧率
					PUNISH.GET.PUNISH.FRAMERATE
					*/
					else if(headerExt2=="FRAMERATE"){
						result=(string)punishFrameRate;
					}
					/*
					惩罚时长范围
					PUNISH.GET.PUNISH.TIME
					*/
					else if(headerExt2=="TIME"){
						result=(string)punishTimeMin+"|"+(string)punishTimeMax;
					}
					/*
					惩罚RLV限制
					PUNISH.GET.PUNISH.RLV
					*/
					else if(headerExt2=="RLV"){
						result=(string)punishRLV;
					}
					/*
					惩罚禁用词
					PUNISH.GET.PUNISH.BANNED
					*/
					else if(headerExt2=="BANNED"){
						result=(string)llDumpList2String(punishBannedWords, ";");
					}
					/*
					惩罚必说词
					PUNISH.GET.PUNISH.NEEDED
					*/
					else if(headerExt2=="NEEDED"){
						result=(string)llDumpList2String(punishNeededWords, ";");
					}
					/*
					惩罚其他人触发
					PUNISH.GET.PUNISH.OTHERS
					*/
					else if(headerExt2=="OTHERS"){
						result=(string)llDumpList2String(punishOthersWords, ";");
					}
				}
				else if(headerExt=="BLACKOUT"){
					/*
					黑屏动画列表
					PUNISH.GET.BLACKOUT.ANIMS
					*/
					if(headerExt2=="ANIMS"){
						result=(string)llDumpList2String(blackoutAnim, ";");
					}
					/*
					黑屏时长范围
					PUNISH.GET.BLACKOUT.TIME
					*/
					if(headerExt2=="TIME"){
						result=(string)punishBlackoutTimeMin+"|"+(string)punishBlackoutTimeMin;
					}
					/*
					黑屏RLV限制
					PUNISH.GET.BLACKOUT.RLV
					*/
					else if(headerExt2=="RLV"){
						result=(string)blackoutRLV;
					}
				}
				else if(headerExt=="SOUNDS"){
					/*
					声音列表
					PUNISH.GET.SOUNDS
					*/
					if(headerExt2==""){
						result=(string)llDumpList2String(punishSounds, ";");
					}
					/*
					音量
					PUNISH.GET.SOUNDS.VOLUME
					*/
					else if(headerExt2=="VOLUME"){
						result=(string)punishSoundsVolume;
					}
				}
			}
			else if(headerSub=="SET"){
				if(headerExt=="ENABLED"){
					/*
					是否启用监听触发
					PUNISH.SET.ENABLED | 1
					*/
					if(headerExt2==""){
						punishEnabledBanned=(integer)msg1;
						result=(string)punishEnabledBanned;
					}
					/*
					是否启用监听触发别人的发言
					PUNISH.SET.ENABLED.OTHERS | 1
					*/
					else if(headerExt2=="OTHERS"){
						punishEnabledOthers=(integer)msg1;
						result=(string)punishEnabledOthers;
					}
					/*
					是否启用高潮系统（需要PA2插件）
					PUNISH.SET.ENABLED.AROUSAL | 1
					*/
					else if(headerExt2=="AROUSAL"){
						punishArousalEnabled=(integer)msg1;
						result=(string)punishArousalEnabled;
					}
				}
				else if(headerExt=="AROUSAL"){
					/*
					高潮系统每帧增加值（需要PA2插件）
					PUNISH.SET.AROUSAL.VALUE | 10
					*/
					if(headerExt2=="VALUE"){
						punishArousalValue=(float)msg1;
						result=(string)punishArousalValue;
					}
				}
				else if(headerExt=="PUNISH"){
					/*
					惩罚动画列表
					PUNISH.SET.PUNISH.ANIMS | Anim1; Anim2; ...
					*/
					if(headerExt2=="ANIMS"){
						punishAnim=llParseStringKeepNulls(msg1, [";"], [""]);
						result=(string)llDumpList2String(punishAnim, ";");
					}
					/*
					惩罚粒子帧
					PUNISH.SET.PUNISH.FRAMES | Frame1; Frame2; ...
					*/
					else if(headerExt2=="FRAMES"){
						punishFrames=llParseStringKeepNulls(msg1, [";"], [""]);
						result=(string)llDumpList2String(punishFrames, ";");
					}
					/*
					惩罚粒子帧率
					PUNISH.SET.PUNISH.FRAMERATE | 0.2
					*/
					else if(headerExt2=="FRAMERATE"){
						punishFrameRate=(float)msg1;
						result=(string)punishFrameRate;
					}
					/*
					惩罚时长范围（min;max）
					PUNISH.SET.PUNISH.TIME | 5 | 10
					*/
					else if(headerExt2=="TIME"){
						punishTimeMin=(integer)msg1;
						punishTimeMax=(integer)msg2;
						result=(string)punishTimeMin+";"+(string)punishTimeMax;
					}
					/*
					惩罚RLV限制
					PUNISH.SET.PUNISH.RLV | rlv1, rlv2, ...
					*/
					else if(headerExt2=="RLV"){
						punishRLV=msg1;
						result=(string)punishRLV;
					}
					/*
					惩罚禁用词
					PUNISH.SET.PUNISH.BANNED | word1; word2; ...
					*/
					else if(headerExt2=="BANNED"){
						punishBannedWords=llParseStringKeepNulls(msg1, [";"], [""]);
						result=(string)llDumpList2String(punishBannedWords, ";");
					}
					/*
					惩罚必说词
					PUNISH.SET.PUNISH.NEEDED | word1; word2; ...
					*/
					else if(headerExt2=="NEEDED"){
						punishNeededWords=llParseStringKeepNulls(msg1, [";"], [""]);
						result=(string)llDumpList2String(punishNeededWords, ";");
					}
					/*
					惩罚其他人触发
					PUNISH.SET.PUNISH.OTHERS | word1; word2; ...
					*/
					else if(headerExt2=="OTHERS"){
						punishOthersWords=llParseStringKeepNulls(msg1, [";"], [""]);
						result=(string)llDumpList2String(punishOthersWords, ";");
					}
				}
				else if(headerExt=="BLACKOUT"){
					/*
					黑屏动画列表
					PUNISH.SET.BLACKOUT.ANIMS | Anim1; Anim2; ...
					*/
					if(headerExt2=="ANIMS"){
						blackoutAnim=llParseStringKeepNulls(msg1, [";"], [""]);
						result=(string)llDumpList2String(blackoutAnim, ";");
					}
					/*
					黑屏时长范围
					PUNISH.SET.BLACKOUT.TIME | 30 | 60
					*/
					if(headerExt2=="TIME"){
						punishBlackoutTimeMin=(integer)msg1;
						punishBlackoutTimeMin=(integer)msg2;
						result=(string)punishBlackoutTimeMin+";"+(string)punishBlackoutTimeMin;
					}
					/*
					黑屏RLV限制
					PUNISH.SET.BLACKOUT.RLV | rlv1, rlv2, ...
					*/
					else if(headerExt2=="RLV"){
						blackoutRLV=msg1;
						result=(string)blackoutRLV;
					}
				}
				else if(headerExt=="SOUNDS"){
					/*
					声音列表
					PUNISH.SET.SOUNDS | Sound1; Sound2; ...
					*/
					if(headerExt2==""){
						punishSounds=llParseStringKeepNulls(msg1, [";"], [""]);
						result=(string)llDumpList2String(punishSounds, ";");
					}
					/*
					音量
					PUNISH.SET.SOUNDS.VOLUME | 1.0
					*/
					else if(headerExt2=="VOLUME"){
						punishSoundsVolume=(float)msg1;
						result=(string)punishSoundsVolume;
					}
				}
			}
			else if(headerSub=="MENU"){
				/*
				显示菜单
				PUNISH.MENU | Parent
				*/
				showMenu(msg1,user);
			}
			if(result!=""){
                llMessageLinked(LINK_THIS, PUNISH_MSG_NUM, "PUNISH.EXEC|"+msgHeader+"|"+result, user);
            }
        }
        else if(headerMain=="MAIN" && headerSub=="INIT"){
			standalone=FALSE;
            llMessageLinked(LINK_THIS, MAIN_MSG_NUM, "FEATURE.REG|Punish|Title", user);
        }
        else if(headerMain=="MENU" && headerSub=="ACTIVE"){
            // MENU.ACTIVE | MenuName | MenuButton
            if(msg1=="appMenu" && msg2=="Punish"){
                showMenu(msg1,user);
            }
			else if(msg1==menuName && msg2!=""){
				if(msg2=="P:Punish"){
					triggerPunish(FALSE, -1, -1);
					showMenu(menuParent,user);
				}
				else if(msg2=="P:Blackout"){
					triggerBlackout(FALSE, -1);
					showMenu(menuParent,user);
				}
				else if(msg2=="P:Recovery"){
					triggerRecovery();
					showMenu(menuParent,user);
				}
				else if(msg2=="P:EnableBanned"){
					punishEnabledBanned=!punishEnabledBanned;
					showMenu(menuParent,user);
				}
				else if(msg2=="P:EnableNecessary"){
					punishEnabledNeeded=!punishEnabledNeeded;
					showMenu(menuParent,user);
				}
				else if(msg2=="P:EnableOthers"){
					punishEnabledOthers=!punishEnabledOthers;
					showMenu(menuParent,user);
				}
				else if(msg2=="P:EnableOutput"){
					punishEnabledOutput=!punishEnabledOutput;
					showMenu(menuParent,user);
				}
				else if(msg2=="P:EnableArousal"){
					punishArousalEnabled=!punishArousalEnabled;
					showMenu(menuParent,user);
				}
				else if(msg2=="P:Volume"){
					llMessageLinked(LINK_SET, MENU_MSG_NUM, "MENU.INPUT|PunishInput_"+msg2+"|Input %1% (0~1), blank to return (Current: %2%):%%;"+msg2+";"+(string)punishSoundsVolume, user);
				}
				else if(msg2=="P:PunishTime"){
					llMessageLinked(LINK_SET, MENU_MSG_NUM, "MENU.INPUT|PunishInput_"+msg2+"|Input %1% (e.g.: 1,10), blank to return (Current: %2%~%3%):%%;"+msg2+";"+(string)punishTimeMin+";"+(string)punishTimeMax, user);
				}
				else if(msg2=="P:BlackoutTime"){
					llMessageLinked(LINK_SET, MENU_MSG_NUM, "MENU.INPUT|PunishInput_"+msg2+"|Input %1% (e.g.: 30,60), blank to return (Current: %2%~%3%):%%;"+msg2+";"+(string)punishBlackoutTimeMin+";"+(string)punishBlackoutTimeMax, user);
				}
				else if(msg2=="P:BannedWords"){
					llMessageLinked(LINK_SET, MENU_MSG_NUM, "MENU.INPUT|PunishInput_"+msg2+"|Input %1% (use , to separate each word), blank to clear (Current: %2%):%%;"+msg2+";"+llDumpList2String(punishBannedWords, ","), user);
				}
				else if(msg2=="P:NecessaryWords"){
					llMessageLinked(LINK_SET, MENU_MSG_NUM, "MENU.INPUT|PunishInput_"+msg2+"|Input %1% (use , to separate each word), blank to clear (Current: %2%):%%;"+msg2+";"+llDumpList2String(punishNeededWords, ","), user);
				}
				else if(msg2=="P:OthersWords"){
					llMessageLinked(LINK_SET, MENU_MSG_NUM, "MENU.INPUT|PunishInput_"+msg2+"|Input %1% (use , to separate each word), blank to clear (Current: %2%):%%;"+msg2+";"+llDumpList2String(punishOthersWords, ","), user);
				}
				else if(msg2=="P:ArousalValue"){
					llMessageLinked(LINK_SET, MENU_MSG_NUM, "MENU.INPUT|PunishInput_"+msg2+"|Input %1% (each punishment value), blank to return (Current: %2%):%%;"+msg2+";"+(string)punishArousalValue, user);
				}
			}
			else if(includes(msg1, "PunishInput")){
				string punishInputType=llGetSubString(msg1, llStringLength("PunishInput_"), -1);
				if(punishInputType=="P:Volume"){
					if(msg2!=""){
						punishSoundsVolume=(float)msg2;
						if(punishSoundsVolume<0) punishSoundsVolume=0;
						if(punishSoundsVolume>1) punishSoundsVolume=1;
					}
				}
				else if(punishInputType=="P:PunishTime"){
					if(msg2!=""){
						list ptList=llParseStringKeepNulls(msg2, [","], [""]);
						punishTimeMin=llList2Integer(ptList, 0);
						punishTimeMax=llList2Integer(ptList, 1);
						if(punishTimeMin<0) punishTimeMin=0;
						if(punishTimeMax<0) punishTimeMax=0;
					}
				}
				else if(punishInputType=="P:BlackoutTime"){
					if(msg2!=""){
						list ptList=llParseStringKeepNulls(msg2, [","], [""]);
						punishBlackoutTimeMin=llList2Integer(ptList, 0);
						punishBlackoutTimeMax=llList2Integer(ptList, 1);
						if(punishBlackoutTimeMin<0) punishBlackoutTimeMin=0;
						if(punishBlackoutTimeMax<0) punishBlackoutTimeMax=0;
					}
				}
				else if(punishInputType=="P:BannedWords"){
					punishBannedWords=llParseStringKeepNulls(msg2, [","], [""]);
				}
				else if(punishInputType=="P:NecessaryWords"){
					punishNeededWords=llParseStringKeepNulls(msg2, [","], [""]);
				}
				else if(punishInputType=="P:OthersWords"){
					punishOthersWords=llParseStringKeepNulls(msg2, [","], [""]);
				}
				else if(punishInputType=="P:ArousalValue"){
					punishArousalValue=(float)msg2;
				}
				showMenu(menuParent,user);
			}
        }
		// llSleep(0.01);
        // llOwnerSay("Punish Memory Used: "+(string)llGetUsedMemory()+"/"+(string)(65536-llGetUsedMemory())+" Free: "+(string)llGetFreeMemory());
    }
}
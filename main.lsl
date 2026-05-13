initMain(){
    // Main Config
	initMenuList=[
        // Name,    MSG_NUM,            MSG.CMD              MSG.READY.CALLBACK          Show    Ready
		"Capture",  CAPTURE_MSG_NUM,    "CAPTURE.LOAD|main", "CAPTURE.LOAD.NOTECARD",    TRUE,   FALSE,
		"Leash",    LEASH_MSG_NUM,      "LEASH.LOAD|main",   "LEASH.LOAD.NOTECARD",      TRUE,   FALSE,
		"RLV",	    RLV_MSG_NUM,        "RLV.LOAD|main",     "RLV.LOAD.NOTECARD",        TRUE,   FALSE,
		"Timer",    TIMER_MSG_NUM,      "TIMER.LOAD|main",   "TIMER.LOAD.NOTECARD",      TRUE,   FALSE,
		"Renamer",  RENAMER_MSG_NUM,    "RENAMER.LOAD|main", "RENAMER.LOAD.NOTECARD",    TRUE,   FALSE,
		"Animation",ANIM_MSG_NUM,       "ANIM.LOAD|main",    "ANIM.LOAD.NOTECARD",       TRUE,   FALSE,
		"Access",   ACCESS_MSG_NUM,     "ACCESS.LOAD|main",  "ACCESS.LOAD.NOTECARD",	 TRUE,   FALSE,
		"Struggle", STRUGGLE_MSG_NUM,   "STRUGGLE.LOAD|main","STRUGGLE.LOAD.NOTECARD",   FALSE,  FALSE,
		"Text",     TEXT_MSG_NUM,       "TEXT.GET.READY",    "TEXT.READY",               FALSE,  FALSE,
		"Language", LAN_MSG_NUM,        "LANGUAGE.INIT",     "",                         FALSE,  FALSE
	];
	cmdList=[
		"menu", MAIN_MSG_NUM, "MAIN.MENU",
		"leash", LEASH_MSG_NUM, "LEASH.TO|%user%",
		"follow", LEASH_MSG_NUM, "LEASH.TO|%user%|0",
		"yank", LEASH_MSG_NUM, "LEASH.YANK|%user%",
		"unleash", LEASH_MSG_NUM, "LEASH.TO",
		"unfollow", LEASH_MSG_NUM, "LEASH.TO"
	];
    initTimer=0.1;
    cmdChannel=1;
    allowPermaLock=TRUE;
    allowSit=TRUE;

    // Main Init
    llOwnerSay("Begin Initialize...");

    if(allowSit){
        llSitTarget(<0.0, 0.0, -0.2>, ZERO_ROTATION);
        llSetSitText("");
    }else{
        llSitTarget(<0.0, 0.0, 0.0>, ZERO_ROTATION);
        llSetSitText("");
    }
    llListenRemove(listenHandle);
    llSleep(initTimer);
    listenHandle=llListen(cmdChannel, "", NULL_KEY, "");
    initIndex=0;
    timerFlag=2;
    llSetTimerEvent(initTimer); // 重置时，设置计时器，5秒后重新初始化，防止初始化失败
}
/*CONFIG END*/

/*
Name: Main
Author: JMRY
Description: A main controller for restraint items.

***更新记录***
- 2.0.2 20260514
    - 修复上锁后，会发出多次消息的bug。

- 2.0.1 20260512
    - 修复App菜单全都显示开关的bug。
    - 修复主脚本菜单项不显示的bug。
    - 修复语言功能失效的bug。

- 2.0 20260511
	- 重构主控脚本。

- 1.2.3 20260510
	- 加入可移除应用注册功能。

- 1.2.2 20260501
	- 优化App注册逻辑。
	- 修复App概率性无法加载的bug。

- 1.2.1 20260428
	- 加入其他脚本调用主菜单功能。
	- 优化内存占用。

- 1.2 20260427
	- 优化代码结构。
	- 优化菜单生成逻辑。
	- 优化菜单注册排序逻辑。
	- 优化权限数据结构和判断逻辑。

- 1.1.14 20260420
	- 加入触摸、上锁、解锁的声音开关。
	- 修复主菜单主人显示不正常的bug。

- 1.1.13 20260419
	- 加入\NL不进行语言匹配功能。
	- 优化ShowText的显示逻辑。

- 1.1.12 20260416
	- 修复周围没有玩家时，无法弹出选择玩家对话框的bug。
	- 修复使用uuid作为声音时，无法播放的bug。

- 1.1.11 20260406
	- - 优化REZ模式下的各种处理逻辑。

- 1.1.10 20260404
	- 加入永久锁定功能。
	- 优化设置菜单显示内容。

- 1.1.9 20260402
	- 自定义菜单功能支持注册在不同菜单中。
	- 加入默认音频并自动检测是否存在。
	- 修复REZ模式下，无人时上锁判断错误的bug。

- 1.1.8 20260324
	- 加入自定义“坐在这里”文本功能。

- 1.1.7 20260321
	- 加入REZ模式下的文字显示。
	- 优化代码结构。

- 1.1.6 20260319
	- 加入音效的音量参数。
	- 加入计时器读取记事卡功能。

- 1.1.5 20260313
	- 优化REZ模式下，权限错误的bug。

- 1.1.4 20260311
	- 加入设置菜单。
	- 加入APP菜单。
	- 优化初始化流程。
	- 修复主菜单自定义功能失效的bug。

- 1.1.3 20260310
	- 加入脚本识别功能。
	- 优化脚本架构。

- 1.1.2 20260302
	- 加入REZ模式的菜单和捕获功能。

- 1.1.1 20260301
	- 加入自定义菜单功能的配置。

- 1.1 20260228
	- 优化代码结构，防止碎片化。
	- 优化挣扎系统判定条件，只有自己才能挣扎。

- 1.0.21 20260226
	- 加入挣扎功能。

- 1.0.20 20260213
	- 加入倒计时且锁定时，禁止访问菜单功能。

- 1.0.19 20260212
	- 优化初始化逻辑，加入启动监听的功能。

- 1.0.18 20260211
	- 优化内存占用。
	- 优化操作锁逻辑，操作锁关闭时，新的操作者会覆盖原来的操作响应。
	- 修复逃跑时，不能重置状态的bug。

- 1.0.17 20260208
	- 修复向频道1发送消息时，提示不可操作的bug。

- 1.0.16 20260203
	- 加入操作锁。

- 1.0.15 20260121
	- 加入配置脚本触发功能（仅示例）。
	- 优化内存占用。

- 1.0.14 20260119
	- 修复语言系统回调判定错误的bug。

- 1.0.13 20260118
	- 加入穿戴时，初始化先上锁功能。
	- 加入Access记事卡读取状态检测功能。

- 1.0.12 20260116
	- 优化初始化逻辑，防止丢失部分初始化项目。
	- 调整初始化重试时间为30秒。

- 1.0.11 20260115
	- 加入动画菜单入口。
	- 加入物品发出命令的监听支持。

- 1.0.10 20260109
	- 加入牵绳功能入口。
	- 加入本地聊天命令功能。

- 1.0.9 20260106
	- 加入计时器和自动解锁功能。

- 1.0.8 20251206
	- 加入锁定时间的展示。
	- 修复在Access逃跑后，可能打开双重菜单的bug。

- 1.0.7 20251204
	- 加入逃跑后，自动解锁功能。
	- 修复上锁后，无法逃跑的bug。

- 1.0.6 20251202
	- 优化主脚本初始化和RLV数据读取机制，提升重置后读取成功率。

- 1.0.5 20251129
	- 加入菜单项注册功能。

- 1.0.4 20251128
	- 加入Renamer菜单。

- 1.0.3 20251127
	- 开放语言菜单。

- 1.0.2 20251122
	- 优化RLV记事卡的读取机制，防止重复读取。

- 1.0.1 20251120
	- 加入库存变化时重新读取RLV脚本功能。

- 1.0 20251115
	- 完成主要功能。
***更新记录***
*/

string userInfo(key user){
	return "secondlife:///app/agent/"+(string)user+"/about";
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

integer hasLanguage=FALSE;
string lanLinkHeader="LAN_";
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
		text=llReplaceSubString(text, "%"+(string)vi+"%", getLanguage(llList2String(var, i)), 0);
	}
	return text;
}

string getTimeDistStr(integer baseTime, integer curTime){
	integer total=curTime - baseTime;
	string totalStr="";
	if(total!=curTime){
		string timeStr="";
		integer days = total / 86400;
		total = total % 86400;

		integer hours = total / 3600;
		total = total % 3600;

		integer minutes = total / 60;
		integer seconds = total % 60;

		timeStr=llGetSubString("00" + (string)hours, -2, -1) + ":" +llGetSubString("00" + (string)minutes, -2, -1) + ":" +llGetSubString("00" + (string)seconds, -2, -1);

		string daysStr="";
		if(days>0){
			daysStr=getLanguageVar("%1% days%%;"+(string)days);
		}

		totalStr=daysStr+timeStr;
	}
	return totalStr;
}

list featureList=[]; // name, prev, menuName, bool
integer featureLen=4;
registFeature(string name, string prev, string menuName, integer bool){
	if(name=="" || menuName==""){
		// name或菜单名为空时，不允许添加
		return;
	}
	integer i;
	for(i=0; i<llGetListLength(featureList); i+=featureLen){
		if(llList2String(featureList, i) == name && llList2String(featureList, i+2) == menuName){
			// featureList=llDeleteSubList(featureList, i, i+featureLen-1);
			featureList=llListReplaceList(featureList, [bool], i+3, i+3);
			return;
		}
	}

	if(prev=="TOP"){
		// TOP永远往前追加，置顶
		featureList=[name, prev, menuName, bool] + featureList;
	}else if(prev!=""){
		// 三个参数都不为空时，查找对应的位置，并插入
		for(i=0; i<llGetListLength(featureList); i+=featureLen){
			// 遍历list查找，prev与name相同，且menuName相同的节点，将它插入到此段后面
			if(prev == llList2String(featureList, i) && menuName == llList2String(featureList, i+2)){
				featureList=llListInsertList(featureList, [name, prev, menuName, bool], i+featureLen);
				// 插入成功，则终止
				return;
			}
		}
		// 上述遍历未匹配到内容时，向尾部插入
		featureList+=[name, prev, menuName, bool];
	}else{
		// prev为空时，往后追加
		featureList+=[name, prev, menuName, bool];
	}
}

removeFeature(string name, string menuName){
	if(name=="" || menuName==""){
		// name或菜单名为空时，不允许添加
		return;
	}
	integer i;
	for(i=0; i<llGetListLength(featureList); i+=featureLen){
		if(llList2String(featureList, i) == name && llList2String(featureList, i+2) == menuName){
			featureList=llDeleteSubList(featureList, i, i+featureLen-1);
			return;
		}
	}
}

list applyFeatureList(string menuName, list origin, list feature){
	integer i;
	for(i=0; i<llGetListLength(feature); i+=featureLen){
		string featureName=llList2String(feature, i);
		string featurePrev=llList2String(feature, i+1);
		integer featureBool=llList2Integer(feature, i+3);
		if(~featureBool){
			featureName="["+(string)featureBool+"]"+featureName;
		}
		if(llList2String(feature, i+2) == menuName){
			if(featurePrev=="TOP"){
				origin=[featureName]+origin;
			}else if(featurePrev!=""){
				integer prevIndex=llListFindList(origin, [featurePrev]);
				if(~prevIndex){
					origin=llListInsertList(origin, [featureName], prevIndex+1);
				}else{
					origin+=[featureName];
				}
			}else{
				origin+=[featureName];
			}
		}
	}
	return origin;
}

integer allowOperate(key user, integer output){
	// 先判断禁止操作的情况，锁定状态，计时器状态，触摸者
	// 穿戴模式
	if(REZ_MODE==FALSE){
		if(
			isLocked==TRUE /*锁定状态*/ &&
			timeoutRunning==TRUE /*倒计时状态*/ &&
			user==llGetOwner() /*自己触摸*/
		){
            if(output==TRUE){
                llMessageLinked(LINK_SET, MENU_MSG_NUM, "MENU.OUT.TO|You're locked by %1% and timer is running, not allow to operate it!%%;"+userInfo(lockUser), user);
            }
			return FALSE;
		}
		else if(
			isLocked==TRUE /*锁定状态*/ && 
			lockUser!=llGetOwner() /*非自锁*/ && 
			user==llGetOwner() /*自己触摸*/
		){
            if(output==TRUE){
                llMessageLinked(LINK_SET, MENU_MSG_NUM, "MENU.OUT.TO|You're locked by %1% and not allow to operate it!%%;"+userInfo(lockUser), user);
            }
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
            if(output==TRUE){
                llMessageLinked(LINK_SET, MENU_MSG_NUM, "MENU.OUT.TO|You're locked by %1% and timer is running, not allow to operate it!%%;"+userInfo(lockUser), user);
            }
			return FALSE;
		}
		else if(
			isLocked==TRUE /*锁定状态*/ && 
			lockUser!=VICTIM_UUID /*非自锁*/ && // REZ模式下，自锁也不允许解锁
			user==VICTIM_UUID /*被困者触摸*/
		){
            if(output==TRUE){
                llMessageLinked(LINK_SET, MENU_MSG_NUM, "MENU.OUT.TO|You're locked by %1% and not allow to operate it!%%;"+userInfo(lockUser), user);
            }
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
		if(isLocked && output==TRUE){
			llMessageLinked(LINK_SET, MENU_MSG_NUM, "MENU.OUT.TO|This %1% is locked by %2%, you don't have permission to operate it!%%;"+llGetObjectName()+";"+userInfo(lockUser), user);
		}
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

integer isLocked=FALSE;
integer isPermaLocked=FALSE;
key lockUser=NULL_KEY;
integer lockTime=0;
integer setLock(integer lock, key user, integer isShowMenu){
	if(REZ_MODE==TRUE && VICTIM_UUID==NULL_KEY && (lock==TRUE || lock==-1)){
		llMessageLinked(LINK_SET, MENU_MSG_NUM, "MENU.OUT.TO|No victims to lock!", user);
		return FALSE;
	}
	if(lock<0){
		if(!isLocked){
			isLocked=TRUE;
		}else{
			isLocked=FALSE;
		}
	}else{
		isLocked=lock;
	}
	llMessageLinked(LINK_SET, RLV_MSG_NUM, "RLV.LOCK|"+(string)isLocked, user);
	integer tempLockTime=lockTime;

	string lockedStatus;
	if(isLocked==TRUE){
		lockUser=user;
		lockTime=llGetUnixTime();
		lockedStatus="locked";
	}else{
		lockUser=NULL_KEY;
		lockTime=0;
		lockedStatus="unlocked";
	}
	if(user!=NULL_KEY && user != llGetOwner()){
		string usedTime="";
		if(tempLockTime>0){
			usedTime=getLanguageVar("Total locked time: %1%%%;"+getTimeDistStr(tempLockTime, llGetUnixTime()));
		}
		llMessageLinked(LINK_SET, MENU_MSG_NUM, "MENU.OUT.TO|You're %1% by %2%. %3%%%;"+lockedStatus+";"+userInfo(user)+";"+usedTime, VICTIM_UUID);
		llMessageLinked(LINK_SET, MENU_MSG_NUM, "MENU.OUT.TO|You %1% %2%'s %3%. %4%%%;"+lockedStatus+";"+userInfo(llGetOwner())+";"+llGetObjectName()+";"+usedTime, user);
	}
	if(isShowMenu){
		showMenu("mainMenu", user); // 防止出现打开双重菜单的bug，无必要不showMenu，尤其在Access逃跑或RLV锁定变更时。
	}
	return isLocked;
}

integer menuOperateLock=FALSE;
key curMenuUser=NULL_KEY;
list initMenuList=[];
integer initMenuListLength=6;
showMenu(string menuName, key user){
    integer isAllow=allowOperate(user, TRUE);
    if(!isAllow){
        return;
    }
    if(menuOperateLock==TRUE){
        if(curMenuUser==NULL_KEY || curMenuUser==user || user==llGetOwner()){
            curMenuUser=user;
            timerFlag=1;
            llSetTimerEvent(60);
        }else{
            llMessageLinked(LINK_SET, MENU_MSG_NUM, "MENU.OUT.TO|Sorry, the menu of %1% is using by %2%.%%;"+llGetObjectName()+";"+userInfo(curMenuUser)+"|0|"+(string)user, user);
            return;
        }
    }else{
        curMenuUser=user;
    }

    string menuCmd="MENU.REG.OPEN";
    string menuText;
    string menuParent="";
    list menuFeatureList=[];

    // 主菜单
    if(menuName=="mainMenu"){
        integer curTime=llGetUnixTime();
        string lockTimeDist=getTimeDistStr(lockTime, curTime);
        if(lockTimeDist!=""){
            lockTimeDist="\n"+getLanguageVar("Time: %1%%%;"+lockTimeDist);
        }

        menuText="Locked: %1% %2%\nOwner: %3%\nPublic: %b4%\nGroup: %b5%\nHardcore: %b6%%%;"+
            userInfo(lockUser)+";"+
            lockTimeDist+";"+
            userInfo(llList2Key(getRelationship("owner"), 0))+";"+
            // llDumpList2String(getOwnerNameList(), ", ")+";"+
            (string)public+";"+
            (string)group+";"+
            (string)hardcore
        ;

        if(isAllow!=-1){
            string lockStr="["+(string)isLocked+"]Lock";
            if(allowPermaLock==TRUE && isPermaLocked==TRUE){
                lockStr="PermaLocked";
            }
            menuFeatureList+=[lockStr];

            integer i;
            for(i=0; i<llGetListLength(initMenuList); i+=initMenuListLength){
                string mName=llList2String(initMenuList, i);
                integer mEnabled=llList2Integer(initMenuList, i+initMenuListLength-2);
                integer mReady=llList2Integer(initMenuList, i+initMenuListLength-1);
                if(mEnabled==TRUE && mReady==TRUE){
                    menuFeatureList+=[mName];
                }
            }

            if(llGetListLength(featureList)>0 && ~llListFindList(featureList, ["appMenu"])){
                menuFeatureList+=["Apps"];
            }

            menuFeatureList+=["Settings"];
            if(llGetListLength(featureList)>0 && ~llListFindList(featureList, ["mainMenu"])){
                menuFeatureList=applyFeatureList(menuName, menuFeatureList, featureList);
            }
        }else{
            list struggleMData=getInitMenuData(STRUGGLE_MSG_NUM);
            if(llGetListLength(struggleMData)>0){
                string sName=llList2String(struggleMData, 0);
                integer sEnabled=llList2Integer(struggleMData, -2);
                integer sReady=llList2Integer(struggleMData, -1);
                // 没权限时菜单内容
                if(sReady==TRUE && user==llGetOwner()){
                    menuFeatureList+=[sName];
                }
            }
            if(!hardcore && !REZ_MODE){ // 硬核模式未开启时，仅显示Escape按钮，菜单名使用AccessMenu以确保功能生效
                list accessMData=getInitMenuData(ACCESS_MSG_NUM);
                if(llGetListLength(accessMData)>0){
                    menuFeatureList+=[llList2String(accessMData, 0)];
                }
            }
            if(llGetListLength(menuFeatureList)<1){
                return;
            }
        }
        llMessageLinked(LINK_SET, MENU_MSG_NUM, "MENU.CLEAR", user);
    }
    // App菜单
    else if(menuName=="appMenu"){
        menuParent="mainMenu";
        menuText="This is apps menu.";
        menuFeatureList=applyFeatureList(menuName, [], featureList);
    }
    // 设置菜单
    else if(menuName=="settingMenu"){
        menuParent="mainMenu";
        menuText="This is settings menu.";
        if(hasLanguage){
            menuFeatureList+=["Language"];
        }
        // 永久锁定功能
        if(allowPermaLock==TRUE && isPermaLocked==FALSE && isLocked==TRUE && lockUser==user && ~llListFindList(getRelationship("owner"), [(string)user]) && hardcore==TRUE && REZ_MODE==FALSE && getInitMenuReady(RLV_MSG_NUM)){
            // 允许永久锁定 && 未被永久锁定 && 已上锁 && 操作者为上锁者 && 操作者在主人列表中 && 非REZ模式 && RLV就绪
            menuFeatureList+=["PermaLock"];
        }
        menuFeatureList=applyFeatureList(menuName, menuFeatureList, featureList);
    }
    // 永久锁定菜单
    else if(menuName=="permaLockMenu"){
        menuParent="settingMenu";
        menuText="%1% is requesting to PERMANENT LOCK your %2%, are you sure to be PERMANENT LOCKED?\nOnce confirmed, you will be permanently locked out and unable to unlock!%%;"+userInfo(user)+";"+llGetObjectName();
        menuFeatureList=[
            "YES", "NO"
        ];
        menuCmd="MENU.CONFIRM";
        
        user=llGetOwner(); // 必须重写user，让佩戴者弹出菜单，而不是操作者
    }
    llMessageLinked(LINK_SET, MENU_MSG_NUM, menuCmd+"|"+menuName+"|"+menuText+"|"+llDumpList2String(menuFeatureList, ";")+"|"+menuParent, user);
}

applyInitMenuReady(string callback, integer bool){
    integer index=llListFindList(initMenuList, [callback]);
    if(~index){
        initMenuList=llListReplaceList(initMenuList, [bool], index+2, index+2);
    }
}
integer getInitMenuReady(integer msgNum){
    integer i=llListFindList(initMenuList, [msgNum]);
    if(~i){
        return llList2Integer(initMenuList, i+initMenuListLength-2);
    }else{
        return FALSE;
    }
}
list getInitMenuData(integer msgNum){
    integer i=llListFindList(initMenuList, [msgNum]);
    if(~i){
        return llList2List(initMenuList, i-1, i+initMenuListLength-2);
    }else{
        return [];
    }
}

integer MAIN_MSG_NUM=9000;
integer CONF_MSG_NUM=8000;
integer MENU_MSG_NUM=1000;
integer RLV_MSG_NUM=1001;
integer RENAMER_MSG_NUM=10011;
integer RLVEXT_MSG_NUM=10012;
integer ACCESS_MSG_NUM=1002;
integer LAN_MSG_NUM=1003;
integer TIMER_MSG_NUM=1004;
integer LEASH_MSG_NUM=1005;
integer ANIM_MSG_NUM=1006;
integer STRUGGLE_MSG_NUM=1007;
integer TEXT_MSG_NUM=1008;
integer CAPTURE_MSG_NUM=1009;

integer allowPermaLock=FALSE;
integer allowSit=TRUE;

integer REZ_MODE=FALSE;
key VICTIM_UUID=NULL_KEY;

integer cmdChannel=1;
list cmdList=[];

integer attachFlag=TRUE;

integer timeoutRunning=FALSE;
integer timerFlag=0; // 0: None; 1: Menu timeout flag; 2: Init timeout flag
integer listenHandle;
integer initIndex=0;
float initTimer=0.1;

default{
	state_entry(){
		initMain();
        if(llGetAttached()){
            REZ_MODE=FALSE;
            VICTIM_UUID=llGetOwner();
        }else{
            REZ_MODE=TRUE;
            VICTIM_UUID=NULL_KEY;
        }
	}
	changed(integer change){
		if(change & CHANGED_OWNER){ // 物品易主时，重置脚本
			llResetScript();
		}
        if(change & CHANGED_INVENTORY){
            initMain();
        }
        if (change & CHANGED_LINK) {
            llSleep(0.1);
            REZ_MODE=TRUE;
			VICTIM_UUID=llAvatarOnSitTarget();
            // 重新坐下时，上锁状态恢复
            if(VICTIM_UUID!=NULL_KEY && isLocked==TRUE){
                setLock(isLocked, lockUser, FALSE);
            }
        }
		llMessageLinked(LINK_SET, MAIN_MSG_NUM, "MAIN.CHANGED|"+(string)change, NULL_KEY);
	}
	attach(key user){
		REZ_MODE=FALSE;
		VICTIM_UUID=llGetOwner();
		llMessageLinked(LINK_SET, MAIN_MSG_NUM, "MAIN.ATTACH|"+(string)user, VICTIM_UUID);
		// llMessageLinked(LINK_SET, STRUGGLE_MSG_NUM, "STRUGGLE.GET.READY", NULL_KEY);
	}
	on_rez(integer start_param){
		// 登录、穿戴时也会触发on_rez，并且比attach更早触发。有时候登录时不触发attach，因此将attach的部分也添加到这里。
		integer attached=llGetAttached();
		if(attached){
			REZ_MODE=FALSE;
			VICTIM_UUID=llGetOwner();
		}else{
			REZ_MODE=TRUE;
			VICTIM_UUID=NULL_KEY;
		}
		llMessageLinked(LINK_SET, MAIN_MSG_NUM, "MAIN.REZ|"+(string)start_param, VICTIM_UUID);
	}
	object_rez(key id){
		REZ_MODE=TRUE;
		VICTIM_UUID=NULL_KEY;
	}
	timer(){
		if(timerFlag==1){ // Menu timeout
			curMenuUser=NULL_KEY;
			timerFlag=0;
			llSetTimerEvent(0);
		}
        else if(timerFlag==2){ // Init timeout
            // Name, MsgNum, InitCmd, CallbackCmd, Enabled
            integer initNum=llList2Integer(initMenuList, initIndex+1);
            string initCmd=llList2String(initMenuList, initIndex+2);
            if(initCmd!=""){
                llMessageLinked(LINK_THIS, initNum, initCmd, NULL_KEY);
                initIndex+=initMenuListLength;
            }else{
                initIndex=0;
                llMessageLinked(LINK_SET, MAIN_MSG_NUM, "MAIN.INIT", NULL_KEY);
                llSetTimerEvent(0);
            }
        }
		else{
			llSetTimerEvent(0);
		}
	}
	touch_start(integer num_detected){
		showMenu("mainMenu", llDetectedKey(0));
		llMessageLinked(LINK_SET, MAIN_MSG_NUM, "MAIN.TOUCH|"+(string)num_detected, llDetectedKey(0));
	}
	listen(integer channel, string name, key id, string message){
		if(channel==cmdChannel){
            string prefix=llGetSubString(llGetUsername(llGetOwner()), 0, 1);
            if(llGetSubString(message, 0, 1) == prefix){
                key user=llGetOwnerKey(id); // 支持使用物品发出命令。user为说话者的uuid，因此需要获取它的所有者uuid。
                if(!allowOperate(user, FALSE)){
                    return;
                }
                string cmdBody=llToLower(llGetSubString(message, 2, -1));
                list cmdParams=llParseStringKeepNulls(cmdBody,[" "],[""]);
                integer cmdIndex=llListFindList(cmdList, [cmdBody]);
                if(~cmdIndex){
                    integer cmdMsgNum=llList2Integer(cmdList, cmdIndex+1);
                    string cmdLinkMsg=llList2String(cmdList, cmdIndex+2);
                    // 处理user转义
                    cmdLinkMsg=llReplaceSubString(cmdLinkMsg, "%user%", (string)user, 0);
                    // 处理参数转义
                    integer i;
                    for(i=0; i<llGetListLength(cmdParams); i++){
                        cmdLinkMsg=llReplaceSubString(cmdLinkMsg, "%param"+(string)i+"%", llList2String(cmdParams, i), 0);
                    }
                    llMessageLinked(LINK_THIS, cmdMsgNum, cmdLinkMsg, user);
                }
            }
            // llOwnerSay("NAME: "+name+" MSG: "+message);
        }
	}
	link_message(integer sender_num, integer num, string msg, key user){
		list msgList=strSplit(msg, "|");
		string msgHeader=llList2String(msgList, 0);
		string msg1=llList2String(msgList, 1);
		string msg2=llList2String(msgList, 2);
		string msg3=llList2String(msgList, 3);
		string msg4=llList2String(msgList, 4);

		if(num==MAIN_MSG_NUM){
			if(msgHeader=="FEATURE.REG"){ // FEATURE.REG | featureName | featurePrev | featureMenuName | featureBool
				if(msg3==""){
					msg3="appMenu";
				}
				if(msg4==""){
					msg4="-1";
				}
				registFeature(msg1, msg2, msg3, (integer)msg4);
			}
			/*
			更改主菜单条目名称
			MAIN.MENU.SET | MenuName | NewName
			*/
			else if(msgHeader=="MAIN.MENU.SET"){
				integer i;
				for(i=0; i<llGetListLength(initMenuList); i+=initMenuListLength){
					if(llList2String(initMenuList, i) == msg1){
						initMenuList=llListReplaceList(initMenuList, [msg2], i, i);
						return;
					}
				}
			}
			/*
			启用主菜单条目
			MAIN.MENU.ENABLE | MenuName | 1
			*/
			else if(msgHeader=="MAIN.MENU.ENABLE"){
				integer i;
				for(i=0; i<llGetListLength(initMenuList); i+=initMenuListLength){
					if(llList2String(initMenuList, i) == msg1){
						initMenuList=llListReplaceList(initMenuList, [(integer)msg2], i+initMenuListLength-2, i+initMenuListLength-2);
						return;
					}
				}
			}
			if(msgHeader=="MAIN.LOCK"){ // MAIN.LOCK | 1
                if(msg1==""){
                    msg1="-1";
                }
                setLock((integer)msg1, user, FALSE);
            }
            else if(msgHeader=="MAIN.MENU"){ // MAIN.MENU | 1
                showMenu("mainMenu", user);
            }
		}
		else if(num==MENU_MSG_NUM){
			if(msgHeader=="MENU.ACTIVE"){
				if(msg1=="mainMenu"){
					if(msg2 == "Lock"){
						setLock(!isLocked, user, TRUE);
					}
					else if(msg2=="PermaLocked"){
						llMessageLinked(LINK_SET, MENU_MSG_NUM, "MENU.OUT.SAY|%1% is PERMANENT LOCKED by %2%!%%;"+userInfo(llGetOwner())+";"+userInfo(lockUser), NULL_KEY);
					}
					else if(msg2=="Apps"){
						showMenu("appMenu", user);
					}
					else if(msg2=="Settings"){
						showMenu("settingMenu", user);
					}
				}
				else if(msg1=="settingMenu"){
					if(msg2=="PermaLock"){
						showMenu("permaLockMenu", user);
					}
				}
				else if(msg1=="permaLockMenu"){
					if(user != llGetOwner()){
						return;
					}
					if(msg2=="YES"){
						isPermaLocked=TRUE;
						llMessageLinked(LINK_SET, MENU_MSG_NUM, "MENU.OUT.TO|You are permanent locked by %1%!%%;"+userInfo(lockUser), llGetOwner());
						llMessageLinked(LINK_SET, MENU_MSG_NUM, "MENU.OUT.TO|You permanent locked %1%!%%;"+userInfo(lockUser), lockUser);
						llMessageLinked(LINK_SET, MAIN_MSG_NUM, "MAIN.SET.PERMALOCK|"+(string)isPermaLocked, lockUser);
					}
					else if(msg2=="NO"){
						llMessageLinked(LINK_SET, MENU_MSG_NUM, "MENU.OUT.TO|%1% refused to accept your permanent lock request!%%;"+userInfo(lockUser), lockUser);
					}
					return;
				}
			}
			else if(msgHeader=="MENU.CLOSE"){
				curMenuUser=NULL_KEY;
				timerFlag=0;
				llSetTimerEvent(0);
			}
		}
		else if(num==RLV_MSG_NUM){
			list rlvCmdData=strSplit(msg2, ";");

			if(msgHeader=="RLV.EXEC"){
				if(msg1=="RLV.GET.LOCK" || msg1=="RLV.LOCK"){
					isLocked=llList2Integer(rlvCmdData, 0);
					lockUser=llList2Key(rlvCmdData, 1);
					string lockStr="detach";
					if(REZ_MODE==1){
						lockStr="unsit";
					}
					if(isLocked){
						lockTime=llGetUnixTime();
						llMessageLinked(LINK_SET, RLV_MSG_NUM, "RLV.RUN.TEMP|"+lockStr+"=n", NULL_KEY);
					}else{
						lockTime=0;
						llMessageLinked(LINK_SET, RLV_MSG_NUM, "RLV.RUN.TEMP|"+lockStr+"=y", NULL_KEY);
					}
					// llMessageLinked(LINK_SET, STRUGGLE_MSG_NUM, "STRUGGLE.GET.READY", NULL_KEY);
				}
			}
			if(msgHeader=="RLV.LOAD.NOTECARD"){
                applyInitMenuReady(msgHeader, TRUE);
				llMessageLinked(LINK_SET, RLV_MSG_NUM, "RLV.GET.LOCK", NULL_KEY);
			}
		}
		else if(num==RENAMER_MSG_NUM){
			if(msgHeader=="RENAMER.LOAD.NOTECARD"){
				applyInitMenuReady(msgHeader, TRUE);
			}
		}
		else if(num==ACCESS_MSG_NUM){
			// 权限功能监听
			if(msgHeader=="ACCESS.NOTIFY"){
				if(msg1=="OWNER" || msg1=="TRUST" || msg1=="BLACK"){
					integer accessIndex=llListFindList(relationshipList, [llToLower(msg1)]);
					if(~accessIndex){
						relationshipList=llListReplaceList(relationshipList, [msg2], accessIndex+1, accessIndex+1);
					}else{
						relationshipList+=[llToLower(msg1), msg2]; // ["owner", "uuid1;uuid2;...", "trust", "uuid1;uuid2;...", "black", "uuid1;uuid2;..."]
					}
				}
				else if(msg1=="MODE"){ // ACCESS.NOTIFY | MODE | PUBLIC; GROUP; HARDCORE
					list accessData=strSplit(msg2, ";");
					public=llList2Integer(accessData, 0);
					group=llList2Integer(accessData, 1);
					hardcore=llList2Integer(accessData, 2);
					autoLock=llList2Integer(accessData, 3);
				}
			}else if(msgHeader=="ACCESS.EXEC"){
				list accessData=strSplit(msg2, ";");
				if(msg1=="ACCESS.RESET" && msg2=="1"){ // Access重置（逃跑）时，解锁
					relationshipList=[];
					setLock(FALSE, NULL_KEY, FALSE);
				}
			}else if(msgHeader=="ACCESS.LOAD.NOTECARD"){
				applyInitMenuReady(msgHeader, TRUE);
				llMessageLinked(LINK_SET, RLV_MSG_NUM, "RLV.GET.LOCK", NULL_KEY);
			}
		}
		else if(num==LAN_MSG_NUM){
			// 语言功能监听
			if (includes(msg, "LANGUAGE.EXEC") && includes(msg, "INIT")) { // 接收语言系统INIT回调，并启用语言功能
                hasLanguage=TRUE;
				applyInitMenuReady(msgHeader, TRUE);
			}
		}
		else if(num==TIMER_MSG_NUM){
			// 计时器功能监听
			if(msgHeader=="TIMER.LOAD.NOTECARD"){
				applyInitMenuReady(msgHeader, TRUE);
			}
			else if (msgHeader=="TIMER.TIMEOUT") { // 接收计时器系统回调
				timeoutRunning=FALSE;
				if(isLocked){
					setLock(FALSE, NULL_KEY, FALSE); // 计时结束时，解锁
				}
			}
			else if (msgHeader=="TIMER.RUNNING") { // 接收计时器系统回调
				timeoutRunning=TRUE;
			}
			else if (msgHeader=="TIMER.SETRUNNING") { // 接收计时器系统回调
				timeoutRunning=FALSE;
			}
		}
		else if(num==LEASH_MSG_NUM){
			if(msgHeader=="LEASH.LOAD.NOTECARD"){
				applyInitMenuReady(msgHeader, TRUE);
			}
		}
		else if(num==ANIM_MSG_NUM){
			if(msgHeader=="ANIM.LOAD.NOTECARD"){
				applyInitMenuReady(msgHeader, TRUE);
			}
		}
		else if(num==STRUGGLE_MSG_NUM){
			if(msgHeader=="STRUGGLE.LOAD.NOTECARD"){
				applyInitMenuReady(msgHeader, TRUE);
			}
			// 挣扎功能监听
			if (msgHeader=="STRUGGLE.APPLY.SUCCESS") { // 接收挣扎系统回调
				if(isLocked){
					setLock(FALSE, NULL_KEY, FALSE); // 挣扎成功时，解锁
				}
			}
		}
		else if(num==TEXT_MSG_NUM){
			if(msgHeader=="TEXT.READY"){
				applyInitMenuReady(msgHeader, TRUE);
			}
		}
		else if(num==CAPTURE_MSG_NUM){
			if(msgHeader=="CAPTURE.LOAD.NOTECARD"){
				applyInitMenuReady(msgHeader, TRUE);
			}
		}

        // llSleep(0.01);
        // llOwnerSay("RLV Memory Used: "+(string)llGetUsedMemory()+"/"+(string)(65536-llGetUsedMemory())+" Free: "+(string)llGetFreeMemory());
	}
	run_time_permissions(integer perm){
		if (perm & PERMISSION_ATTACH){
			if(attachFlag==FALSE){
				llDetachFromAvatar();
			}
		}
	}
}

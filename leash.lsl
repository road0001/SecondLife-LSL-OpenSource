/*
Name: Leash
Author: JMRY
Description: A better leash control system, use link_message to operate leashes.

***更新记录***
- 1.0.4 20260114
	- 优化牵引算法，修复内存溢出的bug。

- 1.0.3 20260113
	- 调整牵引带（Leash holder）消息内容，提升兼容性。
	- 优化牵引启动算法，提升速度。
	- 修复rez物品的牵引会反复要求授权的bug。

- 1.0.2 20260111
    - 加入接收到RLV清空（@clear）通知时，重新应用严格模式限制。
    - 加入牵引带（Leash holder）支持。
    - 优化严格模式RLV处理逻辑。
	- 优化跟随逻辑，提升顺畅度。
	- 修复各种错误和bugs。

- 1.0.1 20260109
    - 完成牵绳菜单和配置功能。

- 1.0 20260107
    - 初步完成牵绳功能。
***更新记录***
*/

/*
TODO:
- 兼容LockGuard和LockMeisger。
*/

/*
基础功能依赖函数
*/
string userInfo(key user){
	if(llGetAgentSize(user) != ZERO_VECTOR){
		return "secondlife:///app/agent/"+(string)user+"/about";
	}else{
		list objDetails=llGetObjectDetails(user, [OBJECT_NAME, OBJECT_OWNER]);
		return "secondlife:///app/objectim/"+(string)user+"?name="+llEscapeURL(llList2String(objDetails, 0))+"&owner="+llList2String(objDetails, 1);
	}
}

string userName(key user, integer type){
    string username=llGetUsername(user);
    string displayname=llGetDisplayName(user);
    if(type==1){
        return username;
    }else if(type==2){
        return displayname;
    }else{
        return displayname+" ("+username+")";
    }
}


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

// string trim(string k){
//     return llStringTrim(k, STRING_TRIM);
// }

list strSplit(string m, string sp){
    list pl=llParseStringKeepNulls(m,[sp],[""]);
    list temp=[];
    integer i;
    for(i=0; i<llGetListLength(pl); i++){
        temp+=[llStringTrim(llList2String(pl, i), STRING_TRIM)];
    }
    return temp;
}
string strJoin(list m, string sp){
    return llDumpList2String(m, sp);
}

// string bundleSplit="&&";
list bundle2List(string b){
    return strSplit(b, "&&");
}
string list2Bundle(list b){
    return strJoin(b, "&&");
}

// string messageSplit="|";
list msg2List(string m){
    return strSplit(m, "|");
}
string list2Msg(list m){
    return strJoin(m, "|");
}

// string dataSplit=";";
list data2List(string d){
    return strSplit(d, ";");
}
string list2Data(list d){
    return strJoin(d, ";");
}
string list2RlvData(list d){
    return strJoin(d, ",");
}

/*
连接点查找
*/
list getLinksByName(string name){
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

/*
粒子系统配置
*/
// Particles默认配置，可以在配置文件里修改
list leashConfig=[
    "particleEnabled",         "1",
    "particleMode",         "Ribbon", // Ribbon, Chain, Leather, Rope, None
    "particleMaxAge",         "3.5",
    "particleColor",         "<1.0,1.0,1.0>",
    "particleScale",         "<0.04,0.04,1.0>",
    "particleBurstRate",    "0.0",
    "particleGravity",         "<0.0,0.0,-1.0>",
    "particleCount",         "1",
    "particleFullBright",    "1",
    "particleGlow",            "0.2",
    "particleTextureRibbon","cdb7025a-9283-17d9-8d20-cee010f36e90",
    "particleTextureChain", "4cde01ac-4279-2742-71e1-47ff81cc3529",
    "particleTextureLeather","8f4c3616-46a4-1ed6-37dc-9705b754b7f1",
    "particleTextureRope",     "9a342cda-d62a-ae1f-fc32-a77a24a85d73",
    "particleTextureNone",     "8dcd4a48-2d37-4909-9f78-f7a9eb4ef903", // TEXTURE_TRANSPARENT
    "particleColorList",    "White;<1.0,1.0,1.0>;Black;<0.0,0.0,0.0>;Gray;<0.5,0.5,0.5>;Red;<1.0,0.0,0.0>;Green;<0.0,1.0,0.0>;Blue;<0.0,0.0,1.0>;Yellow;<1.0,1.0,0.0>;Pink;<1.0,0.5,0.6>;Brown;<0.2,0.1,0.0>;Purple;<0.6,0.2,0.7>;Barbie;<0.9,0.0,0.3>;Orange;<0.9,0.6,0.0>;Toad;<0.2,0.2,0.0>;Khaki;<0.6,0.5,0.3>;Pool;<0.1,0.8,0.9>;Blood;<0.5,0.0,0.0>;Anthracite;<0.1,0.1,0.1>;Midnight;<0.0,0.1,0.2>",

    "leashPointName",         "leashpoint",
    "leashLength",             "3",
    "leashTurnMode",         "1",
    "leashStrictMode",         "0",
    "leashAwait",             "0.2",
    "leashMaxRange",        "60",
    "leashPosOffset",        "<0.0,0.0,0.0>"
];
string setConfig(string k, string v){
    integer index=llListFindList(leashConfig, [k]);
    if(~index){
        leashConfig=llListReplaceList(leashConfig,[v],index+1,index+1);
    }else{
        leashConfig+=[k, v];
    }
    return v;
}
string getConfig(string k){
    if(k==""){
        return list2Data(leashConfig);
        // list configList=[];
        // integer i;
        // for(i=0; i<llGetListLength(leashConfig); i++){
        //     if(i%2!=0){
        //         configList+=llList2String(leashConfig, i);
        //     }
        // }
        // return list2Data(configList);
    }
    integer index=llListFindList(leashConfig, [k]);
    if(~index){
        return llList2String(leashConfig, index+1);
    }else{
        return "";
    }
}

string getParticleColor(string colorName, string colorVector){
    list colorList=data2List(getConfig("particleColorList"));
    integer i;
    for(i=0; i<llGetListLength(colorList); i++){
        string curColor=llList2String(colorList, i);
        if(colorName!=""){ // ColorName => ColorVector
            if(curColor==colorName){
                return llList2String(colorList, i+1); // return is string, need to transfer to vector to use
            }
        }else{ // ColorVector => ColorName
            if(colorVector==curColor){
                return llList2String(colorList, i-1);
            }
        }
    }
    return "";
}

/*
链条粒子系统
*/
// activeParticles(integer link, key target, string particleMode, key particleTexture, vector particleScale, vector particleColor, vector particleGravity, integer particleCount, integer particleFullBright, float particleGlow, float particleMaxAge, float particleBurstRate){
//     if(particleMode=="None"){
//         stopParticles();
//         return;
//     }
//     if(target==NULL_KEY){
//         return;
//     }
//     integer particleFlags = PSYS_PART_FOLLOW_VELOCITY_MASK | PSYS_PART_TARGET_POS_MASK | PSYS_PART_FOLLOW_SRC_MASK;
//     if(particleMode == "Ribbon"){
//         particleFlags = particleFlags | PSYS_PART_RIBBON_MASK;
//     }
//     if(particleFullBright){
//         particleFlags = particleFlags | PSYS_PART_EMISSIVE_MASK;
//     }
//     list particleParams = [
//         PSYS_PART_MAX_AGE,particleMaxAge,
//         PSYS_PART_FLAGS,particleFlags,
//         PSYS_PART_START_COLOR, particleColor,
//         //PSYS_PART_END_COLOR, g_vLeashColor,
//         PSYS_PART_START_SCALE,particleScale,
//         //PSYS_PART_END_SCALE,g_vLeashSize,
//         PSYS_SRC_PATTERN, PSYS_SRC_PATTERN_DROP,
//         PSYS_SRC_BURST_RATE,particleBurstRate,
//         PSYS_SRC_ACCEL, particleGravity,
//         PSYS_SRC_BURST_PART_COUNT,particleCount,
//         //PSYS_SRC_BURST_SPEED_MIN,fMinSpeed,
//         //PSYS_SRC_BURST_SPEED_MAX,fMaxSpeed,
// 		PSYS_PART_START_GLOW,particleGlow,
//         PSYS_SRC_TARGET_KEY,target,
//         PSYS_SRC_MAX_AGE, 0,
//         PSYS_SRC_TEXTURE, particleTexture
//     ];
//     llLinkParticleSystem(link, particleParams);
// }

key startParticles(key target){
	stopParticles();
    if(target==NULL_KEY){
        return target;
    }
    string particleMode=getConfig("particleMode");
    if(particleMode=="None"){
        return NULL_KEY;
    }

    key particleTexture=(key)getConfig("particleTexture"+particleMode);
    if(particleTexture==""){
        particleTexture=TEXTURE_TRANSPARENT;
    }

	// activeParticles
	integer particleFlags = PSYS_PART_FOLLOW_VELOCITY_MASK | PSYS_PART_TARGET_POS_MASK | PSYS_PART_FOLLOW_SRC_MASK;
	if(particleMode == "Ribbon"){
		particleFlags = particleFlags | PSYS_PART_RIBBON_MASK;
	}
	if((integer)getConfig("particleFullBright")){
		particleFlags = particleFlags | PSYS_PART_EMISSIVE_MASK;
	}
	list particleParams = [
		PSYS_PART_MAX_AGE,(float)getConfig("particleMaxAge"),
		PSYS_PART_FLAGS,particleFlags,
		PSYS_PART_START_COLOR, (vector)getConfig("particleColor"),
		//PSYS_PART_END_COLOR, g_vLeashColor,
		PSYS_PART_START_SCALE,(vector)getConfig("particleScale"),
		//PSYS_PART_END_SCALE,g_vLeashSize,
		PSYS_SRC_PATTERN, PSYS_SRC_PATTERN_DROP,
		PSYS_SRC_BURST_RATE,(float)getConfig("particleBurstRate"),
		PSYS_SRC_ACCEL, (vector)getConfig("particleGravity"),
		PSYS_SRC_BURST_PART_COUNT,(integer)getConfig("particleCount"),
		//PSYS_SRC_BURST_SPEED_MIN,fMinSpeed,
		//PSYS_SRC_BURST_SPEED_MAX,fMaxSpeed,
		PSYS_PART_START_GLOW,(float)getConfig("particleGlow"),
		PSYS_SRC_TARGET_KEY,target,
		PSYS_SRC_MAX_AGE, 0,
		PSYS_SRC_TEXTURE, particleTexture
	];

	integer i;
	list leashPoints=getLinksByName(getConfig("leashPointName"));
	if(llGetListLength(leashPoints)<=0){
		leashPoints+=[LINK_SET]; // No leashpoints, use link_set
	}
    for(i=0; i<llGetListLength(leashPoints); i++){
        // activeParticles(llList2Integer(leashPoints, i), target, particleMode, particleTexture, particleScale, particleColor, particleGravity, particleCount, particleFullBright, particleGlow, particleMaxAge, particleBurstRate);
		llLinkParticleSystem(llList2Integer(leashPoints, i), particleParams);
    }
    return target;
}

stopParticles() {
    list leashPoints=getLinksByName(getConfig("leashPointName"));
    integer i;
    for(i=0; i<llGetListLength(leashPoints); i++){
        llLinkParticleSystem(llList2Integer(leashPoints, i), []);
    }
}

/*
牵引系统
*/
key leashTarget=NULL_KEY;
integer leashParticleEnabled;
float leashLength;
integer leashHolderHandle;
integer allowAutoTurn=FALSE;
key leashToTarget(key target, integer particleEnabled){
    leashTarget=target;
    leashParticleEnabled=particleEnabled;

    if(leashTarget!=NULL_KEY){ // Leash
        leashLength=(float)getConfig("leashLength");

		if(REZ_MODE==FALSE){
        	llRequestPermissions(llGetOwner(),PERMISSION_TRIGGER_ANIMATION); // Request auto turn perm
		}
		timerCount=0;
        llSetTimerEvent((float)getConfig("leashAwait")); // Move to target in timer

        if(particleEnabled==TRUE){
            startParticles(leashTarget);
            leashHolderHandle=llListen(CHANNEL_LOCK_MEISTER, "", NULL_KEY, "");
        }else{
            stopParticles();
            llListenRemove(leashHolderHandle);
        }
    }else{ // Unleash
        stopParticles();
        llSetTimerEvent(0);
        llListenRemove(leashHolderHandle);
    }
    applyStrictMode();
    return target;
}

integer leashStrictFlag=FALSE;
applyStrictMode(){
    string strictRestraints="fly=n,tplm=n,tplure=n,tploc=n,tplure:"+(string)leashTarget+"=add,sittp=n,accepttp:"+(string)leashTarget+"=add";
    if((integer)getConfig("leashStrictMode")==TRUE){
        if(leashTarget==NULL_KEY) return;
        llMessageLinked(LINK_SET, RLV_MSG_NUM, "RLV.RUN.TEMP|"+strictRestraints, NULL_KEY);
        leashStrictFlag=TRUE;
    }else if((integer)getConfig("leashStrictMode")==FALSE || leashTarget==NULL_KEY){
        if(leashStrictFlag==TRUE){ // 严格模式RLV限制清除，只有触发过严格模式才进行。临时执行取消限制后，重新执行记录的RLV限制
            llMessageLinked(LINK_SET, RLV_MSG_NUM, "RLV.RUN.TEMP|"+replace(replace(strictRestraints, "=add", "=rem"), "=n", "=y")+"&&RLV.RUN", NULL_KEY);
            leashStrictFlag=FALSE;
        }
    }
}

key yankToTarget(key target){
    if (llGetAgentInfo(llGetOwner()) & AGENT_SITTING){
        llMessageLinked(LINK_SET, RLV_MSG_NUM, "RLV.RUN.TEMP|unsit=force", NULL_KEY);
    }
    llMoveToTarget(llList2Vector(llGetObjectDetails(target, [OBJECT_POS]), 0), 0.5);
    llSleep(2.0);
    llStopMoveToTarget();
    return target;
}

/*
权限控制
*/
list owner=[];
integer checkOwner(key user){
    integer index=llListFindList(owner, [(string)user]); // 从link_message接收的list被直接转化为了string的list而没转成key，因此要将key转成string再判断。
    if(~index){
        return TRUE;
    }else{
        return FALSE;
    }
}


string leashMenuText="Leash";
string leashMenuName="LeashMenu";
string leashParentMenuName="";
showLeashMenu(string parent, key user){
    leashParentMenuName=parent;

    string grabBu="-";
    string unleashBu="-";
    string yankBu="-";
    string styleBu="-";
    string configBu="-";
    string statusText="";
    if(user!=llGetOwner()){
        grabBu="Grab";
    }
    if(leashTarget!=NULL_KEY){
        unleashBu="Unleash";
        yankBu="Yank";
        if(leashParticleEnabled==FALSE){
            unleashBu="Unfollow";
            statusText="Following: ";
        }else{
            statusText="Leashed to: ";
        }
    }
    if(checkOwner(user)){ // 只有Root和Owner才能修改配置
        styleBu="Style";
        configBu="Config";
    }

    string leashMenuText="This is leash menu.\n%1%%2%%%;"+
        statusText+";"+
        userInfo(leashTarget);

    list leashMenuList=[
        grabBu,unleashBu,yankBu,
        "Follow","Anchor","Pass",
        "Length",styleBu,configBu
    ];

    llMessageLinked(LINK_SET, MENU_MSG_NUM, "MENU.REG.OPEN|"+leashMenuName+"|"+leashMenuText+"|"+list2Data(leashMenuList)+"|"+parent, user);
	leashMenuText="";
	leashMenuList=[];
}

list sensorUserList=[];
string leashSubMenuName="LeashSubMenu";
string leashSubMenuParent="";
string leashSubMenuFlag="";
key leashSubMenuUser=NULL_KEY;
showLeashSubMenu(string menuName, string parent, key user, integer reset){
    leashSubMenuParent=parent;
    leashSubMenuFlag=menuName;
	leashSubMenuUser=user;
    string menuText="";
    list buttonList=[];
    if(menuName=="Follow" || menuName=="Pass"){
        menuText="Select user to %1%.%%;"+menuName;
        integer i;
        for(i=0; i<18; i++){
            key uk=llList2Key(sensorUserList, i);
            if(uk){
                string un=userName(uk,1);
                // userList+=[(string)(i+1) + ". " + un];
                buttonList+=[(string)(i+1) + ". " + un];
            }
        }
    }
    else if(menuName=="Anchor"){
        menuText="Select object to %1%.%%;"+menuName;
        integer i;
        for(i=0; i<27; i++){
            key uk=llList2Key(sensorUserList, i);
            if(uk){
                string un=llList2String(llGetObjectDetails(uk, [OBJECT_NAME]), 0);
                // userList+=[(string)(i+1) + ". " + un];
                buttonList+=[(string)(i+1) + ". " + un];
            }
        }
    }
    else if(menuName=="Length"){
        menuText="Current leash length: %1%.%%;"+getConfig("leashLength");
        integer i;
        for(i=1; i<=6; i++){
            buttonList+=[i];
        }
        for(i=10; i<=20; i+=5){
            buttonList+=[i];
        }
    }
    else if(menuName=="Style"){
        menuText="Choose a style and color for leash.\nCurrent size: %1%\nCurrent weight: %2%\nCurrent glow: %3%\nCurrent shine: %b4%\nCurrent color: %5%%%;"+
			getConfig("particleScale")+";"+
            getConfig("particleGravity")+";"+
            getConfig("particleGlow")+";"+
            getConfig("particleFullBright")+";"+
            getParticleColor("", getConfig("particleColor"));

        buttonList=[
            "Bigger", "Smaller", "Glow",
            "Heavier", "Lighter", "["+(string)(getConfig("particleFullBright")=="1")+"]Shine",
            "["+(string)(getConfig("particleMode")=="Chain")+"]Chain", "["+(string)(getConfig("particleMode")=="Ribbon")+"]Ribbon", "["+(string)(getConfig("particleMode")=="None")+"]None"
        ];
        list colorList=data2List(getConfig("particleColorList"));
        integer i;
        for(i=0; i<llGetListLength(colorList); i+=2){
            buttonList+=llList2String(colorList, i);
        }
    }
    else if(menuName=="Config"){
        menuText="Configs of leash.";
        buttonList=[
            "["+getConfig("leashTurnMode")+"]Turn", "["+getConfig("leashStrictMode")+"]Strict"
        ];
    }
	string menuRegOpen="MENU.REG.OPEN";
	if(reset==TRUE){
		menuRegOpen="MENU.REG.OPEN.RESET";
	}
    llMessageLinked(LINK_SET, MENU_MSG_NUM, menuRegOpen+"|"+leashSubMenuName+"|"+menuText+"|"+list2Data(buttonList)+"|"+parent, user);
	menuText="";
	buttonList=[];
}

/*
配置文件读取
*/
key readLeashQuery=NULL_KEY;
integer readLeashLine=0;
string leashHeader="leash_";
string readLeashName="";
string curLeashName="";
integer readLeashNotecards(string aname){
    readLeashLine=0;
    curLeashName=aname;
    readLeashName=leashHeader+aname;
    if (llGetInventoryType(readLeashName) == INVENTORY_NOTECARD) {
        llOwnerSay("Begin reading leash settings: "+aname);
        readLeashQuery=llGetNotecardLine(readLeashName, readLeashLine); // 通过给readLeashQuery赋llGetNotecardLine的key，从而触发datasever事件
        // 后续功能交给下方datasever处理
        return TRUE;
    }else{
        return FALSE;
    }
}

list getLeashNotecards(){
    list leashList=[];
    integer count = llGetInventoryNumber(INVENTORY_NOTECARD);
    integer i;
    for (i=0; i<count; i++){
        string notecardName = llGetInventoryName(INVENTORY_NOTECARD, i);
        if(llGetSubString(notecardName, 0, llStringLength(leashHeader)-1)==leashHeader){
            leashList+=[llGetSubString(notecardName, llStringLength(leashHeader), -1)];
        }
    }
    return leashList;
}

integer MENU_MSG_NUM=1000;
integer RLV_MSG_NUM=1001;
integer ACCESS_MSG_NUM=1002;
integer LAN_MSG_NUM=1003;
integer LEASH_MSG_NUM=1005;
integer CHANNEL_LOCK_MEISTER = -8888;
integer CHANNEL_LOCK_GUARD   = -9119;

// integer leashPulling=FALSE;
// float leashZoneEdge=0.5;
integer REZ_MODE=FALSE;
integer timerCount=0;
default{
    state_entry(){
        // TODO: Read config notecard
    }
    changed(integer change){
        if(change & CHANGED_OWNER){
            llResetScript();
        }
    }
    attach(key user){
        if(user!=NULL_KEY){
            if(leashTarget!=NULL_KEY){
                leashToTarget(leashTarget, leashParticleEnabled);
				llMessageLinked(LINK_SET, ACCESS_MSG_NUM, "ACCESS.GET.NOTIFY", user);
            }
			REZ_MODE=FALSE;
        }
    }
	on_rez(integer start_param){
        // 登录、穿戴时也会触发on_rez，并且比attach更早触发。有时候登录时不触发attach，因此将attach的部分也添加到这里。
        integer attached=llGetAttached();
        if(attached>0){
            REZ_MODE=FALSE;
        }else{
            REZ_MODE=TRUE;
        }
    }
	object_rez(key user){
        REZ_MODE=TRUE;
    }
    listen(integer channel, string name, key id, string msg){
        if(channel == CHANNEL_LOCK_MEISTER){
            /*
            Leash Holder监听
            */
			if(leashParticleEnabled==TRUE){
				if(llGetOwnerKey(id) == leashTarget){
					if(msg=="handle ok"){ // Ready时，粒子向holder发射
						startParticles(id);
					}else if(msg=="handle detached"){ // 脱下时，粒子向角色发射
						startParticles(leashTarget);
					}
				}else{
					startParticles(leashTarget);
				}
			}
        }
    }
    timer() {
		vector avatarPos = llGetPos();
		vector targetPos = llList2Vector(llGetObjectDetails(leashTarget, [OBJECT_POS]), 0);
		integer targetInRange=TRUE;
		// if(targetPos == ZERO_VECTOR || llVecDist(llGetPos(), targetPos)> 255){
		if(targetPos == ZERO_VECTOR || llVecDist(avatarPos, targetPos)> (float)getConfig("leashMaxRange")){
			targetInRange=FALSE;
		}
		if(targetInRange){
			float distance = llVecDist(targetPos, avatarPos);
			if(distance>=leashLength){
				vector dir = llVecNorm(avatarPos - targetPos);
				vector desiredPos = targetPos + dir * (leashLength-0.2) + (vector)getConfig("leashPosOffset");
				llMoveToTarget(desiredPos, 0.8); // 平滑地跟随
				if((integer)getConfig("leashTurnMode")==TRUE && allowAutoTurn==TRUE && timerCount%10==0){
					vector faceDir = llVecNorm(targetPos - avatarPos);
					rotation rot = llRotBetween(<1,0,0>, faceDir);
					llSetAgentRot(rot, 0);
				}
				/*
				TODO：抖动问题存疑，防抖机制暂留。
				*/
				// if (!leashPulling && distance > (leashLength + leashZoneEdge)){
				// 	leashPulling=TRUE;
				// }
				// if (leashPulling && distance < (leashLength - leashZoneEdge)){
				// 	leashPulling=FALSE;
				// }
				// if(leashPulling){
				// 	vector dir = llVecNorm(avatarPos - targetPos);
				// 	vector desiredPos = targetPos + dir * leashLength + (vector)getConfig("leashPosOffset");
				// 	llMoveToTarget(desiredPos, 0.8); // 平滑地跟随
				// 	if((integer)getConfig("leashTurnMode")==TRUE && allowAutoTurn==TRUE){
				// 		vector faceDir = llVecNorm(targetPos - avatarPos);
				// 		rotation rot = llRotBetween(<1,0,0>, faceDir);
				// 		llSetAgentRot(rot, 0);
				// 	}
				// }
			}else{
				llStopMoveToTarget();
			}
		}
		timerCount+=1;
    }
    run_time_permissions(integer perm) {
        if(perm & PERMISSION_TRIGGER_ANIMATION){
            allowAutoTurn=TRUE;
        }
    }
    link_message(integer sender_num, integer num, string msg, key user){
        if(num!=LEASH_MSG_NUM && num!=MENU_MSG_NUM && num!=ACCESS_MSG_NUM && num!=LAN_MSG_NUM){
            return;
        }

        list msgList=bundle2List(msg);
        list resultList=[];
        integer msgCount=llGetListLength(msgList);
        integer mi;
        for(mi=0; mi<msgCount; mi++){
            string str=llList2String(msgList, mi);
            if (llGetSubString(str, 0, 5) == "LEASH." && !includes(str, "EXEC")) {
                list leashMsgList=msg2List(str);
                string leashMsgStr=llList2String(leashMsgList, 0);
                list leashMsgGroup=llParseStringKeepNulls(leashMsgStr, ["."], [""]);

                string leashMsg=llList2String(leashMsgGroup, 0);
                string leashMsgSub=llList2String(leashMsgGroup, 1);
                string leashMsgExt=llList2String(leashMsgGroup, 2);

                string leashMsgName=llList2String(leashMsgList, 1);
                string leashMsgCmd=llList2String(leashMsgList, 2);

                string result="";
                if(leashMsgSub=="SET"){
                    /*
                    更改配置：LEASH.SET | ConfigName | ConfigValue
                    */
                    result=setConfig(leashMsgName, leashMsgCmd);
					leashToTarget(leashTarget, leashParticleEnabled);
                }
                else if(leashMsgSub=="GET"){
                    /*
                    获取配置：LEASH.GET | ConfigName
                    */
                    result=getConfig(leashMsgName);
                }
                else if(leashMsgSub=="TO"){
                    /*
                    牵引目标：LEASH.TO | targetId | particleEnabled
                    目标ID为空时，则为取消牵引
                    粒子效果为空时，则按默认配置
                    */
                    if(leashMsgName==""){
                        leashMsgName=(string)NULL_KEY;
                    }
                    if(leashMsgCmd==""){
                        leashMsgCmd=getConfig("particleEnabled");
                    }
                    result=(string)leashToTarget((key)leashMsgName, (integer)leashMsgCmd);
                }
                else if(leashMsgSub=="YANK"){
                    /*
                    将目标拉到身边：LEASH.YANK | targetId
                    目标ID为空时，则为当前牵引的目标
                    */
                    if(leashMsgName==""){
                        leashMsgName=(string)leashTarget;
                    }
                    result=(string)yankToTarget((key)leashMsgName);
                }
                else if(leashMsgSub=="PARTICLE"){
                    /*
                    仅显示牵引链条：LEASH.PARTICLE | targetId
                    目标ID为空时，则为取消链条
                    */
                    if(leashMsgName==""){
                        leashMsgName=(string)NULL_KEY;
                    }
                    result=(string)startParticles((key)leashMsgName);
                }
                else if(leashMsgSub=="LOAD"){
                    /*
                    读取Leash记事卡
                    LEASH.LOAD | file1
                    回调：
                    LEASH.EXEC | LEASH.LOAD | 1
                    读取记事卡成功后的回调
                    LEASH.LOAD.NOTECARD | file1 | 1
                    */
                    if(leashMsgExt==""){
                        result=(string)readLeashNotecards(leashMsgName);
                    }
                    /*
                    读取Leash记事卡列表
                    LEASH.LOAD.LIST
                    回调：
                    LEASH.EXEC | LEASH.LOAD.LIST | leash_1, leash_2, leash_3, ...
                    */
                    if(leashMsgExt=="LIST"){
                        result=(string)list2Data(getLeashNotecards());
                    }
                }
                else if(leashMsgSub=="MENU"){
                    /*
                    显示菜单
                    LEASH.MENU | 上级菜单名
                    */
                    showLeashMenu(leashMsgName, user);
                }
                
                if(result!=""){
                    list leashExeResult=[
                        "LEASH.EXEC", leashMsgStr, result
                    ];
                    resultList+=[list2Msg(leashExeResult)];
                }
            }
            else if(llGetSubString(str, 0, 4) == "MENU." && includes(str, "ACTIVE")) {
                // MENU.ACTIVE | mainMenu | Access
                list menuCmdList=msg2List(str);
                string menuName=llList2String(menuCmdList, 1);
                string menuButton=llList2String(menuCmdList, 2);

                if(menuButton==leashMenuText){
                    showLeashMenu(menuName, user);
                }
                else if(menuName==leashMenuName && menuButton!=""){
                    integer leashMenuFlag=-999;
                    if(menuButton=="Grab"){
                        leashToTarget(user, TRUE);
                        leashMenuFlag=1;
                    }
                    else if(menuButton=="Unleash" || menuButton=="Unfollow"){
                        leashToTarget(NULL_KEY, FALSE);
                        leashMenuFlag=2;
                    }
                    else if(menuButton=="Yank"){
                        yankToTarget(user);
                        leashMenuFlag=3;
                    }
					else if(menuButton=="Follow" || menuButton=="Pass" || menuButton=="Anchor"){
						leashSubMenuFlag=menuButton;
						leashSubMenuParent=leashMenuName;
						leashSubMenuUser=user;
						if(menuButton=="Follow" | menuButton=="Pass"){
							llSensor("", NULL_KEY, AGENT, 96.0, PI);
						}else if(menuButton=="Anchor"){
							llSensor("", NULL_KEY, PASSIVE|ACTIVE, 96.0, PI);
						}
						//后续功能交给sensor事件
					}
                    else if(menuButton=="Length" || menuButton=="Style" || menuButton=="Config"){
                        showLeashSubMenu(menuButton, leashMenuName, user, TRUE);
                    }
                    if(leashMenuFlag!=-999){
                        showLeashMenu(leashParentMenuName, user);
                    }
                }
                else if(menuName==leashSubMenuName && menuButton!=""){
                    integer menuActiveFlag=-999;
                    if(leashSubMenuFlag=="Follow" || leashSubMenuFlag=="Pass" || leashSubMenuFlag=="Anchor"){
                        list buList=llParseStringKeepNulls(menuButton,[". "],[""]);
                        integer buIndex=llList2Integer(buList,0);
                        string buName=llList2String(buList,1);
                        key buUser=llList2Key(sensorUserList, ((integer)(buIndex-1)));
                        if(buUser!=NULL_KEY){
                            if(leashSubMenuFlag=="Follow"){
                                leashToTarget(buUser, FALSE);
                            }else{
                                leashToTarget(buUser, TRUE);
                            }
                        }
						sensorUserList=[];
                        menuActiveFlag=-999;
                    }
                    else if(leashSubMenuFlag=="Length"){
                        setConfig("leashLength", menuButton);
                        leashLength=(float)menuButton;
                        menuActiveFlag=2;
                    }
                    else if(leashSubMenuFlag=="Style"){
                        if(menuButton=="Bigger" || menuButton=="Smaller"){
                            vector particleScale=(vector)getConfig("particleScale");
                            if(menuButton=="Bigger"){
                                particleScale.x+=0.03;
                                particleScale.y+=0.03;
                            }else if(menuButton=="Smaller"){
                                particleScale.x-=0.03;
                                particleScale.y-=0.03;
                            }
                            if(particleScale.x<0.04 && particleScale.y<0.04){
                                particleScale.x=0.04;
                                particleScale.y=0.04;
                            }
                            setConfig("particleScale", (string)particleScale);
                        }
                        else if(menuButton=="Heavier" || menuButton=="Lighter"){
                            vector particleGravity=(vector)getConfig("particleGravity");
                            if(menuButton=="Heavier"){
                                particleGravity.z-=0.1;
                            }else if(menuButton=="Lighter"){
                                particleGravity.z+=0.1;
                            }
                            if(particleGravity.z<-3.0){
                                particleGravity.z=-3.0;
                            }
                            if(particleGravity.z>0.0){
                                particleGravity.z=0.0;
                            }
                            setConfig("particleGravity", (string)particleGravity);
                        }
                        else if(menuButton=="Glow"){
                            float particleGlow=(float)getConfig("particleGlow");
                            particleGlow+=0.1;
                            if(particleGlow>1){
                                particleGlow=0;
                            }
                            setConfig("particleGlow",(string)particleGlow);
                        }
                        else if(menuButton=="Shine"){
                            integer particleFullBright=(integer)getConfig("particleFullBright");
                            if(particleFullBright==TRUE){
                                particleFullBright=FALSE;
                            }else{
                                particleFullBright=TRUE;
                            }
                            setConfig("particleFullBright",(string)particleFullBright);
                        }
                        else if(menuButton=="Chain" || menuButton=="Ribbon" || menuButton=="None"){
                            setConfig("particleMode", menuButton);
                        }
                        else{
                            string colorVector=getParticleColor(menuButton,"");
                            if(colorVector!=""){
                                setConfig("particleColor", colorVector);
                            }
                        }
                        if(leashParticleEnabled==TRUE){
                            startParticles(leashTarget); // 更改配置后需要重新生成粒子效果，仅限有粒子的牵绳效果
                        }
                        menuActiveFlag=3;
                    }
                    else if(leashSubMenuFlag=="Config"){
                        if(menuButton=="Turn"){
							integer leashTurnMode=(integer)getConfig("leashTurnMode");
                            if(leashTurnMode==TRUE){
                                leashTurnMode=FALSE;
                            }else{
                                leashTurnMode=TRUE;
                            }
                            setConfig("leashTurnMode",(string)leashTurnMode); // 无需刷新，等下次timer事件即生效
                        }
                        else if(menuButton=="Strict"){
							integer leashStrictMode=(integer)getConfig("leashStrictMode");
                            if(leashStrictMode==TRUE){
                                leashStrictMode=FALSE;
                            }else{
                                leashStrictMode=TRUE;
                            }
                            setConfig("leashStrictMode",(string)leashStrictMode);
                            applyStrictMode(); // 严格模式必须重新牵引才能刷新
                        }
                        menuActiveFlag=4;
                    }
                    if(menuActiveFlag!=-999){
                        showLeashSubMenu(leashSubMenuFlag, leashSubMenuParent, user, FALSE);
                    }
                }
            }
            /*
            接收到RLV清空的通知时，重新应用严格模式限制
            */
            else if (llGetSubString(str, 0, 3) == "RLV." && includes(str, "EXEC") && includes(str, "CLEAR")) {
                applyStrictMode();
            }
            else if(num==ACCESS_MSG_NUM){
                // 权限功能监听
                list accessCmdList=msg2List(str);
                string accessCmdStr=llList2String(accessCmdList, 0);
                string accessName=llList2String(accessCmdList, 1);
                list accessData=data2List(llList2String(accessCmdList, 2));

                if(accessCmdStr=="ACCESS.NOTIFY"){
                    if(accessName=="OWNER"){ // ACCESS.NOTIFY | OWNER | UUID1; UUID2; UUID3; ...
                        owner=accessData; // 接收到并写入的用户列表为string，判断时要将key转换为string再判断
                    }
                    applyStrictMode();
                    // if(accessName=="TRUST"){ // ACCESS.NOTIFY | TRUST | UUID1; UUID2; UUID3; ...
                    //     trust=accessData;
                    // }
                    // if(accessName=="BLACK"){ // ACCESS.NOTIFY | BLACK | UUID1; UUID2; UUID3; ...
                    //     black=accessData;
                    // }
                    // if(accessName=="MODE"){ // ACCESS.NOTIFY | MODE | PUBLIC; GROUP; HARDCORE
                    //     public=llList2Integer(accessData, 0);
                    //     group=llList2Integer(accessData, 1);
                    //     hardcore=llList2Integer(accessData, 2);
                    // }
                }
            }
        }
        if(llGetListLength(resultList)>0){
            llMessageLinked(LINK_SET, LEASH_MSG_NUM, list2Bundle(resultList), user); // 处理完成后的回调
        }
		// llOwnerSay("Leash Memory Used: "+(string)llGetUsedMemory()+" Free: "+(string)llGetFreeMemory());
    }
    dataserver(key query_id, string data){
        if (query_id == readLeashQuery) { // 通过readLeashNotecards触发读取记事卡事件，按行读取配置并应用。
            if (data == EOF) {
                llOwnerSay("Finished reading leash config: "+curLeashName);
                llMessageLinked(LINK_SET, ACCESS_MSG_NUM, list2Msg(["LEASH.LOAD.NOTECARD",curLeashName,TRUE]), NULL_KEY); // 成功读取记事卡后回调
                readLeashQuery=NULL_KEY;
            } else {
                if(data!="" && llGetSubString(data,0,0)!="#"){
                    list leashStrSp=llParseStringKeepNulls(data, ["="], []);
                    setConfig(llList2String(leashStrSp,0), llList2String(leashStrSp,1));
                }

                // increment line count
                ++readLeashLine;
                //request next line of notecard.
                readLeashQuery=llGetNotecardLine(readLeashName, readLeashLine);
            }
        }
    }
    sensor(integer detected) {
        sensorUserList=[];
        integer i;
        for (i = 0; i < detected; i++) {
            key uuid = llDetectedKey(i);
            sensorUserList+=uuid;
        }
		showLeashSubMenu(leashSubMenuFlag, leashSubMenuParent, leashSubMenuUser, TRUE);
    }
}
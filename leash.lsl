/*
Name: Leash
Author: JMRY
Description: A better leash control system, use link_message to operate leashes.

***更新记录***
- 1.0 20260107
    - 初步完成牵绳功能。
***更新记录***
*/

/*
TODO:
*/

/*
基础功能依赖函数
*/
string userInfo(key user){
    return "secondlife:///app/agent/"+(string)user+"/about";
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

string trim(string k){
    return llStringTrim(k, STRING_TRIM);
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

integer str2Num(string d){
	return (integer)replace(d,"+","");
}

/*
连接点查找
*/
list getLinksByName(string name){
	name=llToLower(llStringTrim(name));
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
	"particleEnabled", 		"1",
	"particleMode", 		"Ribbon", // Ribbon, Chain, Leather, Rope, None
	"particleMaxAge", 		"3.5",
	"particleColor", 		"<1.0, 1.0, 1.0>",
	"particleScale", 		"<0.04, 0.04, 1.0>",
	"particleBurstRate",	"0.0",
	"particleGravity", 		"<0.0,0.0,-1.0>",
	"particleCount", 		"1",
	"particleFullBright",	"1",
	"particleGlow",			"0.2",
	"particleTextureRibbon","cdb7025a-9283-17d9-8d20-cee010f36e90",
	"particleTextureChain", "4cde01ac-4279-2742-71e1-47ff81cc3529",
	"particleTextureLeather","8f4c3616-46a4-1ed6-37dc-9705b754b7f1",
	"particleTextureRope", 	"9a342cda-d62a-ae1f-fc32-a77a24a85d73",
	"particleTextureNone", 	"8dcd4a48-2d37-4909-9f78-f7a9eb4ef903", // TEXTURE_TRANSPARENT

	"leashPointName", 		"leashpoint",
	"leashLength", 			"3",
	"leashTurnMode",	 	"1",
	"leashStrictMode", 		"0",
	"leashAwait",		 	"3",
	"leashMaxRange",		"60",
	"leashPosOffset",		"<0.0, 0.0, 0.0>",
	"", 	"",
];
string setConfig(string k, string v){
	integer index=llListFindList(leashConfig, [k]);
	if(~rindex){
		leashConfig=llListReplaceList(leashConfig,[v],index+1,index+1);
	}else{
		leashConfig+=[k, v];
	}
}
string getConfig(string k){
	if(k==""){
		list configList=[];
		integer i;
		for(i=0; i<llGetListLength(leashConfig); i++){
			if(i%2!=0){
				configList+=llList2String(leashConfig, i);
			}
		}
		return configList;
	}
	integer index=llListFindList(leashConfig, [k]);
	if(~rindex){
		return llList2String(leashConfig, index+1);
	}else{
		return "";
	}
}

/*
链条粒子系统
*/
activeParticles(integer link, key target, string particleMode, key particleTexture, vector particleScale, vector particleColor, vector particleGravity, integer particleCount, integer particleFullBright, float particleGlow, float particleMaxAge, float particleBurstRate){
	if(particleMode=="None"){
		stopParticles();
		return;
	}
	if(target==NULL_KEY){
		return;
	}
	integer particleFlags = PSYS_PART_FOLLOW_VELOCITY_MASK | PSYS_PART_TARGET_POS_MASK | PSYS_PART_FOLLOW_SRC_MASK;
	if(particleMode == "Ribbon"){
		particleFlags = particleFlags | PSYS_PART_RIBBON_MASK;
	}
	if(particleFullBright){
		particleFlags = particleFlags | PSYS_PART_EMISSIVE_MASK;
	}
	list particleParams = [
        PSYS_PART_MAX_AGE,particleMaxAge,
        PSYS_PART_FLAGS,particleFlags,
        PSYS_PART_START_COLOR, particleColor,
        //PSYS_PART_END_COLOR, g_vLeashColor,
        PSYS_PART_START_SCALE,particleScale,
        //PSYS_PART_END_SCALE,g_vLeashSize,
        PSYS_SRC_PATTERN, PSYS_SRC_PATTERN_DROP,
        PSYS_SRC_BURST_RATE,particleBurstRate,
        PSYS_SRC_ACCEL, particleGravity,
        PSYS_SRC_BURST_PART_COUNT,particleCount,
        //PSYS_SRC_BURST_SPEED_MIN,fMinSpeed,
        //PSYS_SRC_BURST_SPEED_MAX,fMaxSpeed,
        PSYS_SRC_TARGET_KEY,target,
        PSYS_SRC_MAX_AGE, 0,
        PSYS_SRC_TEXTURE, particleTexture
	];
    llLinkParticleSystem(link, particleParams);
}

key startParticles(key target){
	stopParticles();
	if(target==NULL_KEY){
		return target;
	}
	string particleMode=getConfig("particleMode");
	if(particleMode=="None"){
		return;
	}
	
	vector  particleScale		=(vector)	getConfig("particleScale");
	vector  particleColor		=(vector)	getConfig("particleColor");
	vector  particleGravity		=(vector)	getConfig("particleGravity");
	integer particleCount		=(integer)	getConfig("particleCount");
	integer particleFullBright	=(integer)	getConfig("particleFullBright");
	float   particleGlow		=(float)	getConfig("particleGlow");
	float   particleMaxAge		=(float)	getConfig("particleMaxAge");
	float   particleBurstRate	=(float)	getConfig("particleBurstRate");

	key particleTexture=(key)getConfig("particleTexture"+particleMode);
	if(particleTexture==""){
		particleTexture=TEXTURE_TRANSPARENT;
	}

	list leashPoints=getLinksByName(getConfig("leashPointName"));
	integer i;
	for(i=0; i<llGetListLength(leashPoints); i++){
		activeParticles(llList2Integer(leashPoints, i), target, particleMode, particleTexture, particleScale, particleColor, particleGravity, particleCount, particleFullBright, particleGlow, particleMaxAge, particleBurstRate);
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
key leashTarget;
integer leashParticleEnabled;
float leashLength;
float leashAwait;
float leashMaxRange;
integer leashTurnMode;
integer leashStrictMode;
integer allowAutoTurn=FALSE;
integer leashStrictFlag=FALSE;
vector leashPosOffset;
key leashToTarget(key target, integer particleEnabled){
	leashTarget=target;
	leashParticleEnabled=particleEnabled;

	if(leashTarget!=NULL_KEY){ // Leash
		leashAwait=(float)getConfig("leashAwait");
		leashLength=(float)getConfig("leashLength");
		leashMaxRange=(float)getConfig("leashMaxRange");
		leashTurnMode=(integer)getConfig("leashTurnMode");
		leashStrictMode=(integer)getConfig("leashStrictMode");
		leashPosOffset=(vector)getConfig("leashPosOffset");

		llRequestPermissions(llGetOwner(),PERMISSION_TRIGGER_ANIMATION); // Request auto turn perm
		llSetTimerEvent(leashAwait); // Move to target in timer

		if(particleEnabled==TRUE){
			startParticles(leashTarget);
		}else{
			stopParticles();
		}
		
		if(leashStrictMode==TRUE){
			string strictRestraints="fly=n,tplm=n,tplure=n,tploc=n,tplure:"+(string)leashTarget+"=add,sittp=n,accepttp:"+(string)leashTarget+"=add";
			llMessageLinked(LINK_SET, RLV_MSG_NUM, "RLV.RUN.TEMP|"+strictRestraints, NULL_KEY);
			leashStrictFlag=TRUE;
		}else{
			if(leashStrictFlag==TRUE){ // 严格模式RLV限制清除，只有触发过严格模式才进行。临时执行一次clear后，重新执行记录的RLV限制
				llMessageLinked(LINK_SET, RLV_MSG_NUM, "RLV.RUN.TEMP|clear&&RLV.RUN", NULL_KEY);
				leashStrictFlag=FALSE;
			}
		}
	}else{ // Unleash
		stopParticles();
		llSetTimerEvent(0);
		if(leashStrictFlag==TRUE){ // 严格模式RLV限制清除，只有触发过严格模式才进行。临时执行一次clear后，重新执行记录的RLV限制
			llMessageLinked(LINK_SET, RLV_MSG_NUM, "RLV.RUN.TEMP|clear&&RLV.RUN", NULL_KEY);
			leashStrictFlag=FALSE;
		}
	}
	return target;
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
	string statusText="":
	if(user!=llGetOwner()){
		grabBu="Grab";
	}
	if(leashTarget!=NULL_KEY){
		unLeashBu="Unleash";
		yankBu="Yank";
		if(leashParticleEnabled==FALSE){
			unLeashBu="Unfollow";
			statusText="Following: ";
		}else{
			statusText="Leashed to: ";
		}
	}
	if(checkOwner(user)){
		styleBu="Style";
		configBu="Config";
	}

	list leashMenuText=[
		"This is leash menu.\n%1%%2%%%;",
		statusText,
		userInfo(leashTarget)
	];

	list leashMenuList=[
		grabBu,unleashBu,yankBu,
		"Follow","Anchor","Pass",
		"Length",styleBu,configBu
	];

	llMessageLinked(LINK_SET, MENU_MSG_NUM, "MENU.REG.OPEN|"+leashMenuName+"|"+list2Data(leashMenuText)+"|"+list2Data(leashMenuList)+"|"+parent, user);
}

list sensorUserList=[];
string leashSubMenuName="LeashSubMenu";
string leashSubMenuFlag="";
showLeashSubMenu(string menuName, string parent, key user){
	accessActiveFlag=menuName;
	list menuText=[];
    list buttonList=[];
	if(menuName=="Follow" || menuName=="Pass"){
		llSensor("", NULL_KEY, AGENT, 96.0, PI);
		llSleep(0.5);
		menuText=["Select user to %1%.%%",menuName];
        integer i;
        for(i=0; i<9; i++){
            key uk=llList2Key(sensorUserList, i);
            if(uk){
                string un=userName(uk,1);
                // userList+=[(string)(i+1) + ". " + un];
                buttonList+=[(string)i + ". " + un];
            }
        }
	}
	else if(menuName=="Anchor"){
		llSensor("", NULL_KEY, PASSIVE|ACTIVE, 96.0, PI);
		llSleep(0.5);
		menuText=["Select object to %1%.%%",menuName];
        integer i;
        for(i=0; i<9; i++){
            key uk=llList2Key(sensorUserList, i);
            if(uk){
				string un=llList2String(llGetObjectDetails(g_targetObjKey, [OBJECT_NAME]));
                // userList+=[(string)(i+1) + ". " + un];
                buttonList+=[(string)i + ". " + un];
            }
        }
	}
	else if(menuName=="Length"){
		menuText=["Current leash length: %1%.%%",getConfig("leashLength")];
		for(i=1; i<=6; i++){
			buttonList+=[i];
		}
		for(i=10; i<=20; i+=5){
			buttonList+=[i];
		}
	}
	else if(menuName=="Style"){
		menuText=["Choose a style and color for leash."];
		buttonList=[
			"Bigger", "Smaller", "Glow",
			"Heavier", "Lighter", "Shine",
			"["+(string)(getConfig("particleMode")=="Chain")+"]Chain", "["+(string)(getConfig("particleMode")=="Ribbon")+"]Ribbon", "["+(string)(getConfig("particleMode")=="None")+"]None",

			"White", "Black", "Gray",
			"Red", "Green", "Blue",
			"Yellow", "Pink", "Brown",

			"Purple", "Barbie", "Orange",
			"Toad", "Khaki", "Pool",
			"Blood", "Anthracite", "Midnight"
		]
	}
	else if(menuName=="Config"){
		menuText=["Configs of leash."];
		buttonList=[
			"["+getConfig("leashTurnMode")+"]Turn", "["+getConfig("leashStrictMode")+"]Strict"
		];
	}
	llMessageLinked(LINK_SET, MENU_MSG_NUM, "MENU.REG.OPEN|"+leashSubMenuName+"|"+list2Data(menuText)+"|"+list2Data(buttonList)+"|"+parent, user);
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
    llOwnerSay("Begin reading leash settings: "+aname);
    readLeashLine=0;
    curLeashName=aname;
    readLeashName=leashHeader+aname;
    if (llGetInventoryType(readLeashName) == INVENTORY_NOTECARD) {
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
integer LAN_MSG_NUM=1003;
integer LEASH_MSG_NUM=1005;
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
			}
		}
	}
	timer() {
        vector targetPos = llList2Vector(llGetObjectDetails(leashTarget, [OBJECT_POS]), 0);
		integer targetInRange=TRUE;
		// if(targetPos == ZERO_VECTOR || llVecDist(llGetPos(), targetPos)> 255){
		if(targetPos == ZERO_VECTOR || llVecDist(llGetPos(), targetPos)> leashMaxRange){
			targetInRange=FALSE;
		}
		if(targetInRange){
			vector avatarPos = llDetectedPos(0);
			float distance = llVecDist(targetPos, avatarPos);
			if(distance>leashLength){
				llMoveToTarget(targetPos+leashPosOffset, 0.8); // 平滑地跟随
				if(leashTurnMode==TRUE && allowAutoTurn==TRUE){
					rotation rot=llRotBetween(<1,0,0>,llVecNorm(targetPos));
					llSetAgentRot(rot,0);
				}
			}
		}
    }
	run_time_permissions(integer perm) {
        if(perm & PERMISSION_TRIGGER_ANIMATION){
			allowAutoTurn=TRUE;
		}

    }
	link_message(integer sender_num, integer num, string msg, key user){
        if(num!=LEASH_MSG_NUM && num!=MENU_MSG_NUM && num!=LAN_MSG_NUM){
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
                string leashMsgExt2=llList2String(leashMsgGroup, 3);

				string leashMsgName=llList2String(leashMsgList, 1);
                string leashMsgCmd=llList2String(leashMsgList, 2);
                string leashMsgExt=llList2String(leashMsgList, 3);

                string result="";
				if(leashMsgSub=="SET"){
					/*
					更改配置：LEASH.SET | ConfigName | ConfigValue
					*/
					result=setConfig(leashMsgName, leashMsgCmd);
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
						leashMsgCmd=getCOnfig("particleEnabled");
					}
					result=leashToTarget((key)leashMsgName, (integer)leashMsgCmd);
				}
				else if(leashMsgSub=="YANK"){
					/*
					将目标拉到身边：LEASH.YANK | targetId
					目标ID为空时，则为当前牵引的目标
					*/
					if(leashMsgName==""){
						leashMsgName=(string)leashTarget;
					}
					result=leashToTarget((key)leashMsgName);
				}
				else if(leashMsgSub=="PARTICLE"){
					/*
					仅显示牵引链条：LEASH.PARTICLE | targetId
					目标ID为空时，则为取消链条
					*/
					if(leashMsgName==""){
						leashMsgName=(string)NULL_KEY;
					}
					result=startParticles((key)leashMsgName);
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
                string menuCmdStr=llList2String(menuCmdList, 0);
                list menuCmdGroup=llParseStringKeepNulls(menuCmdStr, ["."], [""]);
    
                string menuCmd=llList2String(menuCmdGroup, 0);
                string menuCmdSub=llList2String(menuCmdGroup, 1);
    
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
					else if(menuButton=="Follow" || menuButton=="Pass" || menuButton=="Anchor" || menuButton=="Length" || menuButton=="Style" || menuButton=="Config"){
						showLeashSubMenu(menuButton, leashMenuName, user);
					}
					if(leashMenuFlag!=-999){
						showLeashMenu(leashParentMenuName, user);
					}
                }
				else if(menuName==leashSubMenuName && menuButton!=""){

				}
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
					// if(accessName=="TRUST"){ // ACCESS.NOTIFY | TRUST | UUID1; UUID2; UUID3; ...
					// 	trust=accessData;
					// }
					// if(accessName=="BLACK"){ // ACCESS.NOTIFY | BLACK | UUID1; UUID2; UUID3; ...
					// 	black=accessData;
					// }
					// if(accessName=="MODE"){ // ACCESS.NOTIFY | MODE | PUBLIC; GROUP; HARDCORE
					// 	public=llList2Integer(accessData, 0);
					// 	group=llList2Integer(accessData, 1);
					// 	hardcore=llList2Integer(accessData, 2);
					// }
				}
			}
		}
		if(llGetListLength(resultList)>0){
            llMessageLinked(LINK_SET, LEASH_MSG_NUM, list2Bundle(resultList), user); // 处理完成后的回调
        }
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
    }
}
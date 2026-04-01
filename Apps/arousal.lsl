initMain(){
}
/*CONFIG END*/

/*
Name: Arousal
Author: JMRY
Description: A arousal controller for restraint items.

***更新记录***
- 1.0.1 20260402
	- 优化菜单用语和相关逻辑。
	- 修复强制高潮不会弹出菜单的bug。

- 1.0 20260324
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

integer RandomInteger(integer a, integer b){
    if (a > b){ // 如果下限大于上限，交换
        integer temp = a;
        a = b;
        b = temp;
    }
    return a + (integer)llFrand(b - a + 1);
}

string arousalMode="A:Stop";
integer arousalEdge=FALSE;
integer arousalAllowAnim=TRUE;
integer arousalEdgeLower=20;
integer arousalEdgeUpper=80;
setArousalMode(string mode, key user){
	if(arousalMode != mode){
		arousalMode=mode;
		llMessageLinked(LINK_SET, MENU_MSG_NUM, "MENU.OUT.TO|Your Arousal mode is set to: %1%%%;"+arousalMode, VICTIM_UUID);
	}
	applyArousal();
}

setArousalEdge(integer bool, key user){
	if(arousalEdge != bool){
		arousalEdge=bool;
		llMessageLinked(LINK_SET, MENU_MSG_NUM, "MENU.OUT.TO|Your Arousal edge mode is set to: %b1%%%;"+(string)arousalEdge, VICTIM_UUID);
	}
	applyArousal();
}

list arousalValList=[
	2, 5, 10, // A:Low, A:Medium, A:High arousal val
	1, 10, // A:Tease random delay range
	5, 50 // Random arousal val range
];

integer arousalCurrent=0;
integer arousalVal=0;
integer arousalDelay=0;
integer isEdged=FALSE;
applyArousal(){
	if(arousalMode=="A:Low"){
		arousalVal=llList2Integer(arousalValList, 0);
		arousalDelay=1;
	}
	else if(arousalMode=="A:Medium"){
		arousalVal=llList2Integer(arousalValList, 1);
		arousalDelay=1;
	}
	else if(arousalMode=="A:High"){
		arousalVal=llList2Integer(arousalValList, 2);
		arousalDelay=1;
	}
	else if(arousalMode=="A:Tease"){
		arousalVal=RandomInteger(llList2Integer(arousalValList, 0), llList2Integer(arousalValList, 2));
		arousalDelay=RandomInteger(llList2Integer(arousalValList, 3), llList2Integer(arousalValList, 4));
	}
	else if(arousalMode=="A:Random"){
		arousalVal=RandomInteger(llList2Integer(arousalValList, 5), llList2Integer(arousalValList, 6));
		arousalDelay=RandomInteger(llList2Integer(arousalValList, 3), llList2Integer(arousalValList, 4));
	}
	else if(arousalMode=="A:Stop"){
		arousalVal=0;
		arousalDelay=0;
	}

	if(arousalCurrent >= (integer)(400 * (float)arousalEdgeUpper / 100) ){
		isEdged=TRUE;
	}
	if(arousalCurrent <= (integer)(400 * (float)arousalEdgeLower / 100) ){
		isEdged=FALSE;
	}

	if(arousalEdge==FALSE || (arousalEdge==TRUE && isEdged==FALSE)){
		// llOwnerSay("Arousal+"+(string)arousalVal+" Current: "+(string)arousalCurrent);
		if(arousalAllowAnim==FALSE){
			llMessageLinked(LINK_SET, PA2_MSG_NUM, "arousalStopAnimType|"+(string)VICTIM_UUID+"|ArousedStanding", "");
			llMessageLinked(LINK_SET, PA2_MSG_NUM, "arousalStopAnimType|"+(string)VICTIM_UUID+"|ArousedSitting", "");
			llMessageLinked(LINK_SET, PA2_MSG_NUM, "arousalStopAnimType|"+(string)VICTIM_UUID+"|GetUp", "");
			llMessageLinked(LINK_SET, PA2_MSG_NUM, "arousalStopAnimType|"+(string)VICTIM_UUID+"|Moan", "");
		}
		llMessageLinked(LINK_SET, PA2_MSG_NUM, "caeilarousalup|"+(string)VICTIM_UUID+"|"+(string)arousalVal, "");
	}
	llSetTimerEvent(arousalDelay);
}


string arousalMenuName="ArousalMenu";
string arousalParent="";
showArousalMenu(string parent, key user){
    arousalParent=parent;
    string menuText="This is Arousal menu.\nCurrent mode: %1%\nEdge Lower: %2%%, Edge Upper: %3%%%%;"+arousalMode+";"+(string)arousalEdgeLower+";"+(string)arousalEdgeUpper;
    list menuList=[
        "A:Low", "A:Medium", "A:High",
        "A:Tease", "A:Random", "A:Stop",
        "["+(string)arousalEdge+"]A:Edge","A:EdgeLower","A:EdgeUpper",
		"A:Orgasm"
    ];
    llMessageLinked(LINK_SET, MENU_MSG_NUM, "MENU.REG.OPEN|"+arousalMenuName+"|"+menuText+"|"+llDumpList2String(menuList, ";")+"|"+parent, user);
}

integer MENU_MSG_NUM=1000;
integer MAIN_MSG_NUM=9000;
integer AROUSAL_MSG_NUM=90001;
integer PA2_MSG_NUM=0;
key VICTIM_UUID;

default{
    state_entry(){
        initMain();
		if(llGetAttached()){
            VICTIM_UUID=llGetOwner();
        }else{
            VICTIM_UUID=NULL_KEY;
        }
		if(arousalAllowAnim==FALSE){
			llMessageLinked(LINK_SET, PA2_MSG_NUM, "arousalStopAnimType|"+(string)VICTIM_UUID+"|ArousedStanding", "");
			llMessageLinked(LINK_SET, PA2_MSG_NUM, "arousalStopAnimType|"+(string)VICTIM_UUID+"|ArousedSitting", "");
			llMessageLinked(LINK_SET, PA2_MSG_NUM, "arousalStopAnimType|"+(string)VICTIM_UUID+"|GetUp", "");
			llMessageLinked(LINK_SET, PA2_MSG_NUM, "arousalStopAnimType|"+(string)VICTIM_UUID+"|Moan", "");
		}
    }
	changed(integer change){
        if(change & CHANGED_OWNER){
            llResetScript();
        }
        if(change & CHANGED_LINK){
            VICTIM_UUID=llAvatarOnSitTarget();
        }
    }
	timer(){
		applyArousal();
	}
	attach(key user){
        VICTIM_UUID=user;
    }
	object_rez(key user){
        VICTIM_UUID=NULL_KEY;
    }
    link_message(integer sender_num, integer num, string msg, key user){
        if(num!=MAIN_MSG_NUM && num!=MENU_MSG_NUM && num!=AROUSAL_MSG_NUM && num!=PA2_MSG_NUM){
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

		if(num==PA2_MSG_NUM){
			if(msgHeader=="arousal"+(string)VICTIM_UUID){
				arousalCurrent=(integer)msg1;
			}
		}

        if(headerMain=="AROUSAL" && headerSub!="EXEC"){

        }
        else if(headerMain=="MAIN" && headerSub=="INIT"){
            llMessageLinked(LINK_SET, MAIN_MSG_NUM, "FEATURE.REG|Arousal", user);
        }
        else if(headerMain=="MENU" && headerSub=="ACTIVE"){
            // MENU.ACTIVE | MenuName | MenuButton
            if(msg1=="appMenu" && msg2=="Arousal"){
                showArousalMenu(msg1,user);
            }
			else if(msg1==arousalMenuName && msg2!=""){
				if(msg2=="A:Low" || msg2=="A:Medium" || msg2=="A:High" || msg2=="A:Tease" || msg2=="A:Random" || msg2=="A:Stop"){
					setArousalMode(msg2, user);
					showArousalMenu(arousalParent,user);
				}
				else if(msg2=="A:Edge"){
					setArousalEdge(!arousalEdge, user);
					showArousalMenu(arousalParent,user);
				}
				else if(msg2=="A:EdgeLower"){
					llMessageLinked(LINK_SET, MENU_MSG_NUM, "MENU.INPUT|ArousalInput_"+msg2+"|Input %1% (0~100), blank to return (Current: %2%):%%;"+msg2+";"+(string)arousalEdgeLower, user);
				}
				else if(msg2=="A:EdgeUpper"){
					llMessageLinked(LINK_SET, MENU_MSG_NUM, "MENU.INPUT|ArousalInput_"+msg2+"|Input %1% (0~100), blank to return (Current: %2%):%%;"+msg2+";"+(string)arousalEdgeUpper, user);
				}
				else if(msg2=="A:Orgasm"){
					if(arousalAllowAnim==FALSE){
						llMessageLinked(LINK_SET, PA2_MSG_NUM, "arousalStopAnimType|"+(string)VICTIM_UUID+"|ArousedStanding", "");
						llMessageLinked(LINK_SET, PA2_MSG_NUM, "arousalStopAnimType|"+(string)VICTIM_UUID+"|ArousedSitting", "");
						llMessageLinked(LINK_SET, PA2_MSG_NUM, "arousalStopAnimType|"+(string)VICTIM_UUID+"|GetUp", "");
						llMessageLinked(LINK_SET, PA2_MSG_NUM, "arousalStopAnimType|"+(string)VICTIM_UUID+"|Moan", "");
					}
					llMessageLinked(LINK_SET, PA2_MSG_NUM, "arousalForceOrgasm|"+(string)VICTIM_UUID+"|"+"1", "");
					llMessageLinked(LINK_SET, MENU_MSG_NUM, "MENU.OUT.TO|You had a powerful orgasm.", VICTIM_UUID);
					showArousalMenu(arousalParent,user);
				}
			}
			else if(msg1=="ArousalInput_A:EdgeLower" || msg1=="ArousalInput_A:EdgeUpper"){
				if(msg1=="ArousalInput_A:EdgeLower" && msg2!=""){
					arousalEdgeLower=(integer)msg2;
					if(arousalEdgeLower<0){arousalEdgeLower=0;}
					if(arousalEdgeLower>100){arousalEdgeLower=100;}
					if(arousalEdgeLower>arousalEdgeUpper){arousalEdgeLower=arousalEdgeUpper;}
				}
				else if(msg1=="ArousalInput_A:EdgeUpper" && msg2!=""){
					arousalEdgeUpper=(integer)msg2;
					if(arousalEdgeUpper<0){arousalEdgeUpper=0;}
					if(arousalEdgeUpper>100){arousalEdgeUpper=100;}
					if(arousalEdgeUpper<arousalEdgeLower){arousalEdgeUpper=arousalEdgeLower;}
				}
				setArousalEdge(arousalEdge, user);
				showArousalMenu(arousalParent,user);
			}
        }
    }
}
initMain(){
	standalone=FALSE;
	sitAutoLock=FALSE;
	sitAutoTrap=FALSE;
	scanDistance=96.0;
	showText=TRUE;
	captureTimeout=10;
	maxSensor=18;
	showNoticeText=2;
	captureTriggerText="%1% %2% captured by %3%!";
	captureUnsitText="You have %1% seconds to escape!";
	captureTimeoutText="%1% timed out in %2% seconds. Waiting for the next capture.";
}
/*CONFIG END*/

/*
Name: Capture
Author: JMRY
Description: A capture feature for restraint items.

***更新记录***
- 1.0.2 20260514
	- 优化接口规则。
	- 优化抓捕功能流程。
	- 修复无法抓捕玩家的bug。
	- 修复抓捕流程处理错误的bug。
	- 修复未自动锁定时，RLV限制失效的bug。

- 1.0.1 20260510
	- 适配新版主控脚本。

- 1.0 20260509
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
	if(isLocked==TRUE){
        lockUser=user;
    }else{
        lockUser=NULL_KEY;
    }
	llMessageLinked(LINK_SET, MAIN_MSG_NUM, "MAIN.LOCK|"+(string)isLocked, user);
}


integer sitAutoLock=FALSE;
integer sitAutoTrap=FALSE;
integer showText=TRUE;
float scanDistance=96;
triggerCapture(key victim, key originUser){
	captureByUser=originUser;
	llMessageLinked(LINK_SET, RLV_MSG_NUM, "RLV.CAPTURE|"+(string)victim+"|1", NULL_KEY);
	llSetTimerEvent(captureTimeout);
	// applyCaptureStatus(TRUE);
	// 后续操作由changed承接处理
}

list owner=[];
applyCaptureStatus(integer captured){
	if(VICTIM_UUID==NULL_KEY){
		applyCaptureText(FALSE);
		return;
	}
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
			// setLock(FALSE, NULL_KEY);
			llMessageLinked(LINK_SET, RLV_MSG_NUM, "RLV.APPLY.ALL", NULL_KEY);
		}
		// 显示文字部分
	}else{
		setLock(FALSE, NULL_KEY);
	}
	applyCaptureText(VICTIM_UUID!=NULL_KEY);
	applyCaptureNotice(VICTIM_UUID!=NULL_KEY);
}

applyCaptureText(integer captured){
	regCapture(captured);
	if(captured==TRUE){
		if(showText==TRUE && VICTIM_UUID!=NULL_KEY){
			llMessageLinked(LINK_SET, TEXT_MSG_NUM, "TEXT.SET|Victim|\\NL"+llGetDisplayName(VICTIM_UUID)+" ("+llGetUsername(VICTIM_UUID)+")|"+(string)showText+"|TOP", NULL_KEY);
			llMessageLinked(LINK_SET, TEXT_MSG_NUM, "TEXT.SET|Locked|%b1%Locked%%;"+(string)isLocked+"|1|Victim", NULL_KEY);
			if(lockUser!=NULL_KEY){
				llMessageLinked(LINK_SET, TEXT_MSG_NUM, "TEXT.SET|LockUser|Locked by %1%%%;\\NL"+llGetDisplayName(lockUser)+" ("+llGetUsername(lockUser)+")|1|Locked", NULL_KEY);
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

integer showNoticeText=FALSE;
string captureTriggerText="";
string captureUnsitText="";
string captureTimeoutText="";
applyCaptureNotice(integer captured){
	if(showNoticeText==FALSE){
		return;
	}
	string noticeCmd="MENU.OUT.TO";
	if(showNoticeText==2){
		noticeCmd="MENU.OUT.SAY";
	}
	string noticeStr="";
	if(captured==TRUE){
		if(showNoticeText==1){
			noticeStr=captureTriggerText+"%%;You;are";
		}else if(showNoticeText==2){
			noticeStr=captureTriggerText+"%%;"+userInfo(VICTIM_UUID)+";is";
		}

		if(captureByUser!=NULL_KEY){
			noticeStr+=";"+userInfo(captureByUser);
		}else{
			noticeStr+=";trap";
		}
	}

	else if(captured==FALSE){
		noticeStr=captureUnsitText+"%%;"+(string)((integer)captureTimeout);
	}

	else if(captured==-1){
		noticeStr=captureTimeoutText+"%%;"+llGetObjectName()+";"+(string)((integer)captureTimeout);
	}

	if(noticeStr!=""){
		llMessageLinked(LINK_SET, MENU_MSG_NUM, noticeCmd+"|"+noticeStr, VICTIM_UUID);
	}
}

regCapture(integer captured){
	if(captured==TRUE){
		llMessageLinked(LINK_SET, MAIN_MSG_NUM, "MAIN.MENU.SET|"+appName+"|Unsit", VICTIM_UUID);
		// llMessageLinked(LINK_SET, MAIN_MSG_NUM, "FEATURE.REM|"+appName+"|Lock|mainMenu", NULL_KEY);
		// llMessageLinked(LINK_SET, MAIN_MSG_NUM, "FEATURE.REG|"+appNameUnsit+"|Lock|mainMenu", NULL_KEY);
	}else{
		llMessageLinked(LINK_SET, MAIN_MSG_NUM, "MAIN.MENU.SET|Unsit|"+appName, VICTIM_UUID);
		// llMessageLinked(LINK_SET, MAIN_MSG_NUM, "FEATURE.REM|"+appNameUnsit+"|Lock|mainMenu", NULL_KEY);
		// llMessageLinked(LINK_SET, MAIN_MSG_NUM, "FEATURE.REG|"+appName+"|Lock|mainMenu", NULL_KEY);
	}
}

registCaptureFeature(){
	llMessageLinked(LINK_SET, MAIN_MSG_NUM, "FEATURE.REG|"+appName+"||settingMenu", NULL_KEY);
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
showSettingMenu(string parent, key user){
    menuParent=parent;
    string menuText="This is "+appName+" menu.\nScan distance: %1%\nShow notice: %2%%%;"+(string)scanDistance+";"+(string)showNoticeText;
    list menuList=[
		"["+(string)sitAutoLock+"]C:AutoLock", "["+(string)sitAutoTrap+"]C:AutoTrap", "["+(string)showText+"]C:ShowText",
		"C:ShowNotice", "C:ScanDistance"
	];
    llMessageLinked(LINK_SET, MENU_MSG_NUM, "MENU.REG.OPEN|"+menuName+"|"+menuText+"|"+llDumpList2String(menuList, ";")+"|"+parent, user);
}


integer MENU_MSG_NUM=1000;
integer RLV_MSG_NUM=1001;
integer ACCESS_MSG_NUM=1002;
integer TEXT_MSG_NUM=1008;
integer CAPTURE_MSG_NUM=1009;
integer MAIN_MSG_NUM=9000;

integer REZ_MODE=FALSE;
key VICTIM_UUID=NULL_KEY;
key captureByUser=NULL_KEY;
key lockUser=NULL_KEY;

string notecardHeader="capture_";
key readNotecardQuery=NULL_KEY;
integer readNotecardLine=0;
string readNotecardName="";
string curNotecardName="";

integer standalone=FALSE;
integer allowCapture=TRUE;

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
			// 起立后的预处理
			if(llAvatarOnSitTarget()==NULL_KEY){
				applyCaptureNotice(FALSE);
			}
			// 起立后的处理
			VICTIM_UUID=llAvatarOnSitTarget();
			applyCaptureStatus(VICTIM_UUID!=NULL_KEY);
			if(VICTIM_UUID==NULL_KEY){ // 起立时的处理
				captureByUser=NULL_KEY;
				allowCapture=FALSE;
				llSetTimerEvent(captureTimeout);
			}
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
			allowCapture=TRUE;
			VICTIM_UUID=NULL_KEY;
			captureByUser=NULL_KEY;
			applyCaptureStatus(FALSE);
			applyCaptureNotice(-1);
			llSetTimerEvent(0);
		}
	}
	touch_start(integer num_detected){
		if(standalone==TRUE){
			showSettingMenu("", llDetectedKey(0));
		}
	}
	collision_start(integer num){
        if(allowCapture==TRUE && REZ_MODE==TRUE && sitAutoTrap==TRUE && VICTIM_UUID == NULL_KEY){
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
		string headerExt2=llList2String(msgHeaderGroup, 3);

		string msg1=llList2String(msgList, 1);
		string msg2=llList2String(msgList, 2);
		string msg3=llList2String(msgList, 3);
		string msg4=llList2String(msgList, 4);

		if(headerMain=="CAPTURE" && headerSub!="EXEC"){
			string result="";
			if(headerSub=="GET"){
				/*
				CAPTURE.GET.READY
				获取就绪状态
				回调：
				CAPTURE.READY
				*/
				if(headerExt=="READY"){
					standalone=FALSE;
					llMessageLinked(LINK_THIS, CAPTURE_MSG_NUM, "CAPTURE.READY", NULL_KEY);
					registCaptureFeature();
				}
				/*
				CAPTURE.GET.AUTOLOCK
				获取自动锁定状态
				*/
				else if(headerExt=="AUTOLOCK"){
					result=(string)sitAutoLock;
				}
				/*
				CAPTURE.GET.AUTOTRAP
				获取自动抓捕状态
				*/
				else if(headerExt=="AUTOTRAP"){
					result=(string)sitAutoTrap;
				}
				/*
				CAPTURE.GET.DISTANCE
				获取扫描距离
				*/
				else if(headerExt=="DISTANCE"){
					result=(string)scanDistance;
				}
				/*
				CAPTURE.GET.SHOWTEXT
				获取显示文字状态
				*/
				else if(headerExt=="SHOWTEXT"){
					result=(string)showText;
				}
				/*
				CAPTURE.GET.TIMEOUT
				获取抓捕超时
				*/
				else if(headerExt=="TIMEOUT"){
					result=(string)captureTimeout;
				}
				/*
				CAPTURE.GET.MAXSENSOR
				获取最多扫描数量
				*/
				else if(headerExt=="MAXSENSOR"){
					result=(string)maxSensor;
				}
				else if(headerExt=="NOTICE"){
					/*
					CAPTURE.GET.NOTICE.SHOW
					获取通知是否显示状态
					*/
					if(headerExt2=="SHOW"){
						result=(string)showNoticeText;
					}
					/*
					CAPTURE.GET.NOTICE.CAPTURE
					获取抓捕通知文本
					*/
					else if(headerExt2=="CAPTURE"){
						result=(string)captureTriggerText;
					}
					/*
					CAPTURE.GET.NOTICE.CAPTURE
					获取站立通知文本
					*/
					else if(headerExt2=="UNSIT"){
						result=(string)captureUnsitText;
					}
					/*
					CAPTURE.GET.NOTICE.CAPTURE
					获取超时通知文本
					*/
					else if(headerExt2=="TIMEOUT"){
						result=(string)captureTimeoutText;
					}
				}
			}
			else if(headerSub=="SET"){
				/*
				CAPTURE.SET.AUTOLOCK
				设置自动锁定状态
				*/
				if(headerExt=="AUTOLOCK"){
					sitAutoLock=(integer)msg1;
					result=(string)sitAutoLock;
				}
				/*
				CAPTURE.SET.AUTOTRAP
				设置自动抓捕状态
				*/
				else if(headerExt=="AUTOTRAP"){
					sitAutoTrap=(integer)msg1;
					result=(string)sitAutoTrap;
				}
				/*
				CAPTURE.SET.DISTANCE
				设置扫描距离
				*/
				else if(headerExt=="DISTANCE"){
					scanDistance=(float)msg1;
					result=(string)scanDistance;
				}
				/*
				CAPTURE.SET.SHOWTEXT
				设置是否显示文字
				*/
				else if(headerExt=="SHOWTEXT"){
					showText=(integer)msg1;
					result=(string)showText;
				}
				/*
				CAPTURE.SET.TIMEOUT
				设置抓捕超时
				*/
				else if(headerExt=="TIMEOUT"){
					captureTimeout=(float)msg1;
					result=(string)captureTimeout;
				}
				/*
				CAPTURE.SET.MAXSENSOR
				设置最多扫描数量
				*/
				else if(headerExt=="MAXSENSOR"){
					maxSensor=(integer)msg1;
					result=(string)maxSensor;
				}
				else if(headerExt=="NOTICE"){
					/*
					CAPTURE.SET.NOTICE.SHOW
					设置通知是否显示状态
					*/
					if(headerExt2=="SHOW"){
						showNoticeText=(integer)msg1;
						result=(string)showNoticeText;
					}
					/*
					CAPTURE.SET.NOTICE.CAPTURE
					设置抓捕通知文本
					*/
					else if(headerExt2=="CAPTURE"){
						captureTriggerText=msg1;
						result=(string)captureTriggerText;
					}
					/*
					CAPTURE.SET.NOTICE.UNSIT
					设置站立通知文本
					*/
					else if(headerExt2=="UNSIT"){
						captureUnsitText=msg1;
						result=(string)captureUnsitText;
					}
					/*
					CAPTURE.SET.NOTICE.TIMEOUT
					设置超时通知文本
					*/
					else if(headerExt2=="TIMEOUT"){
						captureTimeoutText=msg1;
						result=(string)captureTimeoutText;
					}
				}
			}
			else if(headerSub=="TRIGGER"){
				triggerCapture((key)msg1, user);
			}
			else if(headerSub=="UNSIT"){
				captureByUser=NULL_KEY;
				llUnSit(llAvatarOnSitTarget());
			}
			else if(headerSub=="LOAD"){
                /*
                读取记事卡（将覆盖现有的Notecard数据）
                CAPTURE.LOAD | file1
                返回：
                CAPTURE.EXEC | CAPTURE.LOAD | 1
                */
				standalone=FALSE;
                if(headerExt==""){
                    readNotecardLine=0;
                    curNotecardName=msg1;
                    readNotecardName=notecardHeader+msg1;
                    if (llGetInventoryType(readNotecardName) == INVENTORY_NOTECARD) {
                        llOwnerSay("Begin reading "+appName+" settings: "+msg1);
                        readNotecardQuery=llGetNotecardLine(readNotecardName, readNotecardLine); // 通过给readNotecardQuery赋llGetNotecardLine的key，从而触发datasever事件
                        // 后续功能交给下方datasever处理
                        result=(string)TRUE;
                    }else{
                        llMessageLinked(LINK_SET, CAPTURE_MSG_NUM, "CAPTURE.LOAD.NOTECARD|"+msg1+"|0", NULL_KEY); // Notecard成功读取记事卡后回调
                        result=(string)FALSE;
                    }
					registCaptureFeature();
                }
                /*
                读取记事卡列表
                CAPTURE.LOAD.LIST
                返回：
                CAPTURE.EXEC | CAPTURE.LOAD.LIST | file1; file2; file3 ...
                */
                else if(headerExt=="LIST"){
                    list notecardList=[];
                    integer count = llGetInventoryNumber(INVENTORY_NOTECARD);
                    integer i;
                    for (i=0; i<count; i++){
                        string notecardName = llGetInventoryName(INVENTORY_NOTECARD, i);
                        if(llGetSubString(notecardName, 0, 9)==notecardHeader){
                            notecardList+=[llGetSubString(notecardName, 10, -1)];
                        }
                    }
                    result=(string)llDumpList2String(notecardList, ";");
                }
            }
            /*
            显示菜单
            STRUGGLE.MENU | 上级菜单名
            */
            else if(headerSub=="MENU"){
				if(headerExt=="SETTING"){
					showSettingMenu(msg1, user);
				}
				else if(headerExt=="SENSOR"){
					curMenuUser=user;
					llSensor("", NULL_KEY, AGENT, scanDistance, PI);
				}
            }
			if(result!=""){
                llMessageLinked(LINK_SET, CAPTURE_MSG_NUM, "CAPTURE.EXEC|"+msgHeader+"|"+result, user);
            }
		}
		else if(headerMain=="MENU" && headerSub=="ACTIVE"){
			// MENU.ACTIVE | MenuName | MenuButton
            if(msg1=="mainMenu" && msg2!=""){
				if(msg2==appName){
					curMenuUser=user;
					llSensor("", NULL_KEY, AGENT, scanDistance, PI);
				}
				else if(msg2=="Unsit"){
					captureByUser=NULL_KEY;
					llUnSit(llAvatarOnSitTarget());
				}
            }
			else if(msg1=="CaptureSensorMenu" && msg2!=""){
				list buList=llParseStringKeepNulls(msg2,[". "],[""]);
				integer buIndex=llList2Integer(buList,0);
				key buUser=llList2Key(sensorUserList, ((integer)(buIndex-1)));
				if(buUser!=NULL_KEY){
					allowCapture=TRUE;
					triggerCapture(buUser, user);
				}
				sensorUserList=[];
			}
			else if(msg1=="settingMenu" && msg2==appName){
				showSettingMenu(msg1, user);
			}
			else if(msg1==menuName && msg2!=""){
				if(msg2=="C:AutoLock"){
					sitAutoLock=!sitAutoLock;
					showSettingMenu(menuParent,user);
				}
				else if(msg2=="C:AutoTrap"){
					sitAutoTrap=!sitAutoTrap;
					showSettingMenu(menuParent,user);
				}
				else if(msg2=="C:ShowText"){
					showText=!showText;
					showSettingMenu(menuParent,user);
				}
				else if(msg2=="C:ShowNotice"){
					showNoticeText++;
					if(showNoticeText>2){
						showNoticeText=0;
					}
					showSettingMenu(menuParent,user);
				}
				else if(msg2=="C:ScanDistance"){
					llMessageLinked(LINK_SET, MENU_MSG_NUM, "MENU.INPUT|CaptureInput_"+msg2+"|Input %1% (0.0~100.0), blank to return (Current: %2%):%%;"+msg2+";"+(string)scanDistance, user);
				}
			}
			else if(includes(msg1, "CaptureInput")){
				string inputType=llGetSubString(msg1, llStringLength("CaptureInput_"), -1);
				if(inputType=="C:ScanDistance"){
					if(msg2!=""){
						scanDistance=(float)msg2;
						if(scanDistance<0) scanDistance=0;
						if(scanDistance>100) scanDistance=100;
					}
				}
				showSettingMenu(menuParent,user);
			}
		}
		else if(num==RLV_MSG_NUM){
            if(msgHeader=="RLV.EXEC"){
                if(msg1=="RLV.GET.LOCK" || msg1=="RLV.LOCK"){ // RLV.EXEC | RLV.LOCK | 1 | UUID
					list rlvCmdData=strSplit(msg2, ";");
                    isLocked=llList2Integer(rlvCmdData, 0);
                    lockUser=llList2Key(rlvCmdData, 1);
                    applyCaptureText(VICTIM_UUID!=NULL_KEY);
					// regCapture(VICTIM_UUID!=NULL_KEY);
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
                    applyCaptureStatus(FALSE);
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
	dataserver(key query_id, string data){
        if (query_id == readNotecardQuery) { // 通过readRLVNotecards触发读取记事卡事件，按行读取指定RLV（readRLVQuery）并设置相关数据。
            while(TRUE){
                string temp=llGetNotecardLineSync(readNotecardName, readNotecardLine);
                if(temp!=NAK){
                    data=temp;
                }
                if (data == EOF) {
                    llOwnerSay("Finished reading "+appName+" settings: "+curNotecardName);
                    llMessageLinked(LINK_SET, CAPTURE_MSG_NUM, "CAPTURE.LOAD.NOTECARD|"+curNotecardName+"|1", NULL_KEY); // RLV成功读取记事卡后回调
                    readNotecardQuery=NULL_KEY;
                    jump end;
                } else {
                    /*
                    configName=configValue
                    */
                    if(data!="" && llGetSubString(data,0,0)!="#"){
                        list notecardStrSp=llParseStringKeepNulls(data, ["="], []);
                        string notecardName=llList2String(notecardStrSp,0);
                        string notecardData=llList2String(notecardStrSp,1);

                        if(notecardName=="sitAutoLock"){sitAutoLock=(integer)notecardData;}
                        else if(notecardName=="sitAutoTrap"){sitAutoTrap=(integer)notecardData;}
                        else if(notecardName=="scanDistance"){scanDistance=(float)notecardData;}
                        else if(notecardName=="showText"){showText=(integer)notecardData;}
                        else if(notecardName=="captureTimeout"){captureTimeout=(float)notecardData;}
                        else if(notecardName=="maxSensor"){maxSensor=(integer)notecardData;}
                        else if(notecardName=="showNoticeText"){showNoticeText=(integer)notecardData;}
                        else if(notecardName=="captureTriggerText"){captureTriggerText=notecardData;}
                        else if(notecardName=="captureUnsitText"){captureUnsitText=notecardData;}
                        else if(notecardName=="captureTimeoutText"){captureTimeoutText=notecardData;}
                    }

                    // increment line count
                    ++readNotecardLine;
                    //request next line of notecard.
                    if(temp==NAK){
                        readNotecardQuery=llGetNotecardLine(readNotecardName, readNotecardLine);
                        jump end;
                    }
                }
            }
            @end;
        }
    }
}
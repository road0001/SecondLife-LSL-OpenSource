initConfig(){
    animConfigList=[]; // name, animName;interval;floatHeight;Ext1;Ext2;..., class, auto
    integer count = llGetInventoryNumber(INVENTORY_ANIMATION);
    integer i;
    for (i=0; i<count; i++){
        string animName = llGetInventoryName(INVENTORY_ANIMATION, i);
        integer auto=FALSE;
        if(i==0){
            auto=TRUE;
        }
        animConfigList+=[animName, animName+";0;0", "Animation", auto];
    }
}
/*CONFIG END*/
/*
Name: Animation
Author: JMRY
Description: A better animation control system, use link_message to operate animations.

***更新记录***
- 1.1.5 20260213
    - 加入自动读取库存中动画的功能。

- 1.1.4 20260212
    - 修复已停止动画的情况下，重新穿戴仍然会播放动画的bug。

- 1.1.3 20260211
    - 优化动画播放逻辑，当动画停止时，重新穿戴不再播放动画。
    - 优化数据结构。
    - 优化初始化逻辑。

- 1.1.2 20260210
    - 修复脚本重置后，无法播放动画的bug。

- 1.1.1 20260203
    - 优化记事卡读取的回调逻辑，在没有记事卡时直接回调。

- 1.1 2026130
    - 优化播放、停止动画的申请权限逻辑。

- 1.0.2 20260128
    - 优化内存占用。

- 1.0.1 20260116
    - 优化停止动画的逻辑，提升流畅度。

- 1.0 20260115
    - 初步完成动画功能。
***更新记录***
*/

/*
TODO:
- 随机动画切换
- 动画播放列表
*/

// string replace(string src, string target, string replacement) {
//     return llReplaceSubString(src, target, replacement, 0);
// }

// integer includes(string src, string target){
//     integer startPos = llSubStringIndex(src, target);
//     if(~startPos){
//         return TRUE;
//     }else{
//         return FALSE;
//     }
// }

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
// string strJoin(list m, string sp){
//     return llDumpList2String(m, sp);
// }

// // string bundleSplit="&&";
// list bundle2List(string b){
//     return strSplit(b, "&&");
// }
// string list2Bundle(list b){
//     return strJoin(b, "&&");
// }

// // string messageSplit="|";
// list msg2List(string m){
//     return strSplit(m, "|");
// }
// string list2Msg(list m){
//     return strJoin(m, "|");
// }

// // string dataSplit=";";
// list data2List(string d){
//     return strSplit(d, ";");
// }
string list2Data(list d){
    return llDumpList2String(d, ";");
}
// string list2RlvData(list d){
//     return strJoin(d, ",");
// }

list animConfigList=[]; // name, animName;interval;floatHeight;Ext1;Ext2;..., class, auto
integer animConfigLength=4; // name,params,class,auto
integer setAnimConfig(string name, string params, string class, integer auto){ // params: animName;interval;floatHeight;Ext1;Ext2;......
    integer rIndex=llListFindList(animConfigList, [name]);
    if(~rIndex){
        animConfigList=llListReplaceList(animConfigList, [params, class, auto], rIndex+1, rIndex+animConfigLength-1);
    }else{
        animConfigList+=[name, params, class, auto];
    }
    return TRUE;
}


string curPlayingAnimName="";
integer playAnimationByName(string name){
    integer rIndex=llListFindList(animConfigList, [name]);
    if(~rIndex){
        return playAnimationByParams(llList2String(animConfigList, rIndex+1), name);
    }
    return FALSE;
}

string curPlayingAnimParams="";
integer playAnimationByParams(string params, string name){
    if(params){
        curPlayingAnimName=name;
        curPlayingAnimParams=params;
        list animParams=strSplit(params, ";");
        // animName;interval;floatHeight;Ext1;Ext2;...
        playAnimInterval=(float)llList2String(animParams, 1);
        if(playAnimInterval<=0.0){ // 重播间隔小于等于0时，说明参数解析错误，因此将其修正。
            playAnimInterval=0.0;
        }
        playAnimFloatHeight=(float)llList2String(animParams, 2);
        if(playAnimFloatHeight<=0.0){
            playAnimFloatHeight=0.0;
        }

        // curPlayingAnimFileName=llList2String(animParams, 0);
        playAnimation(llList2String(animParams, 0), TRUE);
        // playAnimation(curPlayingAnimFileName, TRUE);
        // if(allowPlayAnim==TRUE){ // 不在playAnimation申请权限，防止死循环
        //     playAnimation(curPlayingAnimFileName, TRUE);
        // }else{
        //     playAnimationFlag=2;
        //     llRequestPermissions(animPlayer,PERMISSION_TRIGGER_ANIMATION);
        // }
        return TRUE;
    }else{
        return FALSE;
    }
}

string curPlayingAnimFileName="";
string lastPlayingAnimFileName="";
integer allowPlayAnim=FALSE;
float playAnimInterval=10;
float playAnimFloatHeight=0;
integer playAnimationFlag=FALSE;
integer playAnimation(string name, integer stop){
    if(animPlayer==NULL_KEY) return FALSE;
    if(stop==TRUE){
        playAnimationFlag=2;
    }else{
        playAnimationFlag=TRUE;
    }
    curPlayingAnimFileName=name;
    llRequestPermissions(animPlayer,PERMISSION_TRIGGER_ANIMATION);
    return playAnimationFlag;
}

integer stopAnimation(integer bool){
    if(animPlayer==NULL_KEY) return FALSE;
    playAnimationFlag=FALSE;
    if(bool==TRUE){
        curPlayingAnimName="";
        curPlayingAnimParams="";
        curPlayingAnimFileName="";
    }
    llRequestPermissions(animPlayer,PERMISSION_TRIGGER_ANIMATION);
    return playAnimationFlag;
}

integer stopAllAnimation(integer bool){
    if(animPlayer==NULL_KEY) return FALSE;
    playAnimationFlag=-1;
    if(bool==TRUE){
        curPlayingAnimName="";
        curPlayingAnimParams="";
        curPlayingAnimFileName="";
    }
    llRequestPermissions(animPlayer,PERMISSION_TRIGGER_ANIMATION);
    return playAnimationFlag;
}
// integer playAnimation(string name, integer stop){
//     playAnimationFlag=TRUE;
//     if(allowPlayAnim==TRUE){
//         if(stop==TRUE || curPlayingAnimFileName==""){
//             stopAnimation();
//         }
//         if(name!=""){
//             llStartAnimation(name);
//             curPlayingAnimFileName=name;
//             llSetTimerEvent(playAnimInterval);
        
//             if(allowAutoAdjustHeight==TRUE && playAnimFloatHeight!=0){
//                 llOwnerSay("@adjustheight:"+(string)playAnimFloatHeight+"=force");
//             };
//         }
//     }else{
//         // llRequestPermissions(animPlayer,PERMISSION_TRIGGER_ANIMATION);
//     }
//     return allowPlayAnim;
// }

// integer stopAnimation(){
//     playAnimationFlag=FALSE;
//     if(allowPlayAnim==TRUE){
//         if(curPlayingAnimFileName!=""){
//             llStopAnimation(lastPlayingAnimFileName);
//             // llStartAnimation("stand");
//             // curPlayingAnimName="";
//             // curPlayingAnimFileName="";
//         }
//         llSetTimerEvent(0);
//         if(allowAutoAdjustHeight==TRUE && playAnimFloatHeight!=0){
//             llOwnerSay("@adjustheight:0=force");
//             // playAnimFloatHeight=0;
//         };
//     }else{
//         // llRequestPermissions(animPlayer,PERMISSION_TRIGGER_ANIMATION);
//     }
//     return allowPlayAnim;
// }

// integer stopAllAnimation(){
//     if(allowPlayAnim){
//         list allAnimList=llGetAnimationList(llGetOwner());
//         llSetTimerEvent(0);
//         if(allowAutoAdjustHeight==TRUE){
//             llOwnerSay("@adjustheight:0=force");
//         };
//         integer i;
//         for(i=0; i<llGetListLength(allAnimList); i++){
//             llStopAnimation(llList2String(allAnimList, i));
//         }
//         llSleep(0.1);
//         llStartAnimation("stand");
//     }
//     return allowPlayAnim;
// }

/*
配置文件读取
*/
string notecardHeader="anim_";
string readNotecardName="";
string curNotecardName="";
key readNotecardQuery=NULL_KEY;
integer readNotecardLine=0;
integer readNotecards(string name){
    /*Clear Current Data*/
    readNotecardLine=0;
    curNotecardName=name;
    readNotecardName=notecardHeader+name;
    if (llGetInventoryType(readNotecardName) == INVENTORY_NOTECARD) {
        llOwnerSay("Begin reading animation settings: "+name);
        animConfigList=[];
        readNotecardQuery=llGetNotecardLine(readNotecardName, readNotecardLine); // 通过给readNotecardQuery赋llGetNotecardLine的key，从而触发datasever事件
        // 后续功能交给下方datasever处理
        return TRUE;
    }else{
        llMessageLinked(LINK_SET, ANIM_MSG_NUM, "ANIM.LOAD.NOTECARD|"+name+"|"+(string)llGetListLength(animConfigList), NULL_KEY);
        return FALSE;
    }
}

list getNotecardsList(){
    list notecardList=[];
    integer count = llGetInventoryNumber(INVENTORY_NOTECARD);
    integer i;
    for (i=0; i<count; i++){
        string notecardName = llGetInventoryName(INVENTORY_NOTECARD, i);
        if(llGetSubString(notecardName, 0, llStringLength(notecardHeader)-1)==notecardHeader){
            notecardList+=[llGetSubString(notecardName, llStringLength(notecardHeader), -1)];
        }
    }
    return notecardList;
}

string animMenuText="Animation";
string animMenuName="AnimationMenu";
string animParentMenuName="";
showAnimMenu(string parent, key user){
    list animClassList=[];
    string curClass="";
    integer i;
    for(i=0; i<llGetListLength(animConfigList); i+=animConfigLength){
        string class=llList2String(animConfigList, i+2);
        if(class!="" && curClass != class){
            animClassList+=[class];
            curClass=class;
        }
    }
    if(llGetListLength(animClassList)<=1){
        showAnimSubMenu(parent, curClass, user);
    }else{
        animParentMenuName=parent;
        list menuList=[];
        if(allowStopAnim==TRUE){
            menuList+=["[STOP]"];
        }
        menuList+=animClassList;
        llMessageLinked(LINK_SET, MENU_MSG_NUM, "MENU.REG.OPEN|"+animMenuName+"|Animation Menu\nCurrent Playing: %1%%%;"+curPlayingAnimName+"|"+list2Data(menuList)+"|"+parent, user);
    }
    // llMessageLinked(LINK_SET, MENU_MSG_NUM, list2Msg([
    //     "MENU.REG.OPEN",
    //     animMenuName,
    //     "Animation Menu\nCurrent Playing: %1%%%;"+curPlayingAnimName,
    //     list2Data(menuList),
    //     parent
    // ]), user);
}

string animSubMenuName="AnimationSubMenu";
string curAnimSubMenu="";
string animParentSubMenuName="";
showAnimSubMenu(string parent, string class, key user){
    animParentSubMenuName=parent;
    curAnimSubMenu=class;
    string animSubDesc="This is Animation [%1%] menu.\nCurrent Playing: %2%%%;"+class+";"+curPlayingAnimName;
    list animCmdList=["[STOP]"];
    integer animCmdCount=llGetListLength(animConfigList);
    integer i;
    for(i=0; i<animCmdCount; i+=animConfigLength){
        string curName=llList2String(animConfigList, i);
        string curClass=llList2String(animConfigList, i+2);
        if(curClass==class){
            animCmdList+=["["+(string)(curName == curPlayingAnimName)+"]"+curName];
        }
    }
    llMessageLinked(LINK_SET, MENU_MSG_NUM, "MENU.REG.OPEN|"+animSubMenuName+"|"+animSubDesc+"|"+list2Data(animCmdList)+"|"+parent, user);
}

key animPlayer=NULL_KEY;
integer MENU_MSG_NUM=1000;
integer ANIM_MSG_NUM=1006;
integer allowAutoAdjustHeight=TRUE;
integer allowStopAnim=TRUE;
string curAnimClass="";
default{
    state_entry(){
        initConfig();
        animPlayer=llGetOwner();
        integer i;
        for(i=0; i<llGetListLength(animConfigList); i+=animConfigLength){
            if(llList2Integer(animConfigList, i+3)==TRUE){
                if(llGetAttached()){
                    playAnimationByName(llList2String(animConfigList,i));
                }
            }
        }
    }
    timer(){
        playAnimation(curPlayingAnimFileName, FALSE);
    }
    changed(integer change){
        if(change & CHANGED_OWNER){
            llResetScript();
        }
        if(change & CHANGED_LINK){
            animPlayer=llAvatarOnSitTarget();
            if(animPlayer!=NULL_KEY){
                playAnimation(curPlayingAnimFileName, FALSE);
                // llRequestPermissions(animPlayer,PERMISSION_TRIGGER_ANIMATION);
            }
        }
    }
    attach(key user){
        animPlayer=user;
        if(user!=NULL_KEY){
            if(playAnimationFlag>=TRUE){
                playAnimation(curPlayingAnimFileName, playAnimationFlag);
            }
            // llRequestPermissions(animPlayer,PERMISSION_TRIGGER_ANIMATION);
        }else if(allowAutoAdjustHeight==TRUE && playAnimFloatHeight!=0){
            llOwnerSay("@adjustheight:0=force");
        }
    }
    object_rez(key user){
        animPlayer=NULL_KEY;
    }
    run_time_permissions(integer perm) {
        if(perm & PERMISSION_TRIGGER_ANIMATION){
            if(playAnimationFlag>=TRUE){
                if(playAnimationFlag>TRUE && lastPlayingAnimFileName!=""){
                    llStopAnimation(lastPlayingAnimFileName);
                }
                if(curPlayingAnimFileName==""){
                    return;
                }
                lastPlayingAnimFileName=curPlayingAnimFileName;
                llStartAnimation(curPlayingAnimFileName);
                llSetTimerEvent(playAnimInterval);
                if(allowAutoAdjustHeight==TRUE && playAnimFloatHeight!=0){
                    llOwnerSay("@adjustheight:"+(string)playAnimFloatHeight+"=force");
                };
            }else if(playAnimationFlag==FALSE){
                if(lastPlayingAnimFileName==""){
                    return;
                }
                llStopAnimation(lastPlayingAnimFileName);
                llSetTimerEvent(0);
                if(allowAutoAdjustHeight==TRUE && playAnimFloatHeight!=0){
                    llOwnerSay("@adjustheight:0=force");
                };
            }else if(playAnimationFlag==-1){
                llSetTimerEvent(0);
                list allAnimList=llGetAnimationList(llGetOwner());
                integer i;
                for(i=0; i<llGetListLength(allAnimList); i++){
                    llStopAnimation(llList2String(allAnimList, i));
                }
                if(allowAutoAdjustHeight==TRUE && playAnimFloatHeight!=0){
                    llOwnerSay("@adjustheight:0=force");
                };
                llSleep(0.1);
                llStartAnimation("stand");
            }
        }
    }
    // run_time_permissions(integer perm) {
    //     if(perm & PERMISSION_TRIGGER_ANIMATION){
    //         allowPlayAnim=TRUE;
    //         if(playAnimationFlag>=TRUE){
    //             if(playAnimationFlag>TRUE){
    //                 stopAnimation();
    //             }
    //             playAnimation(curPlayingAnimFileName,TRUE);
    //         }else{
    //             stopAnimation();
    //         }
    //     }
    // }
    link_message(integer sender_num, integer num, string msg, key user){
        if(num!=ANIM_MSG_NUM && num!=MENU_MSG_NUM){
            return;
        }

        list bundleMsgList=strSplit(msg, "&&");
        list resultList=[];
        integer bundleMsgCount=llGetListLength(bundleMsgList);
        integer mi;
        for(mi=0; mi<bundleMsgCount; mi++){
            string str=llList2String(bundleMsgList, mi);
            list msgList=strSplit(str, "|");
            string msgHeader=llList2String(msgList, 0);
            list msgHeaderGroup=llParseStringKeepNulls(msgHeader, ["."], [""]);

            string headerMain=llList2String(msgHeaderGroup, 0);
            string headerSub=llList2String(msgHeaderGroup, 1);
            string headerExt=llList2String(msgHeaderGroup, 2);

            string msgName=llList2String(msgList, 1);
            string msgSub=llList2String(msgList, 2);
            string msgExt=llList2String(msgList, 3);
            string msgExt2=llList2String(msgList, 3);

            if(headerMain=="ANIM" && headerSub!="EXEC"){
                string result="";

                if(headerSub=="SET"){
                    if(headerExt==""){
                        /*
                        添加动画：ANIM.SET | AnimName | AnimParams | AnimClass | AutoPlay
                        */
                        result=(string)setAnimConfig(msgName, msgSub, msgExt, (integer)msgExt2);
                        if((integer)msgExt2==TRUE){
                            playAnimationByName(msgName);
                        }
                    }
                    else if(headerExt=="AUTOHEIGHT"){
                        /*
                        添加Class：ANIM.SET.AUTOHEIGHT | 1
                        */
                        allowAutoAdjustHeight=(integer)msgName;
                        result=(string)allowAutoAdjustHeight;
                    }
                    else if(headerExt=="ALLOWSTOP"){
                        /*
                        添加Class：ANIM.SET.AUTOHEIGHT | 1
                        */
                        allowStopAnim=(integer)msgName;
                        result=(string)allowStopAnim;
                    }
                }

                else if(headerSub=="GET"){
                    if(headerExt==""){
                        /*
                        获取动画列表：ANIM.GET
                        返回：
                        ANIM.EXEC | ANIM.GET | AnimName1; AnimParams1; AnimClass1; AnimAutoPlay1; AnimName2; ...
                        */
                        result=llDumpList2String(animConfigList, "|");
                    }
                    else if(headerExt=="PLAYING"){
                        /*
                        获取正在播放的动画：ANIM.GET.PLAYING
                        返回：
                        ANIM.EXEC | ANIM.GET.PLAYING | AnimName1
                        */
                        result=curPlayingAnimName;
                    }
                    else if(headerExt=="PLAYING.PARAMS"){
                        /*
                        获取正在播放的动画：ANIM.GET.PLAYING.PARAMS
                        返回：
                        ANIM.EXEC | ANIM.GET.PLAYING | AnimParams1
                        */
                        result=curPlayingAnimParams;
                    }
                    else if(headerExt=="PLAYING.FILE"){
                        /*
                        获取正在播放的动画：ANIM.GET.PLAYING.FILE
                        返回：
                        ANIM.EXEC | ANIM.GET.PLAYING | AnimFileName1
                        */
                        result=curPlayingAnimFileName;
                    }
                }

                else if(headerSub=="LOAD"){
                    /*
                    读取记事卡
                    ANIM.LOAD | file1
                    回调：
                    ANIM.EXEC | ANIM.LOAD | 1
                    读取记事卡成功后的回调
                    ANIM.LOAD.NOTECARD | file1 | 1
                    */
                    if(headerExt==""){
                        result=(string)readNotecards(msgName);
                    }
                    /*
                    读取Anim记事卡列表
                    ANIM.LOAD.LIST
                    回调：
                    ANIM.EXEC | ANIM.LOAD.LIST | anim_1, anim_2, anim_3, ...
                    */
                    if(headerExt=="LIST"){
                        result=(string)list2Data(getNotecardsList());
                    }
                }

                else if(headerSub=="PLAY"){
                    if(headerExt==""){
                        /*
                        播放动画：ANIM.PLAY | AnimName1
                        */
                        result=(string)playAnimationByName(msgName);
                    }
                    else if(headerExt=="PARAMS"){
                        /*
                        按参数播放动画：ANIM.PLAY.PARAMS | AnimParams1
                        */
                        result=(string)playAnimationByParams(msgName, "");
                    }
                    else if(headerExt=="FILE"){
                        /*
                        直接播放动画文件：ANIM.PLAY.FILE | AnimFileName1
                        */
                        curPlayingAnimParams="";
                        result=(string)playAnimation(msgName, (integer)msgSub);
                    }
                }
                /*
                停止播放动画：ANIM.STOP | 1
                */
                else if(headerSub=="STOP"){
                    result=(string)stopAnimation((integer)msgName);
                }
                /*
                停止播放所有动画：ANIM.STOPALL | 1
                */
                else if(headerSub=="STOPALL"){
                    result=(string)stopAllAnimation((integer)msgName);
                }

                else if(headerSub=="MENU"){
                    /*
                    显示菜单
                    ANIM.MENU | 上级菜单名
                    */
                    showAnimMenu(msgName, user);
                }

                if(result!=""){
                    resultList+=[headerMain+".EXEC|"+msgHeader+"|"+result];
                }
            }

            else if(headerMain=="MENU" && headerSub=="ACTIVE"){
                // 动画菜单入口
                if(msgSub==animMenuText){
                    showAnimMenu(msgName, user);
                }
                // 动画主菜单（Class菜单）
                else if(msgName==animMenuName && msgSub!=""){ // MENU.ACTIVE | Class | Class1
                    if(msgSub=="[STOP]"){
                        stopAnimation(TRUE);
                        showAnimMenu(animParentMenuName, user);
                    }else{
                        showAnimSubMenu(animMenuName, msgSub, user);
                    }
                }
                // 动画子菜单（Sub菜单）
                else if(msgName==animSubMenuName && msgSub!=""){ // MENU.ACTIVE | Class1 | [1]Anim1
                    if(msgSub=="[STOP]"){
                        stopAnimation(TRUE);
                    }else{
                        playAnimationByName(msgSub);
                    }
                    showAnimSubMenu(animParentSubMenuName, curAnimSubMenu, user);
                }
            }
        }

        if(llGetListLength(resultList)>0){
            llMessageLinked(LINK_SET, ANIM_MSG_NUM, llDumpList2String(resultList, "&&"), user); // 处理完成后的回调
            resultList=[];
        }
        // llSleep(0.01);
        // llOwnerSay("Animation Memory Used: "+(string)llGetUsedMemory()+"/"+(string)(65536-llGetUsedMemory())+" Free: "+(string)llGetFreeMemory());
    }
    dataserver(key query_id, string data){
        if (query_id == readNotecardQuery) { // 通过readNotecardNotecards触发读取记事卡事件，按行读取配置并应用。
            if (data == EOF) {
                llOwnerSay("Finished reading animation config: "+curNotecardName);
                llMessageLinked(LINK_SET, ANIM_MSG_NUM, "ANIM.LOAD.NOTECARD|"+curNotecardName+"|1", NULL_KEY); // 成功读取记事卡后回调
                readNotecardQuery=NULL_KEY;

                if(curPlayingAnimName!=""){
                    playAnimationByName(curPlayingAnimName);
                }
            } else {
                if(data!="" && llGetSubString(data,0,0)!="#"){
                    if(llGetSubString(data,0,0)=="[" && llGetSubString(data,-1,-1)=="]"){
                        curAnimClass=llGetSubString(data,1,-2);
                    }else{
                        list animStrSp=llParseStringKeepNulls(data, ["="], []);
                        string animName=llList2String(animStrSp,0);
                        string animParams=llList2String(animStrSp, 1);
                        integer animAutoPlay=FALSE;
                        if(llGetSubString(animName, 0, 0)=="*"){
                            animAutoPlay=TRUE;
                            animName=llGetSubString(animName, 1, -1);
                            curPlayingAnimName=animName;
                        }
                        setAnimConfig(animName, animParams, curAnimClass, animAutoPlay);
                    }
                }
                ++readNotecardLine;
                readNotecardQuery=llGetNotecardLine(readNotecardName, readNotecardLine);
            }
        }
    }
}
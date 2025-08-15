string  version="1.0.11";
list    g_allUserKeys=[];
list    g_allUserNames=[];
string  g_activeUser="";
key     g_activeKey=NULL_KEY;
integer g_repeatCount=3;
list    g_userMenuItem=["Attachments","BACK","CLOSE"];

// string getFormatedName(key id){
//     llOwnerSay(id);
//     string userName=llGetUsername(id);
//     string displayName=llGetDisplayName(id);
//     return displayName+" ("+userName+")";
// }

string getAttachPoint(integer pointNum){
    list pointMap=[
        ATTACH_HEAD,        "Skull",
        ATTACH_NOSE,        "Nose",
        ATTACH_MOUTH,       "Mouth",
        ATTACH_FACE_TONGUE, "Tongue",
        ATTACH_CHIN,        "Chin",
        ATTACH_FACE_JAW,    "Jaw",
        ATTACH_LEAR,        "Left Ear",
        ATTACH_REAR,        "Right Ear",
        ATTACH_FACE_LEAR,   "Alt Left Ear",
        ATTACH_FACE_REAR,   "Alt Right Ear",
        ATTACH_LEYE,        "Left Eye",
        ATTACH_REYE,        "Right Eye",
        ATTACH_FACE_LEYE,   "Alt Left Eye",
        ATTACH_FACE_REYE,   "Alt Right Eye",
        ATTACH_NECK,        "Neck",
        ATTACH_LSHOULDER,   "Left Shoulder",
        ATTACH_RSHOULDER,   "Right Shoulder",
        ATTACH_LUARM,       "L Upper Arm",
        ATTACH_RUARM,       "R Upper Arm",
        ATTACH_LLARM,       "L Lower Arm",
        ATTACH_RLARM,       "R Lower Arm",
        ATTACH_LHAND,       "Left Hand",
        ATTACH_RHAND,       "Right Hand",
        ATTACH_LHAND_RING1, "Left Ring Finger",
        ATTACH_RHAND_RING1, "Right Ring Finger",
        ATTACH_LWING,       "Left Wing",
        ATTACH_RWING,       "Right Wing",
        ATTACH_CHEST,       "Chest",
        ATTACH_LEFT_PEC,    "Left Pec",
        ATTACH_RIGHT_PEC,   "Right Pec",
        ATTACH_BELLY,       "Stomach",
        ATTACH_BACK,        "Spine",
        ATTACH_TAIL_BASE,   "Tail Base",
        ATTACH_TAIL_TIP,    "Tail Tip",
        ATTACH_AVATAR_CENTER, "Avatar Center",
        ATTACH_PELVIS,      "Pelvis",
        ATTACH_GROIN,       "Groin",
        ATTACH_LHIP,        "Left Hip",
        ATTACH_RHIP,        "Right Hip",
        ATTACH_LULEG,       "L Upper Leg",
        ATTACH_RULEG,       "R Upper Leg",
        ATTACH_RLLEG,       "R Lower Leg",
        ATTACH_LLLEG,       "L Lower Leg",
        ATTACH_LFOOT,       "Left Foot",
        ATTACH_RFOOT,       "Right Foot",
        ATTACH_HIND_LFOOT,  "Left Hind Foot",
        ATTACH_HIND_RFOOT,  "Right Hind Foot",

        ATTACH_HUD_CENTER_2,    "HUD Center 2",
        ATTACH_HUD_TOP_RIGHT,   "HUD Top Right",
        ATTACH_HUD_TOP_CENTER,  "HUD Top",
        ATTACH_HUD_TOP_LEFT,    "HUD Top Left",
        ATTACH_HUD_CENTER_1,    "HUD Center",
        ATTACH_HUD_BOTTOM_LEFT, "HUD Bottom Left",
        ATTACH_HUD_BOTTOM,      "HUD Bottom",
        ATTACH_HUD_BOTTOM_RIGHT, "HUD Bottom Right"
    ];
    return llList2String(pointMap, llListFindList(pointMap, [pointNum])+1 );
}

string getAttachPerm(integer perm){
    list permStr=[];
    if(PERM_COPY & perm){
        permStr+=["C"];
    }else{
        permStr+=["NC"];
    }
    if(PERM_MODIFY & perm){
        permStr+=["M"];
    }else{
        permStr+=["NM"];
    }
    if(PERM_TRANSFER & perm){
        permStr+=["T"];
    }else{
        permStr+=["NT"];
    }
    return llDumpList2String(permStr, "/");
}

outputAttachments(key id){
    list attachments=llGetAttachedList(id);
    llOwnerSay("========== Attachments found on secondlife:///app/agent/"+(string)id+"/about =========="); // 由于系统限制，只能使用SLURL
    integer i;
    for(i=0; i<llGetListLength(attachments); i++){
        key cur=llList2Key(attachments, i);
        list detail=llGetObjectDetails(cur, [OBJECT_NAME, OBJECT_CREATOR, OBJECT_ATTACHED_POINT, OBJECT_PERMS, OBJECT_GROUP]);
        string objName=llList2String(detail, 0);
        // string objAuthor=getFormatedName(llList2Key(detail, 1));
        string objAuthor="secondlife:///app/agent/"+llList2String(detail, 1)+"/about";
        string objPoint=getAttachPoint(llList2Integer(detail, 2));
        string objPerm=getAttachPerm(llList2Integer(detail, -2));
        string objGroup="secondlife:///app/group/"+llList2String(detail, -1)+"/about ("+llList2String(detail, -1)+")";
        if(i==0){
            llOwnerSay("User Group: "+objGroup);
        }
        llOwnerSay("\""+objName+"\" by "+objAuthor+" on "+objPoint+", Permission: "+objPerm);
    }
}

outputAttachmentsRepeat(key id, integer repeat){
    integer i;
    for(i=0; i<repeat; i++){
        outputAttachments(id);
        //llSleep(0.25);
    }
    llSleep(0.25);
    llOwnerSay("========== Attachments found on secondlife:///app/agent/"+(string)id+"/about =========="); // 由于系统限制，只能使用SLURL
    llSleep(1);
    llOwnerSay("========== ATTACHMENTS_END ==========\n\n\n");
}

integer g_numberOfKeys;
scanAvatar(){
    list keys = llGetAgentList(AGENT_LIST_REGION, []);
    g_numberOfKeys = llGetListLength(keys);
    vector currentPos = llGetPos();
    list newkeys;
    key thisAvKey;
    integer i;
    for (i = 0; i < g_numberOfKeys; ++i) {
        thisAvKey = llList2Key(keys,i);
        newkeys += [llVecDist(currentPos,
                        llList2Vector(llGetObjectDetails(thisAvKey, [OBJECT_POS]), 0)),
                    thisAvKey];
    }
    newkeys = llListSort(newkeys, 2, TRUE);

    g_allUserKeys=[];
    g_allUserNames=[];
    for (i = 0; i < (g_numberOfKeys * 2); i += 2) {
        g_allUserKeys +=[llList2Key(newkeys, i+1)];
        g_allUserNames+=[llGetSubString(llKey2Name(llList2Key(newkeys, i+1)), 0, 23)];
        //g_allUserNames+=[llGetSubString(llGetUsername(llList2Key(newkeys, i+1)), 0, 23)];
        // g_allUserNames+=[llKey2Name(llList2Key(newkeys, i+1))];
        // llOwnerSay(llGetUsername(llList2Key(newkeys, i+1))
        //     +" ["+ (string) llList2Float(newkeys, i) + "m]");
    }
}

showUserMenu(string username, key user){
    string menuStr="MENU.CONFIRM|aviUserMenu|About: secondlife:///app/agent/"+(string)g_activeKey+"/about|"+llDumpList2String(g_userMenuItem,";")+"|aviLookMenu";
    llMessageLinked(LINK_SET, 1000, menuStr, llGetOwner());
}

default{
    state_entry(){
        // llSetTimerEvent(1);
    }
    attach(key user){
        // if(user!=NULL_KEY){
        //     llSetTimerEvent(1);
        // }
    }
    timer(){
        scanAvatar();
    }
    touch_start(integer total_number){
        scanAvatar();
        string menuStr="MENU.REG.OPEN.RESET|aviLookMenu|Version: "+version+"\nChecked "+(string)g_numberOfKeys+" users.|"+llDumpList2String(g_allUserNames,";");
        llMessageLinked(LINK_SET, 1000, menuStr, llGetOwner());
    }

    link_message(integer sender_num, integer num, string msg, key user){
        list msgList=llParseStringKeepNulls(msg,["|"],[""]);
        string cmdName=llList2String(msgList, 0);
        if(cmdName=="MENU.ACTIVE"){
            string activeName=llList2String(msgList,1);
            string activeBu=llList2String(msgList,2);
            if(activeName=="aviLookMenu"){ // 选择用户菜单
                g_activeUser=activeBu;
                g_activeKey=llList2Key(g_allUserKeys, llListFindList(g_allUserNames, [g_activeUser]));
                showUserMenu(g_activeUser, g_activeKey);
            }else if(activeName=="aviUserMenu"){ // 抓取选项菜单
                if(activeBu==llList2String(g_userMenuItem,0)){ // 抓取附件
                    if(g_activeKey){
                        outputAttachmentsRepeat(g_activeKey, g_repeatCount);
                        showUserMenu(g_activeUser, g_activeKey);
                        // llMessageLinked(LINK_SET, 1000, "MENU.OPEN|aviUserMenu", llGetOwner());
                    }
                }
            }
        }else if(cmdName=="AVILOOK.GET"){
            key user=llList2Key(msgList,1);
            if(user){
                outputAttachmentsRepeat(user, g_repeatCount);
            }
        }
    }
}

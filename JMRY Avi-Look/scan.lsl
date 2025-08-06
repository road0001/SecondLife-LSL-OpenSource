string g_outputType="OBJECT";
vector g_camPos;
vector g_camDir;
vector g_targetPoint;
list   g_castRayRs;
list   g_objDetails;
key    g_targetObjKey;

integer g_listenHandle;
integer g_menuChannel=288078820;
integer g_outputInChat=TRUE;

// list g_agentList=[];
// key createrAgent;
// key ownerAgent;

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

getUserAttachments(key user){
    // llOwnerSay("Will capture user attachments. secondlife:///app/agent/"+(string)g_targetObjKey+"/about");
    llMessageLinked(LINK_SET, 0, "AVILOOK.GET|"+(string)user, llGetOwner());
}

getObjectInfo(list msg){
    list outputList=llParseStringKeepNulls(llDumpList2String(msg, ""), ["\n"], [""]);
    integer i;
    for(i=0; i<llGetListLength(outputList); i++){
        llOwnerSay(llList2String(outputList, i));
    }
    llOwnerSay("========== OBJECT_END ==========\n\n\n");
}

list updateCastRay(){
    g_camPos = llGetCameraPos();
    g_camDir = llRot2Fwd(llGetCameraRot());
    g_targetPoint = g_camPos + (g_camDir * 100.0);
    integer rejectTypes=RC_REJECT_LAND;
    integer detectPhantom=TRUE;
    integer dataFlags=RC_GET_ROOT_KEY;
    if(g_outputType=="OBJECT"){
        rejectTypes=RC_REJECT_LAND | RC_REJECT_AGENTS;
        detectPhantom=TRUE;
        dataFlags=RC_GET_ROOT_KEY;
    }
    else if(g_outputType=="AGENT"){
        rejectTypes=RC_REJECT_LAND | RC_REJECT_PHYSICAL | RC_REJECT_NONPHYSICAL;
        detectPhantom=FALSE;
        dataFlags=FALSE;
    }
    g_castRayRs=llCastRay(g_camPos, g_targetPoint, [
        RC_REJECT_TYPES, rejectTypes, 
        RC_DATA_FLAGS, dataFlags, 
        RC_DETECT_PHANTOM, detectPhantom,
        RC_MAX_HITS, 1
    ]);
    g_targetObjKey=llList2Key(g_castRayRs, 0);
    g_objDetails=llGetObjectDetails(g_targetObjKey, [OBJECT_NAME, OBJECT_DESC, OBJECT_CREATOR, OBJECT_OWNER, OBJECT_LAST_OWNER_ID, OBJECT_GROUP, OBJECT_ATTACHED_POINT, OBJECT_PERMS]);
    return g_castRayRs;
}

default{
    state_entry(){
        llRequestPermissions(llGetOwner(), PERMISSION_TRACK_CAMERA);
        llSetTimerEvent(1);
    }
    
    attach(key user){
        if(user!=NULL_KEY){
            llRequestPermissions(llGetOwner(), PERMISSION_TRACK_CAMERA);
            llSetTimerEvent(1);
        }
    }

    touch_start(integer total_number){
        key user=llDetectedKey(0);
        key this=llGetKey();
        updateCastRay();
        
        string name=llList2String(g_objDetails, 0);
        string desc=llList2String(g_objDetails, 1);
        key creater=llList2String(g_objDetails, 2);
        key owner=llList2String(g_objDetails, 3);
        key group=llList2String(g_objDetails, 5);
        integer perm=llList2Integer(g_objDetails, -1);
        
        list msg=[
            name, "\n",
            "Desc: ", desc, "\n",
            "Creater: ", "secondlife:///app/agent/"+(string)creater+"/about", " ("+(string)creater+")", "\n",
            "Owner: ", "secondlife:///app/agent/"+(string)owner+"/about", " ("+(string)owner+")", "\n",
            "Group: ", "secondlife:///app/group/"+(string)group+"/about", " ("+(string)group+")", "\n",
            "Permission: ", getAttachPerm(perm)
        ];
        list buttons=["OK"];
        
        if(name!="" && creater==NULL_KEY){
            msg=[
                "Name: ", "secondlife:///app/agent/"+(string)owner+"/about"
            ];
            buttons=["Attachments"]+buttons;
        }
        
        if(g_outputInChat==FALSE){
            llDialog(user, llDumpList2String(msg,""), buttons, g_menuChannel);
            g_listenHandle=llListen(g_menuChannel,"",llGetOwner(),"");
        }else{
            if(name!=""){
                if(creater==NULL_KEY){
                    getUserAttachments(g_targetObjKey);
                }else{
                    getObjectInfo(msg);
                }
            }
        }
    }
    listen(integer channel, string name, key id, string message){
        if(channel==g_menuChannel){
            if(message=="Attachments"){
                getUserAttachments(g_targetObjKey);
            }
            else if(message=="OK"){
                llListenRemove(g_listenHandle);
            }
        }
    }
    timer(){
        updateCastRay();
        string objText=llList2String(g_objDetails,0);
        // if(llList2Key(g_objDetails,2)!=NULL_KEY){
        //     // objText+="\nCreater: "+llKey2Name(llList2Key(g_agentList,0));
        //     // objText+="\nOwner: "+llKey2Name(llList2Key(g_agentList,1));
        //     createrAgent=llRequestAgentData(llList2Key(g_objDetails, 2), DATA_NAME);
        //     ownerAgent=llRequestAgentData(llList2Key(g_objDetails, 3), DATA_NAME);
        //     objText+="\nCreater: "+llList2String(g_agentList,0);
        //     objText+="\nOwner: "+llList2String(g_agentList,1);
        // }
        llSetText(objText, <0.0,1.0,0.0>, 0.5);
    }
    // dataserver(key queryid, string data){
    //     if(queryid == createrAgent){
    //         llListReplaceList([data], g_agentList, 0, 0);
    //     }
    //     if(queryid == ownerAgent){
    //         llListReplaceList([data], g_agentList, 1, 1);
    //     }
    // }
}

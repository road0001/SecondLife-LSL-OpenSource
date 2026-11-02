string searchName="";
key searchUser=NULL_KEY;

list objectList=[];

string userInfo(key user){
    return "secondlife:///app/agent/"+(string)user+"/about";
}

string mapInfo(vector pos){
    string regionname = llGetRegionName();
    return "http://maps.secondlife.com/secondlife/" + 
           llEscapeURL(regionname) + "/" + 
           (string)llRound(pos.x) + "/" + 
           (string)llRound(pos.y) + "/" + 
           (string)llRound(pos.z) + "/";
}

integer includes(string src, string target){
    integer startPos = llSubStringIndex(src, target);
    if(~startPos){
        return TRUE;
    }else{
        return FALSE;
    }
}

outputObjectDetails(){
    integer i;
    for(i=0; i<llGetListLength(objectList); i++){
        list details = llGetObjectDetails(llDetectedKey(i), [OBJECT_NAME, OBJECT_DESC, OBJECT_CREATOR, OBJECT_OWNER, OBJECT_POS, OBJECT_LAST_OWNER_ID, OBJECT_GROUP, OBJECT_ATTACHED_POINT, OBJECT_PERMS]);
        string objName=llList2String(details, 0);
        string objDesc=llList2String(details, 1);
        key objCreater=llList2Key(details, 2);
        key objOwner=llList2Key(details, 3);
        vector objPos=llList2Vector(details, 4);
        llOwnerSay((string)i+". "+objName+" "+mapInfo(objPos));
    }
}



default{
    state_entry(){
    }

    touch_start(integer total_number){
        llOwnerSay("Begin to Search <"+searchName+"> by "+userInfo(searchUser));
        llSensor(searchName, searchUser, ACTIVE | PASSIVE | SCRIPTED, 96.0, PI);
        //llSensor("Black Veil Spookzilla 10 Ghost", NULL_KEY, PASSIVE, 70.0, PI);
        //llSensor("", "7437a6f3-96d5-49ec-ad5a-285b96ed4910", PASSIVE, 96.0, PI);
    }
    
    sensor(integer num_detected){
        //llOwnerSay("Scaned "+(string)num_detected+" objects, filtering...");
        objectList=[];
        integer i;
        for (i = 0; i < num_detected; ++i){
            key objKey = llDetectedKey(i);
            list details = llGetObjectDetails(llDetectedKey(i), [OBJECT_NAME, OBJECT_DESC, OBJECT_CREATOR, OBJECT_OWNER, OBJECT_LAST_OWNER_ID, OBJECT_GROUP, OBJECT_ATTACHED_POINT, OBJECT_PERMS]);
            string objName=llList2String(details, 0);
            string objDesc=llList2String(details, 1);
            key objCreater=llList2Key(details, 2);
            key objOwner=llList2Key(details, 3);
            
            //llOwnerSay(objName);
            
            integer isFiltered=FALSE;
            if(searchName=="" || includes(objName, searchName)){
                if(searchUser==NULL_KEY || objOwner == searchUser){
                    isFiltered=TRUE;
                }
            }
            
            if(isFiltered==TRUE){
                objectList+=objKey;
            }
        }
        outputObjectDetails();
    }
    no_sensor(){
        llOwnerSay("Not found!");
    }
}

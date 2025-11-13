string userInfo(key user){
    return "secondlife:///app/agent/"+(string)user+"/about";
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

string bundleSplit="&&";
list bundle2List(string b){
    return strSplit(b, bundleSplit);
}
string list2Bundle(list b){
    return strJoin(b, bundleSplit);
}

string messageSplit="|";
list msg2List(string m){
    return strSplit(m, messageSplit);
}
string list2Msg(list m){
    return strJoin(m, messageSplit);
}

string dataSplit=";";
list data2List(string d){
    return strSplit(d, dataSplit);
}
string list2Data(list d){
    return strJoin(d, dataSplit);
}

integer isLocked=FALSE;
integer setLock(integer lock, key user){
    if(lock<0){
        if(!isLocked){
            isLocked=TRUE;
        }else{
            isLocked=FALSE;
        }
    }else{
        isLocked=lock;
    }
    list lockLink=[
        "RLV.LOCK",
        (string)isLocked
    ];
    llMessageLinked(LINK_SET, 1001, llDumpList2String(lockLink,"|"), user);
    showMenu(user);
    return isLocked;
}

showMenu(key user){
    string menuText="This is main menu.\nLocked: %1%\nOwner: %2%%%;"+(string)isLocked+";"+owner;
    list mainMenu=["["+(string)isLocked+"]Lock","RLV","Access","Settings","Language","Input","Test2","Test3","Test4","Test5","Test6","Test7","Test8","Test9","Test10","Test11","Test12","Test13","Test14","Test15"];
    list menuLink=[
        "MENU.REG.OPEN.RESET",
        "mainMenu",
        menuText,
        llDumpList2String(mainMenu,";")
    ];
    llMessageLinked(LINK_SET, 1000, llDumpList2String(menuLink,"|"), user);
}


string owner="Test";
string operator;
default{
    state_entry(){
        llMessageLinked(LINK_SET, 1001, "RLV.LOAD|rlvtest", NULL_KEY);
    }
    touch_start(integer num_detected)
    {
        key user=llDetectedKey(0);
        showMenu(user);
        
        
        //string json="[9,\"<1,1,1>\",false,{\"A\":8,\"Z\":9}]";
        //llJsonSetValue(json, ["test1"], "testv1");
        //llJsonSetValue(json, ["test2"], "testv2");
        //llOwnerSay("JSON: "+json);
        //llOwnerSay(llJsonGetValue(json,["test1"]));
    }
    link_message(integer sender_num, integer num, string str, key user)
    {
        if(num==1000){
            list menuCmdList=msg2List(str);
            string menuCmdStr=llList2String(menuCmdList, 0);
            string menuName=llList2String(menuCmdList, 1);
            string menuText=llList2String(menuCmdList, 2);
            if(menuCmdStr=="MENU.ACTIVE"){
                llOwnerSay(menuName+" -> "+menuText);

                if(menuText == "Lock"){
                    setLock(-1, user);
                }

                if(menuText=="Input"){
                    list menuLink=[
                        "MENU.INPUT",
                        "testInput",
                        "Input something you want..."
                    ];
                    llMessageLinked(LINK_SET, 1000, llDumpList2String(menuLink,"|"), user);
                }
            }
        }
        llOwnerSay("LINK_MESSAGE: "+str);
        //llOwnerSay("OPERATER: "+(string)user);
    }
}
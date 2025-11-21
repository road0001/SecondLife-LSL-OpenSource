/*
Name: RLV
Author: JMRY
Description: A better RLV management system, use link_message to operate RLV restraints.

***更新记录***
- 1.0.18 20251122
    - 加入锁定和RLV联动。
    - 优化RLV命令索引机制。

- 1.0.17 20251119
    - RLV获取锁定状态加入返回锁定用户。

- 1.0.16 20251114
    - 修复RLV功能菜单显示错误的bug。
    -修复REZ模式RLV失效的bug。

- 1.0.15 20251018
    - 加入Renamer表情标签。
    - 加入Renamer返回频道状态。

- 1.0.14 20250926
    - 修复编译时报错的bug。

- 1.0.13 20250806
    - 优化内存占用。

- 1.0.12 20250703
    - 修复rez的RLV道具回复消息中uuid错误的bug。

- 1.0.11 20250120
    - 优化锁定逻辑，修复锁定时无法从家具上站起来的bug。

- 1.0.10 20250118
    - 优化穿戴时RLV执行的逻辑。
    - 优化放置物体时，模式判断的逻辑。
    - 修复批量执行RLV时，结束条件错误导致后续指令无法执行的bug。

- 1.0.9 20250115
    - 调整配置文件格式。

- 1.0.8 20250114
    - 优化内存占用。
    - 修复修改配置文件时重置脚本的bug。

- 1.0.7 20250113
    - 修复RLV判断逻辑的bug。
    - 修复bugs。

- 1.0.6 20250108
    - 为RLV功能添加消息识别ID。
    - 调整RLV消息指令处理逻辑。

- 1.0.5 20250103
    - 加入读取记事卡导入RLV数据功能。
    - 修复部分bug，优化处理逻辑。

- 1.0.4 20241231
    - 加入重命名功能。
    - 优化捕获功能逻辑。

- 1.0.3 20241230
    - 加入RLV捕获功能。
    - 加入RLV消息回复监听功能。
    - 加入直接运行RLV指令字符串功能。
    - 调整RLV.RUN指令传递内容和运行方式。
    - 调整RLV执行入口以兼容REZ模式的RLV指令。

- 1.0.2 20241228
    - 修复bugs。

- 1.0.1 20241227
    - 初步完成RLV、管理、功能和菜单。

- 1.0 20241226
    - 初步完成RLV数据化管理。
***更新记录***
*/

/*
TODO:
- ~~应用RLV限制~~
- ~~RLV菜单~~
    - ~~可自定义的RLV主分类~~
    - ~~可自定义的RLV主分类下的子菜单~~
    - ~~根据子菜单注册的指令集一键应用RLV限制，并更新状态~~
- ~~锁定和解锁功能~~
- ~~renamer功能~~
- ~~穿戴时重新应用RLV功能~~
- ~~Rez时，RLV捕获和限制功能~~
- ~~RLV指定频道回复监听功能~~
- 获取#RLV文件夹内容并穿脱功能
- 内存和性能优化
*/

/*
基础功能依赖函数
*/
/*
根据用户UUID获取用户信息URL。
返回：带链接的 显示名称(用户名)
*/
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

// string dataSplit=",";
list data2List(string d){
    return strSplit(d, ",");
}
string list2Data(list d){
    return strJoin(d, ",");
}

// string mdataSplit=";";
list menuData2List(string d){
    return strSplit(d, ";");
}
string list2MenuData(list d){
    return strJoin(d, ";");
}

/*
设置RLV，参数：RLV指令，RLV值
*/
integer RLVRS=-1812221819; // default relay channel
integer RLV_MODE=0; // 0： wear mode；1：rez mode say；2：rez mode whisper；3：rez mode shout；else：rez mode regionSayTo
integer rlvWorldListenHandle;
// key RLV_VICTIM=NULL_KEY; // victim uuid in rez mode
integer executeRLV(string rlv){
    llListenRemove(rlvWorldListenHandle);
    if(RLV_MODE==0){
        llOwnerSay(rlv);
    }else{
        string rlvCmdName="RLV_EXECUTE_" + llGetObjectName();
        list rlvExecList =[rlvCmdName, VICTIM_UUID, replace(rlv,",","|")];
        string rlvExecStr=list2Data(rlvExecList);
        llOwnerSay(rlvExecStr);
        if(RLV_MODE==1){
            llSay(RLVRS,rlvExecStr);
        }else if(RLV_MODE==2){
            llWhisper(RLVRS,rlvExecStr);
        }else if(RLV_MODE==3){
            llShout(RLVRS,rlvExecStr);
        }else{
            llRegionSay(RLVRS,rlvExecStr);
        }
        rlvWorldListenHandle=llListen(RLVRS, "", NULL_KEY, "");
    }
    return RLV_MODE;
}

list rlvListKeyVal=[];
// list rlvListKey=[];
// list rlvListVal=[];
integer rlvChannel;
integer rlvListenHandle;
integer setRLV(string k, string v){
    if(k=="clear" && v==""){
        rlvListKeyVal=[];
        // rlvListKey=[];
        // rlvListVal=[];
        executeRLV("@clear");
        return TRUE;
    }
    rlvChannel=(integer)v;
    integer kIndex=llListFindList(rlvListKeyVal, [k]);
    if(!~kIndex && (v!="y" || v!="rem") && rlvChannel==0){ // ~var表示该变量!=-1，此处判断代表此key不存在，向后插入
        rlvListKeyVal+=[k,v];
        // rlvListKey+=k;
        // rlvListVal+=v;
    }else if(v=="y" || v=="rem" || rlvChannel!=0){ // v表示RLV生效状态，为y或rem时表示解除，因此从list中删除
        rlvListKeyVal=llDeleteSubList(rlvListKeyVal, kIndex, kIndex+1);
        // rlvListKey=llDeleteSubList(rlvListKey, kIndex, kIndex);
        // rlvListVal=llDeleteSubList(rlvListVal, kIndex, kIndex);
    }else{ // >=0代表此key存在，则不修改key，直接替换val值
        rlvListKeyVal=llListReplaceList(rlvListKeyVal,[v],kIndex+1,kIndex+1);
        // rlvListVal=llListReplaceList(rlvListVal,[v],kIndex,kIndex);
    }
    if(llGetSubString(k,0,0)!="_"){ // 以_开头的key作为标识符，不执行，例如：_LightBlind
        executeRLV("@"+k+"="+v);
    }
    llListenRemove(rlvListenHandle);
    llSetTimerEvent(0);
    if(v!="0"){
        rlvListenHandle=llListen(rlvChannel, "", currentUser, "");
    }
    llSetTimerEvent(60);
    return TRUE;
}
/*
获取RLV值，参数：RLV指令（不存在时返回空字符串）。参数为空时，获取当前生效的的RLV指令列表
*/
string getRLV(string k){
    if(k==""){
        integer count=llGetListLength(rlvListKeyVal);
        integer i;
        list rlvl=[];
        for(i=0; i<count; i+=2){
            rlvl+=["@"+llList2String(rlvListKeyVal, i)+"="+llList2String(rlvListKeyVal, i+1)];
        }
        return list2Data(rlvl);
    }else{
        integer kIndex=llListFindList(rlvListKeyVal, [k]);
        if(kIndex<0 || kIndex%2!=0){ // <0代表此key不存在，返回空字符串
            return "";
        }else{ // >=0代表此key存在，返回Val对应值
            return llList2String(rlvListKeyVal,kIndex+1);
        }
    }
}
/*
执行@开头的RLV指令，可不加@，可批量，如：@detach=n,unsit=n,fly=n
*/
integer setRLVStr(string r){
    string rr=replace(r,"@","");
    list rsp=data2List(rr);
    integer i;
    for(i=0; i<llGetListLength(rsp); i++){
        string cur=llList2String(rsp, i);
        list csp=llParseStringKeepNulls(cur,["="],[""]);
        string k=llList2String(csp, 0);
        string v=llList2String(csp, 1);
        setRLV(k, v);
    }
    return TRUE;
}
/*
是否受到RLV限制，参数：RLV指令
获取到的RLV值为n、add、force时，受到限制，返回TRUE。
获取到的RLV值为y、rem时，解除限制，返回FALSE。
获取到的RLV值为字符串时，不存在限制，返回FALSE。
*/
integer hasRLV(string k){
    integer kIndex=llListFindList(rlvListKeyVal, [k]);
    if(!~kIndex || kIndex%2!=0){ // <0代表此key不存在，返回空FALSE
        return FALSE;
    }else{ // >=0代表此key存在，返回Val对应值
        string kVal=llList2String(rlvListKeyVal, kIndex+1);
        if(kVal=="n" || kVal=="add" || kVal=="force"){
            return TRUE;
        }else if(kVal=="y" || kVal=="rem"){
            return FALSE;
        }else{
            return FALSE;
        }
    }
}
/*
执行RLV限制。在重新登录、穿戴时触发。按照每10条执行一次的方式执行。
*/
integer runRLV(){
    if(llGetListLength(rlvListKeyVal)<=0){
        return FALSE;
    }
    list rlvList=[];
    integer i=0;
    integer j=0;
    integer count=llGetListLength(rlvListKeyVal);
    for(i=0; i<count; i+=2){
        string rkey=llList2String(rlvListKeyVal,i);
        string rval=llList2String(rlvListKeyVal,i+1);
        string rlv=rkey+"="+rval;
        if(llStringLength(rlv)>36){ // rlv指令超过36个字母时，防止超长，直接输出，跳过队列
            executeRLV("@"+rlv);
        }else{
            rlvList+=[rlv];
            j++;
        }
        if(j%10==0 || i==count-2){ // j仅在插入list时+1。每记录10条，输出一次并清空list。最后一次循环将剩余部分全部输出。
            // 每10条或i等于总长-1时，输出rlv信息，并清空list
            executeRLV("@"+llDumpList2String(rlvList,","));
            rlvList=[];
        }
    }
    return TRUE;
}
/*
获取RLV自定格式的指令。
格式：RLV指令?受限值?解除值?扩展值
返回：RLV指令
*/
string rlvSpStr="?";
string rlvSpKey(string k){
    //shownames_sec?n?y => ["shownames_sec", "n", "y"]
    return llList2String(llParseStringKeepNulls(k, [rlvSpStr], [""]), 0);
}
/*
获取RLV自定格式指令对应值。
自定格式不全时，自动补全。
参数：RLV自定格式指令，二元或指定扩展值（FALSE、TRUE、2、3……）
格式：RLV指令?受限值?解除值?扩展值
返回：bool对应位字符串
*/
list rlvDefaultValList=[ // 自动应用RLV指令的值的指令名单（add/rem、force）
    // TODO
];
string rlvSpVal(string k, integer bool){
    // shownames_sec?n?y => ["shownames_sec", "n", "y"]
    // shownames_sec?add?rem => ["shownames_sec", "add", "rem"]
    // shownames_sec => ["shownames_sec", "n", "y"]
    list rlvSpList=llParseStringKeepNulls(k, [rlvSpStr], [""]);
    // 如果没有传开关值，则写入默认值
    if(llGetListLength(rlvSpList)<2){
        rlvSpList+=["n","y"]; // shownames_sec => ["shownames_sec", "n", "y"]
    }else if(llGetListLength(rlvSpList)<3){
        if(llList2String(rlvSpList,1)=="n"){
            rlvSpList+=["y"]; // shownames_sec?n => ["shownames_sec", "n", "y"]
        }else if(llList2String(rlvSpList,1)=="y"){
            rlvSpList+=["n"]; // shownames_sec?y => ["shownames_sec", "y", "n"]
        }else if(llList2String(rlvSpList,1)=="add" || llList2String(rlvSpList,1)=="force"){
            rlvSpList+=["rem"]; // shownames_sec?add => ["shownames_sec", "add", "rem"]; shownames_sec?force => ["shownames_sec", "force", "rem"]
        }else if(llList2String(rlvSpList,1)=="rem"){
            rlvSpList+=["add"]; // shownames_sec?rem => ["shownames_sec", "rem", "add"]
        }
    }
    integer i;
    if(bool==TRUE){
        i=1;
    }else if(bool==FALSE){
        i=2;
    }else{
        i=bool;
    }
    // llOwnerSay("RLV SP VAL K: "+k+" BOOL: "+(string)bool+" I: "+(string)i+" VAL: "+llList2String(rlvSpList, i));
    return llList2String(rlvSpList, i);
}

integer rlSpExist(string k){
    string rlvKey=rlvSpKey(k);
    string rlvValTrue=rlvSpVal(k,TRUE);
    string rlvValFalse=rlvSpVal(k,FALSE);
    string rlvStatus=getRLV(rlvKey);
    // llOwnerSay("RLV SP EXIST K: "+k+" KEY: "+rlvKey+" VT: "+rlvValTrue+" VF: "+rlvValFalse+" RS: "+rlvStatus);
    if(rlvStatus==rlvValTrue){
        return TRUE;
    }else if(rlvStatus==rlvValFalse){
        return FALSE;
    }else{
        return -1;
    }
}

/*
应用RLV指令。参数：RLV名称，RLV值参数，用户UUID
RLV名称通过查表，得到RLV指令集，并通过指令集中的自定义参数，得到每条RLV指令的二元值，通过遍历应用每条指令。
*/
integer applyRLVCmd(string name, integer bool){
    string rlvK=getRLVCmd(name);
    list rlvKeysWithVal=data2List(rlvK); // shownames_sec/n/y;setsphere_distmax:15/force/rem;removefit/n/y => ["shownames_sec/n/y", "setsphere_distmax:15/force/rem", "removefit/n/y"]
    integer rlvCount=llGetListLength(rlvKeysWithVal);
    if(bool<0){ // bool小于0时，根据RLV开启状态进行切换； bool等于TRUE或FALSE则根据bool开启或关闭
        if(hasRLVCmd(name)){
            // 有RLV限制，bool为FALSE，即解除
            bool=FALSE;
        }else{
            // 无RLV限制，bool为TRUE，即添加
            bool=TRUE;
        }
    }

    integer i;
    for(i=0;i<rlvCount;i++){
        string curRlv=llList2String(rlvKeysWithVal, i); // shownames_sec?n?y
        if(curRlv!=""){
            setRLV(rlvSpKey(curRlv), rlvSpVal(curRlv, bool)); // shownames_sec, n/y
        }
    }
    setRLVCmdEnabled(name, bool); // 更新RLV启用状态
    /*
    list rlvApplyRs=[
        name,
        rlvK,
        bool
    ];
    */
    // lightBlind | shownames_sec?n?y,setsphere_distmax:15?force?rem,removefit?n?y | 1
    // return list2Msg(rlvApplyRs);
    return bool;
}

/*
根据记录的RLV指令应用全部
*/
integer applyAllRLVCmd(){
    integer i;
    for(i=0; i<llGetListLength(rlvCmdNameKeyClass); i+=rlvCmdLength){
        string curRlvCmdName=llList2String(rlvCmdNameKeyClass, i);
        string curRlvCmd=llList2String(rlvCmdNameKeyClass, i+1);
        integer curRlvEnabled=llList2Integer(rlvCmdNameKeyClass, i+3);
        applyRLVCmd(curRlvCmdName, curRlvEnabled);
    }
    return TRUE;
}

list rlvClassName=[];
integer getRLVClass(string name){
    return llListFindList(rlvClassName, [name]);
}
integer addRLVClass(string name){
    integer rIndex=getRLVClass(name);
    if(!~rIndex){ // name不存在时，添加
        rlvClassName+=[name];
        return TRUE;
    }else{
        return FALSE; // class已存在时，不能重复添加
    }
}
integer removeRLVClass(string name){
    integer rIndex=getRLVClass(name);
    if(~rIndex){
        rlvClassName=llDeleteSubList(rlvClassName, rIndex, rIndex);
        return TRUE;
    }else{
        return FALSE;
    }
}
integer clearRLVClass(){
    rlvClassName=[];
    return TRUE;
}

/*
更新RLV名称与指令集，参数：RLV名称，RLV指令集（RLV命令1;RLV命令2;……）
如果不存在此名称，则添加。
*/
list rlvCmdNameKeyClass=[]; // name, rlvs, class, enabled
integer rlvCmdLength=4;
// list rlvCmdName=[];
// list rlvCmdKey=[];
// list rlvCmdClass=[];
string rlvCmdSpStr=",";
integer setRLVCmd(string name, list k, string class, integer enabled){
    integer rIndex;
    integer notFound=TRUE;
    for(rIndex=0; rIndex<llGetListLength(rlvCmdNameKeyClass); rIndex+=rlvCmdLength){
        string curRlvCmdName=llList2String(rlvCmdNameKeyClass, rIndex);
        if(curRlvCmdName == name){
            rlvCmdNameKeyClass=llListReplaceList(rlvCmdNameKeyClass,[llDumpList2String(k,rlvCmdSpStr), class, enabled],rIndex+1,rIndex+rlvCmdLength-1);
            notFound=FALSE;
        }
    }
    if(notFound==TRUE){
        rlvCmdNameKeyClass+=[name, llDumpList2String(k,rlvCmdSpStr), class, enabled];
    }
    if(class!=""){
        addRLVClass(class);
    }
    return TRUE;
    // integer rIndex=llListFindList(rlvCmdNameKeyClass, [name]);
    // if(!~rIndex){ // name不存在时，添加
    //     rlvCmdNameKeyClass+=[name, llDumpList2String(k,rlvCmdSpStr), class, enabled];
    //     // rlvCmdName +=[name];
    //     // rlvCmdKey  +=[llDumpList2String(k,rlvCmdSpStr)];
    //     // rlvCmdClass+=[class];
    // }else{ // name存在时，修改
    //     rlvCmdNameKeyClass=llListReplaceList(rlvCmdNameKeyClass,[llDumpList2String(k,rlvCmdSpStr), class, enabled],rIndex+1,rIndex+menuRegistLength-1);
    //     // rlvCmdKey  =llListReplaceList(rlvCmdKey,[llDumpList2String(k,rlvCmdSpStr)],rIndex,rIndex);
    //     // rlvCmdClass=llListReplaceList(rlvCmdClass,[class],rIndex,rIndex);
    // }
    // if(class!=""){
    //     addRLVClass(class);
    // }
    // return TRUE;
}
/*
设置RLV启用状态
*/
integer setRLVCmdEnabled(string name, integer enabled){
    integer i;
    for(i=0; i<llGetListLength(rlvCmdNameKeyClass); i+=rlvCmdLength){
        string curRlvCmdName=llList2String(rlvCmdNameKeyClass, i);
        if(curRlvCmdName == name){
            rlvCmdNameKeyClass=llListReplaceList(rlvCmdNameKeyClass,[enabled],i+3,i+3);
            return TRUE;
        }
    }
    return FALSE;
}
/*
根据RLV名称获取指令集。
*/
string getRLVCmd(string name){
    integer i;
    for(i=0; i<llGetListLength(rlvCmdNameKeyClass); i+=rlvCmdLength){
        string curRlvCmdName=llList2String(rlvCmdNameKeyClass, i);
        if(curRlvCmdName == name){
            return llList2String(rlvCmdNameKeyClass, i+1);
        }
    }
    return "";
    // integer rIndex=llListFindList(rlvCmdNameKeyClass, [name]);
    // if(~rIndex && rIndex%4==0){
    //     return llList2String(rlvCmdNameKeyClass, rIndex+1);
    // }else{
    //     return "";
    // }
}
/*
获取RLV启用状态
*/
integer getRLVCmdEnabled(string name){
    integer i;
    for(i=0; i<llGetListLength(rlvCmdNameKeyClass); i+=rlvCmdLength){
        string curRlvCmdName=llList2String(rlvCmdNameKeyClass, i);
        if(curRlvCmdName == name){
            return llList2Integer(rlvCmdNameKeyClass,i+3);
        }
    }
    return FALSE;
}
/*
根据RLV名称获取数据list
*/
list getRLVCmdData(string name){
    integer i;
    for(i=0; i<llGetListLength(rlvCmdNameKeyClass); i+=rlvCmdLength){
        string curRlvCmdName=llList2String(rlvCmdNameKeyClass, i);
        if(curRlvCmdName == name){
            return llList2List(rlvCmdNameKeyClass, i, i+rlvCmdLength-1);
        }
    }
    return [];
}
/*
根据RLV名称获取此指令集是否生效
*/
integer hasRLVCmd(string name){
    list rlvCmdData=getRLVCmdData(name);
    string rlvKey=llList2String(rlvCmdData,1);
    integer rlvEnabled=llList2Integer(rlvCmdData,3);
    if(rlvKey==""){
        return FALSE;
    }else if(rlvEnabled==TRUE){
        return rlvEnabled;
    }else{
        list rlvKeys=llParseStringKeepNulls(rlvKey,[rlvCmdSpStr],[""]);
        integer rlvCount=llGetListLength(rlvKeys);
        if(rlvCount<=0){
            return FALSE;
        }
        integer i;
        // 遍历指令集中每条指令，如果所有指令都生效，则返回TRUE；如果有一条没生效，则返回FALSE。
        for(i=0; i<rlvCount; i++){
            string cur=llList2String(rlvKeys, i);
            // llOwnerSay("===\nName: "+name+" rlvKey: "+rlvKey+" cur: "+cur);
            // llOwnerSay("rlvListKey:"+list2Data(rlvListKey));
            // llOwnerSay("rlvListVal:"+list2Data(rlvListVal));
            if(rlSpExist(cur)<=0){
                return FALSE;
            }
        }
        setRLVCmdEnabled(name, TRUE);
        return TRUE;
    }
}
integer removeRLVCmd(string name){
    integer i;
    for(i=0; i<llGetListLength(rlvCmdNameKeyClass); i+=rlvCmdLength){
        string curRlvCmdName=llList2String(rlvCmdNameKeyClass, i);
        if(curRlvCmdName == name){
            rlvCmdNameKeyClass=llDeleteSubList(rlvCmdNameKeyClass,i,i+rlvCmdLength-1);
            return TRUE;
        }
    }
    return FALSE;
    // integer rIndex=llListFindList(rlvCmdNameKeyClass, [name]);
    // if(~rIndex && rIndex%3==0){
    //     rlvCmdNameKeyClass=llDeleteSubList(rlvCmdNameKeyClass,rIndex,rIndex+3);
    //     // rlvCmdName=llDeleteSubList(rlvCmdName, rIndex, rIndex);
    //     // rlvCmdKey=llDeleteSubList(rlvCmdKey, rIndex, rIndex);
    //     return TRUE;
    // }else{
    //     return FALSE;
    // }
}
/*
清空RLV名称与指令集。
*/
integer clearRLVCmd(){
    rlvCmdNameKeyClass=[];
    // rlvCmdName=[];
    // rlvCmdKey=[];
    return TRUE;
}

integer isLocked=FALSE;
key lockUser=NULL_KEY;
integer lockRLVConnect=TRUE;
integer setLock(integer bool, key user){
    if(bool==-1){
        if(isLocked==FALSE){
            bool=TRUE;
        }else{
            bool=FALSE;
        }
    }
    string lockStr="detach";
    if(RLV_MODE>0){
        lockStr="unsit";
    }
    if(bool==0){
        setRLV(lockStr,"y");
        lockUser=NULL_KEY;
        if(lockRLVConnect==TRUE){ // 锁和RLV联动时，解锁清空所有限制，但保留RLV状态（hasRLV优先读取记录的状态）
            setRLV("clear","");
        }
    }else{
        setRLV(lockStr,"n");
        lockUser=user;
        if(lockRLVConnect==TRUE){ // 锁和RLV联动时，锁定即应用之前的限制
            applyAllRLVCmd();
        }
    }
    isLocked=bool;
    return bool;
}
integer getLock(){
    if(hasRLV("detach") || hasRLV("unsit")){
        return TRUE;
    }else{
        return FALSE;
    }
}
integer restoreLock(){
    return setLock(isLocked, lockUser);
}

/*
捕获用户（rez功能）
*/
key VICTIM_UUID;
integer captureVictim(key user){
    if(RLV_MODE<=0){
        return FALSE;
    }
    VICTIM_UUID=user;
    key objectUuid=llGetKey();
    string sitobj="sit:"+(string)objectUuid;
    return setRLV("sit:"+sitobj, "force");
}
integer isCaptureVictim(key user){
    if(VICTIM_UUID==NULL_KEY){
        return FALSE;
    }
    key objectUuid=llGetKey();
    string sitobj="sit:"+(string)objectUuid;
    if(VICTIM_UUID == user && hasRLV(sitobj)){
        return TRUE;
    }else{
        return FALSE;
    }
}
key getCaptureVictim(){
    key objectUuid=llGetKey();
    string sitobj="sit:"+(string)objectUuid;
    if(VICTIM_UUID != NULL_KEY && hasRLV(sitobj)){
        return (key)VICTIM_UUID;
    }else{
        return NULL_KEY;
    }
}

/*
Renamer功能
*/
integer renamerChannel;
integer renamerListenHandle;
string renamerName="";
integer renamerBool;
integer renamerEnabled(integer bool, key user){
    if(bool==-1){
        if(renamerBool==FALSE){
            bool=TRUE;
        }else{
            bool=FALSE;
        }
    }
    if(bool==TRUE){
        renamerListenHandle=llListen(renamerChannel, "", NULL_KEY, "");
        setRLV("redirchat:"+(string)renamerChannel,"add");
        setRLV("rediremote:"+(string)renamerChannel,"add");
        setRLV("emote","add");
    }else{
        setRLV("redirchat:"+(string)renamerChannel,"rem");
        setRLV("rediremote:"+(string)renamerChannel,"rem");
        setRLV("emote","rem");
        llListenRemove(renamerListenHandle);
    }
    renamerBool=bool;
    return bool;
}
integer renamerSay(string name, string msg, integer type) {
    string oname = llGetObjectName();
    llSetObjectName(":"); // llSetObjectName不支持中文，因此将remaer名字拼接到字符串中来显示。
    string renamerMsg;
    if(llGetSubString(msg, 0, 2) == "/me"){
        renamerMsg="/me "+name+" "+trim(llGetSubString(msg,3,-1));
    }else{
        renamerMsg=name+": "+msg;
    }
    
    if(type==0){
        llSay(0,renamerMsg);
    }else if(type==1){
        llWhisper(0,renamerMsg);
    }else{
        llShout(0,renamerMsg);
    }
    llSetObjectName(oname);
    return TRUE;
}

/*
RLV菜单控制
*/
string rlvMenuText="RLV";
string rlvMenuName="RLVMenu";
showRLVMenu(string parent, key user){
    list rlvMenuList=[
        "MENU.REG.OPEN",
        rlvMenuName,
        "RLV Menu",
        list2MenuData(rlvClassName),
        parent
    ];
    llMessageLinked(LINK_SET, MENU_MSG_NUM, list2Msg(rlvMenuList), user);
}

string rlvSubMenuName="RLVSubMenu";
string curRlvSubMenu="";
showRLVSubMenu(string class, key user){
    curRlvSubMenu=class;
    string rlvSubDesc="This is RLV %1% menu.%%;"+class;
    list rlvCmdList=[];
    integer rlvCmdCount=llGetListLength(rlvCmdNameKeyClass);
    integer i;
    for(i=0; i<rlvCmdCount; i+=rlvCmdLength){
        string cueName=llList2String(rlvCmdNameKeyClass, i);
        string curClass=llList2String(rlvCmdNameKeyClass, i+2);
        if(curClass==class){
            rlvCmdList+=["["+(string)hasRLVCmd(cueName)+"]"+cueName];
        }
    }
    list rlvSubMenuList=[
        "MENU.REG.OPEN",
        rlvSubMenuName,
        rlvSubDesc,
        list2MenuData(rlvCmdList),
        rlvMenuName
    ];
    llMessageLinked(LINK_SET, MENU_MSG_NUM, list2Msg(rlvSubMenuList), user);
}

string rlvHeader="rlv_"; // 语言文件名记事卡前缀rlv_语言名（英文），如：rlv_1, rlv_2等
list getRLVNotecards(){
    list rlvList=[];
    integer count = llGetInventoryNumber(INVENTORY_NOTECARD);
    integer i;
    for (i=0; i<count; i++){
        string notecardName = llGetInventoryName(INVENTORY_NOTECARD, i);
        if(llGetSubString(notecardName, 0, 3)==rlvHeader){
            rlvList+=[llGetSubString(notecardName, 4, -1)];
        }
    }
    return rlvList;
}

key readRLVQuery=NULL_KEY;
integer readRLVLine=0;
string readRLVName="";
string curRLVName="";
string curRLVClass="";
integer readRLVNotecards(string rname){
    readRLVLine=0;
    curRLVName=rname;
    readRLVName=rlvHeader+rname;
    curRLVClass="";
    if (llGetInventoryType(readRLVName) == INVENTORY_NOTECARD) {
        llOwnerSay("Begin reading RLV restraints: "+rname);
        clearRLVClass();
        clearRLVCmd();
        readRLVQuery=llGetNotecardLine(readRLVName, readRLVLine); // 通过给readRLVQuery赋llGetNotecardLine的key，从而触发datasever事件
        // 后续功能交给下方datasever处理
        return TRUE;
    }else{
        return FALSE;
    }
}

integer MENU_MSG_NUM=1000;
integer RLV_MSG_NUM=1001;
key currentUser=NULL_KEY;
default{
    state_entry(){
        renamerChannel=(integer)(99999999 - llFrand(10000000));
    }
    changed(integer change){
        if(change & CHANGED_OWNER){
            llResetScript();
        }
        if (change & CHANGED_LINK) {
            key avatar = llAvatarOnSitTarget();
            if (avatar != NULL_KEY){
                RLV_MODE=1;
                VICTIM_UUID=avatar;
            }else{
                VICTIM_UUID=NULL_KEY;
            }
        }
    }

    listen(integer channel, string name, key user, string message){
        if(channel==rlvChannel){ // 监听RLV返回数据并发送消息
            list msgList=["RLV.EXEC","CALLBACK",message];
            llMessageLinked(LINK_SET, RLV_MSG_NUM, list2Msg(msgList), user);
            llListenRemove(rlvListenHandle);
            llSetTimerEvent(0);
        }
        if(channel==renamerChannel){
            renamerSay(renamerName, message, FALSE);
        }
        // Rez模式与Relay的交互
        if(RLV_MODE>0 && channel==RLVRS){
            list dataList=data2List(message); // header,uuid,main,ext
            string cmdHeader=llList2String(dataList, 0);
            key    cmdUuid=llList2Key(dataList, 1);
            string cmdMain=llList2String(dataList, 2);
            string cmdExt =llList2String(dataList, 3);

            list replyList=[];
            // Relay:  ping,VICTIM_UUID,ping,ping
            // Object: ping,OBJECT_UUID,!pong
            if(cmdMain=="ping" && cmdExt=="ping" && cmdUuid==llGetKey()){ // Relay发送ping,ping，道具回复!pong
                replyList=[cmdHeader, llGetKey(), "!pong"];
            }
            // Relay:  BunchoCommands,VICTIM_UUID,!release
            // Object: BunchoCommands,OBJECT_UUID,!release,ok
            else if(cmdMain=="!release"){ // Relay发送释放指令，道具回复ok
                setRLV("clear","");
                VICTIM_UUID=NULL_KEY;
                replyList=[cmdHeader, llGetKey(), cmdMain, "ok"];
            }
            // Object: BunchoCommands,VICTIM_UUID,@remoutfit:shoes=force
            // Relay:  BunchoCommands,OBJECT_UUID,@remoutfit:shoes=force,ko
            // Object: BunchoCommands,VICTIM_UUID,@remoutfit:shoes=force
            else if(cmdExt=="ko"){ // Relay发送RLV执行结果为ko，则重新执行一次RLV指令
                executeRLV(cmdMain);
            }

            if(llGetListLength(replyList)>0){
                llSay(RLVRS,list2Data(replyList));
            }
        }
    }

    timer(){ // 超时关闭RLV监听并重置
        llListenRemove(rlvListenHandle);
        llSetTimerEvent(0);
    }

    attach(key user) {
        RLV_MODE=0;
        if(user!=NULL_KEY){
            llRequestPermissions(user, PERMISSION_TAKE_CONTROLS);
            runRLV();
        }else{
            executeRLV("@clear"); // 脱下时，仅清除RLV状态，不清空列表，下次穿戴时重新应用
        }
    }
    on_rez(integer start_param){
        // 登录、穿戴时也会触发on_rez，并且比attach更早触发。有时候登录时不触发attach，因此将attach的部分也添加到这里。
        integer attached=llGetAttached();
        if(attached>0){
            RLV_MODE=0;
            llRequestPermissions(llGetOwner(), PERMISSION_TAKE_CONTROLS);
            runRLV();
        }else{
            RLV_MODE=1;
        }
    }
    object_rez(key user){
        RLV_MODE=1;
    }
    link_message(integer sender_num, integer num, string msg, key user){
        if(num!=RLV_MSG_NUM && num!=MENU_MSG_NUM){
            return;
        }
        /*
        注册RLV类别，格式：标头 | RLV类别名1; RLV类别名2; RLV类别名3
        RLV.REG.CLASS | Class 1, Class 2, Class 3
        RLV.REGIST.CLASS | Class 1, Class 2, Class 3
        移除RLV类别
        RLV.REM.CLASS | ClassName
        RLV.REMOVE.CLASS | ClassName
        获取RLV类别Index
        RLV.GET.CLASS | ClassName
        返回（不存在时返回-1）：
        RLV.EXEC | RLV.GET.CLASS | 2
        清空RLV类别
        RLV.CLEAR.CLASS | ClassName

        注册RLV组，格式：标头 | RLV名 | RLV1, RLV2, ... | RLV类别（可选）
        如果RLV类别为空，则注册为野RLV组，不会出现在菜单中。
        RLV.REG | RLVName | RLV1, RLV2, RLV3, ...
        RLV.REGIST | RLVName | RLV1, RLV2, RLV3, ... | Class 1
        注册并应用
        RLV.REG.APPLY | RLVName | RRLV1, RLV2, RLV3, ... | -1
        RLV.REG.APPLY | RLVName | RLV1, RLV2, RLV3, ... | 1
        RLV.REGIST.APPLY | RLVName | RLV1, RLV2, RLV3, ... | 1 | Class 1
        应用已注册的RLV组
        RLV.APPLY | RLVName | -1
        RLV.APPLY | RLVName | 1
        RLV.APPLY | RLVName | 0
        移除RLV组
        RLV.REM | RLVName
        RLV.REMOVE | RLVName
        清空RLV组
        RLV.CLEAR | RLVName
        获取RLV组中的RLV指令
        RLV.GET | RLVName
        返回：
        RLV.EXEC | RLV.GET | RLV1, RLV2, RLV3

        直接执行RLV指令（@开头的RLV指令，可以不加@，用逗号分隔多条指令，如@detach=n,fly=n,unsit=n）
        不带参数时，一键执行当前存在的所有限制（runRLV()）
        RLV.RUN
        RLV.RUN | RLV1, RLV2, RLV3, ...
        锁定/解锁
        RLV.LOCK | -1
        RLV.LOCK | 1
        RLV.LOCK | 0
        获取锁定状态
        RLV.GET.LOCK
        返回：
        RLV.EXEC | RLV.GET.LOCK | 1;UUID
        重命名器
        RLV.RENAMER | Name | 1
        RLV.RENAMER | 0
        获取重命名器状态
        RLV.GET.RENAMER
        返回：
        RLV.EXEC | RLV.GET.RENAMER | Name, channel, 1
        捕获玩家
        RLV.CAPTURE | UUID
        获取捕获状态
        RLV.GET.CAPTURE | UUID
        获取已捕获玩家的UUID
        RLV.GET.CAPTUREID

        获取RLV状态（RLVName或@开头的具体RLV指令）
        RLV.GET.STATUS | RLVName1, RLVName2, RLVName3
        RLV.GET.STATUS | @RLV1, @RLV2, @RLV3
        返回：
        RLV.EXEC | RLV.GET.STATUS | 1, 1, 0 // RLV组中所有限制都为n或add时，返回1，否则返回0；多个组名批量返回
        RLV.EXEC | RLV.GET.STATUS | 0, 0, 1 // 返回RLV指令的状态，多条指令批量返回

        读取RLV记事卡（将覆盖现有的RLV数据）
        RLV.LOAD | rlv1
        返回：
        RLV.EXEC | RLV.LOAD | 1
        读取RLV记事卡列表
        RLV.LOAD.LIST
        返回：
        RLV.EXEC | RLV.LOAD.LIST | rlv1,rlv2,rlv3,...
        
        RLV执行后，会发送执行结果回调，格式：
        RLV.EXEC | RLV.REG.APPLY | 1 // 1=成功，0=失败，或其他结果字符串
        */
        currentUser=user;
        list msgList=bundle2List(msg);
        list resultList=[];
        integer msgCount=llGetListLength(msgList);
        integer mi;
        for(mi=0; mi<msgCount; mi++){
            string str=llList2String(msgList, mi);
            if (llGetSubString(str, 0, 3) == "RLV." && !includes(str, "EXEC")) {
                list rlvMsgList=msg2List(str);
                string rlvMsgStr=llList2String(rlvMsgList, 0);
                list rlvMsgGroup=llParseStringKeepNulls(rlvMsgStr, ["."], [""]);

                string rlvMsg=llList2String(rlvMsgGroup, 0);
                string rlvMsgSub=llList2String(rlvMsgGroup, 1);
                string rlvMsgExt=llList2String(rlvMsgGroup, 2);
                string rlvMsgExt2=llList2String(rlvMsgGroup, 3);

                string rlvMsgName=llList2String(rlvMsgList, 1);
                string rlvMsgCmd=llList2String(rlvMsgList, 2);
                string rlvMsgClass=llList2String(rlvMsgList, 3);
                string rlvMsgClass2=llList2String(rlvMsgList, 4);

                string result="";
                if(rlvMsgSub=="REG" || rlvMsgSub=="REGIST"){
                    if(rlvMsgExt==""){
                        result=(string)setRLVCmd(rlvMsgName, msg2List(rlvMsgCmd), rlvMsgClass, FALSE);
                    }
                    else if(rlvMsgExt=="CLASS"){
                        list rlvClsList=data2List(rlvMsgName);
                        list rstList=[];
                        integer i;
                        for(i=0; i<llGetListLength(rlvClsList); i++){
                            rstList+=[addRLVClass(llList2String(rlvClsList, i))];
                        }
                        result=list2Data(rstList);
                    }
                    else if(rlvMsgExt=="APPLY"){
                        result=(string)setRLVCmd(rlvMsgName, msg2List(rlvMsgCmd), rlvMsgClass2, TRUE);
                        result=(string)applyRLVCmd(rlvMsgName, (integer)rlvMsgClass);
                    }
                }
                else if(rlvMsgSub=="APPLY"){
                    result=(string)applyRLVCmd(rlvMsgName, (integer)rlvMsgCmd);
                }
                else if(rlvMsgSub=="REM" || rlvMsgSub=="REMOVE"){
                    if(rlvMsgExt==""){
                        result=(string)removeRLVCmd(rlvMsgName);
                    }
                    else if(rlvMsgExt=="CLASS"){
                        result=(string)removeRLVClass(rlvMsgName);
                    }
                }
                else if(rlvMsgSub=="CLEAR"){
                    if(rlvMsgExt==""){
                        result=(string)setRLV("clear","");
                    }
                    else if(rlvMsgExt=="CLASS"){
                        result=(string)clearRLVClass();
                    }
                    else if(rlvMsgExt=="CMD"){
                        result=(string)clearRLVCmd();
                    }
                }
                else if(rlvMsgSub=="LOCK"){
                    result=list2MenuData([setLock((integer)rlvMsgName, user), lockUser]);
                }
                else if(rlvMsgSub=="RENAMER"){
                    if(rlvMsgName=="SET"){
                        renamerName=rlvMsgCmd;
                        renamerEnabled(TRUE,user);
                        result=list2MenuData([(string)renamerName, renamerChannel, renamerBool]);
                    }else{
                        renamerEnabled((integer)rlvMsgName,user);
                        result=list2MenuData([(string)renamerName, renamerChannel, renamerBool]);
                    }
                }
                else if(rlvMsgSub=="CAPTURE"){
                    result=(string)captureVictim((key)rlvMsgName);
                }
                else if(rlvMsgSub=="LOAD"){
                    if(rlvMsgExt==""){
                        result=(string)readRLVNotecards(rlvMsgName);
                    }
                    if(rlvMsgExt=="LIST"){
                        result=(string)list2Data(getRLVNotecards());
                    }
                }
                else if(rlvMsgSub=="GET"){
                    if(rlvMsgExt==""){
                        result=getRLV("");
                    }
                    if(rlvMsgExt=="CLASS"){
                        result=(string)getRLVClass(rlvMsgName);
                    }
                    else if(rlvMsgExt=="LOCK"){
                        result=list2MenuData([getLock(), lockUser]);
                    }
                    else if(rlvMsgExt=="RENAMER"){
                        result=list2MenuData([(string)renamerName, renamerChannel, renamerBool]);
                    }
                    else if(rlvMsgExt=="CAPTURE"){
                        result=(string)isCaptureVictim((key)rlvMsgName);
                    }
                    else if(rlvMsgExt=="CAPTUREID"){
                        result=(string)getCaptureVictim();
                    }
                    else if(rlvMsgExt=="STATUS"){
                        list rlvStatusData=data2List(rlvMsgName);
                        list rlvStatusResult=[];
                        integer statusCount=llGetListLength(rlvStatusData);
                        integer si;
                        for(si=0; si<statusCount; si++){
                            string curStatus=llList2String(rlvStatusData, si);
                            if(llGetSubString(curStatus, 0, 0)=="@"){
                                rlvStatusResult+=[hasRLV(llGetSubString(curStatus, 1, -1))];
                            }else{
                                rlvStatusResult+=[hasRLVCmd(curStatus)];
                            }
                        }
                        result=list2Data(rlvStatusResult);
                    }
                    else if(rlvMsgExt=="CONNECT"){
                        result=(string)lockRLVConnect;
                    }
                    else if(rlvMsgName!=""){
                        result=getRLVCmd(rlvMsgName);
                    }
                }
                else if(rlvMsgSub=="SET"){
                    if(rlvMsgExt=="CONNECT"){
                        lockRLVConnect=(integer)rlvMsgName;
                        result=(string)lockRLVConnect;
                    }
                }
                else if(rlvMsgSub=="RUN"){
                    if(rlvMsgName!=""){
                        result=(string)setRLVStr(rlvMsgName);
                        // list rList=data2List(rlvMsgName);
                        // string val=rlvMsgCmd;
                        // integer rCount=llGetListLength(rList);
                        // integer ri;
                        // for(ri=0; ri<rCount; ri++){
                        //     string cur=llList2String(rList, ri);
                        //     result=(string)setRLV(cur, val);
                        // }
                    }else{
                        result=(string)runRLV();
                    }
                }
                if(result!=""){
                    list rlvExeResult=[
                        "RLV.EXEC", rlvMsgStr, result
                    ];
                    resultList+=[list2Msg(rlvExeResult)];
                }
            }
            else if(llGetSubString(str, 0, 4) == "MENU." && includes(str, "ACTIVE")) {
                list menuCmdList=msg2List(str);
                string menuCmdStr=llList2String(menuCmdList, 0);
                list menuCmdGroup=llParseStringKeepNulls(menuCmdStr, ["."], [""]);
    
                string menuCmd=llList2String(menuCmdGroup, 0);
                string menuCmdSub=llList2String(menuCmdGroup, 1);
    
                string menuName=llList2String(menuCmdList, 1);
                string menuButton=llList2String(menuCmdList, 2);

                if(menuButton==rlvMenuText){
                    showRLVMenu(menuName, user);
                }
                else if(menuName==rlvMenuName && menuButton!=""){
                    showRLVSubMenu(menuButton, user);
                }
                else if(menuName==rlvSubMenuName && menuButton!=""){
                    resultList+=[applyRLVCmd(menuButton, -1)];
                    showRLVSubMenu(curRlvSubMenu, user);
                }
            }
        }
        if(llGetListLength(resultList)>0){
            llMessageLinked(LINK_SET, RLV_MSG_NUM, list2Bundle(resultList), user); // RLV处理完成后的回调
        }
        //llOwnerSay("RLV Memory Used: "+(string)llGetUsedMemory()+" Free: "+(string)llGetFreeMemory());
    }

    dataserver(key query_id, string data){
        if (query_id == readRLVQuery) { // 通过readRLVNotecards触发读取记事卡事件，按行读取指定RLV（readRLVQuery）并设置相关数据。
            if (data == EOF) {
                llOwnerSay("Finished reading RLV restraints: "+curRLVName);
                llMessageLinked(LINK_SET, RLV_MSG_NUM, list2Msg(["RLV.LOAD.NOTECARD",TRUE]), NULL_KEY); // RLV成功读取记事卡后回调
                readRLVQuery=NULL_KEY;
            } else {
                /*
                [RLVClass1]
                RLVName1=rlv1,rlv2,rlv3,...
                RLVName2=rlv1,rlv2,rlv3,...
                [RLVClass2]
                RLVName3=rlv1,rlv2,rlv3,...
                RLVName4=rlv1,rlv2,rlv3,...
                */
                if(data!="" && llGetSubString(data,0,0)!="#"){
                    if(llGetSubString(data,0,0)=="[" && llGetSubString(data,-1,-1)=="]"){
                        curRLVClass=llGetSubString(data,1,-2);
                    }else{
                        list rlvStrSp=llParseStringKeepNulls(data, ["="], []);
                        string rlvName=llList2String(rlvStrSp,0);
                        list rlvData=data2List(llList2String(rlvStrSp,1));

                        setRLVCmd(rlvName, rlvData, curRLVClass, FALSE);
                    }
                }

                // increment line count
                ++readRLVLine;
                //request next line of notecard.
                readRLVQuery=llGetNotecardLine(readRLVName, readRLVLine);
            }
        }
    }
}
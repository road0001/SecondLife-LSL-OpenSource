initConfig(){
    particleEnabled    = TRUE;
    particleFlags      = -1;
    particleSrcPattern = PSYS_SRC_PATTERN_DROP;
    particleMode       = "Ribbon"; // Ribbon, Chain, Leather, Rope, None
    particleMaxAge     = 3.5;
    particleColor      = <1.0,1.0,1.0>;
    particleColorEnd   = <1.0,1.0,1.0>;
    particleAlpha      = 1.0;
    particleAlphaEnd   = 1.0;
    particleScale      = <0.04,0.04,1.0>;
    particleScaleEnd   = <0.04,0.04,1.0>;
    particleBurstRate  = 0.0;
    particleGravity    = <0.0,0.0,-1.0>;
    particleCount      = 1;
    particleFullBright = TRUE;
    particleGlow       = 0.2;
    particleGlowEnd    = 0.2;
    particleTextureList= [
        "Ribbon",  "cdb7025a-9283-17d9-8d20-cee010f36e90", // Ribbon
        "Chain",   "4cde01ac-4279-2742-71e1-47ff81cc3529", // Chain
        // "Leather", "8f4c3616-46a4-1ed6-37dc-9705b754b7f1", // Leather
        // "Rope",    "9a342cda-d62a-ae1f-fc32-a77a24a85d73", // Rope
        "None",    "8dcd4a48-2d37-4909-9f78-f7a9eb4ef903"  // None, TEXTURE_TRANSPARENT
    ];
    particleColorList  = [
        "White",      <1.0, 1.0, 1.0>, 
        "Black",      <0.0, 0.0, 0.0>, 
        "Gray",       <0.5, 0.5, 0.5>, 
        "Red",        <1.0, 0.0, 0.0>, 
        "Green",      <0.0, 1.0, 0.0>, 
        "Blue",       <0.0, 0.0, 1.0>, 
        "Yellow",     <1.0, 1.0, 0.0>, 
        "Pink",       <1.0, 0.5, 0.6>, 
        "Brown",      <0.2, 0.1, 0.0>, 
        "Purple",     <0.6, 0.2, 0.7>, 
        "Barbie",     <0.9, 0.0, 0.3>, 
        "Orange",     <0.9, 0.6, 0.0>, 
        "Toad",       <0.2, 0.2, 0.0>, 
        "Khaki",      <0.6, 0.5, 0.3>, 
        "Pool",       <0.1, 0.8, 0.9>, 
        "Blood",      <0.5, 0.0, 0.0>, 
        "Anthracite", <0.1, 0.1, 0.1>, 
        "Midnight",   <0.0, 0.1, 0.2>
    ];

    leashPointName     = "leashpoint";
    leashLength        = 3;
    leashTurnMode      = TRUE;
    leashStrictMode    = FALSE;
    leashAwait         = 0.2;
    leashMaxRange      = 60;
    leashPosOffset     = <0.0,0.0,0.0>;
}
/*CONFIG END*/
/*
Name: Leash
Author: JMRY
Description: A better leash control system, use link_message to operate leashes.

***更新记录***
- 1.1.5 20260211
    - 优化代码结构。

- 1.1.4 20260203
    - 优化记事卡读取的回调逻辑，在没有记事卡时直接回调。
    - 修复Leash Handle脱掉时，粒子追踪失效的bug。

- 1.1.3 20260128
    - 优化内存占用。

- 1.1.2 20260120
    - 优化内存占用。

- 1.1.1 20260116
    - 加入更多配置项。
    - 优化菜单中材质和颜色选择按钮。
    - 调整Leash point的识别方法，在没有Leash point时，使用脚本锁在prim作为Leash point。
    - 修复无法识别leash holder的bug。
    - 修复RLV限制清空后，严格模式没有成功恢复的bug。

- 1.1 20260115
    - 优化牵引时的自动转向体验。
    - 调整配置储存方式，优化内存占用。
    - 修复没有Leash point时，松开牵绳粒子效果仍然持续的bug。

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

// string userName(key user, integer type){
//     string username=llGetUsername(user);
//     string displayname=llGetDisplayName(user);
//     if(type==1){
//         return username;
//     }else if(type==2){
//         return displayname;
//     }else{
//         return displayname+" ("+username+")";
//     }
// }


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
// string strJoin(list m, string sp){
//     return llDumpList2String(m, sp);
// }

// string dataSplit=";";
list data2List(string d){
    return strSplit(d, ";");
}
string list2Data(list d){
    return llDumpList2String(d, ";");
}
// string list2RlvData(list d){
//     return strJoin(d, ",");
// }

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
// list leashConfig=[
//     "particleEnabled",         "1",
//     "particleMode",         "Ribbon", // Ribbon, Chain, Leather, Rope, None
//     "particleMaxAge",         "3.5",
//     "particleColor",         "<1.0,1.0,1.0>",
//     "particleScale",         "<0.04,0.04,1.0>",
//     "particleBurstRate",    "0.0",
//     "particleGravity",         "<0.0,0.0,-1.0>",
//     "particleCount",         "1",
//     "particleFullBright",    "1",
//     "particleGlow",            "0.2",
//     "particleTextureRibbon","cdb7025a-9283-17d9-8d20-cee010f36e90",
//     "particleTextureChain", "4cde01ac-4279-2742-71e1-47ff81cc3529",
//     "particleTextureLeather","8f4c3616-46a4-1ed6-37dc-9705b754b7f1",
//     "particleTextureRope",     "9a342cda-d62a-ae1f-fc32-a77a24a85d73",
//     "particleTextureNone",     "8dcd4a48-2d37-4909-9f78-f7a9eb4ef903", // TEXTURE_TRANSPARENT
//     "particleColorList",    "White;<1.0,1.0,1.0>;Black;<0.0,0.0,0.0>;Gray;<0.5,0.5,0.5>;Red;<1.0,0.0,0.0>;Green;<0.0,1.0,0.0>;Blue;<0.0,0.0,1.0>;Yellow;<1.0,1.0,0.0>;Pink;<1.0,0.5,0.6>;Brown;<0.2,0.1,0.0>;Purple;<0.6,0.2,0.7>;Barbie;<0.9,0.0,0.3>;Orange;<0.9,0.6,0.0>;Toad;<0.2,0.2,0.0>;Khaki;<0.6,0.5,0.3>;Pool;<0.1,0.8,0.9>;Blood;<0.5,0.0,0.0>;Anthracite;<0.1,0.1,0.1>;Midnight;<0.0,0.1,0.2>",

//     "leashPointName",         "leashpoint",
//     "leashLength",             "3",
//     "leashTurnMode",         "1",
//     "leashStrictMode",         "0",
//     "leashAwait",             "0.2",
//     "leashMaxRange",        "60",
//     "leashPosOffset",        "<0.0,0.0,0.0>"
// ];

integer particleEnabled    = TRUE;
integer particleFlags      = -1;
integer particleSrcPattern = PSYS_SRC_PATTERN_DROP;
string  particleMode       = "Ribbon"; // Ribbon, Chain, Leather, Rope, None
float   particleMaxAge     = 3.5;
vector  particleColor      = <1.0,1.0,1.0>;
vector  particleColorEnd   = <1.0,1.0,1.0>;
float   particleAlpha      = 1.0;
float   particleAlphaEnd   = 1.0;
vector  particleScale      = <0.04,0.04,1.0>;
vector  particleScaleEnd   = <0.04,0.04,1.0>;
float   particleBurstRate  = 0.0;
vector  particleGravity    = <0.0,0.0,-1.0>;
integer particleCount      = 1;
integer particleFullBright = TRUE;
float   particleGlow       = 0.2;
float   particleGlowEnd    = 0.2;
list    particleTextureList= [];
list    particleColorList  = [];

string  leashPointName     = "leashpoint";
float   leashLength        = 3;
integer leashTurnMode      = TRUE;
integer leashStrictMode    = FALSE;
float   leashAwait         = 0.2;
float   leashMaxRange      = 60;
vector  leashPosOffset     = <0.0,0.0,0.0>;


string setConfig(string k, string v){
    if     (k=="particleEnabled") particleEnabled=(integer)v;
    else if(k=="particleFlags"){
        list pList=data2List(v);
        particleFlags=0;
        integer i;
        for(i=0; i<llGetListLength(pList); i++){
            particleFlags=particleFlags | llList2Integer(pList, i);
        }
    }
    else if(k=="particleSrcPattern"){
        list pList=data2List(v);
        particleSrcPattern=0;
        integer i;
        for(i=0; i<llGetListLength(pList); i++){
            particleSrcPattern=particleSrcPattern | llList2Integer(pList, i);
        }
    }
    else if(k=="particleMode") particleMode=v;
    else if(k=="particleMaxAge") particleMaxAge=(float)v;

    else if(k=="particleColor") {
        particleColor=(vector)v;
        particleColorEnd=(vector)v;
    }
    else if(k=="particleColorEnd") particleColorEnd=(vector)v;

    else if(k=="particleAlpha") {
        particleAlpha=(float)v;
        particleAlphaEnd=(float)v;
    }
    else if(k=="particleAlphaEnd") particleAlphaEnd=(float)v;

    else if(k=="particleScale") {
        particleScale=(vector)v;
        particleScaleEnd=(vector)v;
    }
    else if(k=="particleScaleEnd") particleScaleEnd=(vector)v;

    else if(k=="particleBurstRate") particleBurstRate=(float)v;
    else if(k=="particleGravity") particleGravity=(vector)v;
    else if(k=="particleCount") particleCount=(integer)v;
    else if(k=="particleFullBright") particleFullBright=(integer)v;

    else if(k=="particleGlow") {
        particleGlow=(float)v;
        particleGlowEnd=(float)v;
    }
    else if(k=="particleGlowEnd") particleGlowEnd=(float)v;

    else if(k=="particleTextureList") particleTextureList=data2List(v);
    else if(k=="particleColorList"){
        list configColorList=data2List(v);
        particleColorList=[];
        integer i;
        for(i=0; i<llGetListLength(configColorList); i++){
            if(i%2==0){ // 0, 2, 4, 6... ColorName
                particleColorList+=[llList2String(configColorList, i)]; // ColorName
            }else{
                particleColorList+=[(vector)llList2String(configColorList, i)]; // ColorVector
            }
        }
    }

    else if(k=="leashPointName") leashPointName=v;
    else if(k=="leashLength") leashLength=(float)v;
    else if(k=="leashTurnMode") leashTurnMode=(integer)v;
    else if(k=="leashStrictMode") leashStrictMode=(integer)v;
    else if(k=="leashAwait") leashAwait=(float)v;
    else if(k=="leashMaxRange") leashMaxRange=(float)v;
    else if(k=="leashPosOffset") leashPosOffset=(vector)v;
    
    return v;
}

string getConfig(string k){
    if     (k=="particleEnabled") return (string)particleEnabled;

    else if(k=="particleFlags") return (string)particleFlags;
    else if(k=="particleSrcPattern") return (string)particleSrcPattern;

    else if(k=="particleMode") return (string)particleMode;
    else if(k=="particleMaxAge") return (string)particleMaxAge;

    else if(k=="particleColor") return (string)particleColor;
    else if(k=="particleColorEnd") return (string)particleColorEnd;

    else if(k=="particleAlpha") return (string)particleAlpha;
    else if(k=="particleAlphaEnd") return (string)particleAlphaEnd;

    else if(k=="particleScale") return (string)particleScale;
    else if(k=="particleScaleEnd") return (string)particleScaleEnd;

    else if(k=="particleBurstRate") return (string)particleBurstRate;
    else if(k=="particleGravity") return (string)particleGravity;
    else if(k=="particleCount") return (string)particleCount;
    else if(k=="particleFullBright") return (string)particleFullBright;

    else if(k=="particleGlow") return (string)particleGlow;
    else if(k=="particleGlowEnd") return (string)particleGlowEnd;
    
    else if(k=="particleTextureList") return list2Data(particleTextureList);
    else if(k=="particleColorList") return list2Data(particleColorList);

    else if(k=="leashPointName") return (string)leashPointName;
    else if(k=="leashLength") return (string)leashLength;
    else if(k=="leashTurnMode") return (string)leashTurnMode;
    else if(k=="leashStrictMode") return (string)leashStrictMode;
    else if(k=="leashAwait") return (string)leashStrictMode;
    else if(k=="leashMaxRange") return (string)leashMaxRange;
    else if(k=="leashPosOffset") return (string)leashPosOffset;
    else return "";
}


// string setConfig(string k, string v){
//     integer index=llListFindList(leashConfig, [k]);
//     if(~index){
//         leashConfig=llListReplaceList(leashConfig,[v],index+1,index+1);
//     }else{
//         leashConfig+=[k, v];
//     }
//     return v;
// }
// string getConfig(string k){
//     if(k==""){
//         return list2Data(leashConfig);
//         // list configList=[];
//         // integer i;
//         // for(i=0; i<llGetListLength(leashConfig); i++){
//         //     if(i%2!=0){
//         //         configList+=llList2String(leashConfig, i);
//         //     }
//         // }
//         // return list2Data(configList);
//     }
//     integer index=llListFindList(leashConfig, [k]);
//     if(~index){
//         return llList2String(leashConfig, index+1);
//     }else{
//         return "";
//     }
// }

vector getParticleColorVector(string colorName){
    integer index = llListFindList(particleColorList, [colorName]);
    if(~index){
        return llList2Vector(particleColorList, index+1);
    }else{
        return ZERO_VECTOR;
    }
}

string getParticleColorName(vector color){
    integer index = llListFindList(particleColorList, [color]);
    if(~index){
        return llList2String(particleColorList, index-1);
    }else{
        return "";
    }
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
//         PSYS_PART_START_GLOW,particleGlow,
//         PSYS_SRC_TARGET_KEY,target,
//         PSYS_SRC_MAX_AGE, 0,
//         PSYS_SRC_TEXTURE, particleTexture
//     ];
//     llLinkParticleSystem(link, particleParams);
// }

key startParticles(key target){
    // stopParticles();
    list leashPoints=getLinksByName(leashPointName);
    if(llGetListLength(leashPoints)<=0){
        leashPoints+=[LINK_THIS]; // No leashpoints, use link_set
    }
    integer i;
    for(i=0; i<llGetListLength(leashPoints); i++){
        llLinkParticleSystem(llList2Integer(leashPoints, i), []);
    }

    if(target==NULL_KEY){
        return target;
    }
    if(particleMode=="None"){
        return NULL_KEY;
    }

    key particleTexture=NULL_KEY;
    integer particleTextureIndex=llListFindList(particleTextureList, [particleMode]);
    if(~particleTextureIndex){
        particleTexture=llList2Key(particleTextureList, particleTextureIndex+1);
    }
    if(particleTexture==NULL_KEY){
        particleTexture=TEXTURE_TRANSPARENT;
    }

    // activeParticles
    integer innerParticleFlags=particleFlags;
    if(innerParticleFlags==-1){
        innerParticleFlags = PSYS_PART_FOLLOW_VELOCITY_MASK | PSYS_PART_TARGET_POS_MASK | PSYS_PART_FOLLOW_SRC_MASK;
    }
    if(particleMode == "Ribbon"){ // Ribbon
        innerParticleFlags = innerParticleFlags | PSYS_PART_RIBBON_MASK;
    }
    if(particleFullBright==TRUE){
        innerParticleFlags = innerParticleFlags | PSYS_PART_EMISSIVE_MASK;
    }
    list particleParams = [
        PSYS_PART_MAX_AGE,particleMaxAge,
        PSYS_PART_FLAGS,innerParticleFlags,
        PSYS_PART_START_COLOR, particleColor,
        PSYS_PART_END_COLOR, particleColorEnd,
        PSYS_PART_START_ALPHA, particleAlpha,
        PSYS_PART_END_ALPHA, particleAlphaEnd,
        PSYS_PART_START_SCALE,particleScale,
        PSYS_PART_END_SCALE,particleScaleEnd,
        PSYS_SRC_PATTERN, particleSrcPattern,
        PSYS_SRC_BURST_RATE,particleBurstRate,
        PSYS_SRC_ACCEL, particleGravity,
        PSYS_SRC_BURST_PART_COUNT,particleCount,
        //PSYS_SRC_BURST_SPEED_MIN,fMinSpeed,
        //PSYS_SRC_BURST_SPEED_MAX,fMaxSpeed,
        PSYS_PART_START_GLOW,particleGlow,
        PSYS_PART_END_GLOW,particleGlowEnd,
        PSYS_SRC_TARGET_KEY,target,
        PSYS_SRC_MAX_AGE, 0,
        PSYS_SRC_TEXTURE, particleTexture
    ];

    // integer i;
    // list leashPoints=getLinksByName(leashPointName);
    leashPoints=getLinksByName(leashPointName);
    if(llGetListLength(leashPoints)<=0){
        leashPoints+=[LINK_THIS]; // No leashpoints, use link_set
    }
    for(i=0; i<llGetListLength(leashPoints); i++){
        // activeParticles(llList2Integer(leashPoints, i), target, particleMode, particleTexture, particleScale, particleColor, particleGravity, particleCount, particleFullBright, particleGlow, particleMaxAge, particleBurstRate);
        llLinkParticleSystem(llList2Integer(leashPoints, i), particleParams);
    }
    return target;
}

// stopParticles() {
//     list leashPoints=getLinksByName(leashPointName);
//     if(llGetListLength(leashPoints)<=0){
//         leashPoints+=[LINK_THIS]; // No leashpoints, use link_set
//     }
//     integer i;
//     for(i=0; i<llGetListLength(leashPoints); i++){
//         llLinkParticleSystem(llList2Integer(leashPoints, i), []);
//     }
// }

/*
牵引系统
*/
key leashTarget=NULL_KEY;
integer leashParticleEnabled;
integer leashHolderHandle;
integer allowAutoTurn=FALSE;
key leashToTarget(key target, integer particleEnabled){
    if(particleEnabled<0){ // Yank模式
        if (llGetAgentInfo(llGetOwner()) & AGENT_SITTING){
            llMessageLinked(LINK_SET, RLV_MSG_NUM, "RLV.RUN.TEMP|unsit=force", NULL_KEY);
        }
        llMoveToTarget(llList2Vector(llGetObjectDetails(target, [OBJECT_POS]), 0), 0.5);
        llSleep(2.0);
        llStopMoveToTarget();
        return target;
    }

    leashTarget=target;
    leashParticleEnabled=particleEnabled;

    if(leashTarget!=NULL_KEY){ // Leash
        if(REZ_MODE==FALSE){
            llRequestPermissions(llGetOwner(),PERMISSION_TRIGGER_ANIMATION); // Request auto turn perm
        }
        timerCount=0;
        llSetTimerEvent(leashAwait); // Move to target in timer

        if(particleEnabled==TRUE){
            startParticles(leashTarget);
            llSay(CHANNEL_LOCK_MEISTER, (string)target+"collar"); // 发送LockMeister指令以链接holder
            leashHolderHandle=llListen(CHANNEL_LOCK_MEISTER, "", NULL_KEY, "");
        }else{
            // stopParticles();
            startParticles(NULL_KEY);
            llListenRemove(leashHolderHandle);
        }
    }else{ // Unleash
        // stopParticles();
        startParticles(NULL_KEY);
        llSetTimerEvent(0);
        llListenRemove(leashHolderHandle);
    }
    applyStrictMode();
    return target;
}

integer leashStrictFlag=FALSE;
applyStrictMode(){
    string strictRestraints="fly=n,tplm=n,tplure=n,tploc=n,tplure:"+(string)leashTarget+"=add,sittp=n,accepttp:"+(string)leashTarget+"=add";
    if(leashStrictMode==TRUE && leashTarget!=NULL_KEY){
        llOwnerSay("@"+strictRestraints);
        leashStrictFlag=TRUE;
    }else if(leashStrictMode==FALSE || leashTarget==NULL_KEY){
        if(leashStrictFlag==TRUE){ // 严格模式RLV限制清除，只有触发过严格模式才进行。临时执行取消限制后，重新执行记录的RLV限制
            llOwnerSay("@"+replace(replace(strictRestraints, "=add", "=rem"), "=n", "=y"));
            llMessageLinked(LINK_SET, RLV_MSG_NUM, "RLV.RUN", NULL_KEY);
            leashStrictFlag=FALSE;
        }
    }
}

// key yankToTarget(key target){
//     if (llGetAgentInfo(llGetOwner()) & AGENT_SITTING){
//         llMessageLinked(LINK_SET, RLV_MSG_NUM, "RLV.RUN.TEMP|unsit=force", NULL_KEY);
//     }
//     llMoveToTarget(llList2Vector(llGetObjectDetails(target, [OBJECT_POS]), 0), 0.5);
//     llSleep(2.0);
//     llStopMoveToTarget();
//     return target;
// }

/*
权限控制
*/
list owner=[];
// integer checkOwner(key user){
//     integer index=llListFindList(owner, [(string)user]); // 从link_message接收的list被直接转化为了string的list而没转成key，因此要将key转成string再判断。
//     if(~index){
//         return TRUE;
//     }else{
//         return FALSE;
//     }
// }


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
    integer ownerIndex=llListFindList(owner, [(string)user]); // 从link_message接收的list被直接转化为了string的list而没转成key，因此要将key转成string再判断。
    if(~ownerIndex){
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
        for(i=0; i<llGetListLength(sensorUserList); i++){
            key uk=llList2Key(sensorUserList, i);
            if(uk){
                // string un=userName(uk,1);
                // userList+=[(string)(i+1) + ". " + un];
                // buttonList+=[(string)(i+1) + ". " + un];
                buttonList+=[(string)(i+1) + ". " + llGetUsername(uk)];
            }
        }
    }
    else if(menuName=="Anchor"){
        menuText="Select object to %1%.%%;"+menuName;
        integer i;
        for(i=0; i<llGetListLength(sensorUserList); i++){
            key uk=llList2Key(sensorUserList, i);
            if(uk){
                string un=llList2String(llGetObjectDetails(uk, [OBJECT_NAME]), 0);
                // userList+=[(string)(i+1) + ". " + un];
                buttonList+=[(string)(i+1) + ". " + un];
            }
        }
    }
    else if(menuName=="Length"){
        menuText="Current leash length: %1%.%%;"+(string)leashLength;
        integer i;
        for(i=1; i<=6; i++){
            buttonList+=[i];
        }
        for(i=10; i<=20; i+=5){
            buttonList+=[i];
        }
    }
    else if(menuName=="Style"){
        string particleColorName=getParticleColorName(particleColor);
        menuText="Choose a style and color for leash.\nCurrent size: %1%\nCurrent weight: %2%\nCurrent glow: %3%\nCurrent shine: %b4%\nCurrent color: %5%%%;"+
            (string)particleScale+";"+
            (string)particleGravity+";"+
            (string)particleGlow+";"+
            (string)particleFullBright+";"+
            particleColorName;

        buttonList=[
            "Bigger", "Smaller", "Glow",
            "Heavier", "Lighter", "["+(string)(particleFullBright==TRUE)+"]Shine"
            // "["+(string)(particleMode=="Chain")+"]Chain", "["+(string)(particleMode=="Ribbon")+"]Ribbon", "["+(string)(particleMode=="None")+"]None"
        ];
        integer i;
        for(i=0; i<llGetListLength(particleTextureList); i+=2){
            string curTexture=llList2String(particleTextureList, i);
            buttonList+="["+(string)(particleMode==curTexture)+"]T."+curTexture;
        }
        for(i=0; i<llGetListLength(particleColorList); i+=2){
            string curColor=llList2String(particleColorList, i);
            buttonList+="["+(string)(particleColorName==curColor)+"]"+curColor;
        }
    }
    else if(menuName=="Config"){
        menuText="Configs of leash.";
        buttonList=[
            "["+(string)leashTurnMode+"]Turn", "["+(string)leashStrictMode+"]Strict"
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
// integer readLeashNotecards(string aname){
//     readLeashLine=0;
//     curLeashName=aname;
//     readLeashName=leashHeader+aname;
//     if (llGetInventoryType(readLeashName) == INVENTORY_NOTECARD) {
//         llOwnerSay("Begin reading leash settings: "+aname);
//         readLeashQuery=llGetNotecardLine(readLeashName, readLeashLine); // 通过给readLeashQuery赋llGetNotecardLine的key，从而触发datasever事件
//         // 后续功能交给下方datasever处理
//         return TRUE;
//     }else{
//         return FALSE;
//     }
// }

// list getLeashNotecards(){
//     list leashList=[];
//     integer count = llGetInventoryNumber(INVENTORY_NOTECARD);
//     integer i;
//     for (i=0; i<count; i++){
//         string notecardName = llGetInventoryName(INVENTORY_NOTECARD, i);
//         if(llGetSubString(notecardName, 0, llStringLength(leashHeader)-1)==leashHeader){
//             leashList+=[llGetSubString(notecardName, llStringLength(leashHeader), -1)];
//         }
//     }
//     return leashList;
// }

integer MENU_MSG_NUM=1000;
integer RLV_MSG_NUM=1001;
integer ACCESS_MSG_NUM=1002;
// integer LAN_MSG_NUM=1003;
integer LEASH_MSG_NUM=1005;
integer CHANNEL_LOCK_MEISTER = -8888;
integer CHANNEL_LOCK_GUARD   = -9119;

// integer leashPulling=FALSE;
// float leashZoneEdge=0.5;
integer REZ_MODE=FALSE;
integer timerCount=0;
integer maxSensor=18;
default{
    state_entry(){
        initConfig();
        llMessageLinked(LINK_SET, ACCESS_MSG_NUM, "ACCESS.GET.NOTIFY", NULL_KEY);
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
                if(msg==(string)leashTarget+"handle ok"){ // Ready时，粒子向holder发射
                    startParticles(id);
                }else if(msg==(string)leashTarget+"handle detached"){ // 脱下时，粒子向角色发射
                    startParticles(leashTarget);
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
        if(targetPos == ZERO_VECTOR || llVecDist(avatarPos, targetPos) > leashMaxRange){
            targetInRange=FALSE;
        }
        if(targetInRange){
            float distance = llVecDist(targetPos, avatarPos);
            if(distance>=leashLength){
                vector dir = llVecNorm(avatarPos - targetPos);
                vector desiredPos = targetPos + dir * (leashLength-0.2) + leashPosOffset;
                llMoveToTarget(desiredPos, 0.8); // 平滑地跟随
                if(leashTurnMode==TRUE && allowAutoTurn==TRUE && timerCount%10==0){
                    vector faceDir = llVecNorm(targetPos - avatarPos);
                    rotation rot = llRotBetween(<1,0,0>, faceDir);
                    llSetAgentRot(rot, 0);
                }
                /*
                TODO：抖动问题存疑，防抖机制暂留。
                */
                // if (!leashPulling && distance > (leashLength + leashZoneEdge)){
                //     leashPulling=TRUE;
                // }
                // if (leashPulling && distance < (leashLength - leashZoneEdge)){
                //     leashPulling=FALSE;
                // }
                // if(leashPulling){
                //     vector dir = llVecNorm(avatarPos - targetPos);
                //     vector desiredPos = targetPos + dir * leashLength + (vector)getConfig("leashPosOffset");
                //     llMoveToTarget(desiredPos, 0.8); // 平滑地跟随
                //     if((integer)getConfig("leashTurnMode")==TRUE && allowAutoTurn==TRUE){
                //         vector faceDir = llVecNorm(targetPos - avatarPos);
                //         rotation rot = llRotBetween(<1,0,0>, faceDir);
                //         llSetAgentRot(rot, 0);
                //     }
                // }
            }else{
                llStopMoveToTarget();
            }
        }
        timerCount++;
    }
    run_time_permissions(integer perm) {
        if(perm & PERMISSION_TRIGGER_ANIMATION){
            allowAutoTurn=TRUE;
        }
    }
    link_message(integer sender_num, integer num, string msg, key user){
        if(num!=LEASH_MSG_NUM && num!=MENU_MSG_NUM && num!=ACCESS_MSG_NUM && num!=RLV_MSG_NUM){
            return;
        }
        if(!includes(msg, "LEASH") && !includes(msg, "MENU.ACTIVE") && !includes(msg, "ACCESS.NOTIFY") && !includes(msg, "RLV.EXEC")){
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

            if(headerMain=="LEASH" && headerSub!="EXEC"){
                string result="";

                if(headerSub=="SET"){
                    /*
                    更改配置：LEASH.SET | ConfigName | ConfigValue
                    */
                    result=setConfig(msgName, msgSub);
                    leashToTarget(leashTarget, leashParticleEnabled);
                }
                if(headerSub=="GET"){
                    /*
                    更改配置：LEASH.GET | ConfigName
                    */
                    result=getConfig(msgName);
                }
                else if(headerSub=="TO"){
                    /*
                    牵引目标：LEASH.TO | targetId | particleEnabled
                    目标ID为空时，则为取消牵引
                    粒子效果为空时，则按默认配置
                    */
                    if(msgName==""){
                        msgName=(string)NULL_KEY;
                    }
                    if(msgSub==""){
                        msgSub=(string)particleEnabled;
                    }
                    result=(string)leashToTarget((key)msgName, (integer)msgSub);
                }
                else if(headerSub=="YANK"){
                    /*
                    将目标拉到身边：LEASH.YANK | targetId
                    目标ID为空时，则为当前牵引的目标
                    */
                    if(msgName==""){
                        msgName=(string)leashTarget;
                    }
                    result=(string)leashToTarget((key)msgName, -1);
                    // result=(string)yankToTarget((key)msgName);
                }
                else if(headerSub=="PARTICLE"){
                    /*
                    仅显示牵引链条：LEASH.PARTICLE | targetId
                    目标ID为空时，则为取消链条
                    */
                    if(msgName==""){
                        msgName=(string)NULL_KEY;
                    }
                    result=(string)startParticles((key)msgName);
                }
                else if(headerSub=="LOAD"){
                    /*
                    读取Leash记事卡
                    LEASH.LOAD | file1
                    回调：
                    LEASH.EXEC | LEASH.LOAD | 1
                    读取记事卡成功后的回调
                    LEASH.LOAD.NOTECARD | file1 | 1
                    */
                    if(headerExt==""){
                        readLeashLine=0;
                        curLeashName=msgName;
                        readLeashName=leashHeader+msgName;
                        if (llGetInventoryType(readLeashName) == INVENTORY_NOTECARD) {
                            llOwnerSay("Begin reading leash settings: "+msgName);
                            readLeashQuery=llGetNotecardLine(readLeashName, readLeashLine); // 通过给readLeashQuery赋llGetNotecardLine的key，从而触发datasever事件
                            // 后续功能交给下方datasever处理
                            result=(string)TRUE;
                        }else{
                            llMessageLinked(LINK_SET, LEASH_MSG_NUM, "LEASH.LOAD.NOTECARD|"+msgName+"|0", NULL_KEY);
                            result=(string)FALSE;
                        }
                    }
                    /*
                    读取Leash记事卡列表
                    LEASH.LOAD.LIST
                    回调：
                    LEASH.EXEC | LEASH.LOAD.LIST | leash_1, leash_2, leash_3, ...
                    */
                    if(headerExt=="LIST"){
                        list leashList=[];
                        integer count = llGetInventoryNumber(INVENTORY_NOTECARD);
                        integer i;
                        for (i=0; i<count; i++){
                            string notecardName = llGetInventoryName(INVENTORY_NOTECARD, i);
                            if(llGetSubString(notecardName, 0, llStringLength(leashHeader)-1)==leashHeader){
                                leashList+=[llGetSubString(notecardName, llStringLength(leashHeader), -1)];
                            }
                        }
                        result=list2Data(leashList);
                    }
                }
                else if(headerSub=="MENU"){
                    /*
                    显示菜单
                    LEASH.MENU | 上级菜单名
                    */
                    showLeashMenu(msgName, user);
                }
                if(result!=""){
                    resultList+=[headerMain+".EXEC|"+msgHeader+"|"+result];
                }
            }

            else if(headerMain=="MENU" && headerSub=="ACTIVE"){
                // MENU.ACTIVE | mainMenu | Access
                integer menuActiveFlag=-999;

                if(msgSub==leashMenuText){
                    showLeashMenu(msgName, user);
                }
                else if(msgName==leashMenuName && msgSub!=""){
                    if(msgSub=="Grab"){
                        leashToTarget(user, TRUE);
                        menuActiveFlag=1;
                    }
                    else if(msgSub=="Unleash" || msgSub=="Unfollow"){
                        if(leashStrictMode==TRUE && user==llGetOwner()){
                            llMessageLinked(LINK_SET, MENU_MSG_NUM, "MENU.OUT|You can't %1% yourself in Strict mode!%%;"+msgSub, user);
                        }else{
                            leashToTarget(NULL_KEY, FALSE);
                        }
                        menuActiveFlag=2;
                    }
                    else if(msgSub=="Yank"){
                        // yankToTarget(user);
                        leashToTarget(user, -1);
                        menuActiveFlag=3;
                    }
                    else if(msgSub=="Follow" || msgSub=="Pass" || msgSub=="Anchor"){
                        leashSubMenuFlag=msgSub;
                        leashSubMenuParent=leashMenuName;
                        leashSubMenuUser=user;
                        if(msgSub=="Follow" | msgSub=="Pass"){
                            llSensor("", NULL_KEY, AGENT, 96.0, PI);
                        }else if(msgSub=="Anchor"){
                            llSensor("", NULL_KEY, PASSIVE|ACTIVE, 96.0, PI);
                        }
                        //后续功能交给sensor事件
                    }
                    else if(msgSub=="Length" || msgSub=="Style" || msgSub=="Config"){
                        showLeashSubMenu(msgSub, leashMenuName, user, TRUE);
                    }
                    if(menuActiveFlag!=-999){
                        showLeashMenu(leashParentMenuName, user);
                    }
                }
                else if(msgName==leashSubMenuName && msgSub!=""){
                    if(leashSubMenuFlag=="Follow" || leashSubMenuFlag=="Pass" || leashSubMenuFlag=="Anchor"){
                        list buList=llParseStringKeepNulls(msgSub,[". "],[""]);
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
                        leashLength=(float)msgSub;
                        menuActiveFlag=2;
                    }
                    else if(leashSubMenuFlag=="Style"){
                        if(msgSub=="Bigger" || msgSub=="Smaller"){
                            if(msgSub=="Bigger"){
                                particleScale.x+=0.03;
                                particleScale.y+=0.03;
                            }else if(msgSub=="Smaller"){
                                particleScale.x-=0.03;
                                particleScale.y-=0.03;
                            }
                            if(particleScale.x<0.04 && particleScale.y<0.04){
                                particleScale.x=0.04;
                                particleScale.y=0.04;
                            }
                        }
                        else if(msgSub=="Heavier" || msgSub=="Lighter"){
                            if(msgSub=="Heavier"){
                                particleGravity.z-=0.1;
                            }else if(msgSub=="Lighter"){
                                particleGravity.z+=0.1;
                            }
                            if(particleGravity.z<-3.0){
                                particleGravity.z=-3.0;
                            }
                            if(particleGravity.z>3.0){
                                particleGravity.z=3.0;
                            }
                        }
                        else if(msgSub=="Glow"){
                            particleGlow+=0.1;
                            if(particleGlow>1.1){
                                particleGlow=0;
                            }
                        }
                        else if(msgSub=="Shine"){
                            if(particleFullBright==TRUE){
                                particleFullBright=FALSE;
                            }else{
                                particleFullBright=TRUE;
                            }
                        }
                        // else if(msgSub=="Chain" || msgSub=="Ribbon" || msgSub=="None"){
                        else if(includes(msgSub, "T.")){
                            particleMode=llGetSubString(msgSub, 2, -1);
                        }
                        else{
                            particleColor=getParticleColorVector(msgSub);
                        }
                        if(leashParticleEnabled==TRUE){
                            startParticles(leashTarget); // 更改配置后需要重新生成粒子效果，仅限有粒子的牵绳效果
                        }
                        menuActiveFlag=3;
                    }
                    else if(leashSubMenuFlag=="Config"){
                        if(msgSub=="Turn"){
                            if(leashTurnMode==TRUE){
                                leashTurnMode=FALSE;
                            }else{
                                leashTurnMode=TRUE;
                            }
                        }
                        else if(msgSub=="Strict"){
                            if(leashStrictMode==TRUE){
                                leashStrictMode=FALSE;
                            }else{
                                leashStrictMode=TRUE;
                            }
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
            else if (headerMain=="RLV" && headerSub=="EXEC" && (msgName=="RLV.CLEAR" || msgName=="RLV.APPLY")){
                // RLV.EXEC | RLV.CLEAR | 1
                applyStrictMode();
            }
            else if (headerMain=="ACCESS" && headerSub=="NOTIFY"){
                // ACCESS.NOTIFY | OWNER | UUID1; UUID2; UUID3; ...
                if(msgName=="OWNER"){
                    owner=data2List(msgSub);
                }
                applyStrictMode();
            }
        }

        if(llGetListLength(resultList)>0){
            llMessageLinked(LINK_SET, LEASH_MSG_NUM, llDumpList2String(resultList, "&&"), user); // 处理完成后的回调
            resultList=[];
        }
        // llSleep(0.01);
        // llOwnerSay("Leash Memory Used: "+(string)llGetUsedMemory()+"/"+(string)(65536-llGetUsedMemory())+" Free: "+(string)llGetFreeMemory());
    }
    dataserver(key query_id, string data){
        if (query_id == readLeashQuery) { // 通过readLeashNotecards触发读取记事卡事件，按行读取配置并应用。
            if (data == EOF) {
                llOwnerSay("Finished reading leash config: "+curLeashName);
                llMessageLinked(LINK_SET, ACCESS_MSG_NUM, "LEASH.LOAD.NOTECARD|"+curLeashName+"|1", NULL_KEY); // 成功读取记事卡后回调
                readLeashQuery=NULL_KEY;
                curLeashName="";
                readLeashName="";
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
        for (i = 0; i<detected && i<maxSensor; i++) {
            key uuid = llDetectedKey(i);
            sensorUserList+=uuid;
        }
        showLeashSubMenu(leashSubMenuFlag, leashSubMenuParent, leashSubMenuUser, TRUE);
    }
}
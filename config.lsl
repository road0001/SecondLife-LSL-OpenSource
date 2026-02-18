/*
Name: Config
Author: JMRY
Description: A better config apply system, use link_message to operate configs.

***更新记录***
- 1.0.1 20260211
    - 加入在写入RLV配置前清空RLV组的功能。
    - 优化写入配置的时间间隔。

- 1.0 20260120
    - 初步完成配置功能。
***更新记录***
*/

list CONFIG=[
"RLV_CONFIG","
[Vision]
Camera=camdistmax:4,setsphere,setsphere_distmin:2.5?force,setsphere_distmax:5?force,setsphere_valuemin:0?force,setcam_unlock
Cover=setoverlay,setoverlay_alpha:0.75?force,setoverlay_texture:40000540-3e66-e477-7e17-c63e89625d29?force
Name=shownames_sec,shownametags
Near=shownearby
Text=showhovertextall
Map=showworldmap,showminimap,showloc
Echo=rext_echoview

[Touch]
Far=fartouch?n?y
World=touchworld
Me=touchme?add?rem

[Inventory]
Inv=showinv
Edit=edit

[Move]
Run=alwaysrun?n?y,temprun
Fly=fly
Move=rext_move
Turn=rext_turn
*MoveTurn=rext_move,rext_turn

[Chat]
Chat=sendchat,recvchat
IM=startim,sendim_sec,recvim_sec
",



"ACCESS_CONFIG","
public=1
group=0
hardcore=0
lock=0
",



"LEASH_CONFIG","
# 启用/禁用牵绳粒子效果
particleEnabled=1
# 粒子行为参数（可使用单个整数或多个整数合成最终掩码，-1保持默认）
particleFlags=16;64;8
# 粒子发射模式（0保持默认）
particleSrcPattern=2
# 粒子效果模式（可选：Ribbon, Chain, Leather, Rope, None）
particleMode=Bubble
# 粒子最大生命周期
particleMaxAge=5
# 粒子颜色
particleColor=<1.0, 1.0, 1.0>
# 粒子透明度
particleAlpha=0.1
# 粒子大小
particleScale=<0.2, 0.2, 1.0>
# 粒子发射频率
particleBurstRate=0.1
# 粒子重量
particleGravity=<0.0,0.0,0.0>
# 粒子数量
particleCount=2
# 粒子全亮模式
particleFullBright=1
# 粒子发光效果
particleGlow=0.2
# 各模式下粒子贴图
particleTextureList=Bubble;de68452c-48d3-7432-0354-e8113321eaa1;Ribbon;cdb7025a-9283-17d9-8d20-cee010f36e90;None;8dcd4a48-2d37-4909-9f78-f7a9eb4ef903
# 粒子颜色列表（用于菜单中的Style选项）
particleColorList=White;<1.0, 1.0, 1.0>;Black;<0.0, 0.0, 0.0>;Gray;<0.5, 0.5, 0.5>;Red;<1.0, 0.0, 0.0>;Green;<0.0, 1.0, 0.0>;Blue;<0.0, 0.0, 1.0>;Yellow;<1.0, 1.0, 0.0>;Pink;<1.0, 0.5, 0.6>;Brown;<0.2, 0.1, 0.0>;Purple;<0.6, 0.2, 0.7>;Barbie;<0.9, 0.0, 0.3>;Orange;<0.9, 0.6, 0.0>;Toad;<0.2, 0.2, 0.0>;Khaki;<0.6, 0.5, 0.3>;Pool;<0.1, 0.8, 0.9>;Blood;<0.5, 0.0, 0.0>;Anthracite;<0.1, 0.1, 0.1>;Midnight;<0.0, 0.1, 0.2>
# 牵绳link名称
leashPointName=leashpoint
# 牵绳长度
leashLength=3
# 被牵引时是否自动转向
leashTurnMode=1
# 严格模式（RLV限制、自动跟随传送等）
leashStrictMode=0
# 位移刷新频率
leashAwait=0.2
# 最大检测距离
leashMaxRange=60
# 位置偏移
leashPosOffset=<0.0, 0.0, 0.0>
",



"ANIM_CONFIG","
[Float]
Bubble1=*SLC*BubST01(P4)
Bubble2=*SLC*BubST02(P4);5;10
Bubble3=*SLC*BubST03(P4);;-5
Bubble4=*SLC*BubST04(P4);2;0
Bubble5=*SLC*BubST05(P4);10;-10
[Float]
BubbleTurn1=*SLC*BubTURN-L-(P4)
BubbleTurn2=*SLC*BubTURN-R-(P4)
[Float]
BubbleWalk=*SLC*BubWALK(P4)
[Float]
LoonFloat1=LoonGirlFloat1;5;20
*LoonFloat2=LoonGirlFloat2;10;-20
"
];

integer MAIN_MSG_NUM=9000;
integer CONF_MSG_NUM=8000;
integer MENU_MSG_NUM=1000;
integer RLV_MSG_NUM=1001;
integer RENAMER_MSG_NUM=10011;
integer RLVEXT_MSG_NUM=10012;
integer ACCESS_MSG_NUM=1002;
integer LAN_MSG_NUM=1003;
integer TIMER_MSG_NUM=1004;
integer LEASH_MSG_NUM=1005;
integer ANIM_MSG_NUM=1006;
float awaitTime=0.1;

default{
    state_entry(){
    }
    
    link_message(integer sender_num, integer num, string msg, key user){
        if(num!=CONF_MSG_NUM && num!=ACCESS_MSG_NUM){
            return;
        }
        if(msg=="CONFIG.LOAD"){
            integer i;
            integer c;
            integer a;
            for(i=0; i<llGetListLength(CONFIG); i+=2){
                string configName=llList2String(CONFIG, i);
                list   configData=llParseString2List(llList2String(CONFIG, i+1), ["\n"], [""]);
                // list configList=llParseString2List(llList2String(CONFIG, i+1),["\n"],[""]);

                if(configName=="RLV_CONFIG"){
                    llMessageLinked(LINK_SET, RLV_MSG_NUM, "RLV.CLEAR", NULL_KEY);
                    string curRLVClass="";
                    for(c=0; c<llGetListLength(configData); c++){
                        string data=llList2String(configData, c);
                        if(data!="" && llGetSubString(data,0,0)!="#"){
                            if(llGetSubString(data,0,0)=="[" && llGetSubString(data,-1,-1)=="]"){
                                curRLVClass=llGetSubString(data,1,-2);
                            }else{
                                list rlvStrSp=llParseStringKeepNulls(data, ["="], []);
                                string rlvName=llList2String(rlvStrSp,0);
                                integer rlvDefaultEnabled=FALSE;
                                if(llGetSubString(rlvName, 0, 0)=="*"){
                                    rlvDefaultEnabled=TRUE;
                                    rlvName=llGetSubString(rlvName, 1, -1);
                                }
                                string rlvData=llList2String(rlvStrSp,1);
                                llMessageLinked(LINK_SET, RLV_MSG_NUM, "RLV.REG|"+rlvName+"|"+rlvData+"|"+curRLVClass+"|"+(string)rlvDefaultEnabled, NULL_KEY);
                            }
                        }
                        // llSleep(awaitTime);
                    }
                    llSleep(awaitTime);
                    llMessageLinked(LINK_SET, RLV_MSG_NUM, "RLV.APPLY.ALL", NULL_KEY);
                    llMessageLinked(LINK_SET, RLV_MSG_NUM, "RLV.LOAD.NOTECARD|CONFIG|1", NULL_KEY); // RLV成功读取记事卡后回调
                }
                else if(configName=="ACCESS_CONFIG"){
                    for(c=0; c<llGetListLength(configData); c++){
                        string data=llList2String(configData, c);
                        if(data!="" && llGetSubString(data,0,0)!="#"){
                            list accStrSp=llParseStringKeepNulls(data, ["="], []);
                            string accName=llList2String(accStrSp,0);
                            list accData=llParseStringKeepNulls(llList2String(accStrSp,1), [";"], [""]);

                            if(accName=="root"){
                                llMessageLinked(LINK_SET, ACCESS_MSG_NUM, "ACCESS.SET.ROOT.KEEP|"+llList2String(accData, 0), NULL_KEY);
                            }
                            else if(accName=="owner"){
                                for(a=0; a<llGetListLength(accData); a++){
                                    llMessageLinked(LINK_SET, ACCESS_MSG_NUM, "ACCESS.ADD.OWNER|"+llList2String(accData, a), NULL_KEY);
                                }
                            }
                            else if(accName=="trust"){
                                for(a=0; a<llGetListLength(accData); a++){
                                    llMessageLinked(LINK_SET, ACCESS_MSG_NUM, "ACCESS.ADD.TRUST|"+llList2String(accData, a), NULL_KEY);
                                }
                            }
                            else if(accName=="black"){
                                for(a=0; a<llGetListLength(accData); a++){
                                    llMessageLinked(LINK_SET, ACCESS_MSG_NUM, "ACCESS.ADD.BLACK|"+llList2String(accData, a), NULL_KEY);
                                }
                            }
                            else if(accName=="public"){
                                llMessageLinked(LINK_SET, ACCESS_MSG_NUM, "ACCESS.SET.MODE|PUBLIC|"+llList2String(accData, 0), NULL_KEY);
                            }
                            else if(accName=="group"){
                                llMessageLinked(LINK_SET, ACCESS_MSG_NUM, "ACCESS.SET.MODE|GROUP|"+llList2String(accData, 0), NULL_KEY);
                            }
                            else if(accName=="hardcore"){
                                llMessageLinked(LINK_SET, ACCESS_MSG_NUM, "ACCESS.SET.MODE|HARDCORE|"+llList2String(accData, 0), NULL_KEY);
                            }
                            else if(accName=="lock"){
                                llMessageLinked(LINK_SET, ACCESS_MSG_NUM, "ACCESS.SET.MODE|AUTOLOCK|"+llList2String(accData, 0), NULL_KEY);
                            }
                        }
                        // llSleep(awaitTime);
                    }
                    llSleep(awaitTime);
                    llMessageLinked(LINK_SET, ACCESS_MSG_NUM, "ACCESS.GET.NOTIFY", NULL_KEY); // 成功读取记事卡后回调
                    llMessageLinked(LINK_SET, ACCESS_MSG_NUM, "ACCESS.LOAD.NOTECARD|CONFIG|1", NULL_KEY); // 成功读取记事卡后回调
                }
                else if(configName=="LEASH_CONFIG"){
                    for(c=0; c<llGetListLength(configData); c++){
                        string data=llList2String(configData, c);
                        if(data!="" && llGetSubString(data,0,0)!="#"){
                            list leashStrSp=llParseStringKeepNulls(data, ["="], []);
                            llMessageLinked(LINK_SET, LEASH_MSG_NUM, "LEASH.SET|"+llList2String(leashStrSp,0)+"|"+llList2String(leashStrSp,1), NULL_KEY);
                        }
                        // llSleep(awaitTime);
                    }
                    llSleep(awaitTime);
                    llMessageLinked(LINK_SET, LEASH_MSG_NUM, "LEASH.LOAD.NOTECARD|CONFIG|1", NULL_KEY); // 成功读取记事卡后回调
                }
                else if(configName=="ANIM_CONFIG"){
                    string curAnimClass="";
                    string curPlayingAnimName="";
                    for(c=0; c<llGetListLength(configData); c++){
                        string data=llList2String(configData, c);
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
                                llMessageLinked(LINK_SET, ANIM_MSG_NUM, "ANIM.SET|"+animName+"|"+animParams+"|"+curAnimClass+"|"+(string)animAutoPlay, NULL_KEY);
                            }
                        }
                        // llSleep(awaitTime);
                    }
                    llSleep(awaitTime);
                    if(curPlayingAnimName!=""){
                        llMessageLinked(LINK_SET, ANIM_MSG_NUM, "ANIM.PLAY|"+curPlayingAnimName, NULL_KEY);
                    }
                    llMessageLinked(LINK_SET, ANIM_MSG_NUM, "ANIM.LOAD.NOTECARD|CONFIG|1", NULL_KEY); // 成功读取记事卡后回调
                }
                llOwnerSay("Config "+configName+" load completed.");
            }
        }
        // llSleep(awaitTime);
        // llOwnerSay("Config Memory Used: "+(string)llGetUsedMemory()+"/"+(string)(65536-llGetUsedMemory())+" Free: "+(string)llGetFreeMemory());
    }
}
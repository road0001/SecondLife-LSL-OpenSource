initMain(){
	standalone=TRUE;
	notecardHeader="music_";
	musicReadFlag=1;
	playMusic("stop");
	musicNotecardList=getNotecardList();
	musicRealNameList=[];
	if(llGetListLength(musicNotecardList) > 0){
		readNotecard(llList2String(musicNotecardList, 0));
	}
}
/*CONFIG END*/

/*
Name: Music player
Author: JMRY
Description: A music player.

***更新记录***
- 1.0 20260807
    - 完成主要功能。
***更新记录***
*/

integer randomInt(integer min, integer max) {
    if (min > max) return min; // 或交换
    return min + (integer)llFrand(max - min + 1);
}

string appName="Music";

list musicNotecardList=[];
list musicRealNameList=[];
integer musicCurrentIndex=0;
integer musicReadFlag=0; // 0: Normal; 1: Read all music notecards; 2: Play current music

string musicRealName="";
string musicAuthor="";
string musicAlbum="";
float musicLength=0.0;
list musicSoundList=[];
list soundLengthList=[];
integer musicSoundIndex=0;
float soundLengthDefault=29.9;
playMusicByName(string name){
	playMusic("stop");
	integer index=llListFindList(musicRealNameList, [name]); // 先找歌曲名列表
	if(!~index){ // 未找到时，再找文件名列表
		index=llListFindList(musicNotecardList, [name]);
	}
	if(~index){
		musicReadFlag=2;
		musicCurrentIndex=index;
		musicSoundIndex=0;
		readNotecard(llList2String(musicNotecardList, musicCurrentIndex));
	}
}

float musicVolume=1.0;
integer musicPlaying=FALSE;
integer musicPlayLoop=TRUE;
integer musicPlayType=1; // -1：单曲循环  0：播放一次  1：顺序播放  2：倒序播放  3：随机播放
list musicAlreadyPlayedList=[];
playMusic(string type){
	llSetTimerEvent(0);
	if(type==""){ // 正常播放
		if(llGetListLength(musicSoundList)<=0){
			return;
		}

		llMessageLinked(LINK_SET, MUSIC_MSG_NUM, "MUSIC.EXEC|MUSIC.PLAYING|"+musicRealName+"|"+musicAuthor+"|"+musicAlbum+"|"+(string)musicLength+"|"+(string)musicSoundIndex, NULL_KEY);
		musicPlaying=TRUE;
		if(showMenuUser!=NULL_KEY){
			showMenu(menuParent,showMenuUser);
			showMenuUser=NULL_KEY;
		}

		string soundMaster=llList2String(musicSoundList, musicSoundIndex);
		string soundSlave =llList2String(musicSoundList, musicSoundIndex+1);
		float soundMasterLength=llList2Float(soundLengthList, musicSoundIndex);
		float soundSlaveLength =llList2Float(soundLengthList, musicSoundIndex+1);

		if(soundMaster==""){
			// 索引为空时，则播放下一首歌，根据类型判断
			if(musicPlayType==-1){
				playMusic("current");
			}
			else if(musicPlayType==0){
				playMusic("stop");
			}
			else if(musicPlayType==1){
				playMusic("next");
			}
			else if(musicPlayType==2){
				playMusic("prev");
			}
			else if(musicPlayType==3){
				playMusic("random");
			}
			return;
		}

		llPlaySound(soundMaster, musicVolume);
		// 如果有，就预载下一段声音
		if(soundSlave!="" && soundSlaveLength>0){
			llSetSoundQueueing(TRUE);
			llPreloadSound(soundSlave);
			llPlaySound(soundSlave, musicVolume);
			soundSlaveLength-=1; // llPreloadSound有1秒延迟，因此减掉
			llSetTimerEvent(soundMasterLength + soundSlaveLength);
		}else{
			llSetSoundQueueing(FALSE);
			llSetTimerEvent(soundMasterLength);
		}
		musicSoundIndex+=2;
		// 后续片段播放交给timer
		
	}
	else if(type=="current"){
		playMusicByName(llList2String(musicRealNameList, musicCurrentIndex));
	}
	else if(type=="prev"){ // 上一曲
		if(musicCurrentIndex==0){
			if(musicPlayLoop==FALSE){
				playMusic("stop");
				return;
			}
			musicCurrentIndex=llGetListLength(musicRealNameList)-1;
		}else{
			musicCurrentIndex--;
		}
		playMusicByName(llList2String(musicRealNameList, musicCurrentIndex));
	}
	else if(type=="next"){ // 下一曲
		if(musicCurrentIndex>=llGetListLength(musicRealNameList)-1){
			if(musicPlayLoop==FALSE){
				playMusic("stop");
				return;
			}
			musicCurrentIndex=0;
		}else{
			musicCurrentIndex++;
		}
		playMusicByName(llList2String(musicRealNameList, musicCurrentIndex));
	}
	else if(type=="random"){ // 随机播放
		if(musicPlayLoop==FALSE && llGetListLength(musicAlreadyPlayedList) >= llGetListLength(musicRealNameList)){
			playMusic("stop");
			return;
		}
		if(llGetListLength(musicAlreadyPlayedList) >= llGetListLength(musicRealNameList)){ // 随机队列满了的时候，清空
			musicAlreadyPlayedList=[];
		}
		@repeat;
		musicCurrentIndex=randomInt(0, llGetListLength(musicRealNameList)-1);
		if(~llListFindList(musicAlreadyPlayedList, [musicCurrentIndex])){ // 随机索引存在时，重随
			jump repeat;
		}else{
			musicAlreadyPlayedList+=[musicCurrentIndex]; // 加入列表，防止重复
		}
		playMusicByName(llList2String(musicRealNameList, musicCurrentIndex));
	}
	else if(type=="stop"){
		llStopSound();
		llSetSoundQueueing(FALSE);
		musicPlaying=FALSE;
		llMessageLinked(LINK_SET, MUSIC_MSG_NUM, "MUSIC.EXEC|MUSIC.STOP|1", NULL_KEY);
		llMessageLinked(LINK_SET, TIMER_MSG_NUM, "TIMER.CLEAR", NULL_KEY);
	}
}

string menuName="MusicMenu";
string menuParent="";
showMenu(string parent, key user){
	menuParent=parent;
	string playType="";
	string typeBu="";
	if(musicPlayType==-1){
		playType="🔂 Single loop";
		typeBu="1️⃣ Play once";
	}
	else if(musicPlayType==0){
		playType="1️⃣ Play once";
		typeBu="↪ Sequence";
	}
	else if(musicPlayType==1){
		playType="↪ Play in sequence";
		typeBu="↩ Backwards";
	}
	else if(musicPlayType==2){
		playType="↩ Play in backwards";
		typeBu="🔀 Randomize";
	}
	else if(musicPlayType==3){
		playType="🔀 Play in randomize";
		typeBu="🔂 Single loop";
	}
	string playStatus="";
	string playBu="";
	if(musicPlaying==TRUE){
		playStatus="▶ Playing";
		playBu="⏹ Stop";
	}else{
		playStatus="⏹ Stopped";
		playBu="▶ Play";
	}
	string loopStatus="";
	if(musicPlayLoop==TRUE){
		loopStatus="🔁 Loop playback";
	}else{
		loopStatus="➡ Playlist once";
	}
	string menuText="Current playing: %1%. %2%\nArtist: %3%\nAlbum: %4%\nDuration: %5%\nPlay mode: %6%\nLoop playback: %7%\nVolume: %8%\n%9%%%;"+(string)(musicCurrentIndex+1)+";"+musicRealName+";"+musicAuthor+";"+musicAlbum+";"+(string)musicLength+";"+playType+";"+loopStatus+";"+(string)musicVolume+";"+playStatus;
	list menuList=[
		"⏮ Prev", playBu, "Next ⏭",
		typeBu, "["+(string)musicPlayLoop+"]🔁 Loop", "🔊 Volume"
	];
	integer i;
	for(i=0; i<llGetListLength(musicRealNameList); i++){
		menuList+=["\\NL"+llList2String(musicRealNameList, i)];
	}
	llMessageLinked(LINK_SET, MENU_MSG_NUM, "MENU.REG.OPEN|"+menuName+"|"+menuText+"|"+llDumpList2String(menuList, ";")+"|"+parent, user);
}

string notecardHeader="music_";
key readNotecardQuery=NULL_KEY;
integer readNotecardLine=0;
string readNotecardName="";
string curNotecardName="";
integer readNotecard(string name){
	readNotecardLine=0;
	curNotecardName=name;
	readNotecardName=notecardHeader+name;
	if (llGetInventoryType(readNotecardName) == INVENTORY_NOTECARD) {
		llMessageLinked(LINK_SET, MUSIC_MSG_NUM, "MUSIC.EXEC|MUSIC.LOAD|"+name, NULL_KEY);
		llMessageLinked(LINK_SET, MENU_MSG_NUM, "MENU.OUT|Begin reading %1%: %2%%%;"+appName+";"+name, NULL_KEY);
		musicRealName="";
		musicAuthor="";
		musicAlbum="";
		musicLength=0.0;
		musicSoundList=[];
		soundLengthList=[];
		musicSoundIndex=0;
		readNotecardQuery=llGetNotecardLine(readNotecardName, readNotecardLine); // 通过给readNotecardQuery赋llGetNotecardLine的key，从而触发datasever事件
		// 后续功能交给下方datasever处理
		return TRUE;
	}else{
		return FALSE;
	}
}

readNotecardEnd(){
	/*
	遍历读取记事卡并获取所有歌曲的歌曲名，组成列表
	*/
	if(musicReadFlag==1){
		musicRealNameList+=[llGetSubString(musicRealName, 0, 23)];
		if(llGetListLength(musicRealNameList) < llGetListLength((musicNotecardList))){
			readNotecard(llList2String(musicNotecardList, llGetListLength(musicRealNameList)));
		}else{
			musicReadFlag=0;
			musicRealName="";
			llMessageLinked(LINK_SET, MUSIC_MSG_NUM, "MUSIC.READY|"+llDumpList2String(musicRealNameList, ";"), NULL_KEY);
			llMessageLinked(LINK_SET, MENU_MSG_NUM, "MENU.OUT|Music list load completed! Total %1% songs.%%;"+(string)llGetListLength(musicRealNameList), NULL_KEY);
		}
		return;
	}
	/*
	读取指定记事卡，并开始播放音乐
	*/
	else if(musicReadFlag==2){
		/*
		如果最后一个文件的时长为默认值，则视为未配置时长，处理最后一个文件的时长
		*/
		integer i;
		if(musicLength==0){
			for(i=0; i<llGetListLength(soundLengthList); i++){
				musicLength+=llList2Float(soundLengthList, i);
			}
		}
		if(llList2Float(soundLengthList, -1) == soundLengthDefault){
			float lastLength=musicLength;
			for(i=0; i<llGetListLength(soundLengthList)-1; i++){
				lastLength-=llList2Float(soundLengthList, i);
			}
			if(lastLength < soundLengthDefault){
				soundLengthList=llListReplaceList(soundLengthList, [lastLength], -1, -1);
			}
		}
		llSetSoundQueueing(FALSE);
		llMessageLinked(LINK_SET, TIMER_MSG_NUM, "TIMER.CLEAR", NULL_KEY);
		for(i=0; i<llGetListLength(musicSoundList); i++){ // 遍历声音列表并播放以预加载
			llTriggerSound(llList2String(musicSoundList, i), 0); // llTriggerSound可叠加，因此可预载每一段声音
			llSleep(0.1);
		}
		llMessageLinked(LINK_SET, TIMER_MSG_NUM, "TIMER.ADD|"+(string)musicLength, NULL_KEY);
		llMessageLinked(LINK_SET, TIMER_MSG_NUM, "TIMER.RUN", NULL_KEY);
		llMessageLinked(LINK_SET, MUSIC_MSG_NUM, "MUSIC.EXEC|MUSIC.PLAY|"+musicRealName+"|"+musicAuthor+"|"+musicAlbum+"|"+(string)musicLength, NULL_KEY);
		playMusic("");
		musicReadFlag=0;
	}
}

list getNotecardList(){
	list notecardList=[];
	integer count = llGetInventoryNumber(INVENTORY_NOTECARD);
	integer i;
	for (i=0; i<count; i++){
		string notecardName = llGetInventoryName(INVENTORY_NOTECARD, i);
		if(notecardHeader=="" || llGetSubString(notecardName, 0, llStringLength(notecardHeader)-1)==notecardHeader){
			notecardList+=[llGetSubString(notecardName, llStringLength(notecardHeader), -1)];
		}
	}
	return notecardList;
}

integer standalone=FALSE;
integer MENU_MSG_NUM=1000;
integer TIMER_MSG_NUM=1004;
integer MAIN_MSG_NUM=9000;
integer MUSIC_MSG_NUM=90006;
key showMenuUser=NULL_KEY;

default{
	state_entry() {
		initMain();
	}
	changed(integer change){
		if(change & CHANGED_OWNER){ // 物品易主时，重置脚本
			llResetScript();
		}
        if(change & CHANGED_INVENTORY){
            initMain();
        }
	}
	timer(){
		playMusic("");
	}
	touch_start(integer num_detected){
		if(standalone==TRUE){
			showMenu("", llDetectedKey(0));
		}
	}
	link_message(integer sender_num, integer num, string msg, key user){
        if(num!=MAIN_MSG_NUM && num!=MENU_MSG_NUM && num!=MUSIC_MSG_NUM){
            return;
        }
        list msgList=llParseStringKeepNulls(msg,["|"],[""]);
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

		if(headerMain=="MUSIC" && headerSub!="EXEC"){
			string result="";
			/*
			MUSIC.INIT
			*/
			if(headerSub=="INIT"){
				initMain();
			}
			/*
			MUSIC.PLAY | musicRealName
			*/
			else if(headerSub=="PLAY"){
				if(msg1==""){
					playMusic("current");
				}else{
					playMusicByName(msg1);
				}
			}
			/*
			MUSIC.STOP
			MUSIC.PREV
			MUSIC.NEXT
			MUSIC.RANDOM
			*/
			else if(headerSub=="STOP"){
				playMusic("stop");
			}
			else if(headerSub=="PREV"){
				playMusic("prev");
			}
			else if(headerSub=="NEXT"){
				playMusic("next");
			}
			else if(headerSub=="RANDOM"){
				playMusic("random");
			}
			else if(headerSub=="SET"){
				/*
				MUSIC.SET.TYPE
				MUSIC.SET.LOOP
				MUSIC.SET.VOLUME
				*/
				if(headerExt=="TYPE"){
					musicPlayType=(integer)msg1;
					result=(string)musicPlayType;
				}
				else if(headerExt=="LOOP"){
					musicPlayLoop=(integer)msg1;
					result=(string)musicPlayLoop;
				}
				else if(headerExt=="VOLUME"){
					musicVolume=(float)msg1;
					result=(string)musicVolume;
				}
			}
			else if(headerSub=="GET"){
				/*
				MUSIC.GET.TYPE
				MUSIC.GET.LOOP
				MUSIC.GET.VOLUME
				*/
				if(headerExt=="TYPE"){
					result=(string)musicPlayType;
				}
				else if(headerExt=="LOOP"){
					result=(string)musicPlayLoop;
				}
				else if(headerExt=="VOLUME"){
					result=(string)musicVolume;
				}
			}
			else if(headerSub=="MENU"){
				/*
				显示菜单
				PUNISH.MENU | Parent
				*/
				showMenu(msg1,user);
			}
			if(result!=""){
                llMessageLinked(LINK_THIS, MUSIC_MSG_NUM, "MUSIC.EXEC|"+msgHeader+"|"+result, user);
            }
		}
		else if(headerMain=="MAIN" && headerSub=="INIT"){
			standalone=FALSE;
            llMessageLinked(LINK_THIS, MAIN_MSG_NUM, "FEATURE.REG|Music", user);
        }
		else if(headerMain=="MENU" && headerSub=="ACTIVE"){
            // MENU.ACTIVE | MenuName | MenuButton
            if(msg1=="appMenu" && msg2=="Music"){
                showMenu(msg1,user);
            }
			else if(msg1==menuName && msg2!=""){
				// 播放
				if(msg2=="▶ Play"){
					playMusic("current");
					showMenuUser=user;
				}
				// 停止
				else if(msg2=="⏹ Stop"){
					playMusic("stop");
					showMenu(menuParent,user);
				}
				// 上一曲
				else if(msg2=="⏮ Prev"){
					playMusic("prev");
					showMenuUser=user;
				}
				// 下一曲
				else if(msg2=="Next ⏭"){
					playMusic("next");
					showMenuUser=user;
				}
				// 播放模式
				else if(msg2=="1️⃣ Play once"){
					musicPlayType=0;
					llMessageLinked(LINK_SET, MUSIC_MSG_NUM, "MUSIC.EXEC|MUSIC.SET.TYPE|"+(string)musicPlayType, NULL_KEY);
					showMenu(menuParent,user);
				}
				else if(msg2=="↪ Sequence"){
					musicPlayType=1;
					llMessageLinked(LINK_SET, MUSIC_MSG_NUM, "MUSIC.EXEC|MUSIC.SET.TYPE|"+(string)musicPlayType, NULL_KEY);
					showMenu(menuParent,user);
				}
				else if(msg2=="↩ Backwards"){
					musicPlayType=2;
					llMessageLinked(LINK_SET, MUSIC_MSG_NUM, "MUSIC.EXEC|MUSIC.SET.TYPE|"+(string)musicPlayType, NULL_KEY);
					showMenu(menuParent,user);
				}
				else if(msg2=="🔀 Randomize"){
					musicPlayType=3;
					llMessageLinked(LINK_SET, MUSIC_MSG_NUM, "MUSIC.EXEC|MUSIC.SET.TYPE|"+(string)musicPlayType, NULL_KEY);
					showMenu(menuParent,user);
				}
				else if(msg2=="🔂 Single loop"){
					musicPlayType=-1;
					llMessageLinked(LINK_SET, MUSIC_MSG_NUM, "MUSIC.EXEC|MUSIC.SET.TYPE|"+(string)musicPlayType, NULL_KEY);
					showMenu(menuParent,user);
				}
				// 循环模式
				else if(msg2=="🔁 Loop"){
					musicPlayLoop=!musicPlayLoop;
					llMessageLinked(LINK_SET, MUSIC_MSG_NUM, "MUSIC.EXEC|MUSIC.SET.LOOP|"+(string)musicPlayLoop, NULL_KEY);
					showMenu(menuParent,user);
				}
				// 音量
				else if(msg2=="🔊 Volume"){
					llMessageLinked(LINK_SET, MENU_MSG_NUM, "MENU.INPUT|MusicInput_"+msg2+"|Input %1% (0~1), blank to return (Current: %2%):%%;"+msg2+";"+(string)musicVolume, user);
				}
				// 歌曲选择
				else{
					playMusicByName(msg2);
					showMenuUser=user;
				}
			}
			else if(~llSubStringIndex(msg1, "MusicInput")){
				string inputType=llGetSubString(msg1, llStringLength("MusicInput_"), -1);
				if(inputType=="🔊 Volume"){
					if(msg2!=""){
						musicVolume=(float)msg2;
						if(musicVolume<0) musicVolume=0;
						if(musicVolume>1) musicVolume=1;
					}
					llAdjustSoundVolume(musicVolume);
					llMessageLinked(LINK_SET, MUSIC_MSG_NUM, "MUSIC.EXEC|MUSIC.SET.VOLUME|"+(string)musicVolume, NULL_KEY);
				}
				showMenu(menuParent,user);
			}
        }
	}
	dataserver(key query_id, string data){
        if (query_id == readNotecardQuery) { // 通过readRLVNotecards触发读取记事卡事件，按行读取指定RLV（readRLVQuery）并设置相关数据。
            while(TRUE){
                string temp=llGetNotecardLineSync(readNotecardName, readNotecardLine);
				// 同步读取
                if(temp!=NAK){
                    data=temp;
                }
                if (data == EOF) {
					llMessageLinked(LINK_SET, MENU_MSG_NUM, "MENU.OUT|Finished reading %1%: %2%%%;"+appName+";"+curNotecardName, NULL_KEY);
					llMessageLinked(LINK_SET, MUSIC_MSG_NUM, "MUSIC.EXEC|MUSIC.LOADED|"+curNotecardName, NULL_KEY);
                    readNotecardQuery=NULL_KEY;
                    jump end;
                } else {
                    /*
                    Music Name
					Author Name
					Album Name
					Music Length
					Music File 1//25
					Music File 2//16
					Music_UUID_1
					Music_UUID_2
                    */
                    if(data!="" && llGetSubString(data,0,0)!="#"){
						// 歌曲名
                        if(readNotecardLine==0){
							musicRealName=data;
							if(musicRealName==""){
								musicRealName=curNotecardName;
							}
							if(musicReadFlag==1){ // musicReadFlag为1时，即预处理，忽略后续流程，直接跳转到后处理
								jump end;
							}
						}
						// 艺术家
						else if(readNotecardLine==1){
							musicAuthor=data;
						}
						// 专辑
						else if(readNotecardLine==2){
							musicAlbum=data;
						}
						// 长度
						else if(readNotecardLine==3){
							musicLength=(float)data;
						}
						// 音频列表
						else{
							// 格式：<音频名>//<音频长度>
							// 音频长度可省略，以默认长度为准
							list curSoundBundle=llParseStringKeepNulls(data, ["|"], [""]);
							float curSoundLength=llList2Float(curSoundBundle, 1);
							if(curSoundLength<=0){
								curSoundLength=soundLengthDefault;
							}
							if(curSoundLength>30.0){
								curSoundLength=30.0;
							}
							musicSoundList+=[llList2String(curSoundBundle, 0)];
							soundLengthList+=curSoundLength;
						}
                    }

                    // increment line count
                    ++readNotecardLine;
                    //request next line of notecard.
                    if(temp==NAK){
						// 同步失效（未缓存）时，重新读取触发事件
                        readNotecardQuery=llGetNotecardLine(readNotecardName, readNotecardLine);
                        jump invalid;
                    }
                }
            }
            @end;
			readNotecardEnd();
			@invalid;
        }
		// llSleep(0.01);
        // llOwnerSay(appName+" Memory Used: "+(string)llGetUsedMemory()+"/"+(string)(65536-llGetUsedMemory())+" Free: "+(string)llGetFreeMemory());
    }
}
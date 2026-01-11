/*
Name: Leash Holder
Author: JMRY
Description: Leash holder script for leash

***更新记录***
- 1.0 20260111
    - 初步完成leash holder功能。
***更新记录***
*/

/*
TODO:
*/

/*
基础功能依赖函数
*/
float refreshTime=5.0;
string LEASH_HOLDER_READY="LEASH_HOLDER_READY";
string LEASH_HOLDER_EMBAR="LEASH_HOLDER_EMBAR";
integer CHANNEL_LOCK_MEISTER = -8888;
integer CHANNEL_LOCK_GUARD   = -9119;
default{
	state_entry(){
	}
	attach(key user){
		if(user!=NULL_KEY){
			llSay(CHANNEL_LOCK_MEISTER, LEASH_HOLDER_READY);
			llSetTimerEvent(refreshTime);
		}else{
			llSay(CHANNEL_LOCK_MEISTER, LEASH_HOLDER_EMBAR);
			llSetTimerEvent(0);
		}
	}
	timer(){
		llSay(CHANNEL_LOCK_MEISTER, LEASH_HOLDER_READY);
	}
}
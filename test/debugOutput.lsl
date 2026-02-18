list listenChannels=[
	
];
list linkNums=[

];

default{
	state_entry(){
		integer i;
		for(i=0; i<llGetListLength(listenChannels); i++){
			llListen(llList2Integer(listenChannels), "", NULL_KEY, "");
		}
	}
	link_message(integer sender_num, integer num, string str, key id){
		if(~llListFindList(linkNums, [num]) || llGetListLength(linkNums)==0){
			llOwnerSay("LINKMSG SENDER: "+(string)sender_num+" NUM: "+(string)num+" ID: "+(string)id+"\n"+str);
		}
	}
	listen(integer channel, string name, key id, string message){
		llOwnerSay("LISTEN CHANNEL: "+(string)channel+" NAME: "+name+" ID: "+(string)id+"\n"+message);
	}
}
initMain(){
	titleName="TitleText";
	titleParent="TOP";
	titleText="";
	titleColor=<1.0, 1.0, 1.0>;
	titleAlpha=1.0;
	titleShow=FALSE;
}
/*CONFIG END*/

/*
Name: Title
Author: JMRY
Description: A title controller for restraint items.

***更新记录***
- 1.0 20260419
    - 完成主要功能。
***更新记录***
*/

integer includes(string src, string target){
    integer startPos = llSubStringIndex(src, target);
    if(~startPos){
        return TRUE;
    }else{
        return FALSE;
    }
}

list strSplit(string m, string sp){
    list pl=llParseStringKeepNulls(m,[sp],[""]);
    list temp=[];
    integer i;
    for(i=0; i<llGetListLength(pl); i++){
        temp+=[llStringTrim(llList2String(pl, i), STRING_TRIM)];
    }
    return temp;
}

string titleName="TitleText";
string titleParent="TOP";
string titleText="";
vector titleColor=ZERO_VECTOR;
float titleAlpha=0.0;
integer titleShow=FALSE;

applyTitle(){
	llMessageLinked(LINK_THIS, TEXT_MSG_NUM, "TEXT.SET|"+titleName+"|"+titleText+"|"+(string)titleShow+"|"+titleParent, NULL_KEY);
	llMessageLinked(LINK_THIS, TEXT_MSG_NUM, "TEXT.SET.COLOR|"+(string)titleColor, NULL_KEY);
	llMessageLinked(LINK_THIS, TEXT_MSG_NUM, "TEXT.SET.ALPHA|"+(string)titleAlpha, NULL_KEY);
	if(titleShow==TRUE){
		llMessageLinked(LINK_THIS, TEXT_MSG_NUM, "TEXT.SET.DISPLAY|"+(string)titleShow, NULL_KEY);
	}
}

string menuName="TitleMenu";
string menuParent="";
showMenu(string parent, key user){
    menuParent=parent;
    string menuText="This is Title menu.\nCurrent title: %1%\nColor: %2%\nAlpha: %3%%%;"+titleText+";"+(string)titleColor+";"+(string)titleAlpha;
    list menuList=[
        "T:SetTitle", "T:SetColor", "T:SetAlpha",
        "["+(string)titleShow+"]T:ShowTitle"
    ];
    llMessageLinked(LINK_SET, MENU_MSG_NUM, "MENU.REG.OPEN|"+menuName+"|\\NL"+menuText+"|"+llDumpList2String(menuList, ";")+"|"+parent, user);
}

integer MENU_MSG_NUM=1000;
integer TEXT_MSG_NUM=1008;
integer MAIN_MSG_NUM=9000;
integer TITLE_MSG_NUM=90002;

default{
    state_entry(){
        initMain();
    }
	changed(integer change){
        if(change & CHANGED_OWNER){
            llResetScript();
        }
    }
    link_message(integer sender_num, integer num, string msg, key user){
        if(num!=MAIN_MSG_NUM && num!=MENU_MSG_NUM && num!=TEXT_MSG_NUM){
            return;
        }
        list msgList=strSplit(msg, "|");
        string msgHeader=llList2String(msgList, 0);
        list msgHeaderGroup=llParseStringKeepNulls(msgHeader, ["."], [""]);

        string headerMain=llList2String(msgHeaderGroup, 0);
        string headerSub=llList2String(msgHeaderGroup, 1);
        string headerExt=llList2String(msgHeaderGroup, 2);

        string msg1=llList2String(msgList, 1);
        string msg2=llList2String(msgList, 2);
        string msg3=llList2String(msgList, 3);
        string msg4=llList2String(msgList, 4);

        if(headerMain=="TITLE" && headerSub!="EXEC"){
			string result="";
			if(headerSub=="GET"){
				if(headerExt=="TEXT"){
					/*
					显示文本颜色
					TITLE.GET.TEXT
					返回：
					TITLE.EXEC | TITLE.GET.TEXT | Text
					*/
					result=(string)titleText;
				}
				else if(headerExt=="COLOR"){
					/*
					显示文本颜色
					TITLE.GET.COLOR
					返回：
					TITLE.EXEC | TITLE.GET.COLOR | <1.0, 1.0, 1.0>
					*/
					result=(string)titleColor;
				}
				else if(headerExt=="ALPHA"){
					/*
					显示文本透明度
					TITLE.GET.ALPHA
					返回：
					TITLE.EXEC | TITLE.GET.ALPHA | 1.0
					*/
					result=(string)titleAlpha;
				}
				else if(headerExt=="SHOW"){
					/*
					是否显示文本
					TITLE.GET.SHOW
					返回：
					TITLE.EXEC | TITLE.GET.SHOW | 1
					*/
					result=(string)titleShow;
				}
			}
			else if(headerSub=="SET"){
				if(headerExt=="TEXT"){
					/*
					显示文本颜色
					TITLE.SET.TEXT | Text
					返回：
					TITLE.EXEC | TITLE.SET.TEXT | Text
					*/
					titleText=msg1;
					result=(string)titleText;
				}
				else if(headerExt=="COLOR"){
					/*
					显示文本颜色
					TITLE.SET.COLOR | <1.0, 1.0, 1.0>
					返回：
					TITLE.EXEC | TITLE.SET.COLOR | <1.0, 1.0, 1.0>
					*/
					titleColor=(vector)msg1;
					result=(string)titleColor;
				}
				else if(headerExt=="ALPHA"){
					/*
					显示文本透明度
					TITLE.SET.ALPHA | 1.0
					返回：
					TITLE.EXEC | TITLE.SET.ALPHA | 1.0
					*/
					titleAlpha=(float)msg1;
					result=(string)titleAlpha;
				}
				else if(headerExt=="SHOW"){
					/*
					是否显示文本
					TITLE.SET.SHOW | 1
					返回：
					TITLE.EXEC | TITLE.SET.SHOW | 1
					*/
					titleShow=(integer)msg1;
					result=(string)titleShow;
				}
				applyTitle();
			}
			else if(headerSub=="MENU"){
				/*
				显示菜单
				TITLE.MENU | Parent
				*/
				showMenu(msg1,user);
			}
			if(result!=""){
                llMessageLinked(LINK_THIS, TITLE_MSG_NUM, "TITLE.EXEC|"+msgHeader+"|"+result, user);
            }
        }
        else if(headerMain=="MAIN" && headerSub=="INIT"){
            llMessageLinked(LINK_THIS, MAIN_MSG_NUM, "FEATURE.REG|Title", user);
        }
        else if(headerMain=="MENU" && headerSub=="ACTIVE"){
            // MENU.ACTIVE | MenuName | MenuButton
            if(msg1=="appMenu" && msg2=="Title"){
                showMenu(msg1,user);
            }
			else if(msg1==menuName && msg2!=""){
				if(msg2=="T:SetTitle"){
					llMessageLinked(LINK_THIS, MENU_MSG_NUM, "MENU.INPUT|TitleInput_"+msg2+"|Input your title (Current: %1%):%%;"+titleText, user);
				}
				else if(msg2=="T:SetColor"){
					llMessageLinked(LINK_THIS, MENU_MSG_NUM, "MENU.INPUT|TitleInput_"+msg2+"|Input your color in format <red, green, blue> like <1.0, 1.0, 1.0> (Current: %1%):%%;"+(string)titleColor, user);
				}
				else if(msg2=="T:SetAlpha"){
					llMessageLinked(LINK_THIS, MENU_MSG_NUM, "MENU.INPUT|TitleInput_"+msg2+"|Input your alpha (0.0~1.0, Current: %1%):%%;"+(string)titleAlpha, user);
				}
				else if(msg2=="T:ShowTitle"){
					titleShow=!titleShow;
					applyTitle();
					showMenu(menuParent,user);
				}
			}
			else if(includes(msg1, "TitleInput")){
				if(msg1=="TitleInput_T:SetTitle"){
					titleText=msg2;
				}
				else if(msg1=="TitleInput_T:SetColor"){
					titleColor=(vector)msg2;
				}
				else if(msg1=="TitleInput_T:SetAlpha"){
					titleAlpha=(float)msg2;
				}
				applyTitle();
				showMenu(menuParent,user);
			}
        }
    }
}
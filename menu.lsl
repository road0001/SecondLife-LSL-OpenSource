/*
Name: Menu
Author: JMRY
Description: A better menu management system, use link_message to operate menus.

***更新记录***
- 1.1.4 20250702
    - 修复报错的bug。
- 1.1.3 20250701
    - 加入多级菜单翻页记忆功能。
- 1.1.2 20250627
    - 调整语言系统算法，当语言系统不存在时，跳过语言功能。
- 1.1.1 20250626
    - 修复菜单系统报错的bug。
    - 修复页数会多次显示的bug。
- 1.1 20250625
    - 加入菜单页数显示。
    - 分离语言处理功能，使用LinkSetData处理语言。
    - 修复使用过简易菜单后，正常菜单失效的bug。
- 1.0.14 20250618
    - 优化菜单端口，现在只会随机生成一次端口号。
    - 修复菜单按钮文字超长而报错的bug。
    - 修复部分情况下，菜单监听失效的bug。
- 1.0.13 20250122
    - 加入语言变量拼接嵌套。
    - 加入获取所有语言数据接口。
    - 加入拼接变量显示开关功能。
    - 优化按钮开关状态显示算法。
    - 调整语言变量拼接字符。

- 1.0.12 20250115
    - 合并菜单、简易菜单、输入框功能函数。
    - 去除不必要的函数以节省内存。

- 1.0.11 20250114
    - 修复修改配置文件时重置脚本的bug。

- 1.0.10 20250113
    - 优化内存占用。

- 1.0.9 20250112
    - 修复页数计算错误的bug。
    - 修复comfirm菜单会报错的bug。

- 1.0.8 20250109
    - 调整语言文本拼接变量格式（%%→%%;）。

- 1.0.7 20250108
    - 为菜单功能添加消息识别ID。

- 1.0.6 20250103
    - 优化语言载入逻辑。

- 1.0.5 20250102
    - 加入简易菜单和输入框功能。

- 1.0.4 20241228
    - 修复bugs。

- 1.0.3 20241227
    - 优化菜单和MessageLinked处理逻辑。
    - 优化变量拼接功能，变量可再匹配一次语言。

- 1.0.2 20241224
    - 加入批量执行菜单指令并批量返回结果功能。
    - 加入获取拼接变量的语言文本功能。
    - 加入语言中自定义开关样式功能。
    - 修复result类型错误的bug。

- 1.0.1 20241223
    - 添加获取菜单语言文本功能（正查、反查）。
    - 提升菜单性能。
    
- 1.0 20241221
    - 完成菜单功能（需要测试）。
    - 修复部分bugs。

- 1.0 20241121
    - 加入多语言功能。
    - 加入执行菜单时不重置页数功能（用于重新显示菜单当前页）。

- 1.0 20241115
    - 完成菜单管理功能。
***更新记录***
*/

/*
TODO:
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
    string t=k;
    integer i;
    list boolList=llParseStringKeepNulls(boolStrList,["|"],[""]);
    for(i=0; i<llGetListLength(boolList); i++){
        t=replace(t,llList2String(boolList, i)+" ", "");
    }
    return llStringTrim(t, STRING_TRIM);
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
/*
菜单多语言通用方法。
设置语言（文字KEY，文字值），返回：当前语言的KEY对应文字
获取语言（文字KEY），返回：当前语言的KEY对应文字
*/
integer hasLanguage=FALSE;
initLanguage(){
    hasLanguage=FALSE;
    llMessageLinked(LINK_SET, LAN_MSG_NUM, "LANGUAGE.INIT", llGetOwner()); // 得到语言系统初始化确认时，将hasLanguage置为TRUE。
}

string lanLinkHeader="LAN_";
string getLanguage(string k){
    if(!hasLanguage){
        return k;
    }
    k=replace(replace(k,"\\n","\n"),"\n","\\n"); // 替换换行符\n。将转义的\\n替换回去再替换
    string curVal=llLinksetDataRead(lanLinkHeader+k);
    if(curVal){
        return replace(curVal,"\\n","\n");
    }else{
        return replace(k,"\\n","\n");
    }
}

string getLanguageKey(string v){
    if(!hasLanguage){
        return v;
    }
    list lanKeyList=llLinksetDataFindKeys(lanLinkHeader, 0, 0);
    integer i;
    for(i=0; i<llGetListLength(lanKeyList); i++){
        string curKey=llList2String(lanKeyList, i);
        string curVal=llLinksetDataRead(curKey);
        if(curVal==v){
            return curKey;
        }
    }
    return v;
}

string getLanguageVar(string k){ // 拼接字符串方法，用于首尾拼接变量等内容。格式：Text text %1 %2.%%var1;var2
    list ksp=llParseStringKeepNulls(k, ["%%;"], [""]); // ["Text text %1 %2.", "var1;var2"]
    string text=getLanguage(trim(llList2String(ksp, 0)));
    list var=data2List(llList2String(ksp, 1)); // ["var1", "var2"]
    integer i;
    for(i=0; i<llGetListLength(var); i++){
        integer vi=i+1;
        text=replace(text, "%"+(string)vi+"%", getLanguage(llList2String(var, i)));
        text=replace(text, "%b"+(string)vi+"%", getLanguageBool(llList2String(var, i)));
    }
    return text;
}

string defaultBoolStrList="◇|◆";
string boolStrList=defaultBoolStrList;
string getLanguageBool(string k){ // 拼接字符串方法之开关，根据传入字符串来判断开关并显示。格式：[0/1]BUTTON_NAME，返回：◇ 按钮名 / ◆ 按钮名
    //return getLanguageVar(k, LVPOS_BEFORE, llList2String(boolStrList,bool));
    list boolList=msg2List(boolStrList);
    integer bool=FALSE;
    if(includes(k, "[1]")){
        bool=TRUE;
    }else if(includes(k, "[0]")){
        bool=FALSE;
    }else{
        bool=-1;
    }
    if(~bool){
        return llList2String(boolList, bool) + " " + getLanguage(replace(replace(k, "[1]", ""), "[0]", ""));
    }else{
        return getLanguage(k);
    }
}

integer applyLanguage(){
    string switchStr=getLanguage("ButtonSwitch"); // 更改开关样式。格式：关|开
    if(switchStr=="ButtonSwitch"){ // 如果返回的是buttonSwitch（即不存在此字段，则应用默认样式）
        boolStrList=defaultBoolStrList;
    }else{
        boolStrList=switchStr;
    }
    return TRUE;
}

/*
注册菜单通用方法。
参数：菜单名，菜单文字，菜单按钮表，父级菜单名（顶层菜单用空字符串）
*/
list menuRegistList=[];
// list menuNameList=[];
// list menuTextList=[];
// list menuItemList=[];
// list menuParentList=[];
integer findMenu(string mname){
    integer menuIndex=llListFindList(menuRegistList, [mname]);
    if(menuIndex%4==0){
        return menuIndex;
    }else{
        return -1;
    }
}
integer registMenu(string mname, string mtext, list mlist, string mparent){
    integer menuIndex=findMenu(mname);
    string menuItem=list2Data(mlist);
    if(~menuIndex){ // 菜单名存在时，覆盖 ~menuIndex等价于menuIndex!=-1，速度更快
        menuRegistList = llListReplaceList(menuRegistList, [mtext, menuItem, mparent], menuIndex+1, menuIndex+3);
        // menuTextList = llListReplaceList(menuTextList, [mtext], menuIndex, menuIndex);
        // menuItemList = llListReplaceList(menuItemList, [menuItem], menuIndex, menuIndex);
        // menuParentList=llListReplaceList(menuParentList, [mparent], menuIndex, menuIndex);
    }else{ // 菜单名不存在时，插入
        menuRegistList+=[mname, mtext, menuItem, mparent];
        // menuNameList+=[mname];
        // menuTextList+=[mtext];
        // menuItemList+=[menuItem];
        // menuParentList+=[mparent];
    }
    return TRUE;
}

integer removeMenu(string mname){
    setShowMenuPageList(mname,-1);
    integer menuIndex=findMenu(mname);
    if(~menuIndex){
        menuRegistList=llDeleteSubList(menuRegistList, menuIndex, menuIndex+3);
        // menuNameList=llDeleteSubList(menuNameList, menuIndex, menuIndex);
        // menuTextList=llDeleteSubList(menuTextList, menuIndex, menuIndex);
        // menuItemList=llDeleteSubList(menuItemList, menuIndex, menuIndex);
        // menuParentList=llDeleteSubList(menuParentList, menuIndex, menuIndex);
        return TRUE;
    }else{
        return FALSE;
    }
}
integer clearMenu(){
    setShowMenuPageList("",-1);
    menuRegistList=[];
    // menuNameList=[];
    // menuTextList=[];
    // menuItemList=[];
    // menuParentList=[];
    return TRUE;
}
integer executeMenu(string mname, integer reset, key user){
    if(mname==""){
        mname=showMenuName;
    }
    integer menuIndex=findMenu(mname);
    if(~menuIndex){
        if(reset>0){ // reset=FALSE用于reshow菜单
            showMenuPage=reset; // 执行菜单时，重置页数
            setShowMenuPageList(mname, reset);
        }else{
            showMenuPage=getShowMenuPageList(mname);
            if(!~showMenuPage){
                showMenuPage=1;
                setShowMenuPageList(mname, showMenuPage);
            }
        }
        string menuName=mname;
        string menuText=llList2String(menuRegistList, menuIndex+1);
        list menuItem=data2List(llList2String(menuRegistList, menuIndex+2));
        string menuParent=llList2String(menuRegistList, menuIndex+3);
        showMenu(menuName, menuText, menuItem, menuParent, TRUE, user); // menuType必须传TRUE，不然会回到原生菜单
        // string menuText=llList2String(menuTextList, menuIndex);
        // // list menuItem=llParseStringKeepNulls(llList2String(menuItemList, menuIndex), ["|"], []);
        // list menuItem=data2List(llList2String(menuItemList, menuIndex));
        // string menuParent=llList2String(menuParentList, menuIndex);
        // showMenu(menuName, menuText, menuItem, menuParent, user);
        return TRUE;
    }else{
        return FALSE;
    }
}
integer reshowMenu(string mname, key user){
    return executeMenu(mname, FALSE, user);
}

list showMenuPageList=[];
integer setShowMenuPageList(string mname, integer mpage){
    if(mname=="" && mpage<0){ // 同时传空字符串和-1表示清空
        showMenuPageList=[];
        return mpage;
    }
    integer menuIndex=llListFindList(showMenuPageList, [mname]);
    if(menuIndex%2==0){
        if(mpage>=0){
            showMenuPageList=llListReplaceList(showMenuPageList, [mpage], menuIndex+1, menuIndex+1); // 页数大于0时，修改
        }else{
            llDeleteSubList(showMenuPageList, menuIndex, menuIndex+1); // 页数小于0时，删除
        }
    }else if(mpage>=0){
        showMenuPageList+=[mname, mpage]; // 未找到时，添加
    }
    return mpage;
}

integer getShowMenuPageList(string mname){
    integer menuIndex=llListFindList(showMenuPageList, [mname]);
    if(menuIndex%2==0){
        return llList2Integer(showMenuPageList, menuIndex+1);
    }else{
        return -1;
    }
}
/*
显示菜单通用方法。
参数：菜单名（用于重显示菜单），菜单文字，菜单按钮表，用户
自动重排：传入菜单按从上到下顺序，显示菜单按从下到上顺序，因此进行重排
*/
integer menuListenHandle;
integer showMenuType=TRUE;
integer menuChannel;
string showMenuName="";
string showMenuText="";
string showMenuParent="";
key showMenuUser=NULL_KEY;
// list pageBu=["←","→","BACK","CLOSE"]; // 上一页，下一页，返回，关闭的文本
string pageBuStr="←|→|BACK|CLOSE"; // 上一页，下一页，返回，关闭的文本
list showMenuList=[];
integer showMenuPage=1;
integer showMenu(string mname, string mtext, list mlist, string mparent, integer mtype, key user){
    showMenuName="";
    showMenuText="";
    showMenuList=[];
    showMenuParent="";
    showMenuUser=NULL_KEY;
    showMenuType=mtype;
    // llListenRemove(menuListenHandle);
    llSetTimerEvent(0);
    if(mname==""){
        return FALSE;
    }
    if(!menuChannel){
        menuChannel=(integer)(llFrand(1000000000.0) - 9000000000.0);
        // menuChannel=(integer)(llFrand(-1000000000.0) - 1000000000.0);
    }
    showMenuName=mname;
    showMenuText=getLanguageVar(mtext);
    string showMenuTextInner=showMenuText;
    showMenuUser=user;
    // showMenuType>0时为菜单，小于等于0时为输入框
    if(mtype>0){
        showMenuList=mlist;
        showMenuParent=mparent;
        // 初始化菜单列表，根据页数载入9个
        list menuItems=[];
        // 正常菜单，处理翻页情况
        if(mtype==1){
            // 计算总页数（向上取整）和偏移数（从0开始计算（0~8，9~17……）
            integer buttonsPerPage=9;
            integer totalPages=llCeil((float)llGetListLength(mlist) / (float)buttonsPerPage); // 向上取整，需要将数值转换成float再算

            //llOwnerSay("Total page: "+(string)totalPages+" CurPage: "+(string)showMenuPage+" Items: "+(string)llGetListLength(showMenuList)+" Calc: "+(string)(llGetListLength(showMenuList) / buttonsPerPage + 1));

            integer offset=(showMenuPage - 1) * buttonsPerPage;
            // 生成翻页和返回按钮
            string prev=" ";
            string next=" ";
            string back=" ";
            list pageBu=msg2List(pageBuStr);
            if(showMenuPage>1){
                prev=llList2String(pageBu,0);
            }
            if(showMenuPage<totalPages){
                next=llList2String(pageBu,1);
            }
            if(showMenuParent!=""){
                back=llList2String(pageBu,2);
            }else{
                back=llList2String(pageBu,3);
            }

            if(totalPages>1){
                showMenuTextInner=showMenuText+"\n"+(string)showMenuPage+" / "+(string)totalPages;
            }
            
            integer i;
            for(i=0; i<buttonsPerPage; i++){
                string curMenu=llList2String(mlist,i+offset);
                if(curMenu!=""){
                    menuItems+=curMenu;
                }else{
                    menuItems+=[" "]; // 对于超出索引的部分，返回空字符串，但在对话框中需要加一个空格
                }
            }
            // 根据菜单按钮规则重新排序并添加翻页和返回按钮
            menuItems=[
                getLanguageBool(prev), getLanguageBool(back), getLanguageBool(next), // 第四行
                getLanguageBool(llList2String(menuItems,6)), getLanguageBool(llList2String(menuItems,7)), getLanguageBool(llList2String(menuItems,8)), // 第三行
                getLanguageBool(llList2String(menuItems,3)), getLanguageBool(llList2String(menuItems,4)), getLanguageBool(llList2String(menuItems,5)), // 第二行
                getLanguageBool(llList2String(menuItems,0)), getLanguageBool(llList2String(menuItems,1)), getLanguageBool(llList2String(menuItems,2))  // 第一行
            ];
            // for(i=0; i<llGetListLength(menuItems); i++){
            //     llListReplaceList(menuItems, [llGetSubString(llList2String(menuItems, i), 0, 23)], i, i);
            // }
        }
        // 简易菜单，只处理按钮的语言
        else if(mtype==2){
            menuItems=mlist;
            integer menuCount=llGetListLength(menuItems);
            if(menuCount==1 && llList2String(menuItems,0)==""){
                menuItems=["OK"];
            }
            integer i;
            for(i=0; i<menuCount; i++){
                menuItems=llListReplaceList(menuItems,[getLanguageBool(llList2String(menuItems, i))], i, i);
            }
        }
        llDialog(user, showMenuTextInner, menuItems, menuChannel);
    }else{
        llTextBox(user, showMenuTextInner, menuChannel);
    }
    menuListenHandle=llListen(menuChannel, "", user, "");
    llSetTimerEvent(60);
    return TRUE;
}

showMenuHandle(string message, key user){
    list pageBu=msg2List(pageBuStr);
    if(showMenuType>0 && message == " "){
        showMenu(showMenuName, showMenuText, showMenuList, showMenuParent, showMenuType, user);
        return;
    }
    if(showMenuType>0){
        message=getLanguageKey(trim(message));
    }else{
        message=llStringTrim(message,STRING_TRIM); // trim会做一些别的事情，因此使用LL函数trim字符串
    }
    if (showMenuType>0 && message == llList2String(pageBu,0)){ // 上一页
        showMenuPage--;
        setShowMenuPageList(showMenuName,showMenuPage);
        showMenu(showMenuName, showMenuText, showMenuList, showMenuParent, showMenuType, user);
        llMessageLinked(LINK_SET, MENU_MSG_NUM, "MENU.PREV", user);
    }else if (showMenuType>0 && message == llList2String(pageBu,1)){ // 下一页
        showMenuPage++;
        setShowMenuPageList(showMenuName,showMenuPage);
        showMenu(showMenuName, showMenuText, showMenuList, showMenuParent, showMenuType, user);
        llMessageLinked(LINK_SET, MENU_MSG_NUM, "MENU.NEXT", user);
    }else if(showMenuType>0 && message == llList2String(pageBu,2)){ // 返回
        removeMenu(showMenuName); // 返回上级菜单时，移除当前菜单
        executeMenu(showMenuParent, FALSE, user);
        llMessageLinked(LINK_SET, MENU_MSG_NUM, "MENU.BACK", user);
    }else if(showMenuType>0 && message == llList2String(pageBu,3)){ // 关闭
        showMenu("", "", [], "", TRUE, user);
        clearMenu(); // 关闭菜单时，清空菜单
        llListenRemove(menuListenHandle);
        llMessageLinked(LINK_SET, MENU_MSG_NUM, "MENU.CLOSE", user);
    }else{
        list menuCmdList=[
            "MENU.ACTIVE",
            showMenuName,
            message
        ];
        // MENU.ACTIVE|MainMenu|Button 1
        llMessageLinked(LINK_SET, MENU_MSG_NUM, list2Msg(menuCmdList), user);
    }
}

integer MENU_MSG_NUM=1000;
integer LAN_MSG_NUM=1003;
default{
    state_entry(){
        initLanguage();
    }
    changed(integer change){
        if(change & CHANGED_OWNER){
            llResetScript();
        }
        if(change & CHANGED_INVENTORY){
            initLanguage();
        }
    }

    listen(integer channel, string name, key user, string message){
        if(channel==menuChannel){ // 监听菜单按钮并调用相关函数
            showMenuHandle(message, user);
        }
    }

    timer(){ // 超时关闭菜单并重置
        showMenu("", "", [], "", TRUE, NULL_KEY);
        clearMenu();
        llListenRemove(menuListenHandle);
    }

    link_message(integer sender_num, integer num, string msg, key user){
        if(num!=MENU_MSG_NUM && num!=LAN_MSG_NUM){
            return;
        }
        /*
        注册菜单，格式：标头 | 菜单名 | 菜单文本 | 菜单按钮1; 菜单按钮2; ... | 上级菜单（可选）
        MENU.REGIST | mainMenu | Main menu desc | Button 1; Button 2; Button 3
        MENU.REG | subMenu | Sub menu desc | Button 1; Button 2; Button 3 | mainMenu
        注册并显示菜单，格式和上面相同
        MENU.REGIST.OPEN | mainMenu | Main menu desc | Button 1; Button 2; Button 3
        MENU.REG.OPEN | subMenu | Sub menu desc | Button 1; Button 2; Button 3 | mainMenu
        MENU.REG.OPEN.1 | subMenu | Sub menu desc | Button 1; Button 2; Button 3 | mainMenu
        MENU.REG.OPEN.RESET | subMenu | Sub menu desc | Button 1; Button 2; Button 3 | mainMenu
        菜单文本拼接变量
        MENU.REG.OPEN | subMenu | Sub menu desc %1 %2 %%;val1;val2 | Button 1; Button 2; Button 3 | mainMenu
        打开菜单，格式：标头 | 菜单名 | 重置页数（可选）
        默认不reshow菜单，在有需要reshow的场合，重新调用同名菜单即可。
        MENU.OPEN | mainMenu
        MENU.OPEN.1 | mainMenu
        MENU.OPEN.RESET | subMenu
        简易菜单（用于提示、确认事项等），格式：标头 | 菜单名 | 菜单文本 | 菜单按钮1; 菜单按钮2; ...（可选，留空为OK）
        MENU.CONFIRM | confirmMenu | Are you confirm desc %1 %2 %%;val1;val2
        MENU.CONFIRM | confirmMenu | Are you confirm desc %1 %2 %%;val1;val2 | OK; Wait; Cancel
        MENU.CONFIRM | confirmMenu | Are you confirm desc %1 %2 %%;val1;val2 | OK; Wait; Cancel; BACK | mainMenu
        文本输入，格式：标头 | 菜单名 | 菜单文本
        MENU.INPUT | inputMenu | Please input something %1 %2 %%;val1;val2
        移除菜单，格式：标头 | 菜单名
        MENU.REM | subMenu
        MENU.REMOVE | subMenu
        清空菜单，格式：标头
        MENU.CLEAR
        按钮激活格式：llMessageLinked(LINK_SET, 1000, 指令, 操作者UUID)
        MENU.ACTIVE | mainMenu | Button 1
        MENU.ACTIVE | confirmMenu | OK
        MENU.ACTIVE | inputMenu | Inputed something
        菜单执行后，会发送执行结果回调，格式：
        MENU.EXEC | MENU.REG.OPEN.RESET | 1 // 1=成功，0=失败，或其他结果字符串
        */
        list msgList=bundle2List(msg);
        list resultList=[];
        integer msgCount=llGetListLength(msgList);
        integer mi;
        for(mi=0; mi<msgCount; mi++){
            string str=llList2String(msgList, mi);
            if (llGetSubString(str, 0, 4) == "MENU." && !includes(str, "EXEC")) {
                list menuCmdList=msg2List(str);
                string menuCmdStr=llList2String(menuCmdList, 0);
                list menuCmdGroup=llParseStringKeepNulls(menuCmdStr, ["."], [""]);
    
                string menuCmd=llList2String(menuCmdGroup, 0);
                string menuCmdSub=llList2String(menuCmdGroup, 1);
                string menuCmdExt=llList2String(menuCmdGroup, 2);
                string menuCmdExt2=llList2String(menuCmdGroup, 3);
    
                string menuName=llList2String(menuCmdList, 1);
                string menuText=llList2String(menuCmdList, 2);
                list menuButtons=data2List(llList2String(menuCmdList, 3));
                string menuParent=llList2String(menuCmdList, 4);
    
                string result="";
                if(menuCmdSub=="REG" || menuCmdSub=="REGIST"){
                    result=(string)registMenu(menuName, menuText, menuButtons, menuParent);
                    if(menuCmdExt=="OPEN"){
                        integer reset=FALSE;
                        if(menuCmdExt2!=""){
                            if(menuCmdExt2=="RESET"){
                                reset=1;
                            }else{
                                reset=(integer)menuCmdExt2;
                            }
                        }
                        result=(string)executeMenu(menuName, reset, user);
                    }
                }
                else if(menuCmdSub=="CONFIRM"){
                    result=(string)showMenu(menuName, menuText, menuButtons, menuParent, 2, user);
                }
                else if(menuCmdSub=="INPUT"){
                    result=(string)showMenu(menuName, menuText, [], "", 0, user);
                }
                else if(menuCmdSub=="OPEN"){
                    integer reset=FALSE;
                    if(menuCmdExt!=""){
                        if(menuCmdExt=="RESET"){
                            reset=1;
                        }else{
                            reset=(integer)menuCmdExt;
                        }
                    }
                    result=(string)executeMenu(menuName, reset, user);
                }
                else if(menuCmdSub=="REM" || menuCmdSub=="REMOVE"){
                    result=(string)removeMenu(menuName);
                }
                else if(menuCmdSub=="CLEAR"){
                    result=(string)clearMenu();
                }
                
                if(result!=""){
                    list menuExeResult=[
                        "MENU.EXEC", menuCmdStr, result
                    ];
                    resultList+=[list2Msg(menuExeResult)];
                    //llMessageLinked(LINK_SET, 0, list2Msg(menuExeResult), user); // 菜单处理完成后的回调
                }
            }
            else if (llGetSubString(str, 0, 2) == "LAN" && includes(str, "INIT")) { // 接收语言系统INIT回调，并启用语言功能
                hasLanguage=TRUE;
            }
            else if (llGetSubString(str, 0, 2) == "LAN" && includes(str, "ACTIVE")) { // 接收语言系统ACTIVE回调，并应用语言数据
                applyLanguage();
            }
        }
        if(llGetListLength(resultList)>0){
            llMessageLinked(LINK_SET, MENU_MSG_NUM, list2Bundle(resultList), user); // 菜单处理完成后的回调
        }
        // llOwnerSay("Menu Memory Used: "+(string)llGetUsedMemory()+" Free: "+(string)llGetFreeMemory());
    }
}
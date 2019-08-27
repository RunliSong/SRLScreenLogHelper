# SRLScreenLogHelper
屏幕日志，可切换单行和列表展示

位于屏幕顶部的的日志展示视图
使用步骤：
1、全局引入头文件
2、在某个地方加个开关触发事件，修改NSUserDefault中show_screen_log_view_key的值，YES为开，NO为关。
3、并在事件中post一条通知screenLogSwitchNotification

如果你不知道怎么写可以直接复制以下代码到事件处理方法中

BOOL isOpen = [[NSUserDefaults standardUserDefaults] boolForKey:show_screen_log_view_key];
isOpen = !isOpen;
[[NSUserDefaults standardUserDefaults] setBool:isOpen forKey:show_screen_log_view_key];
[[NSNotificationCenter defaultCenter] postNotificationName:screenLogSwitchNotification object:nil];

好了，你全部的NSLog都可以在屏幕中看到了。加油。

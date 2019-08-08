//
//  SRLScreenLogHelper.h
//
//  Created by SongRunli on 2019/8/8.
//  Copyright © 2019 com.SongRunli. All rights reserved.
//
/**
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
 */

#import <Foundation/Foundation.h>

#define show_screen_log_view_key @"show_screen_log_view"
#define screenLogSwitchNotification @"screenLogSwitchNotification"

#ifdef DEBUG
#define NSLog(FORMAT, ...)  fprintf(stderr,"%s\n",[[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]); \
                            [[SRLScreenLogHelper sharedHelper] addLogAndShow:[NSString stringWithFormat:FORMAT, ##__VA_ARGS__]]
#else
#define NSLog(...)
#endif

NS_ASSUME_NONNULL_BEGIN

@interface SRLScreenLogHelper : NSObject

+(instancetype)sharedHelper;

- (void)addLogAndShow:(NSString *)log;

@end

NS_ASSUME_NONNULL_END

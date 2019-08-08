//
//  SRLScreenLogHelper.m
//
//  Created by SongRunli on 2019/8/8.
//  Copyright © 2019 com.SongRunli. All rights reserved.
//

#import "SRLScreenLogHelper.h"
#import <Masonry/Masonry.h>

#define MainScreen_W   [UIScreen mainScreen].bounds.size.width //屏幕宽
#define MainScreen_H   [UIScreen mainScreen].bounds.size.height //屏幕高
#define AppKeyWindow   [UIApplication sharedApplication].keyWindow
#define statusBar_H    [[UIApplication sharedApplication] statusBarFrame].size.height

#define MULTILINE_TEXTSIZE(text, font, maxSize, mode) [text length] > 0 ? [text \
boundingRectWithSize:maxSize options:(NSStringDrawingUsesLineFragmentOrigin) \
attributes:@{NSFontAttributeName:font} context:nil].size : CGSizeZero


static SRLScreenLogHelper *_sharedHelper = nil;

static NSString * _defaultLogMsg = @"当前暂无需要展示的日志";

@interface SRLScreenLogHelper () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray <NSString *>* logDataArray;

@property (nonatomic, strong) UIView * containerView;       //背景

@property (nonatomic, strong) UITableView * logTable;       //日志列表

@property (nonatomic, strong) UILabel * currentLogLabel;    //最新的一条日志

@end

@implementation SRLScreenLogHelper

#pragma mark - life cycle

+(instancetype)sharedHelper{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedHelper = [[SRLScreenLogHelper alloc] init];
    });
    return _sharedHelper;
}

+(void)releaseSharedHelper{
    _sharedHelper = nil;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showScreenLogWithUserDefault) name:screenLogSwitchNotification object:nil];
    }
    return self;
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:screenLogSwitchNotification object:nil];
}

#pragma mark - public methods

- (void)addLogAndShow:(NSString *)log{
    if ([log isKindOfClass:[NSString class]] && log.length > 0) {
        NSString *trimedLog = [log stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
        [self.logDataArray addObject:trimedLog];
        if (self.logTable.isHidden) {
            [self setCurrentLogLabelText:trimedLog];
        }else{
            [self.logTable reloadData];
            [self.logTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.logDataArray indexOfObject:trimedLog] inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        }
    }
}


#pragma mark - private methods

- (void)showScreenLogWithUserDefault{
    BOOL isShow = [[NSUserDefaults standardUserDefaults] boolForKey:show_screen_log_view_key];
    if (isShow) {
        [self displayUI];
    }else{
        [self removeAndReset];
    }
}

- (void)displayUI{
    [AppKeyWindow addSubview:self.containerView];
    
    [self.containerView addSubview:self.logTable];
    [self.containerView addSubview:self.currentLogLabel];
    
    self.logTable.hidden = YES;
    self.currentLogLabel.hidden = NO;
    if (self.logDataArray.count > 0) {
        self.currentLogLabel.text = [self.logDataArray lastObject];
    }else{
        [self setCurrentLogLabelText:_defaultLogMsg];
    }
}

- (void)removeAndReset{
    [self.logDataArray removeAllObjects];
    [self.logTable reloadData];
    [self.containerView removeFromSuperview];
}

- (void)setCurrentLogLabelText:(NSString *)text{
    CGSize textSize = MULTILINE_TEXTSIZE(text,[UIFont systemFontOfSize:13], CGSizeMake(MainScreen_W, MainScreen_H), 0);
    self.currentLogLabel.text = text;
    
    self.containerView.height = textSize.height;
    self.currentLogLabel.height = textSize.height;
    
}

- (void)updateLogStyle:(id)sender{
    if ([sender isKindOfClass:[UITapGestureRecognizer class]]) {
        self.currentLogLabel.hidden = YES;
        self.logTable.hidden = NO;
       
        self.containerView.height = MainScreen_H/2;
        
    }else{
        self.currentLogLabel.hidden = NO;
        self.logTable.hidden = YES;
        
        [self setCurrentLogLabelText:[self.logDataArray lastObject]];
    }
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.logDataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellID = @"logCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID] ;
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.contentView.backgroundColor = [UIColor clearColor];
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.text = self.logDataArray[indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:13];
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.textColor = [UIColor whiteColor];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *text = self.logDataArray[indexPath.row];
    CGSize textSize = MULTILINE_TEXTSIZE(text, [UIFont systemFontOfSize:13], CGSizeMake(MainScreen_W, MainScreen_H), 0);

    return textSize.height+10;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self updateLogStyle:tableView];
}

#pragma mark - getters

- (UIView *)containerView{
    if (!_containerView) {
        _containerView = [UIView new];
        _containerView.frame = CGRectMake(0, statusBar_H, MainScreen_W, 20);
        _containerView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
    }
    return _containerView;
}

- (UITableView *)logTable{
    if (!_logTable) {
        _logTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, MainScreen_W, MainScreen_H/2) style:UITableViewStylePlain];
        _logTable.dataSource = self;
        _logTable.delegate = self;
        _logTable.backgroundColor = [UIColor clearColor];
        _logTable.bounces = NO;
        _logTable.backgroundView.backgroundColor = [UIColor clearColor];

    }
    return _logTable;
}

- (UILabel *)currentLogLabel{
    if (!_currentLogLabel) {
        _currentLogLabel = [UILabel new];
        _currentLogLabel.frame = CGRectMake(0, 0, MainScreen_W, 20);
        _currentLogLabel.textColor = [UIColor whiteColor];
        _currentLogLabel.font = [UIFont systemFontOfSize:13];
        _currentLogLabel.numberOfLines = 0;
        _currentLogLabel.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(updateLogStyle:)];
        [_currentLogLabel addGestureRecognizer:tap];
    }
    return _currentLogLabel;
}

- (NSMutableArray <NSString *>*)logDataArray{
    if (!_logDataArray) {
        _logDataArray = [NSMutableArray new];
    }
    return _logDataArray;
}

@end

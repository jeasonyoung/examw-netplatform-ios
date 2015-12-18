//
//  VitamioPlayerViewController.m
//  NetSchool
//
//  Created by jeasonyoung on 15/12/11.
//  Copyright © 2015年 TalkWeb. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

#import "VitamioPlayerViewController.h"
#import "VitamioPlayerView.h"
#import "PlayerTool.h"
#import "Vitamio.h"
#import "AppDelegate.h"
#import "PlayRecord.h"
#import "DownloadSinglecase.h"

//
typedef NS_ENUM(NSInteger,eMoveDirection){
    kMoveDirectionNone = 0x00,
    kMoveDirectionUp = 0x01,
    kMoveDirectionDown = 0x02,
    kMoveDirectionRight = 0x03,
    kMoveDirectionLeft = 0x04
};
//
CGFloat const gesture_minimum_translation = 1.0;
//
@interface VitamioPlayerViewController ()<PlayerToolDelegate,VMediaPlayerDelegate>{
    //播放器
    VMediaPlayer *_player;
    //播放器View
    VitamioPlayerView *_playerView;
    //播放控制工具栏
    PlayerTool *_tool;
   
    //总时间/播放时间(毫秒)
    long _total,_time;
    //播放进度
    float _progressValue;
    //同步播放进度定时器
    NSTimer *_syncSeekTime;
    
    
    //是否缓冲视频
    BOOL _isBufCache;
    
    //播放速度
    float _mRestoreAfterPlayRate;
    //系统音量
    float _volume;
    //音量控制
    UISlider *_volumeViewSlider;
    //手势方向
    eMoveDirection _direction;
}
//是否显示控制工具
@property(nonatomic)BOOL isUnShow;
@end

//Vitamio播放器控制器实现
@implementation VitamioPlayerViewController

#pragma mark -初始化函数
-(id)initWithParameters:(id)parameters{
    if(self = [super initWithParameters:parameters]){
        //设置标题
        [self.navigationItem setNewTitle:parameters[@"name"]];
        //设置返回按钮
        [self.navigationItem setBackItemWithTarget:self title:nil action:@selector(playBack) image:@"back.png"];
        //设置播放速率
        _mRestoreAfterPlayRate = 1.0f;
    }
    return self;
}

#pragma mark -控制条是否显示设置
-(void)setIsUnShow:(BOOL)isUnShow{
    _isUnShow = isUnShow;
    [UIView animateWithDuration:.5 animations:^{
        if(isUnShow){//不显示
            _tool.alpha = 0;
            _tool.transform = CGAffineTransformMakeTranslation(0, CGRectGetHeight(_tool.frame));
            [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
            self.navigationController.navigationBar.alpha = 0;
        }else{//显示
            _tool.alpha = 1;
            _tool.transform = CGAffineTransformIdentity;
            [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
            self.navigationController.navigationBar.alpha = 1;
        }
    }];
}

#pragma mark -加载UI
- (void)viewDidLoad {
    [super viewDidLoad];
    //初始化播放View
    _playerView = [[VitamioPlayerView alloc] initWithFrame:self.view.frame];
    _playerView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    //初始化播放工具
    _tool = [PlayerTool new];
    _tool.delegate = self;
    _tool.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    //添加到主界面
    [self.view addSubview:_playerView];
    [self.view addSubview:_tool];
    
    //播放时不要锁屏
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    //初始化播放器
    if(!_player){
        _player = [VMediaPlayer sharedInstance];
        [_player setupPlayerWithCarrierView:_playerView withDelegate:self];
        [self setupObservers];
    }
    //本地播放
    NSString *localVideoUrl = [[DownloadSinglecase sharedDownloadSinglecase].videoFiles
                                stringByAppendingPathComponent:_parameters[@"videoUrl"]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:localVideoUrl]){
        NSLog(@"播放地址:%@", localVideoUrl);
        //本地播放
        [_player setDataSource:[NSURL URLWithString:localVideoUrl]];
    }else{
        NSLog(@"播放地址:%@", _parameters[@"videoUrl"]);
        //网络播放
        [_player setDataSource:[NSURL URLWithString:_parameters[@"videoUrl"]]];
    }
    //播放器异步缓冲
    [_player prepareAsync];
    //添加手势
    [self addGestureRecognizer];
}

#pragma mark -安装观察者
-(void)setupObservers{
    //通知中心
    NSNotificationCenter *def = [NSNotificationCenter defaultCenter];
    //添加进入前台通知
    [def addObserver:self
            selector:@selector(applicationDidEnterForeground:)
                name:UIApplicationDidBecomeActiveNotification
              object:[UIApplication sharedApplication]];
    //添加进入后台通知
    [def addObserver:self
            selector:@selector(applicationDidEnterBackground:)
                name:UIApplicationWillResignActiveNotification
              object:[UIApplication sharedApplication]];
    //音量控制
    NSError *error;
    [[AVAudioSession sharedInstance] setActive:YES error:&error];
    [def addObserver:self
            selector:@selector(applicationDidVolumeChanged:)
                name:@"AVSystemController_SystemVolumeDidChangeNotification"
              object:nil];
}

#pragma mark -进入前台
-(void)applicationDidEnterForeground:(NSNotification *)notification{
    NSLog(@"进入前台...");
    if(_player){
        [_player setVideoShown:YES];
        if(![_player isPlaying]){
            //播放
            [self play];
        }
    }
}

#pragma mark -进入后台
-(void)applicationDidEnterBackground:(NSNotification *)notification{
    NSLog(@"进入后台...");
    if(_player && [_player isPlaying]){
        //暂停
        [self pause];
        //
        [_player setVideoShown:NO];
    }
}

#pragma mark -外部音量控制
-(void)applicationDidVolumeChanged:(NSNotification *)notification{
    NSLog(@"外部音量调节...");
    if(_volumeViewSlider){
        _volume = _volumeViewSlider.value;
    }
}

#pragma mark -卸载观察者
-(void)dealloc{
    //卸载播放器
    [_player unSetupPlayer];
    //卸载通知
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -内存告警
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark -添加手势处理
-(void)addGestureRecognizer{
    //初始化拍击手势处理
    UITapGestureRecognizer *singleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                       action:@selector(handleSingleTapFrom)];
    //设置单击手势
    singleRecognizer.numberOfTapsRequired = 1;//单击
    //注册手势到界面
    [_playerView addGestureRecognizer:singleRecognizer];
    
    //初始化拖动手势处理
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self
                                                                                          action:@selector(handlePanGestures:)];
    //无论最大还是最小都只允许一个手指
    panGestureRecognizer.minimumNumberOfTouches = 1;
    panGestureRecognizer.maximumNumberOfTouches = 1;
    //注册手势到界面
    [_playerView addGestureRecognizer:panGestureRecognizer];
    
    //系统音量控制
    if(!_volumeViewSlider){
        MPVolumeView *volumeView = [[MPVolumeView alloc] init];
        for(UIView *view in [volumeView subviews]){
            if([view.class.description isEqualToString:@"MPVolumeSlider"]){
                _volumeViewSlider = (UISlider *)view;
                break;
            }
        }
        //获取当前音量
        if(_volumeViewSlider){
            _volume = _volumeViewSlider.value;
        }
    }
}

#pragma mark -单击手势
-(void)handleSingleTapFrom{
    self.isUnShow = !_isUnShow;
}

#pragma mark -声音和进度手势
-(void)handlePanGestures:(UIPanGestureRecognizer *)recognizer{
    CGPoint translatedPoint = [recognizer translationInView:self.view];
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:{
            NSLog(@"start...");
            _direction = kMoveDirectionNone;
            break;
        }
        case UIGestureRecognizerStateChanged:{
            NSLog(@"moving...");
            _direction = [self determineCameraDirectionIfNeeded:translatedPoint];
            //用户的手势指示的方向移动
            switch(_direction){
                case kMoveDirectionDown:{
                    NSLog(@"start moving down...");
                    [self stateChangedVoiceDirection:(translatedPoint.y/DeviceH)];
                    break;
                }
                case kMoveDirectionUp:{
                    NSLog(@"start moving up...");
                    [self stateChangedVoiceDirection:(translatedPoint.y/DeviceH)];
                    break;
                }
                case kMoveDirectionRight:{
                    if(!_isBufCache){
                        NSLog(@"start moving right...");
                        if(self.isUnShow)self.isUnShow = NO;
                        [self beginDragging];
                        [self stateChangedProgressDirection:(translatedPoint.x/DeviceW)];
                    }
                    break;
                }
                case kMoveDirectionLeft:{
                    if(!_isBufCache){
                        NSLog(@"start moving left...");
                        if(self.isUnShow)self.isUnShow = NO;
                        [self beginDragging];
                        [self stateChangedProgressDirection:(translatedPoint.x/DeviceW)];
                    }
                    break;
                }
                default:break;
            }
            break;
        }
        case UIGestureRecognizerStateEnded:{
            NSLog(@"stop...");
            [recognizer setTranslation:CGPointMake(0, 0) inView:self.view];
            switch(_direction){
                case kMoveDirectionDown:{
                    NSLog(@"end moving down...");
                    [self stateEndedVoiceDirection];
                    break;
                }
                case kMoveDirectionUp:{
                    NSLog(@"end moving up...");
                    [self stateEndedVoiceDirection];
                    break;
                }
                case kMoveDirectionRight:{
                    if(!_isBufCache){
                        NSLog(@"end moving right...");
                        [self stateEndedProgressDirection];
                    }
                    break;
                }
                case kMoveDirectionLeft:{
                    if(!_isBufCache){
                        NSLog(@"end moving left...");
                        [self stateEndedProgressDirection];
                    }
                    break;
                }
                default:break;
            }
            break;
        }
        default:break;
    }
}

//计算方向
-(eMoveDirection)determineCameraDirectionIfNeeded:(CGPoint)translation{
    if(_direction != kMoveDirectionNone) return _direction;
    if(fabs(translation.x) > gesture_minimum_translation){//横向
        BOOL gestureHorizontal = NO;
        if(translation.y == 0){
            gestureHorizontal = YES;
        }else{
            gestureHorizontal = fabs(translation.x/translation.y) > 1;
        }
        if(gestureHorizontal){
            if(translation.x > 0)
                return kMoveDirectionRight;
            else
                return kMoveDirectionLeft;
        }
    }else if(fabs(translation.y) > gesture_minimum_translation){//纵向
        BOOL gestureVertical = NO;
        if(translation.x == 0){
            gestureVertical = YES;
        }else{
            gestureVertical = fabs(translation.y/translation.x) > 1;
        }
        if(gestureVertical){
            if(translation.y > 0)
                return kMoveDirectionDown;
            else
                return kMoveDirectionUp;
        }
    }
    return _direction;
}

//调节音量
-(void)stateChangedVoiceDirection:(CGFloat)value{
    if(_volumeViewSlider){
        _volume = _volumeViewSlider.value;
        CGFloat v = fabs(_volume - value);
        if(v < 0)
            v = 0.f;
        else if(v > 1)
            v = 1.0f;
        
        [_volumeViewSlider setValue:v animated:YES];
    }
}

//调节音量完成
-(void)stateEndedVoiceDirection{
    _volume = _volumeViewSlider.value;
}

//设置播放进度条
-(void)stateChangedProgressDirection:(CGFloat)value{
    _tool.scrubber.value += value;
    [self dragging];
}

//设置实际播放进度
-(void)stateEndedProgressDirection{
    [self endDraging];
}

#pragma mark -退出播放
-(void)playBack{
    //暂停播放
    [self pause];
    //停止播放进度刷新
    [_syncSeekTime invalidate];
    _syncSeekTime = nil;
    
    //横屏播放恢复竖屏
    AppDelegate *app = [UIApplication sharedApplication].delegate;
    app.allowRotation = NO;
    if([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]){
        SEL selector = @selector(setOrientation:);
        NSMethodSignature *signature = [UIDevice instanceMethodSignatureForSelector:selector];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val = UIInterfaceOrientationPortrait;
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
    //播放器资源收回
    if(_player){
        //异步处理上传学习记录
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
            @try {
                //更新播放进度
                [PlayRecord saveRecod:_parameters seekToTime:(_time/1000)];
                BOOL status = NO;
                if(labs(_time - _total) < .1){
                    status = YES;
                }
                //主线程更新
                dispatch_async(dispatch_get_main_queue(), ^{
                    @try {
                        [app updateLearingRecord:_parameters[@"id"] status:status];
                    }
                    @catch (NSException *ex) {
                        NSLog(@"上传学习进度异常:%@", ex.description);
                    }
                    @try {
                        //重置播放器
                        [_player reset];
                    }
                    @catch (NSException *ex) {
                        NSLog(@"关闭播放器异常:%@", ex.description);
                    }
                    
                });
            }
            @catch (NSException *e) {
                NSLog(@"更新播放进度异常:%@", e.description);
            }
        });
    }
    //关闭控制器
    [self dismissViewController];
}

#pragma mark -播放进度/总时长
-(NSString *)convertMovieTimeToText:(CGFloat)time{
    int m = (int)(time/60);
    int s = (int)((time/60 - m) * 60);
    return [NSString stringWithFormat:@"%02d:%02d",m,s];
}

#pragma mark -更新播放进度
-(void)syncPlayProgress{
    if(_isBufCache)return;
    if(_player && (_time < _total) > 0){
        //当前播放
        _time = [_player getCurrentPosition];
        //更新播放时间
        [_tool.leftDate setText:[self convertMovieTimeToText:(_time/1000.0f)]];
        //播放进度
        _progressValue = ((CGFloat)_time / _total);
        //更新播放进度
        [_tool.scrubber setValue:_progressValue animated:YES];
        //NSLog(@"更新播放进度[%ld/%ld]=>%f", _time,_total,_progressValue);
    }
}

#pragma mark VMediaPlayerDelegate

/**
 * Called when the player prepared.
 *
 * @param player The shared media player instance.
 * @param arg Not use.
 */
-(void)mediaPlayer:(VMediaPlayer *)player didPrepared:(id)arg{
    //视频长度
    _total = [player getDuration];
    //异步加载播放记录数据
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @try {
            NSArray *records = [PlayRecord readRecod];
            for(PlayRecord *record in records){
                if([record.sid isEqualToString:_parameters[@"id"]]){
                    _time = [record.seekToTime floatValue] * 1000;
                    break;
                }
            }
        }
        @catch (NSException *ex) {
            NSLog(@"加载播放记录数据异常:%@",ex.description);
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if(labs(_time - _total) <.1){
                _time = 0;
                [self.view makeToast:@"课程已学习完，已调到开头"];
            }else{
                [self.view makeToast:[NSString stringWithFormat:@"已跳到:%@",[self convertMovieTimeToText:_time]]];
            }
            //开始播放
            [self play];
            //触发更新播放进度
            _syncSeekTime = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                             target:self
                                                           selector:@selector(syncPlayProgress)
                                                           userInfo:nil
                                                            repeats:YES];
        });
    });
}

/**
 * Called when the player playback completed.
 *
 * @param player The shared media player instance.
 * @param arg Not use.
 */
-(void)mediaPlayer:(VMediaPlayer *)player playbackComplete:(id)arg{
    NSLog(@"播放完毕");
    //播放完毕，暂停放器
    [self pause];
}

/**
 * Called when the player have error occur.
 *
 * @param player The shared media player instance.
 * @param arg Contain the detail error information.
 */
-(void)mediaPlayer:(VMediaPlayer *)player error:(id)arg{
    //播放发生错误
    NSLog(@"播放发生错误:%@",[arg class]);
    [self.view makeToast:@"视频已不存在!"];
    
    [NSThread sleepForTimeInterval:2.0f];
    [self playBack];
}

//-缓冲开始
-(void)mediaPlayer:(VMediaPlayer *)player bufferingStart:(id)arg{
    NSLog(@"开始缓冲...");
    _isBufCache = YES;
    _tool.leftDate.text = @"0";
    _tool.rightDate.text = @"/100";
    _tool.progress.progress = 0.f;
}

//-缓冲过程中
-(void)mediaPlayer:(VMediaPlayer *)player bufferingUpdate:(id)arg{
    int value = [((NSNumber *)arg) intValue];
    NSLog(@"正在缓冲....%d%%", value);
    [_tool.leftDate setText:[NSString stringWithFormat:@"%d", value]];
    [_tool.progress setProgress:(CGFloat)(value /100.0) animated:YES];
}

//-缓冲完成
-(void)mediaPlayer:(VMediaPlayer *)player bufferingEnd:(id)arg{
    NSLog(@"缓冲完成...");
    //设置播放时间
    _tool.leftDate.text = [self convertMovieTimeToText:(_time/1000.0f)];
    NSString *totalTimeText = [self convertMovieTimeToText:(CGFloat)(_total/1000.0f)];
    //设置播放时长
    [_tool.rightDate setText:[NSString stringWithFormat:@"/%@",totalTimeText]];
    //缓存完成
    _isBufCache = NO;
}


#pragma mark PlayerToolDelegate

#pragma mark -播放
-(void)play{
    //播放状态
    _tool.play.selected = YES;
    if(_player && ![_player isPlaying]){
        //播放位置
        if(_time > 0){
            [_player seekTo:_time];
        }
        //播放
        [_player start];
    }
}

#pragma mark -暂停
-(void)pause{
    //暂停状态
    _tool.play.selected = NO;
    if(_player && [_player isPlaying]){
        //暂停
        [_player pause];
        //暂停位置
        _time = [_player getCurrentPosition];
    }
}

#pragma mark -开始滑动
-(void)beginDragging{
    NSLog(@"beginDragging...");
    //暂停播放
    [self pause];
}

#pragma mark -滑动中
-(void)dragging{
    NSLog(@"dragging...");
    _progressValue = _tool.scrubber.value;
    if(_total > 0){
        CGFloat current_time = (_total * _progressValue)/1000.0f;
        [_tool.leftDate setText:[self convertMovieTimeToText:current_time]];
    }
}

#pragma mark -结束滑动
-(void)endDraging{
    NSLog(@"endDraging...");
    _time = (long)(_total * _progressValue);
    //继续播放
    [self play];
}

#pragma mark -播放速度
-(void)speedVideo:(CGFloat)rate{
    if(_player && rate > 0){
        [_player setPlaybackSpeed:rate];
    }
}

@end
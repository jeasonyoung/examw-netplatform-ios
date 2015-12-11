//
//  VitamioPlayerViewController.m
//  NetSchool
//
//  Created by jeasonyoung on 15/12/11.
//  Copyright © 2015年 TalkWeb. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

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
    
    //id _mTimeObserver;
    VitamioPlayerView *_playerView;
    PlayerTool *_tool;
    //float _mRestoreAfterScrubbingRate;
    float _mRestoreAfterPlayRate;
    //BOOL _isSeeking;
    //BOOL _seekToZeroBeforePlay;
    //BOOL _isPlayBack;
    
    float _progressValue;
    float _volume;
    double _time;
    
    UISlider *_volumeViewSlider;
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
    }
//    //本地播放
//    NSString *localVideoUrl = [[DownloadSinglecase sharedDownloadSinglecase].videoFiles
//                                stringByAppendingPathComponent:_parameters[@"videoUrl"]];
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    if([fileManager fileExistsAtPath:localVideoUrl]){
//        NSLog(@"播放地址:%@", localVideoUrl);
//        //本地播放
//        [_player setDataSource:[NSURL URLWithString:localVideoUrl]];
//    }else{
//        NSLog(@"播放地址:%@", _parameters[@"videoUrl"]);
//        //网络播放
//        [_player setDataSource:[NSURL URLWithString:_parameters[@"videoUrl"]]];
//    }
    [_player setDataSource:[NSURL URLWithString:@"http://v.dalischool.com:8091/lxzkqjh1.flv"]];
    //播放器异步缓冲
    [_player prepareAsync];
    //添加手势
    [self addGestureRecognizer];
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
    if(!_volumeViewSlider){
        MPVolumeView *volumeView = [MPVolumeView new];
        for(UIView *view in [volumeView subviews]){
            if([view.class.description isEqualToString:@"MPVolumeSlider"]){
                _volumeViewSlider = (UISlider *)view;
                break;
            }
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
            _volume = [ToolSingleton getInstance].volume;
            break;
        }
        case UIGestureRecognizerStateChanged:{
            NSLog(@"moving...");
            _direction = [self determineCameraDirectionIfNeeded:translatedPoint];
            //用户的手势指示的方向移动
            switch(_direction){
                case kMoveDirectionDown:{
                    NSLog(@"start moving down...");
                    [self stateChangedVoiceDirection:(_volume - translatedPoint.y/DeviceH)];
                    break;
                }
                case kMoveDirectionUp:{
                    NSLog(@"start moving up...");
                    [self stateChangedVoiceDirection:(_volume - translatedPoint.y/DeviceH)];
                    break;
                }
                case kMoveDirectionRight:{
                    NSLog(@"start moving right...");
//                    if(!_mRestoreAfterScrubbingRate){
//                        self.isUnShow = NO;
//                        [self beginDragging];
//                    }
                    [self stateChangedProgressDirection:(_progressValue + translatedPoint.x/DeviceW)];
                    break;
                }
                case kMoveDirectionLeft:{
                    NSLog(@"start moving left...");
//                    if(!_mRestoreAfterScrubbingRate){
//                        self.isUnShow = NO;
//                        [self beginDragging];
//                    }
                    [self stateChangedProgressDirection:(_progressValue + translatedPoint.x/DeviceW)];
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
                    NSLog(@"end moving right...");
                    [self stateEndedProgressDirection];
                }
                case kMoveDirectionLeft:{
                    NSLog(@"end moving left...");
                    [self stateEndedProgressDirection];
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

//设置音量条
-(void)stateChangedVoiceDirection:(CGFloat)value{
    _volumeViewSlider.value = value;
}

//设置实现音量条
-(void)stateEndedVoiceDirection{
    _volume = _volumeViewSlider.value;
}

//设置播放进度条
-(void)stateChangedProgressDirection:(CGFloat)value{
   _tool.scrubber.value = value;
}

//设置实际播放进度
-(void)stateEndedProgressDirection{
    _progressValue = _tool.scrubber.value;
    [self endDraging];
}


//-(void)syncScrubber{
//    
//}
//
//-(void)disableScrubber{
//    
//}

#pragma mark -退出播放
-(void)playBack{
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
        //视频长度
        long total = [_player getDuration]/1000;
        _time = [_player getCurrentPosition]/1000;
        //异步处理上传学习记录
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
            @try {
                //更新播放进度
                [PlayRecord saveRecod:_parameters seekToTime:_time];
                BOOL status = NO;
                if(fabs(_time - total) < .1){
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
                        if(_player.isPlaying)[_player reset];
                        //取消播放器注册
                        [_player unSetupPlayer];
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

-(void)syncPlayPauseButtons{
    
}

-(void)initScrubberTimer{
    
}

-(void)enableScrubber{
    
}

-(void)enablePlayerButtons{
    
}

#pragma mark -播放位置
-(void)seekToTime:(void(^)())seekToTime{
    if(_player){
        CGFloat time = 0;
        long total = [_player getDuration]/1000;
        NSArray *records = [PlayRecord readRecod];
        for(PlayRecord *record in records){
            if([record.sid isEqualToString:_parameters[@"id"]]){
                time = [record.seekToTime floatValue];
                if(fabs(time - total) < .1){
                    time = 0.f;
                    [self.view makeToast:@"课程已学习完，已调到开头"];
                }else{
                    [self.view makeToast:[NSString stringWithFormat:@"已跳到:%@",[self convertMovieTimeToText:time]]];
                }
                break;
            }
        }
        //跳转
        [_player seekTo:(time * 1000)];
    }
}

#pragma mark -播放进度/总时长
-(NSString *)convertMovieTimeToText:(CGFloat)time{
    int m = (int)(time/60);
    int s = (int)((time/60 - m) * 60);
    return [NSString stringWithFormat:@"%02d:%02d",m,s];
}

#pragma mark -计算缓冲总进度
-(NSTimeInterval)availableDuration{
    ///TODO:
    return 0;
}

#pragma mark VMediaPlayerDelegate

/**
 * Called when the player prepared.
 *
 * @param player The shared media player instance.
 * @param arg Not use.
 */
-(void)mediaPlayer:(VMediaPlayer *)player didPrepared:(id)arg{
    //当播放器准备完成,开始播放
    [player start];
}

/**
 * Called when the player playback completed.
 *
 * @param player The shared media player instance.
 * @param arg Not use.
 */
-(void)mediaPlayer:(VMediaPlayer *)player playbackComplete:(id)arg{
    //播放完毕，重置播放器
    [player reset];
}

/**
 * Called when the player have error occur.
 *
 * @param player The shared media player instance.
 * @param arg Contain the detail error information.
 */
-(void)mediaPlayer:(VMediaPlayer *)player error:(id)arg{
    //播放发生错误
    NSLog(@"播放发生错误:%@",arg);
    
}


#pragma mark PlayerToolDelegate

#pragma mark -播放
-(void)play{
    if(_player && ![_player isPlaying]){
        [_player start];
    }
}

#pragma mark -暂停
-(void)pause{
    if(_player && [_player isPlaying]){
        [_player pause];
    }
}

#pragma mark -开始滑动
-(void)beginDragging{
    ///TODO:
    NSLog(@"beginDragging...");
}

#pragma mark -滑动中
-(void)dragging{
    ///TODO:
    NSLog(@"dragging...");
}

#pragma mark -结束滑动
-(void)endDraging{
    ///TODO:
    NSLog(@"endDraging...");
}

#pragma mark -播放速度
-(void)speedVideo:(CGFloat)rate{
    if(_player && rate > 0){
        [_player setPlaybackSpeed:rate];
    }
}

@end

//
//  SongControl.m
//  01-本地歌曲
//
//  Created by qingyun on 16/5/07.
//  Copyright © 2016年 GXT. All rights reserved.
//

#import "SongControl.h"
#import "SongMode.h"
#import "SongList.h"
#import "parLrc.h"

#import <MediaPlayer/MediaPlayer.h>

//#import "SecondViewController.h"

@interface SongControl ()<AVAudioPlayerDelegate>

@property(nonatomic,strong)NSTimer *timer;//定时器
@end

@implementation SongControl

//初始化播放器
+(instancetype)shareSongCtrHandel{
    static SongControl *handel;
    static dispatch_once_t once;
    dispatch_once(&once , ^{
        handel=[[SongControl alloc] init];
        //初始化currentIndex下标
        handel.currentIndex=-1;
        [handel setSeesion];
    });
    return handel;
}
//设置会话对象
-(void)setSeesion{
    //获取会话
    AVAudioSession *seesion=[AVAudioSession sharedInstance];//系统类方法
    //设置策略依照播放轨迹
    [seesion setCategory:AVAudioSessionCategoryPlayback error:nil];
    [seesion setActive:YES error:nil];
}
//歌曲长度
-(NSTimeInterval)durationTime{
    return _player.duration;
}
//代理
-(void)setDelegate:(id<PlayerPRO>)delegate{
    if (delegate==nil) {
        //暂停timer
        self.timer.fireDate=[NSDate distantFuture];
    }else{
        //启动timer
        self.timer.fireDate=[NSDate distantPast];
    }
    _delegate=delegate;
}

-(void)updateSelectIndex{
    NSInteger tempIndex=-1;
    //当前播放时间
    NSTimeInterval currentTime=_player.currentTime;
    NSArray *keyTime=_lrcMode.keyArr;
    for (NSNumber *number in keyTime) {
        //当前时间和歌词时间做对比
        //如果当前时间大于歌词时间++
        //当前时间如果小于歌词时间break，跳出循环体
        if (number.floatValue<=currentTime) {
            tempIndex++;
        }else{
            break;
        }
    }
    if(self.delegate){
        if (tempIndex>-1) {
            //更新歌词
            [self.delegate updateLrcSelectIndex:tempIndex];
        }
    }
}

#pragma mark 获取当前播放时间，实时刷新进度
-(void)getCurrentTime{
    
    if(self.delegate){
        
        //回调当前播放时间，实时更新进度
        [self.delegate sendCurrentTime:_player.currentTime];
        //更新歌词
        [self updateSelectIndex];
    }
}

#pragma mark 通知播放完成
-(void)notFicationSongUpate{
    if (self.delegate) {
        [self.delegate notficationSongReload];
    }
}

-(NSTimer *)timer{
    if (_timer) {
        return _timer;
    }
    _timer=[NSTimer scheduledTimerWithTimeInterval:.3 target:self selector:@selector(getCurrentTime) userInfo:nil repeats:YES];
    return _timer;
}
//设置currentTime
-(void)setCurrentTime:(NSTimeInterval)currentTime{
    _player.currentTime=currentTime;
}

//设置播放暂停
-(void)setPlayOrPause:(BOOL)playOrPause{
    if (playOrPause) {
        //播放
        if ([_player play]) {
//            SecondViewController *sec = [SecondViewController shareSongCtrHandel];
//            sec.player =nil;
        }
        
        self.timer.fireDate=[NSDate distantPast];
    }else{
        //暂停
        [_player pause];
        self.timer.fireDate=[NSDate distantFuture];
    }
    _playOrPause=playOrPause;
}


//设置播放下标 set
-(void)setCurrentIndex:(NSInteger)currentIndex{
    
    if (currentIndex==-1) {
        //首次初始化赋值
        _currentIndex=currentIndex;
        return;
    }
    
    if (_currentIndex==currentIndex) {
        return;
    }
    
    //获取播放的mode
    SongMode *mode=[SongList shareHandel].songArr[currentIndex];
    
    //歌词解析
    _lrcMode=[parLrc initWithPath:[[NSBundle mainBundle] URLForResource:mode.kName withExtension:@"lrc"]];
    
    //歌曲的url
    NSURL *songUrl=[[NSBundle mainBundle]URLForResource:mode.kName withExtension:mode.kType];
    //初始化播放器
    _player=[[AVAudioPlayer alloc] initWithContentsOfURL:songUrl error:nil];
    //设置代理
    _player.delegate=self;
    //初始化
    [_player prepareToPlay];
    //播放
    self.playOrPause=YES;

    
    _currentIndex=currentIndex;
}

-(BOOL)isPlaying{
    return _player.isPlaying;
}
//上一首
-(void)previousSong{
    if (self.currentIndex==0) {
        self.currentIndex=[SongList shareHandel].songArr.count-1;
    }else{
        self.currentIndex--;
    }
    [self notFicationSongUpate];
}
//下一首
-(void)nextSong{
    if(self.currentIndex==[SongList shareHandel].songArr.count-1){
        self.currentIndex=0;
    }else{
        self.currentIndex++;
    }
    [self notFicationSongUpate];
}
//
#pragma mark - Audio 代理方法
-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [self nextSong];
    //刷新UI
    [self notFicationSongUpate];
}


@end

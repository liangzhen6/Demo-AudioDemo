//
//  AudioMaskManger.m
//  AudioDemo
//
//  Created by shenzhenshihua on 2017/4/12.
//  Copyright © 2017年 shenzhenshihua. All rights reserved.
//

#import "AudioMaskManger.h"
#import "AudioMaskHeader.h"
#import "AudioMask.h"
#import "RecordBtnView.h"
#import "AudioModel.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

#define MaxTime 600   //最长多少毫秒 (现在是60秒)

@interface AudioMaskManger ()

@property(nonatomic,strong)NSURL * url;
@property(nonatomic,strong)AVAudioRecorder * recoder;
@property(nonatomic,strong)NSTimer * timer;
@property(nonatomic,assign)NSInteger maxTime;
@property(nonatomic,assign)AudioMaskState state;
@property(nonatomic,getter=isTimerRun)BOOL timerRun;
@property(nonatomic,strong)AudioModel * audioModel;
@property(nonatomic,strong)AudioMask * mask;


@end

@implementation AudioMaskManger

+ (id)audioMaskMangerWithAudioMask:(AudioMask *)mask recordBtnView:(RecordBtnView *)btnView mangerFinishBlock:(void(^)(AudioModel * model))magerFinishBlock {
    AudioMaskManger * manger = [[AudioMaskManger alloc] init];
    manger.magerFinishBlock = magerFinishBlock;
    manger.mask = mask;
//    __weak typeof (manger)mangerWeek = manger;
    __weak AudioMaskManger * mangerWeek = manger;
    [btnView setRecordBtnViewBlock:^(RecordBtnState state){
        [mangerWeek handleBtnViewState:state];
    }];
    
    return manger;
}

- (void)handleBtnViewState:(RecordBtnState)state {
    switch (state) {
        case 0:
        {//按下
            if (self.mask.state!=AudioMaskStateTooShort) {
                self.maxTime = MaxTime;
                self.state = AudioMaskStateRecording;
                [self startRecoder];
                if (self.recoder.prepareToRecord) {
                    BOOL ok =  [self.recoder record];
                    NSLog(@"%d",ok);
                    [self.mask updateState:AudioMaskStateRecording];
                    self.timer.fireDate = [NSDate distantPast];
                    self.timerRun = YES;
                }

            }
            
        }
            break;
        case 1:
        {//按下内部抬起
            self.state = AudioMaskStateNormal;
 /*
//            if (self.maxTime>MaxTime-MinTime) {
//        
//                [self deleateRecoder];
//                
//                [self.mask updateState:AudioMaskStateTooShort];
//
//                dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC));
//                
//                dispatch_after(delayTime, dispatch_get_main_queue(), ^{
//                    [self.mask updateState:AudioMaskStateNormal];
//                });
//                
//            }else{
//                
//                self.audioModel.timeLenth = [NSString stringWithFormat:@"%ld",(long)self.recoder.currentTime];
//                [self.recoder stop];
//                self.timer.fireDate = [NSDate distantFuture];
//                self.timerRun = NO;
//                [self.mask updateState:AudioMaskStateNormal];
//                self.recoder = nil;
//                if (self.magerFinishBlock) {
//                    self.magerFinishBlock(self.audioModel);
//                }
//            }*/
            NSLog(@"%f",self.recoder.currentTime);

            if (self.recoder.currentTime>1.0) {
            //正常
                self.audioModel.timeLenth = [NSString stringWithFormat:@"%ld",(long)self.recoder.currentTime];
                [self recoderFinish];
                [self.mask updateState:AudioMaskStateNormal];
                if (self.magerFinishBlock) {
                    self.magerFinishBlock(self.audioModel);
                }

            }else{
            //录音时间太短
                [self deleateRecoder];
                
                [self.mask updateState:AudioMaskStateTooShort];
                
                dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0/*延迟执行时间*/ * NSEC_PER_SEC));
                
                dispatch_after(delayTime, dispatch_get_main_queue(), ^{
                    [self.mask updateState:AudioMaskStateNormal];
                });
            
            }
            
        }
            break;
        case 2:
        {//按下外部抬起
            self.state = AudioMaskStateNormal;
            [self deleateRecoder];
            [self.mask updateState:AudioMaskStateNormal];

            
        }
            break;
        case 3:
        {//拖到外部
            if (self.isTimerRun) {//计时器在记时的时候才有用
                [self.mask updateState:AudioMaskStateCancel];
            }            
        }
            break;
        case 4:
        {//拖到内部
            if (self.isTimerRun) {//计时器在记时的时候才有用
                if (self.state==AudioMaskStateCountDown) {
                    [self.mask updateState:AudioMaskStateCountDown];
                }else{
                    [self.mask updateState:AudioMaskStateRecording];
                }
            }
            
        }
            break;

            
        default:
            break;
    }

}


/**
 删除本次录音处理
 */
- (void)deleateRecoder {

    [self.recoder deleteRecording];

    [self recoderFinish];
    
    self.audioModel = nil;

}

- (void)recoderFinish {
    [self.recoder stop];
    self.recoder = nil;
    self.timer.fireDate = [NSDate distantFuture];
    self.timerRun = NO;
}


- (NSURL*)url {
    
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * documentsDirectory = [paths objectAtIndex:0];
    //获取当前的时间戳 精确到毫秒
    //        UInt64 recordTime = [[NSDate date] timeIntervalSince1970]*1000;
    
    UInt64 recordTime = [[NSDate date] timeIntervalSince1970];
    NSString * str = [NSString stringWithFormat:@"%llurecord.aac",recordTime];
    NSString * path = [documentsDirectory stringByAppendingPathComponent:str];
    _url= [NSURL fileURLWithPath:path];
    

    return _url;
    
}


-(void)startRecoder {
    
    //激活AVAudioSession
    
    NSError * error =nil;
    
    AVAudioSession * session = [AVAudioSession sharedInstance];
    
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    
    if(session !=nil) {
        
        [session setActive:YES error:nil];
        
    }else{
        
        NSLog(@"Session error = %@",error);
        
    }
    
    NSURL * url = self.url;
    
    self.audioModel = [[AudioModel alloc] init];
    self.audioModel.pathUrl = url;
    self.recoder= [[AVAudioRecorder alloc]initWithURL:url settings:[self setAudioRecorder] error:nil];
    
    // 开启音量检测
    self.recoder.meteringEnabled = YES;
    
    //    self.recoder.delegate = self;
    
}



- (NSMutableDictionary *)setAudioRecorder {
    
    // 录音设置
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    // 设置录音格式   AVFormatIDKey  == kAudioFormatMPEG4AAC
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    // 设置录音采样率   如：AVSampleRateKey == 8000 / 44100 / 96000 （影响音频质量）
    [recordSetting setValue:[NSNumber numberWithFloat:44100] forKey:AVSampleRateKey];
    // 设置通道的数目  1单声道  2立体声
    [recordSetting setValue:[NSNumber numberWithInt:2] forKey:AVNumberOfChannelsKey];
    // 线性采样位数  8， 16， 24， 32 默认是16
    [recordSetting setValue:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
    // 录音质量
    [recordSetting setValue:[NSNumber numberWithInt:AVAudioQualityHigh] forKey:AVEncoderAudioQualityKey];
    
    return recordSetting;
}


- (void)updateVoiceValue {
    
    [self.recoder updateMeters];
    CGFloat value = [self.recoder averagePowerForChannel:1]/2 + [self.recoder averagePowerForChannel:0]/2;
    NSLog(@"value=%f",value);
    
    if (value>-20) {
        value = -20;
    }else if (value<-60){
        value = -60;
    }
    
    CGFloat progress = (1.0/40.0)*(value+60.0);
    
    [self.mask updateVolume:progress];
    
    self.maxTime-=1;
    if (self.maxTime%10==0) {
        NSLog(@"====%ld",(long)self.maxTime);
        NSInteger currentTime = self.maxTime/10;
        if (currentTime<11) {
            self.state = AudioMaskStateCountDown;
            if (self.mask.state!=AudioMaskStateCancel) {
                [self.mask updateState:AudioMaskStateCountDown];
            }
            
            [self.mask updateRemainTime:currentTime];
            if (currentTime==0) {
                //最后到时间了直接发送
                [self.mask updateState:AudioMaskStateNormal];
                self.state = AudioMaskStateNormal;
                self.timer.fireDate = [NSDate distantFuture];
                self.timerRun = NO;
            }
        }
        
    }
    
}



- (NSTimer *)timer {
    if (_timer==nil) {
//        __weak typeof (self)ws = self;
        __weak AudioMaskManger * ws = self;
        _timer = [NSTimer scheduledTimerWithTimeInterval:.1 repeats:YES block:^(NSTimer * _Nonnull timer) {
            [ws updateVoiceValue];
        }];
        [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
        _timer.fireDate = [NSDate distantFuture];
        
    }
    return _timer;
}


- (void)dealloc {
    if ([_timer isValid]) {
        [_timer invalidate];
        _timer = nil;
    }
    
}

@end

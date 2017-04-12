//
//  ViewController.m
//  AudioDemo
//
//  Created by shenzhenshihua on 2017/3/24.
//  Copyright © 2017年 shenzhenshihua. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "AudioModel.h"
#import "AudioMask.h"
#import "AudioMaskHeader.h"
#import "RecordBtnView.h"
#import "AudioMaskManger.h"

@interface ViewController ()<AVAudioPlayerDelegate>

@property(nonatomic,strong)NSURL * url;

@property(nonatomic,strong)AVAudioRecorder * recoder;

@property(nonatomic,strong)AVAudioPlayer * player;

@property(nonatomic,strong)NSMutableArray * allPaths;

@property(nonatomic,strong)AudioModel * audioModel;

@property(nonatomic,strong)AudioMask * mask;

@property(nonatomic,strong)NSTimer * timer;

@property(nonatomic,assign)NSInteger maxTime;

@property(nonatomic,assign)AudioMaskState state;

@property(nonatomic,getter=isTimerRun)BOOL timerRun;

@property(nonatomic,strong)AudioMaskManger *manger;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    AudioMask * mask = [AudioMask audioMaskShowView:self.view];
    self.mask = mask;
    
    RecordBtnView * btnView = [[RecordBtnView alloc] initWithFrame:CGRectMake(40, self.view.bounds.size.height-60, self.view.bounds.size.width-80, 40)];
    [self.view addSubview:btnView];
    __weak ViewController * ws = self;
   AudioMaskManger *manger = [AudioMaskManger audioMaskMangerWithAudioMask:mask recordBtnView:btnView mangerFinishBlock:^(AudioModel *model) {
       [ws.allPaths addObject:model];
        NSLog(@"%@",model);
    }];
    self.manger = manger;
    
   
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sensorStateChange:) name:UIDeviceProximityStateDidChangeNotification object:nil];
    
    
//    [mask updateState:AudioMaskStateRecording];
//    [mask updateVolume:0.5];
    
//    [self startRecoder];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)sensorStateChange:(NSNotificationCenter *)notification {
    //如果此时手机靠近面部放在耳朵旁，那么声音将通过听筒输出，并将屏幕变暗（省电啊）
    if ([[UIDevice currentDevice] proximityState] == YES) {
        NSLog(@"听筒播放");
    
//        [self palyAction:nil];
        [_player stop];
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        [self.player play];
    }else{
        NSLog(@"扬声器播放");
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    }

}

/*

- (NSURL*)url {
    
//    if(_url==nil) {
    
        //在沙盒内创建这样一个文件，来存放录音文件
        
//        NSString*tempDir =NSTemporaryDirectory();
//        
//        NSString*urlPatch = [tempDir stringByAppendingString:@"record.caf"];
        
        NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString * documentsDirectory = [paths objectAtIndex:0];
        //获取当前的时间戳 精确到毫秒
//        UInt64 recordTime = [[NSDate date] timeIntervalSince1970]*1000;
        
        UInt64 recordTime = [[NSDate date] timeIntervalSince1970];
        NSString * str = [NSString stringWithFormat:@"%llurecord.aac",recordTime];
        
        NSString * path = [documentsDirectory stringByAppendingPathComponent:str];

        
        _url= [NSURL fileURLWithPath:path];
        
//    }
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
    
    
//    //设置AVAudioRecorder的setting属性
//    
//    NSDictionary*recoderSettings = [[NSDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithFloat:16000.0],AVSampleRateKey,[NSNumber numberWithInt:kAudioFormatAppleIMA4],AVFormatIDKey,[NSNumber numberWithInt:1],AVNumberOfChannelsKey,[NSNumber numberWithInt:AVAudioQualityMax],AVEncoderAudioQualityKey,nil];
    
    //初始化recodeer对象
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

- (IBAction)touchDownAction:(UIButton *)sender {
       NSLog(@"按下");
    self.maxTime = 150;
    
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


- (IBAction)touchUpInsideAction:(UIButton *)sender {
    NSLog(@"按下内部抬起");
    self.state = AudioMaskStateNormal;
    if (self.maxTime>130) {
        
        [self.recoder stop];
        [self.recoder deleteRecording];
        self.recoder = nil;
        self.timer.fireDate = [NSDate distantFuture];
        self.timerRun = NO;
        [self.mask updateState:AudioMaskStateTooShort];
        self.audioModel = nil;
                                                                               //延迟执行时间
        dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC));
        
        dispatch_after(delayTime, dispatch_get_main_queue(), ^{
            [self.mask updateState:AudioMaskStateNormal];
        });

        
    }else{

    self.audioModel.timeLenth = [NSString stringWithFormat:@"%ld",(long)self.recoder.currentTime];
     [self.recoder stop];
    self.timer.fireDate = [NSDate distantFuture];
    self.timerRun = NO;
    [self.mask updateState:AudioMaskStateNormal];

    [self.allPaths addObject:self.audioModel];
     NSLog(@"%f-----%f",self.recoder.currentTime,self.recoder.deviceCurrentTime);
     self.recoder = nil;
    }
}


- (IBAction)touchUpOutsideAction:(UIButton *)sender {
    NSLog(@"按下外部抬起");
    self.state = AudioMaskStateNormal;

    [self.recoder stop];
    [self.recoder deleteRecording];
    self.recoder = nil;
    self.timer.fireDate = [NSDate distantFuture];
    self.timerRun = NO;
    [self.mask updateState:AudioMaskStateNormal];
    
    self.audioModel = nil;
    
}

- (IBAction)touchDragExitAction:(UIButton *)sender {
    NSLog(@"拖到外部");
    if (self.isTimerRun) {//计时器在记时的时候才有用
        [self.mask updateState:AudioMaskStateCancel];
    }


}

- (IBAction)touchDragEnterAction:(UIButton *)sender {
//    self.state = AudioMaskStateRecording;

    NSLog(@"拖回内部");
    if (self.isTimerRun) {//计时器在记时的时候才有用
        if (self.state==AudioMaskStateCountDown) {
            [self.mask updateState:AudioMaskStateCountDown];
        }else{
            [self.mask updateState:AudioMaskStateRecording];
        }
    }
    
    
}

*/
- (IBAction)palyAction:(UIButton *)sender {
    
    
    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES]; //建议在播放之前设置yes，播放结束设置NO，这个功能是开启红外感应

    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    
    //默认情况下扬声器播放
    
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    [audioSession setActive:YES error:nil];
    

    
   BOOL isplay =  [self.player play];
    if (isplay) {
//       [[UIDevice currentDevice] setProximityMonitoringEnabled:YES]; //建议在播放之前设置yes，播放结束设置NO，这个功能是开启红外感应
    }
  NSLog(@"%d",isplay);

#pragma mark --但是代码写到这里，在播放录音的过程中，只能播放第一个所以每次播放完，要多播放的类进行释放在代理方法里面设置 步骤是先遵循AVAudioPlayerDelegate代理  设置_player.delegate = self;
    
}



- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    NSLog(@"%@---%d",player,flag);
}



/* if an error occurs while decoding it will be reported to the delegate. */
- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError * __nullable)error {
    NSLog(@"%@---%@",player,error);
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];

}



-(AVAudioPlayer*)player {
    
//    if(_player==nil) {
    if (!self.allPaths.count) {
        return nil;
    }
       AudioModel * model = [self.allPaths objectAtIndex:self.allPaths.count-1];
    
        _player= [[AVAudioPlayer alloc]initWithContentsOfURL:model.pathUrl error:nil];
        
        _player.volume = 1.0;
        
        _player.delegate = self;
        
//    }
    
    return _player;
    
}

/*
- (void)updateVoiceValue {
    
    [self.recoder updateMeters];
    CGFloat value = [self.recoder averagePowerForChannel:1]/2 + [self.recoder averagePowerForChannel:0]/2;
    NSLog(@"caocaocao=%f",value);

    if (value>-20) {
        value = -20;
    }else if (value<-60){
        value = -60;
    }
    
//    CGFloat progress = (1.0/160.0)*(value+160.0);
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
 __weak typeof (self)ws = self;
 _timer = [NSTimer scheduledTimerWithTimeInterval:.1 repeats:YES block:^(NSTimer * _Nonnull timer) {
 [ws updateVoiceValue];
 }];
 [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
 _timer.fireDate = [NSDate distantFuture];
 
 }
 
 return _timer;
 }
 */



- (NSMutableArray *)allPaths {
    if (_allPaths == nil) {
        _allPaths = [[NSMutableArray alloc] init];
    }
    return _allPaths;
}



- (void)dealloc {
//    if ([self.timer isValid]) {
//        [self.timer invalidate];
//        self.timer = nil;
//    }
//移除监听
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceProximityStateDidChangeNotification object:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

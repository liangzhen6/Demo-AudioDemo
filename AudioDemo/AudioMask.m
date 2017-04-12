//
//  AudioMask.m
//  AudioDemo
//
//  Created by shenzhenshihua on 2017/4/6.
//  Copyright © 2017年 shenzhenshihua. All rights reserved.
//

#import "AudioMask.h"

@interface AudioMask ()

@property(nonatomic,strong)UIImageView * shortAndCancelImageView;
@property(nonatomic,strong)UIImageView * smicrophoneImageView;
@property(nonatomic,strong)UIImageView * volumeImageView;
@property(nonatomic,strong)UILabel * textLabel;
@property(nonatomic,strong)UILabel * remainTimeLabel;
@property(nonatomic,strong)CAShapeLayer * maskLayer;

@end

@implementation AudioMask


+ (id)audioMaskShowView:(UIView *)view {
    AudioMask * audioMask = [[AudioMask alloc] initWithFrame:CGRectMake(0, 0, 150, 150)];
    audioMask.layer.cornerRadius = 10;
    audioMask.layer.masksToBounds = YES;
    audioMask.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    audioMask.center = view.center;
    [audioMask initView];
    [audioMask updateState:AudioMaskStateNormal];
    [view addSubview:audioMask];
    return audioMask;
}


- (void)initView {
    
    [self addSubview:self.shortAndCancelImageView];
    
    [self addSubview:self.textLabel];
    
    [self addSubview:self.smicrophoneImageView];

    [self addSubview:self.volumeImageView];
    
    [self addSubview:self.remainTimeLabel];

}

- (void)updateState:(AudioMaskState)state {
    self.state = state;
    self.hidden = NO;
    switch (state) {
        case 0:
        {//初始化状态
            self.hidden = YES;
        
        }
            break;
        case 1:
        {//录音中状态
            self.shortAndCancelImageView.hidden = YES;
            self.smicrophoneImageView.hidden = NO;
            self.volumeImageView.hidden = NO;
            self.remainTimeLabel.hidden = YES;
            self.textLabel.text = @"手指上滑，取消发送";
            self.textLabel.backgroundColor = [UIColor clearColor];
        }
            break;
        case 2:
        {//倒计时状态
            self.shortAndCancelImageView.hidden = YES;
            self.smicrophoneImageView.hidden = YES;
            self.volumeImageView.hidden = YES;
            self.remainTimeLabel.hidden = NO;
            self.textLabel.text = @"手指上滑，取消发送";
            self.textLabel.backgroundColor = [UIColor clearColor];
        }
            break;
        case 3:
        {// 太短状态
            self.shortAndCancelImageView.hidden = NO;
            self.smicrophoneImageView.hidden = YES;
            self.volumeImageView.hidden = YES;
            self.remainTimeLabel.hidden = YES;
            self.shortAndCancelImageView.image = [UIImage imageNamed:@"ic_record_too_short"];
            self.textLabel.text = @"说话时间太短";
            self.textLabel.backgroundColor = [UIColor clearColor];
            
        }
            break;
        case 4:
        {//取消状态
            self.shortAndCancelImageView.hidden = NO;
            self.smicrophoneImageView.hidden = YES;
            self.volumeImageView.hidden = YES;
            self.remainTimeLabel.hidden = YES;
            self.shortAndCancelImageView.image = [UIImage imageNamed:@"ic_release_to_cancel"];
            self.textLabel.text = @"松开手指，取消发送";
            self.textLabel.backgroundColor = [UIColor redColor];
        }
            break;
            
        default:
            break;
    }

}

- (void)updateVolume:(float)volume {
    
    if (self.state==AudioMaskStateRecording) {
//        int viewCount = ceil(fabs(volume)*10);
        int viewCount = fabs(volume)*10;

        if (viewCount == 0) {
            viewCount++;
        }
        if (viewCount > 9) {
            viewCount = 9;
        }
        
        if (_maskLayer == nil) {
            self.maskLayer = [[CAShapeLayer alloc] init];
            _maskLayer.backgroundColor = [UIColor whiteColor].CGColor;
        }
        
        CGFloat W = self.volumeImageView.bounds.size.width;
        CGFloat H = self.volumeImageView.bounds.size.height;

        
        CGFloat itemHeight = 3;
        CGFloat itemPadding = 3.5;
        CGFloat maskPadding = itemHeight*viewCount + (viewCount-1)*itemPadding;
//        NSLog(@"%f----%d",maskPadding,viewCount);
        UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(0, H - maskPadding, W, H)];
        _maskLayer.path = path.CGPath;
        self.volumeImageView.layer.mask = _maskLayer;
        
    }

}

- (void)updateRemainTime:(NSInteger)time {
    if (self.state==AudioMaskStateCountDown) {
        self.remainTimeLabel.text = [NSString stringWithFormat:@"%ld",(long)time];
    }
}



#pragma mark =========view=================
// 84  * 130   = 
- (UIImageView *)shortAndCancelImageView {
    if (_shortAndCancelImageView==nil) {
        _shortAndCancelImageView = [[UIImageView alloc] initWithFrame:CGRectMake(75-23, 30, 46, 70)];
//        _shortAndCancelImageView.backgroundColor = [UIColor redColor];
//        _shortAndCancelImageView.hidden = YES;
    }

    return _shortAndCancelImageView;
}


- (UILabel *)textLabel {
    if (_textLabel == nil) {
        _textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 130, 25)];
        _textLabel.textColor = [UIColor whiteColor];
        _textLabel.font = [UIFont systemFontOfSize:13];
        _textLabel.layer.cornerRadius = 2;
        _textLabel.layer.masksToBounds = YES;
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.center = CGPointMake(75, 130);
    }
    return _textLabel;
}


- (UIImageView *)smicrophoneImageView {
    if (_smicrophoneImageView==nil) {
        _smicrophoneImageView = [[UIImageView alloc] initWithFrame:CGRectMake(75-30, 30, 38, 60)];
        _smicrophoneImageView.image = [UIImage imageNamed:@"ic_record"];
    }
    return _smicrophoneImageView;
}
// 36 * 110
- (UIImageView *)volumeImageView {
    if (_volumeImageView==nil) {
        _volumeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(75+15, 35, 18, 55)];
        _volumeImageView.image = [UIImage imageNamed:@"ic_record_ripple"];
    }
    return _volumeImageView;
}


- (UILabel *)remainTimeLabel {
    if (_remainTimeLabel==nil) {
        _remainTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        _remainTimeLabel.font = [UIFont systemFontOfSize:90];
        _remainTimeLabel.textColor = [UIColor whiteColor];
        _remainTimeLabel.textAlignment = NSTextAlignmentCenter;
        _remainTimeLabel.center = CGPointMake(75, 60);
    }
    return _remainTimeLabel;
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

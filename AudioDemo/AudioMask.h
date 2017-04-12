//
//  AudioMask.h
//  AudioDemo
//
//  Created by shenzhenshihua on 2017/4/6.
//  Copyright © 2017年 shenzhenshihua. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AudioMaskHeader.h"
@interface AudioMask : UIView

@property(nonatomic,assign)AudioMaskState state;

+ (id)audioMaskShowView:(UIView *)view;

- (void)updateState:(AudioMaskState)state;

- (void)updateVolume:(float)volume;

- (void)updateRemainTime:(NSInteger)time;

@end

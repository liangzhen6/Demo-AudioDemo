//
//  RecordBtnView.h
//  AudioDemo
//
//  Created by shenzhenshihua on 2017/4/12.
//  Copyright © 2017年 shenzhenshihua. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AudioMaskHeader.h"

@interface RecordBtnView : UIView

@property(nonatomic,copy)void(^recordBtnViewBlock)(RecordBtnState state);

@end

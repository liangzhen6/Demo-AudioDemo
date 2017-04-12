//
//  AudioMaskManger.h
//  AudioDemo
//
//  Created by shenzhenshihua on 2017/4/12.
//  Copyright © 2017年 shenzhenshihua. All rights reserved.
//

#import <Foundation/Foundation.h>
@class AudioMask,RecordBtnView,AudioModel;
@interface AudioMaskManger : NSObject

@property(nonatomic,copy)void(^magerFinishBlock)(AudioModel * model);

+ (id)audioMaskMangerWithAudioMask:(AudioMask *)mask recordBtnView:(RecordBtnView *)btnView mangerFinishBlock:(void(^)(AudioModel * model))magerFinishBlock;

@end

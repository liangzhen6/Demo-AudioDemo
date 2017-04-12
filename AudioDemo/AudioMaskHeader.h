
//
//  AudioMaskHeader.h
//  AudioDemo
//
//  Created by liangzhen on 2017/4/9.
//  Copyright © 2017年 shenzhenshihua. All rights reserved.
//

#ifndef AudioMaskHeader_h
#define AudioMaskHeader_h

typedef NS_ENUM(NSUInteger, AudioMaskState) {
    AudioMaskStateNormal = 0,   ///< 初始化状态
    AudioMaskStateRecording,    ///< 录音中状态
    AudioMaskStateCountDown,    ///< 倒计时状态
    AudioMaskStateTooShort,     ///< 太短状态
    AudioMaskStateCancel,       ///< 取消状态
};



typedef NS_ENUM(NSUInteger, RecordBtnState) {
    RecordBtnStateTouchDown = 0,  ///<  按下
    RecordBtnStateTouchUpInside,  ///<  按下内部抬起
    RecordBtnStateTouchUpOutside, ///<  按下外部抬起
    RecordBtnStateTouchDragExit,  ///<  拖到外部
    RecordBtnStateTouchDragEnter, ///<  拖到内部
    
};


#endif /* AudioMaskHeader_h */

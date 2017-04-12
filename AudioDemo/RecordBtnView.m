//
//  RecordBtnView.m
//  AudioDemo
//
//  Created by shenzhenshihua on 2017/4/12.
//  Copyright © 2017年 shenzhenshihua. All rights reserved.
//

#import "RecordBtnView.h"

@interface RecordBtnView ()

@property(nonatomic,strong)UIButton * btn;

@end

@implementation RecordBtnView


- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initView];
    }
    return self;
}

- (void)initView {
    [self addSubview:self.btn];
}

- (void)touchDownAction:(UIButton *)sender {
    NSLog(@"按下");
    if (self.recordBtnViewBlock) {
        self.recordBtnViewBlock(RecordBtnStateTouchDown);
    }
    
}

- (void)touchUpInsideAction:(UIButton *)sender {
    NSLog(@"按下内部抬起");
    if (self.recordBtnViewBlock) {
        self.recordBtnViewBlock(RecordBtnStateTouchUpInside);
    }
}


- (void)touchUpOutsideAction:(UIButton *)sender {
    NSLog(@"按下外部抬起");
    if (self.recordBtnViewBlock) {
        self.recordBtnViewBlock(RecordBtnStateTouchUpOutside);
    }
}

- (void)touchDragExitAction:(UIButton *)sender {
    NSLog(@"拖到外部");
    if (self.recordBtnViewBlock) {
        self.recordBtnViewBlock(RecordBtnStateTouchDragExit);
    }
}

- (void)touchDragEnterAction:(UIButton *)sender {
    NSLog(@"拖回内部");
    if (self.recordBtnViewBlock) {
        self.recordBtnViewBlock(RecordBtnStateTouchDragEnter);
    }
}



- (UIButton *)btn {
    if (_btn==nil) {
        _btn = [[UIButton alloc] initWithFrame:self.bounds];
        _btn.layer.cornerRadius = 5;
        _btn.layer.borderColor = [UIColor grayColor].CGColor;
        _btn.layer.borderWidth = 1;
        _btn.backgroundColor = [UIColor lightGrayColor];
        [_btn.titleLabel setFont:[UIFont boldSystemFontOfSize:20]];
        [_btn setTitle:@"按住 说话" forState:UIControlStateNormal];
        [_btn setTitle:@"松开 结束" forState:UIControlStateHighlighted];
        [_btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_btn setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
        //添加事件
        [_btn addTarget:self action:@selector(touchDownAction:) forControlEvents:UIControlEventTouchDown];
        [_btn addTarget:self action:@selector(touchUpInsideAction:) forControlEvents:UIControlEventTouchUpInside];
        [_btn addTarget:self action:@selector(touchUpOutsideAction:) forControlEvents:UIControlEventTouchUpOutside];
        [_btn addTarget:self action:@selector(touchDragExitAction:) forControlEvents:UIControlEventTouchDragExit];
        [_btn addTarget:self action:@selector(touchDragEnterAction:) forControlEvents:UIControlEventTouchDragEnter];

    }
    return _btn;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

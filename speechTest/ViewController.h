//
//  ViewController.h
//  speechTest
//
//  Created by Talka_Ying on 2016/7/11.
//  Copyright © 2016年 Talka_Ying. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AVAudioEngine;
@class SFSpeechRecognizer;
@class SFSpeechAudioBufferRecognitionRequest;
@class SFSpeechRecognitionTask;

@class RecorderView;

@interface ViewController : UIViewController

@property (nonatomic,strong) IBOutlet UIButton *start;
@property (nonatomic,strong) IBOutlet UILabel *result;
@property (nonatomic,strong) RecorderView *recordUI;

@property (nonatomic,strong) AVAudioEngine *audioEngine;
@property (nonatomic,strong) SFSpeechRecognizer *speechRecognizer;
@property (nonatomic,strong) __block SFSpeechAudioBufferRecognitionRequest *request;
@property (nonatomic,strong) SFSpeechRecognitionTask *recognitionTask;

@end


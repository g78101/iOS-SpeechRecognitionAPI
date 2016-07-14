//
//  ViewController.m
//  speechTest
//
//  Created by Talka_Ying on 2016/7/11.
//  Copyright © 2016年 Talka_Ying. All rights reserved.
//

#import "ViewController.h"
#import <Speech/Speech.h>
#import "RecorderView.h"

#define autoStopRecordSec 15    //unit: 0.1(sec)
#define MAX_RADIUS 50

@interface ViewController ()  <SFSpeechRecognizerDelegate,SFSpeechRecognitionTaskDelegate>

@end

@implementation ViewController {
    // for auto stop record
    int stopCount;
    bool spoken;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // init UI
    [_start addTarget:self action:@selector(startClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    _start.layer.borderWidth = 1.0f;
    _result.layer.borderWidth = 1.0f;
    
    _recordUI = [[RecorderView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - MAX_RADIUS, 230 , 2*MAX_RADIUS, 2*MAX_RADIUS)];
    [_recordUI addTarget:self action:@selector(stopClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_recordUI];
    _recordUI.layer.borderWidth = 1.0f;
    
    stopCount = 0;
    spoken = false;
    
    //  Remember to add Cocoa Keys in info.plist:
    //  1. NSSpeechRecognitionUsageDescription  (Speech)
    //  2. NSMicrophoneUsageDescription         (Mircophone)
    [SFSpeechRecognizer requestAuthorization:^(SFSpeechRecognizerAuthorizationStatus status) {
        NSLog(@"SFSpeechRecognizer Status:");
        switch (status) {
            case SFSpeechRecognizerAuthorizationStatusNotDetermined:
                NSLog(@"\tDon't know yet");
                break;
            case SFSpeechRecognizerAuthorizationStatusDenied:
                NSLog(@"\tUser said no");
                break;
            case SFSpeechRecognizerAuthorizationStatusRestricted:
                NSLog(@"\tDevice isn't permitted");
                break;
            case SFSpeechRecognizerAuthorizationStatusAuthorized:
                NSLog(@"\tGood to go");
                break;
        }
    }];
    
    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
        NSLog(@"Mircophone:");
        if (granted) {
            NSLog(@"\tGood to go");
        }
        else {
            NSLog(@"\tDevice isn't permitted");
        }
    }];

    [self initSpeech];
}

- (void) initSpeech {

    _audioEngine = [[AVAudioEngine alloc] init];
    _speechRecognizer = [[SFSpeechRecognizer alloc] init];
    [_speechRecognizer setDelegate:self];
    _request = [[SFSpeechAudioBufferRecognitionRequest alloc] init];
    
    
    AVAudioInputNode *node =[_audioEngine inputNode];
    AVAudioFormat *recordingFormat = [node outputFormatForBus:0];
    
    // call frequency 0.1 sec
    [node installTapOnBus:0 bufferSize:1024 format:recordingFormat block:^(AVAudioPCMBuffer * _Nonnull buffer, AVAudioTime * _Nonnull when) {
        
        [_request appendAudioPCMBuffer:buffer];
        
        
        // for UI
        // 'volume' is summation of bufferData.
        // I don't know its unit, but this can work
        float *bufferData = buffer.floatChannelData[0],volume=0;
        
        for (int i=0; i < buffer.frameLength ; ++i) {
            volume += fabs(bufferData[i]);
        }
        
        [_recordUI updateUI:volume];
        
        
        // auto stop record
        if(stopCount == autoStopRecordSec) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self stopClicked:nil];
            });
        }
        // 0~30 ambience voice
        if (volume <= 30 && spoken) {
            stopCount++;
        }
        else if(volume < 100) {
            stopCount = 0;
        }
        else {
            spoken = TRUE;
        }
        
    }];
}

- (void) startClicked:(id) sender {
    [self startRecording];
    [_recordUI setHidden:NO];
}

- (void) stopClicked:(id) sender {
    [self stopRecording];
    [_recordUI setHidden:YES];
}

-(void) startRecording {
    
    if(![_audioEngine isRunning]) {
        [_audioEngine prepare];
        
        NSError *error;
        if([_audioEngine startAndReturnError:(&error)]) {
            _recognitionTask = [_speechRecognizer recognitionTaskWithRequest:_request delegate:self];
        }
        else {
            NSLog(@"Error %@",error);
        }
    }
}

-(void) stopRecording {

    if([_audioEngine isRunning]) {
        [_audioEngine stop];
        [_request endAudio];
        [_recognitionTask finish];
        
        //SFSpeechAudioBufferRecognitionRequest cannot be re-used
        _request = [[SFSpeechAudioBufferRecognitionRequest alloc] init];
        
        // Reset argument
        stopCount = 0;
        spoken = false;
    }
}

#pragma mark - SFSpeechRecognition
// Called when the availability of the given recognizer changes
- (void)speechRecognizer:(SFSpeechRecognizer *)speechRecognizer availabilityDidChange:(BOOL)available {
    
//    NSLog(@"speechRecognizer");
//    EX: internet stage change
}

// Called when the task first detects speech in the source audio
- (void)speechRecognitionDidDetectSpeech:(SFSpeechRecognitionTask *)task {
    
//    NSLog(@"speechRecognitionDidDetectSpeech");
}

// Called for all recognitions, including non-final hypothesis
- (void)speechRecognitionTask:(SFSpeechRecognitionTask *)task didHypothesizeTranscription:(SFTranscription *)transcription {
    
//    NSLog(@"speechRecognitionTask");
}

// Called only for final recognitions of utterances. No more about the utterance will be reported
- (void)speechRecognitionTask:(SFSpeechRecognitionTask *)task didFinishRecognition:(SFSpeechRecognitionResult *)recognitionResult{
    
//    NSLog(@"speechRecognitionTask");
    
    NSString *translatedString = [[recognitionResult bestTranscription] formattedString];
    [_result setText:translatedString];
}

// Called when the task is no longer accepting new audio but may be finishing final processing
- (void)speechRecognitionTaskFinishedReadingAudio:(SFSpeechRecognitionTask *)task {
    
//    NSLog(@"speechRecognitionTaskFinishedReadingAudio");
}

// Called when the task has been cancelled, either by client app, the user, or the system
- (void)speechRecognitionTaskWasCancelled:(SFSpeechRecognitionTask *)task {
    
//    NSLog(@"speechRecognitionTaskWasCancelled");
}

// Called when recognition of all requested utterances is finished.
// If successfully is false, the error property of the task will contain error information
- (void)speechRecognitionTask:(SFSpeechRecognitionTask *)task didFinishSuccessfully:(BOOL)successfully {
    
//    NSLog(@"speechRecognitionTask");
}

@end

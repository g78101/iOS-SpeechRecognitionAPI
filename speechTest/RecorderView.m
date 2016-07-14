//
//  RecorderView.m
//  speechTest
//
//  Created by Talka_Ying on 2016/7/12.
//  Copyright © 2016年 Talka_Ying. All rights reserved.
//

#import "RecorderView.h"

#define MIN_RADIUS 30

@implementation RecorderView
{
    int radius;
    UIImageView *recorderImage;
    UIButton *closeButton;
}

- (instancetype) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if(self) {
        [self setHidden:YES];
        [self setBackgroundColor:[UIColor clearColor]];
        radius = MIN_RADIUS;
        recorderImage = [[UIImageView alloc] initWithFrame:CGRectMake(frame.size.width/2 - MIN_RADIUS,frame.size.height/2 -MIN_RADIUS, MIN_RADIUS*2, MIN_RADIUS*2)];
        [recorderImage setImage:[UIImage imageNamed:@"recorderImage"]];
        closeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [self addSubview:recorderImage];
        [self addSubview:closeButton];
    }
    return self;
}

- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents {

    [closeButton addTarget:target action:action forControlEvents:controlEvents];
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    CGRect borderRect = CGRectMake(rect.size.width/2.0 - radius, rect.size.height/2.0 - radius , 2*radius, 2*radius);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBStrokeColor(context, 0.2, 0.4, 0.8, 1.0);
    CGContextSetRGBFillColor(context, 0.2, 0.4, 0.8, 1.0);
    CGContextFillEllipseInRect(context, borderRect);
    CGContextStrokeEllipseInRect(context, borderRect);
    CGContextFillPath(context);
}

- (void) updateUI:(float) volume {
//    NSLog(@"%f",sum);
    // 0~30 ambience voice
    float lowVolume = 30.0, highVolume = 110.0;
    float maxRadius = self.frame.size.width/2.0;
    float interval = (maxRadius - MIN_RADIUS)/(highVolume - lowVolume);
    if (volume <= lowVolume) {
        radius = MIN_RADIUS;
    }
    else if(volume < highVolume) {
        radius = MIN_RADIUS +(( volume - lowVolume ) * interval);
    }
    else {
        radius = maxRadius;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setNeedsDisplay];
    });
    
}


@end

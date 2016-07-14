//
//  RecorderView.h
//  speechTest
//
//  Created by Talka_Ying on 2016/7/12.
//  Copyright © 2016年 Talka_Ying. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecorderView : UIView

-(void) updateUI:(float) volume;

-(void) addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;
@end

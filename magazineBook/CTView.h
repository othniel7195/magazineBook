//
//  CTView.h
//  magazineBook
//
//  Created by 赵锋 on 15/6/9.
//  Copyright (c) 2015年 赵锋. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>
#import "CTColumnView.h"
@interface CTView : UIScrollView<UIScrollViewDelegate>
{
    NSMutableArray *frames;
    float frameXOffset;
    float frameYOffset;
    @public
    NSAttributedString* attString;
    NSArray* images;
}



- (void)buildFrames;
-(void)attachImagesWithFrame:(CTFrameRef)f inColumnView:(CTColumnView*)col;
@end

//
//  MarkupParser.h
//  magazineBook
//
//  Created by 赵锋 on 15/6/9.
//  Copyright (c) 2015年 赵锋. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>
#import <UIKit/UIKit.h>
@interface MarkupParser : NSObject

@property (strong, nonatomic) NSString* font;
@property (strong, nonatomic) UIColor* color;
@property (strong, nonatomic) UIColor* strokeColor;
@property (assign, readwrite) float strokeWidth;

@property (strong, nonatomic) NSMutableArray* images;

-(NSAttributedString *)attrStringFromMarkup:(NSString *)html;

@end

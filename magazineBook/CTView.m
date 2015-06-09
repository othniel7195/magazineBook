//
//  CTView.m
//  magazineBook
//
//  Created by 赵锋 on 15/6/9.
//  Copyright (c) 2015年 赵锋. All rights reserved.
//

#import "CTView.h"

#import "MarkupParser.h"

@implementation CTView


- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    return;

    //绘制hello core text word
    //1.获取上下文
    CGContextRef context=UIGraphicsGetCurrentContext();
    
    //2.创建绘制路径
    CGMutablePathRef path=CGPathCreateMutable();
    //3.添加一个矩形到路径
    CGPathAddRect(path, NULL, self.bounds);
    
    //4.设置绘制文字 用属性文字
//    NSMutableAttributedString *attributedText=[[NSMutableAttributedString alloc] initWithString:@"hellow core text word"];
//    CTFontRef ctFont=CTFontCreateWithName((CFStringRef)[UIFont systemFontOfSize:50.0].fontName, 50.0, NULL);
//    [attributedText addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)ctFont range:NSMakeRange(0, attributedText.length)];
    
    //5. 设置framesetter
    CTFramesetterRef frameseeter=CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attString);
    
    //6.设置frame
    CTFrameRef ctFrame=CTFramesetterCreateFrame(frameseeter, CFRangeMake(0,attString.length), path, NULL);
    
    //7.改变坐标系统
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    NSLog(@"%f",self.bounds.size.height);
    CGContextTranslateCTM(context, 0, self.bounds.size.height);//移动
    CGContextScaleCTM(context, 1.0, -1.0);
    
    //8.绘制
    
    CTFrameDraw(ctFrame, context);
    
    //9.清理
    CFRelease(frameseeter);
    CFRelease(path);
    CFRelease(ctFrame);
    
}

- (void)buildFrames
{
    frameXOffset = 20; //1
    frameYOffset = 20;
    self.pagingEnabled = YES;
    self.delegate = self;
    frames = [NSMutableArray array];
    
    CGMutablePathRef path = CGPathCreateMutable(); //2
    CGRect textFrame = CGRectInset(self.bounds, frameXOffset, frameYOffset);
    CGPathAddRect(path, NULL, textFrame );
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attString);
    
    int textPos = 0; //3
    int columnIndex = 0;
    
    while (textPos < [attString length]) { //4
        CGPoint colOffset = CGPointMake( (columnIndex+1)*frameXOffset + columnIndex*(textFrame.size.width/2), 20 );
        CGRect colRect = CGRectMake(0, 0 , textFrame.size.width/2-10, textFrame.size.height-40);
        
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, colRect);
        
        //use the column path
        CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(textPos, 0), path, NULL);
        CFRange frameRange = CTFrameGetVisibleStringRange(frame); //5
        
        //create an empty column view
        CTColumnView* content = [[CTColumnView alloc] initWithFrame: CGRectMake(0, 0, self.contentSize.width, self.contentSize.height)];
        content.backgroundColor = [UIColor clearColor];
        content.frame = CGRectMake(colOffset.x, colOffset.y, colRect.size.width, colRect.size.height) ;
        NSLog(@"textPos :%d",textPos);
//        if (textPos==0) {
//            content.backgroundColor=[UIColor redColor];
//        }else if (textPos==668)
//        {
//            content.backgroundColor=[UIColor yellowColor];
//        }else if (textPos==1439)
//        {
//            content.backgroundColor=[UIColor blueColor];
//        }
        
        //set the column view contents and add it as subview
        [content setCtFrame:(__bridge id)frame];  //6
        [self attachImagesWithFrame:frame inColumnView: content];
        [frames addObject: (__bridge id)frame];
        [self addSubview: content];
        
        //prepare for next frame
        textPos += frameRange.length;
        
        //CFRelease(frame);
        CFRelease(path);
        
        columnIndex++;
    }
    
    //set the total width of the scroll view
    int totalPages = (columnIndex+1) / 2; //7
    self.contentSize = CGSizeMake(totalPages*self.bounds.size.width, textFrame.size.height);
}

-(void)attachImagesWithFrame:(CTFrameRef)f inColumnView:(CTColumnView*)col
{
    //drawing images
    NSArray *lines = (NSArray *)CTFrameGetLines(f); //1
    
    CGPoint origins[[lines count]];
    CTFrameGetLineOrigins(f, CFRangeMake(0, 0), origins); //2
    
    int imgIndex = 0; //3
    NSDictionary* nextImage = [images objectAtIndex:imgIndex];
    int imgLocation = [[nextImage objectForKey:@"location"] intValue];
    
    //find images for the current column
    CFRange frameRange = CTFrameGetVisibleStringRange(f); //4
    while ( imgLocation < frameRange.location ) {
        imgIndex++;
        if (imgIndex>=[images count]) return; //quit if no images for this column
        nextImage = [images objectAtIndex:imgIndex];
        imgLocation = [[nextImage objectForKey:@"location"] intValue];
    }
    
    NSUInteger lineIndex = 0;
    for (id lineObj in lines) { //5
        CTLineRef line = (__bridge CTLineRef)lineObj;
        
        for (id runObj in (NSArray *)CTLineGetGlyphRuns(line)) { //6
            CTRunRef run = (__bridge CTRunRef)runObj;
            CFRange runRange = CTRunGetStringRange(run);
            
            if ( runRange.location <= imgLocation && runRange.location+runRange.length > imgLocation ) { //7
                CGRect runBounds;
                CGFloat ascent;//height above the baseline
                CGFloat descent;//height below the baseline
                runBounds.size.width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, NULL); //8
                runBounds.size.height = ascent + descent;
                
                CGFloat xOffset = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL); //9
                runBounds.origin.x = origins[lineIndex].x + self.frame.origin.x + xOffset + frameXOffset;
                runBounds.origin.y = origins[lineIndex].y + self.frame.origin.y + frameYOffset;
                runBounds.origin.y -= descent;
                
                UIImage *img = [UIImage imageNamed: [nextImage objectForKey:@"fileName"] ];
                CGPathRef pathRef = CTFrameGetPath(f); //10
                CGRect colRect = CGPathGetBoundingBox(pathRef);
                
                CGRect imgBounds = CGRectOffset(runBounds, colRect.origin.x - frameXOffset - self.contentOffset.x, colRect.origin.y - frameYOffset - self.frame.origin.y);
                [col.images addObject: //11
                 [NSArray arrayWithObjects:img, NSStringFromCGRect(imgBounds) , nil]
                 ];
                //load the next image //12
                imgIndex++;
                if (imgIndex < [images count]) {
                    nextImage = [images objectAtIndex: imgIndex];
                    imgLocation = [[nextImage objectForKey: @"location"] intValue];
                }
                
            }
        }
        lineIndex++;
    }
}
@end

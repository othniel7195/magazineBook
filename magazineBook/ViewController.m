//
//  ViewController.m
//  magazineBook
//
//  Created by 赵锋 on 15/6/9.
//  Copyright (c) 2015年 赵锋. All rights reserved.
//

#import "ViewController.h"
#import "MarkupParser.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"zombies" ofType:@"txt"];
    NSString* text = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
    MarkupParser* p = [[MarkupParser alloc] init];
    NSAttributedString* attString = [p attrStringFromMarkup: text];
    self.ctv=[[CTView alloc] initWithFrame:self.view.bounds];
    self.ctv.backgroundColor=[UIColor whiteColor];
    self.ctv->attString=attString;
    
    
    self.ctv->images=p.images;
    self.ctv.contentSize=CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height*2);
    [self.ctv buildFrames];
    [self.view addSubview:self.ctv];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

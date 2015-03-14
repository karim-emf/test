//
//  KEMViewController.m
//  RunningMate
//
//  Created by Karim Mourra on 3/2/15.
//  Copyright (c) 2015 Karim Mourra. All rights reserved.
//

#import "KEMViewController.h"


@interface KEMViewController ()

@end

@implementation KEMViewController

//- (instancetype)init
//{
//    self = [super init];
//    if (self) {
//        [self.tabBarItem initWithTabBarSystemItem:UITabBarSystemItemBookmarks tag:0];
//    }
//    return self;
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    KEMDaySettings* daySettingTVC = [KEMDaySettings new];
    daySettingTVC.view.frame = CGRectMake(0, 0, self.view.frame.size.width * 0.9f, self.view.frame.size.height * 0.9f);
    [self.view addSubview:daySettingTVC.view];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

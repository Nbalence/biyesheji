//
//  SongViewController.m
//  心随曲动
//
//  Created by qingyun on 16/5/20.
//  Copyright © 2016年 GXT. All rights reserved.
//

#import "SongViewController.h"

@interface SongViewController ()

@end

@implementation SongViewController


//初始化播放器
+(instancetype)shareSongCtrHandel{
    static SongViewController *handel;
    static dispatch_once_t once;
    dispatch_once(&once , ^{
        handel=[[SongViewController alloc] init];
        //        [handel  setSeesion];
    });
    return handel;
}
- (void)viewDidLoad {
    [super viewDidLoad];
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

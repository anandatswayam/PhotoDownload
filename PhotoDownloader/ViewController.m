//
//  ViewController.m
//  PhotoDownloader
//
//  Created by Anand Patel on 21/12/12.
//  Copyright (c) 2012 Anand Patel. All rights reserved.
//

#import "ViewController.h"
#import "ImagesViewController.h"
#import "VideosViewController.h"
#import "MusicViewController.h"

@interface ViewController (){

}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    serverAPI = [[serverAPIClass alloc] init];
    
    self.title = @"Home";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(IBAction)imagesAction:(id)sender{
    ImagesViewController *imageView = [[ImagesViewController alloc] initWithNibName:@"ImagesViewController" bundle:[NSBundle mainBundle]];
    [self.navigationController pushViewController:imageView animated:YES];
    [imageView release];
}
-(IBAction)videosAction:(id)sender{
    VideosViewController *videosView = [[VideosViewController alloc] initWithNibName:@"VideosViewController" bundle:[NSBundle mainBundle]];
    [self.navigationController pushViewController:videosView animated:YES];
    [videosView release];
}
-(IBAction)musicAction:(id)sender{
    MusicViewController *musicView = [[MusicViewController alloc] initWithNibName:@"MusicViewController" bundle:[NSBundle mainBundle]];
    [self.navigationController pushViewController:musicView animated:YES];
    [musicView release];
}
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    
}
@end

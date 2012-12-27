//
//  imageViewController.m
//  PhotoDownloader
//
//  Created by Anand Patel on 22/12/12.
//  Copyright (c) 2012 Anand Patel. All rights reserved.
//

#import "imageViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

@interface imageViewController (){
    IBOutlet UIImageView *imageView;
    CGFloat lastScale;
    float beginX,beginY;
    AVAudioPlayer *audioplayer;
    
    IBOutlet UIToolbar *imageTools,*videoTools,*musicTools;
    IBOutlet UIBarButtonItem *btnMusicPlayStop;
}

@end

@implementation imageViewController
@synthesize imagePath,fileType;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)viewDidDisappear:(BOOL)animated{
    if(audioplayer){
        [audioplayer stop];
        audioplayer = nil;
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if([fileType isEqualToString:@"image"]){
        imageTools.hidden = false;
        self.title = @"Photos";
        imageView.image = [UIImage imageWithContentsOfFile:imagePath];
        
        UIPinchGestureRecognizer *scalImage = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(scalImage:)];
        [imageView addGestureRecognizer:scalImage];
        [scalImage release];
        
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveImage:)];
        [panGesture setMinimumNumberOfTouches:1];
        [panGesture setMaximumNumberOfTouches:1];
        [imageView addGestureRecognizer:panGesture];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resetImage:)];
        [imageView addGestureRecognizer:tapGesture];
        
    }else if([fileType isEqualToString:@"video"]){
        videoTools.hidden = false;
        self.title = @"Videos";
        imageView.image = [self generateImage:imagePath];
        [self playVideo:nil];
    }else if([fileType isEqualToString:@"music"]){
        musicTools.hidden = false;
        self.title = @"Music";
        [self playMusic:nil];
        btnMusicPlayStop.title = @"Stop";
    }
    if(imageView.image != nil){
        UIPinchGestureRecognizer *scalImage = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(scalImage:)];
        [imageView addGestureRecognizer:scalImage];
        [scalImage release];
        
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveImage:)];
        [panGesture setMinimumNumberOfTouches:1];
        [panGesture setMaximumNumberOfTouches:1];
        [imageView addGestureRecognizer:panGesture];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resetImage:)];
        [imageView addGestureRecognizer:tapGesture];
    }
}

#pragma mark - Image View
- (void)resetImage:(UITapGestureRecognizer *)recognizer
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    imageView.transform = CGAffineTransformIdentity;
    [imageView setCenter:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2)];
    [UIView commitAnimations];
}
- (void)moveImage:(UIPanGestureRecognizer *)recognizer
{
    CGPoint newCenter = [recognizer translationInView:self.view];
    if([recognizer state] == UIGestureRecognizerStateBegan) {
        beginX = imageView.center.x;
        beginY = imageView.center.y;
    }
    newCenter = CGPointMake(beginX + newCenter.x, beginY + newCenter.y);
    [imageView setCenter:newCenter];
}
-(void)scalImage:(UIPinchGestureRecognizer *)gestureRecognizer{

    if([gestureRecognizer state] == UIGestureRecognizerStateBegan) {
        // Reset the last scale, necessary if there are multiple objects with different scales
        lastScale = [gestureRecognizer scale];
    }
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan ||
        [gestureRecognizer state] == UIGestureRecognizerStateChanged) {
        
        CGFloat currentScale = [[[gestureRecognizer view].layer valueForKeyPath:@"transform.scale"] floatValue];
        
        // Constants to adjust the max/min values of zoom
        const CGFloat kMaxScale = 2.0;
        const CGFloat kMinScale = 0.5;
        
        CGFloat newScale = 1 -  (lastScale - [gestureRecognizer scale]); // new scale is in the range (0-1)
        newScale = MIN(newScale, kMaxScale / currentScale);
        newScale = MAX(newScale, kMinScale / currentScale);
        CGAffineTransform transform = CGAffineTransformScale([[gestureRecognizer view] transform], newScale, newScale);
        [gestureRecognizer view].transform = transform;
        
        lastScale = [gestureRecognizer scale];  // Store the previous scale factor for the next pinch gesture call
    }
}

#pragma mark - Video View
-(IBAction)playVideo:(id)sender{
    
    NSURL *url = [NSURL fileURLWithPath:imagePath];
    MPMoviePlayerViewController *moviePlayer = [[MPMoviePlayerViewController alloc] initWithContentURL:url];
    [self.navigationController presentMoviePlayerViewControllerAnimated:moviePlayer];
    [moviePlayer release];
}

#pragma mark - Music View
-(IBAction)playMusic:(id)sender{
    if(!audioplayer){
        NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@",imagePath]];
        audioplayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    }
    
    if([audioplayer isPlaying]){
        [audioplayer stop];

        btnMusicPlayStop.title = @"Play";
    }else{
        [audioplayer play];
        
        btnMusicPlayStop.title = @"Stop";
    }
}

#pragma mark - Extra
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(IBAction)deletePhoto:(id)sender{
    NSString *message = [NSString stringWithFormat:@"Are you sure want to delete this %@?",fileType];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:message delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    [alert show];
    [alert release];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex == 1){
        NSFileManager *manager = [NSFileManager defaultManager];
        [manager removeItemAtPath:imagePath error:nil];
        [self.navigationController popViewControllerAnimated:YES];
    }
}
-(UIImage *)generateImage:(NSString *)path
{
    MPMoviePlayerController *mp = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL fileURLWithPath:path]];
    UIImage *img = [mp thumbnailImageAtTime:3 timeOption:MPMovieTimeOptionNearestKeyFrame];
    [mp stop];
    [mp release];
    return img;
}
@end

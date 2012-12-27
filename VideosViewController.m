//
//  VideosViewController.m
//  PhotoDownloader
//
//  Created by Anand Patel on 24/12/12.
//  Copyright (c) 2012 Anand Patel. All rights reserved.
//

#import "VideosViewController.h"
#import "RJSON.h"
#import "imageViewController.h"
#import <MediaPlayer/MediaPlayer.h>

@interface VideosViewController (){
    IBOutlet UIScrollView *mainScrollView;
    NSMutableArray *allvideos;
    
    bool isLandscap;
    NSString *dirName;
}

@end

@implementation VideosViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    serverAPI = [[serverAPIClass alloc] init];
    
    self.title = @"Videos";
    dirName = @"videos";
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated{
    if(self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft || self.interfaceOrientation == UIInterfaceOrientationLandscapeRight){
        isLandscap = true;
    }
    [self readDir];
}
-(void)readDir{
    allvideos = [[NSMutableArray alloc] init];
    for(UIView *tmpview in [mainScrollView subviews]){
        [tmpview removeFromSuperview];
    }
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    // Get documents folder
    NSString *documentsDirectory = [paths objectAtIndex:0];
    [delegate createDirectoryInDocumentsFolderWithName:dirName];
    documentsDirectory = [documentsDirectory stringByAppendingFormat:@"/%@",dirName];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    NSArray *fileList = [manager directoryContentsAtPath:documentsDirectory];
    int topIndex = 4;
    int leftIndex = 4;
    int width = 75;
    int height = 75;
    int index = 1;
    int numcols = 4;
    if(isLandscap){
        numcols = 6;
    }
    for (NSString *s in fileList){
        UIButton * tmpImage = [[UIButton alloc] initWithFrame:CGRectMake(leftIndex, topIndex, width, height)];
        tmpImage.tag = index-1;
        NSString *des = [NSString stringWithFormat:@"%@/%@",documentsDirectory,s];
        [tmpImage setImage:[self generateImage:des] forState:UIControlStateNormal];
        [tmpImage addTarget:self action:@selector(viewImage:) forControlEvents:UIControlEventTouchUpInside];
        [mainScrollView addSubview:tmpImage];
        [allvideos addObject:des];
        
        if(index%numcols == 0){
            leftIndex = 4;
            topIndex += height + 4;
        }else{
            leftIndex += width + 4;
        }
        index++;
    }
    
    [mainScrollView setContentSize:CGSizeMake(mainScrollView.frame.size.width, topIndex*10)];
}
-(IBAction)viewImage:(id)sender{
    
    NSString *path = [allvideos objectAtIndex:[sender tag]];
    imageViewController *imageView = [[imageViewController alloc] initWithNibName:@"imageViewController" bundle:[NSBundle mainBundle]];
    imageView.imagePath = path;
    imageView.fileType = @"video";
    [self.navigationController pushViewController:imageView animated:YES];
    [imageView release];
}

-(IBAction)getFromServer:(id)sender{
    
    [self startLoader];
    [NSThread detachNewThreadSelector:@selector(copyFiles:) toTarget:self withObject:nil];
}
-(void)copyFiles:(NSDictionary *)allFiles{
    NSString *output = [serverAPI SendWebURL:@"videos.php" SendWebPostData:@"iphone=true"];
    NSLog(@"%@",output);
    
    allFiles = [output JSONValue];
    
    int fetched = 0;
    HUD.labelText = [NSString stringWithFormat:@"Synchronize video %d/%d",fetched,allFiles.count];
    
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    for(NSDictionary *files in allFiles){
        NSString *filePath = [NSString stringWithFormat:@"%@%@/%@",serverAPI.base_server,dirName,files];
        NSURL *url = [NSURL URLWithString: filePath];
        NSData *data = [NSData dataWithContentsOfURL:url];
        [data writeToFile:[NSString stringWithFormat:@"%@/%@/%@",docDir,dirName,files] atomically:YES];
        fetched++;
        HUD.labelText = [NSString stringWithFormat:@"Synchronize video %d/%d",fetched,allFiles.count];
    }
    [self stopLoader];
    [self readDir];
}
-(void)startLoader{
    //loader.hidden = false;
    //[loader startAnimating];
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
	HUD.hidden = false;
	HUD.delegate = self;
	HUD.labelText = @"Synchronize videos...";
    [self.navigationController.view addSubview:HUD];
	[HUD show:YES];
	//[HUD showWhileExecuting:@selector(myTask) onTarget:self withObject:nil animated:YES];
}
-(void)stopLoader{
    //loader.hidden = true;
    //[loader stopAnimating];
    [HUD hide:YES];
}
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    if(toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown){
        isLandscap = false;
    }else{
        isLandscap = true;
    }
    [self readDir];
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

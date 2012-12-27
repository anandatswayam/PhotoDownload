//
//  ImagesViewController.m
//  PhotoDownloader
//
//  Created by Anand Patel on 24/12/12.
//  Copyright (c) 2012 Anand Patel. All rights reserved.
//

#import "ImagesViewController.h"
#import "RJSON.h"
#import "imageViewController.h"

@interface ImagesViewController (){
    IBOutlet UIScrollView *mainScrollView;
    NSMutableArray *allimages;
    
    bool isLandscap;
    NSString *dirName;
}

@end

@implementation ImagesViewController

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
    
    self.title = @"Photos";
    dirName = @"images";
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
    allimages = [[NSMutableArray alloc] init];
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
        [tmpImage setImage:[UIImage imageWithContentsOfFile:des] forState:UIControlStateNormal];
        [tmpImage addTarget:self action:@selector(viewImage:) forControlEvents:UIControlEventTouchUpInside];
        [mainScrollView addSubview:tmpImage];
        [allimages addObject:des];
        
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
    
    NSString *path = [allimages objectAtIndex:[sender tag]];
    imageViewController *imageView = [[imageViewController alloc] initWithNibName:@"imageViewController" bundle:[NSBundle mainBundle]];
    imageView.imagePath = path;
    imageView.fileType = @"image";
    [self.navigationController pushViewController:imageView animated:YES];
    [imageView release];
}

-(IBAction)getFromServer:(id)sender{

    [self startLoader];
    [NSThread detachNewThreadSelector:@selector(copyFiles:) toTarget:self withObject:nil];
}
-(void)copyFiles:(NSDictionary *)allFiles{
    NSString *output = [serverAPI SendWebURL:@"index.php" SendWebPostData:@"iphone=true"];
    NSLog(@"%@",output);
    
    allFiles = [output JSONValue];
    
    int fetched = 0;
    HUD.labelText = [NSString stringWithFormat:@"Synchronize image %d/%d",fetched,allFiles.count];
    
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    for(NSMutableArray *files in allFiles){
        NSString *folderName = [files objectAtIndex:0];
        NSString *fileName = [files objectAtIndex:1];
        NSString *liveFilePath = @"";
        NSString *localFilePath = @"";
        if([folderName isEqualToString:@"root"]){
            liveFilePath = [NSString stringWithFormat:@"%@%@/%@",serverAPI.base_server,dirName,fileName];
            localFilePath = [NSString stringWithFormat:@"%@/%@/%@",docDir,dirName,files];
        }else{
            //[delegate createDirectoryInDocumentsFolderWithName:[NSString stringWithFormat:@"%@/%@",dirName,folderName]];
            liveFilePath = [NSString stringWithFormat:@"%@%@/%@/%@",serverAPI.base_server,dirName,folderName,fileName];
            localFilePath = [NSString stringWithFormat:@"%@/%@/%@/%@",docDir,dirName,folderName,files];
        }
        
        NSURL *url = [NSURL URLWithString: liveFilePath];
        NSData *data = [NSData dataWithContentsOfURL:url];
        [data writeToFile:[NSString stringWithFormat:@"%@",localFilePath] atomically:YES];
        fetched++;
        HUD.labelText = [NSString stringWithFormat:@"Synchronize images %d/%d",fetched,allFiles.count];
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
	HUD.labelText = @"Synchronize images...";
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

@end

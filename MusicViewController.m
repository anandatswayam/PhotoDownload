//
//  MusicViewController.m
//  PhotoDownloader
//
//  Created by Anand Patel on 24/12/12.
//  Copyright (c) 2012 Anand Patel. All rights reserved.
//

#import "MusicViewController.h"
#import "RJSON.h"
#import "imageViewController.h"

@interface MusicViewController (){
    NSMutableArray *allmusics;
    NSString *dirName;
}
@property(nonatomic, retain) IBOutlet UITableView *tableView;
@end

@implementation MusicViewController
@synthesize tableView;

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
    
    self.title = @"Music";
    dirName = @"music";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewDidAppear:(BOOL)animated{
    [self readDir];
}

-(void)readDir{
    allmusics = [[NSMutableArray alloc] init];

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    // Get documents folder
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSFileManager *manager = [NSFileManager defaultManager];
    [delegate createDirectoryInDocumentsFolderWithName:dirName];
    documentsDirectory = [documentsDirectory stringByAppendingFormat:@"/%@",dirName];
    NSArray *fileList = [manager directoryContentsAtPath:documentsDirectory];
    for(NSString *s in fileList){
        [allmusics addObject:s];
    }
    NSLog(@"%@",allmusics);
    [self.tableView reloadData];
}
-(IBAction)getFromServer:(id)sender{
    [self startLoader];
    [NSThread detachNewThreadSelector:@selector(copyFiles:) toTarget:self withObject:nil];
}

-(void)copyFiles:(NSDictionary *)allFiles{
    NSString *output = [serverAPI SendWebURL:@"music.php" SendWebPostData:@"iphone=true"];
    NSLog(@"%@",output);
    
    allFiles = [output JSONValue];
    
    int fetched = 0;
    HUD.labelText = [NSString stringWithFormat:@"Synchronize music files %d/%d",fetched,allFiles.count];
    
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    for(NSDictionary *files in allFiles){
        NSString *filePath = [NSString stringWithFormat:@"%@%@/%@",serverAPI.base_server,dirName,files];
        NSURL *url = [NSURL URLWithString: filePath];
        NSData *data = [NSData dataWithContentsOfURL:url];
        [data writeToFile:[NSString stringWithFormat:@"%@/%@/%@",docDir,dirName,files] atomically:YES];
        fetched++;
        HUD.labelText = [NSString stringWithFormat:@"Synchronize music files %d/%d",fetched,allFiles.count];
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
	HUD.labelText = @"Synchronize music files...";
    [self.navigationController.view addSubview:HUD];
	[HUD show:YES];
	//[HUD showWhileExecuting:@selector(myTask) onTarget:self withObject:nil animated:YES];
}
-(void)stopLoader{
    //loader.hidden = true;
    //[loader stopAnimating];
    [HUD hide:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return allmusics.count;
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if((indexPath.row+1)%2 == 0 ){
        cell.backgroundColor= [UIColor colorWithRed:85.0/255.0 green:85.0/255.0 blue:85.0/255.0 alpha:1];
    }else{
        cell.backgroundColor= [UIColor colorWithRed:63.0/255.0 green:63.0/255.0 blue:63.0/255.0 alpha:1];
    }
    cell.textLabel.textColor = [UIColor whiteColor];
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"cell";
	
	UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	
	//if (cell == nil) {
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    
    NSString *fileName = [allmusics objectAtIndex:indexPath.row];
    //NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    // Get documents folder
    //NSString *documentsDirectory = [paths objectAtIndex:0];
    //fileName = [documentsDirectory stringByAppendingFormat:@"/%@/%@",dirName,fileName];
    cell.textLabel.text = [NSString stringWithFormat:@"%@",fileName];
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *fileName = [allmusics objectAtIndex:indexPath.row];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    // Get documents folder
    NSString *documentsDirectory = [paths objectAtIndex:0];
    fileName = [documentsDirectory stringByAppendingFormat:@"/%@/%@",dirName,fileName];
    
    imageViewController *imageView = [[imageViewController alloc] initWithNibName:@"imageViewController" bundle:[NSBundle mainBundle]];
    imageView.imagePath =fileName;
    imageView.fileType = @"music";
    [self.navigationController pushViewController:imageView animated:YES];
    [imageView release];
    
}
@end

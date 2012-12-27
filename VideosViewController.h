//
//  VideosViewController.h
//  PhotoDownloader
//
//  Created by Anand Patel on 24/12/12.
//  Copyright (c) 2012 Anand Patel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "MBProgressHUD.h"

@interface VideosViewController : UIViewController<MBProgressHUDDelegate, NSFileManagerDelegate>{
    AppDelegate *delegate;
    serverAPIClass *serverAPI;
    MBProgressHUD *HUD;
}

@end

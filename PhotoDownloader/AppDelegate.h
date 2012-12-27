//
//  AppDelegate.h
//  PhotoDownloader
//
//  Created by Anand Patel on 21/12/12.
//  Copyright (c) 2012 Anand Patel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "serverAPIClass.h"

@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) ViewController *viewController;
@property (strong, nonatomic) UINavigationController *navigationController;

- (void)createDirectoryInDocumentsFolderWithName:(NSString *)dirName;

@end

//
//  serverAPIClass.h
//  Greetings
//
//  Created by Anand Patel on 05/09/12.
//  Copyright (c) 2012 anandconcious@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface serverAPIClass : NSObject{
    
}
@property(nonatomic, retain) NSString *base_server;

-(id)init;
-(NSString*)SendWebURL:(NSString*) posturl SendWebPostData:(NSString*) post1;
@end

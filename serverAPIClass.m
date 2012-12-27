//
//  serverAPIClass.m
//  Greetings
//
//  Created by Anand Patel on 05/09/12.
//  Copyright (c) 2012 anandconcious@gmail.com. All rights reserved.
//

#import "serverAPIClass.h"

@implementation serverAPIClass
@synthesize base_server;

-(id)init{
    self.base_server = @"http://domainforclient.com/photodownloader/";
    
    return self;
}

-(NSString*)SendWebURL:(NSString*) posturl SendWebPostData:(NSString*) post1 {
	
    posturl = [NSString stringWithFormat:@"%@%@",self.base_server,posturl];
    NSData *postData = [post1 dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
    
    
	NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    //NSLog(@"URL:%@",posturl);
    
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	[request setURL:[NSURL URLWithString:[[NSString alloc] initWithFormat:@"%@",posturl]]];
	[request setHTTPMethod:@"POST"];
	[request setValue:postLength forHTTPHeaderField:@"Content-Length"];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	[request setHTTPBody:postData];
    
    NSError *error;
	NSURLResponse *response;    
	NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
   /* if(error){
        NSLog(@"Error: %@",error);
    }*/
    NSString *data=[[NSString alloc]initWithData:urlData encoding:NSUTF8StringEncoding];
    return data;
}
@end

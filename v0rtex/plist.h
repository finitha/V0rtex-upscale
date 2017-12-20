//
//  plist.h
//  v0rtex-s
//
//  Created by Stanislav on 21.12.2017.
//  Copyright © 2017. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface Plist : NSObject

//Convert Object(Dictionary,Array) to Plist(NSData)
+(NSData *) objToPlistAsData:(id)obj;

//Convert Object(Dictionary,Array) to Plist(NSString)
+(NSString *) objToPlistAsString:(id)obj;

//Convert Plist(NSData) to Object(Array,Dictionary)
+(id) plistToObjectFromData:(NSData *)data;

//Convert Plist(NSString) to Object(Array,Dictionary)
+(id) plistToObjectFromString:(NSString*)str;

@end

//
//  TypeMapper.m
//  sourcefilegen
//
//  Created by aditya-d on 8/22/13.
//  Copyright (c) 2013 aditya-d. All rights reserved.
//

#import "SQCDTypeMapper.h"

@implementation SQCDTypeMapper

+(NSString*)xctypeFromType:(NSString*)sqlliteType
{
    static dispatch_once_t pred;
    static NSDictionary* typesDict = nil;
    dispatch_once(&pred, ^{
        // TODO remove hardcoded string
        typesDict = [[NSDictionary alloc] initWithContentsOfFile:@"/Users/adityad/Developer/sourcefilegen/sourcefilegen/xctypemap.plist"];
        if (typesDict == nil) {
            NSLog(@"Could not initialize types dictionary");
        }
    });
    
    // strip of brackets and anything in between
    NSRange bracketRange = [sqlliteType rangeOfString:@"("];
    if (bracketRange.location != NSNotFound) {
        sqlliteType = [sqlliteType substringToIndex:bracketRange.location];
    }
    return [typesDict valueForKey:sqlliteType];
}

@end

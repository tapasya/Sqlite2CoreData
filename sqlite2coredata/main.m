//
//  main.m
//  sqlite2coredata
//
//  Created by Tapasya on 21/08/13.
//  Copyright (c) 2013 Tapasya. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SQCDMigrationHelper.h"

int main(int argc, const char * argv[])
{

    @autoreleasepool {
        
        for (int i=0; i<argc; i++)
        {
            NSString *str = [NSString stringWithUTF8String:argv[i]];
            NSLog(@"argv[%d] = '%@'", i, str);
        }
        
        NSString* dbPath = [[NSString stringWithUTF8String:argv[1]] stringByExpandingTildeInPath];
        NSString* outputPath = [[NSString stringWithUTF8String:argv[2]] stringByExpandingTildeInPath];
        
        [SQCDMigrationHelper generateCoreDataModelFromDBPath:dbPath outputDirectoryPath:outputPath];
        
    }
    return 0;
}


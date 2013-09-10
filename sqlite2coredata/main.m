//
//  main.m
//  sqlite2coredata
//
//  Created by Tapasya on 21/08/13.
//  Copyright (c) 2013 Tapasya. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SQCDMigrationHelper.h"
#import "CDMMigrationManager.h"

int main(int argc, const char * argv[])
{

    if (argc < 2) {
        NSLog(@"USAGE: sqlite2coredata <dbpath> [<output-directory> [<output-filename>]]");
        return -1;
    }
    @autoreleasepool {
        for (int i=0; i<argc; i++)
        {
            NSString *str = [NSString stringWithUTF8String:argv[i]];
            NSLog(@"argv[%d] = '%@'", i, str);
        }
        
        NSString* dbPath = [[NSString stringWithUTF8String:argv[1]] stringByExpandingTildeInPath];
        NSString* outputPath = argc > 2 ? [[NSString stringWithUTF8String:argv[2]] stringByExpandingTildeInPath] : [dbPath stringByDeletingLastPathComponent];
        NSString* fileName = argc > 3 ? [[NSString stringWithUTF8String:argv[3]] stringByExpandingTildeInPath] : nil;
        
        [SQCDMigrationHelper generateCoreDataModelFromDBPath:dbPath
                                         outputDirectoryPath:outputPath
                                                    fileName:fileName];
        
        // compile the xcdatamodeld
        if ([fileName length] == 0) {
            fileName = [[dbPath lastPathComponent] stringByDeletingPathExtension];
        }
        
        NSTask* task = [[NSTask alloc] init];
        [task setLaunchPath:@"/Applications/Xcode.app/Contents/Developer/usr/bin/momc"];
        //NSString* options = @"-XD_MOMC_SDKROOT=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator6.0.sdk -XD_MOMC_IOS_TARGET_VERSION=6.0 -MOMC_PLATFORMS iphonesimulator -MOMC_PLATFORMS iphoneos -XD_MOMC_TARGET_VERSION=10.6";
        NSString* options = @"-XD_MOMC_SDKROOT=/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.8.sdk -MOMC_PLATFORMS macosx -XD_MOMC_TARGET_VERSION=10.7";
        NSString* xcModelPath = [[outputPath stringByAppendingPathComponent:fileName] stringByAppendingPathExtension:@"xcdatamodeld"];
        NSString* momdPath = [[outputPath stringByAppendingPathComponent:fileName] stringByAppendingPathExtension:@"momd"];
        NSMutableArray* argsArr = [[NSMutableArray alloc] init];
        [argsArr addObjectsFromArray:[options componentsSeparatedByString:@" "]];
        [argsArr addObject:xcModelPath];
        [argsArr addObject:momdPath];
        [task setArguments:argsArr];
        [task setTerminationHandler:^(NSTask *aTask) {
            int status = [aTask terminationStatus];
            if (status != 0) {
                NSLog(@"Task ended with status %d. Reason: %ld",status,[aTask terminationReason]);
            }
        }];
        [task launch];
        [task waitUntilExit];
        
        // migrate
        [CDMMigrationManager startDataMigration];
        
    }
    return 0;
}


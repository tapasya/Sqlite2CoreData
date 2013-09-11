//
//  main.m
//  sqlite2coredata
//
//  Created by Tapasya on 21/08/13.
//  Copyright (c) 2013 Tapasya. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SQCDDataModelGenerator.h"
#import "SQCDMigrationManager.h"

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
        NSString* outputPath = argc > 2 ? [[NSString stringWithUTF8String:argv[2]] stringByExpandingTildeInPath] : [[dbPath stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"output"];
        NSString* fileName = argc > 3 ? [[NSString stringWithUTF8String:argv[3]] stringByExpandingTildeInPath] : nil;
        
        BOOL xcModelGenerated = [SQCDDataModelGenerator generateCoreDataModelFromDBPath:dbPath
                                         outputDirectoryPath:outputPath
                                                    fileName:fileName];
        if (!xcModelGenerated) {
            return -1;
        }
        
        // compile the xcdatamodeld
        NSLog(@"Compiling xcdatamodel...");
        if ([fileName length] == 0) {
            fileName = [[dbPath lastPathComponent] stringByDeletingPathExtension];
        }
                
        NSTask* task = [[NSTask alloc] init];
        [task setLaunchPath:@"/Applications/Xcode.app/Contents/Developer/usr/bin/momc"];
        NSString* xcModelPath = [[outputPath stringByAppendingPathComponent:fileName] stringByAppendingPathExtension:@"xcdatamodeld"];
        NSString* momdPath = [[outputPath stringByAppendingPathComponent:fileName] stringByAppendingPathExtension:@"momd"];
        NSMutableArray* argsArr = [[NSMutableArray alloc] init];
        [argsArr addObject:xcModelPath];
        [argsArr addObject:momdPath];
        [task setArguments:argsArr];
        [task launch];
        [task waitUntilExit];        
        if ([task terminationReason] != NSTaskTerminationReasonExit) {
            NSLog(@"xcdatamodel compilation failed with status %d",[task terminationStatus]);
            return -1;
        }
        NSLog(@"xcdatamodel compiled successfully");
        
        // migrate
        [SQCDMigrationManager startDataMigrationWithDBPath:dbPath
                                                  momdPath:momdPath
                                                outputPath:outputPath];
        
    }
    return 0;
}


//
//  SQCDPListGenerator.m
//  sqlite2coredata
//
//  Created by Tapasya on 02/09/13.
//  Copyright (c) 2013 Tapasya. All rights reserved.
//

#import "SQCDPListGenerator.h"
#import "SQCDTableInfo.h"

@implementation SQCDPListGenerator

+ (BOOL) generatePListAtPath:(NSString*) filePath
               forTableInfos:(NSDictionary*) tableInfos
{
    //Create a Mutant Dictionary
    NSMutableDictionary *rootDictionary = [[NSMutableDictionary alloc] init];
    
    NSMutableArray* tableInfoArray = [NSMutableArray arrayWithCapacity:tableInfos.count];
    
    for (SQCDTableInfo* tableInfo in [tableInfos allValues]) {
        NSLog(@"Generating pList for table '%@'",tableInfo.sqliteName);
        [tableInfoArray addObject:[tableInfo pListRepresentation]];

    }
    
    [rootDictionary setObject:tableInfoArray forKey:@"tableInfo"];
    
    BOOL isCreated = [rootDictionary writeToFile:filePath atomically:YES];
    
    return isCreated;
}

@end

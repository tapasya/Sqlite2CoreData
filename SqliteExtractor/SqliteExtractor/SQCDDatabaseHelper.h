//
//  SQCDDatabaseHelper.h
//  sqlite2coredata
//
//  Created by Tapasya on 27/08/13.
//  Copyright (c) 2013 Tapasya. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SQCDTableInfo.h"
#import "SQCDColumnInfo.h"
#import "SQCDForeignKeyInfo.h"
#import "sqlite3.h"


@interface SQCDDatabaseHelper : NSObject

+ (NSDictionary*) fetchTableInfos:(NSString*) dbPath;

+(NSMutableDictionary*) inverseRelationships;

@end

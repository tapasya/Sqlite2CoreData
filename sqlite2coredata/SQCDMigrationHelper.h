//
//  SQCDMigrationHelper.h
//  sqlite2coredata
//
//  Created by Tapasya on 21/08/13.
//  Copyright (c) 2013 Tapasya. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SQCDMigrationHelper : NSObject

+ (void) generateCoreDataModelFromDBPath:(NSString*) dbPath outputDirectoryPath:(NSString*) outputPath;

@end

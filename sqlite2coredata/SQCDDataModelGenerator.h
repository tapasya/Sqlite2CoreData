//
//  SQCDMigrationHelper.h
//  sqlite2coredata
//
//  Created by Tapasya on 21/08/13.
//  Copyright (c) 2013 Tapasya. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SQCDDataModelGenerator : NSObject

+(BOOL) generateCoreDataModelFromDBPath:(NSString *)dbPath
                    outputDirectoryPath:(NSString*) outputPath
                               fileName:(NSString*) fileName;
@end

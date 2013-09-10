//
//  CDMMigrationManager.h
//  CoreDataMigration
//
//  Created by Tapasya on 20/08/13.
//  Copyright (c) 2013 Tapasya. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SQCDMigrationManager : NSObject

+(BOOL) startDataMigrationWithDBPath:(NSString*) dbPath
                            momdPath:(NSString*) momnPath
                          outputPath:(NSString*) outputPath;
@end

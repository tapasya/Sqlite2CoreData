//
//  CDMMigrationManager.h
//  CoreDataMigration
//
//  Created by Tapasya on 20/08/13.
//  Copyright (c) 2013 Tapasya. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CDMMigrationManager : NSObject

+ (BOOL) startDataMigration;

+ (BOOL) isDataMigrated;

@end

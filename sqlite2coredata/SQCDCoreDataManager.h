//
//  CDMCoreDataManager.h
//  CoreDataMigration
//
//  Created by Tapasya on 20/08/13.
//  Copyright (c) 2013 Tapasya. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#define DBEXTENSION     @"sqlite"

@interface SQCDCoreDataManager : NSObject
{
    
}

-(id) initWithModelPath:(NSString*) momdPath
        outputDirectory:(NSString*) outputPath;

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end

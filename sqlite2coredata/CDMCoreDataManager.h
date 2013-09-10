//
//  CDMCoreDataManager.h
//  CoreDataMigration
//
//  Created by Tapasya on 20/08/13.
//  Copyright (c) 2013 Tapasya. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#define DATAMODELNAME @"Chinook_Sqlite"
#define DBNAME          @"Chinook_Sqlite"
#define DBEXTENSION     @"sqlite"
#define PLIST_NAME      @"Chinook_Sqlite"

@interface CDMCoreDataManager : NSObject
{
    
}


@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end

//
//  CDMCoreDataManager.m
//  CoreDataMigration
//
//  Created by Tapasya on 20/08/13.
//  Copyright (c) 2013 Tapasya. All rights reserved.
//

#import "CDMCoreDataManager.h"

@implementation CDMCoreDataManager

@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize managedObjectContext = _managedObjectContext;


// Returns the directory the application uses to store the Core Data store file. This code uses a directory named "hg.HGGroup" in the user's Application Support directory.
- (NSURL *)applicationFilesDirectory
{
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    NSURL *appSupportURL = [[fileManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
//    return [appSupportURL URLByAppendingPathComponent:@"cdm"];
    NSURL* appSupportURL = [[NSURL alloc] initFileURLWithPath:@"/Users/adityad/Desktop" isDirectory:YES];
    return [appSupportURL URLByAppendingPathComponent:@"cdm"];
}

// Creates if necessary and returns the managed object model for the application.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel) {
        return _managedObjectModel;
    }
	
    //NSURL *modelURL = [[NSBundle mainBundle] URLForResource:DATAMODELNAME withExtension:@"momd"];
    NSURL *modelDirURL = [[NSURL alloc] initFileURLWithPath:@"/Users/adityad/Developer/ChinookDatabase1.4_Sqlite" isDirectory:YES];
    NSURL *modelURL = [[modelDirURL URLByAppendingPathComponent:DATAMODELNAME] URLByAppendingPathExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
//    _managedObjectModel = [CDMCoreDataManager createModel];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. (The directory for the store is created, if necessary.)
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator) {
        return _persistentStoreCoordinator;
    }
    
    NSManagedObjectModel *mom = [self managedObjectModel];
    if (!mom) {
        NSLog(@"%@:%@ No model to generate a store from", [self class], NSStringFromSelector(_cmd));
        return nil;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *applicationFilesDirectory = [self applicationFilesDirectory];
    NSError *error = nil;
    
    NSDictionary *properties = [applicationFilesDirectory resourceValuesForKeys:@[NSURLIsDirectoryKey] error:&error];
    
    if (!properties) {
        BOOL ok = NO;
        if ([error code] == NSFileReadNoSuchFileError) {
            ok = [fileManager createDirectoryAtPath:[applicationFilesDirectory path] withIntermediateDirectories:YES attributes:nil error:&error];
        }
        if (!ok) {
            // TODO Handle error
//            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    } else {
        if (![properties[NSURLIsDirectoryKey] boolValue]) {
            // Customize and localize this error.
            NSString *failureDescription = [NSString stringWithFormat:@"Expected a folder to store application data, found a file (%@).", [applicationFilesDirectory path]];
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:failureDescription forKey:NSLocalizedDescriptionKey];
            error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:101 userInfo:dict];

            // TODO Handle error
//            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    }
    
    NSURL *url = [applicationFilesDirectory URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite", DATAMODELNAME]];
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    if (![coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:url options:nil error:&error]) {
        // TODO Handle error
//        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    _persistentStoreCoordinator = coordinator;
    
    return _persistentStoreCoordinator;
}

// Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
        [dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];
        NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // TODO Handle error
//        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    
    return _managedObjectContext;
}

+ (NSManagedObjectModel*) createModel
{
    static NSManagedObjectModel *mom = nil;
    
    if (mom != nil) {
        return mom;
    }
    
    NSEntityDescription *accountEntity = [[NSEntityDescription alloc] init];
    [accountEntity setName:@"CDMAccountRuntime"];
    [accountEntity setManagedObjectClassName:@"CDMAccountRuntime"];
    
    NSAttributeDescription *dateAttribute = [[NSAttributeDescription alloc] init];
    [dateAttribute setName:@"modifiedDate"];
    [dateAttribute setAttributeType:NSStringAttributeType];
    [dateAttribute setOptional:NO];
    
    NSAttributeDescription *idAttribute = [[NSAttributeDescription alloc] init];
    [idAttribute setName:@"accountId"];
    [idAttribute setAttributeType:NSStringAttributeType];
    [idAttribute setOptional:NO];
    [idAttribute setDefaultValue:@"LOCAL"];
    
    NSAttributeDescription *nameAttribute = [[NSAttributeDescription alloc] init];
    [nameAttribute setName:@"accountName"];
    [nameAttribute setAttributeType:NSStringAttributeType];
    [nameAttribute setOptional:NO];
    [nameAttribute setDefaultValue:@"No Name"];

    
//    NSExpression *lhs = [NSExpression expressionForEvaluatedObject];
//    NSExpression *rhs = [NSExpression expressionForConstantValue:@0];
//    
//    NSPredicate *validationPredicate = [NSComparisonPredicate
//                                        predicateWithLeftExpression:lhs
//                                        rightExpression:rhs
//                                        modifier:NSDirectPredicateModifier
//                                        type:NSGreaterThanPredicateOperatorType
//                                        options:0];
//    
//    NSString *validationWarning = @"Process ID < 1";
//    
//    [idAttribute setValidationPredicates:@[validationPredicate]
//                  withValidationWarnings:@[validationWarning]];
    
    [accountEntity setProperties:@[dateAttribute, idAttribute, nameAttribute]];
    
    mom = [[NSManagedObjectModel alloc] init];
    [mom setEntities:@[accountEntity]];
    
//    NSDictionary *localizationDictionary = @{
//                                             @"Property/date/Entity/Run":@"Date",
//                                             @"Property/processID/Entity/Run":@"Process ID",
//                                             @"ErrorString/Process ID < 1":@"Process ID must not be less than 1"};
//    
//    [mom setLocalizationDictionary:localizationDictionary];
    
    return mom;
}
@end

//
//  CDMMigrationManager.m
//  CoreDataMigration
//
//  Created by Tapasya on 20/08/13.
//  Copyright (c) 2013 Tapasya. All rights reserved.
//

#import "SQCDMigrationManager.h"
#import "FMDatabase.h"
#import "SQCDCoreDataManager.h"
#import "SqliteExtractor.h"

#define XCUNDEFINED             @"Undefined"
#define XCINT16                 @"Integer 16"
#define XCINT32                 @"Integer 32"
#define XCINT64                 @"Integer 64"
#define XCDECIMAL               @"Decimal"
#define XCDOUBLE                @"Double"
#define XCFLOAT                 @"Float"
#define XCSTRING                @"String"
#define XCBOOL                  @"Boolean"
#define XCDATE                  @"Date"
#define XCBINARY                @"Binary Data"
#define XCTRANFORMABLE          @"Transformable"

@implementation SQCDMigrationManager

#pragma mark - Migration

+(BOOL) startDataMigrationWithDBPath:(NSString*) dbPath
                            momdPath:(NSString*) momnPath
                          outputPath:(NSString*) outputPath
{
    // Set db path to be reused later
    [SQCDMigrationManager dbPath:dbPath];
    
    FMDatabase* database = [SQCDMigrationManager openDatabase];
    
    SQCDCoreDataManager* cdm = [[SQCDCoreDataManager alloc] initWithModelPath:momnPath outputDirectory:outputPath];
    NSManagedObjectContext* moc = [cdm managedObjectContext];
    
    [SQCDMigrationManager migrateTableDataFromDatabase:database
                               toManagedObjectContext:moc
                                    withRelationships:YES];
        
    [database close];
    
    return YES;
}

#pragma mark - data and relationship migration

+ (BOOL) migrateTableDataFromDatabase:(FMDatabase*) database
               toManagedObjectContext:(NSManagedObjectContext*) moc
                    withRelationships:(BOOL) migrateRelationships
{
    NSDictionary *tablesDict = [SQCDMigrationManager tableDictionary];
    
    __block __weak NSError* error;
    
    for (SQCDTableInfo* tableInfo in [tablesDict allValues]) {
        NSString* tableName =  tableInfo.sqliteName;
        
        if (![tableName isEqualToString:@"sqlite_sequence"] && [tableInfo shouldMigrate]){
            
            NSLog(@"***************  Started migration for table %@  ****************", tableInfo.sqliteName);
            
            FMResultSet *results = [database executeQuery:[NSString stringWithFormat:@"select * from %@", tableName]];
            
            while([results next]) {
                // TODO ensure duplicates are not added
                NSManagedObject *entity =  [SQCDMigrationManager createEntityFromResultSet:results
                                                                            withTableInfo:tableInfo
                                                                   inManagedObjectContext:moc];
                [moc save:&error];
                if ( nil != error){
                    NSLog(@"Error while saving %@, %@", entity.entity.name, [error localizedDescription]);
                    for (NSError* detailedError in [[error userInfo] valueForKey:NSDetailedErrorsKey]) {
                        NSLog(@"Error while saving %@", [detailedError debugDescription]);
                    }
                }
            }
            
            NSLog(@"***************  Ended migration for table %@  ****************", tableInfo.sqliteName);

        }
    }
    
    return error != nil;

}

+ (BOOL) addRelationshipsFromDatabase:(FMDatabase*) database
               toManagedObjectContext:(NSManagedObjectContext*) moc
{    
    NSDictionary *tablesDict = [SQCDMigrationManager tableDictionary];
    
    __block __weak NSError* error;
    
    // Iterate each table
    [[tablesDict allValues] enumerateObjectsUsingBlock:^(SQCDTableInfo* tableInfo, NSUInteger idx, BOOL *stop) {
        
        NSArray* foreignKeyInfo = [tableInfo.foreignKeys allValues];
        
        // Iterate over all foreign keys
        [foreignKeyInfo enumerateObjectsUsingBlock:^(SQCDForeignKeyInfo* relationInfo, NSUInteger idx, BOOL *stop) {
            
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            NSString* primaryPropertyName = [[tableInfo primaryColumn] nameForProperty];
            
            [fetchRequest setEntity:[NSEntityDescription entityForName:[relationInfo.fromSqliteTableName capitalizedString] inManagedObjectContext:moc]];
            [fetchRequest setSortDescriptors:@[[[NSSortDescriptor alloc] initWithKey:primaryPropertyName ascending:YES]]];
            error = nil;
            NSArray *fromEntities = [moc executeFetchRequest:fetchRequest error:&error];
            if (!error) {
                for (NSManagedObject* fromEntity in fromEntities) {
                    // TODO should create appropriate object
                    int fromEntityId = [[fromEntity valueForKey:primaryPropertyName] intValue];
                    
                    NSArray* toEntityIds = [SQCDMigrationManager fetchValuesforColumnName:relationInfo.fromSqliteColumnName
                                                                                 inTable:relationInfo.fromSqliteTableName
                                                                          withPrimaryKey:[tableInfo primaryColumn].sqliteName
                                                                                   value:fromEntityId];
                    
                    error = [SQCDMigrationManager setRelationshipForEntity:fromEntity
                                                             toEntityName:[relationInfo.toSqliteTableName capitalizedString]
                                                           toPropertyName:[relationInfo nameForProperty:relationInfo.toSqliteColumnName]
                                                               toEntities:toEntityIds
                                                         withRelationName:relationInfo.relationName
                                                                 isTomany:relationInfo.toMany
                                                   inManagedObjectContext:moc];
                }
            }
        }];
    }];
        
    return error != nil;
}

+ (NSError*) setRelationshipForEntity:(NSManagedObject*) fromEntity
                         toEntityName:(NSString*) toEntityName
                       toPropertyName:(NSString*) toPropertyName
                           toEntities:(NSArray*) toEntityIds
                     withRelationName:(NSString*) relationName
                             isTomany:(BOOL) isToMany
               inManagedObjectContext:(NSManagedObjectContext*) moc
{
    NSError* error;
        
    if ([toEntityIds count]) {
        // Fetch the saved from entites
        NSFetchRequest *toFetchRequest = [[NSFetchRequest alloc] init];
        [toFetchRequest setEntity:[NSEntityDescription entityForName:toEntityName inManagedObjectContext:moc]];
        NSString* predicateString = [NSString stringWithFormat:@"(%@ IN %@)", toPropertyName, @"%@"];
        [toFetchRequest setPredicate: [NSPredicate predicateWithFormat:predicateString, toEntityIds]];
        NSArray* toEntities = [moc executeFetchRequest:toFetchRequest error:&error];
        if (!error) {
            @try {
                if (toEntities.count) {
                    if (isToMany) {
                        [fromEntity setValue:[NSSet setWithArray:toEntities] forKey:relationName];
                    } else{
                        [fromEntity setValue:[toEntities objectAtIndex:0] forKey:relationName];
                    }
                    [moc save:&error];
                }
                
                if ( nil != error)
                    NSLog(@"Error while saving relationship, %@", [error localizedDescription]);
            }
            @catch (NSException *exception) {
                NSLog(@"Exception while setting %@: %@", toEntityName, [exception debugDescription]);
            }
        }else{
            NSLog(@"Error fetching %@ of %@: %@",toEntityName, fromEntity.entity.name,[error localizedDescription]);
        }
    }
    
    return error;
}

#pragma mark - NSManagedObject Creation

+ (NSArray*) fetchEntity:(NSString*) entityName
       primaryPropertyName:(NSString*) propertyName
                 primaryPropertyValue:(int) primaryId
    inManagedObjectContext:(NSManagedObjectContext*) moc
    
{
    NSArray* toEntities = nil;
    @try {
        NSError* error;
        NSFetchRequest *toFetchRequest = [[NSFetchRequest alloc] init];
        [toFetchRequest setEntity:[NSEntityDescription entityForName:entityName inManagedObjectContext:moc]];
        NSString* predicateString = [NSString stringWithFormat:@"(%@ IN %@)", propertyName, @"%@"];
        [toFetchRequest setPredicate: [NSPredicate predicateWithFormat:predicateString,[NSArray arrayWithObject:[NSNumber numberWithInteger:primaryId]]]];
       toEntities = [moc executeFetchRequest:toFetchRequest error:&error];
        
        return toEntities;
    }
    @catch (NSException *exception) {
        NSLog(@"Exception while fetching with property %@ on %@: %@", propertyName, entityName, [exception debugDescription]);
    }
    @finally {
        
    }
    
    return toEntities;
   
}

+(NSManagedObject*) createEntityFromResultSet:(FMResultSet*) results
                                withTableInfo:(SQCDTableInfo*) tableInfo
                       inManagedObjectContext:(NSManagedObjectContext*) moc
{
    NSString* entityName = [tableInfo representedClassName];
    
    NSString *primaryProperty = [[tableInfo primaryColumn] nameForProperty];
    
    NSArray* existingEntities = [SQCDMigrationManager fetchEntity:entityName
                                         primaryPropertyName:primaryProperty
                                        primaryPropertyValue:[results intForColumn:primaryProperty]
                                      inManagedObjectContext:moc];
    
    if (existingEntities.count > 0) {
        NSLog(@"Found Entity %@", entityName);

        return [existingEntities objectAtIndex:0];
    }
    
    NSLog(@"Creating Entity %@", entityName);
    
    id entity = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:moc];
    
    for (SQCDColumnInfo* columnInfo in [tableInfo.columns allValues]) {
        // TODO check for foreign keys
        SQCDForeignKeyInfo* foreignKeyInfo = [tableInfo.foreignKeys valueForKey:columnInfo.sqliteName];
        
        if (foreignKeyInfo != nil && ![foreignKeyInfo.toSqliteTableName isEqualToString:tableInfo.sqliteName]) {
            NSLog(@"Ingnoring foreignkey %@ from %@ to %@", foreignKeyInfo.fromSqliteColumnName, foreignKeyInfo.fromSqliteTableName, foreignKeyInfo.toSqliteTableName);
        }else{
            NSString* propertyName = [columnInfo nameForProperty];
            NSString* columnName = columnInfo.sqliteName;
            NSString* propertyType = [SQCDTypeMapper xctypeFromType:columnInfo.sqlliteType];
            
            id value = nil;
            
            // TODO handle other values
            if ([propertyType isEqualToString:XCSTRING]) {
                value = [results stringForColumn:columnName];
            } else if ([propertyType isEqualToString:XCINT64] || [propertyType isEqualToString:XCINT32]){
                value = [NSNumber numberWithInt:[results intForColumn:columnName]];
            } else if ([propertyType isEqualToString:XCDECIMAL]){
                value = [NSDecimalNumber numberWithFloat:[[results stringForColumn:columnName] floatValue]];
            } else if ([propertyType isEqualToString:XCDATE]){
                value = [results dateForColumn:columnName];
            }else{
                value = [results objectForColumnName:columnName];
            }
            
            if ([value isKindOfClass:[NSNull class]]) {
                value = nil;
            }
            
            @try {
                [entity setValue:value forKey:propertyName];
            }
            @catch (NSException *exception) {
                NSLog(@"Exception while setting %@ on %@: %@", propertyName, entityName, [exception debugDescription]);
            }
            @finally {
                
            }

        }
    }
    
    if (entity != nil) {
        [SQCDMigrationManager createRelationshipForEntity:entity
                                  inManagedObjectContext:moc
                                               tableInfo:tableInfo
                                               resultSet:results];
    }
    
    return entity;
}

+(void) createRelationshipForEntity:(NSManagedObject*) fromEntity
             inManagedObjectContext:(NSManagedObjectContext*) moc
                          tableInfo:(SQCDTableInfo*) tableInfo
                          resultSet:(FMResultSet*) fromResultSet
{
    FMDatabase* database = [SQCDMigrationManager openDatabase];
    
    // Fetch all the related entries from the destination table
    NSArray* foreignKeyInfo = [tableInfo.foreignKeys allValues];
    // Iterate over all foreign keys
    [foreignKeyInfo enumerateObjectsUsingBlock:^(SQCDForeignKeyInfo* relationInfo, NSUInteger idx, BOOL *stop) {
        
        if (![relationInfo.toSqliteTableName isEqualToString:tableInfo.sqliteName]) {
            
            NSString* toEntityName = [relationInfo.toSqliteTableName capitalizedString];
            NSString* toTableName = relationInfo.toSqliteTableName;
            NSString* toColumnName = relationInfo.toSqliteColumnName;
            NSString* fromColumnName = relationInfo.fromSqliteColumnName;
            NSString* relationName = relationInfo.relationName;
            BOOL isToMany = relationInfo.toMany;
            
            // Get the destination table info
            NSDictionary *tablesDict = [SQCDMigrationManager tableDictionary];
            SQCDTableInfo* toTableInfo = [tablesDict valueForKey:toTableName];
            
            // Fetch results from db and create entities
            int fromColumnValue = [fromResultSet intForColumn:fromColumnName];
            FMResultSet *results = [database executeQuery:[NSString stringWithFormat:@"select * from %@ where %@=%d", toTableName, toColumnName, fromColumnValue]];
            NSMutableArray* relationEntities = [NSMutableArray array];
            while([results next]) {
                NSLog(@"Creating Relation %@ form %@ to %@", relationName, fromEntity.entity.name, toEntityName);

                NSManagedObject *relationEntity =  [SQCDMigrationManager createEntityFromResultSet:results
                                                                                    withTableInfo:toTableInfo
                                                                           inManagedObjectContext:moc];
                [relationEntities addObject:relationEntity];
            }
            
            @try {
                // Set the reation property upon the fromEntity
                if (relationEntities.count) {
                    if (isToMany) {
                        [fromEntity setValue:[NSSet setWithArray:relationEntities] forKey:relationName];
                    } else{
                        [fromEntity setValue:[relationEntities objectAtIndex:0] forKey:relationName];
                    }
                }
            }
            @catch (NSException *exception) {
                NSLog(@"Exception while setting %@ on %@: %@", relationName, fromEntity.entity.name, [exception debugDescription]);
            }
            @finally {
                
            }
        }
    }];
    
    [database close];
}

#pragma mark - DB helpers

+ (NSArray*) fetchValuesforColumnName:(NSString*) columnName
                                 inTable:(NSString*) tableName
                       withPrimaryKey:(NSString*) primaryKey
                                value:(int) primaryId
{
    FMDatabase* database = [SQCDMigrationManager openDatabase];

    FMResultSet *results = [database executeQuery:[NSString stringWithFormat:@"select %@ from %@ where %@=%d", columnName, tableName ,primaryKey, primaryId]];
    // Addd all ids to array
    NSMutableArray* toEntityIds = [[NSMutableArray alloc] init];
    while ([results next]) {
        NSNumber* toEntityId = [NSNumber numberWithInteger:[results intForColumn:columnName]];
        [toEntityIds addObject:toEntityId];
    }
    
    [database close];
    
    return toEntityIds;
}

+ (FMDatabase *)openDatabase
{
    FMDatabase *db = [FMDatabase databaseWithPath:[SQCDMigrationManager dbPath:nil]];
    if (![db open])
        NSLog(@"Failed to open database!");
    return db;
}

#pragma mark plist helper
+(NSDictionary*) tableDictionary
{
    static dispatch_once_t pred;
    static NSDictionary* inverseDict = nil;
    dispatch_once(&pred, ^{
        inverseDict = [SQCDDatabaseHelper fetchTableInfos:[SQCDMigrationManager dbPath:nil]];
        if (inverseDict == nil) {
            NSLog(@"Could not initialize inverse dictionary");
        }
    });
    
    return inverseDict;
}

+(NSString*) dbPath:(NSString*) _dbPath
{
    static dispatch_once_t pathd;
    static NSString* dbPath = nil;
    dispatch_once(&pathd, ^{
        dbPath  = _dbPath;
        if (dbPath == nil) {
            NSLog(@"Could not initialize db path");
        }
    });
    
    return dbPath;
}

@end

//
//  SQCDMigrationHelper.m
//  sqlite2coredata
//
//  Created by Tapasya on 21/08/13.
//  Copyright (c) 2013 Tapasya. All rights reserved.
//

#import "SQCDMigrationHelper.h"
#import "SQCDTableInfo.h"
#import "SQCDColumnInfo.h"
#import "sqlite3.h"

#define kXCDataModelDExtention   @"xcdatamodeld"
#define kXCDataModelExtention    @"xcdatamodel"
#define kXCDContents             @"contents"

@implementation SQCDMigrationHelper

+(void) generateCoreDataModelFromDBPath:(NSString *)dbPath
                    outputDirectoryPath:(NSString*) outputPath
                               fileName:(NSString*) fileName
{
    NSArray* tableNames = [SQCDMigrationHelper fetchTableNames:dbPath];
    NSMutableArray* tableInfos = [NSMutableArray arrayWithCapacity:tableNames.count];
    for (NSString* tableName in tableNames) {
        SQCDTableInfo* tableInfo = [[SQCDTableInfo alloc] init];
        tableInfo.sqliteName = tableName;
        tableInfo.columns = [SQCDMigrationHelper allColumnsInTableNamed:tableName dbPath:dbPath];
        [tableInfos addObject:tableInfo];
    }
    
    // Create root node
    NSXMLElement *root =(NSXMLElement *)[NSXMLNode elementWithName:@"model"];
    [root addAttribute:[NSXMLNode attributeWithName:@"name" stringValue:@""]];
    [root addAttribute:[NSXMLNode attributeWithName:@"type" stringValue:@"com.apple.IDECoreDataModeler.DataModel"]];
    [root addAttribute:[NSXMLNode attributeWithName:@"documentVersion" stringValue:@"1.0"]];
    [root addAttribute:[NSXMLNode attributeWithName:@"lastSavedToolsVersion" stringValue:@"2061"]];
    [root addAttribute:[NSXMLNode attributeWithName:@"systemVersion" stringValue:@"12E55"]];
    [root addAttribute:[NSXMLNode attributeWithName:@"minimumToolsVersion" stringValue:@"Automatic"]];
    [root addAttribute:[NSXMLNode attributeWithName:@"macOSVersion" stringValue:@"Automatic"]];
    [root addAttribute:[NSXMLNode attributeWithName:@"iOSVersion" stringValue:@"Automatic"]];
    
    // Create document with root Node
    NSXMLDocument *xmlDoc = [[NSXMLDocument alloc] initWithRootElement:root];
    [xmlDoc setVersion:@"1.0"];
    [xmlDoc setCharacterEncoding:@"UTF-8"];
    [xmlDoc setStandalone:YES];
    
    for (SQCDTableInfo *tableInfo in tableInfos) {
        NSLog(@"Generating xml for table '%@'",tableInfo.sqliteName);
        NSXMLElement* tableEntity = [tableInfo xmlRepresentation];
        [root addChild:tableEntity];
    }
    
    // NSLog(@"XML Document\n%@", xmlDoc);
    NSData *xmlData = [xmlDoc XMLDataWithOptions:NSXMLNodePrettyPrint];
    
    NSFileManager* fm = [NSFileManager defaultManager];
    
    if ([fileName length] == 0) {
        fileName = [[dbPath lastPathComponent] stringByDeletingPathExtension];
    }
    
    // TODO remove hardcoded filenames
    NSString* xcdmdPath = [outputPath stringByAppendingFormat:@"/%@.%@/", fileName, kXCDataModelDExtention];
    NSString* xcdmPath = [xcdmdPath stringByAppendingFormat:@"%@.%@/", fileName, kXCDataModelExtention];
    NSString* contentsPath = [xcdmPath stringByAppendingString:kXCDContents];
    
    BOOL isCreated = [fm createDirectoryAtPath:xcdmdPath
                   withIntermediateDirectories:YES
                                    attributes:nil
                                         error:nil] &&
                    [fm createDirectoryAtPath:xcdmPath
                  withIntermediateDirectories:YES
                                   attributes:nil
                                        error:nil] &&
                    [fm createFileAtPath:contentsPath
                                contents:xmlData
                              attributes:nil];
    
    isCreated ? NSLog(@"Data model succesfully generated at %@ with name %@", outputPath, fileName): NSLog(@"Data model generation failed");
}

+ (NSArray*) fetchTableNames:(NSString*) dbPath
{
    sqlite3*            _db;
    
    int err = sqlite3_open([dbPath fileSystemRepresentation], &_db );
    if(err != SQLITE_OK) {
        NSLog(@"error opening!: %d", err);
    }else{
        
        sqlite3_stmt* statement;
        NSString *query = @"SELECT name FROM sqlite_master WHERE type=\'table\'";
        int retVal = sqlite3_prepare_v2(_db,
                                        [query UTF8String],
                                        -1,
                                        &statement,
                                        NULL);
        
        NSMutableArray *selectedRecords = [NSMutableArray array];
        if ( retVal == SQLITE_OK )
        {
            while(sqlite3_step(statement) == SQLITE_ROW )
            {
                NSString *value = [NSString stringWithCString:(const char *)sqlite3_column_text(statement, 0)
                                                     encoding:NSUTF8StringEncoding];
                [selectedRecords addObject:value];
            }
        }
        
        sqlite3_clear_bindings(statement);
        sqlite3_finalize(statement);
        
        return selectedRecords;
    }
    
    return nil;

}

+ (NSArray*) allColumnsInTableNamed:(NSString*)tableName dbPath:(NSString*) dbPath
{
    // Will return nil if fails, empty array if no columns
    
    sqlite3*            _db;
    
    int err = sqlite3_open([dbPath fileSystemRepresentation], &_db );
    if(err != SQLITE_OK) {
        NSLog(@"error opening!: %d", err);
    }else{
        char* errMsg = NULL ;
        int result ;
        
        NSString* statement ;
        statement = [[NSString alloc] initWithFormat:@"pragma table_info(%@)", tableName] ;
        char** results ;
        int nRows ;
        int nColumns ;
        result = sqlite3_get_table(
                                   _db,        /* An open database */
                                   [statement UTF8String], /* SQL to be executed */ &results, /* Result is in char *[] that this points to */ &nRows, /* Number of result rows written here */ &nColumns, /* Number of result columns written here */
                                   &errMsg    /* Error msg written here */
                                   ) ;
        
        
        NSMutableArray* columnNames = nil ;
        if (!(result == SQLITE_OK)) {
            // Invoke the error handler for this class
    //        [self showError:errMsg from:16 code:result] ;
            sqlite3_free(errMsg) ;
        }
        else {
            int nameColumnIndex;
            int typeColumnIndex;
            int nonnullColumnIndex;
            for (int j=0; j<nColumns; j++) {
                if (strcmp(results[j], "name") == 0) {
                    nameColumnIndex = j;
                } else if(strcmp(results[j], "type") == 0){
                    typeColumnIndex = j;
                } else if (strcmp(results[j], "notnull")){
                    nonnullColumnIndex = j;
                }
            }
            
            if (nameColumnIndex<nColumns && typeColumnIndex < nColumns) {
                int i ;
                columnNames = [[NSMutableArray alloc] init] ;
                for (i=0; i<nRows; i++) {
                    SQCDColumnInfo* column = [[SQCDColumnInfo alloc] init];
                    column.sqliteName = [NSString stringWithCString:results[(i+1)*nColumns + nameColumnIndex] encoding:NSUTF8StringEncoding];
                    column.sqlliteType = [NSString stringWithCString:results[(i+1)*nColumns + typeColumnIndex] encoding:NSUTF8StringEncoding];
                    column.isNonNull = [[NSString stringWithCString:results[(i+1)*nColumns + nonnullColumnIndex] encoding:NSUTF8StringEncoding] boolValue];
                    column.sqliteTableName = tableName;
                    // TO DO add non null and default value
                    [columnNames addObject:column] ;
                }
            }
        }
        sqlite3_free_table(results) ;
    
        NSArray* output = nil ;
        if (columnNames != nil) {
            output = [columnNames copy] ;
        }
        
        return output ;
    }
    
    return nil;
}



@end

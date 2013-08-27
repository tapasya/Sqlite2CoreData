//
//  SQCDDatabaseHelper.m
//  sqlite2coredata
//
//  Created by Tapasya on 27/08/13.
//  Copyright (c) 2013 Tapasya. All rights reserved.
//

#import "SQCDDatabaseHelper.h"

@implementation SQCDDatabaseHelper

+ (NSArray*) fetchTableInfos:(NSString*) dbPath
{
    sqlite3*            _db;
    
    int err = sqlite3_open([dbPath fileSystemRepresentation], &_db );
    if(err != SQLITE_OK) {
        NSLog(@"error opening!: %d", err);
    }else{
        
        sqlite3_stmt* statement;
        NSString *query = @"SELECT name, sql FROM sqlite_master WHERE type=\'table\'";
        int retVal = sqlite3_prepare_v2(_db,
                                        [query UTF8String],
                                        -1,
                                        &statement,
                                        NULL);
        
        NSMutableArray *tableInfos = [NSMutableArray array];
        if ( retVal == SQLITE_OK )
        {
            while(sqlite3_step(statement) == SQLITE_ROW )
            {
                NSString *tableName = [NSString stringWithCString:(const char *)sqlite3_column_text(statement, 0)
                                                         encoding:NSUTF8StringEncoding];
                NSString *tableSql = [NSString stringWithCString:(const char *)sqlite3_column_text(statement, 1)
                                                        encoding:NSUTF8StringEncoding];
                SQCDTableInfo* tableInfo = [[SQCDTableInfo alloc] init];
                tableInfo.sqliteName = tableName;
                tableInfo.sqlStatement = tableSql;
                
                tableInfo.columns = [SQCDDatabaseHelper allColumnsInTableNamed:tableInfo.sqliteName dbPath:dbPath];
                
                tableInfo.foreignKeys = [SQCDDatabaseHelper allForeignKeysInTableNamed:tableInfo.sqliteName inDatabase:_db];
                
                [tableInfos addObject:tableInfo];
            }
        }
        
        sqlite3_clear_bindings(statement);
        sqlite3_finalize(statement);
        sqlite3_close(_db);
        
        return tableInfos;
    }
    
    return nil;
    
}

+ (NSArray*) allForeignKeysInTableNamed:(NSString*)tableName inDatabase:(sqlite3*) db
{
    sqlite3_stmt* statement;
    NSString *query = [[NSString alloc] initWithFormat:@"pragma foreign_key_list(%@)", tableName];
    int retVal = sqlite3_prepare_v2(db,
                                    [query UTF8String],
                                    -1,
                                    &statement,
                                    NULL);
    
    NSMutableArray *tableInfos = [NSMutableArray array];
    if ( retVal == SQLITE_OK )
    {
        while(sqlite3_step(statement) == SQLITE_ROW )
        {
            NSString *toTableName = [NSString stringWithCString:(const char *)sqlite3_column_text(statement, 2)
                                                     encoding:NSUTF8StringEncoding];
            NSString *fromColName = [NSString stringWithCString:(const char *)sqlite3_column_text(statement, 3)
                                                    encoding:NSUTF8StringEncoding];

            NSString *toColName = [NSString stringWithCString:(const char *)sqlite3_column_text(statement, 4)
                                                       encoding:NSUTF8StringEncoding];

            SQCDForeignKeyInfo* fkInfo = [SQCDForeignKeyInfo new];
            fkInfo.fromSqliteTableName = tableName;
            fkInfo.toSqliteTableName = toTableName;
            fkInfo.fromSqliteColumnName = fromColName;
            fkInfo.toSqliteColumnName = toColName;
            
            [tableInfos addObject:fkInfo];
        }
    }
    
    sqlite3_clear_bindings(statement);
    sqlite3_finalize(statement);
    
    return tableInfos;

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
                    // TO DO default value reading
                    [columnNames addObject:column] ;
                }
            }
        }
        sqlite3_free_table(results) ;
        
        sqlite3_close(_db);
        
        NSArray* output = nil ;
        if (columnNames != nil) {
            output = [columnNames copy] ;
        }
        
        return output ;
    }
    
    return nil;
}

@end

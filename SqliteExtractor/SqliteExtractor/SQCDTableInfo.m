//
//  SQLiteTableInfo.m
//  sqlite2coredata
//
//  Created by Tapasya on 22/08/13.
//  Copyright (c) 2013 Tapasya. All rights reserved.
//

#import "SQCDTableInfo.h"
#import "SQCDColumnInfo.h"
#import "SQCDForeignKeyInfo.h"
#import "SQCDDatabaseHelper.h"

#import "NSString+Inflections.h"

@implementation SQCDTableInfo

#ifdef __MAC_OS_X_VERSION_MIN_REQUIRED
-(NSXMLElement*) xmlRepresentation
{
    // Add an entity
    NSXMLElement* entity = (NSXMLElement*)[NSXMLNode elementWithName:@"entity"];
    // Entity Name
    [entity addAttribute:[NSXMLNode attributeWithName:@"name" stringValue:[self representedClassName]]];
    [entity addAttribute:[NSXMLNode attributeWithName:@"representedClassName" stringValue:[self representedClassName]]];
    [entity addAttribute:[NSXMLNode attributeWithName:@"syncable" stringValue:@"YES"]];
    
    for (SQCDColumnInfo* colunmInfo in [self.columns allValues]) {
        SQCDForeignKeyInfo* foreignKeyInfo = [self.foreignKeys valueForKey:colunmInfo.sqliteName];
        
        if (foreignKeyInfo != nil && ![foreignKeyInfo.toSqliteTableName isEqualToString:self.sqliteName]) {
            // TODO Need to findout about the many to many scenario
            [entity addChild:[foreignKeyInfo xmlRepresentation]];
            
        } else{
            [entity addChild:[colunmInfo xmlRepresentation]];
        }
    }
    
    NSMutableArray* inverseRelationForTable = [[SQCDDatabaseHelper inverseRelationships] valueForKey:self.sqliteName];
    
    for (SQCDForeignKeyInfo* inverseInfo in inverseRelationForTable) {
        
        SQCDForeignKeyInfo* manyToManyRelation = [SQCDDatabaseHelper manyToManyRelationFromTable:self.sqliteName
                                                                                         toTable:inverseInfo.toSqliteTableName];
        if (manyToManyRelation != nil) {
            [entity addChild:[manyToManyRelation xmlRepresentation]];
        }else if (![inverseInfo.toSqliteTableName isEqualToString:inverseInfo.fromSqliteTableName]) {
            [entity addChild:[inverseInfo xmlRepresentation]];
        }
    }
    
    return entity;
}
#endif

- (NSString*) representedClassName
{
    NSString* tableName = [self.sqliteName lowercaseString];
    
    NSArray *components = [tableName componentsSeparatedByString:@"_"];
    NSMutableString *output = [NSMutableString string];
    
    for (NSUInteger i = 0; i < components.count; i++) {
        [output appendString:[components[i] capitalizedString]];
    }
    
    return [NSString stringWithString:output];
}

- (NSDictionary*) pListRepresentation
{
    NSMutableDictionary* tablePlistDict = [NSMutableDictionary dictionary];
    [tablePlistDict setObject:[self representedClassName] forKey:@"entityName"];
    [tablePlistDict setObject:self.sqliteName forKey:@"tableName"];
    
    NSMutableArray* columnPlist = [NSMutableArray array];
    NSMutableArray* fkplist = [NSMutableArray array];
    NSMutableArray* pkColumnNames = [NSMutableArray array];
    for (SQCDColumnInfo* columnInfo in [self.columns allValues]) {
        SQCDForeignKeyInfo* foreignKeyInfo = [self.foreignKeys valueForKey:columnInfo.sqliteName];
        
        if (foreignKeyInfo != nil && ![foreignKeyInfo.toSqliteTableName isEqualToString:self.sqliteName]) {
            NSMutableDictionary* fkPlistDict = [NSMutableDictionary dictionaryWithDictionary:[foreignKeyInfo pListRepresentation]];
            [fkPlistDict setValue:[NSNumber numberWithBool:(columnInfo.isNonNull==NO)] forKey:@"optional"];
            [fkplist addObject:fkPlistDict];
        } else{
            [columnPlist addObject:[columnInfo pListRepresentation]];
        }
        if (columnInfo.isPrimaryKey) {
            [pkColumnNames addObject:columnInfo.sqliteName];
        }
    }
    
    [tablePlistDict setObject:columnPlist forKey:@"columnmap"];
    [tablePlistDict setObject:pkColumnNames forKey:@"primarykeys"];
    [tablePlistDict setObject:fkplist forKey:@"foreignkeymap"];
    
    NSMutableArray* inverseRelationForTable = [[SQCDDatabaseHelper inverseRelationships] valueForKey:self.sqliteName];

    for (SQCDForeignKeyInfo* inverseInfo in inverseRelationForTable) {
        if (![inverseInfo.toSqliteTableName isEqualToString:inverseInfo.fromSqliteTableName]) {

        }
    }
    
    return tablePlistDict;
}

- (SQCDColumnInfo*) primaryColumn
{
    for (SQCDColumnInfo* columnInfo in [self.columns allValues]) {
        if (columnInfo.isPrimaryKey) {
            return columnInfo;
        }
    }
    return nil;
}

-(BOOL) isManyToMany
{
    for (SQCDColumnInfo* colunmInfo in [self.columns allValues]) {
        SQCDForeignKeyInfo* foreignKeyInfo = [self.foreignKeys valueForKey:colunmInfo.sqliteName];
        if (!(foreignKeyInfo != nil && ![foreignKeyInfo.toSqliteTableName isEqualToString:self.sqliteName])) {
            // Found valid column
            return NO;
        }
    }
    
    return YES;
}

@end

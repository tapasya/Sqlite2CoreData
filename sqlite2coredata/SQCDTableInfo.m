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

@implementation SQCDTableInfo

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
        
        if (foreignKeyInfo != nil) {
            // TODO Need to findout about the many to many scenario
            [entity addChild:[foreignKeyInfo xmlRepresentation]];
            
        } else{
            [entity addChild:[colunmInfo xmlRepresentation]];
        }
    }
    
    NSMutableArray* inverseRelationForTable = [[SQCDDatabaseHelper inverseRelationships] valueForKey:self.sqliteName];
    
    for (SQCDForeignKeyInfo* inverseInfo in inverseRelationForTable) {
        [entity addChild:[inverseInfo xmlRepresentation]];

    }
    
    return entity;
}

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
    
    for (SQCDColumnInfo* colunmInfo in [self.columns allValues]) {
        SQCDForeignKeyInfo* foreignKeyInfo = [self.foreignKeys valueForKey:colunmInfo.sqliteName];
        
        if (foreignKeyInfo != nil) {
            
        } else{
            [columnPlist addObject:[colunmInfo pListRepresentation]];
        }
    }
    
    [tablePlistDict setObject:columnPlist forKey:@"columnmap"];
    
    NSMutableArray* inverseRelationForTable = [[SQCDDatabaseHelper inverseRelationships] valueForKey:self.sqliteName];
    
    for (SQCDForeignKeyInfo* inverseInfo in inverseRelationForTable) {
        
    }

    
    return tablePlistDict;
}

@end

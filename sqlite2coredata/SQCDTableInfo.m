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
        BOOL isForeignKey = NO;
        for (SQCDForeignKeyInfo* foreignKeys in self.foreignKeys) {
            isForeignKey = [foreignKeys.fromSqliteColumnName isEqualToString:colunmInfo.sqliteName];
        }
        if (isForeignKey) {
            // TODO handle relationships based on foreign keys.
            // Unique foreign key represents one to one on both sides
            // Non unique foreign key represents one to many on one side and one to one on other side
            // Need to findout about the many to many scenario
            // Should figure out a way to handle inverse relationship
            
            
        } else{
            [entity addChild:[colunmInfo xmlRepresentation]];
        }
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

@end

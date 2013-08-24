//
//  SQLiteTableInfo.m
//  sqlite2coredata
//
//  Created by Tapasya on 22/08/13.
//  Copyright (c) 2013 Tapasya. All rights reserved.
//

#import "SQCDTableInfo.h"
#import "SQCDColumnInfo.h"

@implementation SQCDTableInfo

-(NSXMLElement*) xmlRepresentation
{
    // Add an entity
    NSXMLElement* entity = (NSXMLElement*)[NSXMLNode elementWithName:@"entity"];
    // Entity Name
    [entity addAttribute:[NSXMLNode attributeWithName:@"name" stringValue:[self representedClassName]]];
    [entity addAttribute:[NSXMLNode attributeWithName:@"representedClassName" stringValue:[self representedClassName]]];
    [entity addAttribute:[NSXMLNode attributeWithName:@"syncable" stringValue:@"YES"]];
    
    for (SQCDColumnInfo* colunmInfo in self.columns) {
        [entity addChild:[colunmInfo xmlRepresentation]];
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

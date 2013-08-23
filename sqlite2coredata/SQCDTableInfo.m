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
    [entity addAttribute:[NSXMLNode attributeWithName:@"name" stringValue:[self.sqliteName capitalizedString]]];
    [entity addAttribute:[NSXMLNode attributeWithName:@"representedClassName" stringValue:[self.sqliteName capitalizedString]]];
    [entity addAttribute:[NSXMLNode attributeWithName:@"syncable" stringValue:@"YES"]];
    
    for (SQCDColumnInfo* colunmInfo in self.columns) {
        [entity addChild:[colunmInfo xmlRepresentation]];
    }
    
    return entity;
}

@end

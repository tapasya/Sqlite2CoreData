//
//  SQLiteColumnInfo.m
//  sqlite2coredata
//
//  Created by Tapasya on 22/08/13.
//  Copyright (c) 2013 Tapasya. All rights reserved.
//

#import "SQCDColumnInfo.h"
#import "SQCDTypeMapper.h"

@implementation SQCDColumnInfo

- (NSXMLElement*) xmlRepresentation
{
    NSXMLElement* childAttr = (NSXMLElement*) [NSXMLNode elementWithName:@"attribute"];
    [childAttr addAttribute:[NSXMLNode attributeWithName:@"name" stringValue:[self nameForProperty]]];
    [childAttr addAttribute:[NSXMLNode attributeWithName:@"optional" stringValue:self.isNonNull ? @"NO":@"YES"]];
    [childAttr addAttribute:[NSXMLNode attributeWithName:@"attributeType" stringValue:[SQCDTypeMapper xctypeFromType:self.sqlliteType]]];
    [childAttr addAttribute:[NSXMLNode attributeWithName:@"syncable" stringValue:@"YES"]];
    
    return childAttr;
}

- (NSString*) nameForProperty
{
    NSString* columnName = self.sqliteName;
    
    if ([[columnName lowercaseString] isEqualToString:@"id"]) {
        columnName = [[self.sqliteTableName lowercaseString] stringByAppendingFormat:@"_%@", self.sqliteName];
    }
    
    NSArray *components = [columnName componentsSeparatedByString:@"_"];
    NSMutableString *output = [NSMutableString string];
    
    for (NSUInteger i = 0; i < components.count; i++) {
        if (i == 0) {
            [output appendString:components[i]];
        } else {
            [output appendString:[components[i] capitalizedString]];
        }
    }
    
    return [NSString stringWithString:output];}

@end

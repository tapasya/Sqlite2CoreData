//
//  SQCDForeignKeyInfo.m
//  sqlite2coredata
//
//  Created by Tapasya on 27/08/13.
//  Copyright (c) 2013 Tapasya. All rights reserved.
//

#import "SQCDForeignKeyInfo.h"

@implementation SQCDForeignKeyInfo

-(NSXMLElement*) xmlRepresentation
{
    NSXMLElement* childAttr = (NSXMLElement*) [NSXMLNode elementWithName:@"relationship"];
    [childAttr addAttribute:[NSXMLNode attributeWithName:@"name" stringValue:self.fromSqliteColumnName]];
    [childAttr addAttribute:[NSXMLNode attributeWithName:@"destinationEntity" stringValue:self.toSqliteTableName]];
    [childAttr addAttribute:[NSXMLNode attributeWithName:@"toMany" stringValue:(self.toMany ? @"YES":@"NO")]];
    [childAttr addAttribute:[NSXMLNode attributeWithName:@"inverseName" stringValue:self.toSqliteColumnName]];
    [childAttr addAttribute:[NSXMLNode attributeWithName:@"inverseEntity" stringValue:self.toSqliteTableName]];
    [childAttr addAttribute:[NSXMLNode attributeWithName:@"syncable" stringValue:@"YES"]];
    return childAttr;
}


@end

//
//  SQCDRelationshipInfo.m
//  sqlite2coredata
//
//  Created by aditya-d on 8/27/13.
//  Copyright (c) 2013 Tapasya. All rights reserved.
//

#import "SQCDRelationshipInfo.h"

@implementation SQCDRelationshipInfo

-(NSXMLElement*) xmlRepresentation
{
    NSXMLElement* childAttr = (NSXMLElement*) [NSXMLNode elementWithName:@"relationship"];
    [childAttr addAttribute:[NSXMLNode attributeWithName:@"name" stringValue:self.sqliteReferencingColumnName]];
    [childAttr addAttribute:[NSXMLNode attributeWithName:@"destinationEntity" stringValue:self.sqliteReferencedTableName]];
    [childAttr addAttribute:[NSXMLNode attributeWithName:@"toMany" stringValue:(self.toMany ? @"YES":@"NO")]];
    [childAttr addAttribute:[NSXMLNode attributeWithName:@"inverseName" stringValue:self.sqliteReferencedColumnName]];
    [childAttr addAttribute:[NSXMLNode attributeWithName:@"inverseEntity" stringValue:self.sqliteReferencedTableName]];
    [childAttr addAttribute:[NSXMLNode attributeWithName:@"syncable" stringValue:@"YES"]];
    return childAttr;
}

@end

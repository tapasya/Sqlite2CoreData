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
    
    [childAttr addAttribute:[NSXMLNode attributeWithName:@"name" stringValue:self.isInverse ? self.toSqliteColumnName : self.fromSqliteColumnName]];
   
    [childAttr addAttribute:[NSXMLNode attributeWithName:@"destinationEntity" stringValue:self.isInverse ? [self.fromSqliteTableName capitalizedString] :[self.toSqliteTableName capitalizedString]]];
    
    
    [childAttr addAttribute:[NSXMLNode attributeWithName:@"inverseName" stringValue: self.isInverse ? self.fromSqliteColumnName : self.toSqliteColumnName]];
    
    [childAttr addAttribute:[NSXMLNode attributeWithName:@"inverseEntity" stringValue:self.isInverse ? [self.fromSqliteTableName capitalizedString] : [self.toSqliteTableName capitalizedString]]];
    
    [childAttr addAttribute:[NSXMLNode attributeWithName:@"toMany" stringValue:(self.toMany ? @"YES":@"NO")]];
    [childAttr addAttribute:[NSXMLNode attributeWithName:@"deletionRule" stringValue:@"Nullify"]];
    [childAttr addAttribute:[NSXMLNode attributeWithName:@"syncable" stringValue:@"YES"]];
    
    return childAttr;
}

- (id) copyWithZone:(NSZone *)zone;
{
    SQCDForeignKeyInfo* copy = [SQCDForeignKeyInfo new];
    if (copy) {
        copy.fromSqliteColumnName = self.fromSqliteColumnName;
        copy.fromSqliteTableName = self.fromSqliteTableName;
        copy.toSqliteTableName = self.toSqliteTableName;
        copy.toSqliteColumnName = self.toSqliteColumnName;
        copy.toMany = self.toMany;
        copy.isInverse = self.isInverse;
    }
    
    return copy;
}

@end

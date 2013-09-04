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
    
    [childAttr addAttribute:[NSXMLNode attributeWithName:@"name" stringValue:self.relationName]];
   
    [childAttr addAttribute:[NSXMLNode attributeWithName:@"destinationEntity" stringValue:[self.toSqliteTableName capitalizedString]]];
    
    
    [childAttr addAttribute:[NSXMLNode attributeWithName:@"inverseName" stringValue:self.invRelationName]];
    
    [childAttr addAttribute:[NSXMLNode attributeWithName:@"inverseEntity" stringValue:[self.toSqliteTableName capitalizedString]]];
    
    [childAttr addAttribute:[NSXMLNode attributeWithName:@"toMany" stringValue:(self.toMany ? @"YES":@"NO")]];
    [childAttr addAttribute:[NSXMLNode attributeWithName:@"deletionRule" stringValue:@"Nullify"]];
    [childAttr addAttribute:[NSXMLNode attributeWithName:@"syncable" stringValue:@"YES"]];
    
    return childAttr;
}

- (NSDictionary*) pListRepresentation
{
    NSMutableDictionary* columnPlistDict = [NSMutableDictionary dictionary];
    
    [columnPlistDict setObject:self.relationName forKey:@"name"];
//    [columnPlistDict setObject:[self nameForProperty] forKey:@"propertyName"];
//    [columnPlistDict setObject:[SQCDTypeMapper xctypeFromType:self.sqlliteType] forKey:@"propertyType"];
//    [columnPlistDict setObject:[NSNumber numberWithBool:(self.isNonNull==NO)] forKey:@"optional"];
    
    return columnPlistDict;
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

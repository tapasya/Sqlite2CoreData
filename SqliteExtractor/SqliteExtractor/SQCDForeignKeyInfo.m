//
//  SQCDForeignKeyInfo.m
//  sqlite2coredata
//
//  Created by Tapasya on 27/08/13.
//  Copyright (c) 2013 Tapasya. All rights reserved.
//

#import "SQCDForeignKeyInfo.h"

@implementation SQCDForeignKeyInfo

- (id) init
{
    self = [super init];
    if (self) {
        self.isOptional = NO;
    }
    return self;
}

#ifdef __MAC_OS_X_VERSION_MIN_REQUIRED
// Other kinds of Mac OS

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
    
    // TODO should set based on optional parameter
    if (self.isOptional) {
        [childAttr addAttribute:[NSXMLNode attributeWithName:@"minCount" stringValue:@"0"]];
    } else{
        [childAttr addAttribute:[NSXMLNode attributeWithName:@"minCount" stringValue:@"1"]];
    }
    
    if (!self.toMany) {
        [childAttr addAttribute:[NSXMLNode attributeWithName:@"maxCount" stringValue:@"1"]];
    }
    
    //TODO should handle 
    [childAttr addAttribute:[NSXMLNode attributeWithName:@"optional" stringValue:self.isInverse || self.isOptional ? @"YES": @"NO"]];
    
    return childAttr;
}

#endif

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

- (NSString*) nameForProperty:(NSString*) columnName
{
    columnName = [columnName lowercaseString];
        
    NSArray *components = [columnName componentsSeparatedByString:@"_"];
    NSMutableString *output = [NSMutableString string];
    
    for (NSUInteger i = 0; i < components.count; i++) {
        if (i == 0) {
            [output appendString:components[i]];
        } else {
            [output appendString:[components[i] capitalizedString]];
        }
    }
    
    return [NSString stringWithString:output];
}


- (NSDictionary*) pListRepresentation
{
    NSMutableDictionary* relationPlistDict = [NSMutableDictionary dictionary];
    
    [relationPlistDict setObject:[self.fromSqliteTableName capitalizedString] forKey:@"fromEntityName"];
    [relationPlistDict setObject:[self.toSqliteTableName capitalizedString] forKey:@"toEntityName"];
    
    [relationPlistDict setObject:self.relationName forKey:@"relationName"];
    [relationPlistDict setObject:self.invRelationName forKey:@"inverseRelationName"];

    [relationPlistDict setObject:self.fromSqliteTableName forKey:@"fromTableName"];
    [relationPlistDict setObject:self.toSqliteTableName forKey:@"toTableName"];

    [relationPlistDict setObject:self.fromSqliteColumnName forKey:@"fromColumnName"];
    [relationPlistDict setObject:self.toSqliteColumnName forKey:@"toColumnName"];
    
    [relationPlistDict setObject:[self nameForProperty:self.fromSqliteColumnName] forKey:@"fromPropertyName"];
    [relationPlistDict setObject:[self nameForProperty:self.toSqliteColumnName] forKey:@"toPropertyName"];

    [relationPlistDict setObject:self.toMany?@"YES":@"NO" forKey:@"isToMany"];
    
    return relationPlistDict;
}

@end

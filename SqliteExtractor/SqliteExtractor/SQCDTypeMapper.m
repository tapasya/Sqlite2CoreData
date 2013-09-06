//
//  TypeMapper.m
//  sourcefilegen
//
//  Created by aditya-d on 8/22/13.
//  Copyright (c) 2013 aditya-d. All rights reserved.
//

#import "SQCDTypeMapper.h"

#define XCUNDEFINED @"Undefined"
#define XCINT16 @"Integer 16"
#define XCINT32 @"Integer 32"
#define XCINT64 @"Integer 64"
#define XCDECIMAL @"Decimal"
#define XCDOUBLE @"Double"
#define XCFLOAT @"Float"
#define XCSTRING @"String"
#define XCBOOL @"Boolean"
#define XCDATE @"Date"
#define XCBINARY @"Binary Data"
#define XCTRANFORMABLE @"Transformable"

@implementation SQCDTypeMapper

+(NSString*)xctypeFromType:(NSString*)sqlliteType
{
    static dispatch_once_t pred;
    static NSDictionary* typesDict = nil;
    dispatch_once(&pred, ^{
        typesDict = [SQCDTypeMapper datatypeMap];
        if (typesDict == nil) {
            NSLog(@"Could not initialize types dictionary");
        }
    });
    
    // strip of brackets and anything in between
    NSRange bracketRange = [sqlliteType rangeOfString:@"("];
    if (bracketRange.location != NSNotFound) {
        sqlliteType = [sqlliteType substringToIndex:bracketRange.location];
    }
    NSString* xcType = [typesDict valueForKey:[sqlliteType uppercaseString]];
    if (xcType == nil) {
        NSLog(@"WARNING: Using '%@' for sqllite type '%@'",XCUNDEFINED,sqlliteType);
        xcType = XCUNDEFINED;
    }
    return xcType;
}

+(NSDictionary*)datatypeMap
{
    NSMutableDictionary* map = [[NSMutableDictionary alloc] init];
    //Integers
    [map setValue:XCINT32 forKey:@"INT"];
    [map setValue:XCINT64 forKey:@"INTEGER"];
    [map setValue:XCINT16 forKey:@"TINYINT"];
    [map setValue:XCINT16 forKey:@"SMALLINT"];
    [map setValue:XCINT32 forKey:@"MEDIUMINT"];
    [map setValue:XCINT64 forKey:@"BIGINT"];
    [map setValue:XCINT64 forKey:@"UNSIGNED BIG INT"];
    [map setValue:XCINT16 forKey:@"INT2"];
    [map setValue:XCINT64 forKey:@"INT8"];
    
    //Text
    [map setValue:XCSTRING forKey:@"CHARACTER"];
    [map setValue:XCSTRING forKey:@"VARCHAR"];
    [map setValue:XCSTRING forKey:@"VARYING CHARACTER"];
    [map setValue:XCSTRING forKey:@"NCHAR"];
    [map setValue:XCSTRING forKey:@"NATIVE CHARACTER"];
    [map setValue:XCSTRING forKey:@"NVARCHAR"];
    [map setValue:XCSTRING forKey:@"TEXT"];
    [map setValue:XCSTRING forKey:@"CLOB"];
    [map setValue:XCSTRING forKey:@"STRING"];
    
    //Binary
    [map setValue:XCBINARY forKey:@"BLOB"];
    [map setValue:XCBINARY forKey:@"BINARY"];
    
    //Real,Decimal
    [map setValue:XCDOUBLE forKey:@"REAL"];
    [map setValue:XCDOUBLE forKey:@"DOUBLE"];
    [map setValue:XCDOUBLE forKey:@"DOUBLE PRECISION"];
    [map setValue:XCFLOAT forKey:@"FLOAT"];
    [map setValue:XCDECIMAL forKey:@"DECIMAL"];
    [map setValue:XCDECIMAL forKey:@"NUMERIC"];
    
    //Date
    [map setValue:XCDATE forKey:@"DATE"];
    [map setValue:XCDATE forKey:@"DATETIME"];
    [map setValue:XCDATE forKey:@"TIMESTAMP"];
    
    //Boolean
    [map setValue:XCBOOL forKey:@"BOOLEAN"];
    [map setValue:XCBOOL forKey:@"BOOL"];
    
    return map;
}

@end

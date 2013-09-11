//
//  TypeMapper.h
//  sourcefilegen
//
//  Created by aditya-d on 8/22/13.
//  Copyright (c) 2013 aditya-d. All rights reserved.
//

#import <Foundation/Foundation.h>

#define XCUNDEFINED             @"Undefined"
#define XCINT16                 @"Integer 16"
#define XCINT32                 @"Integer 32"
#define XCINT64                 @"Integer 64"
#define XCDECIMAL               @"Decimal"
#define XCDOUBLE                @"Double"
#define XCFLOAT                 @"Float"
#define XCSTRING                @"String"
#define XCBOOL                  @"Boolean"
#define XCDATE                  @"Date"
#define XCBINARY                @"Binary Data"
#define XCTRANFORMABLE          @"Transformable"


@interface SQCDTypeMapper : NSObject

+(NSString*) xctypeFromType:(NSString*)sqlliteType;

@end

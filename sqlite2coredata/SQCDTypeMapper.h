//
//  TypeMapper.h
//  sourcefilegen
//
//  Created by aditya-d on 8/22/13.
//  Copyright (c) 2013 aditya-d. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SQCDTypeMapper : NSObject

+(NSString*) xctypeFromType:(NSString*)sqlliteType;

@end

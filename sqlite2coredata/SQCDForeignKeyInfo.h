//
//  SQCDForeignKeyInfo.h
//  sqlite2coredata
//
//  Created by Tapasya on 27/08/13.
//  Copyright (c) 2013 Tapasya. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SQCDForeignKeyInfo : NSObject

@property (nonatomic, strong) NSString* fromSqliteTableName;
@property (nonatomic, strong) NSString* toSqliteTableName;
@property (nonatomic, strong) NSString* fromSqliteColumnName;
@property (nonatomic, strong) NSString* toSqliteColumnName;


@end

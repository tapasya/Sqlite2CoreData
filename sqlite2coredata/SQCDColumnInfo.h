//
//  SQLiteColumnInfo.h
//  sqlite2coredata
//
//  Created by Tapasya on 22/08/13.
//  Copyright (c) 2013 Tapasya. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SQCDColumnInfo : NSObject

@property (nonatomic, strong) NSString* sqliteName;
@property (nonatomic, strong) NSString* sqlliteType;
@property (nonatomic, strong) NSString* sqliteDefaultValue;
@property (nonatomic, assign) BOOL isNonNull;
@property (nonatomic, assign) BOOL isPrimaryKey;

@property (nonatomic, assign) NSString* sqliteTableName;

-(NSXMLElement*) xmlRepresentation;

- (NSDictionary*) pListRepresentation;

@end

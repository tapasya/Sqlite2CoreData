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
@property (nonatomic, strong) NSString* relationName;
@property (nonatomic, strong) NSString* invRelationName;
@property (nonatomic, assign) BOOL toMany;
@property (nonatomic, assign) BOOL isInverse;

#ifdef __MAC_OS_X_VERSION_MIN_REQUIRED
-(NSXMLElement*) xmlRepresentation;
#endif

- (NSDictionary*) pListRepresentation;

- (NSString*) nameForProperty:(NSString*) columnName;

@end

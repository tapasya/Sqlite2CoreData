//
//  SQLiteTableInfo.h
//  sqlite2coredata
//
//  Created by Tapasya on 22/08/13.
//  Copyright (c) 2013 Tapasya. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SQCDColumnInfo.h"

@interface SQCDTableInfo : NSObject

@property (nonatomic, strong) NSDictionary* columns;

@property (nonatomic, strong) NSString* sqliteName;

@property (nonatomic, strong) NSString* sqlStatement;

@property (nonatomic, strong) NSDictionary* foreignKeys;

- (NSString*) representedClassName;

- (SQCDColumnInfo*) primaryColumn;

- (BOOL) shouldMigrate;

#ifdef __MAC_OS_X_VERSION_MIN_REQUIRED
-(NSXMLElement*) xmlRepresentation;
#endif
- (NSDictionary*) pListRepresentation;

@end

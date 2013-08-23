//
//  SQLiteTableInfo.h
//  sqlite2coredata
//
//  Created by Tapasya on 22/08/13.
//  Copyright (c) 2013 Tapasya. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SQCDTableInfo : NSObject

@property (nonatomic, strong) NSArray* columns;

@property (nonatomic, strong) NSString* sqliteName;

-(NSXMLElement*) xmlRepresentation;

@end

//
//  SQCDPListGenerator.h
//  sqlite2coredata
//
//  Created by Tapasya on 02/09/13.
//  Copyright (c) 2013 Tapasya. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SQCDPListGenerator : NSObject

+ (BOOL) generatePListAtPath:(NSString*) filePath
               forTableInfos:(NSDictionary*) tableInfos;
@end

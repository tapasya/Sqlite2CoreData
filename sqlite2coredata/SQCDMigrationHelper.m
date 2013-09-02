//
//  SQCDMigrationHelper.m
//  sqlite2coredata
//
//  Created by Tapasya on 21/08/13.
//  Copyright (c) 2013 Tapasya. All rights reserved.
//

#import "SQCDMigrationHelper.h"
#import "SQCDDatabaseHelper.h"
#import "SQCDPListGenerator.h"

#define kXCDataModelDExtention   @"xcdatamodeld"
#define kXCDataModelExtention    @"xcdatamodel"
#define kXCDContents             @"contents"

@implementation SQCDMigrationHelper

+(void) generateCoreDataModelFromDBPath:(NSString *)dbPath
                    outputDirectoryPath:(NSString*) outputPath
                               fileName:(NSString*) fileName
{        
    // Create root node
    NSXMLElement *root =(NSXMLElement *)[NSXMLNode elementWithName:@"model"];
    [root addAttribute:[NSXMLNode attributeWithName:@"name" stringValue:@""]];
    [root addAttribute:[NSXMLNode attributeWithName:@"type" stringValue:@"com.apple.IDECoreDataModeler.DataModel"]];
    [root addAttribute:[NSXMLNode attributeWithName:@"documentVersion" stringValue:@"1.0"]];
    [root addAttribute:[NSXMLNode attributeWithName:@"lastSavedToolsVersion" stringValue:@"2061"]];
    [root addAttribute:[NSXMLNode attributeWithName:@"systemVersion" stringValue:@"12E55"]];
    [root addAttribute:[NSXMLNode attributeWithName:@"minimumToolsVersion" stringValue:@"Automatic"]];
    [root addAttribute:[NSXMLNode attributeWithName:@"macOSVersion" stringValue:@"Automatic"]];
    [root addAttribute:[NSXMLNode attributeWithName:@"iOSVersion" stringValue:@"Automatic"]];
    
    // Create document with root Node
    NSXMLDocument *xmlDoc = [[NSXMLDocument alloc] initWithRootElement:root];
    [xmlDoc setVersion:@"1.0"];
    [xmlDoc setCharacterEncoding:@"UTF-8"];
    [xmlDoc setStandalone:YES];
    
    NSDictionary* tableInfos = [SQCDDatabaseHelper fetchTableInfos:dbPath];

    for (SQCDTableInfo *tableInfo in [tableInfos allValues]) {
        NSLog(@"Generating xml for table '%@'",tableInfo.sqliteName);
        NSXMLElement* tableEntity = [tableInfo xmlRepresentation];
        [root addChild:tableEntity];
    }
    
    // NSLog(@"XML Document\n%@", xmlDoc);
    NSData *xmlData = [xmlDoc XMLDataWithOptions:NSXMLNodePrettyPrint];
    
    NSFileManager* fm = [NSFileManager defaultManager];
    
    if ([fileName length] == 0) {
        fileName = [[dbPath lastPathComponent] stringByDeletingPathExtension];
    }
    
    NSString* xcdmdPath = [outputPath stringByAppendingFormat:@"/%@.%@/", fileName, kXCDataModelDExtention];
    NSString* xcdmPath = [xcdmdPath stringByAppendingFormat:@"%@.%@/", fileName, kXCDataModelExtention];
    NSString* contentsPath = [xcdmPath stringByAppendingString:kXCDContents];
    
    BOOL isCreated = [fm createDirectoryAtPath:xcdmdPath
                   withIntermediateDirectories:YES
                                    attributes:nil
                                         error:nil] &&
                    [fm createDirectoryAtPath:xcdmPath
                  withIntermediateDirectories:YES
                                   attributes:nil
                                        error:nil] &&
                    [fm createFileAtPath:contentsPath
                                contents:xmlData
                              attributes:nil];
    
    isCreated ? NSLog(@"Data model succesfully generated at %@ with name %@", outputPath, fileName): NSLog(@"Data model generation failed");
    
    if (isCreated) {
        NSString* plistPath = [outputPath stringByAppendingFormat:@"/%@.plist", fileName];
        isCreated = [SQCDPListGenerator generatePListAtPath:plistPath forTableInfos:tableInfos];
        
        isCreated ? NSLog(@"Plist succesfully generated at %@ with name %@", plistPath, fileName): NSLog(@"Plist generation failed");

    }
    
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:60]];
}
@end

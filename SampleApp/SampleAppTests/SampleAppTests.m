//
//  SampleAppTests.m
//  SampleAppTests
//
//  Created by Aditya Dasgupta on 9/14/13.
//  Copyright (c) 2013 Aditya Dasgupta. All rights reserved.
//

#import <CoreData/CoreData.h>

#import "SampleAppTests.h"
#import "Album.h"
#import "Artist.h"

@implementation SampleAppTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

-(void)testInsertNewAlbum
{
    // MOM
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Chinook" withExtension:@"momd"];
    NSManagedObjectModel* mom = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    // Store Coordinator
    if (!mom) {
        STAssertTrue(NO, @"%@:%@ No model to generate a store from", [self class], NSStringFromSelector(_cmd));
        return;
    }
    
    NSError *error = nil;
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"Chinook" withExtension:@"sqlite"];
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    if (![coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:url options:nil error:&error]) {
        STAssertTrue(NO, @"Error adding persistence store: %@",[error localizedDescription]);
        return;
    }
    
    // Context
    NSManagedObjectContext* moc = [[NSManagedObjectContext alloc] init];
    [moc setPersistentStoreCoordinator:coordinator];
    
    // Insert new album
    Album* newAlbum = (Album*)[NSEntityDescription insertNewObjectForEntityForName:@"Album" inManagedObjectContext:moc];
    newAlbum.albumid = [NSNumber numberWithInt:500];
    newAlbum.title = @"Desert Rain";
    // fetch artist
    NSFetchRequest* fetchReq = [[NSFetchRequest alloc] initWithEntityName:@"Artist"];
    [fetchReq setPredicate:[NSPredicate predicateWithFormat:@"artistid = 1"]];
    error = nil;
    NSArray* artists = [moc executeFetchRequest:fetchReq error:&error];
    if (error) {
        STAssertTrue(NO, @"Error fetching record: %@",[error localizedDescription]);
        return;
    }
    newAlbum.artist = [artists lastObject];
    
    error = nil;
    [moc save:&error];
    if (error) {
        STAssertTrue(NO, @"Error saving record: %@",[error localizedDescription]);
    }
    
    // test inverse relationship
    STAssertTrue([[newAlbum.artist albums] containsObject:newAlbum], @"Error establishing inverse relationship: Artist '%@' not associated with album '%@'",newAlbum.artist.name,newAlbum.title);
}

@end

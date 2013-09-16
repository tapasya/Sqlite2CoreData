# Sqlite2Coredata
**Tool to migrate Standard Sqlite Database to Core Data**

Sqlite2CoreData is a command line tool to migrate the Sqlite database to to Core Data compatible database. It generates the Datamodel file and Core Data Sqlite file which can be imported to Mac/iOS projects and used with Core Data. 
Main purpose of the tool is to ease the migration process. It generates Datamodel by creating entities based on the table schema. Foreign Key information is used to generate the relationship information.

For more details and sample usage visit the [blog post](http://blog.imaginea.com/migrating-sqlite-to-core-data/)

## What it is?
- Command line Tool
- Xcdatamodeld Generator
- Data Migrator to Core Data compatible Sqlite


## What it is not?
- ~~Core Data Version Updater~~
- ~~Core Data Replacement~~
- ~~Wrapper for Core Data~~

## Usage

### Command Line
1. Download the distribution.zip folder and extract
2. From terminal browse to the extracted folder
3. Run `./sqlite2coredata "path_to_database_file"`

### XCode
1. Clone the repository 
2. Open `Sqlite2CoreData.xcodeproj` file
3. Select Edit Schema and select Arguments tab
4. Specify the path to the database

Output Files are saved to a folder named Output in the same directory containing the input database

## Requirements

- Mac OSX 10.7+
- Xcode 4+
- Xcode Command Line Tools

## Next Steps

Next up for `Sqlite2CoreData` are the following:

- Migrating many to many relationships
- Migrating up the referential constraints
- Optimizing setting up relationships

## Credits

- [FMDB](https://github.com/ccgus/fmdb) is being used for Sqlite Interactions.
- [Infections](https://github.com/adamelliot/Inflections) is used to generate Relationship names based on foreign key info

## Creators

- [Tapasya](http://github.com/tapasya)  
- [Aditya](http://github.com/adienthu)  


## License

Sqlite2CoreData is available under the MIT license. See the LICENSE file for more info.

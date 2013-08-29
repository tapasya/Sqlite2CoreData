/*
NSString+Inflections.h
Inflections

Copyright (c) 2010 Adam Elliot (adam@adamelliot.com)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

/*
This code is a port of the Ruby ActiveSupport Inflector which is part of
rails. It's design is after inflection.js which is a very useful port of the
inflector that is for JavaScript. This port was originally written by
Adam Elliot (adam@adamelliot.com). Usage of this port requires RegexKitLite.

The code for this project can be found at: http://github.com/adamelliot/

See the README for instructions on how to use it in your project.
*/

#import <Foundation/Foundation.h>
#import "RegexKitLite.h"


@interface NSString (Inflections)

+ (NSArray *)uncountableWords;
+ (NSArray *)pluralRules;
+ (NSArray *)singularRules;
+ (NSArray *)nonTitlecasedWords;

- (NSString *)pluralize;
- (NSString *)singularize;
- (NSString *)humanize;
- (NSString *)titleize;
- (NSString *)tableize;
- (NSString *)classify;
- (NSString *)camelize;
- (NSString *)camelizeWithLowerFirstLetter;
- (NSString *)underscore;
- (NSString *)dasherize;
- (NSString *)demodulize;
- (NSString *)foreignKey;
- (NSString *)foreignKeyWithoutIdUnderscore;
- (NSString *)ordinalize;
- (NSString *)capitalize;

@end

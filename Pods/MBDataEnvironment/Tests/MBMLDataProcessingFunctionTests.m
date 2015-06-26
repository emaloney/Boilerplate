//
//  MBMLDataProcessingFunctionTests.m
//  Mockingbird Data Environment Unit Tests
//
//  Created by Evan Coyne Maloney on 1/25/12.
//  Copyright (c) 2012 Gilt Groupe. All rights reserved.
//

#import "MBDataEnvironmentTestSuite.h"

/******************************************************************************/
#pragma mark -
#pragma mark MBMLDataProcessingFunctionTests class
/******************************************************************************/

@interface MBMLDataProcessingFunctionTests : MBDataEnvironmentTestSuite
@end

@implementation MBMLDataProcessingFunctionTests

/*
    <Function class="MBMLDataProcessingFunctions" name="collectionPassesTest" input="pipedExpressions"/>
    <Function class="MBMLDataProcessingFunctions" name="containsValue" input="pipedObjects"/>
    <Function class="MBMLDataProcessingFunctions" name="setContains" input="pipedExpressions"/>
    <Function class="MBMLDataProcessingFunctions" name="selectFirstValue" input="pipedExpressions"/>
    <Function class="MBMLDataProcessingFunctions" name="valuesPassingTest" input="pipedExpressions"/>
    <Function class="MBMLDataProcessingFunctions" name="valuesIntersect" input="pipedObjects"/>
    <Function class="MBMLDataProcessingFunctions" name="join" input="pipedObjects"/>
    <Function class="MBMLDataProcessingFunctions" name="split" input="pipedStrings"/>
    <Function class="MBMLDataProcessingFunctions" name="splitLines" input="string"/>
    <Function class="MBMLDataProcessingFunctions" name="appendArrays" input="pipedObjects"/>
    <Function class="MBMLDataProcessingFunctions" name="flattenArrays" input="pipedObjects"/>
    <Function class="MBMLDataProcessingFunctions" name="filter" input="pipedExpressions"/>
    <Function class="MBMLDataProcessingFunctions" name="list" input="pipedExpressions"/>
    <Function class="MBMLDataProcessingFunctions" name="pruneMatchingLeaves" input="pipedExpressions"/>
    <Function class="MBMLDataProcessingFunctions" name="pruneNonmatchingLeaves" input="pipedExpressions"/>
    <Function class="MBMLDataProcessingFunctions" name="associate" input="pipedExpressions"/>
    <Function class="MBMLDataProcessingFunctions" name="associateWithSingleValue" input="pipedExpressions"/>
    <Function class="MBMLDataProcessingFunctions" name="associateWithArray" input="pipedExpressions"/>
    <Function class="MBMLDataProcessingFunctions" name="sort" input="pipedExpressions"/>
    <Function class="MBMLDataProcessingFunctions" name="mergeDictionaries" input="pipedExpressions"/>
    <Function class="MBMLDataProcessingFunctions" name="unique" input="object"/>
    <Function class="MBMLDataProcessingFunctions" name="distributeArrayElements" input="pipedObjects"/>
    <Function class="MBMLDataProcessingFunctions" name="groupArrayElements" input="pipedObjects"/>
    <Function class="MBMLDataProcessingFunctions" name="reduce" input="pipedExpressions"/>
*/

- (void) testCollectionPassesTest
{
    MBLogInfoTrace();

    //
    // test expected successes
    //
    BOOL passes = [MBExpression asBoolean:@"^collectionPassesTest($nameList|$item.firstName.length -GT 0)"];
    XCTAssertTrue(passes);

    passes = [MBExpression asBoolean:@"^collectionPassesTest($nameList|$item.firstName == Debbie)"];
    XCTAssertFalse(passes);

    //
    // test expected failures
    //
    MBExpressionError* err = nil;
    [MBExpression asBoolean:@"^collectionPassesTest()" error:&err];
    expectError(err);

    err = nil;
    [MBExpression asBoolean:@"^collectionPassesTest($nameList)" error:&err];
    expectError(err);

    err = nil;
    [MBExpression asBoolean:@"^collectionPassesTest($nameList|$item.firstName.length -GT 0|foo)" error:&err];
    expectError(err);
}

- (void) testContainsValue
{
    MBLogInfoTrace();

    //
    // test expected successes
    //
    BOOL contains = [MBExpression asBoolean:@"^containsValue($nameList|$(Jill Test))"];
    XCTAssertTrue(contains);

    contains = [MBExpression asBoolean:@"^containsValue($nameList|$newYorkTeams)"];
    XCTAssertFalse(contains);

    contains = [MBExpression asBoolean:@"^containsValue($nameList|$newYorkTeams|$(Debbie Test))"];
    XCTAssertTrue(contains);

    //
    // test expected failures
    //
    MBExpressionError* err = nil;
    [MBExpression asBoolean:@"^containsValue()" error:&err];
    expectError(err);

    err = nil;
    [MBExpression asBoolean:@"^containsValue($nameList)" error:&err];
    expectError(err);

    err = nil;
    [MBExpression asBoolean:@"^containsValue(string|foo)" error:&err];
    expectError(err);
}

- (void) testSetContains
{
    MBLogInfoTrace();

    //
    // test expected successes
    //
    BOOL contains = [MBExpression asBoolean:@"^setContains($testSet|$(Jill Test))"];
    XCTAssertTrue(contains);
    contains = [MBExpression asBoolean:@"^setContains($testSet|something nonexistent)"];
    XCTAssertFalse(contains);

    //
    // test expected failures
    //
    MBExpressionError* err = nil;
    [MBExpression asBoolean:@"^setContains()" error:&err];
    expectError(err);

    err = nil;
    [MBExpression asBoolean:@"^setContains($testSet)" error:&err];
    expectError(err);

    err = nil;
    [MBExpression asBoolean:@"^setContains($NULL|item)" error:&err];
    expectError(err);

    err = nil;
    [MBExpression asBoolean:@"^setContains($testSet|$(Jill Test)|$(Barrett Test))" error:&err];
    expectError(err);
}

- (void) testSelectFirstValue
{
    MBLogInfoTrace();

    //
    // test expected successes
    //
    NSString* foo = [MBExpression asObject:@"^selectFirstValue($NULL|foo)"];
    XCTAssertTrue([foo isKindOfClass:[NSString class]]);
    XCTAssertEqualObjects(foo, @"foo");

    foo = [MBExpression asObject:@"^selectFirstValue($NULL|$null|$NULL|$null|$NULL|$null|foo)"];
    XCTAssertTrue([foo isKindOfClass:[NSString class]]);
    XCTAssertEqualObjects(foo, @"foo");

    //
    // test expected failures
    //
    MBExpressionError* err = nil;
    [MBExpression asObject:@"^selectFirstValue(foo)" error:&err];
    expectError(err);

    err = nil;
    [MBExpression asObject:@"^selectFirstValue()" error:&err];
    expectError(err);
}

- (void) testValuesPassingTest
{
    MBLogInfoTrace();

    //
    // test expected successes
    //
    NSArray* values1 = [MBExpression asObject:@"^valuesPassingTest($testSet|$item.firstName == Jill)"];
    XCTAssertTrue([values1 isKindOfClass:[NSArray class]]);
    XCTAssertTrue(values1.count == 1);
    id jill = [MBExpression asObject:@"$(Jill Test)"];
    XCTAssertEqualObjects(values1[0], jill);

    NSArray* values2 = [MBExpression asObject:@"^valuesPassingTest($testMap|!^hasPrefix($item|T))"];
    XCTAssertTrue([values2 isKindOfClass:[NSArray class]]);
    XCTAssertTrue(values2.count == 2);
    NSSet* set = [NSSet setWithArray:values2];
    XCTAssertTrue([set containsObject:@"One"]);
    XCTAssertTrue([set containsObject:@"Four"]);

    NSArray* values3 = [MBExpression asObject:@"^valuesPassingTest($testSet|$testMap|$item == Two -OR (^isDictionary($item) -AND $item.species == cat))"];
    XCTAssertTrue([values3 isKindOfClass:[NSArray class]]);
    XCTAssertTrue(values3.count == 2);
    id barrett = [MBExpression asObject:@"$(Barrett Test)"];
    set = [NSSet setWithArray:values3];
    XCTAssertTrue([set containsObject:barrett]);
    XCTAssertTrue([set containsObject:@"Two"]);

    //
    // test expected failures
    //
    MBExpressionError* err = nil;
    [MBExpression asBoolean:@"^valuesPassingTest()" error:&err];
    expectError(err);

    err = nil;
    [MBExpression asBoolean:@"^valuesPassingTest($testMap)" error:&err];
    expectError(err);

    err = nil;
    [MBExpression asBoolean:@"^valuesPassingTest($NULL|T)" error:&err];
    expectError(err);
}

- (void) testValuesIntersect
{
    MBLogInfoTrace();

    //
    // test expected successes
    //
    BOOL result = [MBExpression asBoolean:@"^valuesIntersect($testMap|$testValues)"];
    XCTAssertTrue(result);
    result = [MBExpression asBoolean:@"^valuesIntersect($testKeys|$testValues)"];
    XCTAssertFalse(result);
    result = [MBExpression asBoolean:@"^valuesIntersect(^setWithArray($testKeys)|^array(Key 2))"];
    XCTAssertTrue(result);

    //
    // test expected failures
    //
    MBExpressionError* err = nil;
    [MBExpression asBoolean:@"^valuesIntersect($testMap|$NULL)" error:&err];
    expectError(err);

    err = nil;
    [MBExpression asBoolean:@"^valuesIntersect($testMap)" error:&err];
    expectError(err);

    err = nil;
    [MBExpression asBoolean:@"^valuesIntersect($testMap|$testValues|$testValues)" error:&err];
    expectError(err);
}

- (void) testJoin
{
    MBLogInfoTrace();

    //
    // test expected successes
    //
    NSString* joined = [MBExpression asString:@"^join($testKeys|; )"];
    XCTAssertNotNil(joined);
    XCTAssertEqualObjects(joined, @"Key 1; Key 2; Key 3; Key 4");

    joined = [MBExpression asString:@"^join($testKeys|$testValues|, )"];
    XCTAssertNotNil(joined);
    XCTAssertEqualObjects(joined, @"Key 1, Key 2, Key 3, Key 4, One, Two, Three, Four");

    //
    // test expected failures
    //
    MBExpressionError* err = nil;
    [MBExpression asString:@"^join($testKeys)" error:&err];
    expectError(err);

    err = nil;
    [MBExpression asString:@"^join(, |$testKeys)" error:&err];
    expectError(err);

    err = nil;
    [MBExpression asString:@"^join($testKeys|$testValues)" error:&err];
    expectError(err);

    err = nil;
    [MBExpression asString:@"^join($testKeys|not a collection|, )" error:&err];
    expectError(err);
}

- (void) testSplit
{
    MBLogInfoTrace();

    //
    // test expected successes
    //
    NSArray* testArray1 = [MBExpression asObject:@"$testKeys"];
    NSArray* array1 = [MBExpression asObject:@"^split(, |Key 1, Key 2, Key 3, Key 4)"];
    XCTAssertTrue([array1 isKindOfClass:[NSArray class]]);
    XCTAssertEqualObjects(array1, testArray1);

    //
    // test expected failures
    //
    MBExpressionError* err = nil;
    [MBExpression asObject:@"^split(, )" error:&err];
    expectError(err);

    err = nil;
    [MBExpression asObject:@"^split(, |Split, Me|But, Not, Me!)" error:&err];
    expectError(err);
}

- (void) testSplitLines
{
    MBLogInfoTrace();

    //
    // test expected successes
    //
    // (note: failures are not tested because this function doesn't
    //        have any error conditions; it won't return MBMLFunctionError)
    //
    NSArray* testSplit = [MBExpression asObject:@"$testValues"];
    NSArray* split = [MBExpression asObject:@"^splitLines($splitLines)"];
    XCTAssertTrue([split isKindOfClass:[NSArray class]]);
    XCTAssertEqualObjects(split, testSplit);

    split = [MBExpression asObject:@"^splitLines(One\nTwo\nThree\nFour)"];
    XCTAssertTrue([split isKindOfClass:[NSArray class]]);
    XCTAssertEqualObjects(split, testSplit);
}

- (void) testAppendArrays
{
    MBLogInfoTrace();

    //
    // test expected successes
    //
    NSArray* testKeys = [MBExpression asObject:@"$testKeys"];
    NSArray* testValues = [MBExpression asObject:@"$testValues"];
    NSArray* newYorkTeams = [MBExpression asObject:@"$newYorkTeams"];
    NSArray* testArray = [testKeys arrayByAddingObjectsFromArray:[testValues arrayByAddingObjectsFromArray:newYorkTeams]];

    NSArray* array = [MBExpression asObject:@"^appendArrays($testKeys|$testValues|$newYorkTeams)"];
    XCTAssertTrue([array isKindOfClass:[NSArray class]]);
    XCTAssertEqualObjects(array, testArray);

    //
    // test expected failures
    //
    MBExpressionError* err = nil;
    [MBExpression asObject:@"^appendArrays()" error:&err];
    expectError(err);

    err = nil;
    [MBExpression asObject:@"^appendArrays($testKeys)" error:&err];
    expectError(err);

    err = nil;
    [MBExpression asObject:@"^appendArrays($testKeys|notAnArray)" error:&err];
    expectError(err);
}

- (void) testFlattenArrays
{
    MBLogInfoTrace();

    //
    // test expected successes
    //
    NSArray* testAgainst = [MBExpression asObject:@"^appendArrays($testKeys|$testValues|$newYorkTeams)"];
    NSArray* flattened = [MBExpression asObject:@"^flattenArrays($toFlatten)"];
    XCTAssertTrue([flattened isKindOfClass:[NSArray class]]);
    XCTAssertEqualObjects(flattened, testAgainst);
    flattened = [MBExpression asObject:@"^flattenArrays($toFlatten|$toFlatten)"];
    XCTAssertTrue([flattened isKindOfClass:[NSArray class]]);
    XCTAssertEqualObjects(flattened, [testAgainst arrayByAddingObjectsFromArray:testAgainst]);

    //
    // test expected failures
    //
    MBExpressionError* err = nil;
    [MBExpression asObject:@"^flattenArrays()" error:&err];
    expectError(err);

    err = nil;
    [MBExpression asObject:@"^flattenArrays($NULL)" error:&err];
    expectError(err);

    err = nil;
    [MBExpression asObject:@"^flattenArrays($toFlatten|$NULL)" error:&err];
    expectError(err);

    err = nil;
    [MBExpression asObject:@"^flattenArrays($toFlatten|string)" error:&err];
    expectError(err);
}

- (void) testFilter
{
    MBLogInfoTrace();

    //
    // test expected successes
    //
    MBScopedVariables* scope = [MBScopedVariables enterVariableScope];

    // filter an array
    NSArray* humansArray = [MBExpression asObject:@"^filter($nameList|$item.species == human|matchAll)"];
    XCTAssertTrue([humansArray isKindOfClass:[NSArray class]]);
    XCTAssertTrue(humansArray.count == 4);
    scope[@"humansArray"] = humansArray;
    NSArray* testHumans = [MBExpression asObject:@"^array($(Jill Test)|$(Evan Test)|$(Debbie Test)|$(Lauren Test))"];
    XCTAssertEqualObjects(humansArray, testHumans);

    NSArray* humansWithNiecesArray = [MBExpression asObject:@"^filter($humansArray|$item[nieces]|matchAll)"];
    XCTAssertTrue([humansWithNiecesArray isKindOfClass:[NSArray class]]);
    XCTAssertTrue(humansWithNiecesArray.count == 2);
    NSArray* testHumansWithNiecesArray = [MBExpression asObject:@"^array($(Jill Test)|$(Debbie Test))"];
    XCTAssertEqualObjects(humansWithNiecesArray, testHumansWithNiecesArray);

    // filter a dictionary
    NSDictionary* humansMap = [MBExpression asObject:@"^filter($nameMap|$item.species == human|matchAll)"];
    XCTAssertTrue([humansMap isKindOfClass:[NSDictionary class]]);
    XCTAssertTrue(humansMap.count == 4);
    scope[@"humansMap"] = humansMap;
    NSDictionary* testHumansMap = [MBExpression asObject:@"^dictionary(Jill|$(Jill Test)|Evan|$(Evan Test)|Debbie|$(Debbie Test)|Lauren|$(Lauren Test))"];
    XCTAssertEqualObjects(humansMap, testHumansMap);

    NSDictionary* humansWithNiecesMap = [MBExpression asObject:@"^filter($humansMap|$item[nieces]|matchAll)"];
    XCTAssertTrue([humansWithNiecesMap isKindOfClass:[NSDictionary class]]);
    XCTAssertTrue(humansWithNiecesMap.count == 2);
    NSDictionary* testHumansWithNiecesMap = [MBExpression asObject:@"^dictionary(Jill|$(Jill Test)|Debbie|$(Debbie Test))"];
    XCTAssertEqualObjects(humansWithNiecesMap, testHumansWithNiecesMap);

    // filter a set
    NSSet* humansSet = [MBExpression asObject:@"^filter(^setWithArray($nameList)|$item.species == human|matchAll)"];
    XCTAssertTrue([humansSet isKindOfClass:[NSSet class]]);
    XCTAssertTrue(humansSet.count == 4);
    scope[@"humansSet"] = humansSet;
    NSSet* testHumansSet = [MBExpression asObject:@"^set($(Jill Test)|$(Evan Test)|$(Debbie Test)|$(Lauren Test))"];
    XCTAssertEqualObjects(humansSet, testHumansSet);

    NSSet* humansWithNiecesSet = [MBExpression asObject:@"^filter($humansSet|$item[nieces]|matchAll)"];
    XCTAssertTrue([humansWithNiecesSet isKindOfClass:[NSSet class]]);
    XCTAssertTrue(humansWithNiecesSet.count == 2);
    NSSet* testHumansWithNiecesSet = [MBExpression asObject:@"^set($(Jill Test)|$(Debbie Test))"];
    XCTAssertEqualObjects(humansWithNiecesSet, testHumansWithNiecesSet);

    [MBScopedVariables exitVariableScope];

    //
    // test expected failures
    //
    MBExpressionError* err = nil;
    [MBExpression asObject:@"^filter()" error:&err];
    expectError(err);

    err = nil;
    [MBExpression asObject:@"^filter($nameList)" error:&err];
    expectError(err);

    err = nil;
    [MBExpression asObject:@"^filter($NULL|$item)" error:&err];
    expectError(err);
}

- (void) testList
{
    MBLogInfoTrace();

    //
    // test expected successes
    //
    NSArray* testList1 = @[@"Twenty-One", @"Twenty-Two", @"Twenty-Three", @"Twenty-Four"];
    NSArray* list1 = [MBExpression asObject:@"^list($testValues|Twenty-$item)"];
    XCTAssertTrue([list1 isKindOfClass:[NSArray class]]);
    XCTAssertEqualObjects(list1, testList1);

    NSArray* testList2 = @[@"Jill Test", @"Debbie Test"];
    NSArray* list2 = [MBExpression asObject:@"^list($nameMap|$item[aunts]|$item)"];
    XCTAssertTrue([list2 isKindOfClass:[NSArray class]]);
    XCTAssertEqual(list2.count, testList2.count);
    XCTAssertEqualObjects([NSSet setWithArray:list2], [NSSet setWithArray:testList2]);  // order is nondeterministic when ^list() uses a map as input

    //
    // test expected failures
    //
    MBExpressionError* err = nil;
    [MBExpression asObject:@"^list()" error:&err];
    expectError(err);

    err = nil;
    [MBExpression asObject:@"^list($nameList)" error:&err];
    expectError(err);

    err = nil;
    MBLogInfoObject([MBExpression asObject:@"^list($NULL)" error:&err]);
    expectError(err);
}

- (void) testPruneMatchingLeaves
{
    MBLogInfoTrace();

    //
    // test expected successes
    //
    NSArray* testPruned1 = @[@"Key 1", @"Key 2", @"Key 3"];
    NSArray* pruned1 = [MBExpression asObject:@"^pruneMatchingLeaves($testKeys|^hasSuffix($item|4))"];
    XCTAssertTrue([pruned1 isKindOfClass:[NSArray class]]);
    XCTAssertEqualObjects(pruned1, testPruned1);

    NSArray* testPruned2 = [MBExpression asObject:@"^array($(Jill Test)|$(Evan Test)|$(Debbie Test)|$(Lauren Test))"];
    NSArray* pruned2 = [MBExpression asObject:@"^pruneMatchingLeaves($nameList|$item[species] != human)"];
    XCTAssertTrue([pruned2 isKindOfClass:[NSArray class]]);
    XCTAssertEqualObjects(pruned2, testPruned2);

    //
    // test expected failures
    //
    MBExpressionError* err = nil;
    [MBExpression asObject:@"^pruneMatchingLeaves($testKeys)" error:&err];
    expectError(err);

    err = nil;
    [MBExpression asObject:@"^pruneMatchingLeaves(notAnArray|$item)" error:&err];
    expectError(err);

    err = nil;
    [MBExpression asObject:@"^pruneMatchingLeaves($NULL|$item)" error:&err];
    expectError(err);

    err = nil;
    [MBExpression asObject:@"^pruneMatchingLeaves($testKeys|$item|foo)" error:&err];
    expectError(err);
}

- (void) testPruneNonmatchingLeaves
{
    MBLogInfoTrace();

    //
    // test expected successes
    //
    NSArray* testPruned1 = @[@"Key 4"];
    NSArray* pruned1 = [MBExpression asObject:@"^pruneNonmatchingLeaves($testKeys|^hasSuffix($item|4))"];
    XCTAssertTrue([pruned1 isKindOfClass:[NSArray class]]);
    XCTAssertEqualObjects(pruned1, testPruned1);

    NSArray* testPruned2 = [MBExpression asObject:@"^array($(Jill Test)|$(Evan Test)|$(Debbie Test)|$(Lauren Test))"];
    NSArray* pruned2 = [MBExpression asObject:@"^pruneNonmatchingLeaves($nameList|$item[species] == human)"];
    XCTAssertTrue([pruned2 isKindOfClass:[NSArray class]]);
    XCTAssertEqualObjects(pruned2, testPruned2);

    //
    // test expected failures
    //
    MBExpressionError* err = nil;
    [MBExpression asObject:@"^pruneNonmatchingLeaves()" error:&err];
    expectError(err);

    err = nil;
    [MBExpression asObject:@"^pruneNonmatchingLeaves($nameList)" error:&err];
    expectError(err);

    err = nil;
    [MBExpression asObject:@"^pruneNonmatchingLeaves($NULL|$item)" error:&err];
    expectError(err);

    err = nil;
    [MBExpression asObject:@"^pruneNonmatchingLeaves($testKeys|$item|foo)" error:&err];
    expectError(err);
}

- (void) testAssociate
{
    MBLogInfoTrace();

    //
    // test expected successes
    //
    NSDictionary* testAssoc1 = @{@"Jill": @"human", @"Evan": @"human", @"Debbie": @"human", @"Lauren": @"human", @"Daisy": @"dog", @"Barrett": @"cat"};
    NSDictionary* assoc1 = [MBExpression asObject:@"^associate($nameMap|$key|$item[species])"];
    XCTAssertTrue([assoc1 isKindOfClass:[NSDictionary class]]);
    XCTAssertEqualObjects(assoc1, testAssoc1);

    NSDictionary* testAssoc2 = @{@"female": @[@"Jill", @"Debbie", @"Lauren", @"Daisy", @"Barrett"], @"male": @"Evan"};
    NSDictionary* assoc2 = [MBExpression asObject:@"^associate($nameMap|$item[gender]|$key)"];
    XCTAssertTrue([assoc2 isKindOfClass:[NSDictionary class]]);
    XCTAssertEqualObjects(assoc2[@"male"], @"Evan");
    XCTAssertTrue([assoc2[@"female"] isKindOfClass:[NSArray class]]);
    NSSet* namesSet = [NSSet setWithArray:assoc2[@"female"]];
    NSSet* testNamesSet = [NSSet setWithArray:testAssoc2[@"female"]];
    XCTAssertEqualObjects(namesSet, testNamesSet);

    NSDictionary* assoc3 = [MBExpression asObject:@"^associate($nameMap|$item[species]|$item[firstName])"];
    XCTAssertTrue([assoc3 isKindOfClass:[NSDictionary class]]);
    XCTAssertTrue(assoc3.count == 3);
    XCTAssertEqualObjects(assoc3[@"cat"], @"Barrett");
    XCTAssertEqualObjects(assoc3[@"dog"], @"Daisy");
    NSSet* testHumanSet = [NSSet setWithArray:@[@"Jill", @"Evan", @"Debbie", @"Lauren"]];
    NSSet* humanSet = [NSSet setWithArray:assoc3[@"human"]];
    XCTAssertEqualObjects(humanSet, testHumanSet);

    //
    // test expected failures
    //
    MBExpressionError* err = nil;
    [MBExpression asObject:@"^associate()" error:&err];
    expectError(err);

    err = nil;
    [MBExpression asObject:@"^associate($nameList)" error:&err];
    expectError(err);

    err = nil;
    [MBExpression asObject:@"^associate($nameMap|$item)" error:&err];
    expectError(err);

    err = nil;
    [MBExpression asObject:@"^associate(not an array|$key|$item)" error:&err];
    expectError(err);
}

- (void) testAssociateWithSingleValue
{
    MBLogInfoTrace();

    //
    // test expected successes
    //
    NSDictionary* testAssoc1 = @{@"Jill": @"human", @"Evan": @"human", @"Debbie": @"human", @"Lauren": @"human", @"Daisy": @"dog", @"Barrett": @"cat"};
    NSDictionary* assoc1 = [MBExpression asObject:@"^associateWithSingleValue($nameMap|$key|$item[species])"];
    XCTAssertTrue([assoc1 isKindOfClass:[NSDictionary class]]);
    XCTAssertEqualObjects(assoc1, testAssoc1);

    NSDictionary* testAssoc2 = @{@"female": @[@"Jill", @"Debbie", @"Lauren", @"Daisy", @"Barrett"], @"male": @"Evan"};
    NSDictionary* assoc2 = [MBExpression asObject:@"^associateWithSingleValue($nameMap|$item[gender]|$key)"];
    XCTAssertTrue([assoc2 isKindOfClass:[NSDictionary class]]);
    XCTAssertEqualObjects(assoc2[@"male"], @"Evan");
    XCTAssertTrue([assoc2[@"female"] isKindOfClass:[NSString class]]);
    NSSet* testNamesSet = [NSSet setWithArray:testAssoc2[@"female"]];
    XCTAssertTrue([testNamesSet containsObject:assoc2[@"female"]]);

    NSDictionary* assoc3 = [MBExpression asObject:@"^associateWithSingleValue($nameMap|$item[species]|$item[firstName])"];
    XCTAssertTrue([assoc3 isKindOfClass:[NSDictionary class]]);
    XCTAssertTrue(assoc3.count == 3);
    XCTAssertEqualObjects(assoc3[@"cat"], @"Barrett");
    XCTAssertEqualObjects(assoc3[@"dog"], @"Daisy");
    NSSet* testHumanSet = [NSSet setWithArray:@[@"Jill", @"Evan", @"Debbie", @"Lauren"]];
    XCTAssertTrue([assoc3[@"human"] isKindOfClass:[NSString class]]);
    XCTAssertTrue([testHumanSet containsObject:assoc3[@"human"]]);

    //
    // test expected failures
    //
    MBExpressionError* err = nil;
    [MBExpression asObject:@"^associateWithSingleValue()" error:&err];
    expectError(err);

    err = nil;
    [MBExpression asObject:@"^associateWithSingleValue($nameList)" error:&err];
    expectError(err);

    err = nil;
    [MBExpression asObject:@"^associateWithSingleValue($nameMap|$item)" error:&err];
    expectError(err);

    err = nil;
    [MBExpression asObject:@"^associateWithSingleValue(not an array|$key|$item)" error:&err];
    expectError(err);
}

- (void) testAssociateWithArray
{
    MBLogInfoTrace();

    //
    // test expected successes
    //
    NSDictionary* testAssoc1 = @{@"Jill": @[@"human"], @"Evan": @[@"human"], @"Debbie": @[@"human"], @"Lauren": @[@"human"], @"Daisy": @[@"dog"], @"Barrett": @[@"cat"]};
    NSDictionary* assoc1 = [MBExpression asObject:@"^associateWithArray($nameMap|$key|$item[species])"];
    XCTAssertTrue([assoc1 isKindOfClass:[NSDictionary class]]);
    XCTAssertEqualObjects(assoc1, testAssoc1);

    NSDictionary* testAssoc2 = @{@"Jill": @[@"female"], @"Evan": @[@"male"], @"Debbie": @[@"female"], @"Lauren": @[@"female"], @"Daisy": @[@"female"], @"Barrett": @[@"female"]};
    NSDictionary* assoc2 = [MBExpression asObject:@"^associateWithArray($nameMap|$key|$item[gender])"];
    XCTAssertTrue([assoc2 isKindOfClass:[NSDictionary class]]);
    XCTAssertEqualObjects(assoc2, testAssoc2);

    NSDictionary* assoc3 = [MBExpression asObject:@"^associateWithArray($nameMap|$item[species]|$item[firstName])"];
    XCTAssertTrue([assoc3 isKindOfClass:[NSDictionary class]]);
    XCTAssertTrue(assoc3.count == 3);
    XCTAssertEqualObjects(assoc3[@"cat"], @[@"Barrett"]);
    XCTAssertEqualObjects(assoc3[@"dog"], @[@"Daisy"]);
    NSSet* testHumanSet = [NSSet setWithArray:@[@"Jill", @"Evan", @"Debbie", @"Lauren"]];
    NSSet* humanSet = [NSSet setWithArray:assoc3[@"human"]];
    XCTAssertEqualObjects(humanSet, testHumanSet);

    //
    // test expected failures
    //
    MBExpressionError* err = nil;
    [MBExpression asObject:@"^associateWithArray()" error:&err];
    expectError(err);

    err = nil;
    [MBExpression asObject:@"^associateWithArray($nameList)" error:&err];
    expectError(err);

    err = nil;
    [MBExpression asObject:@"^associateWithArray($nameMap|$item)" error:&err];
    expectError(err);

    err = nil;
    [MBExpression asObject:@"^associateWithArray(not an array|$key|$item)" error:&err];
    expectError(err);
}

- (void) testReverse
{
    MBLogInfoTrace();

    //
    // test expected successes
    //
    NSArray* testReversed = @[@"Four", @"Three", @"Two", @"One"];
    NSArray* reversed = [MBExpression asObject:@"^reverse($testValues)"];
    XCTAssertTrue([reversed isKindOfClass:[NSArray class]]);
    XCTAssertEqualObjects(reversed, testReversed);

    //
    // test expected failures
    //
    MBExpressionError* err = nil;
    [MBExpression asObject:@"^reverse()" error:&err];
    expectError(err);

    err = nil;
    [MBExpression asObject:@"^reverse(notAnArray)" error:&err];
    expectError(err);

    err = nil;
    [MBExpression asObject:@"^reverse($NULL)" error:&err];
    expectError(err);
}

- (void) testSort
{
    MBLogInfoTrace();

    //
    // test expected successes
    //
    NSArray* testKeys = [@"$testKeys" evaluateAsObject];
    NSArray* sortedKeys = [MBExpression asObject:@"^sort(^array(Key 4|Key 3|Key 2|Key 1))"];
    XCTAssertTrue([sortedKeys isKindOfClass:[NSArray class]]);
    XCTAssertEqualObjects(sortedKeys, testKeys);

    NSArray* testValues = @[@"Four", @"One", @"Three", @"Two"];
    NSArray* sortedValues = [MBExpression asObject:@"^sort($testValues)"];
    XCTAssertTrue([sortedValues isKindOfClass:[NSArray class]]);
    XCTAssertEqualObjects(sortedValues, testValues);

    //
    // test expected failures
    //
    MBExpressionError* err = nil;
    [MBExpression asObject:@"^sort()" error:&err];
    expectError(err);

    err = nil;
    [MBExpression asObject:@"^sort(not an array)" error:&err];
    expectError(err);
}

- (void) testMergeDictionaries
{
    MBLogInfoTrace();

    //
    // test expected successes
    //
    NSDictionary* testMap = [@"$testMap" evaluateAsObject];
    NSDictionary* testData = [@"$testData" evaluateAsObject];
    NSMutableDictionary* testMerged1 = [NSMutableDictionary new];
    [testMerged1 addEntriesFromDictionary:testMap];
    [testMerged1 addEntriesFromDictionary:testData];
    NSDictionary* merged1 = [MBExpression asObject:@"^mergeDictionaries($testMap|$testData)"];
    XCTAssertTrue([merged1 isKindOfClass:[NSDictionary class]]);
    XCTAssertEqualObjects(merged1, testMerged1);

    MBScopedVariables* scope = [MBScopedVariables enterVariableScope];

    NSDictionary* duplicateKeys = @{@"Key 3": @"III",
                                   @"orderNumer": @(121112) };
    scope[@"duplicateKeys"] = duplicateKeys;

    NSMutableDictionary* testMerged2 = [NSMutableDictionary new];
    [testMerged2 addEntriesFromDictionary:testMap];
    [testMerged2 addEntriesFromDictionary:testData];
    [testMerged2 addEntriesFromDictionary:duplicateKeys];
    NSDictionary* merged2 = [MBExpression asObject:@"^mergeDictionaries($testMap|$testData|$duplicateKeys)"];
    XCTAssertTrue([merged2 isKindOfClass:[NSDictionary class]]);
    XCTAssertEqualObjects(merged2, testMerged2);

    [MBScopedVariables exitVariableScope];

    //
    // test expected failures
    //
    MBExpressionError* err = nil;
    [MBExpression asObject:@"^mergeDictionaries()" error:&err];
    expectError(err);

    err = nil;
    [MBExpression asObject:@"^mergeDictionaries($testMap)" error:&err];
    expectError(err);

    err = nil;
    [MBExpression asObject:@"^mergeDictionaries($testMap|$nameList)" error:&err];
    expectError(err);
}

- (void) testUnique
{
    MBLogInfoTrace();

    //
    // test expected successes
    //
    NSArray* testUnique = [MBExpression asObject:@"^appendArrays($testKeys|$testValues)"];
    NSArray* unique = [MBExpression asObject:@"^unique(^appendArrays($testKeys|$testValues|$testKeys|$testValues|$testKeys|$testValues))"];
    XCTAssertTrue([unique isKindOfClass:[NSArray class]]);
    XCTAssertEqualObjects(unique, testUnique);

    //
    // test expected failures
    //
    MBExpressionError* err = nil;
    [MBExpression asObject:@"^unique()" error:&err];
    expectError(err);

    err = nil;
    [MBExpression asObject:@"^unique(notAnIterable)" error:&err];
    expectError(err);
}

- (void) testDistributeArrayElements
{
    MBLogInfoTrace();
    
    //
    // test expected successes
    //
    NSArray* distributed = [MBExpression asObject:@"^distributeArrayElements($newYorkTeams|2)"];
    XCTAssertTrue([distributed isKindOfClass:[NSArray class]]);
    XCTAssertTrue(distributed.count == 2);
    NSArray* expectedArray1 = [NSArray arrayWithObjects:@"Yankees", @"Knicks", @"Islanders", nil];
    NSArray* expectedArray2 = [NSArray arrayWithObjects:@"Mets", @"Rangers", nil];
    XCTAssertEqualObjects(expectedArray1, distributed[0]);
    XCTAssertEqualObjects(expectedArray2, distributed[1]);

    //
    // test expected failures
    //
    MBExpressionError* err = nil;
    [MBExpression asObject:@"^distributeArrayElements()" error:&err];
    expectError(err);

    err = nil;
    [MBExpression asObject:@"^distributeArrayElements($nameList)" error:&err];
    expectError(err);

    err = nil;
    [MBExpression asObject:@"^distributeArrayElements($nameList|2|3)" error:&err];
    expectError(err);
}

- (void) testGroupArrayElements
{
    MBLogInfoTrace();

    //
    // test expected successes
    //
    NSArray* grouped = [MBExpression asObject:@"^groupArrayElements($newYorkTeams|2)"];
    XCTAssertTrue([grouped isKindOfClass:[NSArray class]]);
    XCTAssertTrue(grouped.count == 3);
    NSArray* expectedArray1 = [NSArray arrayWithObjects:@"Yankees", @"Mets", nil];
    NSArray* expectedArray2 = [NSArray arrayWithObjects:@"Knicks", @"Rangers", nil];
    NSArray* expectedArray3 = [NSArray arrayWithObjects:@"Islanders", nil];
    XCTAssertEqualObjects(expectedArray1, grouped[0]);
    XCTAssertEqualObjects(expectedArray2, grouped[1]);
    XCTAssertEqualObjects(expectedArray3, grouped[2]);

    //
    // test expected failures
    //
    MBExpressionError* err = nil;
    [MBExpression asObject:@"^groupArrayElements()" error:&err];
    expectError(err);

    err = nil;
    [MBExpression asObject:@"^groupArrayElements($nameList)" error:&err];
    expectError(err);

    err = nil;
    [MBExpression asObject:@"^groupArrayElements($nameList|2|3)" error:&err];
    expectError(err);
}

- (void) testReduce
{
    MBLogInfoTrace();

    //
    // test expected successes
    //
    NSObject* reduced = [MBExpression asObject:@"^reduce($newYorkTeams|na|$item)"];
    XCTAssertEqualObjects(@"Islanders", reduced);
    
    reduced = [MBExpression asObject:@"^reduce($newYorkTeams|0|#($currentValue + $item.length))"];
    XCTAssertEqualObjects([NSNumber numberWithInt:33], reduced);
    
    reduced = [MBExpression asObject:@"^reduce(^array()|#(0)|#($currentValue + $item.length))"];
    XCTAssertEqualObjects([NSNumber numberWithInt:0], reduced);
    
    reduced = [MBExpression asObject:@"^reduce(^array(test)|0|#($currentValue + $item.length))"];
    XCTAssertEqualObjects([NSNumber numberWithInt:4], reduced);

    //
    // test expected failures
    //
    MBExpressionError* err = nil;
    [MBExpression asObject:@"^reduce()" error:&err];
    expectError(err);

    err = nil;
    [MBExpression asObject:@"^reduce($nameList)" error:&err];
    expectError(err);

    err = nil;
    [MBExpression asObject:@"^reduce($nameList)" error:&err];
    expectError(err);

    err = nil;
    [MBExpression asObject:@"^reduce($NULL|0|#($currentValue + $item.length))" error:&err];
    expectError(err);

    err = nil;
    [MBExpression asObject:@"^reduce(notAnArray|0|#($currentValue + $item.length))" error:&err];
    expectError(err);
}

@end

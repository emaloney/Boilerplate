//
//  MBDataEnvironmentTestSuite.h
//  MockingbirdTests
//
//  Created by Evan Coyne Maloney on 1/25/12.
//  Copyright (c) 2012 Gilt Groupe. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MBVariableSpace.h"
#import "MBExpression.h"
#import "MBEnvironment.h"
#import "MBStringConversions.h"
#import "MBScopedVariables.h"

#define LOG_EXPECTED_ERRORS         1
#define logExpectedError(x)         if (LOG_EXPECTED_ERRORS && (x)) MBLog(MBModuleLogSeverityVerbose, @"Received expected error (this is safe to ignore): %@", [(MBExpressionError*)x logOutput])
#define expectError(x)              { XCTAssertNotNil(x); logExpectedError(x); }

/******************************************************************************/
#pragma mark -
#pragma mark MBDataEnvironmentTestSuite class
/******************************************************************************/

@interface MBDataEnvironmentTestSuite : XCTestCase

@property(nonatomic, assign, readonly) BOOL loadTestManifest;

- (void) willLoadEnvironment;

- (void) didLoadEnvironment:(MBEnvironment*)env;

- (NSString*) manifestFileName;

- (NSArray*) mbmlSearchDirectories;

- (void) setUpVariableSpace:(MBVariableSpace*)vars;

@end

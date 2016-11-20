//
//  RMPickerViewController_Demo_Tests.m
//  RMPickerViewController-Demo-Tests
//
//  Created by Roland Moers on 09.11.15.
//  Copyright © 2015 Roland Moers. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "RMPickerViewController.h"

@interface RMPickerViewControllerTests : XCTestCase

@end

@implementation RMPickerViewControllerTests

#pragma mark - Helper
- (RMPickerViewController *)createDateSelectionViewControllerWithStyle:(RMActionControllerStyle)aStyle {
    RMAction *selectAction = [RMAction actionWithTitle:@"Select" style:RMActionStyleDone andHandler:nil];
    RMAction *cancelAction = [RMAction actionWithTitle:@"Cancel" style:RMActionStyleCancel andHandler:nil];
    
    RMPickerViewController *dateSelectionController = [RMPickerViewController actionControllerWithStyle:aStyle];
    dateSelectionController.title = @"Test";
    dateSelectionController.message = @"This is a test message.\nPlease choose a date and press 'Select' or 'Cancel'.";
    
    [dateSelectionController addAction:selectAction];
    [dateSelectionController addAction:cancelAction];
    
    RMAction *nowAction = [RMAction actionWithTitle:@"Now" style:RMActionStyleAdditional andHandler:nil];
    nowAction.dismissesActionController = NO;
    
    [dateSelectionController addAction:nowAction];
    
    return dateSelectionController;
}

- (void)presentAndDismissController:(RMActionController *)aController {
    XCTestExpectation *expectation = [self expectationWithDescription:@"PresentationCompleted"];
    
    BOOL catchedException = NO;
    @try {
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:aController animated:YES completion:^{
            [expectation fulfill];
        }];
    }
    @catch (NSException *exception) {
        catchedException = YES;
    }
    @finally {
        XCTAssertFalse(catchedException);
    }
    
    [self waitForExpectationsWithTimeout:2 handler:nil];
    
    expectation = [self expectationWithDescription:@"DismissalCompleted"];
    
    [[UIApplication sharedApplication].keyWindow.rootViewController dismissViewControllerAnimated:YES completion:^{
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:2 handler:nil];
}

#pragma mark - Tests
- (void)testPresentingDateSelectionViewControllerWhite {
    RMPickerViewController *controller = [self createDateSelectionViewControllerWithStyle:RMActionControllerStyleWhite];
    
    XCTAssertNotNil(controller.contentView);
    XCTAssertEqual(controller.contentView, controller.picker);
    XCTAssertTrue([controller.contentView isKindOfClass:[UIPickerView class]]);
    XCTAssertEqualObjects(controller.title, @"Test");
    XCTAssertEqualObjects(controller.message, @"This is a test message.\nPlease choose a date and press 'Select' or 'Cancel'.");
    
    [self presentAndDismissController:controller];
}

- (void)testPresentingDateSelectionViewControllerBlack {
    RMPickerViewController *controller = [self createDateSelectionViewControllerWithStyle:RMActionControllerStyleBlack];
    
    XCTAssertNotNil(controller.contentView);
    XCTAssertEqual(controller.contentView, controller.picker);
    XCTAssertTrue([controller.contentView isKindOfClass:[UIPickerView class]]);
    XCTAssertEqualObjects(controller.title, @"Test");
    XCTAssertEqualObjects(controller.message, @"This is a test message.\nPlease choose a date and press 'Select' or 'Cancel'.");
    
    [self presentAndDismissController:controller];
}

@end

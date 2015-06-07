//
//  RMPickerViewController.m
//  RMPickerViewController
//
//  Created by Roland Moers on 26.10.13.
//  Copyright (c) 2013-2015 Roland Moers
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "RMPickerViewController.h"
#import <QuartzCore/QuartzCore.h>

#define RM_PICKER_HEIGHT_PORTRAIT 216
#define RM_PICKER_HEIGHT_LANDSCAPE 162

#if !__has_feature(attribute_availability_app_extension)
//Normal App
#define RM_CURRENT_ORIENTATION_IS_LANDSCAPE_PREDICATE UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)
#else
//App Extension
#define RM_CURRENT_ORIENTATION_IS_LANDSCAPE_PREDICATE [UIScreen mainScreen].bounds.size.height < [UIScreen mainScreen].bounds.size.width
#endif

@interface RMPickerViewController ()

@property (nonatomic, readwrite, strong) UIPickerView *picker;
@property (nonatomic, weak) NSLayoutConstraint *pickerHeightConstraint;

@end

@implementation RMPickerViewController

#pragma mark - Class
+ (instancetype)actionControllerWithStyle:(RMActionControllerStyle)style title:(NSString *)aTitle message:(NSString *)aMessage selectAction:(RMAction *)selectAction andCancelAction:(RMAction *)cancelAction {
    RMPickerViewController *controller = [super actionControllerWithStyle:style title:aTitle message:aMessage selectAction:selectAction andCancelAction:cancelAction];
    
    controller.picker = [[UIPickerView alloc] initWithFrame:CGRectZero];
    controller.picker.translatesAutoresizingMaskIntoConstraints = NO;
    
    controller.pickerHeightConstraint = [NSLayoutConstraint constraintWithItem:controller.picker attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:0];
    
    if(RM_CURRENT_ORIENTATION_IS_LANDSCAPE_PREDICATE) {
        controller.pickerHeightConstraint.constant = RM_PICKER_HEIGHT_LANDSCAPE;
    } else {
        controller.pickerHeightConstraint.constant = RM_PICKER_HEIGHT_PORTRAIT;
    }
    
    [controller.picker addConstraint:controller.pickerHeightConstraint];
    
    return controller;
}

#pragma mark - Init and Dealloc
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRotate) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    
    [super viewDidDisappear:animated];
}

#pragma mark - Orientation
- (void)didRotate {
    NSTimeInterval duration = 0.4;
    
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        duration = 0.3;
        
        if(RM_CURRENT_ORIENTATION_IS_LANDSCAPE_PREDICATE) {
            self.pickerHeightConstraint.constant = RM_PICKER_HEIGHT_LANDSCAPE;
        } else {
            self.pickerHeightConstraint.constant = RM_PICKER_HEIGHT_PORTRAIT;
        }
        
        [self.picker setNeedsUpdateConstraints];
        [self.picker layoutIfNeeded];
    }
    
    [self.view.superview setNeedsUpdateConstraints];
    __weak RMPickerViewController *blockself = self;
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        [blockself.view.superview layoutIfNeeded];
    } completion:^(BOOL finished) {
    }];
}

#pragma mark - Properties
- (UIView *)contentView {
    return self.picker;
}

@end

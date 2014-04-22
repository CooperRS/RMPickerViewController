//
//  RMViewController.m
//  RMPickerViewController-Demo
//
//  Created by Roland Moers on 26.10.13.
//  Copyright (c) 2013 Roland Moers
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

#import "RMViewController.h"

@interface RMViewController () <RMPickerViewControllerDelegate>

@end

@implementation RMViewController

#pragma mark - Actions
- (IBAction)openPickerController:(id)sender {
    RMPickerViewController *pickerVC = [RMPickerViewController pickerController];
    pickerVC.delegate = self;
    pickerVC.titleLabel.text = @"This is an example title.\n\nPlease choose a row and press 'Select' or 'Cancel'.";
    
    //You can enable or disable bouncing and motion effects
    //pickerVC.disableBouncingWhenShowing = YES;
    //pickerVC.disableMotionEffects = YES;
    
    [pickerVC show];
    
    //You can also adjust colors (enabling example will result in a black version)
    //pickerVC.tintColor = [UIColor whiteColor];
    //pickerVC.backgroundColor = [UIColor colorWithWhite:0.25 alpha:1];
}

- (IBAction)openPickerControllerWithBlock:(id)sender {
    RMPickerViewController *pickerVC = [RMPickerViewController pickerController];
    pickerVC.delegate = self;
    
    //You can enable or disable bouncing and motion effects
    //pickerVC.disableBouncingWhenShowing = YES;
    //pickerVC.disableMotionEffects = YES;
    
    [pickerVC showWithSelectionHandler:^(RMPickerViewController *vc, NSArray *selectedRows) {
        NSLog(@"Successfully selected rows: %@ (With block)", selectedRows);
    } andCancelHandler:^(RMPickerViewController *vc) {
        NSLog(@"Selection was canceled (with block)");
    }];
}

#pragma mark - UITableView Delegates
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0 && indexPath.row == 0) {
        [self openPickerController:self];
    } else if (indexPath.section == 0 && indexPath.row == 1) {
        [self openPickerControllerWithBlock:self];
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - RMPickerViewController Delegates
- (void)pickerViewController:(RMPickerViewController *)vc didSelectRows:(NSArray *)selectedRows {
    NSLog(@"Successfully selected rows: %@", selectedRows);
}

- (void)pickerViewControllerDidCancel:(RMPickerViewController *)vc {
    NSLog(@"Selection was canceled");
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return 5;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [NSString stringWithFormat:@"Row %lu", (long)row];
}

@end

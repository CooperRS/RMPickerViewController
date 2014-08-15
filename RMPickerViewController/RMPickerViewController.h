//
//  RMPickerViewController.h
//  RMPickerViewController
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

#import <UIKit/UIKit.h>

/**
 `RMPickerViewController` is an iOS control for selecting a row using UIPickerView in a UIActionSheet like fashion.
 */

@class RMPickerViewController;

/**
 This block is called when the user selects a certain row if blocks are used.
 
 @param vc The picker view controller that just finished selecting a row.
 
 @param selectedRows An array of selected rows (one entry per component).
 */

typedef void (^RMSelectionBlock)(RMPickerViewController *vc, NSArray *selectedRows);

/**
 This block is called when the user cancels if blocks are used.
 
 @param vc The picker view controller that just got canceled.
  */
typedef void (^RMCancelBlock)(RMPickerViewController *vc);

@protocol RMPickerViewControllerDelegate <UIPickerViewDelegate, UIPickerViewDataSource>

/**
 This delegate method is called when the user selects a certain row.
 
 @param vc The picker view controller that just finished selecting a row.
 
 @param selectedRows An array of selected rows (one entry per component).
 */
- (void)pickerViewController:(RMPickerViewController *)vc didSelectRows:(NSArray *)selectedRows;

/**
 This delegate method is called when the user selects the cancel button or taps the darkened background (if `backgroundTapsDisabled` is set to NO).
 
 @param vc The picker view controller that just canceled.
 */
- (void)pickerViewControllerDidCancel:(RMPickerViewController *)vc;

@end

@interface RMPickerViewController : UIViewController

/// @name Properties

/**
 Will return the instance of UIPickerView that is used.
 */
@property (nonatomic, readonly) UIPickerView *picker;

/**
 Will return the label that is used as a title for the picker. You can use this property to set a title and to customize the appearance of the title.
 
 If you want to set a title, be sure to set it before showing the picker view controller as otherwise the title will not be shown.
 */
@property (nonatomic, strong, readonly) UILabel *titleLabel;

/**
 Used to set the delegate.
 
 The delegate must conform to the `RMPickerViewControllerDelegate` protocol.
 */
@property (nonatomic, weak) id<RMPickerViewControllerDelegate> delegate;

/**
 Used to set the text color of the buttons (has no effect on picker view).
 */
@property (strong, nonatomic) UIColor *tintColor;

/**
 Used to set the background color.
 */
@property (strong, nonatomic) UIColor *backgroundColor;

/**
 *  Used to set the background color when the user selets a button.
 */
@property (strong, nonatomic) UIColor *selectedBackgroundColor;

/**
 Used to enable or disable motion effects. Default value is NO.
 */
@property (assign, nonatomic) BOOL disableMotionEffects;

/**
 Used to enable or disable bouncing effects when sliding in the picker view. Default value is NO.
 */
@property (assign, nonatomic) BOOL disableBouncingWhenShowing;

/**
 Used to enable or disable blurring the picker view. Default value is NO.
 */
@property (assign, nonatomic) BOOL disableBlurEffects;

/**
 *  Used to choose a particular blur effect style (default value is UIBlurEffectStyleExtraLight). Ignored if blur effects are disabled.
 */
@property (assign, nonatomic) UIBlurEffectStyle blurEffectStyle;

/**
 *  When YES taps on the background view are ignored. Default value is NO.
 */
@property (assign, nonatomic) BOOL backgroundTapsDisabled;

/// @name Class Methods

/**
 This returns a new instance of `RMPickerViewController`. Always use this class method to get an instance. Do not initialize an instance yourself.
 
 @return Returns a new instance of `RMPickerViewController`
 */
+ (instancetype)pickerController;

/**
 Set a localized title for the select button. Default is 'Cancel'.
 */
+ (void)setLocalizedTitleForCancelButton:(NSString *)newLocalizedTitle;

/**
 Set a localized title for the select button. Default is 'Select'.
 */
+ (void)setLocalizedTitleForSelectButton:(NSString *)newLocalizedTitle;

/// @name Instance Methods

/**
 *  This shows the picker view controller on top of every other view controller using a new UIWindow. The RMPickerViewController will be added as a child view controller of the UIWindows root view controller. The background of the root view controller is used to darken the views behind the RMPickerViewController.
 *
 *  This method is the preferred method for showing a RMPickerViewController on iPhones and iPads. Nevertheless, there are situations where this method is not sufficient on iPads. An example for this is that the RMPickerViewController shall be shown within an UIPopover. This can be achieved by using -[RMPickerViewController showFromViewController:].
 *
 *  Make sure the delegate property is assigned. Otherwise you will not get any calls when a row is selected or the selection has been canceled.
 */
- (void)show;

/**
 *  This shows the picker view controller on top of every other view controller using a new UIWindow. The RMPickerViewController will be added as a child view controller of the UIWindows root view controller. The background of the root view controller is used to darken the views behind the RMPickerViewController.
 *
 *  This method is the preferred method for showing a RMPickerViewController on iPhones and iPads when a block based API is preferred. Nevertheless, there are situations where this method is not sufficient on iPads. An example for this is that the RMPickerViewController shall be shown within an UIPopover. This can be achieved by using -[RMPickerViewController showFromViewController:withSelectionHandler:andCancelHandler:].
 *
 *  After a row has been selected the selectionBlock will be called. If the user choses to cancel the selection, the cancel block will be called. If you assigned a delegate the corresponding delegate methods will be called, too.
 *
 *  @param selectionBlock The block to call when the user selects a row.
 *  @param cancelBlock    The block to call when the user cancels the selection.
 */
- (void)showWithSelectionHandler:(RMSelectionBlock)selectionBlock andCancelHandler:(RMCancelBlock)cancelBlock;

/**
 *  This shows the picker view controller as child view controller of `aViewController`. The content of `aViewController` will be darkened and the picker view controller will be shown on top.
 *
 *  This method should only be used on iPads in situations where -[RMPickerViewController show:] is not sufficient (for example, when the RMPickerViewController shoud be shown within an UIPopover). If -[RMPickerViewController show:] is sufficient, please use it!
 *
 *  Make sure the delegate property is assigned. Otherwise you will not get any calls when a row is selected or the selection has been canceled.
 *
 *  @param aViewController The parent view controller of the RMPickerViewController.
 */
- (void)showFromViewController:(UIViewController *)aViewController;

/**
 *  This shows the picker view controller as child view controller of `aViewController`. The content of `aViewController` will be darkened and the picker view controller will be shown on top.
 *
 *  This method should only be used on iPads in situations where -[RMPickerViewController showWithSelectionHandler:andCancelHandler:] is not sufficient (for example, when the RMPickerViewController shoud be shown within an UIPopover). If -[RMPickerViewController showWithSelectionHandler:andCancelHandler:] is sufficient, please use it!
 *
 *  After a row has been selected the selectionBlock will be called. If the user choses to cancel the selection, the cancel block will be called. If you assigned a delegate the corresponding delegate methods will be called, too.
 *
 *  @param aViewController The parent view controller of the RMPickerViewController.
 *  @param selectionBlock  The block to call when the user selects a row.
 *  @param cancelBlock     The block to call when the user cancels the selection.
 */
- (void)showFromViewController:(UIViewController *)aViewController withSelectionHandler:(RMSelectionBlock)selectionBlock andCancelHandler:(RMCancelBlock)cancelBlock;

/**
 This will remove the picker view controller from whatever view controller it is currently shown in.
 */
- (void)dismiss;

@end

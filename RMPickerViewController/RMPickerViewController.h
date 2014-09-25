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

@class RMPickerViewController;

/**
 *  This block is called when the user selects a certain row if blocks are used.
 *
 *  @param vc           The picker view controller that just finished selecting a row.
 *  @param selectedRows An array of selected rows (one entry per component).
 */
typedef void (^RMSelectionBlock)(RMPickerViewController *vc, NSArray *selectedRows);

/**
 *  This block is called when the user cancels if blocks are used.
 *
 *  @param vc The picker view controller that just got canceled.
 */
typedef void (^RMCancelBlock)(RMPickerViewController *vc);

/**
 *  On the one hand, these methods are used to inform the [delegate]([RMPickerViewController delegate]) of an instance of RMPickerViewController about the status of the picker view controller. On the other hand, they are also used to control what content the picker view controller displays. For this purpose this protocol conforms to UIPickerViewDataSource and UIPickerViewDelegate.
 */
@protocol RMPickerViewControllerDelegate <UIPickerViewDelegate, UIPickerViewDataSource>

/// @name Select and Cancel

/**
 *  This delegate method is called when the user selects a certain row.
 *
 *  @param vc           The picker view controller that just finished selecting a row.
 *  @param selectedRows An array of selected rows (one entry per component).
 */
- (void)pickerViewController:(RMPickerViewController *)vc didSelectRows:(NSArray *)selectedRows;

/**
 *  This delegate method is called when the user selects the cancel button or taps the darkened background (if [backgroundTapsDisabled]([RMPickerViewController backgroundTapsDisabled]) of RMPickerViewController returns NO).
 *
 *  @param vc @param vc The picker view controller that just canceled.
 */
- (void)pickerViewControllerDidCancel:(RMPickerViewController *)vc;

@end

/**
 *  RMPickerViewController is an iOS control for selecting a row using UIPickerView in a UIActionSheet like fashion. When a RMPickerViewController is shown the user gets the opportunity to select some rows using a UIPickerView.
 *  
 *  RMPickerViewController supports bouncing effects when animating the picker view controller. In addition, motion effects are supported while showing the picker view controller. Both effects can be disabled by using the properties called disableBouncingWhenShowing and disableMotionEffects.
 *
 *  On iOS 8 and later Apple opened up their API for blurring the background of UIViews. RMPickerViewController makes use of this API. The type of the blur effect can be changed by using the blurEffectStyle property. If you want to disable the blur effect you can do so by using the disableBlurEffects property.
 *
 *  @warning RMPickerViewController is not designed to be reused. Each time you want to display a RMPickerViewController a new instance should be created. If you want to select a specific row before displaying, you can do so by using the picker property.
 */
@interface RMPickerViewController : UIViewController

/// @name Getting an Instance

/**
 *  This returns a new instance of RMPickerViewController.
 *
 *  @warning Always use this class method to get an instance. Do not initialize an instance yourself.
 *
 *  @return Returns a new instance of RMPickerViewController.
 */
+ (instancetype)pickerController;

/// @name Localization

/**
 *  Set a localized title for the cancel button. Default title is 'Cancel'.
 *
 *  @param newLocalizedTitle    The new localized title for the cancel button.
 */
+ (void)setLocalizedTitleForCancelButton:(NSString *)newLocalizedTitle;

/**
 *  Set a localized title for the select button. Default title is 'Select'.
 *
 *  @param newLocalizedTitle    The new localized title for the select button.
 */
+ (void)setLocalizedTitleForSelectButton:(NSString *)newLocalizedTitle;

/// @name Delegate

/**
 *  Used to set the delegate.
 *
 *  The delegate must conform to the RMPickerViewControllerDelegate protocol.
 */
@property (nonatomic, weak) id<RMPickerViewControllerDelegate> delegate;

/// @name User Interface

/**
 *  Will return the instance of UIPickerView that is used.
 */
@property (nonatomic, readonly) UIPickerView *picker;

/**
 *  Will return the label that is used as a title for the picker. You can use this property to set a title and to customize the appearance of the title.
 *
 *  @warning If you want to set a title, be sure to set it before showing the picker view controller as otherwise the title will not be shown.
 */
@property (nonatomic, strong, readonly) UILabel *titleLabel;

/**
 *  When YES taps on the background view are ignored. Default value is NO.
 */
@property (assign, nonatomic) BOOL backgroundTapsDisabled;

/// @name Appearance

/**
 *  Used to set the text color of the buttons (has no effect on picker view).
 */
@property (strong, nonatomic) UIColor *tintColor;

/**
 *  Used to set the background color.
 */
@property (strong, nonatomic) UIColor *backgroundColor;

/**
 *  Used to set the background color when the user selets a button.
 */
@property (strong, nonatomic) UIColor *selectedBackgroundColor;

/// @name Effects

/**
 *  Used to enable or disable motion effects. Default value is NO.
 */
@property (assign, nonatomic) BOOL disableMotionEffects;

/**
 *  Used to enable or disable bouncing effects when sliding in the picker view. Default value is NO.
 */
@property (assign, nonatomic) BOOL disableBouncingWhenShowing;

/**
 *  Used to enable or disable blurring the picker view. Default value is NO.
 *
 *  @warning This property always returns NO if either UIBlurEffect, UIVibrancyEffect or UIVisualEffectView is not available on your system at runtime.
 */
@property (assign, nonatomic) BOOL disableBlurEffects;

/**
 *  Used to choose a particular blur effect style (default value is UIBlurEffectStyleExtraLight). Ignored if blur effects are disabled.
 */
@property (assign, nonatomic) UIBlurEffectStyle blurEffectStyle;

/// @name Showing

/**
 *  This shows the picker view controller on top of every other view controller using a new UIWindow. The RMPickerViewController will be added as a child view controller of the UIWindows root view controller. The background of the root view controller is used to darken the views behind the RMPickerViewController.
 *
 *  This method is the preferred method for showing a RMPickerViewController on iPhones and iPads. Nevertheless, there are situations where this method is not sufficient on iPads. An example for this is that the RMPickerViewController shall be shown within an UIPopover. This can be achieved by using [showFromViewController:]([RMPickerViewController showFromViewController:]).
 *
 *  @warning Make sure the delegate property is assigned. Otherwise you will not get any calls when a row is selected or the selection has been canceled.
 */
- (void)show;

/**
 *  This shows the picker view controller on top of every other view controller using a new UIWindow. The RMPickerViewController will be added as a child view controller of the UIWindows root view controller. The background of the root view controller is used to darken the views behind the RMPickerViewController.
 *
 *  After a row has been selected the selection block will be called. If the user choses to cancel the selection, the cancel block will be called. If you assigned a delegate the corresponding delegate methods will be called, too.
 *
 *  This method is the preferred method for showing a RMPickerViewController on iPhones and iPads when a block based API is preferred. Nevertheless, there are situations where this method is not sufficient on iPads. An example for this is that the RMPickerViewController shall be shown within an UIPopover. This can be achieved by using [showFromViewController:withSelectionHandler:andCancelHandler:]([RMPickerViewController showFromViewController:withSelectionHandler:andCancelHandler:]).
 *
 *  @param selectionBlock The block to call when the user selects a row.
 *  @param cancelBlock    The block to call when the user cancels the selection.
 */
- (void)showWithSelectionHandler:(RMSelectionBlock)selectionBlock andCancelHandler:(RMCancelBlock)cancelBlock;

/**
 *  This shows the picker view controller as child view controller of the view controller you passed in as parameter. The content of this view controller will be darkened and the picker view controller will be shown on top.
 *
 *  @warning This method should only be used on iPads in situations where [show]([RMPickerViewController show]) is not sufficient (for example, when the RMPickerViewController shoud be shown within an UIPopover). If [show]([RMPickerViewController show]) is sufficient, please use it!
 *
 *  @warning Make sure the delegate property is assigned. Otherwise you will not get any calls when a row is selected or the selection has been canceled.
 *
 *  @param aViewController The parent view controller of the RMPickerViewController.
 */
- (void)showFromViewController:(UIViewController *)aViewController;

/**
 *  This shows the picker view controller as child view controller of the view controller you passed in as parameter. The content of this view controller will be darkened and the picker view controller will be shown on top.
 *
 *  After a row has been selected the selection block will be called. If the user choses to cancel the selection, the cancel block will be called. If you assigned a delegate the corresponding delegate methods will be called, too.
 *
 *  @warning This method should only be used on iPads in situations where [showWithSelectionHandler:andCancelHandler:]([RMPickerViewController showWithSelectionHandler:andCancelHandler:]) is not sufficient (for example, when the RMPickerViewController shoud be shown within an UIPopover). If [showWithSelectionHandler:andCancelHandler:]([RMPickerViewController showWithSelectionHandler:andCancelHandler:]) is sufficient, please use it!
 *
 *  @param aViewController The parent view controller of the RMPickerViewController.
 *  @param selectionBlock  The block to call when the user selects a row.
 *  @param cancelBlock     The block to call when the user cancels the selection.
 */
- (void)showFromViewController:(UIViewController *)aViewController withSelectionHandler:(RMSelectionBlock)selectionBlock andCancelHandler:(RMCancelBlock)cancelBlock;

/**
 *  This shows the picker view controller within a popover. The popover is initialized with the picker view controller as content view controller and then presented from the rect in the view given as parameters.
 *
 *  @warning Make sure the delegate property is assigned. Otherwise you will not get any calls when a row is selected or the selection has been canceled.
 *
 *  @warning This method should only be used on iPads. On iPhones please use [show]([RMPickerViewController show]) or [showWithSelectionHandler:andCancelHandler:]([RMPickerViewController showWithSelectionHandler:andCancelHandler:]) instead.
 *
 *  @param aRect The rect in the given view the popover should be presented from.
 *  @param aView The view the popover should be presented from.
 */
- (void)showFromRect:(CGRect)aRect inView:(UIView *)aView;

/**
 *  This shows the picker view controller within a popover. The popover is initialized with the picker view controller as content view controller and then presented from the rect in the view given as parameters.
 *
 *  After a row has been selected the selection block will be called. If the user choses to cancel the selection, the cancel block will be called. If you assigned a delegate the corresponding methods will be called, too.
 *
 *  @warning This method should only be used on iPads. On iPhones please use [show]([RMPickerViewController show]) or [showWithSelectionHandler:andCancelHandler:]([RMPickerViewController showWithSelectionHandler:andCancelHandler:]) instead.
 *
 *  @param aRect The rect in the given view the popover should be presented from.
 *  @param aView The view the popover should be presented from.
 *  @param selectionBlock The block to call when the user selects a row.
 *  @param cancelBlock    The block to call when the user cancels the selection.
 */
- (void)showFromRect:(CGRect)aRect inView:(UIView *)aView withSelectionHandler:(RMSelectionBlock)selectionBlock andCancelHandler:(RMCancelBlock)cancelBlock;

/// @name Dismissing

/**
 *  This will dismiss the picker view controller and remove it from the view hierarchy.
 */
- (void)dismiss;

@end

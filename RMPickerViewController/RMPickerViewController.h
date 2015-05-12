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

/**
 *  Set a image for the select button. Default is nil.
 *
 *  @param newImage    The new image for the select button.
 */
+ (void)setImageForSelectButton:(UIImage *)newImage;

/**
 *  Set a image for the cancel button. Default is nil.
 *
 *  @param newImage    The new image for the cancel button.
 */
+ (void)setImageForCancelButton:(UIImage *)newImage;

/// @name Block Support

/**
 *  The block that is executed when the select button is tapped.
 *
 *  @warning Although your app won't crash when presenting a RMPickerViewController without a select block, setting this block is not really optional. You will need this block to get the row selected by the user.
 */
@property (nonatomic, copy) void (^selectButtonAction)(RMPickerViewController *controller, NSArray *selectedRows);

/**
 *  The block that is executed when the cancel button or the background view is tapped.
 *
 *  @warning Setting this block is optional. the default behavior of RMPickerViewController already dismisses the view controller when select or cancel is tapped.
 */
@property (nonatomic, copy) void (^cancelButtonAction)(RMPickerViewController *controller);

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

/**
 * Used to set select button background color
 */
@property (strong, nonatomic) UIColor *selectButtonBackgroundColor;

/**
 * Used to set cancel button background color
 */
@property (strong, nonatomic) UIColor *cancelButtonBackgroundColor;

/**
 * Font used for buttons
 */
@property (strong, nonatomic) UIFont *buttonFont;

/// @name Effects

/**
 *  Used to enable or disable motion effects. Default value is NO.
 *
 *  @warning This property always returns YES, if motion is reduced via accessibilty options.
 */
@property (assign, nonatomic) BOOL disableMotionEffects;

/**
 *  Used to enable or disable bouncing effects when sliding in the picker view. Default value is NO.
 *
 *  @warning This property always returns YES, if motion is reduced via accessibilty options.
 */
@property (assign, nonatomic) BOOL disableBouncingWhenShowing;

/**
 *  Used to enable or disable blurring the picker view. Default value is NO.
 *
 *  @warning This property always returns YES if either UIBlurEffect, UIVibrancyEffect or UIVisualEffectView is not available on your system at runtime or transparency is reduced via accessibility options.
 */
@property (assign, nonatomic) BOOL disableBlurEffects;

/**
 *  Used to choose a particular blur effect style (default value is UIBlurEffectStyleExtraLight). Ignored if blur effects are disabled.
 */
@property (assign, nonatomic) UIBlurEffectStyle blurEffectStyle;

@end

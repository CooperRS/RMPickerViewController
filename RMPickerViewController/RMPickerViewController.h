//
//  RMPickerViewController.h
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

#import <RMActionController/RMActionController.h>

/**
 *  RMPickerViewController is an iOS control for selecting a row using UIPickerView in a UIActionSheet like fashion. When a RMPickerViewController is shown the user gets the opportunity to select some rows using a UIPickerView.
 *  
 *  RMPickerViewController supports bouncing effects when animating the picker view controller. In addition, motion effects are supported while showing the picker view controller. Both effects can be disabled by using the properties called disableBouncingWhenShowing and disableMotionEffects.
 *
 *  On iOS 8 and later Apple opened up their API for blurring the background of UIViews. RMPickerViewController makes use of this API. The type of the blur effect can be changed by using the blurEffectStyle property. If you want to disable the blur effect you can do so by using the disableBlurEffects property.
 *
 *  @warning RMPickerViewController is not designed to be reused. Each time you want to display a RMPickerViewController a new instance should be created. If you want to select a specific row before displaying, you can do so by using the picker property.
 */
@interface RMPickerViewController : RMActionController <UIPickerView *>

/// @name User Interface

/**
 *  Will return the instance of UIPickerView that is used.
 */
@property (nonatomic, readonly) UIPickerView *picker;

@end

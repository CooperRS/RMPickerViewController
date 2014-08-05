//
//  RMPickerViewController.m
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

/*
 * We need RMNonRotatingViewController because Apple decided that a UIWindow adds a black background while rotating.
 * ( http://stackoverflow.com/questions/19782944/blacked-out-interface-rotation-when-using-second-uiwindow-with-rootviewcontrolle )
 *
 * To work around this problem, the root view controller of our window is a RMNonRotatingPickerViewController which cannot rotate.
 * In this case, UIWindow does not add a black background (as it is not rotating any more) and we handle the rotation
 * ourselves.
 */
@interface RMNonRotatingPickerViewController : UIViewController

@property (nonatomic, assign) UIInterfaceOrientation mutableInterfaceOrientation;

@end

@implementation RMNonRotatingPickerViewController

#pragma mark - Init and Dealloc
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRotate) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    
    [super viewDidDisappear:animated];
}

#pragma mark - Orientation
- (BOOL)shouldAutorotate {
    return NO;
}

- (void)didRotate {
    [self updateUIForInterfaceOrientation:[UIApplication sharedApplication].statusBarOrientation animated:YES];
}

- (void)updateUIForInterfaceOrientation:(UIInterfaceOrientation)newOrientation animated:(BOOL)animated {
    CGFloat duration = 0.3f;
    CGFloat angle = 0.f;
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    
    if(newOrientation == UIInterfaceOrientationPortrait) {
        angle = 0;
        if(self.mutableInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
            duration = 0.6f;
    } else if(newOrientation == UIInterfaceOrientationPortraitUpsideDown) {
        angle = M_PI;
        if(self.mutableInterfaceOrientation == UIInterfaceOrientationPortrait)
            duration = 0.6f;
    } else if(newOrientation == UIInterfaceOrientationLandscapeLeft) {
        angle = -M_PI_2;
        if(self.mutableInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
            duration = 0.6f;
    } else if(newOrientation == UIInterfaceOrientationLandscapeRight) {
        angle = M_PI_2;
        if(self.mutableInterfaceOrientation == UIInterfaceOrientationLandscapeLeft)
            duration = 0.6f;
    }
    
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0 && UIInterfaceOrientationIsLandscape(newOrientation) && animated) {
        screenBounds = CGRectMake(0, 0, screenBounds.size.height, screenBounds.size.width);
    }
    
    if(animated) {
        [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            self.view.transform = CGAffineTransformMakeRotation(angle);
            self.view.frame = screenBounds;
        } completion:^(BOOL finished) {
        }];
    } else {
        self.view.transform = CGAffineTransformMakeRotation(angle);
        self.view.frame = screenBounds;
    }
    
    self.mutableInterfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
}

@end

#define RM_DATE_PICKER_HEIGHT_PORTRAIT 216
#define RM_DATE_PICKER_HEIGHT_LANDSCAPE 162

#import "RMPickerViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface RMPickerViewController ()

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) UIViewController *rootViewController;
@property (nonatomic, strong) UIView *backgroundView;

@property (nonatomic, weak) NSLayoutConstraint *xConstraint;
@property (nonatomic, weak) NSLayoutConstraint *yConstraint;
@property (nonatomic, weak) NSLayoutConstraint *widthConstraint;

@property (nonatomic, strong) UIView *titleLabelContainer;
@property (nonatomic, strong, readwrite) UILabel *titleLabel;

@property (nonatomic, strong) UIView *pickerContainer;
@property (nonatomic, readwrite, strong) UIPickerView *picker;
@property (nonatomic, strong) NSLayoutConstraint *pickerHeightConstraint;

@property (nonatomic, strong) UIView *cancelAndSelectButtonContainer;
@property (nonatomic, strong) UIView *cancelAndSelectButtonSeperator;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *selectButton;

@property (nonatomic, strong) UIMotionEffectGroup *motionEffectGroup;

@property (nonatomic, copy) RMSelectionBlock selectedDateBlock;
@property (nonatomic, copy) RMCancelBlock cancelBlock;

@property (nonatomic, assign) BOOL hasBeenDismissed;

@end

@implementation RMPickerViewController

@synthesize selectedBackgroundColor = _selectedBackgroundColor;

#pragma mark - Class
+ (instancetype)pickerController {
    return [[RMPickerViewController alloc] init];
}

static NSString *_localizedCancelTitle = @"Cancel";
static NSString *_localizedSelectTitle = @"Select";

+ (NSString *)localizedTitleForCancelButton {
    return _localizedCancelTitle;
}

+ (NSString *)localizedTitleForSelectButton {
    return _localizedSelectTitle;
}

+ (void)setLocalizedTitleForCancelButton:(NSString *)newLocalizedTitle {
    _localizedCancelTitle = newLocalizedTitle;
}

+ (void)setLocalizedTitleForSelectButton:(NSString *)newLocalizedTitle {
    _localizedSelectTitle = newLocalizedTitle;
}

+ (void)showDateSelectionViewController:(RMPickerViewController *)aPickerViewController usingWindow:(BOOL)extraWindow {
    if(extraWindow) {
        [(RMNonRotatingPickerViewController *)aPickerViewController.window.rootViewController updateUIForInterfaceOrientation:[UIApplication sharedApplication].statusBarOrientation animated:NO];
        [aPickerViewController.window makeKeyAndVisible];
    }
    
    aPickerViewController.backgroundView.alpha = 0;
    [aPickerViewController.rootViewController.view addSubview:aPickerViewController.backgroundView];
    
    [aPickerViewController.rootViewController.view addConstraint:[NSLayoutConstraint constraintWithItem:aPickerViewController.backgroundView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:aPickerViewController.rootViewController.view attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    [aPickerViewController.rootViewController.view addConstraint:[NSLayoutConstraint constraintWithItem:aPickerViewController.backgroundView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:aPickerViewController.rootViewController.view attribute:NSLayoutAttributeLeading multiplier:1 constant:0]];
    [aPickerViewController.rootViewController.view addConstraint:[NSLayoutConstraint constraintWithItem:aPickerViewController.backgroundView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:aPickerViewController.rootViewController.view attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
    [aPickerViewController.rootViewController.view addConstraint:[NSLayoutConstraint constraintWithItem:aPickerViewController.backgroundView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:aPickerViewController.rootViewController.view attribute:NSLayoutAttributeHeight multiplier:1 constant:0]];
    
    [aPickerViewController willMoveToParentViewController:aPickerViewController.rootViewController];
    [aPickerViewController viewWillAppear:YES];
    
    [aPickerViewController.rootViewController addChildViewController:aPickerViewController];
    [aPickerViewController.rootViewController.view addSubview:aPickerViewController.view];
    
    [aPickerViewController viewDidAppear:YES];
    [aPickerViewController didMoveToParentViewController:aPickerViewController.rootViewController];
    
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        if(UIInterfaceOrientationIsLandscape(aPickerViewController.rootViewController.interfaceOrientation)) {
            aPickerViewController.pickerHeightConstraint.constant = RM_DATE_PICKER_HEIGHT_LANDSCAPE;
        } else {
            aPickerViewController.pickerHeightConstraint.constant = RM_DATE_PICKER_HEIGHT_PORTRAIT;
        }
    }
    
    aPickerViewController.xConstraint = [NSLayoutConstraint constraintWithItem:aPickerViewController.view attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:aPickerViewController.rootViewController.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    aPickerViewController.yConstraint = [NSLayoutConstraint constraintWithItem:aPickerViewController.view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:aPickerViewController.rootViewController.view attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    aPickerViewController.widthConstraint = [NSLayoutConstraint constraintWithItem:aPickerViewController.view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:aPickerViewController.rootViewController.view attribute:NSLayoutAttributeWidth multiplier:1 constant:0];
    
    [aPickerViewController.rootViewController.view addConstraint:aPickerViewController.xConstraint];
    [aPickerViewController.rootViewController.view addConstraint:aPickerViewController.yConstraint];
    [aPickerViewController.rootViewController.view addConstraint:aPickerViewController.widthConstraint];
    
    [aPickerViewController.rootViewController.view setNeedsUpdateConstraints];
    [aPickerViewController.rootViewController.view layoutIfNeeded];
    
    [aPickerViewController.rootViewController.view removeConstraint:aPickerViewController.yConstraint];
    aPickerViewController.yConstraint = [NSLayoutConstraint constraintWithItem:aPickerViewController.view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:aPickerViewController.rootViewController.view attribute:NSLayoutAttributeBottom multiplier:1 constant:-10];
    [aPickerViewController.rootViewController.view addConstraint:aPickerViewController.yConstraint];
    
    [aPickerViewController.rootViewController.view setNeedsUpdateConstraints];
    
    CGFloat damping = 1.0f;
    CGFloat duration = 0.3f;
    if(!aPickerViewController.disableBouncingWhenShowing) {
        damping = 0.6f;
        duration = 1.0f;
    }
    
    [UIView animateWithDuration:duration delay:0 usingSpringWithDamping:damping initialSpringVelocity:1 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction animations:^{
        aPickerViewController.backgroundView.alpha = 1;
        
        [aPickerViewController.rootViewController.view layoutIfNeeded];
    } completion:^(BOOL finished) {
    }];
}

+ (void)dismissDateSelectionViewController:(RMPickerViewController *)aPickerViewController {
    [aPickerViewController.rootViewController.view removeConstraint:aPickerViewController.yConstraint];
    aPickerViewController.yConstraint = [NSLayoutConstraint constraintWithItem:aPickerViewController.view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:aPickerViewController.rootViewController.view attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    [aPickerViewController.rootViewController.view addConstraint:aPickerViewController.yConstraint];
    
    [aPickerViewController.rootViewController.view setNeedsUpdateConstraints];
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        aPickerViewController.backgroundView.alpha = 0;
        
        [aPickerViewController.rootViewController.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        [aPickerViewController willMoveToParentViewController:nil];
        [aPickerViewController viewWillDisappear:YES];
        
        [aPickerViewController.view removeFromSuperview];
        [aPickerViewController removeFromParentViewController];
        
        [aPickerViewController didMoveToParentViewController:nil];
        [aPickerViewController viewDidDisappear:YES];
        
        [aPickerViewController.backgroundView removeFromSuperview];
        aPickerViewController.window = nil;
        aPickerViewController.hasBeenDismissed = NO;
    }];
}

#pragma mark - Init and Dealloc
- (id)init {
    self = [super init];
    if(self) {
        [self setupUIElements];
    }
    return self;
}

- (void)setupUIElements {
    //Instantiate elements
    self.titleLabelContainer = [[UIView alloc] initWithFrame:CGRectZero];
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    
    self.pickerContainer = [[UIView alloc] initWithFrame:CGRectZero];
    self.picker = [[UIPickerView alloc] initWithFrame:CGRectZero];
    self.picker.delegate = self.delegate;
    self.picker.dataSource = self.delegate;
    
    self.cancelAndSelectButtonContainer = [[UIView alloc] initWithFrame:CGRectZero];
    self.cancelAndSelectButtonSeperator = [[UIView alloc] initWithFrame:CGRectZero];
    self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    //Add elements to their views
    [self.titleLabelContainer addSubview:self.titleLabel];
    
    [self.pickerContainer addSubview:self.picker];
    
    [self.cancelAndSelectButtonContainer addSubview:self.cancelAndSelectButtonSeperator];
    [self.cancelAndSelectButtonContainer addSubview:self.cancelButton];
    [self.cancelAndSelectButtonContainer addSubview:self.selectButton];
    
    //Setup properties of elements
    self.titleLabelContainer.backgroundColor = [UIColor whiteColor];
    self.titleLabelContainer.layer.cornerRadius = 5;
    self.titleLabelContainer.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel.textColor = [UIColor grayColor];
    self.titleLabel.font = [UIFont systemFontOfSize:12];
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.numberOfLines = 0;
    
    self.pickerContainer.backgroundColor = [UIColor whiteColor];
    self.pickerContainer.layer.cornerRadius = 5;
    self.pickerContainer.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.picker.layer.cornerRadius = 5;
    self.picker.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.cancelAndSelectButtonContainer.backgroundColor = [UIColor whiteColor];
    self.cancelAndSelectButtonContainer.layer.cornerRadius = 5;
    self.cancelAndSelectButtonContainer.clipsToBounds = YES;
    self.cancelAndSelectButtonContainer.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.cancelAndSelectButtonSeperator.backgroundColor = [UIColor lightGrayColor];
    self.cancelAndSelectButtonSeperator.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.cancelButton setTitle:[RMPickerViewController localizedTitleForCancelButton] forState:UIControlStateNormal];
    [self.cancelButton setTitleColor:[UIColor colorWithRed:0 green:122./255. blue:1 alpha:1] forState:UIControlStateNormal];
    [self.cancelButton addTarget:self action:@selector(cancelButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    self.cancelButton.layer.cornerRadius = 5;
    self.cancelButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.cancelButton setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    
    [self.selectButton setTitle:[RMPickerViewController localizedTitleForSelectButton] forState:UIControlStateNormal];
    [self.selectButton setTitleColor:[UIColor colorWithRed:0 green:122./255. blue:1 alpha:1] forState:UIControlStateNormal];
    [self.selectButton addTarget:self action:@selector(doneButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    self.selectButton.titleLabel.font = [UIFont boldSystemFontOfSize:[UIFont buttonFontSize]];
    self.selectButton.layer.cornerRadius = 5;
    self.selectButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.selectButton setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
}

- (void)setupConstraints {
    UIView *pickerContainer = self.pickerContainer;
    UIView *cancelSelectContainer = self.cancelAndSelectButtonContainer;
    UIView *seperator = self.cancelAndSelectButtonSeperator;
    UIButton *cancel = self.cancelButton;
    UIButton *select = self.selectButton;
    UIPickerView *picker = self.picker;
    UIView *labelContainer = self.titleLabelContainer;
    UILabel *label = self.titleLabel;
    
    NSDictionary *bindingsDict = NSDictionaryOfVariableBindings(cancelSelectContainer, seperator, pickerContainer, cancel, select, picker, labelContainer, label);
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(10)-[pickerContainer]-(10)-|" options:0 metrics:nil views:bindingsDict]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(10)-[cancelSelectContainer]-(10)-|" options:0 metrics:nil views:bindingsDict]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[pickerContainer]-(10)-[cancelSelectContainer(44)]-(0)-|" options:0 metrics:nil views:bindingsDict]];
    self.pickerHeightConstraint = [NSLayoutConstraint constraintWithItem:self.pickerContainer attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant:RM_DATE_PICKER_HEIGHT_PORTRAIT];
    [self.view addConstraint:self.pickerHeightConstraint];
    
    if(self.titleLabel.text && self.titleLabel.text.length != 0) {
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(10)-[labelContainer]-(10)-|" options:0 metrics:nil views:bindingsDict]];
        
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(0)-[labelContainer]-(10)-[pickerContainer]" options:0 metrics:nil views:bindingsDict]];
        
        [self.titleLabelContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(10)-[label]-(10)-|" options:0 metrics:nil views:bindingsDict]];
        [self.titleLabelContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(10)-[label]-(10)-|" options:0 metrics:nil views:bindingsDict]];
    } else {
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(0)-[pickerContainer]" options:0 metrics:nil views:bindingsDict]];
    }
    
    [self.pickerContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(0)-[picker]-(0)-|" options:0 metrics:nil views:bindingsDict]];
    [self.cancelAndSelectButtonContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(0)-[cancel]-(0)-[seperator(1)]-(0)-[select]-(0)-|" options:0 metrics:nil views:bindingsDict]];
    [self.cancelAndSelectButtonContainer addConstraint:[NSLayoutConstraint constraintWithItem:self.cancelAndSelectButtonSeperator attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.cancelAndSelectButtonContainer attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    
    [self.pickerContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(0)-[picker]-(0)-|" options:0 metrics:nil views:bindingsDict]];
    [self.cancelAndSelectButtonContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(0)-[cancel]-(0)-|" options:0 metrics:nil views:bindingsDict]];
    [self.cancelAndSelectButtonContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(0)-[seperator]-(0)-|" options:0 metrics:nil views:bindingsDict]];
    [self.cancelAndSelectButtonContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(0)-[select]-(0)-|" options:0 metrics:nil views:bindingsDict]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    self.view.backgroundColor = [UIColor clearColor];
    self.view.layer.masksToBounds = YES;
    
    if(self.titleLabel.text && self.titleLabel.text.length != 0)
        [self.view addSubview:self.titleLabelContainer];
    
    [self.view addSubview:self.pickerContainer];
    [self.view addSubview:self.cancelAndSelectButtonContainer];
    
    [self setupConstraints];
    
    if(self.tintColor) {
        [self.cancelButton setTitleColor:self.tintColor forState:UIControlStateNormal];
        [self.selectButton setTitleColor:self.tintColor forState:UIControlStateNormal];
    }
    
    if(self.backgroundColor) {
        self.titleLabelContainer.backgroundColor = self.backgroundColor;
        self.pickerContainer.backgroundColor = self.backgroundColor;
        self.cancelAndSelectButtonContainer.backgroundColor = self.backgroundColor;
    }
    
    if(self.selectedBackgroundColor) {
        [self.cancelButton setBackgroundImage:[self imageWithColor:self.selectedBackgroundColor] forState:UIControlStateHighlighted];
        [self.selectButton setBackgroundImage:[self imageWithColor:self.selectedBackgroundColor] forState:UIControlStateHighlighted];
    }
    
    if(!self.disableMotionEffects)
        [self addMotionEffects];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRotate) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    
    [super viewDidDisappear:animated];
}

#pragma mark - Orientation
- (void)didRotate {
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        if(UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
            self.pickerHeightConstraint.constant = RM_DATE_PICKER_HEIGHT_LANDSCAPE;
        } else {
            self.pickerHeightConstraint.constant = RM_DATE_PICKER_HEIGHT_PORTRAIT;
        }
        
        [self.picker setNeedsUpdateConstraints];
        [self.picker layoutIfNeeded];
        
        [self.window.rootViewController.view setNeedsUpdateConstraints];
        __weak RMPickerViewController *blockself = self;
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            [blockself.window.rootViewController.view layoutIfNeeded];
        } completion:^(BOOL finished) {
        }];
    }
}

#pragma mark - Helper
- (void)addMotionEffects {
    [self.view addMotionEffect:self.motionEffectGroup];
}

- (void)removeMotionEffects {
    [self.view removeMotionEffect:self.motionEffectGroup];
}

- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0, 0, 1, 1);
    
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    [color setFill];
    UIRectFill(rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

#pragma mark - Properties
- (void)setDelegate:(id<RMPickerViewControllerDelegate>)newDelegate {
    if(newDelegate != _delegate) {
        _delegate = newDelegate;
        
        self.picker.delegate = newDelegate;
        self.picker.dataSource = newDelegate;
    }
}

- (void)setDisableMotionEffects:(BOOL)newDisableMotionEffects {
    if(_disableMotionEffects != newDisableMotionEffects) {
        _disableMotionEffects = newDisableMotionEffects;
        
        if(newDisableMotionEffects) {
            [self removeMotionEffects];
        } else {
            [self addMotionEffects];
        }
    }
}

- (UIMotionEffectGroup *)motionEffectGroup {
    if(!_motionEffectGroup) {
        UIInterpolatingMotionEffect *verticalMotionEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
        verticalMotionEffect.minimumRelativeValue = @(-10);
        verticalMotionEffect.maximumRelativeValue = @(10);
        
        UIInterpolatingMotionEffect *horizontalMotionEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
        horizontalMotionEffect.minimumRelativeValue = @(-10);
        horizontalMotionEffect.maximumRelativeValue = @(10);
        
        _motionEffectGroup = [UIMotionEffectGroup new];
        _motionEffectGroup.motionEffects = @[horizontalMotionEffect, verticalMotionEffect];
    }
    
    return _motionEffectGroup;
}

- (UIWindow *)window {
    if(!_window) {
        self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        _window.windowLevel = UIWindowLevelStatusBar;
        _window.rootViewController = [[RMNonRotatingPickerViewController alloc] init];
    }
    
    return _window;
}

- (UIView *)backgroundView {
    if(!_backgroundView) {
        self.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
        _backgroundView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
        _backgroundView.translatesAutoresizingMaskIntoConstraints = NO;
        
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundViewTapped:)];
        [_backgroundView addGestureRecognizer:tapRecognizer];
    }
    
    return _backgroundView;
}

- (void)setTintColor:(UIColor *)newTintColor {
    if(_tintColor != newTintColor) {
        _tintColor = newTintColor;
        
        [self.cancelButton setTitleColor:newTintColor forState:UIControlStateNormal];
        [self.selectButton setTitleColor:newTintColor forState:UIControlStateNormal];
    }
}

- (void)setBackgroundColor:(UIColor *)newBackgroundColor {
    if(_backgroundColor != newBackgroundColor) {
        _backgroundColor = newBackgroundColor;
        
        self.titleLabelContainer.backgroundColor = newBackgroundColor;
        self.pickerContainer.backgroundColor = newBackgroundColor;
        self.cancelAndSelectButtonContainer.backgroundColor = newBackgroundColor;
    }
}

- (UIColor *)selectedBackgroundColor {
    if(!_selectedBackgroundColor) {
        self.selectedBackgroundColor = [UIColor colorWithWhite:230./255. alpha:1];
    }
    
    return _selectedBackgroundColor;
}

- (void)setSelectedBackgroundColor:(UIColor *)newSelectedBackgroundColor {
    if(_selectedBackgroundColor != newSelectedBackgroundColor) {
        _selectedBackgroundColor = newSelectedBackgroundColor;
        
        [self.cancelButton setBackgroundImage:[self imageWithColor:newSelectedBackgroundColor] forState:UIControlStateHighlighted];
        [self.selectButton setBackgroundImage:[self imageWithColor:newSelectedBackgroundColor] forState:UIControlStateHighlighted];
    }
}

#pragma mark - Presenting
- (void)show {
    [self showWithSelectionHandler:nil andCancelHandler:nil];
}

- (void)showWithSelectionHandler:(RMSelectionBlock)selectionBlock andCancelHandler:(RMCancelBlock)cancelBlock {
    self.selectedDateBlock = selectionBlock;
    self.cancelBlock = cancelBlock;
    self.rootViewController = self.window.rootViewController;
    
    [RMPickerViewController showDateSelectionViewController:self usingWindow:YES];
}

- (void)showFromViewController:(UIViewController *)aViewController {
    [self showFromViewController:aViewController withSelectionHandler:nil andCancelHandler:nil];
}

- (void)showFromViewController:(UIViewController *)aViewController withSelectionHandler:(RMSelectionBlock)selectionBlock andCancelHandler:(RMCancelBlock)cancelBlock {
    if([aViewController isKindOfClass:[UITableViewController class]]) {
        if(aViewController.navigationController) {
            NSLog(@"Warning: -[RMDateSelectionViewController showFromViewController:] has been called with an instance of UITableViewController as argument. Trying to use the navigation controller of the UITableViewController instance instead.");
            aViewController = aViewController.navigationController;
        } else {
            NSLog(@"Error: -[RMDateSelectionViewController showFromViewController:] has been called with an instance of UITableViewController as argument. Showing the date selection view controller from an instance of UITableViewController is not possible due to some internals of UIKit. To prevent your app from crashing, showing the date selection view controller will be canceled.");
            return;
        }
    }
    
    self.selectedDateBlock = selectionBlock;
    self.cancelBlock = cancelBlock;
    self.rootViewController = aViewController;
    
    [RMPickerViewController showDateSelectionViewController:self usingWindow:NO];
}

- (void)dismiss {
    [RMPickerViewController dismissDateSelectionViewController:self];
}

#pragma mark - Actions
- (IBAction)doneButtonPressed:(id)sender {
    if(!self.hasBeenDismissed) {
        self.hasBeenDismissed = YES;
        
        NSMutableArray *selectedRows = [NSMutableArray array];
        for(NSInteger i=0 ; i<[self.picker numberOfComponents] ; i++) {
            [selectedRows addObject:@([self.picker selectedRowInComponent:i])];
        }
        
        [self.delegate pickerViewController:self didSelectRows:selectedRows];
        if (self.selectedDateBlock) {
            self.selectedDateBlock(self, selectedRows);
        }
        [self performSelector:@selector(dismiss) withObject:nil afterDelay:0.1];
    }
}

- (IBAction)cancelButtonPressed:(id)sender {
    if(!self.hasBeenDismissed) {
        self.hasBeenDismissed = YES;
        
        [self.delegate pickerViewControllerDidCancel:self];
        if (self.cancelBlock) {
            self.cancelBlock(self);
        }
        [self performSelector:@selector(dismiss) withObject:nil afterDelay:0.1];
    }
}

- (IBAction)backgroundViewTapped:(UIGestureRecognizer *)sender {
    if(!self.backgroundTapsDisabled && !self.hasBeenDismissed) {
        self.hasBeenDismissed = YES;
        
        [self.delegate pickerViewControllerDidCancel:self];
        if (self.cancelBlock) {
            self.cancelBlock(self);
        }
        [self performSelector:@selector(dismiss) withObject:nil afterDelay:0.1];
    }
}

@end

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

@interface RMPickerViewController () <UIViewControllerTransitioningDelegate>

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

@property (nonatomic, assign) BOOL hasBeenDismissed;

@end

typedef NS_ENUM(NSInteger, RMPickerViewControllerAnimationStyle) {
    RMPickerViewControllerAnimationStylePresenting,
    RMPickerViewControllerAnimationStyleDismissing
};

@interface RMPickerViewControllerAnimationController : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign) RMPickerViewControllerAnimationStyle animationStyle;

@end

@implementation RMPickerViewControllerAnimationController

#pragma mark - Transition
- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    if(self.animationStyle == RMPickerViewControllerAnimationStylePresenting) {
        UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
        if([toVC isKindOfClass:[RMPickerViewController class]]) {
            RMPickerViewController *pickerVC = (RMPickerViewController *)toVC;
            
            if(pickerVC.disableBouncingWhenShowing) {
                return 0.3f;
            } else {
                return 1.0f;
            }
        }
    } else if(self.animationStyle == RMPickerViewControllerAnimationStyleDismissing) {
        return 0.3f;
    }
    
    return 1.0f;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIView *containerView = [transitionContext containerView];
    
    if(self.animationStyle == RMPickerViewControllerAnimationStylePresenting) {
        UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
        if([toVC isKindOfClass:[RMPickerViewController class]]) {
            RMPickerViewController *pickerVC = (RMPickerViewController *)toVC;
            
            pickerVC.backgroundView.alpha = 0;
            [containerView addSubview:pickerVC.backgroundView];
            [containerView addSubview:pickerVC.view];
            
            NSDictionary *bindingsDict = @{@"Container": containerView, @"BGView": pickerVC.backgroundView};
            
            [containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(0)-[BGView]-(0)-|" options:0 metrics:nil views:bindingsDict]];
            [containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(0)-[BGView]-(0)-|" options:0 metrics:nil views:bindingsDict]];
            
            if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
                if(RM_CURRENT_ORIENTATION_IS_LANDSCAPE_PREDICATE) {
                    pickerVC.pickerHeightConstraint.constant = RM_PICKER_HEIGHT_LANDSCAPE;
                } else {
                    pickerVC.pickerHeightConstraint.constant = RM_PICKER_HEIGHT_PORTRAIT;
                }
            }
            
            pickerVC.xConstraint = [NSLayoutConstraint constraintWithItem:pickerVC.view attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:containerView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
            pickerVC.yConstraint = [NSLayoutConstraint constraintWithItem:pickerVC.view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:containerView attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
            pickerVC.widthConstraint = [NSLayoutConstraint constraintWithItem:pickerVC.view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:containerView attribute:NSLayoutAttributeWidth multiplier:1 constant:0];
            
            [containerView addConstraint:pickerVC.xConstraint];
            [containerView addConstraint:pickerVC.yConstraint];
            [containerView addConstraint:pickerVC.widthConstraint];
            
            [containerView setNeedsUpdateConstraints];
            [containerView layoutIfNeeded];
            
            [containerView removeConstraint:pickerVC.yConstraint];
            pickerVC.yConstraint = [NSLayoutConstraint constraintWithItem:pickerVC.view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:containerView attribute:NSLayoutAttributeBottom multiplier:1 constant:-10];
            [containerView addConstraint:pickerVC.yConstraint];
            
            [containerView setNeedsUpdateConstraints];
            
            CGFloat damping = 1.0f;
            CGFloat duration = 0.3f;
            if(!pickerVC.disableBouncingWhenShowing) {
                damping = 0.6f;
                duration = 1.0f;
            }
            
            [UIView animateWithDuration:duration delay:0 usingSpringWithDamping:damping initialSpringVelocity:1 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction animations:^{
                pickerVC.backgroundView.alpha = 1;
                
                [containerView layoutIfNeeded];
            } completion:^(BOOL finished) {
                [transitionContext completeTransition:YES];
            }];
        }
    } else if(self.animationStyle == RMPickerViewControllerAnimationStyleDismissing) {
        UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
        if([fromVC isKindOfClass:[RMPickerViewController class]]) {
            RMPickerViewController *pickerVC = (RMPickerViewController *)fromVC;
            
            [containerView removeConstraint:pickerVC.yConstraint];
            pickerVC.yConstraint = [NSLayoutConstraint constraintWithItem:pickerVC.view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:containerView attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
            [containerView addConstraint:pickerVC.yConstraint];
            
            [containerView setNeedsUpdateConstraints];
            
            [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                pickerVC.backgroundView.alpha = 0;
                
                [containerView layoutIfNeeded];
            } completion:^(BOOL finished) {
                [pickerVC.view removeFromSuperview];
                [pickerVC.backgroundView removeFromSuperview];
                
                pickerVC.hasBeenDismissed = NO;
                [transitionContext completeTransition:YES];
            }];
        }
    }
}

@end

@implementation RMPickerViewController

@synthesize selectedBackgroundColor = _selectedBackgroundColor;
@synthesize disableMotionEffects = _disableMotionEffects;

#pragma mark - Class
+ (instancetype)pickerController {
    return [[RMPickerViewController alloc] init];
}

static NSString *_localizedCancelTitle = @"Cancel";
static NSString *_localizedSelectTitle = @"Select";
static UIImage *_selectImage;
static UIImage *_cancelImage;

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

+ (UIImage *)imageForSelectButton {
    return _selectImage;
}

+ (UIImage *)imageForCancelButton {
    return _cancelImage;
}

+ (void)setImageForSelectButton:(UIImage *)newImage {
    _selectImage = newImage;
}

+ (void)setImageForCancelButton:(UIImage *)newImage {
    _cancelImage = newImage;
}

#pragma mark - Init and Dealloc
- (id)init {
    self = [super init];
    if(self) {
        self.blurEffectStyle = UIBlurEffectStyleExtraLight;
        
        if([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
            self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        } else {
            self.modalPresentationStyle = UIModalPresentationCustom;
        }
        
        self.transitioningDelegate = self;
        
        [self setupUIElements];
    }
    return self;
}

- (void)setupUIElements {
    //Instantiate elements
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    
    self.picker = [[UIPickerView alloc] initWithFrame:CGRectZero];
    
    self.cancelAndSelectButtonSeperator = [[UIView alloc] initWithFrame:CGRectZero];
    self.cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.selectButton = [UIButton buttonWithType:UIButtonTypeSystem];
    
    //Setup properties of elements
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel.textColor = [UIColor grayColor];
    self.titleLabel.font = [UIFont systemFontOfSize:12];
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.numberOfLines = 0;
    
    self.picker.layer.cornerRadius = 4;
    self.picker.translatesAutoresizingMaskIntoConstraints = NO;
    
    if ([RMPickerViewController imageForSelectButton]) {
        [self.cancelButton setImage:[RMPickerViewController imageForCancelButton] forState:UIControlStateNormal];
    } else {
        [self.cancelButton setTitle:[RMPickerViewController localizedTitleForCancelButton] forState:UIControlStateNormal];
    }
    
    [self.cancelButton setTitle:[RMPickerViewController localizedTitleForCancelButton] forState:UIControlStateNormal];
    [self.cancelButton addTarget:self action:@selector(cancelButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    self.cancelButton.titleLabel.font = [UIFont systemFontOfSize:[UIFont buttonFontSize]];
    self.cancelButton.layer.cornerRadius = 4;
    self.cancelButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.cancelButton setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    
    if ([RMPickerViewController imageForSelectButton]) {
        [self.selectButton setImage:[RMPickerViewController imageForSelectButton] forState:UIControlStateNormal];
    } else {
        [self.selectButton setTitle:[RMPickerViewController localizedTitleForSelectButton] forState:UIControlStateNormal];
    }
    
    [self.selectButton setTitle:[RMPickerViewController localizedTitleForSelectButton] forState:UIControlStateNormal];
    [self.selectButton addTarget:self action:@selector(doneButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    self.selectButton.titleLabel.font = [UIFont boldSystemFontOfSize:[UIFont buttonFontSize]];
    self.selectButton.layer.cornerRadius = 4;
    self.selectButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.selectButton setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
}

- (void)setupContainerElements {
    if(!self.disableBlurEffects) {
        UIBlurEffect *blur = [UIBlurEffect effectWithStyle:self.blurEffectStyle];
        UIVibrancyEffect *vibrancy = [UIVibrancyEffect effectForBlurEffect:blur];
        
        UIVisualEffectView *vibrancyView = [[UIVisualEffectView alloc] initWithEffect:vibrancy];
        vibrancyView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        self.titleLabelContainer = [[UIVisualEffectView alloc] initWithEffect:blur];
        [((UIVisualEffectView *)self.titleLabelContainer).contentView addSubview:vibrancyView];
    } else {
        self.titleLabelContainer = [[UIView alloc] initWithFrame:CGRectZero];
    }
    
    if(!self.disableBlurEffects) {
        UIBlurEffect *blur = [UIBlurEffect effectWithStyle:self.blurEffectStyle];
        UIVibrancyEffect *vibrancy = [UIVibrancyEffect effectForBlurEffect:blur];
        
        UIVisualEffectView *vibrancyView = [[UIVisualEffectView alloc] initWithEffect:vibrancy];
        vibrancyView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        self.pickerContainer = [[UIVisualEffectView alloc] initWithEffect:blur];
        [((UIVisualEffectView *)self.pickerContainer).contentView addSubview:vibrancyView];
    } else {
        self.pickerContainer = [[UIView alloc] initWithFrame:CGRectZero];
    }
    
    if(!self.disableBlurEffects) {
        UIBlurEffect *blur = [UIBlurEffect effectWithStyle:self.blurEffectStyle];
        UIVibrancyEffect *vibrancy = [UIVibrancyEffect effectForBlurEffect:blur];
        
        UIVisualEffectView *vibrancyView = [[UIVisualEffectView alloc] initWithEffect:vibrancy];
        vibrancyView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        self.cancelAndSelectButtonContainer = [[UIVisualEffectView alloc] initWithEffect:blur];
        [((UIVisualEffectView *)self.cancelAndSelectButtonContainer).contentView addSubview:vibrancyView];
    } else {
        self.cancelAndSelectButtonContainer = [[UIView alloc] initWithFrame:CGRectZero];
    }
    
    if(!self.disableBlurEffects) {
        [[[[[(UIVisualEffectView *)self.titleLabelContainer contentView] subviews] objectAtIndex:0] contentView] addSubview:self.titleLabel];
        [[[[[(UIVisualEffectView *)self.pickerContainer contentView] subviews] objectAtIndex:0] contentView] addSubview:self.picker];
        
        [[[[[(UIVisualEffectView *)self.cancelAndSelectButtonContainer contentView] subviews] objectAtIndex:0] contentView] addSubview:self.cancelAndSelectButtonSeperator];
        [[[[[(UIVisualEffectView *)self.cancelAndSelectButtonContainer contentView] subviews] objectAtIndex:0] contentView] addSubview:self.cancelButton];
        [[[[[(UIVisualEffectView *)self.cancelAndSelectButtonContainer contentView] subviews] objectAtIndex:0] contentView] addSubview:self.selectButton];
        
        self.titleLabelContainer.backgroundColor = [UIColor clearColor];
        self.pickerContainer.backgroundColor = [UIColor clearColor];
        self.cancelAndSelectButtonContainer.backgroundColor = [UIColor clearColor];
    } else {
        [self.titleLabelContainer addSubview:self.titleLabel];
        [self.pickerContainer addSubview:self.picker];
        
        [self.cancelAndSelectButtonContainer addSubview:self.cancelAndSelectButtonSeperator];
        [self.cancelAndSelectButtonContainer addSubview:self.cancelButton];
        [self.cancelAndSelectButtonContainer addSubview:self.selectButton];
        
        self.titleLabelContainer.backgroundColor = [UIColor whiteColor];
        self.pickerContainer.backgroundColor = [UIColor whiteColor];
        self.cancelAndSelectButtonContainer.backgroundColor = [UIColor whiteColor];
    }
    
    self.titleLabelContainer.layer.cornerRadius = 4;
    self.titleLabelContainer.clipsToBounds = YES;
    self.titleLabelContainer.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.pickerContainer.layer.cornerRadius = 4;
    self.pickerContainer.clipsToBounds = YES;
    self.pickerContainer.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.cancelAndSelectButtonContainer.layer.cornerRadius = 4;
    self.cancelAndSelectButtonContainer.clipsToBounds = YES;
    self.cancelAndSelectButtonContainer.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.cancelAndSelectButtonSeperator.backgroundColor = [UIColor lightGrayColor];
    self.cancelAndSelectButtonSeperator.translatesAutoresizingMaskIntoConstraints = NO;
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
    self.pickerHeightConstraint = [NSLayoutConstraint constraintWithItem:self.pickerContainer attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant:RM_PICKER_HEIGHT_PORTRAIT];
    [self.view addConstraint:self.pickerHeightConstraint];
    
    [self.pickerContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(0)-[picker]-(0)-|" options:0 metrics:nil views:bindingsDict]];
    [self.cancelAndSelectButtonContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(0)-[cancel]-(0)-[seperator(1)]-(0)-[select]-(0)-|" options:0 metrics:nil views:bindingsDict]];
    [self.cancelAndSelectButtonContainer addConstraint:[NSLayoutConstraint constraintWithItem:self.cancelAndSelectButtonSeperator attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.cancelAndSelectButtonContainer attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    
    [self.pickerContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(0)-[picker]-(0)-|" options:0 metrics:nil views:bindingsDict]];
    [self.cancelAndSelectButtonContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(0)-[cancel]-(0)-|" options:0 metrics:nil views:bindingsDict]];
    [self.cancelAndSelectButtonContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(0)-[seperator]-(0)-|" options:0 metrics:nil views:bindingsDict]];
    [self.cancelAndSelectButtonContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(0)-[select]-(0)-|" options:0 metrics:nil views:bindingsDict]];
    
    NSDictionary *metricsDict = @{@"TopMargin": @(self.modalPresentationStyle == UIModalPresentationPopover ? 10 : 0)};
    
    if(self.titleLabel.text && self.titleLabel.text.length != 0) {
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(10)-[labelContainer]-(10)-|" options:0 metrics:nil views:bindingsDict]];
        
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(TopMargin)-[labelContainer]-(10)-[pickerContainer]" options:0 metrics:metricsDict views:bindingsDict]];
        
        [self.titleLabelContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(10)-[label]-(10)-|" options:0 metrics:nil views:bindingsDict]];
        [self.titleLabelContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(10)-[label]-(10)-|" options:0 metrics:nil views:bindingsDict]];
    } else {
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(TopMargin)-[pickerContainer]" options:0 metrics:metricsDict views:bindingsDict]];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    self.view.backgroundColor = [UIColor clearColor];
    self.view.layer.masksToBounds = YES;
    
    [self setupContainerElements];
    
    if(self.titleLabel.text && self.titleLabel.text.length != 0)
        [self.view addSubview:self.titleLabelContainer];
    
    [self.view addSubview:self.pickerContainer];
    [self.view addSubview:self.cancelAndSelectButtonContainer];
    
    [self setupConstraints];
    
    if(self.disableBlurEffects) {
        if(self.tintColor) {
            self.cancelButton.tintColor = self.tintColor;
            self.selectButton.tintColor = self.tintColor;
        } else {
            self.cancelButton.tintColor = [UIColor colorWithRed:0 green:122./255. blue:1 alpha:1];
            self.selectButton.tintColor = [UIColor colorWithRed:0 green:122./255. blue:1 alpha:1];
        }
    }
    
    if(self.backgroundColor) {
        if(!self.disableBlurEffects) {
            [((UIVisualEffectView *)self.titleLabelContainer).contentView setBackgroundColor:self.backgroundColor];
            [((UIVisualEffectView *)self.pickerContainer).contentView setBackgroundColor:self.backgroundColor];
            [((UIVisualEffectView *)self.cancelAndSelectButtonContainer).contentView setBackgroundColor:self.backgroundColor];
        } else {
            self.titleLabelContainer.backgroundColor = self.backgroundColor;
            self.pickerContainer.backgroundColor = self.backgroundColor;
            self.cancelAndSelectButtonContainer.backgroundColor = self.backgroundColor;
        }
    }
    
    if(self.selectedBackgroundColor) {
        if(!self.disableBlurEffects) {
            [self.cancelButton setBackgroundImage:[self imageWithColor:[self.selectedBackgroundColor colorWithAlphaComponent:0.3]] forState:UIControlStateHighlighted];
            [self.selectButton setBackgroundImage:[self imageWithColor:[self.selectedBackgroundColor colorWithAlphaComponent:0.3]] forState:UIControlStateHighlighted];
        } else {
            [self.cancelButton setBackgroundImage:[self imageWithColor:self.selectedBackgroundColor] forState:UIControlStateHighlighted];
            [self.selectButton setBackgroundImage:[self imageWithColor:self.selectedBackgroundColor] forState:UIControlStateHighlighted];
        }
    }
    
    if(!self.disableMotionEffects)
        [self addMotionEffects];
    
    if([self respondsToSelector:@selector(popoverPresentationController)]) {
        CGSize minimalSize = [self.view systemLayoutSizeFittingSize:CGSizeMake(999, 999)];
        self.preferredContentSize = CGSizeMake(minimalSize.width, minimalSize.height+10);
        self.popoverPresentationController.backgroundColor = self.backgroundView.backgroundColor;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //Row selection controller will appear, so it hasn't been dismissed, right?
    self.hasBeenDismissed = NO;
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

#pragma mark - Custom Properties
- (BOOL)disableBlurEffects {
    if(!NSClassFromString(@"UIBlurEffect") || !NSClassFromString(@"UIVibrancyEffect") || !NSClassFromString(@"UIVisualEffectView")) {
        return YES;
    } else if(&UIAccessibilityIsReduceTransparencyEnabled != nil && UIAccessibilityIsReduceTransparencyEnabled()) {
        return YES;
    }
    
    return _disableBlurEffects;
}

- (BOOL)disableMotionEffects {
    if(&UIAccessibilityIsReduceMotionEnabled != nil && UIAccessibilityIsReduceMotionEnabled()) {
        return YES;
    }
    
    return _disableMotionEffects;
}

- (void)setDisableMotionEffects:(BOOL)newDisableMotionEffects {
    if(_disableMotionEffects != newDisableMotionEffects) {
        _disableMotionEffects = newDisableMotionEffects;
        
        if([self isViewLoaded]) {
            if(newDisableMotionEffects) {
                [self removeMotionEffects];
            } else {
                [self addMotionEffects];
            }
        }
    }
}

- (BOOL)disableBouncingWhenShowing {
    if(&UIAccessibilityIsReduceMotionEnabled != nil && UIAccessibilityIsReduceMotionEnabled()) {
        return YES;
    }
    
    return _disableBouncingWhenShowing;
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
        
        if(!self.disableBlurEffects) {
            self.picker.tintColor = newTintColor;
        }
        
        self.cancelButton.tintColor = newTintColor;
        self.selectButton.tintColor = newTintColor;
    }
}

- (void)setBackgroundColor:(UIColor *)newBackgroundColor {
    if(_backgroundColor != newBackgroundColor) {
        _backgroundColor = newBackgroundColor;
        
        if([self isViewLoaded]) {
            if(!self.disableBlurEffects &&
               [self.titleLabelContainer isKindOfClass:[UIVisualEffectView class]] &&
               [self.pickerContainer isKindOfClass:[UIVisualEffectView class]] &&
               [self.cancelAndSelectButtonContainer isKindOfClass:[UIVisualEffectView class]]) {
                [((UIVisualEffectView *)self.titleLabelContainer).contentView setBackgroundColor:newBackgroundColor];
                [((UIVisualEffectView *)self.pickerContainer).contentView setBackgroundColor:newBackgroundColor];
                [((UIVisualEffectView *)self.cancelAndSelectButtonContainer).contentView setBackgroundColor:newBackgroundColor];
            } else {
                self.titleLabelContainer.backgroundColor = newBackgroundColor;
                self.pickerContainer.backgroundColor = newBackgroundColor;
                self.cancelAndSelectButtonContainer.backgroundColor = newBackgroundColor;
            }
        }
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
        
        if(!self.disableBlurEffects) {
            [self.cancelButton setBackgroundImage:[self imageWithColor:[newSelectedBackgroundColor colorWithAlphaComponent:0.3]] forState:UIControlStateHighlighted];
            [self.selectButton setBackgroundImage:[self imageWithColor:[newSelectedBackgroundColor colorWithAlphaComponent:0.3]] forState:UIControlStateHighlighted];
        } else {
            [self.cancelButton setBackgroundImage:[self imageWithColor:newSelectedBackgroundColor] forState:UIControlStateHighlighted];
            [self.selectButton setBackgroundImage:[self imageWithColor:newSelectedBackgroundColor] forState:UIControlStateHighlighted];
        }
    }
}

#pragma mark - Custom Transitions
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    RMPickerViewControllerAnimationController *animationController = [[RMPickerViewControllerAnimationController alloc] init];
    animationController.animationStyle = RMPickerViewControllerAnimationStylePresenting;
    
    return animationController;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    RMPickerViewControllerAnimationController *animationController = [[RMPickerViewControllerAnimationController alloc] init];
    animationController.animationStyle = RMPickerViewControllerAnimationStyleDismissing;
    
    return animationController;
}

#pragma mark - Actions
- (IBAction)doneButtonPressed:(id)sender {
    if(!self.hasBeenDismissed) {
        self.hasBeenDismissed = YES;
        
        NSMutableArray *selectedRows = [NSMutableArray array];
        for(NSInteger i=0 ; i<[self.picker numberOfComponents] ; i++) {
            [selectedRows addObject:@([self.picker selectedRowInComponent:i])];
        }
        
        if(self.selectButtonAction) {
            self.selectButtonAction(self, selectedRows);
        }
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)cancelButtonPressed:(id)sender {
    if(!self.hasBeenDismissed) {
        self.hasBeenDismissed = YES;
        
        if(self.cancelButtonAction) {
            self.cancelButtonAction(self);
        }
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)backgroundViewTapped:(UIGestureRecognizer *)sender {
    if(!self.backgroundTapsDisabled) {
        [self cancelButtonPressed:sender];
    }
}

@end

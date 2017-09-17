RMPickerViewController [![Build Status](https://travis-ci.org/CooperRS/RMPickerViewController.svg?branch=master)](https://travis-ci.org/CooperRS/RMPickerViewController/) [![Pod Version](https://img.shields.io/cocoapods/v/RMPickerViewController.svg)](https://cocoapods.org/pods/RMPickerViewController) [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
=============================

This framework allows you to pick something with a picker presented as an action sheet. In addition, it allows you to add actions arround the presented picker which behave like a button and can be tapped by the user. The result looks very much like an UIActionSheet or UIAlertController with a UIPickerView and some UIActions attached.

Besides being a fully-usable project, RMPickerViewController also is an example for an use case of [RMActionController](https://github.com/CooperRS/RMActionController). You can use it to learn how to present a picker other than UIPickerView.

## Screenshots

### Portrait

| White | Black |
|:-----:|:-----:|
|![White Version](https://raw.githubusercontent.com/CooperRS/RMPickerViewController/gh-pages/images/Blur-Screen1.png)|![Black version](https://raw.githubusercontent.com/CooperRS/RMPickerViewController/gh-pages/images/Blur-Screen3.png)|

### Landscape

![Landscape](https://raw.githubusercontent.com/CooperRS/RMPickerViewController/gh-pages/images/Blur-Screen2.png)

## Demo Project
If you want to run the demo project do not forget to initialize submodules.

## Installation (CocoaPods)
```ruby
platform :ios, '8.0'
pod "RMPickerViewController", "~> 2.3.1"
```

## Usage

For a detailed description on how to use RMPickerViewController take a look at the [Wiki Pages](https://github.com/CooperRS/RMPickerViewController/wiki). The following four steps are a very short intro:

* Import RMPickerViewController:

```objc
#import <RMPickerViewController/RMPickerViewController.h>
```

* Create select and cancel actions:

```objc
RMAction<UIPickerView *> *selectAction = [RMAction<UIPickerView *> actionWithTitle:@"Select" style:RMActionStyleDone andHandler:^(RMActionController<UIPickerView *> *controller) {
    NSMutableArray *selectedRows = [NSMutableArray array];
    
    for(NSInteger i=0 ; i<[controller.contentView numberOfComponents] ; i++) {
        [selectedRows addObject:@([controller.contentView selectedRowInComponent:i])];
    }
    
    NSLog(@"Successfully selected rows: %@", selectedRows);
}];

RMAction<UIPickerView *> *cancelAction = [RMAction<UIPickerView *> actionWithTitle:@"Cancel" style:RMActionStyleCancel andHandler:^(RMActionController<UIPickerView *> *controller) {
    NSLog(@"Row selection was canceled");
}];
```

* Create and instance of RMPickerViewController and present it:

```objc
RMPickerViewController *pickerController = [RMPickerViewController actionControllerWithStyle:style title:@"Test" message:@"This is a test message.\nPlease choose a row and press 'Select' or 'Cancel'." selectAction:selectAction andCancelAction:cancelAction];
pickerController.picker.dataSource = self;
pickerController.picker.delegate = self;

[self presentViewController:pickerController animated:YES completion:nil];
```

* The following code block shows you a complete method:

```objc
- (IBAction)openPickerController:(id)sender {
    RMAction<UIPickerView *> *selectAction = [RMAction<UIPickerView *> actionWithTitle:@"Select" style:RMActionStyleDone andHandler:^(RMActionController<UIPickerView *> *controller) {
        NSMutableArray *selectedRows = [NSMutableArray array];
    
        for(NSInteger i=0 ; i<[controller.contentView numberOfComponents] ; i++) {
            [selectedRows addObject:@([controller.contentView selectedRowInComponent:i])];
        }
        
        NSLog(@"Successfully selected rows: %@", selectedRows);
    }];
    
    RMAction<UIPickerView *> *cancelAction = [RMAction<UIPickerView *> actionWithTitle:@"Cancel" style:RMActionStyleCancel andHandler:^(RMActionController<UIPickerView *> *controller) {
        NSLog(@"Row selection was canceled");
    }];
    
    RMPickerViewController *pickerController = [RMPickerViewController actionControllerWithStyle:style title:@"Test" message:@"This is a test message.\nPlease choose a row and press 'Select' or 'Cancel'." selectAction:selectAction andCancelAction:cancelAction];
    pickerController.picker.dataSource = self;
    pickerController.picker.delegate = self;
    
    [self presentViewController:pickerController animated:YES completion:nil];
}
```

## Migration

See [Migration](https://github.com/CooperRS/RMPickerViewController/wiki/Migration) on how to migrate to the latest version of RMPickerViewController.

## Documentation
There is an additional documentation available provided by the CocoaPods team. Take a look at [cocoadocs.org](http://cocoadocs.org/docsets/RMPickerViewController/).

## Requirements

| Compile Time  | Runtime       |
| :------------ | :------------ |
| Xcode 7       | iOS 8         |
| iOS 9 SDK     |               |
| ARC           |               |

Note: ARC can be turned on and off on a per file basis.

Version 1.4.0 and above of RMPickerViewController use custom transitions for presenting the picker view controller. Custom transitions are a new feature introduced by Apple in iOS 7. Unfortunately, custom transitions are totally broken in landscape mode on iOS 7. This issue has been fixed with iOS 8. So if your application supports landscape mode (even on iPad), version 1.4.0 and above of this control require iOS 8. Otherwise, iOS 7 should be fine. In particular, iOS 7 is fine for version 1.3.3 and below.

## Further Info
If you want to show an UIDatePicker instead of an UIPickerView, you may take a look at my other control called [RMDateSelectionViewController](https://github.com/CooperRS/RMDateSelectionViewController).

If you want to show any other control you may want to take a look at [RMActionController](https://github.com/CooperRS/RMActionController).

## Credits
Code contributions:
* Denis Andrasec
	* Bugfixes
* steveoleary
	* Bugfixes

I want to thank everyone who has contributed code and/or time to this project!

## License (MIT License)

```
Copyright (c) 2013-2016 Roland Moers

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
```

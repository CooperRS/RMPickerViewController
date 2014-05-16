RMPickerViewController
=============================

This is an iOS control for selecting something using UIPickerView in a UIActionSheet like fashion

### Portrait
![Portrait](http://cooperrs.github.io/RMPickerViewController/images/Screen1.png)

### Landscape
![Landscape](http://cooperrs.github.com/RMPickerViewController/images/Screen2.png)

##Installation
###CocoaPods
```ruby
platform :ios, '7.0'
pod "RMPickerViewController", "~> 1.1.1"
```

###Manual
1. Check out the project
2. Add all files in `RMPickerViewController folder to Xcode

##Usage
###Basic
1. Import `RMPickerViewController.h` in your view controller
	
	```objc
	#import "RMPickerViewController.h"
	```
2. Implement the `RMPickerViewControllerDelegate` protocol
	
	```objc
	@interface YourViewController () <RMPickerViewControllerDelegate>
	@end
	```
	
	```objc
	#pragma mark - RMPickerViewController Delegates
	- (void)pickerViewController:(RMDateSelectionViewController *)vc didSelectRows:(NSArray  *)selectedRows {
		//Do something
	}

	- (void)pickerViewControllerDidCancel:(RMDateSelectionViewController *)vc {
		//Do something else
	}
	```
	
3. Open date selection view controller
	
	```objc
	- (IBAction)openSelectionController:(id)sender {
    	RMPickerViewController *pickerVC = [RMPickerViewController pickerController];
    	pickerVC.delegate = self;
    	
   		[pickerVC show];
	}
	
4. Do not forget to implement `UIPickerViewDelegate` and `UIPickerViewDataSource` methods.

###How to localize the buttons? 
[Localization](https://github.com/CooperRS/RMPickerViewController/wiki/Localization)

###Limitations
Due to some UIKit internals, it is not possible to show a picker view controller from an instance of UITableViewController. If the UITableViewController instance is wrapped into an UINavigationController instance the date selection view controller will be shown from the UINavigationController instance. If no UINavigationController can be used instead, an error will be logged and showing the date selection view controller will be canceled (to prevent your app from crashing).

## Requirements
Works with:

* Xcode 5
* iOS 7 SDK
* ARC (You can turn it on and off on a per file basis)

May also work with previous Xcode and iOS SDK versions. But it will at least need a system capable of Autolayout (and I think it will look awful on iOS 6 ;)...)

##Credits
Code contributions:
* Denis Andrasec
	* Bugfixes

I want to thank everyone who has contributed code and/or time to this project!

## License (MIT License)
Copyright (c) 2013 Roland Moers

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

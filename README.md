RMPickerViewController
=============================

This is an iOS control for selecting something using UIPickerView in a UIActionSheet like fashion

## Screenshots
### Portrait
![Portrait](http://cooperrs.github.io/RMPickerViewController/images/Blur-Screen1.png)

### Landscape
![Landscape](http://cooperrs.github.com/RMPickerViewController/images/Blur-Screen2.png)

### Black version
![Black version](http://cooperrs.github.com/RMPickerViewController/images/Blur-Screen3.png)

## Demo Project
If you want to run the demo project you first need to run `pod install` to install the dependencies of RMPickerViewController.

## Installation (CocoaPods)
```ruby
platform :ios, '8.0'
pod "RMPickerViewController", "~> 2.0.1"
```

## Usage
### Basic
1. Import `RMPickerViewController.h` in your view controller
	
	```objc
	#import "RMPickerViewController.h"
	```
2. Create a picker view controller, set select and cancel block and present the view controller
	
	```objc
    - (IBAction)openPickerController:(id)sender {
        //Create select action
        RMAction *selectAction = [RMAction actionWithTitle:@"Select" style:RMActionStyleDone andHandler:^(RMActionController *controller) {
            UIPickerView *picker = ((RMPickerViewController *)controller).picker;
            NSMutableArray *selectedRows = [NSMutableArray array];
            
            for(NSInteger i=0 ; i<[picker numberOfComponents] ; i++) {
                [selectedRows addObject:@([picker selectedRowInComponent:i])];
            }
            
            NSLog(@"Successfully selected rows: %@", selectedRows);
        }];
        

        RMAction *cancelAction = [RMAction actionWithTitle:@"Cancel" style:RMActionStyleCancel andHandler:^(RMActionController *controller) {
            NSLog(@"Row selection was canceled");
        }];

        //Create picker view controller
        RMPickerViewController *pickerController = [RMPickerViewController actionControllerWithStyle:style selectAction:selectAction andCancelAction:cancelAction];
        pickerController.picker.delegate = self;
        pickerController.picker.dataSource = self;

        //Now just present the picker controller using the standard iOS presentation method
        [self presentViewController:pickerController animated:YES completion:nil];
    }
	```
	
3. Do not forget to implement `UIPickerViewDelegate` and `UIPickerViewDataSource` methods.

###Advanced

#### Accessing the Picker
Every RMPickerViewController has a property `picker`. With this property you have total control over the UIPickerView that is shown on the screen.

#### Presentation Style
Additionally, you can use the property `modalPresentationStyle` to control how the picker view controller is shown. By default, it is set to `UIModalPresentationOverCurrentContext`. But on the iPad you could use `UIModalPresentationPopover` to present the picker view controller within a popover. See the following example on how this works:

```objc
- (IBAction)openPickerController:(id)sender {
    //Create select and cancel action
    ...

    RMPickerViewController *pickerController = [RMPickerViewController actionControllerWithStyle:style selectAction:selectAction andCancelAction:cancelAction];

    //On the iPad we want to show the picker view controller within a popover.
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        //First we set the modal presentation style to the popover style
        pickerController.modalPresentationStyle = UIModalPresentationPopover;

        //Then we tell the popover presentation controller, where the popover should appear
        pickerController.popoverPresentationController.sourceView = self.tableView;
        pickerController.popoverPresentationController.sourceRect = [self.tableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    }
    
    //Now just present the picker view controller using the standard iOS presentation method
    [self presentViewController:pickerController animated:YES completion:nil];
}
```

#### Adding Additional Buttons
You can add an arbitrary number of custom buttons to a RMPickerViewController. Each button has it's own block that is executed when tapping the button. See the following example on how to add buttons.

```objc
- (IBAction)openPickerController:(id)sender {
    //Create select and cancel action
    ...

    RMPickerViewController *pickerController = [RMPickerViewController actionControllerWithStyle:style selectAction:selectAction andCancelAction:cancelAction];
    
    //Create additional action and add it to picker view controller
    RMAction *additionalAction = [RMAction actionWithTitle:@"Additional" style:RMActionStyleAdditional andHandler:^(RMActionController *controller) {
        NSLog(@"Additional button tapped");
    }];
    additionalAction.dismissesActionController = NO;
    
    [pickerController addAction:additionalAction];
    
    //Now just present the picker view controller using the standard iOS presentation method
    [self presentViewController:pickerController animated:YES completion:nil];
}
```

#### Others
Finially, RMPickerViewController can be used in both your main application and an action extension showing UI.

## Documentation
There is an additional documentation available provided by the CocoaPods team. Take a look at [cocoadocs.org](http://cocoadocs.org/docsets/RMPickerViewController/).

## Requirements

| Compile Time  | Runtime       |
| :------------ | :------------ |
| Xcode 6       | iOS 8         |
| iOS 8 SDK     |               |
| ARC           |               |

Note: ARC can be turned on and off on a per file basis.

Version 1.4.0 and above of RMPickerViewController use custom transitions for presenting the picker view controller. Custom transitions are a new feature introduced by Apple in iOS 7. Unfortunately, custom transitions are totally broken in landscape mode on iOS 7. This issue has been fixed with iOS 8. So if your application supports landscape mode (even on iPad), version 1.4.0 and above of this control require iOS 8. Otherwise, iOS 7 should be fine. In particular, iOS 7 is fine for version 1.3.3 and below.

## Further Info
If you want to show an UIDatePicker instead of an UIPickerView, you may take a look at my other control called [RMDateSelectionViewController](https://github.com/CooperRS/RMDateSelectionViewController).

If you want to show any other control you may want to take a look at [RMActionController](https://github.com/CooperRS/RMActionController).

##Credits
Code contributions:
* Denis Andrasec
	* Bugfixes
* steveoleary
	* Bugfixes

I want to thank everyone who has contributed code and/or time to this project!

## License (MIT License)
Copyright (c) 2013-2015 Roland Moers

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

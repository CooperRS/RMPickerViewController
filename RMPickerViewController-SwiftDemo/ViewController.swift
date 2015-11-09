//
//  MasterViewController.swift
//  RMActionController-SwiftDemo
//
//  Created by Roland Moers on 19.08.15.
//  Copyright (c) 2015 Roland Moers. All rights reserved.
//

import UIKit
import RMPickerViewController

class ViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    //MARK: Properties
    @IBOutlet weak var blackSwitch: UISwitch!
    @IBOutlet weak var blurSwitch: UISwitch!
    @IBOutlet weak var motionSwitch: UISwitch!
    @IBOutlet weak var bouncingSwitch: UISwitch!
    
    // MARK: Actions
    func openPickerViewController() {
        var style = RMActionControllerStyle.White
        if self.blackSwitch.on {
            style = RMActionControllerStyle.Black
        }
        
        let selectAction = RMAction(title: "Select", style: RMActionStyle.Done) { controller in
            if let pickerController = controller as? RMPickerViewController {
                let selectedRows = NSMutableArray();
                
                for(var i=0 ; i<pickerController.picker.numberOfComponents ; i++) {
                    selectedRows.addObject(pickerController.picker.selectedRowInComponent(i));
                }
                
                print("Successfully selected rows: ", selectedRows);
            }
        }
        
        let cancelAction = RMAction(title: "Cancel", style: RMActionStyle.Cancel) { _ in
            print("Row selection was canceled")
        }
        
        let actionController = RMPickerViewController(style: style, title: "Test", message: "This is a test message.\nPlease choose a row and press 'Select' or 'Cancel'.", selectAction: selectAction, andCancelAction: cancelAction)!;
        
        //You can enable or disable blur, bouncing and motion effects
        actionController.disableBouncingEffects = !self.bouncingSwitch.on
        actionController.disableMotionEffects = !self.motionSwitch.on
        actionController.disableBlurEffects = !self.blurSwitch.on
        
        actionController.picker.delegate = self;
        actionController.picker.dataSource = self;
        
        //On the iPad we want to show the date selection view controller within a popover. Fortunately, we can use iOS 8 API for this! :)
        //(Of course only if we are running on iOS 8 or later)
        if actionController.respondsToSelector(Selector("popoverPresentationController:")) && UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad {
            //First we set the modal presentation style to the popover style
            actionController.modalPresentationStyle = UIModalPresentationStyle.Popover
            
            //Then we tell the popover presentation controller, where the popover should appear
            if let popoverPresentationController = actionController.popoverPresentationController {
                popoverPresentationController.sourceView = self.tableView
                popoverPresentationController.sourceRect = self.tableView.rectForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))
            }
        }
        
        //Now just present the date selection controller using the standard iOS presentation method
        presentViewController(actionController, animated: true, completion: nil)
    }
    
    // MARK: UITableView Delegates
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            openPickerViewController()
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // MARK: UIPickerView Delegates
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1;
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 5;
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return NSString(format: "Row %lu", row) as String;
    }
    
}


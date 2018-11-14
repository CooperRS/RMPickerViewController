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
    @IBOutlet weak var blurActionSwitch: UISwitch!
    @IBOutlet weak var motionSwitch: UISwitch!
    @IBOutlet weak var bouncingSwitch: UISwitch!
    
    // MARK: Actions
    func openPickerViewController() {
        var style = RMActionControllerStyle.white
        if self.blackSwitch.isOn {
            style = RMActionControllerStyle.black
        }
        
        let selectAction = RMAction<UIPickerView>(title: "Select", style: .done) { controller in
            let selectedRows = NSMutableArray();
            for i in 0 ..< controller.contentView.numberOfComponents {
                selectedRows.add(controller.contentView.selectedRow(inComponent: i));
            }
            print("Successfully selected rows: ", selectedRows);
        }
        
        let cancelAction = RMAction<UIPickerView>(title: "Cancel", style: .cancel) { _ in
            print("Row selection was canceled")
        }
        
        let actionController = RMPickerViewController(style: style, title: "Test", message: "This is a test message.\nPlease choose a row and press 'Select' or 'Cancel'.", select: selectAction, andCancel: cancelAction);
        
        //You can enable or disable blur, bouncing and motion effects
        actionController.disableBouncingEffects = !self.bouncingSwitch.isOn
        actionController.disableMotionEffects = !self.motionSwitch.isOn
        actionController.disableBlurEffects = !self.blurSwitch.isOn
        actionController.disableBlurEffectsForActions = !self.blurActionSwitch.isOn
        
        actionController.picker.delegate = self;
        actionController.picker.dataSource = self;
        
        //On the iPad we want to show the date selection view controller within a popover. Fortunately, we can use iOS 8 API for this! :)
        //(Of course only if we are running on iOS 8 or later)
        if actionController.responds(to: Selector(("popoverPresentationController:"))) && UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad {
            //First we set the modal presentation style to the popover style
            actionController.modalPresentationStyle = UIModalPresentationStyle.popover
            
            //Then we tell the popover presentation controller, where the popover should appear
            if let popoverPresentationController = actionController.popoverPresentationController {
                popoverPresentationController.sourceView = self.tableView
                popoverPresentationController.sourceRect = self.tableView.rectForRow(at: IndexPath(row: 0, section: 0))
            }
        }
        
        //Now just present the date selection controller using the standard iOS presentation method
        present(actionController, animated: true, completion: nil)
    }
    
    // MARK: UITableView Delegates
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            openPickerViewController()
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: UIPickerView Delegates
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1;
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 5;
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return NSString(format: "Row %lu", row) as String;
    }
    
}


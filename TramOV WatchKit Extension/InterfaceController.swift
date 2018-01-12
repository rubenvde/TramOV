//
//  InterfaceController.swift
//  TramOV WatchKit Extension
//
//  Created by Ruben van den Engel on 10/01/2018.
//  Copyright © 2018 Ruben van den Engel. All rights reserved.
//

import WatchKit
import Foundation

class InterfaceController: WKInterfaceController {
  
  @IBOutlet var picker: WKInterfacePicker!
  
  var foodList: [String] = ["Thuis", "Werk"]
  var selected: String = "Thuis"
  override func awake(withContext context: Any?) {
    super.awake(withContext: context)
    
    // Configure interface objects here.
  }
  
  override func willActivate() {
    // This method is called when watch view controller is about to be visible to user
    super.willActivate()
    
    let pickerItems: [WKPickerItem] = foodList.map {
      let pickerItem = WKPickerItem()
      pickerItem.title = $0
      return pickerItem
    }
    picker.setItems(pickerItems)
    
    
  }
  @IBAction func search() {
    
  }
  
  @IBAction func pickerSelectedItemChanged(value: Int) {
    self.selected = foodList[value]
  }
  override func didDeactivate() {
    // This method is called when watch view controller is no longer visible
    super.didDeactivate()
  }
  
  override func contextForSegue(withIdentifier segueIdentifier: String) -> Any? {
    if segueIdentifier == "search" {
      return selected
    } else {
      return nil
    }
  }
  
}

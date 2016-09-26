//
//  HomeViewControllerExtension.swift
//  Movy
//
//  Created by Prateek Grover on 26/09/16.
//  Copyright © 2016 prateekgrover. All rights reserved.
//

import Foundation
import UIKit

extension HomeViewController : UIPickerViewDelegate, UIPickerViewDataSource{
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row == 0{
            return "Popularity"
        }else{
            return "User Rating"
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print(row)
        self.sortOrderTextField.text = row == 0 ? "Popularity" : "User Rating"
        self.sortOrderTextField.resignFirstResponder()
    }
    
}

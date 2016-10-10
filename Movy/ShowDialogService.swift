//
//  ShowDialogService.swift
//  Movy
//
//  Created by Prateek Grover on 09/10/16.
//  Copyright © 2016 prateekgrover. All rights reserved.
//

import Foundation
import UIKit
import MBProgressHUD
import ReachabilitySwift

class ShowDialogService : NSObject{
    
    static let sharedInstance = ShowDialogService()
    
    fileprivate var currentContext:UIView!
    
    override init(){
        super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.showErrorDialog(notification:)), name: MovieViewModel.onError, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func setCurrentContext(context:UIView){
        self.currentContext = context
    }
    
    func showHUD(message:String){
        DispatchQueue.main.async {
            let loader = MBProgressHUD.showAdded(to: self.currentContext, animated: true)
            loader.mode = MBProgressHUDMode.indeterminate
            loader.label.text = message
            loader.show(animated: true)
        }
    }
    
    func networkErrorDialog(){
        
        DispatchQueue.main.async {
            MBProgressHUD.hide(for: self.currentContext, animated: true)
            let loader = MBProgressHUD.showAdded(to: self.currentContext, animated: true)
            loader.mode = MBProgressHUDMode.text
            loader.label.text = NETWORK_UNAVAILABLE.localized
            loader.hide(animated: true, afterDelay: 3)
        }
    }
    
    func showErrorDialog(notification:NSNotification){
        
        let message = notification.userInfo![ERROR_NOTIFICATION_MESSAGE_KEY] as! String
        
        DispatchQueue.main.async {
            MBProgressHUD.hide(for: self.currentContext, animated: true)
            let loader = MBProgressHUD.showAdded(to: self.currentContext, animated: true)
            loader.mode = MBProgressHUDMode.text
            loader.label.text = message
            loader.hide(animated: true, afterDelay: 3)
        }
    }
    
    func hideHUD(){
        DispatchQueue.main.async {
            MBProgressHUD.hide(for: self.currentContext, animated: true)
        }
    }
}

//
//  ApplicationSettings.swift
//  Movy
//
//  Created by Prateek Grover on 25/09/16.
//  Copyright © 2016 prateekgrover. All rights reserved.
//

import Foundation
import UIKit

class ApplicationSettings{
    
    public static var SCREEN_WIDTH:CGFloat?
    public static var SCREEN_ORIENTATION:UIInterfaceOrientation?
    public static let NO_COLUMNS = 2
    
    internal static func resetScreenSizeConstants(){
        if UIInterfaceOrientationIsPortrait(getScreenOrientation()) {
            SCREEN_WIDTH = UIScreen.main.bounds.size.width
        } else {
            SCREEN_WIDTH = UIScreen.main.bounds.size.height
        }
    }
    
    internal static func getScreenOrientation() -> UIInterfaceOrientation{
        SCREEN_ORIENTATION = UIApplication.shared.statusBarOrientation
        return SCREEN_ORIENTATION!
    }
}

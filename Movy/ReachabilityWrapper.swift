//
//  ReachabilityWrapper.swift
//  Movy
//
//  Created by Prateek Grover on 09/10/16.
//  Copyright © 2016 prateekgrover. All rights reserved.
//

import Foundation
import ReachabilitySwift

class ReachabilityWrapper: NSObject {
    
    static let sharedInstance = ReachabilityWrapper()
    
    var isOnline = false
    private var reachability: Reachability
    
    override init() {
        
        self.reachability = Reachability()!
        
        super.init()
        start()
    }
    
    
    private func start(){
        
        self.reachability.whenReachable = { reachability in
            self.isOnline = true
        }
        
        self.reachability.whenUnreachable = { reachability in
            self.isOnline = false
        }
    }
    
    func isReachable() -> Bool{
        
        self.isOnline =  self.reachability.isReachable
        return self.isOnline
    }
}

//
//  PPViewControllerMediator.swift
//  PrePostApp
//
//  Created by aram on 2016. 6. 15..
//  Copyright © 2016년 artcow. All rights reserved.
//

import UIKit

class PPViewControllerMediator: NSObject {

    static var _instance: PPViewControllerMediator!
    static func sharedInstance() -> PPViewControllerMediator {
        if _instance == nil {
            _instance = PPViewControllerMediator()
        }
        return _instance
    }
    
    var currentAppearanceViewController: IPPAppearanceViewController?
    
    // MARK: - find viewcontroller
    
    func isAddScheduleViewcontroller() -> (Bool, PPScheduleEditViewController?) {
        if let viewcontoller = currentAppearanceViewController as? PPScheduleEditViewController {
            if let _ = viewcontoller.controlSource as? PPScheduleCreatorController {
                return (true, viewcontoller)
            }
        }
        return (false, nil)
    }
    
    func forceUpdateViewController() -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        return storyboard.instantiateViewControllerWithIdentifier("ForceUpdateViewController")
    }
    
    func rootViewController() -> UIViewController {
        return (UIApplication.sharedApplication().delegate!.window!! as UIWindow).rootViewController!
    }
}


protocol IPPAppearanceViewController {
    
    func clear()
}
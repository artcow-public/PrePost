//
//  PPAnalyticsSender.swift
//  PrePostApp
//
//  Created by aram on 2016. 6. 21..
//  Copyright © 2016년 artcow. All rights reserved.
//

import UIKit

class PPAnalyticsSender: NSObject {
    
    static func sendName(name: String) {
        #if RELEASE
            let tracker = GAI.sharedInstance().defaultTracker
            tracker.set(kGAIScreenName, value: name) // "메인화면 런칭"
            tracker.set(kGAIAppVersion, value: PPUserDefaults.sharedInstance().currentVersion())
            
            tracker.send(GAIDictionaryBuilder.createScreenView().build() as [NSObject: AnyObject])
        #endif
    }

}

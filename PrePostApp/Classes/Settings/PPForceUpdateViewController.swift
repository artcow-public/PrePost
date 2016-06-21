//
//  PPForceUpdateViewController.swift
//  PrePostApp
//
//  Created by aram on 2016. 5. 24..
//  Copyright © 2016년 artcow. All rights reserved.
//

import UIKit

class PPForceUpdateViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let alertView = UIAlertController(title: "알림", message: "앱을 계속 해서 사용하시기 위해서는 업데이트가 필요합니다.", preferredStyle: .Alert)
        let action = UIAlertAction(title: "업데이트", style: .Default, handler:{ (action) in
            self.goToAppstoreAction(action)
        })
        alertView.addAction(action)
        self.presentViewController(alertView, animated: true, completion: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        PPAnalyticsSender.sendName("강제업데이트 화면")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func goToAppstoreAction(sender: AnyObject) {
        PPAnalyticsSender.sendName("앱스토어 연결 시도")
        UIApplication.sharedApplication().openURL(NSURL(string: "https://itunes.apple.com/us/app/app-name/id1126220578?mt=8")!) // ls=1&
    }
}

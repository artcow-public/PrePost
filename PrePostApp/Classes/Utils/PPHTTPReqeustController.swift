//
//  PPHTTPReqeustController.swift
//  PrePostApp
//
//  Created by aram on 2016. 6. 17..
//  Copyright © 2016년 artcow. All rights reserved.
//

import UIKit
import SystemConfiguration

class PPHTTPReqeustController: NSObject {
    
    private static var lastCheckDate: NSDate = NSDate()
    static func enabledReqeust() -> Bool {
        // 오랜 시간이 지체되었는지 확인
        if PPUserDefaults.sharedInstance().isNetworkConnectedLongTimaAgo() {
            PPAnalyticsSender.sendName("오랜 네트워크 미사용")
            let alertView = UIAlertController(title: "알림", message: "앱 사용에 필요한 일부 정보를 서버로 부터 가져옵니다.\n원활한 사용을 위해 네트워크를 켜주세요.", preferredStyle: .Alert)
            alertView.addAction(UIAlertAction(title: "확인", style: .Default, handler: {(action) in
                UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
            }))
            PPViewControllerMediator.sharedInstance().rootViewController().presentViewController(alertView, animated: true, completion: nil)
            return false
        }
        
        return lastCheckDate.earlierDate(NSDate()) == lastCheckDate
    }
    
    // MARK: - http methods
    
    func hasNewDataReqeust(complete: ((PPDTONewData?) -> Void)?) {
        // 네트워크를 사용가능한지 확인
        if isEnabledNetwork() == false {
            complete?(nil)
            return
        }
        let url = NSURL(string: "http://prepost.woobi.co.kr/Webservice/isThereNewData.php?os=i")!
        let session = NSURLSession.sharedSession()
        let request = NSMutableURLRequest(URL:  url)
        request.HTTPMethod = "GET"
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringCacheData
    
        let task = session.dataTaskWithRequest(request) { (let data, let response, let error) in
            guard let _:NSData = data, let _:NSURLResponse = response  where error == nil else {
                complete?(nil)
                return
            }
            
            // 최소 1시간은 업데이트를 검사 하지 않기 위해서 마지막 리퀘스트를 한 시점을 기록해둔다.
            PPHTTPReqeustController.lastCheckDate = NSDate(timeIntervalSinceReferenceDate: NSDate().timeIntervalSince1970 + 60 * 60)
            
            if let json = self.dataToJSONObject(data!) {
                complete?(PPDTONewData(json: json))
                PPUserDefaults.sharedInstance().refereshLastDate()
            } else {
                complete?(nil)
            }
        }
        task.resume()
    }
    
    // 법정 공휴일
    func getHDate(complete: ((PPDTOHoliDayContainer?) -> Void)?) {
        getDate("h", complete: complete)
    }
    
    // 대체 휴일
    func getIDate(complete: ((PPDTOHoliDayContainer?) -> Void)?) {
        getDate("i", complete: complete)
    }
    
    private func getDate(type: String, complete: ((PPDTOHoliDayContainer?) -> Void)?) {
        if ScheduleDatabaseManager.sharedInstance().hasSchedule() {
            if let years = ScheduleDatabaseManager.sharedInstance().allYears() {
                let params = "[" + years.joinWithSeparator(", ") + "]"
                let strURL = "http://prepost.woobi.co.kr/Webservice/fetchHolidays.php?type="+type+"&targetYears=" + params
                holidayReqeust(strURL, complete: complete)
                return
            }
        }
        complete?(nil)
        
    }
    
    private func holidayReqeust(url: String, complete: ((PPDTOHoliDayContainer?) -> Void)?) {
        let url = NSURL(string: url)!
        let session = NSURLSession.sharedSession()
        let request = NSMutableURLRequest(URL:  url)
        request.HTTPMethod = "GET"
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringCacheData
        
        let task = session.dataTaskWithRequest(request) { (let data, let response, let error) in
            guard let _:NSData = data, let _:NSURLResponse = response  where error == nil else {
                print("error = \(data)")
                complete?(nil)
                return
            }
            
            if let json = self.dataToJSONObject(data!) {
                complete?(PPDTOHoliDayContainer(json: json))
            } else {
                complete?(nil)
            }
        }
        task.resume()
    }
    
    
    // MARK: - data convert
    
    private func dataToJSONObject(data: NSData) -> NSDictionary? {
        do {
            let dict = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            if let _ = dict.objectForKey("isComplete") as? String {
                return dict as? NSDictionary
            }
        } catch _ {}
        return nil
    }
    
    // MARK: - network state 
    
    private func isEnabledNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(&zeroAddress, {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
        }) else {
            return false
        }
        
        var flags : SCNetworkReachabilityFlags = []
        
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        
        let isReachable = flags.contains(.Reachable)
        let needsConnection = flags.contains(.ConnectionRequired)
        return (isReachable && !needsConnection)
    }
}

// MARK: - data to object

class PPDTOObject: NSObject {
    let isComplete: Int!
    init(json: NSDictionary) {
        isComplete = Int(json.objectForKey("isComplete") as! String)
    }
}

class PPDTONewData: PPDTOObject {
    
    var forceUpdateVersion: String?
    var hDate: String?
    var iDate: String?
    
    override init(json: NSDictionary) {
        super.init(json: json)

        if isComplete == 1 {
            forceUpdateVersion = json.objectForKey("forceVersion") as? String
            hDate = json.objectForKey("hDate") as? String // 법정 공휴일
            iDate = json.objectForKey("iDate") as? String // 대체 휴일
        }
    }
}

class PPDTOHoliday: NSObject, IPPHolidayCompare {
    var day: Int!
    var month: Int!
    var year: Int!
    var name: String!
    var type: String!
    
    var formattedDate: String { get { return String(format: "%04li-%02li-%02li", year, month, day) } }
    
    init(data: NSDictionary) {
        
        day = Int(data.objectForKey("day") as! String)
        month = Int(data.objectForKey("month") as! String)
        year = Int(data.objectForKey("year") as! String)
        name = data.objectForKey("name") as! String
        type = data.objectForKey("type") as! String
    }
}

class PPDTOHoliDayContainer: PPDTOObject {
    
    var dates: [PPDTOHoliday] = []
    var type: String!
    
    override init(json: NSDictionary) {
        super.init(json: json)
        let dateArray = json.objectForKey("dates") as! NSArray
        for date in dateArray {
            if let dict = date as? NSDictionary {
                let holiday = PPDTOHoliday(data: dict)
                dates.append(holiday)
                type = holiday.type
            }
        }
    }
}

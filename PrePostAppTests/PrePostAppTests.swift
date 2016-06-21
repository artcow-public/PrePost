//
//  PrePostAppTests.swift
//  PrePostAppTests
//
//  Created by aram on 2016. 4. 19..
//  Copyright © 2016년 artcow. All rights reserved.
//

import XCTest

@testable import PrePostApp

class PrePostAppTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
//    func defaultCreatorSetting() -> PPScheduleCreatorController {
//        
//        let creator = PPScheduleCreatorController()
//        creator.creator = D_ScheduleCreator()
//        creator.addModel(D_ScheduleDataModel(), forKey: .Title)
//        creator.addModel(D_ScheduleDataModel(), forKey: .Date)
//        creator.addModel(D_ScheduleDataModel(), forKey: .Money)
//        creator.addModel(D_ScheduleDataModel(), forKey: .Rate)
//        creator.addModel(D_ScheduleDataModel(), forKey: .Type)
//        
//        return creator
//    }
//    
//    func setDefault_1_11(creator: PPScheduleCreatorController) {
//        
//        creator.setModelValue("정기", forKey: .Title)
//        creator.setModelValue(PPDateConverter.stringToDate("2016-04-10"), forKey: .Date)
//        creator.setModelValue(100000, forKey: .Money)
//        creator.setModelValue(1.4, forKey: .Rate)
//        creator.setModelValue(ScheduleType.Schedule_1_11.hashValue, forKey: .Type)
//    }
//    
//    func setDefault_6_1_5(creator: PPScheduleCreatorController) {
//        creator.setModelValue("정기", forKey: .Title)
//        creator.setModelValue(PPDateConverter.stringToDate("2016-04-10"), forKey: .Date)
//        creator.setModelValue(100000, forKey: .Money)
//        creator.setModelValue(1.4, forKey: .Rate)
//        creator.setModelValue(ScheduleType.Schedule_6_1_5.hashValue, forKey: .Type)
//    }
//    
//    func test_create_schedule() {
//    
//        let creator = defaultCreatorSetting()
//        XCTAssertEqual(creator.canCreate, false)
//        
//        setDefault_1_11(creator)
//        XCTAssertEqual(creator.canCreate, true)
//        
//        let schedule = creator.createSchedule()
//        
//        XCTAssertNotNil(schedule)
//        XCTAssertEqual(schedule.totalPaymentCount, 2)
//        XCTAssertEqual(schedule.payDateOfIndex(0), "2016-04-10")
//        XCTAssertEqual(schedule.payForIndex(0), 100000)
//        XCTAssertEqual(schedule.payDateOfIndex(1), "2016-10-10")
//        XCTAssertEqual(schedule.payForIndex(1), 1100000)
//        XCTAssertEqual(schedule.simpleInterest, 10400) // 이자 단리
//        XCTAssertEqual(schedule.compoundInterest, 10451) // 이자 복리
//        XCTAssertEqual(schedule.simplePrincipalAndInterest, 1210400) // 원리금 단리
//        XCTAssertEqual(schedule.compoundPrincipalAndInterest, 1210451) // 원리금 복리
//        XCTAssertEqual(schedule.expirationDate, "2017-04-10") // 만기일
//        XCTAssertEqual(schedule.totalDelayedDay, 0) // 총 (선납)지연일수
//        XCTAssertEqual(schedule.expirationDelay, 0) // 만기 지연일수
//        XCTAssertEqual(schedule.delayedExpirationDay, "2017-04-10") // 지연된 만기일자
//        
//    }
//    
//    func test_detail_1_11() {
//        let creator = defaultCreatorSetting()
//        setDefault_1_11(creator)
//        
//        let schedule = creator.createSchedule()
//        
//        XCTAssertEqual(schedule.totalPaymentCount, 2)
//        
//        // 1회차
//        var turn = schedule.containerForIndex(0)
//        var instalment: IPPInstalment? = turn.instalmentForIndex(0)
//
//        XCTAssertEqual(instalment!.delayedDate, 0)
//        XCTAssertEqual(instalment!.turn, 1)
//        XCTAssertEqual(instalment!.payment, 100000)
//        XCTAssertEqual(instalment!.dueDate, "2016-04-10")
//        XCTAssertEqual(instalment!.paymentDate, "2016-04-10")
//        instalment = turn.instalmentForIndex(1)
//        XCTAssertNil(instalment)
//        
//        // 2회차
//        turn = schedule.containerForIndex(1)
//        instalment = turn.instalmentForIndex(0)
//        XCTAssertEqual(instalment!.delayedDate, 153)
//        XCTAssertEqual(instalment!.turn, 2)
//        XCTAssertEqual(instalment!.payment, 1100000)
//        XCTAssertEqual(instalment!.dueDate, "2016-05-10")
//        XCTAssertEqual(instalment!.paymentDate, "2016-10-10")
//        
//        instalment = turn.instalmentForIndex(1)
//        XCTAssertEqual(instalment!.delayedDate, 122)
//        XCTAssertEqual(instalment!.turn, 3)
//        XCTAssertEqual(instalment!.payment, 0)
//        XCTAssertEqual(instalment!.dueDate, "2016-06-10")
//        XCTAssertEqual(instalment!.paymentDate, "2016-10-10")
//        
//        instalment = turn.instalmentForIndex(2)
//        XCTAssertEqual(instalment!.delayedDate, 92)
//        XCTAssertEqual(instalment!.turn, 4)
//        XCTAssertEqual(instalment!.payment, 0)
//        XCTAssertEqual(instalment!.dueDate, "2016-07-10")
//        XCTAssertEqual(instalment!.paymentDate, "2016-10-10")
//        
//        instalment = turn.instalmentForIndex(3)
//        XCTAssertEqual(instalment!.delayedDate, 61)
//        XCTAssertEqual(instalment!.turn, 5)
//        XCTAssertEqual(instalment!.payment, 0)
//        XCTAssertEqual(instalment!.dueDate, "2016-08-10")
//        XCTAssertEqual(instalment!.paymentDate, "2016-10-10")
//        
//        instalment = turn.instalmentForIndex(4)
//        XCTAssertEqual(instalment!.delayedDate, 30)
//        XCTAssertEqual(instalment!.turn, 6)
//        XCTAssertEqual(instalment!.payment, 0)
//        XCTAssertEqual(instalment!.dueDate, "2016-09-10")
//        XCTAssertEqual(instalment!.paymentDate, "2016-10-10")
//        
//        instalment = turn.instalmentForIndex(5)
//        XCTAssertEqual(instalment!.delayedDate, 0)
//        XCTAssertEqual(instalment!.turn, 7)
//        XCTAssertEqual(instalment!.payment, 0)
//        XCTAssertEqual(instalment!.dueDate, "2016-10-10")
//        XCTAssertEqual(instalment!.paymentDate, "2016-10-10")
//        
//        instalment = turn.instalmentForIndex(6)
//        XCTAssertEqual(instalment!.delayedDate, -31)
//        XCTAssertEqual(instalment!.turn, 8)
//        XCTAssertEqual(instalment!.payment, 0)
//        XCTAssertEqual(instalment!.dueDate, "2016-11-10")
//        XCTAssertEqual(instalment!.paymentDate, "2016-10-10")
//        
//        instalment = turn.instalmentForIndex(7)
//        XCTAssertEqual(instalment!.delayedDate, -61)
//        XCTAssertEqual(instalment!.turn, 9)
//        XCTAssertEqual(instalment!.payment, 0)
//        XCTAssertEqual(instalment!.dueDate, "2016-12-10")
//        XCTAssertEqual(instalment!.paymentDate, "2016-10-10")
//        
//        instalment = turn.instalmentForIndex(8)
//        XCTAssertEqual(instalment!.delayedDate, -92)
//        XCTAssertEqual(instalment!.turn, 10)
//        XCTAssertEqual(instalment!.payment, 0)
//        XCTAssertEqual(instalment!.dueDate, "2017-01-10")
//        XCTAssertEqual(instalment!.paymentDate, "2016-10-10")
//        
//        instalment = turn.instalmentForIndex(9)
//        XCTAssertEqual(instalment!.delayedDate, -123)
//        XCTAssertEqual(instalment!.turn, 11)
//        XCTAssertEqual(instalment!.payment, 0)
//        XCTAssertEqual(instalment!.dueDate, "2017-02-10")
//        XCTAssertEqual(instalment!.paymentDate, "2016-10-10")
//        
//        instalment = turn.instalmentForIndex(10)
//        XCTAssertEqual(instalment!.delayedDate, -151)
//        XCTAssertEqual(instalment!.turn, 12)
//        XCTAssertEqual(instalment!.payment, 0)
//        XCTAssertEqual(instalment!.dueDate, "2017-03-10")
//        XCTAssertEqual(instalment!.paymentDate, "2016-10-10")
//        
//        instalment = turn.instalmentForIndex(11)
//        XCTAssertNil(instalment)
//        
//    }
//    
//    func test_detail_6_1_5() {
//        
//    }
    
//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measureBlock {
//            // Put the code you want to measure the time of here.
//        }
//    }
    
}

//
//  ICKDate.swift
//  Ichika
//
//  Created by Grass Plainson on 2021/3/15.
//

import Foundation

public class ICKDate: NSObject {

    static var today: ICKDate = ICKDate.init()
    
    public var dateFormatterString: String = "yyyy-MM-dd"
    
    private var date: Date!
    private var dateFormatter: DateFormatter = DateFormatter.init()
    private var calendar: ICKCalendar = ICKCalendar.current
    
    public var day: Int {
        return self.calendar.day(date: self)
    }
    
    public var month: Int {
        return self.calendar.month(date: self)
    }
    
    public var week: Int {
        return self.calendar.week(date: self)
    }
    
    public var mark: String?
    
    override init() {
        super.init()
        self.date = Date.init()
        self.dateFormatter.dateFormat = self.dateFormatterString
    }
    
    convenience init(date: Date) {
        self.init()
        self.date = date
    }
    
    convenience init(date: Date, dateFormatterString: String) {
        self.init(date: date)
        self.dateFormatterString = dateFormatterString
    }
    
    convenience init(date: Date, dateFormatterString: String, calendar: ICKCalendar) {
        self.init(date: date, dateFormatterString: dateFormatterString)
        self.calendar = calendar
    }
}

extension ICKDate {
    
    public func toDate() -> Date {
        return self.date
    }
    
    public func toString() -> String {
        return self.dateFormatter.string(from: self.date)
    }
}

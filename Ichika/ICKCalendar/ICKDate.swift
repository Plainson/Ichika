//
//  ICKDate.swift
//  Ichika
//
//  Created by Grass Plainson on 2021/3/15.
//

import Foundation

struct ICKDate {
    
    static var today: ICKDate = ICKDate.init()
    
    public var dateFormatterString: String = "yyyy-MM-dd"
    
    private var date: Date!
    private var dateFormatter: DateFormatter = DateFormatter.init()
    private var calendar: ICKCalendar = ICKCalendar.current
    
    init() {
        self.date = Date.init()
        self.dateFormatter.dateFormat = self.dateFormatterString
    }
    
    init(date: Date) {
        self.init()
        self.date = date
    }
    
    init(date: Date, dateFormatterString: String) {
        self.init(date: date)
        self.dateFormatterString = dateFormatterString
    }
    
    init(date: Date, dateFormatterString: String, calendar: ICKCalendar) {
        self.init(date: date, dateFormatterString: dateFormatterString)
        self.calendar = calendar
    }
    
    public func week() -> Int {
        
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

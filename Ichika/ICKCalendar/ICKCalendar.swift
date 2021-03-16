//
//  ICKCalendar.swift
//  Ichika
//
//  Created by Grass Plainson on 2021/3/15.
//

import Foundation

struct ICKCalendar {
    
    static var current: ICKCalendar = ICKCalendar.init()
    
    private var calendar: Calendar = Calendar.current
    
    init() {
        self.calendar = Calendar.current
    }
    
    init(calendar: Calendar) {
        self.calendar = calendar
    }
    
    public func week() -> Int {
        
    }
}

extension ICKCalendar {
    
    // MARK: - 获取给定时间的月份的第一天。
    
    public func getFirstDateOfMonth(date: ICKDate) -> ICKDate {
        let dateComponents: DateComponents = self.calendar.dateComponents([.year, .month], from: date.toDate())
        let firstDateOfMonth: ICKDate = ICKDate.init(date: self.calendar.date(from: dateComponents)!)
        return firstDateOfMonth
    }
    
    // MARK: - 获取给定时间月份的最后一天。
    
    public func getLastDateOfMonth(date: ICKDate) -> ICKDate {
        var dateComponents: DateComponents = DateComponents.init()
        dateComponents.month = 1
        dateComponents.second = -1
        let lastDateOfMonth: ICKDate = ICKDate.init(date: self.calendar.date(byAdding: dateComponents, to: self.getFirstDateOfMonth(date: date).toDate())!)
        return lastDateOfMonth
    }
}

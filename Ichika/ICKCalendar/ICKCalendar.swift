//
//  ICKCalendar.swift
//  Ichika
//
//  Created by Grass Plainson on 2021/3/15.
//

import Foundation

public struct ICKCalendar {
    
    static var current: ICKCalendar = ICKCalendar.init()
    
    private var calendar: Calendar = Calendar.current
    
    init() {
        self.calendar = Calendar.current
    }
    
    init(calendar: Calendar) {
        self.calendar = calendar
    }
    
    public func day(date: ICKDate) -> Int {
        var dateComponents: DateComponents = DateComponents.init()
        dateComponents = self.calendar.dateComponents([.day], from: date.toDate())
        return dateComponents.day!
    }
    
    public func month(date: ICKDate) -> Int {
        var dateComponents: DateComponents = DateComponents.init()
        dateComponents = self.calendar.dateComponents([.month], from: date.toDate())
        return dateComponents.month!
    }
    
    // Week 的范围是 1~7，其中 1 代表星期天，2 代表星期一。
    public func week(date: ICKDate) -> Int {
        var dateComponents: DateComponents = DateComponents.init()
        dateComponents = self.calendar.dateComponents([.weekday], from: date.toDate())
        return dateComponents.weekday!
    }
    
    public func date(byAdding: Calendar.Component, value: Int, to: ICKDate) -> ICKDate {
        let date: Date = self.calendar.date(byAdding: byAdding, value: value, to: to.toDate())!
        return ICKDate.init(date: date)
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

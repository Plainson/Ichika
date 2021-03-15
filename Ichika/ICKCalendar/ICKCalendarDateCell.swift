//
//  ICKCalendarDateCell.swift
//  Ichika
//
//  Created by Grass Plainson on 2021/3/8.
//

import Foundation
import UIKit

class ICKCalendarDateCell: UICollectionViewCell {
    var date: Date!
    var fillWithLastAndNextMonthDay: Bool = true  // 当月日期多余的位置是否填充上个月和下个月的日期，默认填充。
    var dateCellTinColor: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor.label
        } else {
            return UIColor.black
        }
    }
    var otherDateCellColor: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor.lightGray
        } else {
            return UIColor.gray
        }
    }
    
    private var currentDateArray: Array<String> = Array<String>.init(repeating: "", count: 49)
    
    private var dateView: UIView!
    
    // MARK: - Init。
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 获取当月的第一天和最后一天。
    
    private func getFirstDateOfMonth(date: Date) -> (date: Date, str: String) {
        let calendar: Calendar = Calendar.current
        let dateComponents: DateComponents = calendar.dateComponents([.year, .month], from: date)
        let firstDateOfMonth: Date = calendar.date(from: dateComponents)!
        let dateFormatter: DateFormatter = DateFormatter.init()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let firstDateOfMonthString: String = dateFormatter.string(from: firstDateOfMonth)
        return (firstDateOfMonth, firstDateOfMonthString)
    }
    
    private func getLastDateOfMonth(date: Date) -> (date: Date, str: String) {
        let calendar: Calendar = Calendar.current
        var dateComponents: DateComponents = DateComponents.init()
        dateComponents.month = 1
        dateComponents.second = -1
        let lastFateOfMonth: Date = calendar.date(byAdding: dateComponents, to: getFirstDateOfMonth(date: date).date)!
        let dateFormatter: DateFormatter = DateFormatter.init()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let lastDateOfMonthString: String = dateFormatter.string(from: lastFateOfMonth)
        return (lastFateOfMonth, lastDateOfMonthString)
    }
    
    // MARK: - 更新某月的日期数据，让该月的每一天各归其位。
    
    private func update() {
        let calendar: Calendar = Calendar.current
        let firstDateOfMonth: Date = self.getFirstDateOfMonth(date: self.date).date
        let lastDateOfMonthString: String = self.getLastDateOfMonth(date: self.date).str
        var firstDayOfMonthDateComponents: DateComponents = DateComponents.init()
        firstDayOfMonthDateComponents = calendar.dateComponents([.weekday], from: firstDateOfMonth as Date)
        
        // - 如果需要填充上个月和下个月的日期，需要提前计算好上个月的最后一天以避免在下面的循环中重复计算。
        
        var lastDayOfLastMonth: String = ""  // 上个月的最后一天。
        if self.fillWithLastAndNextMonthDay {
            let day: Date = calendar.date(byAdding: .day, value: -1, to: firstDateOfMonth)!
            let dateFormatter: DateFormatter = DateFormatter.init()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            lastDayOfLastMonth = String(dateFormatter.string(from: day).suffix(2))
        }
        
        var dayNum: Int = 1
        var nextDayNum: Int = 1
        let lastDayOfLastMonthNum: Int = Int(lastDayOfLastMonth)!
        var retainDays: Int = self.transformWeekday(day: firstDayOfMonthDateComponents.weekday!)  // 准备填入的上个月的总天数。
        for index in 7..<49 {  // 数组固定 49 个元素，前 7 个元素被星期日～星期六的字符串占据。
            if dayNum > Int(lastDateOfMonthString.suffix(2))! {
                self.currentDateArray[index] = self.fillWithLastAndNextMonthDay == false ? "" : String(nextDayNum)
                nextDayNum += 1
            } else if index - 7 < 6 && index - 7 < self.transformWeekday(day: firstDayOfMonthDateComponents.weekday!) {
                let day: Int = lastDayOfLastMonthNum - retainDays + 1
                retainDays -= 1
                self.currentDateArray[index] = self.fillWithLastAndNextMonthDay == false ? "" : String(day)
            } else {
                self.currentDateArray[index] = String(dayNum)
                dayNum += 1
            }
        }
    }
    
    // MARK: - 转化星期计数。
    
    private func transformWeekday(day: Int) -> Int {
        // 正常情况下，使用系统默认的 api，weeday 的范围是 1~7，
        // 其中 1 代表星期天，2 代表星期一。
        // 为了直观，该方法将星期天设置为 0。
        return day - 1
    }
    
    // MARK: - 刷新数据，填入数据。
    
    func refreshDateView() {
        self.update()

        self.dateView?.removeFromSuperview()
        self.dateView = UIView.init()
        self.dateView.frame = CGRect.init(x: 0, y: 0, width: self.contentView.frame.width, height: self.contentView.frame.height)
        self.contentView.addSubview(self.dateView)
        for i in 0...48 {
            let dateButton: ICKCalendarDateButton = ICKCalendarDateButton.init()
            switch i {
            case 0:
                dateButton.date = "日"
            case 1:
                dateButton.date = "一"
            case 2:
                dateButton.date = "二"
            case 3:
                dateButton.date = "三"
            case 4:
                dateButton.date = "四"
            case 5:
                dateButton.date = "五"
            case 6:
                dateButton.date = "六"
            default:
                dateButton.date = self.currentDateArray[i]
            }
            let itemSizeWidth: CGFloat = self.dateView.frame.width / 7
            let itemSizeHeight: CGFloat = itemSizeWidth
            dateButton.frame = CGRect.init(x: CGFloat(i % 7) * itemSizeWidth, y: CGFloat(i / 7) * itemSizeHeight, width: itemSizeWidth, height: itemSizeHeight)
            dateButton.setTitle(dateButton.date, for: .normal)
            
            dateButton.setTitleColor(self.dateCellTinColor, for: .normal)
            self.dateView.addSubview(dateButton)
        }
    }
}

// MARK: - ICKCalendarDateCell.

extension ICKCalendarDateCell {
    
}

// MARK: - ICKCalendarDateButton.

class ICKCalendarDateButton: UIButton {
    var date: String!
}

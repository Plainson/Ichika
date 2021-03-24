//
//  ICKCalendarDateCell.swift
//  Ichika
//
//  Created by Grass Plainson on 2021/3/8.
//

import Foundation
import UIKit

class ICKCalendarDateCell: UICollectionViewCell {
    var date: ICKDate!
    var calendarView: ICKCalendarView!
    var fillWithLastAndNextMonthDay: Bool = true  // 当月日期多余的位置是否填充上个月和下个月的日期，默认填充。
    
    var dateCellTinColor: UIColor? {
        willSet {
            self.setDateButtonColor(color: newValue)
        }
    }
    var otherDateCellColor: UIColor? {
        willSet {
            self.setOtherDateButtonColor(color: newValue)
        }
    }
    var weekDateCellColor: UIColor? {
        willSet {
            self.setWeekButtonColor(color: newValue)
        }
    }
    
    var handleTapDate: ((_ view: ICKCalendarView, _ cell: ICKCalendarDateButton) -> Void)?
    var viewForCellHandle: ((_ view: ICKCalendarView, _ date: ICKDate) -> UIView?)?
    
    private var currentDateArray: Array<ICKDate?> = Array<ICKDate?>.init(repeating: ICKDate.init(), count: 49)
    
    private var dateView: UIView!
    
    // MARK: - Init。
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 更新某月的日期数据，让该月的每一天各归其位。
    
    private func update() {
        let calendar: ICKCalendar = ICKCalendar.current
        let firstDateOfMonth: ICKDate = calendar.getFirstDateOfMonth(date: self.date)
        
        // - 如果需要填充上个月和下个月的日期，需要提前计算好上个月的最后一天以避免在下面的循环中重复计算。
        
        var lastDateOfLastMonth: ICKDate = ICKDate.init()  // 上个月的最后一天。
        if self.fillWithLastAndNextMonthDay {
            let day: ICKDate = calendar.date(byAdding: .day, value: -1, to: firstDateOfMonth)
            lastDateOfLastMonth = day
        }
        
        var dayNum: Int = 1
        var retainDays: Int = self.transformWeekday(day: firstDateOfMonth.week)  // 准备填入的上个月的总天数。
        for index in 7..<49 {  // 数组固定 49 个元素，前 7 个元素被星期日～星期六的字符串占据。
            if dayNum > lastDateOfLastMonth.day {
                let date: ICKDate = ICKCalendar.current.date(byAdding: .day, value: dayNum - 1, to: firstDateOfMonth)
                date.mark = String(date.day)
                self.currentDateArray[index] = date
                dayNum += 1
            } else if index - 7 < 6 && index - 7 < self.transformWeekday(day: firstDateOfMonth.week) {
                let date: ICKDate = ICKCalendar.current.date(byAdding: .day, value: -retainDays, to: firstDateOfMonth)
                date.mark = String(date.day)
                self.currentDateArray[index] = date
                retainDays -= 1
            } else {
                let date: ICKDate = ICKCalendar.current.date(byAdding: .day, value: dayNum - 1, to: firstDateOfMonth)
                date.mark = String(date.day)
                self.currentDateArray[index] = date
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
            dateButton.isSelected = false
            switch i {
            case 0:
                self.currentDateArray[i] = nil
                dateButton.setTitle("日", for: .normal)
                dateButton.tag = 100
            case 1:
                self.currentDateArray[i] = nil
                dateButton.setTitle("一", for: .normal)
                dateButton.tag = 101
            case 2:
                self.currentDateArray[i] = nil
                dateButton.setTitle("二", for: .normal)
                dateButton.tag = 102
            case 3:
                self.currentDateArray[i] = nil
                dateButton.setTitle("三", for: .normal)
                dateButton.tag = 103
            case 4:
                self.currentDateArray[i] = nil
                dateButton.setTitle("四", for: .normal)
                dateButton.tag = 104
            case 5:
                self.currentDateArray[i] = nil
                dateButton.setTitle("五", for: .normal)
                dateButton.tag = 105
            case 6:
                self.currentDateArray[i] = nil
                dateButton.setTitle("六", for: .normal)
                dateButton.tag = 106
            default:
                dateButton.date = self.currentDateArray[i]
                dateButton.tag = 100 + i
            }
            let itemSizeWidth: CGFloat = self.dateView.frame.width / 7
            let itemSizeHeight: CGFloat = itemSizeWidth
            dateButton.frame = CGRect.init(x: CGFloat(i % 7) * itemSizeWidth, y: CGFloat(i / 7) * itemSizeHeight, width: itemSizeWidth, height: itemSizeHeight)
            if dateButton.date != nil {
                dateButton.setTitle(dateButton.date!.mark, for: .normal)
                if dateButton.date!.month != self.date!.month {
                    dateButton.setTitleColor(self.otherDateCellColor, for: .normal)
                } else {
                    dateButton.setTitleColor(self.dateCellTinColor, for: .normal)
                }
                dateButton.addTarget(self, action: #selector(self.handleTapDateButton(sender:)), for: .touchUpInside)
                if let handle = self.viewForCellHandle {
                    dateButton.customView(view: handle(self.calendarView, dateButton.date!))
                }
            } else {
                dateButton.setTitleColor(self.weekDateCellColor, for: .normal)
            }
            
            self.dateView.addSubview(dateButton)
        }
    }
    
    // MARK: - 更改 UI 样式。
    
    private func setWeekButtonColor(color: UIColor?) {
        for i in 0...6 {
            let button: ICKCalendarDateButton = self.dateView.viewWithTag(100 + i) as! ICKCalendarDateButton
            button.setTitleColor(color, for: .normal)
        }
    }
    
    private func setDateButtonColor(color: UIColor?) {
        for i in 7...48 {
            let button: ICKCalendarDateButton = self.dateView.viewWithTag(100 + i) as! ICKCalendarDateButton
            if button.date!.month == self.date.month {
                button.setTitleColor(color, for: .normal)
            }
        }
    }
    
    private func setOtherDateButtonColor(color: UIColor?) {
        for i in 7...48 {
            let button: ICKCalendarDateButton = self.dateView.viewWithTag(100 + i) as! ICKCalendarDateButton
            if button.date!.month != self.date.month {
                button.setTitleColor(color, for: .normal)
            }
        }
    }
}

// MARK: - ICKCalendarDateCell.

extension ICKCalendarDateCell {
    
    @objc func handleTapDateButton(sender: ICKCalendarDateButton) {
        sender.isSelected = !sender.isSelected
        self.handleTapDate?(self.calendarView, sender)
    }
}

// MARK: - ICKCalendarDateButton.

public class ICKCalendarDateButton: UIButton {
    
    public var date: ICKDate?
    
    fileprivate func customView(view: UIView?) {
        if view == nil {
            return
        }
        let backgroundView: UIView = UIView.init()
        backgroundView.frame = CGRect.init(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        self.addSubview(backgroundView)
        view!.frame = CGRect.init(x: 0, y: 0, width: backgroundView.frame.width, height: backgroundView.frame.height)
        backgroundView.addSubview(view!)
    }
}

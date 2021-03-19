//
//  ICKCalendarViewDelegate.swift
//  Ichika
//
//  Created by Grass Plainson on 2021/3/8.
//

import Foundation
import UIKit

@objc public protocol ICKCalendarViewDelegate {
    
    @objc optional func calendarView(itemSizeForCalendarView: ICKCalendarView) -> CGSize
    
    @objc optional func calendarView(calendarView: ICKCalendarView, didSelectCellAt date: ICKDate)
    
    @objc optional func calendarView(calendarView: ICKCalendarView, viewForCellAt date: ICKDate) -> UIView
}

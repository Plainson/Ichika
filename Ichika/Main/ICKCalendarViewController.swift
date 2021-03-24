//
//  ICKCalendarViewController.swift
//  Ichika
//
//  Created by Grass Plainson on 2021/3/8.
//

import Foundation
import UIKit
import Masonry

class ICKCalendarViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let calendarView: ICKCalendarView = ICKCalendarView.init(frame: CGRect.init(x: 0, y: 64, width: self.view.frame.width, height: self.view.frame.height))
        calendarView.delegate = self
        calendarView.allowControlView = true
        calendarView.weekDateCellColor = UIColor.green
        calendarView.allowManualScroll = false
        self.view.addSubview(calendarView)
    }
}

extension ICKCalendarViewController: ICKCalendarViewDelegate {
    
    func calendarView(calendarView: ICKCalendarView, didSelectCell cell: ICKCalendarDateButton) {
        if let date = cell.date {
            print(date.toString())
        }
    }
}

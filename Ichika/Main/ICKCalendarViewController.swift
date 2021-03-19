//
//  ICKCalendarViewController.swift
//  Ichika
//
//  Created by Grass Plainson on 2021/3/8.
//

import Foundation
import UIKit
import Masonry

@available(iOS 11.0, *)
class ICKCalendarViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let calendarView: ICKCalendarView = ICKCalendarView.init(frame: CGRect.init(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        calendarView.delegate = self
        calendarView.weekDateCellColor = UIColor.green
        self.view.addSubview(calendarView)
        calendarView.mas_makeConstraints { (view) in
            view!.left.equalTo()(self.view.mas_safeAreaLayoutGuideLeft)?.offset()
            view!.right.equalTo()(self.view.mas_safeAreaLayoutGuideRight)?.offset()
            view!.top.equalTo()(self.view.mas_safeAreaLayoutGuideTop)?.offset()
            view!.bottom.equalTo()(self.view.mas_safeAreaLayoutGuideBottom)?.offset()
        }
    }
}

@available(iOS 11.0, *)
extension ICKCalendarViewController: ICKCalendarViewDelegate {
    
    func calendarView(calendarView: ICKCalendarView, didSelectCellAt date: ICKDate) {
        print(date.toString())
    }
}

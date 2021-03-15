//
//  ICKCalendarView.swift
//  Ichika
//
//  Created by Grass Plainson on 2021/3/8.
//

import Foundation
import UIKit

public class ICKCalendarView: UIView {
    
    // MARK: - Property.
    
    private var dateDisplayLabel: UILabel!
    private var mainCollectionView: UICollectionView!
    
    public var delegate: ICKCalendarViewDelegate?
    
    public var fillWithLastAndNextMonthDay: Bool = true  // 当月日期多余的位置是否填充上个月和下个月的日期，默认填充。
    public var dateCellTinColor: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor.label
        } else {
            return UIColor.black
        }
    }
    public var otherDateCellColor: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor.lightGray
        } else {
            return UIColor.gray
        }
    }
    
    private var _itemSize: CGSize = CGSize.init()
    private var _calendarViewHeight: CGFloat = 0
    private var monthCount: Int = 10
    
    // MARK: - Init.
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialize()
    }
    
    public init() {
        fatalError("you must initialize calendar view with init(frame:) initializer.")
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialize()
    }
    
    private func initialize() {
        self.dateDisplayLabel = UILabel.init()
        let dateDisplayLabelHeight: CGFloat = 40
        self.dateDisplayLabel.frame = CGRect.init(x: 0, y: 0, width: self.frame.width, height: dateDisplayLabelHeight)
        self.dateDisplayLabel.text = "---"
        self.dateDisplayLabel.textAlignment = .center
        self.addSubview(self.dateDisplayLabel)
        
        self._calendarViewHeight = self.frame.height - dateDisplayLabelHeight
        let mainCollectionViewFlowLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout.init()
        mainCollectionViewFlowLayout.itemSize = CGSize.init(width: self.frame.width, height: self._calendarViewHeight)
        mainCollectionViewFlowLayout.scrollDirection = .horizontal
        mainCollectionViewFlowLayout.minimumLineSpacing = 0
        mainCollectionViewFlowLayout.minimumInteritemSpacing = 0
        self.mainCollectionView = UICollectionView.init(frame: CGRect.init(), collectionViewLayout: mainCollectionViewFlowLayout)
        self.mainCollectionView.frame = CGRect.init(x: 0, y: dateDisplayLabelHeight, width: self.frame.width, height: self._calendarViewHeight)
        self.mainCollectionView.backgroundColor = self.backgroundColor
        self.mainCollectionView.isScrollEnabled = true
        self.mainCollectionView.allowsMultipleSelection = false
        self.mainCollectionView.register(ICKCalendarDateCell.self, forCellWithReuseIdentifier: "DateCell")
        self.mainCollectionView.delegate = self
        self.mainCollectionView.dataSource = self
        self.mainCollectionView.isPagingEnabled = true
        self.addSubview(self.mainCollectionView)
        self.mainCollectionView.scrollToItem(at: IndexPath.init(row: self.monthCount - 1, section: 0), at: .centeredHorizontally, animated: false)
    }
    
    private func calculationDate(addOrSub: String, value: Int) -> Date {
        let date: Date = Date.init()
        let calendar: Calendar = Calendar.current
        if addOrSub == "add" {
            return calendar.date(byAdding: .month, value: value, to: date)!
        } else {
            return calendar.date(byAdding: .month, value: -value, to: date)!
        }
    }
}

// MARK: - UICollectionViewDelegate.

extension ICKCalendarView: UICollectionViewDelegate {
    
}

// MARK: - UICollectionViewDataSource.

extension ICKCalendarView: UICollectionViewDataSource {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.monthCount
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ICKCalendarDateCell = collectionView.dequeueReusableCell(withReuseIdentifier: "DateCell", for: indexPath) as! ICKCalendarDateCell
        cell.date = self.calculationDate(addOrSub: "sub", value: self.monthCount - 1 - indexPath.row)
        cell.refreshDateView()
        return cell
    }
}

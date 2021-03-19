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
    
    private var _dateCellTinColor: UIColor?
    public var dateCellTinColor: UIColor {
        get {
            if #available(iOS 13.0, *), self._dateCellTinColor == nil {
                self._dateCellTinColor = UIColor.lightGray
            } else if self._dateCellTinColor == nil {
                self._dateCellTinColor = UIColor.gray
            }
            return self._dateCellTinColor!
        }
        set {
            self._dateCellTinColor = newValue
        }
    }
    
    private var _otherDateCellColor: UIColor?
    public var otherDateCellColor: UIColor {
        get {
            if #available(iOS 13.0, *), self._otherDateCellColor == nil {
                self._otherDateCellColor = UIColor.lightGray
            } else if self._otherDateCellColor == nil {
                self._otherDateCellColor = UIColor.gray
            }
            return self._otherDateCellColor!
        }
        set {
            self._otherDateCellColor = newValue
        }
    }
    
    private var _weekDateCellColor: UIColor?
    public var weekDateCellColor: UIColor {
        get {
            if #available(iOS 13.0, *), self._weekDateCellColor == nil {
                self._weekDateCellColor = UIColor.lightGray
            } else if self._weekDateCellColor == nil {
                self._weekDateCellColor = UIColor.gray
            }
            return self._weekDateCellColor!
        }
        set {
            self._weekDateCellColor = newValue
        }
    }
    
    private var _itemSize: CGSize = CGSize.init()
    private var _calendarViewHeight: CGFloat = 0
    private var _lastContentOffSet: CGPoint?
    
    private var monthCount: Int = 10
    private var dateArray: Array<Int> = Array<Int>.init()
    
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
        self.mainCollectionView.allowsSelection = true
        self.mainCollectionView.allowsMultipleSelection = false
        self.mainCollectionView.register(ICKCalendarDateCell.self, forCellWithReuseIdentifier: "DateCell")
        self.mainCollectionView.delegate = self
        self.mainCollectionView.dataSource = self
        self.mainCollectionView.isPagingEnabled = true
        self.addSubview(self.mainCollectionView)
        self.mainCollectionView.scrollToItem(at: IndexPath.init(row: self.monthCount - 1, section: 0), at: .centeredHorizontally, animated: false)
        self._lastContentOffSet = CGPoint.init(x: (self.monthCount - 1) * Int(self.frame.width), y: 0)
        self.dateArray = [-9, -8, -7, -6, -5, -4, -3, -2, -1, 0]
    }
    
    private func calculationDate(value: Int) -> ICKDate {
        let date: ICKDate = ICKCalendar.current.date(byAdding: .month, value: value, to: ICKDate.init())
        return date
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
        let date: ICKDate = self.calculationDate(value: self.dateArray[indexPath.row])
        cell.date = date
        cell.calendarView = self
        cell.dateCellTinColor = self.dateCellTinColor
        cell.otherDateCellColor = self.otherDateCellColor
        cell.weekDateCellColor = self.weekDateCellColor
        
        // - delegate.
        
        if let delegate = self.delegate {
            cell.handleTapDate = { (view, date) in
                delegate.calendarView?(calendarView: view, didSelectCellAt: date)
            }
            
            cell.viewForCellHandle = { (view, date) in
                let view: UIView? = delegate.calendarView?(calendarView: view, viewForCellAt: date)
                return view
            }
        }
        
        cell.refreshDateView()
        return cell
    }
}

extension ICKCalendarView {
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x == 0 {
            for _ in 0..<10 {
                self.monthCount += 1
                self.dateArray.insert(self.dateArray.first! - 1, at: 0)
                self.mainCollectionView.insertItems(at: [IndexPath.init(row: 0, section: 0)])
            }
            self.mainCollectionView.scrollToItem(at: IndexPath.init(row: 10, section: 0), at: .centeredHorizontally, animated: false)
        } else if scrollView.contentOffset.x == CGFloat((self.monthCount - 1)) * self.frame.width {
            for _ in 0..<10 {
                self.monthCount += 1
                self.dateArray.insert(self.dateArray.last! + 1, at: self.dateArray.count)
                self.mainCollectionView.insertItems(at: [IndexPath.init(row: self.monthCount - 1, section: 0)])
            }
            self.mainCollectionView.scrollToItem(at: IndexPath.init(row: self.monthCount - 10, section: 0), at: .centeredHorizontally, animated: false)
        }
    }
}

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
    
    private var controlView: UIView?
    private var dateDisplayLabel: UILabel?
    private var leftArrow: UIButton?
    private var rightArrow: UIButton?
    private var mainCollectionView: UICollectionView!
    
    public weak var delegate: ICKCalendarViewDelegate?
    
    /// 当月日期多余的位置是否填充上个月和下个月的日期，默认填充。
    public var fillWithLastAndNextMonthDay: Bool = true
    
    private var _allowManualScroll: Bool = true
    /// 是否允许手动滑动日历，如果为 `false`，则日历不允许左右滑动，只能通过 `controlView` 来控制日历月份切换。
    public var allowManualScroll: Bool {
        get {
            return self._allowManualScroll
        }
        set {
            self._allowManualScroll = newValue
            self.mainCollectionView.isScrollEnabled = newValue
        }
    }
    
    private var _allowControlView: Bool = true
    /// 是否打开日历切换控制视图，默认打开。
    public var allowControlView: Bool {
        get {
            return self._allowControlView
        }
        set {
            self._allowControlView = newValue
            self.layoutIfNeeded()
        }
    }
    
    private var _dateCellTinColor: UIColor?
    /// 日历当中日期的 cell 字体颜色。
    public var dateCellTinColor: UIColor {
        get {
            if #available(iOS 13.0, *), self._dateCellTinColor == nil {
                self._dateCellTinColor = UIColor.label
            } else if self._dateCellTinColor == nil {
                self._dateCellTinColor = UIColor.black
            }
            return self._dateCellTinColor!
        }
        set {
            self._dateCellTinColor = newValue
            self.getCurrentMonthCell()?.dateCellTinColor = newValue
        }
    }
    
    private var _otherDateCellColor: UIColor?
    /// 若 `fillWithLastAndNextMonthDay` 为 `true`，那么改值表示不属于当月的日期的 cell 的字体颜色。
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
            self.getCurrentMonthCell()?.otherDateCellColor = newValue
        }
    }
    
    private var _weekDateCellColor: UIColor?
    /// 表示日历当中星期X的字体颜色。
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
            self.getCurrentMonthCell()?.weekDateCellColor = newValue
        }
    }
    
    private var _controlTitleColor: UIColor?
    public var controlTitleColor: UIColor {
        get {
            if #available(iOS 13.0, *), self._controlTitleColor == nil {
                self._controlTitleColor = UIColor.label
            } else if self._controlTitleColor == nil {
                self._controlTitleColor = UIColor.gray
            }
            return self._controlTitleColor!
        }
        set {
            self._controlTitleColor = newValue
            self.dateDisplayLabel?.textColor = newValue
        }
    }
    
    private var _controlArrowColor: UIColor?
    public var controlArrowColor: UIColor {
        get {
            if #available(iOS 13.0, *), self._controlArrowColor == nil {
                self._controlArrowColor = UIColor.label
            } else if self._controlArrowColor == nil {
                self._controlArrowColor = UIColor.gray
            }
            return self._controlArrowColor!
        }
        set {
            self._controlArrowColor = newValue
            self.leftArrow?.setTitleColor(newValue, for: .normal)
            self.rightArrow?.setTitleColor(newValue, for: .normal)
        }
    }
        
    private var _monthCount: Int?
    private var monthCount: Int {
        get {
            if self.allowManualScroll == false {
                self._monthCount = 1
            } else {
                if self._monthCount == nil {
                    self._monthCount = 10
                }
            }
            return self._monthCount!
        }
        set {
            self._monthCount = newValue
        }
    }
    
    public var currentDate: ICKDate = ICKDate.init()
    
    private var dateArray: Array<Int> = [-9, -8, -7, -6, -5, -4, -3, -2, -1, 0]
    
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
        self.controlView?.removeFromSuperview()
        self.mainCollectionView?.removeFromSuperview()
        
        var mainCollectionViewFrame: CGRect = CGRect.init()
        if self.allowControlView {
            let controlViewWidth: CGFloat = 220
            let controlViewHeight: CGFloat = 64
            let calendarLabelSize: CGSize = CGSize.init(width: 120, height: 50)
            let arrowSize: CGSize = CGSize.init(width: 50, height: 50)
            let y: CGFloat = (controlViewHeight - arrowSize.height) / 2
            
            self.controlView = UIView.init()
            self.controlView!.frame = CGRect.init(x: 0, y: 0, width: self.frame.width, height: controlViewHeight)
            self.addSubview(self.controlView!)
            
            self.leftArrow = UIButton.init()
            self.leftArrow!.frame = CGRect.init(x: (self.frame.width - controlViewWidth) / 2, y: y, width: arrowSize.width, height: arrowSize.height)
            self.leftArrow!.setTitle("<", for: .normal)
            self.leftArrow!.setTitleColor(self.controlArrowColor, for: .normal)
            self.leftArrow!.addTarget(self, action: #selector(self.leftArrowHandle(sender:)), for: .touchUpInside)
            self.controlView!.addSubview(self.leftArrow!)
            
            self.dateDisplayLabel = UILabel.init()
            let dateDisplayLabelX: CGFloat = self.leftArrow!.frame.origin.x + arrowSize.width
            self.dateDisplayLabel!.frame = CGRect.init(x: dateDisplayLabelX, y: y, width: calendarLabelSize.width, height: calendarLabelSize.height)
            self.dateDisplayLabel!.text = String(ICKDate.init().toString().prefix(7))
            self.dateDisplayLabel!.textColor = self.controlTitleColor
            self.dateDisplayLabel!.textAlignment = .center
            self.controlView!.addSubview(self.dateDisplayLabel!)
            
            self.rightArrow = UIButton.init()
            let rightArrowX: CGFloat = self.dateDisplayLabel!.frame.origin.x + self.dateDisplayLabel!.frame.width
            self.rightArrow!.frame = CGRect.init(x: rightArrowX, y: y, width: arrowSize.width, height: arrowSize.height)
            self.rightArrow!.setTitle(">", for: .normal)
            self.rightArrow!.setTitleColor(self.controlArrowColor, for: .normal)
            self.rightArrow!.addTarget(self, action: #selector(self.rightArrowHandle(sender:)), for: .touchUpInside)
            self.controlView!.addSubview(self.rightArrow!)
            
            mainCollectionViewFrame = CGRect.init(x: 0, y: controlViewHeight, width: self.frame.width, height: self.frame.height - controlViewHeight)
        } else {
            mainCollectionViewFrame = CGRect.init(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        }
        
        let mainCollectionViewFlowLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout.init()
        mainCollectionViewFlowLayout.itemSize = CGSize.init(width: self.frame.width, height: mainCollectionViewFrame.height)
        mainCollectionViewFlowLayout.scrollDirection = .horizontal
        mainCollectionViewFlowLayout.minimumLineSpacing = 0
        mainCollectionViewFlowLayout.minimumInteritemSpacing = 0
        self.mainCollectionView = UICollectionView.init(frame: CGRect.init(), collectionViewLayout: mainCollectionViewFlowLayout)
        self.mainCollectionView.frame = mainCollectionViewFrame
        self.mainCollectionView.backgroundColor = self.backgroundColor
        self.mainCollectionView.isScrollEnabled = false
        self.mainCollectionView.allowsSelection = true
        self.mainCollectionView.allowsMultipleSelection = false
        self.mainCollectionView.register(ICKCalendarDateCell.self, forCellWithReuseIdentifier: "DateCell")
        self.mainCollectionView.delegate = self
        self.mainCollectionView.dataSource = self
        self.mainCollectionView.isPagingEnabled = true
        self.addSubview(self.mainCollectionView)
        self.mainCollectionView.scrollToItem(at: IndexPath.init(row: self.monthCount - 1, section: 0), at: .centeredHorizontally, animated: false)
    }
    
    // MARK: - Layout subviews.
    
    public override func layoutSubviews() {
        self.initialize()
    }
    
    // MARK: - Calculation date.
    
    private func calculationDate(value: Int) -> ICKDate {
        let date: ICKDate = ICKCalendar.current.date(byAdding: .month, value: value, to: ICKDate.init())
        return date
    }
    
    // MARK: - Left arrow and right arrow handle.
    
    @objc private func leftArrowHandle(sender: UIButton) {
        self.jumpToDate(date: ICKCalendar.current.date(byAdding: .month, value: -1, to: self.currentDate))
    }
    
    @objc private func rightArrowHandle(sender: UIButton) {
        self.jumpToDate(date: ICKCalendar.current.date(byAdding: .month, value: 1, to: self.currentDate))
    }
    
    // MARK: - 根据当前日期获取 collectionView 当中该月的 cell。
    
    private func getCurrentMonthCell() -> ICKCalendarDateCell? {
        let cells: Array<ICKCalendarDateCell> = self.mainCollectionView.visibleCells as! Array<ICKCalendarDateCell>
        for cell in cells {
            if cell.date.toString() == self.currentDate.toString() {
                return cell
            }
        }
        return nil
    }
    
    // MARK: - Public.
    
    /// 可以使用这个方法让日历显示任何指定的日期的月份。
    public func jumpToDate(date: ICKDate) {
        self.currentDate = date
        self.dateDisplayLabel?.text = String(self.currentDate.toString().prefix(7))
        self.mainCollectionView.reloadData()
    }
    
    /// 可以使用这个方法让日历显示任何指定的月份，传入的参数必须为 `yyyy-MM` 形式，如 `2021-04`。
    public func jumpToMonth(month: String) {
        let dateString: String = "\(month)-01"
        let dateFormatter: DateFormatter = DateFormatter.init()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date: Date? = dateFormatter.date(from: dateString)
        var ickDate: ICKDate? = nil
        if date != nil {
            ickDate = ICKDate.init(date: date!)
            self.jumpToDate(date: ickDate!)
        }
    }
    
    /// 获取当前视图显示的月份。
    public func currentMonth() -> ICKDate {
        let cell: ICKCalendarDateCell = self.mainCollectionView.visibleCells[0] as! ICKCalendarDateCell
        self.currentDate = cell.date
        return cell.date
    }
    
    /// 刷新数据数据。
    public func reloadData() {
        self.mainCollectionView.reloadData()
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
        var cell: ICKCalendarDateCell = ICKCalendarDateCell.init()
        if self.allowManualScroll {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DateCell", for: indexPath) as! ICKCalendarDateCell
            let date: ICKDate = self.calculationDate(value: self.dateArray[indexPath.row])
            cell.date = date
            
        } else {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DateCell", for: indexPath) as! ICKCalendarDateCell
            cell.date = self.currentDate
        }
        
        cell.calendarView = self

        // - delegate.
        
        if let delegate = self.delegate {
            cell.handleTapDate = { (view, button) in
                delegate.calendarView?(calendarView: view, didSelectCell: button)
            }
            
            cell.viewForCellHandle = { (view, size, date) in
                let view: UIView? = delegate.calendarView?(calendarView: view, cellItemSize: size, viewForCellAt: date)
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

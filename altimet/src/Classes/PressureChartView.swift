//
//  PressureChartView.swift
//  altimet
//
//  Created by David Högborg on 05/10/14.
//  Copyright (c) 2014 Kampanjbolaget. All rights reserved.
//

import Foundation
import UIKit

class PressureChartView : UIView, JBLineChartViewDelegate, JBLineChartViewDataSource {
    
    
    lazy var chartView: JBChartView = JBLineChartView()
    lazy var chartScaleTop: UILabel = UILabel()
    lazy var chartScaleBottom: UILabel = UILabel()
    
    var timedData: [Float] = []
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        self.setupChart()
        self.setupLabels()
        
    }
    
    override func awakeFromNib() {
        
        self.setupChart()
        self.setupLabels()
        
    }
    
    required init(coder aDecoder: NSCoder) {
        return super.init(coder: aDecoder)
    }
    
    func setupChart() {
        
        self.chartView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.chartView.delegate = self
        self.chartView.dataSource = self
        
        self.addSubview(self.chartView)
        
        let hConst = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[chart]-0-|",
            options: nil, metrics: nil, views: ["chart": self.chartView])
        
        let vConst = NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[chart]-0-|",
            options: nil, metrics: nil, views: ["chart": self.chartView])
        
        self.addConstraints(hConst)
        self.addConstraints(vConst)
        
        
    }
    
    func setupLabels() {

        
        self.chartScaleTop.text = "----.--- hPa"
        self.chartScaleTop.font = UIFont.systemFontOfSize(13)
        self.chartScaleTop.textColor = UIColor(white: 0.9, alpha: 1)
        self.chartScaleTop.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        self.chartScaleBottom.text = "----.--- hPa"
        self.chartScaleBottom.font = UIFont.systemFontOfSize(13)
        self.chartScaleBottom.textColor = UIColor(white: 0.9, alpha: 1)
        self.chartScaleBottom.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        self.addSubview(self.chartScaleTop)
        self.addSubview(self.chartScaleBottom)
        
        
        let views = [
            "top": self.chartScaleTop,
            "bottom": self.chartScaleBottom
        ]
        let c1 = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[top(100)]",
            options: nil, metrics: nil, views: views)
        let c2 = NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[top(21)]",
            options: nil, metrics: nil, views: views)
        let c3 = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[bottom(100)]",
            options: nil, metrics: nil, views: views)
        let c4 = NSLayoutConstraint.constraintsWithVisualFormat("V:[bottom(21)]-0-|",
            options: nil, metrics: nil, views: views)
        
        self.addConstraints(c1 + c2 + c3 + c4)
        
    }
    
    func addTimedDataPoint(#pressure: Float) {
        
        if (self.timedData.count == 0) {
            
            for i in 0...59 {
                self.timedData.append(pressure)
            }
            
        }
        
        self.timedData.append(pressure)
        
        if self.timedData.count > 59 {
            self.timedData.removeAtIndex(0)
        }
        
        self.chartView.reloadData()
        self.updateChartScale()
        
    }
    
    func updateChartScale() {
        
        var max = Float(Int.min)
        var min = Float(Int.max)
        
        for dataPoint in self.timedData {
            
            if dataPoint > max {
                max = dataPoint
            }
            
            if dataPoint < min {
                min = dataPoint
            }

        }

        self.chartScaleTop.text = NSString(format: "%0.3f hPa", max * 10)
        self.chartScaleBottom.text = NSString(format: "%0.3f hPa", min * 10)
        
    }
    
    func numberOfLinesInLineChartView(lineChartView: JBLineChartView!) -> UInt {
        return 1
    }
    
    func lineChartView(lineChartView: JBLineChartView!, numberOfVerticalValuesAtLineIndex lineIndex: UInt) -> UInt {
        return UInt(self.timedData.count)
    }
    
    func lineChartView(lineChartView: JBLineChartView!, verticalValueForHorizontalIndex horizontalIndex: UInt, atLineIndex lineIndex: UInt) -> CGFloat {
        
        let index = Int(horizontalIndex)
        return CGFloat(self.timedData[index])
            
    }
    
    func lineChartView(lineChartView: JBLineChartView!, smoothLineAtLineIndex lineIndex: UInt) -> Bool {
        return true
    }
    
    func lineChartView(lineChartView: JBLineChartView!, widthForLineAtLineIndex lineIndex: UInt) -> CGFloat {
        return 2.0
    }
    
    func lineChartView(lineChartView: JBLineChartView!, colorForLineAtLineIndex lineIndex: UInt) -> UIColor! {
        return UIColor(white: 1, alpha: 1)
    }
    
    func lineChartView(lineChartView: JBLineChartView!, selectionColorForLineAtLineIndex lineIndex: UInt) -> UIColor! {
        return UIColor.clearColor()
    }
}
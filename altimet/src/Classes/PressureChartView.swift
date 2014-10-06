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
    var timedData: [Float] = []
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        self.setupChart()
        
    }
    
    override func awakeFromNib() {
        
        self.setupChart()
        
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
    
    func addTimedDataPoint(#pressure: Float) {
        
        self.timedData.append(pressure)
        
        if self.timedData.count > 60 {
            self.timedData.removeAtIndex(0)
        }
        
        self.chartView.reloadData()
        
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
    
    
}
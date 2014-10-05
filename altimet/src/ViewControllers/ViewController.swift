//
//  ViewController.swift
//  altimet
//
//  Created by David Högborg on 04/10/14.
//  Copyright (c) 2014 Kampanjbolaget. All rights reserved.
//

import UIKit
import CoreMotion

class ViewController: UIViewController {

    lazy var altimeter :CMAltimeter = CMAltimeter()
    
    @IBOutlet weak var meterLabel: UILabel!
    @IBOutlet weak var pressureLabel: UILabel!
    
    
    @IBOutlet weak var maxPressureLabel: UILabel!
    @IBOutlet weak var minPressureLabel: UILabel!
    @IBOutlet weak var maxAltLabel: UILabel!
    @IBOutlet weak var minAltLabel: UILabel!
    @IBOutlet weak var signalView: UIView!
    @IBOutlet weak var chartView: PressureChartView!
    
    // altitude offset in meter, enables reset feature
    var offset: Float = 0.0
    
    // relative altitude in meter
    var altitude: Float = 0.0 {
        didSet { updateViewWithNewAlt(meter: self.altitude) }
    }
    
    // current pressure in kPa
    var pressure :Float = 0.0 {
        didSet { updateViewWithNewPressure(kPa: self.pressure)}
    }
    
    // min / max values are inited with maximum values, so they dont get capped to 0 if below 0
    var maxAlt: Float = Float(Int.min)
    var minAlt: Float = Float(Int.max)
    
    var maxPressure: Float = Float(Int.min)
    var minPressure: Float = Float(Int.max)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.reloadStatsFromBackground()
        
        if CMAltimeter.isRelativeAltitudeAvailable() {
            
            self.startAltimeterUpdate()
        }
        
        NSNotificationCenter.defaultCenter().addObserverForName("APP_ENTER_BACKGROUND",
            object: nil, queue: NSOperationQueue.currentQueue(),
            { (n:NSNotification!) -> Void in
            
                self.saveStatsForBackground()
                
        })
        
    }
   
    // constraints that will be affected by a rotation change
    @IBOutlet weak private var chartViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak private var chartViewTopConstraint: NSLayoutConstraint!
    
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        
        let ui = toInterfaceOrientation
        
        // 78 or 10
        self.chartViewBottomConstraint.constant = (ui.isLandscape) ? 10 : 78
        
        // 389 or 10
        self.chartViewTopConstraint.constant = (ui.isLandscape) ? 10 : 389
        
        
        
        UIView.animateWithDuration(duration, animations: { () -> Void in
            
            self.view.setNeedsLayout()
          
            }, { (finished:Bool) -> Void in
                
                self.chartView.chartView.reloadData()
        })
        
    }
    
    
    func startAltimeterUpdate() {
        
        self.altimeter.startRelativeAltitudeUpdatesToQueue(NSOperationQueue.currentQueue(),
            withHandler: { (altdata:CMAltitudeData!, error:NSError!) -> Void in
            
                self.handleNewMeasure(pressureData: altdata)
        })
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func handleNewMeasure(#pressureData: CMAltitudeData) {
        
        self.pressure = pressureData.pressure.floatValue
        self.altitude = pressureData.relativeAltitude.floatValue

        self.chartView.addTimedDataPoint(pressure: self.pressure)
        
    }

    @IBAction func tappedReset(sender: UIButton) {
        
        self.offset = self.altitude
        
        self.maxAlt = Float(Int.min)
        self.minAlt = Float(Int.max)
        
        self.maxPressure = Float(Int.min)
        self.minPressure = Float(Int.max)
        
    }
    
    func updateViewWithNewAlt(#meter :Float) {
        
        let newAlt = meter - self.offset
        self.meterLabel.text = NSString(format: "%0.3f m", newAlt)
        
        if newAlt > self.maxAlt {
            self.maxAlt = newAlt
            self.flashSignalWith(color: UIColor.greenColor())
        }
        
        if newAlt < self.minAlt {
            self.minAlt = newAlt
            self.flashSignalWith(color: UIColor.redColor())
        }
        
        self.maxAltLabel.text = NSString(format: "%0.3f m", self.maxAlt)
        self.minAltLabel.text = NSString(format: "%0.3f m", self.minAlt)

    }
    
    func updateViewWithNewPressure(#kPa :Float) {
        
        let hPa = kPa * 10
        
        self.pressureLabel.text = NSString(format: "%0.3f hPa", hPa)
        
        if hPa > self.maxPressure {
            self.maxPressure = hPa
        }
        
        if hPa < self.minPressure {
            self.minPressure = hPa
        }
        
        self.maxPressureLabel.text = NSString(format: "%0.3f hPa", self.maxPressure)
        self.minPressureLabel.text = NSString(format: "%0.3f hPa", self.minPressure)
        
    }
    
    func flashSignalWith(#color: UIColor) {
        
        self.signalView.backgroundColor = color
        self.signalView.alpha = 1
        
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            
            self.signalView.alpha = 0
            
        })
    }
    
    func saveStatsForBackground() {
        
        let dict = NSDictionary(dictionary: [
            "pressure": self.pressure,
            "alt": self.altitude,
            "maxPressure": self.maxPressure,
            "minPressure": self.minPressure,
            "maxAlt": self.maxAlt,
            "minAlt": self.minAlt
        ])
        
        
        NSUserDefaults.standardUserDefaults().setObject(dict, forKey: "minMaxStats")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func reloadStatsFromBackground() {
        
        if let dict = NSUserDefaults.standardUserDefaults().objectForKey("minMaxStats") as? NSDictionary {
            
            let sdict = dict as Dictionary<String, Float>
            
            self.altitude = sdict["alt"]!
            self.pressure = sdict["pressure"]!
            
            self.maxPressure = sdict["maxPressure"]!
            self.minPressure = sdict["minPressure"]!
            self.maxAlt = sdict["maxAlt"]!
            self.minAlt = sdict["minAlt"]!
            
            self.updateViewWithNewAlt(meter: self.altitude)
            self.updateViewWithNewPressure(kPa: self.pressure)
        }
        
    }
}


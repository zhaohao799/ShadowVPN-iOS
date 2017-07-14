//
//  TodayViewController.swift
//  TodayWidget
//
//  Created by Joe on 16/1/17.
//  Copyright © 2016年 clowwindy. All rights reserved.
//

import UIKit
import NotificationCenter

let groupBundle = "group.com.HansonStudio.NetShuttle"

class TodayViewController: UIViewController, NCWidgetProviding {
    
    var statusSwitch: UISwitch!
    var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
        
        preferredContentSize = CGSize(width: 0, height: 50)
        configureUI()
        
        statusSwitch.addTarget(self, action: #selector(TodayViewController.statusSwitchValueChanged(_:)), for: .valueChanged)
        // NSNotificationCenter.defaultCenter().addObserver(self, selector: "setStatusSwitchState", name: NSUserDefaultsDidChangeNotification, object: nil)
    }
    
    func configureUI() {
        label = UILabel(frame: CGRect(x: 0, y: 0, width: 150, height: 31))
        setLabelDisplayText(label)
        
        statusSwitch = UISwitch(frame: CGRect(x: 0, y: 0, width: 50, height: 31))
        statusSwitch.isOn = false
        setStatusSwitchState()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        statusSwitch.translatesAutoresizingMaskIntoConstraints = false
        
        let labelConstraintCenterY = NSLayoutConstraint(item: label,
            attribute: .centerY,
            relatedBy: .equal,
            toItem: view,
            attribute: .centerY,
            multiplier: 1,
            constant: 0)
        
        let labelConstraingLeading = NSLayoutConstraint(item: label,
            attribute: .leading,
            relatedBy: .equal,
            toItem: view,
            attribute: .leading,
            multiplier: 1,
            constant: 0)
        
        let statusSwitchConstraintCenterY = NSLayoutConstraint(item: statusSwitch,
            attribute: .centerY,
            relatedBy: .equal,
            toItem: label,
            attribute: .centerY,
            multiplier: 1,
            constant: 0)
        
        let statusSwitchConstraintTailling = NSLayoutConstraint(item: statusSwitch,
            attribute: .trailing,
            relatedBy: .equal,
            toItem: view,
            attribute: .trailing,
            multiplier: 1,
            constant: -20)
        
        let constrants = [labelConstraintCenterY, labelConstraingLeading, statusSwitchConstraintCenterY, statusSwitchConstraintTailling]
        
        view.addSubview(label)
        view.addSubview(statusSwitch)
        view.addConstraints(constrants)

    }
    
    func setLabelDisplayText(_ label: UILabel) {
        label.textColor = UIColor.white
        
        let shared = UserDefaults(suiteName: groupBundle)
        if let text = shared?.value(forKey: "currentVPN") as? String {
            label.text = text
        } else {
            label.text = "missing configurations"
        }
    }
    
    func setStatusSwitchState() {
        let shared = UserDefaults(suiteName: groupBundle)!
        let state = shared.bool(forKey: "vpnState")
        statusSwitch.isOn = state
    }
    
    func statusSwitchValueChanged(_ sender: UISwitch) {
        let urlSchema = "shadowvpn"
        var host: String
        if sender.isOn {
            host = "start"
        } else {
            host = "stop"
        }
        let url = urlSchema + "://" + host
        
        extensionContext?.open(URL(string: url)!, completionHandler: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetMarginInsets(forProposedMarginInsets defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
        let inset = UIEdgeInsets(top: defaultMarginInsets.top, left: defaultMarginInsets.left, bottom: 0, right: defaultMarginInsets.right)
        return inset
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.

        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }
    
}

//
//  ViewController.swift
//  AQI
//
//  Created by Alonso on 2018/4/13.
//  Copyright © 2018 Alonso. All rights reserved.
//

import Cocoa
import Ji

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let jiDoc = Ji(htmlURL: URL(string: "http://222.92.42.178:8083/AQI/Index.aspx")!)
        let spanDate = jiDoc?.xPath("//span[@id='ContentPlaceHolder1_spanDate']")?.first?.content
        print("更新时间:\(spanDate!)")
        let spanAQI = jiDoc?.xPath("//span[@id='ContentPlaceHolder1_spanAQI']")?.first?.content
        print("空气质量指数(AQI):\(spanAQI!)")
        let spanClass = jiDoc?.xPath("//span[@id='ContentPlaceHolder1_spanClass']")?.first?.content
        let spanGrade = jiDoc?.xPath("//span[@id='ContentPlaceHolder1_spanGrade']")?.first?.content
        print("等级:\(spanClass!) \(spanGrade!)")
        let spanHealthEffect = jiDoc?.xPath("//span[@id='ContentPlaceHolder1_spanHealthEffect']")?.first?.content
        print("对健康的影响:\(spanHealthEffect!)")
        let spanTakeStep = jiDoc?.xPath("//span[@id='ContentPlaceHolder1_spanTakeStep']")?.first?.content
        print("建议采取的措施:\(spanTakeStep!)")
        let spanPrimaryPollutant = jiDoc?.xPath("//span[@id='ContentPlaceHolder1_spanPrimaryPollutant']")?.first?.content
        let spanValue = jiDoc?.xPath("//span[@id='ContentPlaceHolder1_spanValue']")?.first?.content
        print("首要污染物:\(spanPrimaryPollutant!) \(spanValue!)")
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}


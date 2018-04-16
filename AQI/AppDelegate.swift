//
//  AppDelegate.swift
//  AQI
//
//  Created by Alonso on 2018/4/16.
//  Copyright © 2018 Alonso. All rights reserved.
//

import Cocoa
import Ji
import Alamofire

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusItem.button?.title = "🌞"
        statusItem.menu = NSMenu()
        self.refreshMenu()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func refreshMenu() {
        Alamofire.request("http://222.92.42.178:8083/AQI/Index.aspx").responseString { response in
            if(response.result.isSuccess){
                self.dealAQIHTML(Str: response.description)
            }else{
                print("AQI Check network")
            }
        }
        
        Alamofire.request("http://www.weather.com.cn/html/weather/101190404.shtml").response { response in
            if let _ = response.response{
                let str = String(data:response.data!, encoding: .utf8)!
                self.dealWEAHTML(Str: str)
            }else{
                print("Weather Check network")
            }
        }
    }

    func dealWEAHTML(Str:String) {
        let jiDoc = Ji(htmlString: Str, encoding: .utf8)
        var showArr :[String] = []
        let spanDate = jiDoc?.xPath("//input[@id='fc_3h_internal_update_time']")?.first!["value"]
        var weather = "weather"
        for i in 0..<7{
            if let date = jiDoc?.xPath("//ul[@class='t clearfix']//li//h1")![i].content, let wea = jiDoc?.xPath("//ul[@class='t clearfix']//li//p[@class='wea']")![i].content , let temStr = jiDoc?.xPath("//ul[@class='t clearfix']//li//p[@class='tem']")![i].content{
                let tem = temStr.trimmingCharacters(in:.whitespacesAndNewlines).replacingOccurrences(of: "℃", with: "°C")
                if i == 0{
                    weather = "\(wea) \(tem)"
                }else{
                    showArr.append("\(date):\(wea):\(tem)")
                }
            }
        }
        let menuItem = NSMenuItem(title: weather, action: nil, keyEquivalent: "")
        self.setFont(Item: menuItem, color:NSColor.green , size: 20)
        let submenu = NSMenu()
        let updateItem = NSMenuItem(title: "更新时间:\(spanDate!)", action: nil, keyEquivalent: "")
        self.setFont(Item: updateItem, color:NSColor.clear , size: 10)
        for showStr in showArr{
            let showStrArr = showStr.components(separatedBy: ":")
            let submenuItem = NSMenuItem(title: "\(showStrArr[0]):", action: nil, keyEquivalent: "")
            self.setFont(Item: submenuItem, color:NSColor.green , size: 16)
            let submenuItem2 = NSMenuItem(title: "\(showStrArr[1]) \(showStrArr[2])", action: nil, keyEquivalent: "")
            self.setFont(Item: submenuItem2, color: NSColor.blue, size: 14)
            submenu.addItem(submenuItem)
            submenu.addItem(submenuItem2)
        }
        submenu.addItem(updateItem)
        menuItem.submenu = submenu
        statusItem.menu?.addItem(menuItem)
        //self.statusItem.menu?.addItem(NSMenuItem.separator())
    }
    
    func dealAQIHTML(Str:String) {
        let jiDoc = Ji(htmlString: Str, encoding: .utf8)
        var showArr :[String] = []
        let spanDate = jiDoc?.xPath("//span[@id='ContentPlaceHolder1_spanDate']")?.first?.content
        let spanAQI = jiDoc?.xPath("//span[@id='ContentPlaceHolder1_spanAQI']")?.first?.content
        let spanClass = jiDoc?.xPath("//span[@id='ContentPlaceHolder1_spanClass']")?.first?.content
        let spanGrade = jiDoc?.xPath("//span[@id='ContentPlaceHolder1_spanGrade']")?.first?.content
        let spanHealthEffect = jiDoc?.xPath("//span[@id='ContentPlaceHolder1_spanHealthEffect']")?.first?.content
        let spanTakeStep = jiDoc?.xPath("//span[@id='ContentPlaceHolder1_spanTakeStep']")?.first?.content
        let spanPrimaryPollutant = jiDoc?.xPath("//span[@id='ContentPlaceHolder1_spanPrimaryPollutant']")?.first?.content
        let spanValue = jiDoc?.xPath("//span[@id='ContentPlaceHolder1_spanValue']")?.first?.content
        showArr.append("更新时间:\(spanDate!)")
        showArr.append("等级:\(spanClass!) \(spanGrade!)")
        showArr.append("首要污染物:\(spanPrimaryPollutant!) \(spanValue!)")
        showArr.append("对健康的影响:\(spanHealthEffect!)")
        showArr.append("建议采取的措施:\(spanTakeStep!)")
        
        statusItem.button?.title = spanAQI!
        let menuItem = NSMenuItem(title: "空气质量指数:\(spanAQI!)", action: nil, keyEquivalent: "")
        var aqicolor = NSColor.white
        if let aqi = Int(spanAQI!){
            if aqi < 50{
                aqicolor = NSColor.green
            }else if aqi < 100{
                aqicolor = NSColor.yellow
            }else if aqi < 150{
                aqicolor = NSColor.orange
            }else if aqi < 200{
                aqicolor = NSColor.red
            }else if aqi < 300{
                aqicolor = NSColor.purple
            }else if aqi >= 300{
                aqicolor = NSColor.brown
            }
        }
        self.setFont(Item: menuItem, color:aqicolor , size: 20)
        let submenu = NSMenu()
        for showStr in showArr{
            let showStrArr = showStr.components(separatedBy: ":")
            let submenuItem = NSMenuItem(title: "\(showStrArr[0]):", action: nil, keyEquivalent: "")
            self.setFont(Item: submenuItem, color:NSColor.green , size: 16)
            let submenuItem2 = NSMenuItem(title: "\(showStrArr[1])", action: nil, keyEquivalent: "")
            self.setFont(Item: submenuItem2, color: NSColor.blue, size: 14)
            submenu.addItem(submenuItem)
            submenu.addItem(submenuItem2)
        }
        menuItem.submenu = submenu
        statusItem.menu?.addItem(menuItem)
        //self.statusItem.menu?.addItem(NSMenuItem.separator())
    }
    
    func setFont(Item:NSMenuItem,color:NSColor,size:Float) {
        let attributes: Dictionary = [
            NSAttributedStringKey.font:NSFont(name: "Menlo", size: CGFloat(size))!,
            NSAttributedStringKey.foregroundColor:color
        ]
        let attributedTitle = NSAttributedString.init(string: Item.title, attributes: attributes)
        Item.attributedTitle = attributedTitle
    }
}


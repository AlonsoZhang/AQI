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
    var timer: Timer?
    var statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    let dateFormatter = DateFormatter()
    var spanAQI = ""
    var weather = ""
    let greenColor = NSColor(calibratedRed: 0.3, green: 0.9, blue: 0, alpha: 0.6)
    let blueColor = NSColor(calibratedRed: 0.1, green: 0.3, blue: 1, alpha: 0.9)
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusItem.button?.title = "☁️"
        statusItem.menu = NSMenu()
        self.refreshMenu()
        dateFormatter.dateFormat = "HH:mm:ss"
        let hourFormatter = DateFormatter()
        hourFormatter.dateFormat = "mm:ss"
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (timer) in
            if hourFormatter.string(from: Date()) == "00:00"{
                self.refreshMenu()
            }
            if self.dateFormatter.string(from: Date()) == "16:00:00"{
                self.judgehealth()
            }
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    func refreshMenu() {
        Alamofire.request("http://222.92.42.178:8083/AQI/Index.aspx").responseString { response in
            if(response.result.isSuccess){
                self.statusItem.menu?.removeAllItems()
                self.dealAQIHTML(Str: response.description)
                Alamofire.request("http://www.weather.com.cn/html/weather/101190404.shtml").response { response in
                    if let _ = response.response{
                        let str = String(data:response.data!, encoding: .utf8)!
                        self.dealWEAHTML(Str: str)
                        let quitItem = NSMenuItem(title: "退出", action: #selector(self.quit), keyEquivalent: "")
                        self.statusItem.menu?.addItem(quitItem)
                    }else{
                        print("Weather Check network")
                    }
                }
            }else{
                print("AQI Check network")
                if self.statusItem.menu?.numberOfItems == 0{
                    let refresh = NSMenuItem(title: "刷新", action: #selector(self.refresh), keyEquivalent: "")
                    self.statusItem.menu?.addItem(refresh)
                    let quitItem = NSMenuItem(title: "退出", action: #selector(self.quit), keyEquivalent: "")
                    self.statusItem.menu?.addItem(quitItem)
                }
            }
        }
    }
    
    @objc func quit() {
        NSApp.terminate(self)
    }

    @objc func refresh() {
        refreshMenu()
    }
    
    func dealWEAHTML(Str:String) {
        let jiDoc = Ji(htmlString: Str, encoding: .utf8)
        var showArr :[String] = []
        let spanDate = jiDoc?.xPath("//input[@id='fc_3h_internal_update_time']")?.first!["value"]
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
        self.setFont(Item: menuItem, color:NSColor(calibratedRed: 0.3, green: 0.9, blue: 0, alpha: 0.8) , size: 20)
        let submenu = NSMenu()
        let updateItem = NSMenuItem(title: "更新时间:\(spanDate!)", action: nil, keyEquivalent: "")
        self.setFont(Item: updateItem, color:NSColor.brown , size: 10)
        for showStr in showArr{
            let showStrArr = showStr.components(separatedBy: ":")
            let submenuItem = NSMenuItem(title: "\(showStrArr[0]):", action: nil, keyEquivalent: "")
            self.setFont(Item: submenuItem, color:greenColor , size: 16)
            let submenuItem2 = NSMenuItem(title: "\(showStrArr[1]) \(showStrArr[2])", action: nil, keyEquivalent: "")
            self.setFont(Item: submenuItem2, color: blueColor, size: 14)
            submenu.addItem(submenuItem)
            submenu.addItem(submenuItem2)
        }
        submenu.addItem(updateItem)
        menuItem.submenu = submenu
        statusItem.menu?.addItem(menuItem)
        self.statusItem.menu?.addItem(NSMenuItem.separator())
    }
    
    func dealAQIHTML(Str:String) {
        let jiDoc = Ji(htmlString: Str, encoding: .utf8)
        var showArr :[String] = []
        let spanDate = jiDoc?.xPath("//span[@id='ContentPlaceHolder1_spanDate']")?.first?.content
        spanAQI = (jiDoc?.xPath("//span[@id='ContentPlaceHolder1_spanAQI']")?.first?.content)!
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
        
        statusItem.button?.title = spanAQI
        let menuItem = NSMenuItem(title: "空气质量指数:\(spanAQI)", action: nil, keyEquivalent: "")
        var aqicolor = NSColor.white
        if let aqi = Int(spanAQI){
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
            self.setFont(Item: submenuItem, color:greenColor , size: 16)
            let submenuItem2 = NSMenuItem(title: "\(showStrArr[1])", action: nil, keyEquivalent: "")
            self.setFont(Item: submenuItem2, color: blueColor, size: 14)
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
    
    func judgehealth(){
        var notititle = ""
        var notiinfo = ""
        if let aqi = Int(spanAQI){
            if aqi > 0 && aqi < 150{
                if weather.contains("雨")||weather.contains("雷"){
                    notititle = "天气不佳，今晚不宜运动"
                }else{
                    notititle = "今晚适宜跑步，加油"
                }
            }else{
                notititle = "污染严重，今晚不宜运动"
            }
            notiinfo = "\(weather) AQI:\(aqi)"
            startLocalNotification(title: notititle, info: notiinfo)
        }
    }
    
    func startLocalNotification(title:String,info:String) {
        let notification = NSUserNotification()
        notification.title = title
        notification.hasActionButton = true
        notification.actionButtonTitle = "Fighting"
        notification.otherButtonTitle = "Give Up"
        notification.informativeText = info
        notification.deliveryDate = Date()
        notification.setValue(NSImage(named: NSImage.Name(rawValue: "kaola")), forKey: "_identityImage")

        // Notification定时显示，最短60s
//        var dateComponents = DateComponents()
//        dateComponents.second = 70
//        notification.deliveryRepeatInterval = dateComponents
        
        NSUserNotificationCenter.default.delegate = self
        NSUserNotificationCenter.default.scheduleNotification(notification)
        
        //删除已显示过的Notification
        //NSUserNotificationCenter.default.removeAllDeliveredNotifications()
        
        //注销后台运行的Notification
//        for notify in NSUserNotificationCenter.default.scheduledNotifications{
//            NSUserNotificationCenter.default.removeScheduledNotification(notify)
//        }
    }
}

extension AppDelegate: NSUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: NSUserNotificationCenter, didDeliver notification: NSUserNotification) {
        print("didDeliver notification \(notification)")
    }
    
    func userNotificationCenter(_ center: NSUserNotificationCenter, didActivate notification: NSUserNotification) {
        //点击之后动作
        print("fighting")
    }
    
    func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
        return true
    }
}

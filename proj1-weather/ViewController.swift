//
//  ViewController.swift
//  proj1-weather
//
//  Created by 小拿 on 15/3/8.
//  Copyright (c) 2015年 Justin. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    let locationManager: CLLocationManager = CLLocationManager()

    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var temperature: UILabel!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loadingMessage: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // 加载背景图
        let background = UIImage(named: "background.png")
        self.view.backgroundColor = UIColor(patternImage: background!)
        
        self.loadingIndicator.startAnimating()
        
        locationManager.delegate = self
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        if (ios8()) {
            locationManager.requestAlwaysAuthorization()
        }
        locationManager.startUpdatingLocation()
    }
    
    func ios8() -> Bool {
        return UIDevice.currentDevice().systemVersion == "8.1"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        var location: CLLocation = locations[locations.count-1] as CLLocation
        println("debug info in locationManager1")
        if (location.horizontalAccuracy > 0) {
            
            // 获取经纬度
            println(location.coordinate.latitude)
            println(location.coordinate.longitude)
            
            // 根据经纬度查询天气接口
            self.updateWeatherInfo(location.coordinate.latitude, longitude: location.coordinate.longitude)
            
            // 关闭地理位置获取
            locationManager.stopUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println("错误信息：\(error)")
        self.loadingMessage.text = "地理位置信息获取失败！-\(error)"
    }
    
    // 封装天气接口调用
    func updateWeatherInfo(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        
        // 获取AFNetworking的实例
        let manager = AFHTTPRequestOperationManager()
        
        // 天气接口URL
        let url = "http://api.openweathermap.org/data/2.5/weather"
        
        // 初始化URL参数
        let params = ["lat": latitude, "lon": longitude, "cnt": 0]
        
        manager.GET(url,
            parameters: params,
            success: { (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) in
                println("JSON: " + responseObject.description!)
                
                //根据天气信息更新UI
                self.updateUISucess(responseObject as NSDictionary!)
            },
            failure: { (operation: AFHTTPRequestOperation!, error: NSError!) in
                println("Error: " + error.localizedDescription)
            }
        )
        
    }
    
    func updateUISucess(jsonResult: NSDictionary!) {
        
        // 关闭进程控件
        self.loadingIndicator.stopAnimating()
        self.loadingIndicator.hidden = true
        self.loadingMessage.text = nil
        
        if let tempResult = jsonResult["main"]?["temp"]? as? Double {
            
            // 设置温度
            var temperature: Double
            if (jsonResult["sys"]?["country"]? as String == "US") {
                temperature = round(((tempResult - 273.15) * 1.8) + 32)
            } else {
                //
                temperature = round(tempResult - 273.15)
            }
            self.temperature.text = "\(temperature)℃"
            self.temperature.font = UIFont.boldSystemFontOfSize(60)
            
            // 设置城市名称
            var name = jsonResult["name"]? as String
            self.location.text = "\(name)"
            self.location.font = UIFont.boldSystemFontOfSize(25)
            
            // 设置图标
            var condition = (jsonResult["weather"]? as NSArray)[0]["id"] as Int
            var sunrise = jsonResult["sys"]?["sunrise"]? as Double
            var sunset = jsonResult["sys"]?["sunset"]? as Double
            
            var nightTime = false
            var now = NSDate().timeIntervalSince1970
            if (now < sunrise || now > sunset) {
                nightTime = true
            }
            
            self.updateWeatherIcon(condition, nightTime: nightTime)
            
        } else {
            //
            self.loadingMessage.text = "天气信息获取成功，但解析失败！"
        }
    }
    
    func updateWeatherIcon(condition: Int, nightTime: Bool) {
        // Thunderstorm
        if (condition < 300) {
            if nightTime {
                self.icon.image = UIImage(named: "tstorm1_night")
            } else {
                self.icon.image = UIImage(named: "tstorm1")
            }
        }
            // Drizzle
        else if (condition < 500) {
            self.icon.image = UIImage(named: "light_rain")
            
        }
            // Rain / Freezing rain / Shower rain
        else if (condition < 600) {
            self.icon.image = UIImage(named: "shower3")
        }
            // Snow
        else if (condition < 700) {
            self.icon.image = UIImage(named: "snow4")
        }
            // Fog / Mist / Haze / etc.
        else if (condition < 771) {
            if nightTime {
                self.icon.image = UIImage(named: "fog_night")
            } else {
                self.icon.image = UIImage(named: "fog")
            }
        }
            // Tornado / Squalls
        else if (condition < 800) {
            self.icon.image = UIImage(named: "tstorm3")
        }
            // Sky is clear
        else if (condition == 800) {
            if (nightTime){
                self.icon.image = UIImage(named: "sunny_night")
            }
            else {
                self.icon.image = UIImage(named: "sunny")
            }
        }
            // few / scattered / broken clouds
        else if (condition < 804) {
            if (nightTime){
                self.icon.image = UIImage(named: "cloudy2_night")
            }
            else{
                self.icon.image = UIImage(named: "cloudy2")
            }
        }
            // overcast clouds
        else if (condition == 804) {
            self.icon.image = UIImage(named: "overcast")
        }
            // Extreme
        else if ((condition >= 900 && condition < 903) || (condition > 904 && condition < 1000)) {
            self.icon.image = UIImage(named: "tstorm3")
        }
            // Cold
        else if (condition == 903) {
            self.icon.image = UIImage(named: "snow5")
        }
            // Hot
        else if (condition == 904) {
            self.icon.image = UIImage(named: "sunny")
        }
            // Weather condition is not available
        else {
            self.icon.image = UIImage(named: "dunno")
        }
    }

}












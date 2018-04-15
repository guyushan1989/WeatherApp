//
//  WeatherViewController.swift
//  WeatherAPP
//
//  Created by Mac for gu on 2018/4/13.
//  Copyright © 2018年 Mac for gu. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class WeatherViewController: UIViewController,CLLocationManagerDelegate,City {
    
    
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var weatherLabel: UILabel!
    @IBOutlet weak var weatherImageView: UIImageView!
    
    let byArea = "https://api.apishop.net/common/weather/get15DaysWeatherByArea"
    let byGPS = "https://api.apishop.net/common/weather/getWeatherByGPS"
    let apiKey = "a3SzIxvef9f690e392f96b7c2cfd042edc73b09281c362e"
    
    //TODO:创建一个CLLocationManager实例
    let locationManager = CLLocationManager()
    //创建一个WeatherDataModel实例
    var weatherDataModel = WeatherDataModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        //TODO:设置locationManager的相关属性
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToSecondView" {
            let changeCityVC = segue.destination as! ChangeCityViewController
            changeCityVC.cityDelegate = self
            
        }
    }
    //TODO:执行City协议的方法
    func city(cityName: String) {
        let parameters: [String:String] = ["apiKey":apiKey,"area":cityName]
        getWeatherData(url: byArea, parameters: parameters)
        print(cityName)
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        //获取用户当前位置
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0 {
            
            //print("longitude = \(location.coordinate.longitude),latitude = \(location.coordinate.latitude)")
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            let parameters: [String:String] = [
                "apiKey":apiKey,
                "need3HourForcast":"0",
                "needAlarm":"0",
                "needHourData":"0",
                "needIndex":"0",
                "needMoreDay":"0",
                "from":"1",
                "lat":"\(latitude)",
                "lng":"\(longitude)"]
            getWeatherData(url:byGPS, parameters:parameters)

        }
    }
    
    //创建获取天气数据的func
    func getWeatherData(url:String, parameters:[String:String]) {
        if url == byGPS {
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON { (response) in
            switch response.result {
            case .success:
                let json = JSON(response.result.value!)
               // print("输出请求成功后返回的信息",json)
                //TODO:调用天气数据更新方法
                self.updateWeatherData(json: json)
                
            case .failure(let error):
                print(error)
                self.weatherLabel.text = "Failed"
            }
            }
            } else {
                Alamofire.request(url, method: .get, parameters: parameters).responseJSON { (response) in
                    switch response.result {
                    case .success:
                        let json = JSON(response.result.value!)
                        // print("输出请求成功后返回的信息",json)
                        //TODO:调用天气数据更新方法
                        self.updateWeatherDataByArea(json: json)
                        
                    case .failure(let error):
                        print(error)
                        self.weatherLabel.text = "Failed"
                }
            }
        }
    }
    //TODO:JSON数据解析
    func updateWeatherData(json:JSON) {
        weatherDataModel.temperature = json["result"]["now"]["temperature"].intValue
        //print(weatherDataModel.temperature)
        weatherDataModel.city = json["result"]["now"]["aqiDetail"]["area"].stringValue
        weatherDataModel.weather = json["result"]["now"]["weather"].stringValue
        weatherDataModel.iconURL = json["result"]["now"]["weather_pic"].stringValue
        //TODO:更新视图数据
        updateWeatherView(temperature: weatherDataModel.temperature, city: weatherDataModel.city, weather: weatherDataModel.weather, weatherIconUrl: weatherDataModel.iconURL)
    }
    //TODO:JSON数据解析
    func updateWeatherDataByArea(json:JSON) {
        weatherDataModel.temperature = json["result"]["dayList"][1]["day_air_temperature"].intValue
        weatherDataModel.city = json["result"]["dayList"][1]["area"].stringValue
        weatherDataModel.weather = json["result"]["dayList"][1]["day_weather"].stringValue
        weatherDataModel.iconURL = json["result"]["dayList"][1]["day_weather_pic"].stringValue
        //print(weatherDataModel.iconURL)
        updateWeatherView(temperature: weatherDataModel.temperature, city: weatherDataModel.city, weather: weatherDataModel.weather, weatherIconUrl: weatherDataModel.iconURL)
    }
    //mark-: 更新视图数据
    func updateWeatherView(temperature:Int, city:String, weather:String, weatherIconUrl:String) {
        cityLabel.text = city
        temperatureLabel.text = "\(temperature)°C"
        weatherLabel.text = weather
        downWeatherImage(url: weatherIconUrl)
}
    //TODO:download weather image
    func downWeatherImage(url:String) {
        Alamofire.request(url, method: .get, parameters: nil).responseData(queue: DispatchQueue.global()) { (responseData) in
            DispatchQueue.main.async {
                guard let imageData = responseData.data else { return }
                self.weatherImageView.image = UIImage(data: imageData)
            }
        }
}

}

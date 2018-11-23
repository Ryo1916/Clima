//
//  ViewController.swift
//  WeatherApp
//
//  Created by Angela Yu on 23/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class WeatherViewController: UIViewController, CLLocationManagerDelegate {
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "3486f122e589efd3e860f3a10775ce47"
    /***Get your own App ID at https://openweathermap.org/appid ****/
    

    //TODO: Declare instance variables here
    // CoreLocationで提供されているCLLocationManager関数を定数にセット
    let locationManager = CLLocationManager()
    let weatherDataModel = WeatherDataModel()

    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //TODO:Set up the location manager here.
        // WeatherViewController(self)がCLLocationManagerDelegateの処理を代理でやりますよ、という意味
        locationManager.delegate = self
        // 天気予報なので、位置情報の正確さは大体数100m程度の精度で問題ない
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        // ユーザに毎回位置情報を利用していいか聞く
        locationManager.requestAlwaysAuthorization()
        // バックグラウンドで位置情報取得を開始する
        locationManager.startUpdatingLocation()
        
        
    }
    
    
    
    //MARK: - Networking
    /***************************************************************/
    
    //Write the getWeatherData method here:
    func getWeatherData(url: String, parameters: [String : String]) {
        // バックグラウンドで非同期処理する。response inは非同期処理の記法？
        // response in はクロージャ
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
            response in
            if response.result.isSuccess {
                print("Success! Got the weather data")
                
                // response.result.valueはオプショナル型だが、if文で結果を確認しているのでforce unwrappedしてよい
                let weatherJSON: JSON = JSON(response.result.value!)
                // 以下の記法だとなぜダメか調べる(Any型からJSON型へのダウンキャスト)
                //let weatherJSON: JSON = response.result.value! as! JSON
                
                // クロージャの中でメソッドを呼び出すにはself句を呼び出すメソッドの前につける必要あり
                self.updateWeatherData(json: weatherJSON)
                
            } else {
                print("Error \(String(describing: response.result.error))")
                self.cityLabel.text = "Connection Issues"
            }
        }
    }

    
    
    
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
   
    
    //Write the updateWeatherData method here:
    func updateWeatherData(json: JSON) {
        
        guard let tempResult = json["main"]["temp"].double else {
            cityLabel.text = "Weather Unavailable"
            return
        }
        let cityResult = json["name"].stringValue
        let conditionResult = json["weather"][0]["id"].intValue
        
        weatherDataModel.temperature = Int(tempResult - 273.15)
        weatherDataModel.city = cityResult
        weatherDataModel.condition = conditionResult
        weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
    }

    
    
    
    //MARK: - UI Updates
    /***************************************************************/
    
    
    //Write the updateUIWithWeatherData method here:
    
    
    
    
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    //Write the didUpdateLocations method here:
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // CLLocationの配列に収められている位置情報のうち、最新のものが最も精度が良いので、それのみを取得
        let location = locations[locations.count - 1]
        // 位置情報はlatitudeとlongitudeのunsigned floatでradiusな情報として与えられるが、
        // もし負になると位置情報の取得に失敗しているので、位置情報取得を停止して電池消耗を抑える
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            
            print("longitude = \(location.coordinate.longitude), latitude = \(location.coordinate.latitude)")
            
            // 緯度・経度を文字列に変換してセット
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            
            // Dictionary型を定義して、緯度・経度・APIKeyをセット
            let params: [String : String] = ["lat" : latitude, "lon" : longitude, "appid" : APP_ID]
            
            getWeatherData(url: WEATHER_URL, parameters: params)
        }
    }
    
    
    //Write the didFailWithError method here:
    // トンネルやAirplaneモードなど利用不可の時のためのメソッド
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        cityLabel.text = "Location Unavailable"
    }
    
    

    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    
    //Write the userEnteredANewCityName Delegate method here:
    

    
    //Write the PrepareForSegue Method here
    
    
    
    
    
}



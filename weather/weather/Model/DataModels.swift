//
//  DataModels.swift
//  weather
//
//  Created by Baudunov Rapkat on 3/13/20.
//  Copyright © 2020 Baudunov Rapkat. All rights reserved.
//

import Foundation

struct Weather: Codable {
    var id: Int
    var main: String
    var description: String
    var icon: String
}

struct Main: Codable {
    var temp: Double = 0.0
    var pressure: Int = 0
    var humidity: Int = 0
    var feels_like: Double = 0.0
    
    
}

struct Wind: Codable {
    var speed:Int = 0
}

struct WeatherData: Codable {
    var weather: [Weather] = []
    var main: Main = Main()
    var name: String = ""
    var wind: Wind = Wind()
    var dt:Int?
    var dt_txt:String?
    var pod:Pod?
}

struct Pod:Codable {
    var pod:String?
}

struct PredictWeather: Codable {
    var list: [List]?
}

struct List:Codable {
    var list:[WeatherData]
}

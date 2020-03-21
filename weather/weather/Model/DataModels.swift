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
   //  var dt:Int?
}

struct Main: Codable {
    var temp: Double
    var pressure: Int
    var humidity: Int
    var feels_like: Double
    
    
}

struct Wind: Codable {
    var speed:Int = 0
}

struct WeatherData: Codable {
    var weather: [Weather] = []
    var main: Main
    var name: String = ""
    var wind: Wind = Wind()
    var dt:Int?
    var pod:Pod?
}

struct Pod:Codable {
    var pod:String?
}

//struct Welcome: Codable {
//    var list: [List]?
//    var dt_txt: String?
//
//}

class List: Codable {
    var list: [WeatherItem]?
}

struct Main2: Codable {
    var temp: Double = 0.0
}

struct WeatherItem: Codable {
    var weather: [Weather]?
    var main: Main?
    var dt_txt: String?
    var dt:Int?
    
}

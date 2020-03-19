//
//  Server.swift
//  weather
//
//  Created by Baudunov Rapkat on 3/19/20.
//  Copyright © 2020 Baudunov Rapkat. All rights reserved.
//

import Foundation

class Servers {
    
    static let shared = Servers()

func updateWeatherInfo(latitude: Double, longtitude: Double, completion: @escaping (WeatherData)->()){
    let session = URLSession.shared
    let url = URL(string: "http://api.openweathermap.org/data/2.5/weather?lat=\(latitude.description)&lon=\(longtitude.description)&units=metric&APPID=b02ed43b351c5a197dde4d6a0a50c53c")!
    let task = session.dataTask(with: url) { (data, respose, error) in
        guard error == nil else{
            print("DataTask error \(error!.localizedDescription)")
            return
        }
        do{
            let info = try JSONDecoder().decode(WeatherData.self, from: data!)
            DispatchQueue.main.async {
                completion(info)
            }
        }catch{
            print(error.localizedDescription)
        }
    }
    task.resume()
}

func predictWeather(latitude: Double, longtitude: Double,completion: @escaping (List)->()){
    let session = URLSession.shared
    let url = URL(string: "http://api.openweathermap.org/data/2.5/forecast?lat=\(latitude.description)&lon=\(longtitude.description)&units=metric&APPID=b02ed43b351c5a197dde4d6a0a50c53c")!
    let task = session.dataTask(with: url) { (data, respose, error) in
        guard error == nil else{
            print("DataTask error \(error!.localizedDescription)")
            return
        }
        do{
            let data = try JSONDecoder().decode(List.self, from: data!)

            DispatchQueue.main.async {
//                self.list = data
//                self.collectionViewLabel.reloadData()
//                self.updateTemp()
                completion(data)
            }
        }catch{
            print(error.localizedDescription)
        }
    }
    task.resume()
}
}

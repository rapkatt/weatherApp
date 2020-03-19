//
//  ViewController.swift
//  weather
//
//  Created by Baudunov Rapkat on 3/12/20.
//  Copyright © 2020 Baudunov Rapkat. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire

class ViewController: UIViewController,UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout,UICollectionViewDataSource {
    
    
    
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var weatherDescription: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var windLabel: UILabel!
    @IBOutlet weak var feelsLikeLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var currentDayLabel: UILabel!
    
    @IBOutlet weak var imageLabel: UIImageView!
    @IBOutlet var background: UIView!
    @IBOutlet weak var collectionViewLabel: UICollectionView!
    
    let locationManager = CLLocationManager()
    var weatherData: WeatherData?
    var list: List?
    //    var list2 = Welcome()
    var chekerDayorNight = ""
    var date: Int = 1584446400
    var temperatureDay : [WeatherItem] = []
    var temperatureNight: [WeatherItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startLocationManager()
        UpdateDayorNight()
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! NextDaysModel

        if temperatureDay.isEmpty {
            return cell
        }
        cell.weekDayLabel.text = date.week(indexPath.row)
        cell.tempDayLabel.text = (Int(temperatureDay[indexPath.row].main!.temp)).description
        cell.tempNightLabel.text = (Int(temperatureNight[indexPath.row].main!.temp)).description
        
        
        return cell
    }
    
    func updateTemp(){
        for i in (list?.list!)! {
            if i.dt_txt!.suffix(8) == "12:00:00"{
                self.temperatureDay.append(i)
            }else if i.dt_txt!.suffix(8) == "00:00:00"{
                self.temperatureNight.append(i)
            }
        }
        collectionViewLabel.reloadData()
    }
    
    func startLocationManager(){
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled(){
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            locationManager.pausesLocationUpdatesAutomatically = false
            locationManager.startUpdatingLocation()
        }
    }
    
    func updateView(){
        cityNameLabel.text = weatherData?.name
        weatherDescription.text = DataSource.weatherIDs[(weatherData?.weather[0].id)!]
        temperatureLabel.text = (Int((weatherData?.main.temp)!)).description + "º"
        feelsLikeLabel.text = (Int((weatherData?.main.feels_like)!)).description + "º"
        humidityLabel.text = (weatherData?.main.humidity.description)! + "%"
        windLabel.text = (weatherData?.wind.speed.description)! + " km/h"
        currentDayLabel.text = weatherData?.dt?.week(0)
        imageLabel.image = UIImage(named: (weatherData?.weather[0].icon)!)
    }
    
    
    func updateWeatherInfo(latitude: Double, longtitude: Double){
        let session = URLSession.shared
        let url = URL(string: "http://api.openweathermap.org/data/2.5/weather?lat=\(latitude.description)&lon=\(longtitude.description)&units=metric&APPID=b02ed43b351c5a197dde4d6a0a50c53c")!
        let task = session.dataTask(with: url) { (data, respose, error) in
            guard error == nil else{
                print("DataTask error \(error!.localizedDescription)")
                return
            }
            do{
                self.weatherData = try JSONDecoder().decode(WeatherData.self, from: data!)
                DispatchQueue.main.async {
                    self.updateView()
                }
            }catch{
                print(error.localizedDescription)
            }
        }
        task.resume()
    }
    
    
    
    func predictWeather(latitude: Double, longtitude: Double){
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
                    self.list = data
                    self.collectionViewLabel.reloadData()
                    self.updateTemp()
                }
            }catch{
                print(error.localizedDescription)
            }
        }
        task.resume()
    }
    func UpdateDayorNight(){
        chekerDayorNight = weatherData?.pod?.pod?.description ?? "d"
        
        if chekerDayorNight == "d" {
            chekerDayorNight = "d"
            background.backgroundColor = UIColor(red: 82/255, green: 155/255, blue: 204/255, alpha: 1.0)
        } else {
            chekerDayorNight = "n"
            background.backgroundColor = UIColor(red: 0/255, green: 97/255, blue: 158/255, alpha: 1.0)
        }
    }
    
}
extension ViewController:CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let lastLocation = locations.last{
            updateWeatherInfo(latitude: lastLocation.coordinate.latitude, longtitude: lastLocation.coordinate.longitude)
            predictWeather(latitude: lastLocation.coordinate.latitude, longtitude: lastLocation.coordinate.longitude)
        }
    }
}

extension Int {
    
    func week(_ offset: Int) -> String {
        return weekMaker(unixTime: Double(self), offset: offset)
    }
    
}

func weekMaker(unixTime: Double, timeZone: String = "Kyrgyzstan/Bishkek", offset: Int) -> String {
    if(timeZone == "" || unixTime == 0.0) {
        return ""
    } else {
        let time = Date(timeIntervalSince1970: unixTime)
        var cal = Calendar(identifier: .gregorian)
        if let kg = TimeZone(identifier: timeZone) {
            cal.timeZone = kg
        }
        
        let weekday = (cal.component(.weekday, from: time) + offset - 1) % 7
        
        return Calendar.current.weekdaySymbols[weekday]
    }
}

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
    
    var list: List?
    var chekerDayorNight = ""
    var weatherData: WeatherData?
    var date: Int = 1584619200
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
    
    func updateTemp(list:List){
        for i in (list.list!) {
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
    
    func updateView(weatherData: WeatherData){
        
        cityNameLabel.text = weatherData.name
        weatherDescription.text = DataSource.weatherIDs[(weatherData.weather[0].id)]
        temperatureLabel.text = (Int((weatherData.main.temp))).description + "º"
        feelsLikeLabel.text = (Int((weatherData.main.feels_like))).description + "º"
        humidityLabel.text = (weatherData.main.humidity.description) + "%"
        windLabel.text = (weatherData.wind.speed.description) + " km/h"
        currentDayLabel.text = weatherData.dt?.week(0)
        imageLabel.image = UIImage(named: (weatherData.weather[0].icon))
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
            
            Servers.shared.updateWeatherInfo(latitude: lastLocation.coordinate.latitude, longtitude: lastLocation.coordinate.longitude, completion: updateView(weatherData:) )
            
            Servers.shared.predictWeather(latitude: lastLocation.coordinate.latitude, longtitude: lastLocation.coordinate.longitude,completion: updateTemp(list:))
            
        }
    }
}



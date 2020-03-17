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
    
    @IBOutlet var background: UIView!
    @IBOutlet weak var collectionViewLabel: UICollectionView!
    
    let locationManager = CLLocationManager()
    var weatherData = WeatherData()
    var list = PredictWeather()
    var chekerDayorNight = ""
    var date: Int = 1584446400
    
    
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
       
    
        cell.weekDayLabel.text = date.week(indexPath.row)

       
       return cell
   }
    
    func up(info:List){
        self.date = info.list[0].dt!
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
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
        cityNameLabel.text = weatherData.name
        weatherDescription.text = DataSource.weatherIDs[weatherData.weather[0].id]
        temperatureLabel.text = weatherData.main.temp.description + "º"
        feelsLikeLabel.text = weatherData.main.feels_like.description + "º"
        humidityLabel.text = weatherData.main.humidity.description + "%"
        windLabel.text = weatherData.wind.speed.description + " km/h"
        currentDayLabel.text = weatherData.dt?.week(0)
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
    

    func predictWeather( latitude: Double, longtitude: Double,completion:  @escaping (List)->()){
        
        let jsonUrlString = "http://api.openweathermap.org/data/2.5/forecast?lat=\(latitude.description)&lon=\(longtitude.description)&units=metric&APPID=b02ed43b351c5a197dde4d6a0a50c53c"
        
        guard let url = URL(string: jsonUrlString) else { return }
      
        AF.request(url).validate().responseJSON { (response) in
            let result = response.data
            
            
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .secondsSince1970
                let info = try decoder.decode(List.self, from: result!)
                
                DispatchQueue.main.async {
                    completion(info)
                }
            } catch let jsonErr {
                print("Error serializing json:", jsonErr)
            }
        }
    }
    func UpdateDayorNight(){
        chekerDayorNight = weatherData.pod?.pod?.description ?? "d"
        
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
            print(lastLocation.coordinate.latitude,lastLocation.coordinate.longitude)
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

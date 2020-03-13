//
//  ViewController.swift
//  weather
//
//  Created by Baudunov Rapkat on 3/12/20.
//  Copyright © 2020 Baudunov Rapkat. All rights reserved.
//

import UIKit
import CoreLocation


class ViewController: UIViewController {
    
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var weatherDescription: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var imageIconImageView: UIImageView!
    let locationManager = CLLocationManager()
    var weatherData = WeatherData()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        startLocationManager()
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
        imageIconImageView.image = UIImage(named: weatherData.weather[0].icon)
    }
    
    func updateWeatherInfo(latitude: Double, longtitude: Double){
        let session = URLSession.shared
        let url = URL(string: "http://api.openweathermap.org/data/2.5/weather?lat=\(latitude.description)&lon=\(longtitude.description)&units=metric&lang=ru&APPID=b02ed43b351c5a197dde4d6a0a50c53c")!
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
}
extension ViewController:CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let lastLocation = locations.last{
            updateWeatherInfo(latitude: lastLocation.coordinate.latitude, longtitude: lastLocation.coordinate.longitude)
            print(lastLocation.coordinate.latitude,lastLocation.coordinate.longitude)
        }
    }
}

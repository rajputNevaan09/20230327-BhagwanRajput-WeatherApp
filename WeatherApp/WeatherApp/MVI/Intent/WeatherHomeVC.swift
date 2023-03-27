//
//  WeatherHomeVC.swift
//  WeatherApp
//
//  Created by Bhagwan Rajput on 27/03/23.
//

import UIKit
import MapKit
import CoreLocation
import SwiftUI


class WeatherHomeVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate{
    
    //Outlest and connections
    @IBOutlet var lblWindSpeed: UILabel!
    @IBOutlet var bgView: UIView!
    @IBOutlet var searchText: UILabel!
    @IBOutlet var SearchView: UIView!
    @IBOutlet var btnSearch: UIButton!
    @IBOutlet var lblVisibility: UILabel!
    @IBOutlet var lblHumidity: UILabel!
    @IBOutlet var mapView: MKMapView!
    
    @IBOutlet var imgWeather: UIImageView!
    @IBOutlet var lblTemperature: UILabel!
    
    @IBOutlet var lblCurrentCity: UILabel!
    @IBOutlet var lblCurrentDateAndTime: UILabel!
    @IBOutlet var lblDescprition: UILabel!
    
    //Variable and properties decleration
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var cityName: String?
    var stateName: String?
    var countryName: String?
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // On initial load
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, h:mm a"
        let dateString = dateFormatter.string(from: Date())
        
        print(dateString) // Output: "Mar 27, 11:18 AM"
        
        mapView.delegate = self
        mapView.showsUserLocation = true
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loadViewIfNeeded()
        
        if (Constant.city != "") {
            getWeatherDataFromAPI()
        }
    }
    
    
    //Location delegate manager
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        currentLocation = location
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = location.coordinate
        annotation.title = "You are here"
        mapView.addAnnotation(annotation)
        
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(region, animated: true)
        
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] (placemarks, error) in
            if let error = error {
                print("Error getting city name: \(error.localizedDescription)")
                return
            }
            
            guard let placemark = placemarks?.first else {
                print("No placemark found")
                return
            }
            
            self?.cityName = placemark.locality ?? ""
            print("City: \(self?.cityName ?? "unknown")")
            self?.stateName = placemark.administrativeArea ?? ""
            print("State: \(self?.stateName ?? "unknown")")
            self?.countryName = placemark.country ?? ""
            print("country: \(self?.countryName ?? "unknown")")
            
            let address = "\(self?.cityName ?? "unknown"), \(self?.stateName ?? "unknown") \(self?.countryName ?? "unknown")"
            self?.searchText.text! = address
            let defaults = UserDefaults.standard
            if let cityName = defaults.string(forKey: "cityName") {
                // do something with the username
                Constant.city = cityName
            }else{
                if Constant.city == "" {
                    Constant.city = placemark.locality ?? ""
                }
            }
            
            self?.getWeatherDataFromAPI()
        }
        locationManager.stopUpdatingLocation()
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else { return nil }
        
        let identifier = "marker"
        var view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if view == nil {
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view?.canShowCallout = true
        } else {
            view?.annotation = annotation
        }
        
        return view
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error getting user location: \(error.localizedDescription)")
    }
    
    
    //MARK:: API call to get weather data
    func getWeatherDataFromAPI() {
        if (Constant.alert == false) {
            self.view.isUserInteractionEnabled = false
            let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)
            
            let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
            loadingIndicator.hidesWhenStopped = true
            loadingIndicator.style = UIActivityIndicatorView.Style.medium
            loadingIndicator.startAnimating()
            
            alert.view.addSubview(loadingIndicator)
            
            present(alert, animated: true, completion: nil)
        }
        
        if let url = URL(string: "\(APIEndPoints.BASE_URL)\(Constant.city)&appid=\(Constant.API_KEY)") {
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                guard data == data, error == nil else {
                    print(error?.localizedDescription ?? "Unknown error")
                    print(data as Any)
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        // The response is successful
                        do {
                            let weatherResponse = try JSONDecoder().decode(WeatherResponse.self, from: data!)
                            // Use the WeatherResponse instance as needed
                            DispatchQueue.main.async {
                                
                                let date = self.getCurrentDateAndTime()
                                self.lblCurrentDateAndTime.text! = date
                                
                                // Access the humidty from weather response
                                let humidity = weatherResponse.main.humidity
                                print("Humidity: \(humidity) %")
                                self.lblHumidity.text! = "Humidity: \(humidity)%"
                                
                                // Access the humidty from weather response
                                let visibility = weatherResponse.visibility / 1000
                                print("Visibility: \(visibility) %")
                                self.lblVisibility.text! = "Visibility: \(visibility) km"
                                
                                
                                // Access the humidty from weather response
                                let windspeed = weatherResponse.wind.speed
                                print("Wind Speed: \(windspeed) %")
                                self.lblWindSpeed.text! = "Wind Speed: \(Int(windspeed)) km/h"
                                
                                // Access the Feel like temp in Celsius
                                let temperatureFeellikeCelsius = weatherResponse.main.feelsLike - 273.15
                                print("Temperature Feell ike: \(temperatureFeellikeCelsius) °C")
                                // Access the weather description
                                let weatherDescription = weatherResponse.weather.first?.description ?? "Unknown"
                                self.lblDescprition.text! = ("Feels like \(Int(temperatureFeellikeCelsius)) °C. \(weatherDescription). Gentle Breeze")
                                print("Weather description: \(weatherDescription)")
                                
                                // Access the temperature in Celsius
                                let temperatureCelsius = weatherResponse.main.temp - 273.15
                                print("Temperature: \(temperatureCelsius) °C")
                                
                                self.lblTemperature.text! = "\(Int(temperatureCelsius)) °C"
                                
                                // Access the wind speed in kilometers per hour
                                let windSpeedKph = weatherResponse.wind.speed * 3.6
                                print("Wind speed: \(windSpeedKph) km/h")
                                
                                // Access the coutry name
                                let weatherCity = weatherResponse.name
                                let weatherCountry = weatherResponse.sys.country
                                self.lblCurrentCity.text! = "\(weatherCity), \(weatherCountry)"
                                self.searchText.text! =  "\(weatherCity), \(weatherCountry)"
                                print("Weather Country: \(weatherCountry)")
                                
                                if let iconCode = weatherResponse.weather.first?.icon as? String {
                                    let iconURL = URL(string: "https://openweathermap.org/img/wn/\(iconCode).png")!
                                    URLSession.shared.dataTask(with: iconURL) { data, response, error in
                                        guard let data = data, error == nil else { return }
                                        DispatchQueue.main.async {
                                            let image = UIImage(data: data)
                                            self.imgWeather.image = image
                                        }
                                    }.resume()
                                }
                                
                                if (Constant.alert == false) {
                                    self.dismiss(animated: true)
                                }
                                self.view.isUserInteractionEnabled = true
                                let defaults = UserDefaults.standard
                                defaults.set(Constant.city, forKey: "cityName")
                                
                            }
                            print("Weather data response is::",weatherResponse)
                        } catch {
                            print("Error decoding response data: \(error.localizedDescription)")
                            DispatchQueue.main.async {
                                self.showAlert()
                            }
                        }
                        
                    } else {
                        // The API call failed
                        DispatchQueue.main.async {
                            self.showAlert()
                        }
                        print("HTTP response status code: \(httpResponse.statusCode)")
                    }
                }
            }
            task.resume()
        } else {
            // The API call failed
            DispatchQueue.main.async {
                self.showAlert()
            }
            print("Invalid URL")
        }
    }
    
    
    //For Alert Controller
    func showAlert() {
        let alert = UIAlertController(title: "Weather Alert!", message: "Please enter valid city or try after sometime.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            // Added code here to be executed when the "OK" button is tapped
            self.goToNextVC()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    //To get current date and time in Mar 27, 11:18 AM format
    func getCurrentDateAndTime() -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, h:mm a"
        let dateString = dateFormatter.string(from: Date())
        print("Current date and time is::", dateString) // Output: "Mar 27, 11:18 AM"
        
        return dateString
        
    }
    
    
    // MARK: - Navigation
    @IBAction func btnSearchAction(_ sender: Any) {
        print("Search Actionc Called")
        goToNextVC()
    }
    
    //Navigation controller to SwiftUI class
    func goToNextVC() {
        let mySwiftUIView = EnterCityView()
        let hostingController = UIHostingController(rootView: mySwiftUIView)
        hostingController.modalPresentationStyle = .fullScreen
        Constant.alert = true
        self.present(hostingController, animated: true, completion: nil)
    }
    
}

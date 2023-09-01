//
//  ViewController.swift
//  Weather
//
//  Created by 賴詩晴 on 2023/8/30.
//

import UIKit
import Alamofire //網路處理的程式庫，取代我們使用 URLSession 方式下來載資料
import SwiftyJSON  //處理 JSON 的第三方程式庫
import NVActivityIndicatorView //客製化loading圖示
import CoreLocation //device location

class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var daylabel: UILabel!
    
    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var conditionLabel: UILabel!
    
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var background: UIView!
    
    let gradientLayer = CAGradientLayer()
    
    let apiKey = "9760fa2ead59c8cf3825c08ca70225cb"
    var lat = 23.5
    var lon = 121.0
    var activityIndicator: NVActivityIndicatorView!
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        background.layer.addSublayer(gradientLayer)
        
        let indicatorSize: CGFloat = 70
        let indicatorFrame = CGRect(x: (view.frame.width-indicatorSize)/2, y: (view.frame.height-indicatorSize)/2, width: indicatorSize, height: indicatorSize)
        activityIndicator = NVActivityIndicatorView(frame: indicatorFrame, type: .lineScale, color: UIColor.white, padding: 20.0)
        activityIndicator.backgroundColor = UIColor.black
        view.addSubview(activityIndicator)
        
        locationManager.requestAlwaysAuthorization()  //詢問權限
        
        if(CLLocationManager.locationServicesEnabled()){
            locationManager.delegate = self  //設定delegate來接收update
            locationManager.desiredAccuracy = kCLLocationAccuracyBest //決定精準度
        }
        
        activityIndicator.startAnimating()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setBlueGradientBackground()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch locationManager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            let controller = UIAlertController(title: "需要位置權限", message: "不然不能用", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default)
            controller.addAction(ok)
            present(controller,animated: true)
        default:   //一開始會先跑 .notDetermined 所以要break
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        lat = location.coordinate.latitude
        lon = location.coordinate.longitude
        Alamofire.request("https://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(lon)&units=metric&&appid=\(apiKey)").responseJSON{
            response in
            self.activityIndicator.stopAnimating()
            if let responseStr = response.result.value {
                let jsonResponse = JSON(responseStr)
                let jsonWeather = jsonResponse["weather"].array![0]
                let jsonTemp = jsonResponse["main"]
                let iconName = jsonWeather["icon"].stringValue
                
                self.locationLabel.text = jsonResponse["name"].stringValue
                self.conditionImageView.image = UIImage(named: iconName)
                self.conditionLabel.text = jsonWeather["main"].stringValue
                self.temperatureLabel.text = "\(Int(round(jsonTemp["temp"].doubleValue)))"
                
                let date = Date()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "EEEE"
                self.daylabel.text = dateFormatter.string(from: date)
                
                //iconName 早上d 晚上n
                let suffix = iconName.suffix(1)
                if(suffix == "n"){
                    self.setGreyGradientBackground()
                }else{
                    self.setBlueGradientBackground()
                }
            }
        }
        self.locationManager.stopUpdatingLocation()
    }

    func setBlueGradientBackground(){
        let topColor = UIColor(red: 95/255, green: 165/255, blue: 1, alpha: 1).cgColor
        let bottomColor = UIColor(red: 72/255, green: 114/255, blue: 184/255, alpha: 1).cgColor
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [topColor, bottomColor]
    }
    
    func setGreyGradientBackground(){
        let topColor = UIColor(red: 151/255, green: 151/255, blue: 151/255, alpha: 1).cgColor
        let bottomColor = UIColor(red: 72/255, green: 72/255, blue: 72/255, alpha: 1).cgColor
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [topColor, bottomColor]
    }
}


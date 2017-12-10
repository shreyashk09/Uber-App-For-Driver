//
//  DriverVC.swift
//  Uber App For Driver
//
//  Created by Shreyash Kawalkar on 09/12/17.
//  Copyright © 2017 Sk. All rights reserved.
//

import UIKit
import MapKit

class DriverVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UberController {
    
    
    @IBOutlet weak var myMap: MKMapView!
    
    @IBOutlet weak var acceptUberBtn: UIButton!
   private var locationManager = CLLocationManager()
    private var userLocation: CLLocationCoordinate2D?
    private var riderLocation: CLLocationCoordinate2D?
    private var timer = Timer()
    
    private var acceptedUber = false
    private var driverCanceledUber = false
    override func viewDidLoad() {
        super.viewDidLoad()
        UberHandler.instance.delegate = self
        UberHandler.instance.observeMessegaesForDriver()
        initializeLocationManager()
    }
    
    private func initializeLocationManager(){
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locationManager.location?.coordinate{
            userLocation = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        let region =  MKCoordinateRegionMake(userLocation!, MKCoordinateSpanMake(0.01, 0.01))
        myMap.setRegion(region, animated: true)
        myMap.removeAnnotations(myMap.annotations)
            if riderLocation != nil{
                let annotation = MKPointAnnotation();
                annotation.coordinate = riderLocation!
                annotation.title = "Riders Location"
                myMap.addAnnotation(annotation)
            }
            let annotation = MKPointAnnotation();
            annotation.coordinate = userLocation!
            annotation.title = "Driver Location"
            myMap.addAnnotation(annotation)
        }
        
    }
    
    func updateDriverLocation(){
        UberHandler.instance.updateDiverLocation(lat: (userLocation?.latitude)!, long: (userLocation?.longitude)!)
        
    }
    
    func updateRiderLocation(lat: Double, long: Double) {
        riderLocation = CLLocationCoordinate2D(latitude: lat, longitude: long)
    }
    
    func acceptUber(lat: Double, long: Double) {
        if !acceptedUber{
        uberRequest(title: "Uber Request", message: "You have request for Uber at this location \(lat) and \(long)", isAlive: true)
        }
    }
    
    func riderCancledUber(){
        if !driverCanceledUber && acceptedUber{
            UberHandler.instance.cancelUberForDriver()
        self.acceptedUber = false
            self.acceptUberBtn.isHidden = true
            uberRequest(title: "Uber Canceled", message: "The rider has cancled Uber", isAlive: false)
        }
    }
    
    @IBAction func logout(_ sender: Any) {
        
        if AuthProviders.instance.logOut(){
            if acceptedUber{
                acceptUberBtn.isHidden = true
                UberHandler.instance.cancelUberForDriver()
                timer.invalidate()
            }
            dismiss(animated: true, completion: nil)
        }
        else{
            uberRequest(title: "Could Not LogOut", message: "Account didn't logout try again!!!", isAlive: false)
        }
    }
    
    
    @IBAction func cancelUber(_ sender: Any) {
        if acceptedUber{
            driverCanceledUber = false
            acceptUberBtn.isHidden = true
            UberHandler.instance.cancelUberForDriver()
            timer.invalidate()
        }
    }
    
    func uberCancled() {
        acceptedUber = false
        acceptUberBtn.isHidden = true
        timer.invalidate()
    }
    
    private func uberRequest(title: String,message: String, isAlive: Bool ){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        if isAlive{
            let accept = UIAlertAction(title : "Accept", style: .default, handler: {(alertAction: UIAlertAction) in
                
                self.timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(DriverVC.updateDriverLocation),userInfo: nil ,repeats: true)
                
                self.acceptedUber = true
                self.acceptUberBtn.isHidden = false
                UberHandler.instance.uberAccepted(lat:
                    Double(self.userLocation!.latitude), long: Double(self.userLocation!.longitude))
            } )
            let cancel = UIAlertAction(title : "cancel", style: .default, handler: nil)
        alert.addAction(accept)
        alert.addAction(cancel)
        }
        else{
            let ok = UIAlertAction(title : "Ok", style: .default, handler: nil)
            alert.addAction(ok)
        }
         present(alert, animated: true, completion: nil)
    }
    
}

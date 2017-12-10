//
//  UberHandler.swift
//  Uber App For Driver
//
//  Created by Shreyash Kawalkar on 09/12/17.
//  Copyright © 2017 Sk. All rights reserved.
//

import Foundation
import FirebaseDatabase

protocol UberController: class{
    func acceptUber(lat: Double, long: Double);
    func riderCancledUber()
    func uberCancled()
    func updateRiderLocation(lat: Double, long: Double)
}

class UberHandler{
   
    weak var delegate: UberController?
    private static let inst = UberHandler()
    
    var rider = ""
    var driver = ""
    var driver_id = ""
    
    static var instance: UberHandler{return inst}
    
    func observeMessegaesForDriver(){
        DBProvider.instance.requestRef.observe(DataEventType.childAdded, with: {(snapshot: DataSnapshot) in
            if let data = snapshot.value as? NSDictionary{
                if let latitude = data[Constants.LATITUDE] as? Double{
                    if let longitude = data[Constants.LONGITUDE] as? Double{
                        self.delegate?.acceptUber(lat: latitude, long: longitude)
                    }
                }
                if let name = data[Constants.NAME]{
                self.rider = name as! String
                }
            }
            DBProvider.instance.requestRef.observe(DataEventType.childRemoved, with: {(snapshot: DataSnapshot) in if let data = snapshot.value as? NSDictionary{
                if let name = data[Constants.NAME] as? String{
                    if name == self.rider{
                        self.rider = ""
                        self.delegate?.riderCancledUber()
                    }
                }}
            })
        })
        
        DBProvider.instance.requestAcceptedRef.observe(DataEventType.childAdded, with: {(snapshot: DataSnapshot) in
            if let data = snapshot.value as? NSDictionary{
                if let name = data[Constants.NAME] as? String{
                    if name == self.driver {
                        self.driver_id = snapshot.key
                    }
                }}
            })
        DBProvider.instance.requestAcceptedRef.observe(DataEventType.childRemoved, with: {(snapshot: DataSnapshot) in
            if let data = snapshot.value as? NSDictionary{
                if let name = data[Constants.NAME] as? String{
                    if name == self.driver {
                        self.delegate?.uberCancled()
                    }
                }}
        })
        
        // update rider location
        DBProvider.instance.requestRef.observe(DataEventType.childChanged, with: {(snapshot: DataSnapshot) in
            if let data = snapshot.value as? NSDictionary{
                if let name = data[Constants.NAME] as? String{
                    if name == self.rider {
                        if let lat = data[Constants.LATITUDE] as? Double{
                            if let long = data[Constants.LONGITUDE] as? Double{
                        
                        self.delegate?.updateRiderLocation(lat: lat, long: long)
                            }}}
                }}
        })

    }
    
    func uberAccepted(lat: Double, long: Double){
        let data: Dictionary<String, Any> = [Constants.NAME: driver, Constants.LATITUDE: lat, Constants.LONGITUDE: long]
        DBProvider.instance.requestAcceptedRef.childByAutoId().setValue(data)
    }
    
    func cancelUberForDriver(){
    DBProvider.instance.requestAcceptedRef.child(driver_id).removeValue()
    }
    
    func updateDiverLocation(lat: Double, long: Double){
        DBProvider.instance.requestAcceptedRef.child(driver_id).updateChildValues([Constants.LONGITUDE: long, Constants.LATITUDE: lat])
    }
    
}

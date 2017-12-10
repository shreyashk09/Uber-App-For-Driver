//
//  DBProvider.swift
//  Uber App For Driver
//
//  Created by Shreyash Kawalkar on 09/12/17.
//  Copyright © 2017 Sk. All rights reserved.
//

import Foundation
import Firebase
class DBProvider {
    
    private static let _inst =  DBProvider()
    static var instance: DBProvider {return _inst}
    
    var dbRef: DatabaseReference{
        return Database.database().reference()}
    
    var ridersRef: DatabaseReference{
        return dbRef.child(Constants.DRIVERS)
    }
    
    func saveUser(id:String, email: String, password: String){
        let data: Dictionary <String, Any> = [Constants.EMAIL: email, Constants.PASSWORD: password, Constants.ISDRIVER: true]
        ridersRef.child(id).child(Constants.DATA).setValue(data)
    }
    var requestRef: DatabaseReference{ return dbRef.child(Constants.UBER_REQUEST)
    }
    
    var requestAcceptedRef: DatabaseReference{
        return dbRef.child(Constants.UBER_ACCEPTED)
    }
}

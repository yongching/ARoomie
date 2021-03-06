//
//  User.swift
//  ARoomie
//
//  Created by Yong Ching on 25/12/2016.
//  Copyright © 2016 Yong Ching. All rights reserved.
//

import Foundation
import SwiftyJSON

class User {
    /**
    var name: String?
    var age_range: String?
    var gender: String?
    var email: String?
    var pictureURL: String?
    **/
    
    static let currentUser = User()
    
    var id: Int?
    var pictureURL: String?
    var name: String?
    var age_range: String?
    var gender: String?
    var race: Int?
    var email: String?
    var phone: String?
    var lifestyle: String?
    
    var gender_pref: Int?
    var race_pref: Int?
    var budget_pref: String?
    var move_in_pref: String?
    
    /**
    func setInfo(json: JSON) {
        self.name = json["name"].string
        self.age_range = json["age_range"].string
        self.gender = json["gender"].string
        self.email = json["email"].string
        
        let image = json["picture"].dictionary
        let imageData = image?["data"]?.dictionary
        self.pictureURL = imageData?["url"]?.string
        //self.pictureURL = json["picture"]["data"]["url"].string
    }
    **/
    
    func setInfo(json: JSON) {
        self.id = json["basic"]["id"].intValue
        self.pictureURL = json["profile"]["avatar"].stringValue
        self.name = json["basic"]["first_name"].stringValue + " " + json["basic"]["last_name"].stringValue
        self.age_range = json["age_range"].stringValue
        self.gender = json["profile"]["gender"].stringValue
        let race = json["profile"]["race"].stringValue
        if !(race == "") {
            self.race = Int(race)
        }
        self.email = json["basic"]["email"].stringValue
        self.phone = json["profile"]["phone"].stringValue
        self.lifestyle = json["profile"]["lifestyle_info"].stringValue
        
        let gender_pref = json["profile"]["gender_pref"].stringValue
        if !(gender_pref == "") {
            self.gender_pref = Int(gender_pref)
        }
        let race_pref = json["profile"]["race_pref"].stringValue
        if !(race_pref == "") {
            self.race_pref = Int(race_pref)
        }
        self.budget_pref = json["profile"]["budget_pref"].stringValue
        self.move_in_pref = json["profile"]["move_in_pref"].stringValue
    }
    
    func setPreferences(gender: Int?, race: Int?, budget: String?, moveIn: String?) {
        self.gender_pref = gender
        self.race_pref = race
        self.budget_pref = budget
        self.move_in_pref = moveIn
    }
    
    func resetInfo() {
        self.id = nil
        self.pictureURL = nil
        self.name = nil
        self.age_range = nil
        self.gender = nil
        self.race = nil
        self.email = nil
        self.phone = nil
        self.lifestyle = nil
        
        self.gender_pref = nil
        self.race_pref = nil
        self.budget_pref = nil
        self.move_in_pref = nil
    }
}

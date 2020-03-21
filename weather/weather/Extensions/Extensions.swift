//
//  Extensions.swift
//  weather
//
//  Created by Baudunov Rapkat on 3/19/20.
//  Copyright © 2020 Baudunov Rapkat. All rights reserved.
//

import Foundation

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


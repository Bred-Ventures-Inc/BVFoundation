//
//  File.swift
//  
//
//  Created by TealShift Schwifty on 7/12/22.
//

import Foundation

public extension Date {
    var age: TimeInterval {
        -self.timeIntervalSinceNow
    }
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay)!
    }
    
    var startOfWeek: Date {
        var myCalendar = Calendar.current
        myCalendar.firstWeekday = 2
        return self.adjust(for: .startOfWeek, calendar: myCalendar)!
    }
    
    var endOfWeek: Date {
        var myCalendar = Calendar.current
        myCalendar.firstWeekday = 2
        return self.adjust(for: .endOfWeek, calendar: myCalendar)!
    }
    
    var startOfMonth: Date {
        return self.adjust(for: .startOfMonth)!
    }
    
    var oneDayPrior: Date {
        self.offset(.day, value: -1)!
    }
    
    var oneDayLater: Date {
        self.offset(.day, value: 1)!   
    }
    
    var oneWeekPrior: Date {
        self.offset(.day, value: -7)!
    }
    var oneMonthPrior: Date {
        self.offset(.month, value: -1)!
    }
    var oneMonthLater: Date {
        self.offset(.month, value: 1)!
    }
    
    var oneWeekLater: Date {
        self.offset(.day, value: 7)!
    }
    
    var startOfYear: Date {
        return self.adjust(for: .startOfYear)!
    }
    var oneYearLater: Date {
        self.offset(.year, value: 1)!
    }
    
    var endOfMonth: Date {
        return self.adjust(for: .endOfMonth)!
    }
    
    var endOfYear: Date {
        return self.adjust(for: .endOfYear)!
    }
    
    func getDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E, MMM d"
        return formatter.string(from: self)
    }
    
    func getWeekString() -> String {
        
        let calendar = Calendar.current
            let dayOfMonth = calendar.component(.day, from: self)
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .ordinal
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return "Week of " + formatter.string(from: self) + " \(numberFormatter.string(from: NSNumber(value:dayOfMonth)) ?? "")"
    }
}

public extension Int {
    var getOrdinalString: String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .ordinal
        return numberFormatter.string(from: self as NSNumber) ?? ""
    }
    var string: String {
        String(self)
    }
}

public extension TimeInterval {
    var formattedAsWorkoutTime: String {
        let hours = Int(self/3600)
        let minutes = Int(self/60) % 60
        let seconds = Int(self) % 60
        let minsStr = String(format: "%02d", minutes)
        let secsStr = String(format: "%02d", seconds)
        if hours == 0 {
            return "\(minsStr):\(secsStr)"
        } else {
            return "\(hours):\(minsStr):\(secsStr)"
        }
    }
}

extension Date {
    public func allDatesUp(to end: Date, incrementing period: DateComponentType) -> [Date] {
        var allDates = [self]
        var thisDate = self
        while let next = thisDate.offset(period, value: 1), next < end {
            thisDate = next
            allDates.append(thisDate)
        }
        return allDates
    }
}

extension Date: Strideable {
    public func distance(to other: Date) -> TimeInterval {
        return other.timeIntervalSinceReferenceDate - self.timeIntervalSinceReferenceDate
    }

    public func advanced(by n: TimeInterval) -> Date {
        return self + n
    }
}

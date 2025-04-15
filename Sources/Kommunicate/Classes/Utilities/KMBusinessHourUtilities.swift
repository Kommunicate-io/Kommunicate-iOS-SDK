//
//  KMBusinessHourUtilities.swift
//  Kommunicate
//
//  Created by Abhijeet Ranjan on 20/03/25.
//

import Foundation

extension KMConversationViewController {
    
    func convertToTimezone(for timezoneIdentifier: String) -> Int {
        let deviceDate = Date() // Current device time
        let formatter = DateFormatter()
        
        // Set the target timezone
        guard let targetTimezone = TimeZone(identifier: timezoneIdentifier) else {
            print("Invalid TimeZone Identifier")
            return 0
        }
        
        formatter.timeZone = targetTimezone
        formatter.dateFormat = "HHmm" // Adjust as needed

        return Int(formatter.string(from: deviceDate)) ?? 0
    }
    
    func getDayOfWeek(for timeZoneIdentifier: String) -> Int {
        let timeZone = TimeZone(identifier: timeZoneIdentifier)
        let calendar = Calendar.current
        var components = calendar.dateComponents([.weekday], from: Date())

        // Convert the date to the given time zone
        if let timeZone = timeZone {
            let secondsFromGMT = timeZone.secondsFromGMT()
            if let convertedDate = Calendar.current.date(byAdding: .second, value: secondsFromGMT, to: Date()) {
                components = calendar.dateComponents([.weekday], from: convertedDate)
            }
        }

        // Convert Sunday = 1, ..., Saturday = 7 to the required format [0,1,2,3,4,5,6]
        if let weekday = components.weekday {
            return (weekday - 1) % 7  // Convert Sunday (1) to 0, Monday (2) to 1, ..., Saturday (7) to 6
        }
        
        return -1
    }
    
    func getWorkingDays(from input: String) -> [Int] {
        let validNumbers = Array(0...6)  // Define the fixed circular sequence
        
        let components = input.split(separator: ",").compactMap { Int($0) }
        guard components.count == 2, let start = components.first, let end = components.last,
              validNumbers.contains(start), validNumbers.contains(end) else {
            return []
        }
        
        var result = [start]
        var current = start
        
        while current != end {
            current = (current + 1) % 7  // Circular increment
            result.append(current)
        }
        
        return result
    }
    
    func minutesBetween(start: Int, end: Int) -> Int {
        let startHours = start / 100
        let startMinutes = start % 100
        let endHours = end / 100
        let endMinutes = end % 100

        let totalStartMinutes = (startHours * 60) + startMinutes
        let totalEndMinutes = (endHours * 60) + endMinutes

        if totalEndMinutes < totalStartMinutes {
            return (1440 - totalStartMinutes) + totalEndMinutes  // Handles crossing midnight
        }

        return totalEndMinutes - totalStartMinutes
    }
}

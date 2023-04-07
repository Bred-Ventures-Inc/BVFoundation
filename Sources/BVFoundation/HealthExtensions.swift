//
//  File.swift
//  
//
//  Created by TealShift Schwifty on 7/12/22.
//

import HealthKit

public extension HKWorkout {
    var locationType: HKWorkoutSessionLocationType {
        metadata?[HKMetadataKeyIndoorWorkout] as? Bool ?? false ? .indoor : .outdoor
    }
}

public extension HKWorkoutActivityType {
    
    /// Simple mapping of available workout types to a human readable name.
    var name: String {
        switch self {
        case .americanFootball:             return "American Football"
        case .archery:                      return "Archery"
        case .australianFootball:           return "Australian Football"
        case .badminton:                    return "Badminton"
        case .baseball:                     return "Baseball"
        case .basketball:                   return "Basketball"
        case .bowling:                      return "Bowling"
        case .boxing:                       return "Boxing"
        case .climbing:                     return "Climbing"
        case .crossTraining:                return "Cross Training"
        case .curling:                      return "Curling"
        case .cycling:                      return "Cycling"
        case .dance:                        return "Dance"
        case .danceInspiredTraining:        return "Dance Inspired Training"
        case .elliptical:                   return "Elliptical"
        case .equestrianSports:             return "Equestrian Sports"
        case .fencing:                      return "Fencing"
        case .fishing:                      return "Fishing"
        case .functionalStrengthTraining:   return "Functional Strength Training"
        case .golf:                         return "Golf"
        case .gymnastics:                   return "Gymnastics"
        case .handball:                     return "Handball"
        case .hiking:                       return "Hike"
        case .hockey:                       return "Hockey"
        case .hunting:                      return "Hunting"
        case .lacrosse:                     return "Lacrosse"
        case .martialArts:                  return "Martial Arts"
        case .mindAndBody:                  return "Mind and Body"
        case .mixedMetabolicCardioTraining: return "Mixed Metabolic Cardio Training"
        case .paddleSports:                 return "Paddle Sports"
        case .play:                         return "Play"
        case .preparationAndRecovery:       return "Preparation and Recovery"
        case .racquetball:                  return "Racquetball"
        case .rowing:                       return "Row"
        case .rugby:                        return "Rugby"
        case .running:                      return "Run"
        case .sailing:                      return "Sailing"
        case .skatingSports:                return "Skating Sports"
        case .snowSports:                   return "Snow Sports"
        case .soccer:                       return "Soccer"
        case .softball:                     return "Softball"
        case .squash:                       return "Squash"
        case .stairClimbing:                return "Stair Climbing"
        case .surfingSports:                return "Surfing Sports"
        case .swimming:                     return "Swim"
        case .tableTennis:                  return "Table Tennis"
        case .tennis:                       return "Tennis"
        case .trackAndField:                return "Track and Field"
        case .traditionalStrengthTraining:  return "Traditional Strength Training"
        case .volleyball:                   return "Volleyball"
        case .walking:                      return "Walk"
        case .waterFitness:                 return "Water Fitness"
        case .waterPolo:                    return "Water Polo"
        case .waterSports:                  return "Water Sports"
        case .wrestling:                    return "Wrestling"
        case .yoga:                         return "Yoga"
        case .other:                        return "Other"
            
            // iOS 10
        case .barre:                        return "Barre"
        case .coreTraining:                 return "Core Training"
        case .crossCountrySkiing:           return "Cross Country Skiing"
        case .downhillSkiing:               return "Downhill Skiing"
        case .flexibility:                  return "Flexibility"
        case .highIntensityIntervalTraining:    return "High Intensity Interval Training"
        case .jumpRope:                     return "Jump Rope"
        case .kickboxing:                   return "Kickboxing"
        case .pilates:                      return "Pilates"
        case .snowboarding:                 return "Snowboarding"
        case .stairs:                       return "Stairs"
        case .stepTraining:                 return "Step Training"
        case .wheelchairWalkPace:           return "Wheelchair Walk Pace"
        case .wheelchairRunPace:            return "Wheelchair Run Pace"
            
            // iOS 11
        case .taiChi:                       return "Tai Chi"
        case .mixedCardio:                  return "Cardio"
        case .handCycling:                  return "Hand Cycling"
            
            // iOS 13
        case .discSports:                   return "Disc Sports"
        case .fitnessGaming:                return "Fitness Gaming"
        
            // iOS 14+
        case .cricket:                      return "Cricket"
        case .cardioDance:                  return "Dance"
        case .socialDance:                  return "Social Dance"
        case .pickleball:                   return "Pickleball"
        case .cooldown:                     return "Cooldown"
        case .swimBikeRun:                  return "Multisports"
        case .transition:                   return "transition"
            
        @unknown default:                   return "Other"
        }
    }
    
    /// Additional mapping for common name for activity types where appropriate.
    var commonName: String {
        switch self {
        case .highIntensityIntervalTraining: return "HIIT"
        case .functionalStrengthTraining,
                .traditionalStrengthTraining: return "Strength Training"
        default: return name
        }
    }
    
    /*
     Mapping of available activity types to emojis, where an appropriate gender-agnostic emoji is available.
     */
    var associatedEmoji: String? {
        switch self {
        case .americanFootball:             return "🏈"
        case .archery:                      return "🏹"
        case .badminton:                    return "🏸"
        case .baseball:                     return "⚾️"
        case .basketball:                   return "🏀"
        case .bowling:                      return "🎳"
        case .boxing:                       return "🥊"
        case .curling:                      return "🥌"
        case .cycling:                      return "🚲"
        case .equestrianSports:             return "🏇"
        case .fencing:                      return "🤺"
        case .fishing:                      return "🎣"
        case .functionalStrengthTraining:   return "💪"
        case .golf:                         return "⛳️"
        case .hiking:                       return "🥾"
        case .hockey:                       return "🏒"
        case .lacrosse:                     return "🥍"
        case .martialArts:                  return "🥋"
        case .mixedMetabolicCardioTraining: return "❤️"
        case .paddleSports:                 return "🛶"
        case .rowing:                       return "🛶"
        case .rugby:                        return "🏉"
        case .sailing:                      return "⛵️"
        case .skatingSports:                return "⛸"
        case .snowSports:                   return "🛷"
        case .soccer:                       return "⚽️"
        case .softball:                     return "🥎"
        case .tableTennis:                  return "🏓"
        case .tennis:                       return "🎾"
        case .traditionalStrengthTraining:  return "🏋️‍♂️"
        case .volleyball:                   return "🏐"
        case .waterFitness, .waterSports:   return "💧"
            
            // iOS 10
        case .barre:                        return "🥿"
        case .crossCountrySkiing:           return "⛷"
        case .downhillSkiing:               return "⛷"
        case .kickboxing:                   return "🥋"
        case .snowboarding:                 return "🏂"
            
            // iOS 11
        case .mixedCardio:                  return "❤️"
            
            // iOS 13
        case .discSports:                   return "🥏"
        case .fitnessGaming:                return "🎮"
            
            // Catch-all
        default:                            return nil
        }
    }
    
    var isTravelingType: Bool {
        switch self {
        case .americanFootball,
            .australianFootball,
            .basketball,
            .crossCountrySkiing,
            .cycling,
            .hiking,
            .running,
            .soccer,
            .trackAndField,
            .walking,
            .wheelchairRunPace,
            .wheelchairWalkPace:
            return true
        default: return false
        }
    }
}

public extension Measurement<UnitLength> {
    private func distanceUnit(metric: Bool) -> UnitLength {
        if metric {
            if value(in: .kilometers) < 0.1 {
                return .meters
            } else {
                return .kilometers
            }
        } else {
            if value(in: .miles) < 0.1 {
                return .feet
            } else {
                return .miles
            }
        }
    }
    private func distanceUnitPrecision(metric: Bool) -> Int {
        switch distanceUnit(metric: metric) {
        case .kilometers: return 1
        case .miles: return 2
        case .meters: return 0
        case .feet: return 0
        default: return 0
        }
    }
    private func distanceFormat(metric: Bool) -> MeasurementFormatter {
        let format = MeasurementFormatter()
        format.unitOptions = .providedUnit
        format.numberFormatter.maximumFractionDigits = distanceUnitPrecision(metric: metric)
        return format
    }
    
    func formattedAsDistance(metric: Bool) -> String {
        distanceFormat(metric: metric).string(from: self.converted(to: distanceUnit(metric: metric)))
    }
}

public extension Measurement<UnitSpeed> {
    func formattedAsPace(splitUnit: UnitLength) -> String? {
        let metersPerSecond = self.value(in: .metersPerSecond)
        guard metersPerSecond > 0 else { return nil }

        let splitDistance = Measurement<UnitLength>(value: 1, unit: splitUnit)
        let splitMeters = splitDistance.value(in: .meters)

        let pace = TimeInterval(splitMeters / metersPerSecond)
        if pace >= 3600 { return nil } // Too slow (pace must be displayed as under an hour)
        
        let minutes = Int(pace/60)
        let seconds = Int(pace) % 60
        // Pace (mins:secs) should format like XX'XX"
        return "\(String(format: "%02d", minutes))\'\(String(format: "%02d", seconds))\""
    }
}

public extension Measurement where UnitType : Dimension {
    init(_ value: Double, in unit: UnitType) {
        self.init(value: value, unit: unit)
    }
    func value(in unit: UnitType) -> Double {
        return self.converted(to: unit).value
    }
}

public extension HKUnit {
    static let bpmUnit = HKUnit.count().unitDivided(by: .minute())
}
public extension HKQuantity {
    var hrBPM: Int {
        return Int(round(doubleValue(for: .bpmUnit)))
    }
}

public extension HKQuantitySample {
    var hrBPM: Int {
        return quantity.hrBPM
    }
    
    @available(iOS 15.4, watchOS 8.5, *)
    static func fetchHeartRate(last: Bool = false, within interval: DateInterval? = nil) async -> [HKQuantitySample]? {
        guard let hrType = HKObjectType.quantityType(forIdentifier: .heartRate) else {return nil}
        var queryPredicate: NSPredicate? = nil
        if let interval = interval {
            queryPredicate = HKQuery.predicateForSamples(withStart: interval.start, end: interval.end, options: .strictEndDate)
        }
        /// Fetch heart rate samples in descending order
        let queryDescriptor = HKSampleQueryDescriptor(
            predicates: [.sample(type: hrType, predicate: queryPredicate)],
            sortDescriptors: [SortDescriptor(\.startDate, order: last ? .reverse :  .forward)],
            limit: last ? 1 : HKObjectQueryNoLimit
        )
        do {
            return try await queryDescriptor.result(for: HKHealthStore()) as? [HKQuantitySample]
        } catch {
            return nil
        }
    }
    
    /// Fetch the last sample of HR from Health (within the past 10 mins)
    @available(iOS 15.4, watchOS 8.5, *)
    static func fetchRecentHeartRateSample() async -> HKQuantitySample? {
        let pastTenMins = DateInterval(start: Date().advanced(by: -10*60), end: Date())
        let samples = await fetchHeartRate(last: true, within: pastTenMins)
        return samples?.first
    }
}

#if os(iOS)
import UIKit
public extension HKSource {
    private static let APPLE_HEALTHAPP_PREFIX   = "com.apple.Health"
    private static let APPLE_ACTIVITYAPP_PREFIX = "com.apple.health"
    
    private enum HKNativeType {
        case appleHealth,
             appleWorkout,
             thisApp
    }

    private static func nativeType(for bundleId: String) -> HKNativeType? {
        if bundleId.hasPrefix(APPLE_HEALTHAPP_PREFIX) { return .appleHealth }
        if bundleId.hasPrefix(APPLE_ACTIVITYAPP_PREFIX) { return .appleWorkout }
        if let myAppIdPrefix = Bundle.main.bundleIdentifier?.lowercased(),
           bundleId.lowercased().contains(myAppIdPrefix) { return .thisApp }
        return nil
    }
    
    static func fetchAppIcon(for bundleId: String) async -> UIImage {
        await memoize(uniquingWith: bundleId) {
            await withCheckedContinuation { continuation in
                if let nativeType = HKSource.nativeType(for: bundleId) {
                    let nativeImg: UIImage?
                    switch nativeType {
                    case .appleHealth: nativeImg = UIImage(named: "icn_appleHealthApp")
                    case .appleWorkout: nativeImg = UIImage(named: "icn_watchActivityApp")
                    case .thisApp: nativeImg = UIImage(named: "icn_fatBurnAppIcon")
                    }
                    continuation.resume(returning: nativeImg ?? UIImage())
                    return
                }
                /// Try to find an icon for this app bundle ID
                let bundleIdBase = bundleId.replacingOccurrences(of: ".watchkitapp", with: "")
//                Log.d("Fetching icon for \(bundleId)")
                guard let requestURL = URL(string: "http://itunes.apple.com/lookup?bundleId=" + bundleIdBase),
                      let jsonData = try? Data(contentsOf: requestURL),
                      let jsonObj = try? (JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as? NSDictionary),
                      let results = jsonObj["results"] as? NSArray,
                      let app = results.firstObject as? NSDictionary,
                      let iconURL = app["artworkUrl100"] as? String,
                      let iconData = try? Data(contentsOf: URL(string: iconURL)!) else {
                    let defaultIcon = UIImage(named: "Start Tab") ?? UIImage()
                    continuation.resume(returning: defaultIcon)
                    return
                }
                continuation.resume(returning: UIImage(data: iconData) ?? UIImage())
            }
        }
    }
}
#endif

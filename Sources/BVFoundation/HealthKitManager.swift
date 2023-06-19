//
//  HealthKitManager.swift
//
//
//  Created by Krishnaprasad Jagadish on 11/07/22.
//

#if canImport(HealthKit)
import Foundation
#if os(iOS)
import NotificationCenter
#endif
import HealthKit

private let userDefaults = UserDefaults.standard

let USER_AGE = 38.0

public struct HRZone {
    public init?(raw: [Int]) {
        guard raw.count == 2, raw[0] <= raw[1] else {return nil}
        self.min = raw[0]
        self.max = raw[1]
    }
    public init(min: Int, max: Int) {
        self.min = min
        self.max = max
    }
    public var min: Int
    public var max: Int
    public func contains(heartRate: Int) -> Bool {
        heartRate <= max && heartRate >= min
    }
    public var rawValue: [Int] {
        [min, max]
    }
}

public struct DailySummaryStat: Identifiable {
    public let id: Date
    public let value: Int
    public let goal: Int
}

@available(watchOS 8.5, *)
@available(iOS 15.4, *)
public class HealthKitManager {
    
    public static let shared = HealthKitManager()
    private let myHealthStore = HKHealthStore()
    
    let writeDataTypes: Set<HKSampleType> = [HKObjectType.workoutType(),
                                             HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
                                             HKObjectType.quantityType(forIdentifier: .heartRate)!,
                                             HKSeriesType.workoutRoute()]
    let readDataTypes : Set = [ HKQuantityType.quantityType(forIdentifier: .heartRate)!,
                                .workoutType(),
                                HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
                                HKObjectType.quantityType(forIdentifier: .basalEnergyBurned)!,
                                HKObjectType.quantityType(forIdentifier: .stepCount)!,
                                HKObjectType.quantityType(forIdentifier: .walkingHeartRateAverage)!,
                                HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
                                HKObjectType.quantityType(forIdentifier: .distanceCycling)!,
                                HKSeriesType.activitySummaryType(),
                                HKSeriesType.workoutRoute(),
                                HKSeriesType.workoutType(),
                                HKObjectType.characteristicType(forIdentifier: .dateOfBirth)!,
                                HKObjectType.workoutType()]
    
    public func determineIfPermissionsRequestNeeded() async -> Bool {
        do {
            let status = try await myHealthStore.statusForAuthorizationRequest(toShare: writeDataTypes, read: readDataTypes)
            return status == .shouldRequest
        } catch {
            Log.e("Error getting permission request status: \(error.localizedDescription)")
            return true
        }
    }
    
    public var liveWorkoutPermissionsGranted: Bool {
        myHealthStore.authorizationStatus(for: .workoutType()) == .sharingAuthorized
    }
    
    //MARK: PUBLIC FUNCTIONS
    //Request health permission
    @discardableResult
    public func requestPermissions() async -> Bool {
        guard !Bundle.main.bundlePath.hasSuffix(".appex") else {
            Log.d("No write types required for extensions.")
            return true
        }
//        Log.d("Requesting HK permission...")
        do {
            try await myHealthStore.requestAuthorization(toShare: writeDataTypes, read: readDataTypes)
            return true
        } catch {
            Log.e("HK permission request error: \(error.localizedDescription)")
            return false
        }
    }
    
    public func getFirstWorkoutDateForSourceString(_ sourceString: String) async -> Date? {
        let sourceDescriptor = HKSourceQueryDescriptor(predicate: .workout())
        guard let sources = try? await sourceDescriptor.result(for: myHealthStore) else {return  nil}
        let fatBurnSources = sources.filter {$0.bundleIdentifier.contains(sourceString)}
        let combined = NSCompoundPredicate(orPredicateWithSubpredicates: fatBurnSources.map({ source in
            HKQuery.predicateForObjects(from: source)
        }))
        let queryDescriptor = HKSampleQueryDescriptor(
            predicates: [.workout(combined)],
            sortDescriptors: [SortDescriptor(\.startDate, order: .forward)],
            limit: 1
        )
        let firstWorkout = try? await queryDescriptor.result(for: myHealthStore).first
        return firstWorkout?.startDate ?? Date()
    }

    /// Determines a Max Heart Rate by first checking Health profile, then falling back to an age-based formula
    public func fetchMaxHR(knownDateOfBirth: Date? = nil) -> Int? {
        do {
            let dobComponents = try myHealthStore.dateOfBirthComponents()
            if let yearOfBirth = dobComponents.year {
                let yearsAge = Date().component(.year)! - yearOfBirth
                return 220 - yearsAge
            }
        } catch { } // Ignore fetch error
        if let dateOfBirth = knownDateOfBirth,
           let thisYear = Date().component(.year),
           let yearOfBirth = dateOfBirth.component(.year) {
            return 220 - (thisYear - yearOfBirth)
        } else {
            Log.w("Failed to fetch user age from Health.")
        }
        return nil
    }
    
    /// Determine the user's walking heart rate for the past week.
    public func fetchWalkingHeartRate(block: @escaping (Int?)->()) {
        let predicate = HKQuery.predicateForSamples(withStart: Date().oneMonthPrior, end: nil)
        let query = HKStatisticsQuery(quantityType: HKQuantityType(.walkingHeartRateAverage),
                                      quantitySamplePredicate: predicate, options: .discreteAverage) { query, stats, error in
            let average = stats?.averageQuantity()
            block(average?.hrBPM)
        }
        myHealthStore.execute(query)

    }
        
    // Get all workouts from a Date range
    // You can choose to add a specific workout type to filter out the workouts
    
    public func getAllWorkouts(within interval: DateInterval) async -> [HKWorkout]? {
        
        // Prepare the predicate
        let queryPredicate = HKQuery.predicateForSamples(withStart: interval.start, end: interval.end, options: .strictEndDate)
        // We only consider a workout if its duration is >= 60 seconds
        let workoutPredicate = HKQuery.predicateForWorkouts(with: .greaterThanOrEqualTo, duration: 60)
        
        let combined = NSCompoundPredicate(andPredicateWithSubpredicates: [queryPredicate, workoutPredicate])
        
        // Prepare descriptor that represents query
        let queryDescriptor = HKSampleQueryDescriptor(
            predicates: [.workout(combined)],
            sortDescriptors: [SortDescriptor(\.startDate, order: .forward)],
            limit: HKObjectQueryNoLimit
        )
        
        return try? await queryDescriptor.result(for: HKHealthStore()) as [HKWorkout]
    }
    
    //Get active calories for a specific date
    public func getActiveMinutes(forDate: Date) async -> Double {
        do {
            return try await getActiveMinutes(within: .init(start: forDate.startOfDay, end: forDate.endOfDay))
        } catch {
            return 0
        }
    }
    
    // Get active calories for a range of dates
    public func getActiveMinutes(within interval: DateInterval) async throws -> Double {
        return try await withUnsafeThrowingContinuation({ (continuation: UnsafeContinuation<Double, Error>) in
            let query = HKActivitySummaryQuery(predicate: self.predicateForSummaryDates(within: interval)) { (query, summaries, error) -> Void in
                
                if let error = error {
                    continuation.resume(throwing: error)
                }
                
                if let activitySummaries = summaries {
                    var minutes = 0.0
                    let exerciseUnit = HKUnit.minute()
                    for summary in activitySummaries {
                        minutes += summary.appleExerciseTime.doubleValue(for: exerciseUnit)
                    }
                    continuation.resume(with: .success(minutes))
                }  else {
                    continuation.resume(with: .success(0)) // todo: see if this is needed
                }
            }
            
            self.myHealthStore.execute(query)
        })
    }
    
    //Get active calories for a specific date
    public func getActiveCalories(for day: Date) async -> Int {
        do {
            let summary = try await getActivitySummaries(within: .init(start: day.startOfDay, end: day.endOfDay))
            return summary.first?.totalCaloriesBurned ?? 0
        } catch {
            return 0
        }
    }
    
    // Get active calories for a range of dates
    public func getActiveCalories(within interval: DateInterval) async throws -> Int {
        try await withUnsafeThrowingContinuation({ (continuation: UnsafeContinuation<Int, Error>) in
            
            let query = HKActivitySummaryQuery(predicate: self.predicateForSummaryDates(within: interval)) { (query, summaries, error) -> Void in
                
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                if let activitySummaries = summaries {
                    var totalCalories = 0.0
                    for summary in activitySummaries {
                        totalCalories += summary.activeEnergyBurned.doubleValue(for: .kilocalorie())
                    }
                    continuation.resume(with: .success(Int(totalCalories)))
                } else {
                    continuation.resume(with: .success(0)) // todo: see if this is needed
                }
            }
            self.myHealthStore.execute(query)
        })
    }
    
    public func getActivitySummaries(within interval: DateInterval) async throws -> [HKActivitySummary] {
        let cacheKey = interval.end < Date() ? interval : nil
        return try await memoize(uniquingWith: cacheKey) {
            return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[HKActivitySummary], Error>) in
                let query = HKActivitySummaryQuery(predicate: self.predicateForSummaryDates(within: interval)) { (query, summaries, error) -> Void in
                    if let error = error {
                        continuation.resume(throwing: error)
                        return
                    }
                    continuation.resume(with: .success(summaries ?? []))
                }
                self.myHealthStore.execute(query)
            }
        }
    }

    //MARK: PRIVATE FUNCTIONS
    
    private func predicateForSummaryDates(within interval: DateInterval) -> NSPredicate? {
        let calender = Calendar.autoupdatingCurrent
        let start = interval.start.startOfDay
        /// The end of the interval can sometimes equal the start of the next day, which should not be counted for this query.
        /// Correct for that by subtracting one second so the interval does not include the next day.
        let end = interval.end.offset(.second, value: -1)!
        
//        let numberOfDays = max(0, calender.dateComponents([.day], from: start, to: end).day!)
//        print("Total days in \(interval): \(numberOfDays)")
        
        var startDay = calender.dateComponents([.year, .month, .day], from: start)
        var endDay = calender.dateComponents([.year, .month, .day], from: max(start, end))
        
        startDay.calendar = calender
        endDay.calendar = calender
        return HKQuery.predicate(forActivitySummariesBetweenStart: startDay, end: endDay)
    }
    
    //Predicate for workouts. Use iOS 16 workout predicate here
    private func createPredicate(date: Date) -> NSPredicate? {
        let calendar = Calendar.autoupdatingCurrent
        
        var dateComponents = calendar.dateComponents([.year, .month, .day],
                                                     from: date)
        dateComponents.calendar = calendar
        
        let predicate = HKQuery.predicateForActivitySummary(with: dateComponents)
        return predicate
    }
    
    
    //Get heart rate as a HKQuantity Sample for a given date range
    public func getHeartRate(within interval: DateInterval) async throws -> [HKQuantitySample] {
        if interval.end.addingTimeInterval(10*60) > Date() {
            /// Heart rate data outside a workout has been observed to take ~5 minutes to deliver from watch to iOS Health store.
            /// Do not cache result if the full result may not be available yet.
            return await HKQuantitySample.fetchHeartRate(within: interval) ?? []
        }
        let cacheKey = interval.end > Date() ? nil : interval
        return await memoize(uniquingWith: cacheKey) {
            let samples = await HKQuantitySample.fetchHeartRate(within: interval)
            return samples ?? []
        }
    }
    
    //Get the time between the first and the last sample and get points per minute
    private func determinePointsFrom(samples: [HKQuantitySample]) -> Double {
        if let firstSample = samples.first, let lastSample = samples.last {
            let timeDifference = abs(firstSample.startDate.timeIntervalSinceReferenceDate - lastSample.startDate.timeIntervalSinceReferenceDate)
            return timeDifference / 60.0
        }
        return 0
    }
    
    public typealias WorkoutProcessor = (HKWorkout) async -> Bool
    
    public func listenForNewHealthWorkouts(processor: @escaping WorkoutProcessor) {
        myHealthStore.enableBackgroundDelivery(for: .workoutType(), frequency: .immediate) { (success, error) in
            if success {
                //                Log.d("[HealthKit Observer] Enabled BG Delivery")
            } else {
                Log.w("[HealthKit Observer] BG Delivery failed to enable!")
            }
            let workoutPredicate = HKQuery.predicateForWorkouts(with: .greaterThanOrEqualTo, duration: 60)
            let observerQuery = HKObserverQuery(sampleType: .workoutType(), predicate: workoutPredicate) { [weak self] (query, completion, error) in
                guard let self = self else {return}
                Task {
                    let auth = try? await HKHealthStore()
                        .statusForAuthorizationRequest(toShare: [], read: [.workoutType()])
                    if auth == .unnecessary {
                        await self.runAnchoredQuery(processor: processor)
                    }
                    completion()
                }
            }
            self.myHealthStore.execute(observerQuery)
        }
    }
    
    public func listenForNewHealthUpdates(types: [(HKSampleType, HKUpdateFrequency)],
                                          block: @escaping ()async->()) {
        for (type, frequency) in types {
            myHealthStore.enableBackgroundDelivery(for: type, frequency: frequency) { _,_ in }
            myHealthStore.execute(HKObserverQuery(sampleType: type, predicate: nil) { (query, completion, error) in
                Task {
                    let auth = try? await HKHealthStore()
                        .statusForAuthorizationRequest(toShare: [], read: [type])
                    if auth == .unnecessary {
                        await block()
                    }
                    completion()
                }
            })
        }
    }
    
    private func runAnchoredQuery(processor: WorkoutProcessor) async {
        let ANCHOR_KEY = "WorkoutsListenerAnchor"
        let health = HKHealthStore()
        var anchor: HKQueryAnchor?
        if let anchorSaved = userDefaults.value(forKey: ANCHOR_KEY) as? Data {
            anchor = try? NSKeyedUnarchiver.unarchivedObject(ofClass: HKQueryAnchor.self, from: anchorSaved)
        }
        let workoutPredicate = HKQuery.predicateForWorkouts(with: .greaterThanOrEqualTo, duration: 60)
        
        let hkPredicate = HKSamplePredicate.sample(type: .workoutType(), predicate: workoutPredicate)
        let descriptor = HKAnchoredObjectQueryDescriptor(predicates: [hkPredicate], anchor: anchor)
        guard let result = try? await descriptor.result(for: health) else {return}
        let anchorData = try? NSKeyedArchiver.archivedData(withRootObject: result.newAnchor as Any, requiringSecureCoding: true)
        userDefaults.set(anchorData, forKey: ANCHOR_KEY)
        
        let deletedWorkouts = result.deletedObjects
        let addedWorkouts = result.addedSamples as? [HKWorkout] ?? []
        let successfulAdditions = await addedWorkouts.asyncMap {
            Log.d("Anchored query update found workout: \($0.uuid.uuidString) from \($0.startDate)")
            return await processor($0)
        }
        Log.d("Added: \(successfulAdditions)")
        Log.d("Deleted: \(deletedWorkouts)")
        
        if successfulAdditions.contains(where: {$0 == true}) || !deletedWorkouts.isEmpty {
            Log.d("Notifying update!")
            await MainActor.run {
                NotificationCenter.default.post(.init(name: .init("WorkoutHistoryUpdate")))
            }
        }
    }
    
    
    /// Get the date on which heart rate was first added to Health
    public func fetchDateOfFirstData() async throws -> Date {
        let typeHeart = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)
        
        return try await withUnsafeThrowingContinuation({ (continuation: UnsafeContinuation<Date, Error>) in
            let query = HKSampleQuery(sampleType: typeHeart, predicate: nil, limit: 1, sortDescriptors: [sort]) { (query, samples, error) in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                if let samples = samples as? [HKQuantitySample], let firstOne = samples.first {
                    continuation.resume(with: .success(firstOne.startDate.startOfDay))
                } else {
                    continuation.resume(with: .success(Date(timeIntervalSinceReferenceDate: 0)))
                }
            }
            myHealthStore.execute(query)
        })
    }

}

public extension HKActivitySummary {
    var totalCaloriesBurned: Int {
        let kCals = activeEnergyBurned.doubleValue(for: .kilocalorie())
        return Int(kCals)
    }
    var caloriesBurnedGoal: Int {
        let kCals = activeEnergyBurnedGoal.doubleValue(for: .kilocalorie())
        return Int(kCals)
    }
    
    var totalMinutesExercised: Int {
        let minutes = appleExerciseTime.doubleValue(for: .minute())
        return Int(minutes)
    }
    @available(watchOS 9.0, *)
    @available(iOS 16.0, *)
    var minutesExercisedGoal: Int {
        guard let minutes = exerciseTimeGoal?.doubleValue(for: .minute()) else {return 0}
        return Int(minutes)
    }
}

private struct DatePair: Hashable {
    let from: Date
    let to: Date
}

#endif

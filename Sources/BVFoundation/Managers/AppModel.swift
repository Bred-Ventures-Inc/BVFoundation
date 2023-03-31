//
//  File.swift
//  
//
//  Created by Krishnaprasad Jagadish on 11/07/22.
//

import Foundation


public class AppModel: ObservableObject {
    public enum FatburnTab: String {
        case Summary
        case Start
        case Learn
        case Settings
    }
    
    public static let shared = AppModel()
    @Published public var activeTab: FatburnTab = .Summary
    
    private init() {
        
    }
}

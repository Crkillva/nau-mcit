//
//  cit693App.swift
//  cit693
//
//  Created by crkillva on 2025-02-11.
//
// 个人保险智能投保顾问iOS应用

import SwiftUI
import SwiftData

@main
struct cit693App: App {
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var consultancyOptions = ConsultancyOptions()
    @StateObject private var formVM = FormVM()
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            User.self, InsuranceProduct.self, InsuranceForm.self, SolutionItem.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
        .environmentObject(authViewModel.setupModelContext(modelContext: sharedModelContainer.mainContext))
        .environmentObject(consultancyOptions)
        .environmentObject(formVM)
    }
}

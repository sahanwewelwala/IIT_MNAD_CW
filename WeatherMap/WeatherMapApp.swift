//
//  WeatherMapApp.swift
//  WeatherMap
//
//  Created by Sahan Wewelwala on 2023-11-24.
//



import SwiftUI

@main
struct WeatherMapApp: App {
    var viewModel = WeatherViewModel()
    init() {
     
        let appearance = UITabBarAppearance()
        appearance.backgroundColor = UIColor(Color.black.opacity(0.8)) // Use your custom color
               UITabBar.appearance().standardAppearance = appearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: viewModel)
                .edgesIgnoringSafeArea(.all)
        }
    }
}

//
//  ContentView.swift
//  WeatherMap
//
//  Created by Sahan Wewelwala on 2023-11-24.
//
//
// ContentView.swift
import SwiftUI

struct ContentView: View {
    @StateObject var viewModel: WeatherViewModel = WeatherViewModel()
    @StateObject private var networkManager = NetworkManager()
    @State private var showAlert = false

    var body: some View {
        
        TabView {
            // First tab for displaying current weather
            WeatherView(viewModel: viewModel)
                .tabItem {
                    Image(systemName: "sun.max.fill")
                    Text("Weather")
                }
                .edgesIgnoringSafeArea(.all)

            // Second tab for displaying weather forecast
            ForecastTab(viewModel: viewModel)
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Forecast")
                }
                .edgesIgnoringSafeArea(.all)

            // Third tab for displaying a map
            MapTab(viewModel: viewModel)
                .tabItem {
                    Image(systemName: "map.fill")
                    Text("Map")
                }
                .edgesIgnoringSafeArea(.all)
        }
        .alert(isPresented: $showAlert) {
            // Show a network error alert if there is no internet connection
            Alert(
                title: Text("Network Error"),
                message: Text("Please check your internet connection and try again."),
                dismissButton: .default(Text("Retry"), action: {
                    if !networkManager.isConnected {
                                            showAlert = true
                    } else {
                        showAlert = false
                    }
                })
            )
        }
        .onAppear {
            // Check for internet connection on app launch
            if !networkManager.isConnected {
                showAlert = true
            }
        }
        .onChange(of: networkManager.isConnected) { newValue in
            // Handle changes in internet connection status
            showAlert = !newValue // Show the alert when connection is lost
        }
        .ignoresSafeArea()
        .cornerRadius(20)
        .foregroundColor(.blue)
        .accentColor(.white)
        .background(.black)
    }
}

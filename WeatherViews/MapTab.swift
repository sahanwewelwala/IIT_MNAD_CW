//
//  MapTab.swift
//  WeatherMap
//
//  Created by Sahan Wewelwala on 2023-12-29.
//
import SwiftUI
import MapKit

struct MapTab: View {
    @ObservedObject var viewModel: WeatherViewModel

    @State private var region = MKCoordinateRegion()
    @State private var locations: [Location] = []
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isActive = false  // Track if the view is currently presented

    var body: some View {
        VStack {
            // Map view with default set to London
            Map(coordinateRegion: $region, annotationItems: locations) { location in
                MapMarker(coordinate: location.coordinates, tint: .blue)
            }
            .cornerRadius(20)
            .onAppear {
                isActive = true  // Mark the view as active
                setDefaultLocation()
                print("MapTab onAppear - Setting default location to London")
                cityChanged(newValue: viewModel.city)
            }
            .onDisappear {
                isActive = false  // Mark the view as inactive
            }
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("No Details Found"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }

            // Description and city name
            Text("Places around \(viewModel.city)")
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity, alignment: .center)
                .background(Color.black)

            // Details view
            ScrollView {
                ForEach(locations) { location in
                    locationView(location)
                }
                .font(.caption2)
                .padding(10)
            }
            .background(Color.black)
        }
        .padding(.bottom, 80)
        .background(Color.black)

        .onChange(of: viewModel.city) { newValue in
            if isActive {
                print("MapTab onChange - City changed to \(newValue)")
                cityChanged(newValue: newValue)
            }
        }
    }

    // Set the default location to London
    private func setDefaultLocation() {
        let londonCoordinates = CLLocationCoordinate2D(latitude: 51.5074, longitude: -0.1278)
        self.region = MKCoordinateRegion(center: londonCoordinates, latitudinalMeters: 5000, longitudinalMeters: 5000)
        print("setDefaultLocation - London coordinates set")
    }

    // Handle city change
    private func cityChanged(newValue: String) {
        print("cityChanged - New City: \(newValue)")
        if let loadedLocations = viewModel.loadLocationsFromJSONFile(cityName: newValue) {
            print("Loaded Locations: \(loadedLocations)")
            self.locations = loadedLocations.filter { $0.cityName == newValue }
            print("Filtered Locations: \(self.locations)")
            if self.locations.isEmpty {
                alertMessage = "Location not available for \(newValue)."
                showingAlert = true
                print("cityChanged - No locations found. Alert set.")
            } else if let firstLocation = self.locations.first {
                region = MKCoordinateRegion(center: firstLocation.coordinates, latitudinalMeters: 5000, longitudinalMeters: 5000)
                print("cityChanged - Updated region to first location of \(newValue)")
            }
        } else {
            alertMessage = "Error loading locations for \(newValue)."
            showingAlert = true
            print("cityChanged - Error loading locations. Alert set.")
        }
    }

    // Create a view for displaying location details
    private func locationView(_ location: Location) -> some View {
        VStack(alignment: .leading) {
            Text(location.name)
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .center)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(location.imageNames, id: \.self) { imageName in
                        Image(imageName)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipped()
                            .cornerRadius(10)
                    }
                }
            }
            Text(location.description)
                .foregroundColor(.white)
                .padding(.top, 10)
        }
        .padding()
        .background(Color.gray.opacity(0.3))
        .cornerRadius(8)
    }
}

// Preview for the MapTab
struct MapTab_Previews: PreviewProvider {
    static var previews: some View {
        MapTab(viewModel: WeatherViewModel())  
    }
}

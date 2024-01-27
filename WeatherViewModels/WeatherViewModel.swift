//
//  WeatherViewModel.swift
//  WeatherMap
//
//  Created by Sahan Wewelwala on 2023-11-24.
//
import Foundation
import CoreLocation

// Create a ViewModel class for managing weather data and interactions
class WeatherViewModel: ObservableObject {
    @Published var weatherData: WeatherDTO?
    @Published var city: String = "London"  // Default city is London
    @Published var formattedDate: String = ""
    @Published var formattedTime: String = ""
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""

    let apiKey = "7ac0db421cf0515587911414b04a79cd"  // Replace with your actual API key

    // Initialize the ViewModel with the default city (London)
    init() {
        print("WeatherViewModel - Initialized with city: \(city)")
        loadWeather(for: city)
    }

    // Load weather data for a given city
    func loadWeather(for newCity: String) {
        DispatchQueue.main.async {
            self.city = newCity
            print("WeatherViewModel - City updated to: \(newCity) on the main thread")
        }
        Task {
            do {
                print("WeatherViewModel - Fetching coordinates for: \(newCity)")
                let coordinates = try await getCoordinates(for: newCity)
                print("WeatherViewModel - Coordinates received: \(coordinates)")
                print("WeatherViewModel - Fetching weather details for: \(newCity) at \(coordinates)")
                await fetchWeatherDetail(lat: coordinates.latitude, lon: coordinates.longitude)
            } catch {
                print("WeatherViewModel - Error fetching coordinates or weather for \(newCity): \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.showAlert = true
                    self.alertMessage = "Location not found: \(newCity)"
                }
            }
        }
    }

    // Fetch weather details using the provided latitude and longitude
    func fetchWeatherDetail(lat: Double, lon: Double) async {
        let urlString = "https://api.openweathermap.org/data/2.5/onecall?lat=\(lat)&lon=\(lon)&exclude=minutely&units=metric&appid=\(apiKey)"
        print("WeatherViewModel - Fetching weather data from: \(urlString)")
        guard let url = URL(string: urlString) else {
            print("WeatherViewModel - Invalid URL")
            return
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            print("WeatherViewModel - Weather data received")
            let decodedData = try JSONDecoder().decode(WeatherDTO.self, from: data)
            DispatchQueue.main.async {
                self.weatherData = decodedData
                print("WeatherViewModel - Weather data updated")
                self.updateDateTime(decodedData.current.dt)
            }
        } catch {
            print("WeatherViewModel - Error fetching weather data: \(error.localizedDescription)")
        }
    }

    // Get coordinates (latitude and longitude) for a given city
    func getCoordinates(for city: String) async throws -> CLLocationCoordinate2D {
        let geocoder = CLGeocoder()
        let placemarks = try await geocoder.geocodeAddressString(city)
        if let location = placemarks.first?.location {
            return location.coordinate
        } else {
            print("WeatherViewModel - Geocoding error for city: \(city)")
            throw GeocodingError.locationNotFound
        }
    }

    // Get the weather icon based on the main weather condition
    func iconForWeatherMain(_ main: String, timezone: String) -> String {
        let currentTime = Date()
        let isNight = currentTime.isNightTime(timezone: timezone)
        switch main {
        case "Thunderstorm": return "ThunderstormIcon"
        case "Clear":  return isNight ? "ClearNightIcon" : "ClearIcon"
        case "Atmosphere": return "AtmosphereIcon"
        case "Clouds": return "CloudsIcon"
        case "Drizzle": return "DrizzleIcon"
        case "Rain": return "RainIcon"
        case "Snow": return "SnowIcon"
        case "Mist": return "MistIcon"
        default: return "defaultIcon"  // Default icon for unhandled conditions
        }
    }

    // Load location data from a JSON file
    func loadLocationsFromJSONFile(cityName: String) -> [Location]? {
        if let fileURL = Bundle.main.url(forResource: "Location", withExtension: "json") {
            do {
                let data = try Data(contentsOf: fileURL)
                let decoder = JSONDecoder()
                let allLocations = try decoder.decode([Location].self, from: data)
                return allLocations
            } catch {
                print("Error decoding JSON: \(error)")
            }
        } else {
            print("File not found")
        }
        return nil
    }

    // Update the formatted date and time based on the timestamp
    private func updateDateTime(_ timestamp: Int) {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: weatherData?.timezone ?? "UTC") // Use the timezone from the API response
        dateFormatter.dateFormat = "E dd MMM"  // Or any format you prefer
        self.formattedDate = dateFormatter.string(from: date)
        dateFormatter.dateFormat = "HH:mm"  // Or any format you prefer
        self.formattedTime = dateFormatter.string(from: date)
        print("WeatherViewModel - Date and time updated to: \(formattedDate) \(formattedTime)")
    }

    enum GeocodingError: Error {
        case locationNotFound
    }
}

//
//  WeatherView.swift
//  WeatherMap
//
//  Created by Sahan Wewelwala on 2023-11-24.
//
import SwiftUI
import Foundation

struct WeatherView: View {
    // Create a view model to manage weather data
    @StateObject var viewModel: WeatherViewModel = WeatherViewModel()
    
    // State variables for various properties
    @State var isSearching: Bool = false
    @State private var showingSearchBar = false
    @State var searchbarLocation = "London"
  
    
    // DateFormatter for formatting date and time
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "E dd MMM HH:mm"  // "Mon 03 JAN 16:17"
        return formatter
    }()
    
    // Background images based on time of day
    let backgroundImages = [
        "Night": "Night",
        "Morning": "Morning",
        "Day": "Day",
        "Evening": "Evening"
    ]
    
    // Function to format hour
    func formatHour(_ timestamp: Int, timezone: String? = nil) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = " h a " // e.g., "1PM", "2AM"

        if let timezone = timezone, let tz = TimeZone(identifier: timezone) {
            dateFormatter.timeZone = tz
        } else {
            dateFormatter.timeZone = .current // User's current time zone
        }

        return dateFormatter.string(from: date)
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack(spacing: 0) {
                    // Check if weather data is available
                    if let weatherData = viewModel.weatherData, let weather = weatherData.current.weather.first {
                        let currentTime = Date(timeIntervalSince1970: TimeInterval(weatherData.current.dt))
                        let timeOfDay = currentTime.getTimeOfDay(timezone: viewModel.weatherData?.timezone ?? "UTC")
                        
                        // Display background image based on time of day
                        Image(backgroundImages[timeOfDay] ?? "DefaultBackground")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geometry.size.width, height: geometry.size.height * 0.55) // 55% of the height
                            .cornerRadius(50)
                            .overlay(
                                VStack {
                                    let icon = viewModel.iconForWeatherDescription(weather.main.rawValue, timezone: viewModel.weatherData?.timezone ?? "UTC")

                                    Image(icon) // Display the weather icon
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 150, height: 150)
                                        .padding(.bottom, 4)
                                    Text(String(format: "%.f°",viewModel.weatherData?.current.temp ?? ""))
                                        .foregroundColor(.white)
                                    Text(weather.description.capitalized) // Display the weather description
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .padding(.bottom, 4)
                                }
                                .background(Color.black.opacity(0.40))
                                .cornerRadius(20)
                                .edgesIgnoringSafeArea(.top)
                            )
                            .overlay(
                                VStack {
                                    HStack {
                                        Text(" \(viewModel.formattedDate)")
                                            .foregroundColor(.white)
                                            .font(.caption)
                                            
                                        Text(" \(viewModel.formattedTime)")
                                            .foregroundColor(.white)
                                            .font(.caption2)
                                            .bold()
                                    }.padding(.top,50)
                                     .padding(.leading,-180)
                                    HStack {
                                        Spacer()
                                        TextField("Search Location", text: $searchbarLocation)
                                            .foregroundColor(.white)
                                            .frame(width: 150)
                                            .background(Color.white.opacity(0.40))
                                            .cornerRadius(5)
                                        Button(action: {
                                            if !searchbarLocation.isEmpty {
                                                Task {
                                                    await viewModel.loadWeather(for: searchbarLocation)
                                                }
                                            }
                                        }) {
                                            Image(systemName: "magnifyingglass")
                                                .resizable()
                                                .frame(width: 20, height: 20)
                                                .padding()
                                                .foregroundColor(.white)
                                        }
                                    }
                                    .padding(.top, -43)
                                    
                                    Spacer()
                                    HStack {
                                        Spacer()
                                        Text(viewModel.weatherData?.timezone ?? "Unknown Location")
                                            .foregroundColor(.white)
                                            .font(.headline)
                                    }
                                }
                                .padding(),
                                alignment: .topLeading
                            )
                            .clipped()
                            .padding(.bottom, 20)
                    }
                    
                    // Horizontal ScrollView for the first row of weather details
                    HStack(spacing: 15) {
                        if let weatherData = viewModel.weatherData {
                            WeatherDetailBoxWithIcon(
                                title: "Temp",
                                value: "\(weatherData.current.temp)",
                                iconName: "temp",
                                iconSize: 30
                            )
                            WeatherDetailBoxWithIcon(
                                title: "Humidity",
                                value: "\(weatherData.current.humidity)%",
                                iconName: "humidity",
                                iconSize: 30
                            )
                            WeatherDetailBoxWithIcon(
                                title: "Wind",
                                value: "\(weatherData.current.windSpeed) km/h",
                                iconName: "wind",
                                iconSize: 30
                            )
                            WeatherDetailBoxWithIcon(
                                title: "Pressure",
                                value: "\(weatherData.current.pressure) hspa",
                                iconName: "pressure",
                                iconSize: 30
                            )
                            // Add more weather details as needed
                        } else {
                            ProgressView() // Shows loading spinner if data is not available
                        }
                    }
                    .frame(width:380,height: 120)
                    .cornerRadius(10)
                    .background(Color.gray.opacity(0.2))
                    .padding(.bottom, 10)
                    
                    // Second row with time-based weather details
                    HStack(spacing: 20) {
                        // Iterate over the first 3 hours of hourly weather data
                        ForEach(Array(viewModel.weatherData?.hourly.prefix(3) ?? []).indices, id: \.self) { index in
                            if let hourlyData = viewModel.weatherData?.hourly[index],
                               let weatherMain = hourlyData.weather.first?.main {
                                
                                let timezone = viewModel.weatherData?.timezone ?? "UTC"
                                let time = formatHour(hourlyData.dt, timezone: timezone)
                                
                                WeatherDetailBoxWithIcon(
                                    title: time,  // Convert the date to a readable format
                                    value: weatherMain.rawValue,       // Use the main weather condition
                                    iconName: viewModel.iconForWeatherDescription(weatherMain.rawValue,timezone: viewModel.weatherData?.timezone ?? "UTC"),
                                    iconSize: 70
                                )
                                .frame(width: geometry.size.width / 3.5, height: geometry.size.height / 9) // Adjust the frame size as needed
                            }
                        }
                    }
                    .padding(.top,25)
                    .padding(.bottom, 25)
                    
                    Spacer()
                }
                .background(Color.black.edgesIgnoringSafeArea(.all))
                .onAppear {
                    Task {
                        await viewModel.loadWeather(for: searchbarLocation)
                    }
                }
            }.alert(isPresented: $viewModel.showAlert) {
                Alert(
                    title: Text("Error"),
                    message: Text(viewModel.alertMessage),
                    dismissButton: .default(Text("OK")) {
                        // Reset alert state after dismissal
                        viewModel.showAlert = false
                        viewModel.alertMessage = ""
                    }
                )
            }
        }
    }
    
    // Create a view for displaying weather details with an icon
    struct WeatherDetailBoxWithIcon: View {
        var title: String
        var value: String
        var iconName: String
        var iconSize: CGFloat
        
        var body: some View {
            ZStack {
                Color.clear
                VStack {
                    Image(iconName)
                        .resizable()
                        .scaledToFit ()
                        .frame(width: iconSize, height: iconSize)
                    Text(title)
                        .foregroundColor(.white)
                        .font(.caption)
                    Text(value)
                        .foregroundColor(.white)
                        .font(.caption)
                        .bold()
                }
                .padding()
            }
            .background(Color.gray.opacity(0.25))
            .cornerRadius(10)
        }
    }
}

// Function to format hour
func formatHour(_ timestamp: Int) -> String {
    let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
    let dateFormatter = DateFormatter()
    dateFormatter.timeZone = .current // User's current time zone
    dateFormatter.locale = NSLocale.current
    dateFormatter.dateFormat = "ha" // e.g., "1PM", "2AM"
    let strDate = dateFormatter.string(from: date)
    return strDate
}

// Extension to get time of day based on hour
extension Date {
    func getTimeOfDay(timezone: String) -> String {
        var calendar = Calendar.current
        if let tz = TimeZone(identifier: timezone) {
            calendar.timeZone = tz
        }
        let hour = calendar.component(.hour, from: self)
        switch hour {
        case 5..<12: return "Morning"
        case 12..<17: return "Day"
        case 17..<21: return "Evening"
        default: return "Night"
        }
    }
}
extension Date {
    func isNightTime(timezone: String) -> Bool {
        var calendar = Calendar.current
        if let tz = TimeZone(identifier: timezone) {
            calendar.timeZone = tz
        }
        let hour = calendar.component(.hour, from: self)
        return hour >= 18 || hour < 5 || (hour == 5 && calendar.component(.minute, from: self) < 30)
    }
}

// Extension to get weather icon based on weather description
extension WeatherViewModel {
    func iconForWeatherDescription(_ main: String, timezone: String) -> String {
            let currentTime = Date()
            let isNight = currentTime.isNightTime(timezone: timezone)

            switch main {
            case "Clear":
                return isNight ? "ClearNightIcon" : "ClearIcon"
            case "Thunderstorm":
                return "ThunderstormIcon"
            case "Atmosphere":
                return "AtmosphereIcon"
            case "Clouds":
                return "CloudsIcon"
            case "Drizzle":
                return "DrizzleIcon"
            case "Rain":
                return "RainIcon"
            case "Snow":
                return "SnowIcon"
            case "Mist":
                return "MistIcon"
            default:
                return "defaultIcon"
            }
        }
}

// Preview for the WeatherView
struct WeatherView_Previews: PreviewProvider {
    static var previews: some View {
        WeatherView()
    }
}

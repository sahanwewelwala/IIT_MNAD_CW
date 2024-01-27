//
//  ForecastTab.swift
//  WeatherMap
//
//  Created by Sahan Wewelwala on 2023-12-25.
//

import SwiftUI

// Create a view for displaying the weather forecast tab
struct ForecastTab: View {
    @ObservedObject var viewModel: WeatherViewModel
    @State private var showingHourly = true

    // Background images based on time of day
    let backgroundImages = [
        "Night": "Night",
        "Morning": "Morning",
        "Day": "Day",
        "Evening": "Evening"
    ]

    var body: some View {
        VStack {
            GeometryReader { geometry in
                ZStack {
                    VStack(spacing: 0) {
                        if let weatherData = viewModel.weatherData, let weather = weatherData.current.weather.first {
                            let currentTime = Date(timeIntervalSince1970: TimeInterval(weatherData.current.dt))
                            let timeOfDay = currentTime.getTimeOfDay(timezone: viewModel.weatherData?.timezone ?? "UTC")
                            let icon = viewModel.iconForWeatherMain(weather.main.rawValue, timezone: viewModel.weatherData?.timezone ?? "UTC")

                            // Display background image based on time of day
                            Image(backgroundImages[timeOfDay] ?? "DefaultBackground")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: geometry.size.width, height: geometry.size.height * 0.55)
                                .cornerRadius(50)
                                .overlay(
                                    VStack {
                                        let icon = viewModel.iconForWeatherMain(weather.main.rawValue, timezone: viewModel.weatherData?.timezone ?? "UTC")
                                        Image(icon)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 150, height: 150)
                                            .padding(.bottom, 4)
                                        Text(String(format: "%.f°", viewModel.weatherData?.current.temp ?? ""))
                                            .foregroundColor(.white)
                                        Text(weather.description.capitalized)
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
                                        }.padding(.top, 50)
                                        .padding(.leading, -180)
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
                                .background(.black)
                                .clipped()
                                .padding(.bottom, 0)
                        }

                        VStack {
                            ToggleButtonView(showingHourly: $showingHourly)
                            if showingHourly {
                                HourlyForecastView(hourlyData: viewModel.weatherData?.hourly ?? [], viewModel: viewModel, timezone: viewModel.weatherData?.timezone ?? "UTC")
                            } else {
                                DailyForecastView(dailyData: viewModel.weatherData?.daily ?? [], viewModel: viewModel, timezone: viewModel.weatherData?.timezone ?? "UTC")
                            }
                        }
                    }
                }.background(.black)
            }
        }
    }
}

// Create a view for displaying hourly weather forecast
struct HourlyForecastView: View {
    var hourlyData: [WeatherDTO.Hourly]
    var viewModel: WeatherViewModel
    var timezone: String

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 20) {
                ForEach(Array(hourlyData.prefix(48)), id: \.dt) { hour in
                    HourlyWeatherCard(hour: hour, timezone: timezone, viewModel: viewModel)
                }
            }
        }.padding(.bottom, 85)
    }
}

// Create a view for displaying hourly weather forecast card
struct HourlyWeatherCard: View {
    var hour: WeatherDTO.Hourly
    var timezone: String
    var viewModel: WeatherViewModel
    
    var body: some View {
        HStack {
            Text(hour.formattedHour(timezone: timezone))
                .font(.headline)
                .bold()
                .foregroundColor(.white)
                .padding(.leading, 20)
            Image(viewModel.iconForWeatherMain(hour.weather.first?.main.rawValue ?? "",timezone: viewModel.weatherData?.timezone ?? "UTC"))
                .resizable()
                .scaledToFit()
                .frame(width: 70, height: 70)
            Text("\(Int(hour.temp))°")
                .font(.title)
                .foregroundColor(.white)
            Spacer()
            Text(hour.weather.first?.description ?? "Clear")
                .font(.caption)
                .foregroundColor(.white)
                .padding(.trailing, 20)
        }
        .frame(width: 350, height: 70)
        .background(Color.gray.opacity(0.3))
        .cornerRadius(10)
    }
}

// Create a view for displaying a toggle button
struct ToggleButtonView: View {
    @Binding var showingHourly: Bool
    
    var body: some View {
        HStack {
            Button("Hourly") {
                showingHourly = true
            }
            .foregroundColor(showingHourly ? .white : .gray)
            
            Button("Daily") {
                showingHourly = false
            }
            .foregroundColor(!showingHourly ? .white : .gray)
        }
        .padding()
    }
}

// Create a view for displaying daily weather forecast
struct DailyForecastView: View {
    var dailyData: [WeatherDTO.Daily]
    var viewModel: WeatherViewModel
    var timezone: String

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 20) {
                ForEach(Array(dailyData.prefix(7)), id: \.dt) { day in
                    DailyWeatherCard(day: day, timezone: timezone, viewModel: viewModel)
                }
            }
        }.padding(.bottom, 85)
    }
}

// Create a view for displaying daily weather forecast card
struct DailyWeatherCard: View {
    var day: WeatherDTO.Daily
    var timezone: String
    var viewModel: WeatherViewModel
    
    var body: some View {
        HStack {
            Text(day.formattedDate(timezone: timezone))
                .font(.headline)
                .bold()
                .foregroundColor(.white)
                .padding(.leading, 20)
            Image(viewModel.iconForWeatherMain(day.weather.first?.main.rawValue ?? "",timezone: viewModel.weatherData?.timezone ?? "UTC"))
                .resizable()
                .scaledToFit()
                .frame(width: 70, height: 70)
            Text("\(Int(day.temp.day))°")
                .font(.title)
                .foregroundColor(.white)
            Spacer()
            Text(day.weather.first?.description ?? "Clear")
                .font(.caption)
                .foregroundColor(.white)
                .padding(.trailing, 20)
        }
        .frame(width: 350, height: 70)
        .background(Color.gray.opacity(0.3))
        .cornerRadius(10)
    }
}

// Extensions

extension WeatherDTO.Daily {
    func formattedDate(timezone: String) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(self.dt))
        let formatter = DateFormatter()
        formatter.dateFormat = "E dd"  // Example format: "Wed 18"
        if let tz = TimeZone(identifier: timezone) {
            formatter.timeZone = tz
        }
        return formatter.string(from: date)
    }
}

extension WeatherDTO.Hourly {
    func formattedHour(timezone: String) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(self.dt))
        let formatter = DateFormatter()
        formatter.dateFormat = "h a"  // Example format: "4 PM"
        if let tz = TimeZone(identifier: timezone) {
            formatter.timeZone = tz
        }
        return formatter.string(from: date)
    }
}

// Preview for the ForecastTab
struct ForecastTab_Previews: PreviewProvider {
    static var previews: some View {
        ForecastTab(viewModel: WeatherViewModel())
    }
}

//
//  WeatherDTO.swift
//  WeatherMap
//
//  Created by Sahan Wewelwala on 2023-11-24.
//

import Foundation

struct WeatherDTO : Codable {
    let lat : Double
    let lon: Double
    let timezone: String
    let timezoneOffset: Int?
    let current: Current
    let hourly: [Hourly]
    let daily: [Daily]
    
    struct Hourly: Codable {
        let dt: Int
        let temp: Double
        let weather: [Weather]
    }
    
    
    enum CodingKeys: String, CodingKey {
        case lat, lon, timezone, timezoneOffset, current, hourly , daily
        
    }
    
    
    // MARK: - Current
    struct Current: Codable {
        let dt: Int
        let sunrise, sunset: Int
        let temp, feelsLike: Double
        let pressure, humidity: Int
        let dewPoint, uvi: Double
        let clouds, visibility: Int
        let windSpeed: Double
        let windDeg: Int
        var windGust: Double?
        let weather: [Weather]
        let pop: Double?
        
        enum CodingKeys: String, CodingKey {
            case dt, sunrise, sunset, temp
            case feelsLike = "feels_like"
            case pressure, humidity
            case dewPoint = "dew_point"
            case uvi, clouds, visibility
            case windSpeed = "wind_speed"
            case windDeg = "wind_deg"
            case windGust = "wind_gust"
            case weather, pop
        }
    }
    
    // MARK: - Weather
    struct Weather: Codable {
        let id: Int
        let main: Main
        let description: String
        let icon: String
    }
    
    enum Description: String, Codable {
        case brokenClouds = "broken clouds"
        case clearSky = "clear sky"
        case fewClouds = "few clouds"
        case moderateRain = "moderate rain"
        case overcastClouds = "overcast clouds"
        case scatteredClouds = "scattered clouds"
        case lightRain = "light rain"
        
        
    }
    
    enum Main: String, Codable {
        case clear = "Clear"
        case clouds = "Clouds"
        case rain = "Rain"
        case thunderstorm = "Thunderstorm"
        case atmosphere = "Atmosphere"
        case drizzle = "Drizzle"
        case snow = "Snow"
        case mist = "Mist"
        
    }
    
    // MARK: - Daily
    struct Daily: Codable {
        let dt, sunrise, sunset, moonrise: Int
        let moonset: Int
        let moonPhase: Double
        let summary: String?
        let temp: Temp
        let feelsLike: FeelsLike
        let pressure, humidity: Int
        let dewPoint, windSpeed: Double
        let windDeg: Int
        let windGust: Double
        let weather: [Weather]
        let clouds: Int
        let pop, uvi: Double
        let rain: Double?
        
        enum CodingKeys: String, CodingKey {
            case dt, sunrise, sunset, moonrise, moonset
            case moonPhase = "moon_phase"
            case summary, temp
            case feelsLike = "feels_like"
            case pressure, humidity
            case dewPoint = "dew_point"
            case windSpeed = "wind_speed"
            case windDeg = "wind_deg"
            case windGust = "wind_gust"
            case weather, clouds, pop, uvi, rain
        }
    }
    
  


          
    
    // MARK: - FeelsLike
    struct FeelsLike: Codable {
        let day, night, eve, morn: Double
    }
    
    // MARK: - Temp
    struct Temp: Codable {
        let day, min, max, night: Double
        let eve, morn: Double
    }
    
    // MARK: - Minutely
    struct Minutely: Codable {
        let dt, precipitation: Int
    }
}

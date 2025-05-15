import Foundation
import WeatherKit
import CoreLocation

// This struct wraps the important weather data we'll display in the app.
struct WeatherData: Identifiable {
let id = UUID()
let city: String
let temperature: Double
let condition: String
let icon: String
}

// OpenWeatherMap API Response Models
// Models/OpenWeatherResponse.swift

/// Top‐level response from OpenWeatherMap’s “current weather” API
struct OpenWeatherResponse: Codable {
    /// City name
    let name: String
    
    /// Main weather data (temperature, etc.)
    let main: MainWeather
    
    /// Array of weather conditions (usually one element)
    let weather: [Weather]
    
    /// Convert into your app’s simpler WeatherData model
    func toWeatherData() -> WeatherData {
        let condition = weather.first?.description.capitalized ?? "N/A"
        let iconCode  = weather.first?.icon          ?? "01d"
        
        return WeatherData(
            city:        name,
            temperature: main.temp,
            condition:   condition,
            icon:        iconCode
        )
    }
}

/// Contents of the “main” object in the JSON
struct MainWeather: Codable {
    /// Temperature in the units you requested (e.g. imperial → °F)
    let temp: Double
    // Removed `icon` – OpenWeatherMap does not return an “icon” key here.
}

/// One element of the “weather” array in the JSON
struct Weather: Codable {
    /// Textual description, e.g. “Scattered Clouds”
    let description: String
    
    /// Icon code, e.g. “03d”
    let icon: String
}


//struct MainWeather: Codable {
//    let temp: Double
//}
//
//struct Weather: Codable {
//    let description: String
//    let icon: String
//}

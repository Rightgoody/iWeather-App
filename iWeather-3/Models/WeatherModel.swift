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
struct OpenWeatherResponse: Codable {
    let name: String
    let main: MainWeather
    let weather: [Weather]
    
    // Add conversion directly in the struct
    func toWeatherData() -> WeatherData {
        return WeatherData(
            city: self.name,
            temperature: self.main.temp,
            condition: self.weather.first?.description.capitalized ?? "N/A",
            icon: self.weather.first?.icon ?? "01d"
        )
    }
}

struct MainWeather: Codable {
    let temp: Double
    let icon: String
}

struct Weather: Codable {
    let description: String
    let icon: String
}

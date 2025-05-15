import Foundation

struct SavedCityWeather: Identifiable {
    let id = UUID()
    let cityName: String
    let tag: String?
    let currentTime: Date
    let temperature: Double
    let weatherDescription: String
    let highTemp: Double
    let lowTemp: Double
    let weatherIcon: String
    
    static let mockData: [SavedCityWeather] = [
        SavedCityWeather(
            cityName: "San Francisco",
            tag: "My Location",
            currentTime: Date(),
            temperature: 68,
            weatherDescription: "Partly Cloudy",
            highTemp: 72,
            lowTemp: 62,
            weatherIcon: "cloud.sun.fill"
        ),
        SavedCityWeather(
            cityName: "New York",
            tag: "Work",
            currentTime: Date(),
            temperature: 75,
            weatherDescription: "Sunny",
            highTemp: 78,
            lowTemp: 68,
            weatherIcon: "sun.max.fill"
        ),
        SavedCityWeather(
            cityName: "London",
            tag: nil,
            currentTime: Date(),
            temperature: 58,
            weatherDescription: "Light Rain",
            highTemp: 62,
            lowTemp: 54,
            weatherIcon: "cloud.rain.fill"
        ),
        SavedCityWeather(
            cityName: "Tokyo",
            tag: "Vacation",
            currentTime: Date(),
            temperature: 82,
            weatherDescription: "Clear",
            highTemp: 85,
            lowTemp: 75,
            weatherIcon: "sun.max.fill"
        ),
        SavedCityWeather(
            cityName: "Paris",
            tag: nil,
            currentTime: Date(),
            temperature: 65,
            weatherDescription: "Mostly Cloudy",
            highTemp: 70,
            lowTemp: 60,
            weatherIcon: "cloud.fill"
        )
    ]
} 
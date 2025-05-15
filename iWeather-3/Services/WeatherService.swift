import Foundation
import CoreLocation
import WeatherKit


/// Service responsible for fetching weather data from external APIs
class WeatherServiceManager {
    private let apiKey = "ea53bd41a55a7f295942ddeac5f42d3f"

    // Fetch weather by city name (manual entry)
    // Updated to handle coordinate-based requests
    private func fetchWeatherData(from urlString: String) async throws -> WeatherData {
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.cannotParseResponse)
        }
        
        guard httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        return try JSONDecoder().decode(OpenWeatherResponse.self, from: data).toWeatherData()
    }

    func fetchWeather(for city: String) async throws -> WeatherData {
        let query = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? city
        let urlString = "https://api.openweathermap.org/data/2.5/weather?q=\(query)&appid=\(apiKey)&units=imperial"
        return try await fetchWeatherData(from: urlString)
    }

    func fetchWeather(latitude: Double, longitude: Double) async throws -> WeatherData {
        let urlString = "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&appid=\(apiKey)&units=imperial"
        return try await fetchWeatherData(from: urlString)
    }
}

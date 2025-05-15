import Foundation

class ForecastService {
    private let apiKey = "ea53bd41a55a7f295942ddeac5f42d3f"
    private let baseURL = "https://api.openweathermap.org/data/2.5/forecast"
    
    func fetchForecast(for city: String) async throws -> [ForecastEntry] {
        let urlString = "\(baseURL)?q=\(city)&appid=\(apiKey)&units=imperial"
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        struct ForecastResponse: Codable {
            let list: [ForecastItem]
            
            struct ForecastItem: Codable {
                let dt: TimeInterval
                let main: Main
                let weather: [Weather]
                
                struct Main: Codable {
                    let temp: Double
                }
                
                struct Weather: Codable {
                    let description: String
                    let icon: String
                }
            }
        }
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(ForecastResponse.self, from: data)
        
        let entries: [ForecastEntry] = decoded.list.enumerated().compactMap { index, item in
            // every 8th item represents ~24 hours
            guard index % 8 == 0 else { return nil }
            
            return ForecastEntry(
                date: Date(timeIntervalSince1970: item.dt),
                temperature: item.main.temp,
                condition: item.weather.first?.description ?? "",
                icon: item.weather.first?.icon ?? ""
            )
        }
        
        print("Decoded forecast count: \(entries.count)")
        return entries
    }
}

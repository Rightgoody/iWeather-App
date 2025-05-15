import Foundation

struct ForecastEntry: Identifiable {
    let id = UUID()
    let date: Date
    let temperature: Double
    let condition: String
    let icon: String
}

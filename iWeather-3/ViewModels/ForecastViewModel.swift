import Foundation

@MainActor
class ForecastViewModel: ObservableObject {
    @Published var forecast: [ForecastEntry] = []
    @Published var isLoading = true
    @Published var errorMessage: String?
    
    private let city: String
    private let forecastService = ForecastService()
    
    init(city: String) {
        self.city = city
        Task {
            await fetchForecast()
        }
    }
    
    private func fetchForecast() async {
        do {
            forecast = try await forecastService.fetchForecast(for: city)
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
}

import Foundation
import CoreLocation
import SwiftUI

/// ViewModel responsible for managing weather data and business logic
@MainActor
class WeatherViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var weatherData: WeatherData?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let weatherService = WeatherServiceManager()
    private let locationManager = CLLocationManager()

    override init() {
        super.init()
        locationManager.delegate = self
    }

    // MARK: - Location Permission

    func requestLocation() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }

    // Called when location is updated
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        Task {
            await fetchWeather(for: location)
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            self.errorMessage = "Failed to get location: \(error.localizedDescription)"
        }
    }

    // MARK: - Fetch Weather

    func fetchWeather(for location: CLLocation) async {
        isLoading = true
        do {
            let placemark = try await CLGeocoder().reverseGeocodeLocation(location).first
            let city = placemark?.locality ?? "Unknown"
            weatherData = try await weatherService.fetchWeather(for: city)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func fetchWeather(for city: String) async {
        isLoading = true
        do {
            weatherData = try await weatherService.fetchWeather(for: city)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}

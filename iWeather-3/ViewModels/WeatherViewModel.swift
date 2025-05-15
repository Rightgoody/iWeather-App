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

    // Inside WeatherViewModel, as it conforms to CLLocationManagerDelegate
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        if status == .denied || status == .restricted {
            Task { @MainActor in
                self.errorMessage = "Location access was denied. Please enable permissions in Settings or enter a city manually."
            }
        } else if status == .authorizedWhenInUse || status == .authorizedAlways {
            manager.requestLocation()  // now safe to request location
        }
    }

    
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
            errorMessage = nil  // clear any previous error
        } catch let urlError as URLError {
            if urlError.code == .badServerResponse {
                errorMessage = "City not found. Please try another city."
            } else {
                errorMessage = "Network error: \(urlError.localizedDescription)"
            }
        } catch {
            errorMessage = "Failed to get weather: \(error.localizedDescription)"
        }
        isLoading = false
    }

}

import SwiftUI
import CoreLocation

struct SavedCitiesView: View {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var viewModel = WeatherViewModel()
    @State private var manualCity = ""
    @AppStorage("useCelsius") private var useCelsius = false
    @AppStorage("isDarkMode") private var isDarkMode = false
    let cities: [SavedCityWeather] = SavedCityWeather.mockData
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Search Section (Always Visible)
                VStack(spacing: 16) {
                    TextField("Enter city name", text: $manualCity)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    
                    Button(action: {
                        Task {
                            let searchCity = manualCity.trimmingCharacters(in: .whitespacesAndNewlines)
                            await viewModel.fetchWeather(for: searchCity)
                            // Only clear if the search was successful and matches
                            if let weather = viewModel.weatherData,
                               weather.city.lowercased() == searchCity.lowercased() {
                                manualCity = ""
                            }
                        }
                    }) {
                        Text("Search")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.systemGray6))
                            .foregroundColor(.primary)
                            .cornerRadius(12)
                    }
                    .disabled(manualCity.isEmpty)
                    .padding(.horizontal)
                    
                    Button(action: {
                        Task {
                            await viewModel.requestLocation()
                        }
                    }) {
                        HStack {
                            Image(systemName: "location.circle.fill")
                            Text("Use My Location")
                        }
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemBlue).opacity(0.2))
                        .foregroundColor(.blue)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                }
                
                // Current Weather Section
                if viewModel.isLoading {
                    ProgressView("Loading weather...")
                } else if let weather = viewModel.weatherData {
                    VStack(spacing: 8) {
                        VStack(spacing: 8) {
                            Text(weather.city)
                                .font(.headline)
                                .bold()
                            Text("\(formatTemperature(weather.temperature))°")
                                .font(.system(size: 36))
                            Text(weather.condition)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            if let iconURL = URL(string: "https://openweathermap.org/img/wn/\(weather.icon)@2x.png") {
                                AsyncImage(url: iconURL) { image in
                                    image.resizable()
                                         .scaledToFit()
                                         .frame(width: 50, height: 50)
                                } placeholder: {
                                    ProgressView()
                                }
                            }
                        }
                        .padding(12)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .shadow(color: Color.primary.opacity(0.1), radius: 2, x: 0, y: 1)
                    }
                } else {
                    // No data warning
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.orange)
                        
                        VStack(spacing: 8) {
                            Text("No weather data available")
                                .font(.title3)
                                .bold()
                            Text("Enter a city name or use your location")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                }
                
                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                }
                
                // Saved Cities Section
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(cities) { city in
                            SavedCityCard(city: city, useCelsius: useCelsius)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
            .navigationTitle("Home")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        withAnimation {
                            isDarkMode.toggle()
                        }
                    } label: {
                        Image(systemName: isDarkMode ? "sun.max.fill" : "moon.fill")
                            .foregroundColor(.primary)
                    }
                }
            }
            .alert("Location Access Required", isPresented: $viewModel.showLocationDeniedAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Settings") {
                    if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(settingsURL)
                    }
                }
            } message: {
                Text("Location permission is denied. Please enable it in Settings.")
            }
        }
    }
    
    private func formatTemperature(_ fahrenheit: Double) -> Int {
        if useCelsius {
            return Int((fahrenheit - 32) * 5/9)
        }
        return Int(fahrenheit)
    }
}

struct SavedCityCard: View {
    let city: SavedCityWeather
    let useCelsius: Bool
    
    var body: some View {
        ZStack {
            // Background with gradient
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(.systemBackground),
                            Color(.systemBackground).opacity(0.95)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .shadow(color: Color.primary.opacity(0.1), radius: 10, x: 0, y: 5)
            
            // Weather icon background effect
            Image(systemName: city.weatherIcon)
                .font(.system(size: 100))
                .foregroundColor(Color.primary.opacity(0.1))
                .offset(x: 120, y: -20)
            
            // Content
            VStack(alignment: .leading, spacing: 12) {
                // City name and tag
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(city.cityName)
                            .font(.title2)
                            .bold()
                        
                        if let tag = city.tag {
                            Text(tag)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    // Current time
                    Text(city.currentTime.formatted(.dateTime.hour().minute()))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Divider()
                
                // Temperature and weather
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(formatTemperature(city.temperature))°")
                            .font(.system(size: 44, weight: .medium))
                        
                        Text(city.weatherDescription)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // High/Low temperatures
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("H: \(formatTemperature(city.highTemp))°")
                            .font(.headline)
                        Text("L: \(formatTemperature(city.lowTemp))°")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
        }
    }
    
    private func formatTemperature(_ fahrenheit: Double) -> Int {
        if useCelsius {
            return Int((fahrenheit - 32) * 5/9)
        }
        return Int(fahrenheit)
    }
}

#Preview {
    SavedCitiesView()
} 

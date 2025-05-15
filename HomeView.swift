import SwiftUI
import CoreLocation

/// Main view displaying current weather information
struct HomeView: View {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var viewModel = WeatherViewModel()
    @State private var manualCity = ""
    @AppStorage("isDarkMode") private var isDarkMode = false

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
                
                // Weather Data Section
                if viewModel.isLoading {
                    ProgressView("Loading weather...")
                } else if let weather = viewModel.weatherData {
                    VStack(spacing: 16) {
                        VStack(spacing: 10) {
                            Text(weather.city)
                                .font(.largeTitle)
                                .bold()
                            Text("\(Int(weather.temperature))°")
                                .font(.system(size: 64))
                            Text(weather.condition)
                                .font(.title2)
                            if let iconURL = URL(string: "https://openweathermap.org/img/wn/\(weather.icon)@2x.png") {
                                AsyncImage(url: iconURL) { image in
                                    image.resizable()
                                         .scaledToFit()
                                         .frame(width: 80, height: 80)
                                } placeholder: {
                                    ProgressView()
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(16)
                        .shadow(color: Color.primary.opacity(0.1), radius: 5, x: 0, y: 2)
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
                
                Spacer()
            }
            .padding()
            .navigationTitle("iWeather")
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
        }
    }
}

#Preview {
    HomeView()
}

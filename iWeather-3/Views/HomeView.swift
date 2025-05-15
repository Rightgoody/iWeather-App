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
                if viewModel.isLoading {
                    ProgressView("Loading weather...")
                } else if let weather = viewModel.weatherData {
                    // Weather data view
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
                } else {
                    // No data view
                    VStack(spacing: 32) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.orange)
                        
                        VStack(spacing: 8) {
                            Text("No weather data available")
                                .font(.title2)
                                .bold()
                            Text("Try entering a city or use your location")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        TextField("e.g. New York, London", text: $manualCity)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                        
                        Button(action: {
                            Task {
                                await viewModel.fetchWeather(for: manualCity)
                            }
                        }) {
                            Text("Search")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.accentColor)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal)
                        .disabled(manualCity.isEmpty)
                        
                        Button(action: {
                            Task {
                                await viewModel.requestLocation()
                            }
                        }) {
                            Label("Use My Location", systemImage: "location.circle.fill")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.accentColor.opacity(0.2))
                                .cornerRadius(10)
                        }
                        .padding(.horizontal)
                    }
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

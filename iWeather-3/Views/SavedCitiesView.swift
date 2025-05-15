import SwiftUI

struct SavedCitiesView: View {
    @AppStorage("useCelsius") private var useCelsius = false
    let cities: [SavedCityWeather] = SavedCityWeather.mockData
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(cities) { city in
                        SavedCityCard(city: city, useCelsius: useCelsius)
                    }
                }
                .padding()
            }
            .navigationTitle("Saved Cities")
            .background(Color(.systemGroupedBackground))
        }
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
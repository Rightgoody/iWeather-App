import SwiftUI

struct ForecastScreen: View {
    let city: String
    @StateObject private var viewModel: ForecastViewModel
    @State private var hasAppeared = false
    
    init(city: String) {
        self.city = city
        self._viewModel = StateObject(wrappedValue: ForecastViewModel(city: city))
    }
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading forecast...")
                } else if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                } else if !viewModel.forecast.isEmpty {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(Array(viewModel.forecast.enumerated()), id: \.element.id) { index, entry in
                                ForecastCard(entry: entry)
                                    .transition(.opacity.combined(with: .slide))
                                    .animation(.easeOut(duration: 0.3).delay(Double(index) * 0.05), value: hasAppeared)
                            }
                        }
                        .padding()
                    }
                } else {
                    Text("No forecast available")
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("\(city) Forecast")
            .onAppear {
                // Trigger animation only on first appearance
                if !hasAppeared {
                    hasAppeared = true
                }
            }
        }
    }
}

struct ForecastCard: View {
    let entry: ForecastEntry
    
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            // Date section
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.date.formatted(.dateTime.weekday(.abbreviated)))
                    .font(.headline)
                Text(entry.date.formatted(.dateTime.month().day()))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(width: 80, alignment: .leading)
            
            Spacer()
            
            // Temperature and condition
            VStack(alignment: .center, spacing: 4) {
                Text("\(Int(entry.temperature))°")
                    .font(.title2)
                    .bold()
                Text(friendlyDescription(entry.condition))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Weather icon
            Image(systemName: weatherIcon(for: entry.condition))
                .font(.title)
                .foregroundColor(.accentColor)
                .frame(width: 40)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.primary.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    private func friendlyDescription(_ condition: String) -> String {
        let condition = condition.lowercased()
        switch condition {
        case "broken clouds":
            return "Mostly Cloudy"
        case "scattered clouds":
            return "Partly Cloudy"
        case "clear sky":
            return "Sunny"
        case "few clouds":
            return "Fair"
        case "overcast clouds":
            return "Cloudy"
        default:
            return condition.capitalized
        }
    }
    
    private func weatherIcon(for condition: String) -> String {
        let condition = condition.lowercased()
        switch condition {
        case let c where c.contains("clear"):
            return "sun.max.fill"
        case let c where c.contains("cloud"):
            return "cloud.sun.fill"
        case let c where c.contains("rain"):
            return "cloud.rain.fill"
        case let c where c.contains("snow"):
            return "cloud.snow.fill"
        case let c where c.contains("thunder"):
            return "cloud.bolt.fill"
        case let c where c.contains("fog") || c.contains("mist"):
            return "cloud.fog.fill"
        default:
            return "cloud.fill"
        }
    }
}

#Preview {
    ForecastScreen(city: "Cupertino")
}

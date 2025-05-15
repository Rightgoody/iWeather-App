import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                .tag(0)
            
            MapScreen()
                .tabItem {
                    Label("Map", systemImage: "map")
                }
                .tag(1)
            
            ForecastScreen(city: "Cupertino")
                .tabItem {
                    Label("Forecast", systemImage: "cloud.sun")
                }
                .tag(2)
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
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

#Preview {
    MainTabView()
}

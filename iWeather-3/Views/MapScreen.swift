import SwiftUI
import MapKit

struct MapScreen: View {
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var userLocation: CLLocationCoordinate2D?
    
    var body: some View {
        NavigationView {
            Map(position: $position, interactionModes: [.all]) {
                if let location = userLocation {
                    Annotation("My Location", coordinate: location) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.title)
                            .foregroundColor(.red)
                    }
                }
            }
            .mapControls {
                MapUserLocationButton()
            }
            .ignoresSafeArea(edges: .top)
            .navigationTitle("Map")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                // Request location permission and update userLocation
                let locationManager = CLLocationManager()
                locationManager.requestWhenInUseAuthorization()
                
                if let location = locationManager.location?.coordinate {
                    userLocation = location
                }
            }
        }
    }
}

#Preview {
    MapScreen()
}

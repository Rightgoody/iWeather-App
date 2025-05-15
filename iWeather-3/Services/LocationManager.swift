import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var authorizationStatus: CLAuthorizationStatus
    @Published var currentLocation: CLLocation?
    @Published var error: Error?
    
    override init() {
        self.authorizationStatus = manager.authorizationStatus
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    }
    
    // Call this to prompt the permission dialog
    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }
    
    // Call this to actually get one location update (once authorized)
    func requestLocation() {
        manager.requestLocation()
    }
    
    // Delegate: monitor auth changes
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways {
            // Permission granted, we can request location now
            manager.requestLocation()
        } else if authorizationStatus == .denied {
            // Permission denied – we can handle that if needed
            DispatchQueue.main.async {
                // Perhaps notify the ViewModel or set an error message
            }
        }
    }
    
    // Delegate: got an updated location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.first
    }
    
    // Delegate: error occurred (e.g. no permission or unable to get location)
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.error = error
    }
}

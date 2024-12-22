import Foundation
import CoreLocation
import SwiftUI

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var location: CLLocationCoordinate2D?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var locationError: LocationError?
    
    private let locationManager = CLLocationManager()
    
    enum LocationError: LocalizedError, Identifiable {
        case accessDenied
        case locationDisabled
        case updateFailed
        
        var id: String {
            switch self {
            case .accessDenied: return "accessDenied"
            case .locationDisabled: return "locationDisabled"
            case .updateFailed: return "updateFailed"
            }
        }
        
        var errorDescription: String? {
            switch self {
            case .accessDenied:
                return "位置访问被拒绝"
            case .locationDisabled:
                return "位置服务已禁用"
            case .updateFailed:
                return "位置更新失败"
            }
        }
    }
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10 // 10米更新一次
    }
    
    func requestAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last?.coordinate else { return }
        self.location = location
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationError = .updateFailed
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
            locationError = nil
        case .denied:
            locationError = .accessDenied
        case .restricted:
            locationError = .locationDisabled
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        @unknown default:
            break
        }
    }
} 

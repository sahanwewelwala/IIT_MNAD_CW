//
//  NetworkManager.swift
//  WeatherMap
//
//  Created by Sahan Wewelwala on 2024-01-03.
//

import Network
import SwiftUI 
class NetworkManager: ObservableObject {
    let monitor = NWPathMonitor()
    let queue = DispatchQueue(label: "NetworkMonitor")
    @Published var isConnected: Bool = true  // Now it should recognize @Published

    init() {
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                self.isConnected = path.status == .satisfied
            }
        }
        monitor.start(queue: queue)
    }
}


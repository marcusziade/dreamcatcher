import HealthKit
import SwiftUI

struct ContentView: View {
    @State private var isAuthorized = false
    @State private var totalSleepInterval = TimeInterval()

    var body: some View {
        Group {
            if isAuthorized {
                VStack {
                    Text("Authorized")
                        .font(.title)
                        .foregroundStyle(.green)
                    Text(
                        "Total sleep: \(totalSleepInterval / 3600, specifier: "%.0f") hours \(totalSleepInterval.truncatingRemainder(dividingBy: 3600) / 60, specifier: "%.0f") minutes"
                    )
                    .font(.title2)
                    .foregroundStyle(.secondary)
                }
            } else {
                VStack {
                    Image(systemName: "globe")
                        .imageScale(.large)
                        .foregroundStyle(.tint)
                    Text("Hello, world!")
                }
            }
        }
        .padding()
        .onAppear(perform: requestAuthorization)
    }
    
    func requestAuthorization() {
        HealthKitManager.shared.requestAuthorization { success in
            if success {
                isAuthorized = true
                print("Authorization granted")
            } else {
                isAuthorized = false
                print("Authorization denied")
            }
        }
    }
}

#Preview {
    ContentView()
}

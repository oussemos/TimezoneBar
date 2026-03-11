import SwiftUI

@main
struct TimezoneBarApp: App {
    @StateObject private var manager = ClockManager()

    var body: some Scene {
        MenuBarExtra {
            MenuBarContentView()
                .environmentObject(manager)
        } label: {
            Text(manager.menuBarTitle)
                .font(.system(size: 12, weight: .regular, design: .monospaced))
                .fixedSize()
        }
        .menuBarExtraStyle(.window)

        WindowGroup("Add Timezone", id: "add-timezone") {
            AddEditClockView()
                .environmentObject(manager)
        }
        .windowResizability(.contentSize)

        Settings {
            PreferencesView()
                .environmentObject(manager)
        }
    }
}

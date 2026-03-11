import Foundation
import SwiftUI

class ClockManager: ObservableObject {
    @Published var clocks: [ClockConfig] = []
    @Published var currentDate: Date = Date()

    private var timer: Timer?
    private let defaultsKey = "com.timezonebar.clocks"

    init() {
        load()
        startTimer()
    }

    deinit {
        timer?.invalidate()
    }

    private func startTimer() {
        let t = Timer(timeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.currentDate = Date()
        }
        RunLoop.main.add(t, forMode: .common)
        timer = t
    }

    func load() {
        guard let data = UserDefaults.standard.data(forKey: defaultsKey),
              let saved = try? JSONDecoder().decode([ClockConfig].self, from: data) else {
            resetToDefaults()
            return
        }
        clocks = saved
    }

    func save() {
        if let data = try? JSONEncoder().encode(clocks) {
            UserDefaults.standard.set(data, forKey: defaultsKey)
        }
    }

    private func resetToDefaults() {
        clocks = [
            ClockConfig(name: "Local",  timezoneIdentifier: TimeZone.current.identifier, showSeconds: true),
            ClockConfig(name: "UTC",    timezoneIdentifier: "UTC"),
            ClockConfig(name: "NYC",    timezoneIdentifier: "America/New_York"),
            ClockConfig(name: "London", timezoneIdentifier: "Europe/London"),
            ClockConfig(name: "Tokyo",  timezoneIdentifier: "Asia/Tokyo"),
        ]
        save()
    }

    func add(_ clock: ClockConfig) {
        clocks.append(clock)
        save()
    }

    func remove(at offsets: IndexSet) {
        clocks.remove(atOffsets: offsets)
        save()
    }

    func move(from source: IndexSet, to destination: Int) {
        clocks.move(fromOffsets: source, toOffset: destination)
        save()
    }

    func update(_ clock: ClockConfig) {
        guard let idx = clocks.firstIndex(where: { $0.id == clock.id }) else { return }
        clocks[idx] = clock
        save()
    }

    var menuBarTitle: String {
        guard !clocks.isEmpty else { return "🕐" }
        return clocks.map { $0.menuBarLabel(date: currentDate) }.joined(separator: "  ·  ")
    }
}

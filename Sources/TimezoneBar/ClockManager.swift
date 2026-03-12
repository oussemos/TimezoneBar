import Foundation
import SwiftUI

class ClockManager: ObservableObject {
    @Published var clocks: [ClockConfig] = []
    @Published var currentDate: Date = Date()

    private var timer: Timer?
    private var alignmentWork: DispatchWorkItem?
    private var activeInterval: TimeInterval = 0
    private let defaultsKey = "com.timezonebar.clocks"

    private var needsSecondTicks: Bool {
        clocks.contains { $0.showSeconds }
    }

    init() {
        load()
        scheduleTimer()
    }

    deinit {
        timer?.invalidate()
        alignmentWork?.cancel()
    }

    private func scheduleTimer() {
        timer?.invalidate()
        timer = nil
        alignmentWork?.cancel()
        alignmentWork = nil

        if needsSecondTicks {
            activeInterval = 1.0
            let t = Timer(timeInterval: 1.0, repeats: true) { [weak self] _ in
                self?.currentDate = Date()
            }
            RunLoop.main.add(t, forMode: .common)
            timer = t
        } else {
            // Minute-precision: fire immediately, then align to the next :00 boundary
            // so the display always flips exactly when the minute changes.
            activeInterval = 60.0
            currentDate = Date()
            let delay = 60.0 - Date().timeIntervalSince1970.truncatingRemainder(dividingBy: 60.0)
            let work = DispatchWorkItem { [weak self] in
                guard let self else { return }
                self.currentDate = Date()
                let t = Timer(timeInterval: 60.0, repeats: true) { [weak self] _ in
                    self?.currentDate = Date()
                }
                RunLoop.main.add(t, forMode: .common)
                self.timer = t
            }
            alignmentWork = work
            DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: work)
        }
    }

    private func restartTimerIfNeeded() {
        let needed: TimeInterval = needsSecondTicks ? 1.0 : 60.0
        if needed != activeInterval { scheduleTimer() }
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
        restartTimerIfNeeded()
    }

    func remove(at offsets: IndexSet) {
        clocks.remove(atOffsets: offsets)
        save()
        restartTimerIfNeeded()
    }

    func move(from source: IndexSet, to destination: Int) {
        clocks.move(fromOffsets: source, toOffset: destination)
        save()
    }

    func update(_ clock: ClockConfig) {
        guard let idx = clocks.firstIndex(where: { $0.id == clock.id }) else { return }
        clocks[idx] = clock
        save()
        restartTimerIfNeeded()
    }

    var menuBarTitle: String {
        guard !clocks.isEmpty else { return "🕐" }
        return clocks.map { $0.menuBarLabel(date: currentDate) }.joined(separator: "  ·  ")
    }
}

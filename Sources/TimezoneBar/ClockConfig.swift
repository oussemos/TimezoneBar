import Foundation

struct ClockConfig: Identifiable, Codable, Equatable, Hashable {
    var id: UUID = UUID()
    var name: String
    var timezoneIdentifier: String
    var use24Hour: Bool = true
    var showSeconds: Bool = false
    var showDate: Bool = false
    var showLabel: Bool = true

    var timezone: TimeZone {
        TimeZone(identifier: timezoneIdentifier) ?? .current
    }

    func formattedTime(date: Date) -> String {
        let f = DateFormatter()
        f.timeZone = timezone
        if use24Hour {
            f.dateFormat = showSeconds ? "HH:mm:ss" : "HH:mm"
        } else {
            f.dateFormat = showSeconds ? "h:mm:ss a" : "h:mm a"
        }
        return f.string(from: date)
    }

    func formattedDate(date: Date) -> String {
        let f = DateFormatter()
        f.timeZone = timezone
        f.dateFormat = "EEE, MMM d"
        return f.string(from: date)
    }

    func menuBarLabel(date: Date) -> String {
        if showLabel && !name.isEmpty {
            return "\(name) \(formattedTime(date: date))"
        }
        return formattedTime(date: date)
    }

    var offsetString: String {
        let seconds = timezone.secondsFromGMT()
        let hours = seconds / 3600
        let minutes = abs((seconds % 3600) / 60)
        let sign = hours >= 0 ? "+" : ""
        if minutes == 0 {
            return "UTC\(sign)\(hours)"
        } else {
            return "UTC\(sign)\(hours):\(String(format: "%02d", minutes))"
        }
    }
}

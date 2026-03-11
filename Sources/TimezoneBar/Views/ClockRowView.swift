import SwiftUI

struct ClockRowView: View {
    let clock: ClockConfig
    let date: Date

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                if !clock.name.isEmpty {
                    Text(clock.name)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                }

                Text(clock.formattedTime(date: date))
                    .font(.system(size: 26, weight: .light, design: .monospaced))
                    .foregroundColor(.primary)

                if clock.showDate {
                    Text(clock.formattedDate(date: date))
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            Text(clock.offsetString)
                .font(.system(size: 11, design: .monospaced))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
    }
}

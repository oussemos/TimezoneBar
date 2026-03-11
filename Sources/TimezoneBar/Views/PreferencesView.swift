import SwiftUI

struct PreferencesView: View {
    @EnvironmentObject var manager: ClockManager
    @State private var showingAdd = false
    @State private var editingClock: ClockConfig?

    var body: some View {
        VStack(spacing: 0) {
            List {
                ForEach(manager.clocks) { clock in
                    PreferenceClockRow(clock: clock) {
                        editingClock = clock
                    }
                }
                .onMove { manager.move(from: $0, to: $1) }
                .onDelete { manager.remove(at: $0) }
            }
            .listStyle(.inset(alternatesRowBackgrounds: true))

            Divider()

            HStack {
                Button {
                    showingAdd = true
                } label: {
                    Label("Add Timezone", systemImage: "plus.circle.fill")
                }
                .buttonStyle(.plain)
                .foregroundColor(.accentColor)

                Spacer()

                Text("\(manager.clocks.count) timezone\(manager.clocks.count == 1 ? "" : "s")")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .frame(minWidth: 460, minHeight: 320)
        .sheet(isPresented: $showingAdd) {
            AddEditClockView()
                .environmentObject(manager)
        }
        .sheet(item: $editingClock) { clock in
            AddEditClockView(existingClock: clock)
                .environmentObject(manager)
        }
    }
}

struct PreferenceClockRow: View {
    let clock: ClockConfig
    let onEdit: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(clock.name.isEmpty ? "(unnamed)" : clock.name)
                    .font(.body)
                Text(clock.timezoneIdentifier)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Text(clock.offsetString)
                .font(.system(size: 11, design: .monospaced))
                .foregroundColor(.secondary)
                .frame(width: 70, alignment: .trailing)

            Button("Edit") { onEdit() }
                .font(.caption)
                .buttonStyle(.bordered)
                .controlSize(.small)
        }
        .padding(.vertical, 2)
    }
}

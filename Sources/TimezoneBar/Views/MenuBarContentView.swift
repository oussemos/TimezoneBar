import SwiftUI

struct MenuBarContentView: View {
    @EnvironmentObject var manager: ClockManager
    @Environment(\.openWindow) private var openWindow
    @Environment(\.openSettings) private var openSettings

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(manager.clocks) { clock in
                        HStack(spacing: 0) {
                            ClockRowView(clock: clock, date: manager.currentDate)

                            Button {
                                if let idx = manager.clocks.firstIndex(where: { $0.id == clock.id }) {
                                    manager.remove(at: IndexSet([idx]))
                                }
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.tertiary)
                                    .font(.system(size: 14))
                            }
                            .buttonStyle(.plain)
                            .padding(.trailing, 12)
                        }

                        if clock.id != manager.clocks.last?.id {
                            Divider().padding(.horizontal, 12)
                        }
                    }
                }
                .padding(.vertical, 8)
            }
            .frame(maxHeight: 440)

            Divider()

            HStack {
                Button {
                    openWindow(id: "add-timezone")
                    NSApp.activate(ignoringOtherApps: true)
                } label: {
                    Label("Add Timezone", systemImage: "plus.circle.fill")
                        .font(.system(size: 12))
                }
                .buttonStyle(.plain)
                .foregroundColor(.accentColor)

                Spacer()

                Button("Preferences…") {
                    openSettings()
                    NSApp.activate(ignoringOtherApps: true)
                }
                .buttonStyle(.plain)
                .foregroundColor(.secondary)
                .font(.system(size: 12))

                Divider()
                    .frame(height: 14)
                    .padding(.horizontal, 4)

                Button("Quit") {
                    NSApp.terminate(nil)
                }
                .buttonStyle(.plain)
                .foregroundColor(.secondary)
                .font(.system(size: 12))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
        }
        .frame(width: 320)
    }
}

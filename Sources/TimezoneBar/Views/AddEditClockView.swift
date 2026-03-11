import SwiftUI

struct AddEditClockView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var manager: ClockManager

    let existingClock: ClockConfig?

    @State private var name: String
    @State private var timezoneSearch: String = ""
    @State private var selectedTimezone: String
    @State private var use24Hour: Bool
    @State private var showSeconds: Bool
    @State private var showDate: Bool
    @State private var showLabel: Bool

    init(existingClock: ClockConfig? = nil) {
        self.existingClock = existingClock
        let c = existingClock
        _name             = State(initialValue: c?.name ?? "")
        _selectedTimezone = State(initialValue: c?.timezoneIdentifier ?? TimeZone.current.identifier)
        _use24Hour        = State(initialValue: c?.use24Hour ?? true)
        _showSeconds      = State(initialValue: c?.showSeconds ?? false)
        _showDate         = State(initialValue: c?.showDate ?? false)
        _showLabel        = State(initialValue: c?.showLabel ?? true)
    }

    var filteredTimezones: [String] {
        let all = TimeZone.knownTimeZoneIdentifiers.sorted()
        guard !timezoneSearch.isEmpty else { return all }
        return all.filter { $0.localizedCaseInsensitiveContains(timezoneSearch) }
    }

    var isValid: Bool { !name.trimmingCharacters(in: .whitespaces).isEmpty }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(existingClock == nil ? "Add Timezone" : "Edit Timezone")
                    .font(.headline)
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 12)

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    // Name
                    VStack(alignment: .leading, spacing: 6) {
                        Label("Label", systemImage: "tag")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)
                        TextField("e.g. New York", text: $name)
                            .textFieldStyle(.roundedBorder)
                    }

                    Divider()

                    // Timezone picker
                    VStack(alignment: .leading, spacing: 6) {
                        Label("Timezone", systemImage: "globe")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)

                        TextField("Search timezones…", text: $timezoneSearch)
                            .textFieldStyle(.roundedBorder)

                        ScrollViewReader { proxy in
                            ScrollView {
                                LazyVStack(alignment: .leading, spacing: 0) {
                                    ForEach(filteredTimezones, id: \.self) { tz in
                                        HStack {
                                            Text(tz)
                                                .font(.system(size: 12))
                                            Spacer()
                                            if tz == selectedTimezone {
                                                Image(systemName: "checkmark")
                                                    .font(.caption)
                                                    .foregroundColor(.accentColor)
                                            }
                                        }
                                        .id(tz)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 5)
                                        .background(
                                            tz == selectedTimezone
                                                ? Color.accentColor.opacity(0.12)
                                                : Color.clear
                                        )
                                        .cornerRadius(4)
                                        .contentShape(Rectangle())
                                        .onTapGesture { selectedTimezone = tz }
                                    }
                                }
                                .padding(4)
                            }
                            .frame(height: 160)
                            .background(Color(NSColor.textBackgroundColor))
                            .cornerRadius(6)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color(NSColor.separatorColor), lineWidth: 1)
                            )
                            .onAppear {
                                proxy.scrollTo(selectedTimezone, anchor: .center)
                            }
                            .onChange(of: timezoneSearch) {
                                if let first = filteredTimezones.first {
                                    proxy.scrollTo(first, anchor: .top)
                                }
                            }
                        }
                    }

                    Divider()

                    // Format options
                    VStack(alignment: .leading, spacing: 10) {
                        Label("Format", systemImage: "slider.horizontal.3")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)

                        Toggle("Show label in menu bar", isOn: $showLabel)
                        Toggle("24-hour format", isOn: $use24Hour)
                        Toggle("Show seconds", isOn: $showSeconds)
                        Toggle("Show date", isOn: $showDate)
                    }
                    .toggleStyle(.checkbox)
                }
                .padding(20)
            }

            Divider()

            HStack {
                Button("Cancel") { dismiss() }
                    .keyboardShortcut(.cancelAction)
                Spacer()
                Button(existingClock == nil ? "Add" : "Save") {
                    commit()
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(!isValid)
                .buttonStyle(.borderedProminent)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
        }
        .frame(width: 400, height: 560)
    }

    private func commit() {
        var clock = existingClock ?? ClockConfig(name: name, timezoneIdentifier: selectedTimezone)
        clock.name = name.trimmingCharacters(in: .whitespaces)
        clock.timezoneIdentifier = selectedTimezone
        clock.use24Hour = use24Hour
        clock.showSeconds = showSeconds
        clock.showDate = showDate
        clock.showLabel = showLabel

        if existingClock != nil {
            manager.update(clock)
        } else {
            manager.add(clock)
        }
    }
}

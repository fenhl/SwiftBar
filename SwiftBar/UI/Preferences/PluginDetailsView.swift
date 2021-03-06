import SwiftUI

struct PluginDetailsView: View {
    @ObservedObject var md: PluginMetadata
    let plugin: Plugin
    @State var isEditing: Bool = false
    @State var dependencies: String = ""
    let screenProportion: CGFloat = 0.3
    let width: CGFloat = 400
    var body: some View {
        VStack {
            Form {
                Section(header: HStack {
                    Text("About Plugin")
                    Spacer()
                    if #available(OSX 11.0, *) {
                        Button(action: {
                            AppShared.openPluginFolder(path: plugin.file)
                        }) {
                            Image(systemName: "folder")
                        }.padding(.trailing)
                    }
                }) {
                    PluginDetailsTextView(label: "Name",
                                          text: $md.name,
                                          width: width * screenProportion)
                    PluginDetailsTextView(label: "Description",
                                          text: $md.desc,
                                          width: width * screenProportion)
                    PluginDetailsTextView(label: "Dependencies",
                                          text: $dependencies,
                                          width: width * screenProportion)
                        .onAppear(perform: {
                            dependencies = md.dependencies.joined(separator: ",")
                        })
                    HStack {
                        PluginDetailsTextView(label: "GitHub",
                                              text: $md.github,
                                              width: width * screenProportion)
                        PluginDetailsTextView(label: "Author",
                                              text: $md.author,
                                              width: width * 0.2)
                    }
                    HStack {
                        PluginDetailsTextView(label: "Version",
                                              text: $md.version,
                                              width: width * screenProportion)
                        PluginDetailsTextView(label: "Schedule",
                                              text: $md.schedule,
                                              width: width * 0.2)
                    }
                }
                Divider()
                Section(header: Text("Hide Menu Items")) {
                    HStack {
                        PluginDetailsToggleView(label: "About",
                                                state: $md.hideAbout,
                                                width: width * screenProportion)
                        PluginDetailsToggleView(label: "Run In Terminal",
                                                state: $md.hideRunInTerminal,
                                                width: width * screenProportion)
                        PluginDetailsToggleView(label: "Last Updated",
                                                state: $md.hideLastUpdated,
                                                width: width * screenProportion)
                            .padding(.trailing, 5)
                    }
                    HStack {
                        PluginDetailsToggleView(label: "SwiftBar",
                                                state: $md.hideSwiftBar,
                                                width: width * screenProportion)

                        PluginDetailsToggleView(label: "Disable Plugin",
                                                state: $md.hideDisablePlugin,
                                                width: width * screenProportion)
                    }
                }
                if !md.environment.isEmpty {
                    Section(header: Text("Environment Variables")) {
                        PluginDetailsTextView(label: "Variable 1",
                                              text: $md.github,
                                              width: width * screenProportion)
                        PluginDetailsTextView(label: "Variable 3",
                                              text: $md.github,
                                              width: width * screenProportion)
                    }
                }
            }.padding()
            Spacer()
            HStack {
                Spacer()
                Button("Save in Plugin File", action: {
                    PluginMetadata.writeMetadata(metadata: md, fileURL: URL(fileURLWithPath: plugin.file))
                }).padding(.trailing, 5)
            }.padding()
        }.padding(8)
    }
}

struct PluginDetailsTextView: View {
    @EnvironmentObject var preferences: PreferencesStore
    let label: String
    @Binding var text: String
    let width: CGFloat
    var body: some View {
        HStack {
            HStack {
                Spacer()
                Text("\(label):")
            }.frame(width: width)
            TextField("", text: $text)
                .disabled(!PreferencesStore.shared.pluginDeveloperMode)
            Spacer()
        }
    }
}

struct PluginDetailsToggleView: View {
    let label: String
    @Binding var state: Bool
    let width: CGFloat
    var body: some View {
        HStack {
            HStack {
                Spacer()
                Text("\(label):")
            }.frame(width: width)
            Toggle("", isOn: $state)
        }
    }
}

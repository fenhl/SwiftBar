import Cocoa
import Combine

class PreferencesStore: ObservableObject {
    static let shared = PreferencesStore()
    enum PreferencesKeys: String {
        case PluginDirectory
        case DisabledPlugins
        case Terminal
        case HideSwiftBarIcon
        case MakePluginExecutable
        case PluginDeveloperMode
        case DisableBashWrapper
        case StreamablePluginDebugOutput
        case PluginDebugMode
    }

    let disabledPluginsPublisher = PassthroughSubject<Any, Never>()

    @Published var pluginDirectoryPath: String? {
        didSet {
            PreferencesStore.setValue(value: pluginDirectoryPath, key: .PluginDirectory)
        }
    }

    var pluginDirectoryResolvedURL: URL? {
        guard let path = pluginDirectoryPath as NSString? else { return nil }
        return URL(fileURLWithPath: path.expandingTildeInPath).resolvingSymlinksInPath()
    }

    var pluginDirectoryResolvedPath: String? {
        pluginDirectoryResolvedURL?.path
    }

    @Published var disabledPlugins: [PluginID] {
        didSet {
            let unique = Array(Set(disabledPlugins))
            PreferencesStore.setValue(value: unique, key: .DisabledPlugins)
            disabledPluginsPublisher.send("")
        }
    }

    @Published var terminal: ShellOptions {
        didSet {
            PreferencesStore.setValue(value: terminal.rawValue, key: .Terminal)
        }
    }

    @Published var swiftBarIconIsHidden: Bool {
        didSet {
            PreferencesStore.setValue(value: swiftBarIconIsHidden, key: .HideSwiftBarIcon)
            delegate.pluginManager.rebuildAllMenus()
        }
    }

    var makePluginExecutable: Bool {
        guard let out = PreferencesStore.getValue(key: .MakePluginExecutable) as? Bool else {
            PreferencesStore.setValue(value: true, key: .MakePluginExecutable)
            return true
        }
        return out
    }

    var pluginDeveloperMode: Bool {
        PreferencesStore.getValue(key: .PluginDeveloperMode) as? Bool ?? false
    }

    var pluginDebugMode: Bool {
        PreferencesStore.getValue(key: .PluginDebugMode) as? Bool ?? false
    }

    var disableBashWrapper: Bool {
        PreferencesStore.getValue(key: .DisableBashWrapper) as? Bool ?? false
    }

    var streamablePluginDebugOutput: Bool {
        PreferencesStore.getValue(key: .StreamablePluginDebugOutput) as? Bool ?? false
    }

    init() {
        pluginDirectoryPath = PreferencesStore.getValue(key: .PluginDirectory) as? String
        disabledPlugins = PreferencesStore.getValue(key: .DisabledPlugins) as? [PluginID] ?? []
        terminal = .Terminal
        swiftBarIconIsHidden = PreferencesStore.getValue(key: .HideSwiftBarIcon) as? Bool ?? false
        if let savedTerminal = PreferencesStore.getValue(key: .Terminal) as? String,
           let shell = ShellOptions(rawValue: savedTerminal)
        {
            terminal = shell
        }
    }

    static func removeAll() {
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
    }

    private static func setValue(value: Any?, key: PreferencesKeys) {
        UserDefaults.standard.setValue(value, forKey: key.rawValue)
        UserDefaults.standard.synchronize()
    }

    private static func getValue(key: PreferencesKeys) -> Any? {
        UserDefaults.standard.value(forKey: key.rawValue)
    }
}

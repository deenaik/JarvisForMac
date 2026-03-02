import Carbon
import Cocoa

/// Registers a global Cmd+Shift+J hotkey using the Carbon API.
final class HotkeyManager {
    private var hotkeyRef: EventHotKeyRef?
    private let handler: () -> Void

    // Store the handler in a static so the C callback can access it
    private static var activeHandler: (() -> Void)?

    init(handler: @escaping () -> Void) {
        self.handler = handler
    }

    deinit {
        unregister()
    }

    func register() {
        HotkeyManager.activeHandler = handler

        // Cmd+Shift+J — 'J' keycode is 38
        let hotkeyID = EventHotKeyID(signature: fourCharCode("JRVS"), id: 1)
        let modifiers: UInt32 = UInt32(cmdKey | shiftKey)

        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))

        InstallEventHandler(
            GetApplicationEventTarget(),
            { _, event, _ -> OSStatus in
                HotkeyManager.activeHandler?()
                return noErr
            },
            1,
            &eventType,
            nil,
            nil
        )

        let status = RegisterEventHotKey(
            UInt32(kVK_ANSI_J),
            modifiers,
            hotkeyID,
            GetApplicationEventTarget(),
            0,
            &hotkeyRef
        )

        if status != noErr {
            NSLog("Failed to register hotkey: \(status)")
        }
    }

    func unregister() {
        if let ref = hotkeyRef {
            UnregisterEventHotKey(ref)
            hotkeyRef = nil
        }
        HotkeyManager.activeHandler = nil
    }

    private func fourCharCode(_ string: String) -> FourCharCode {
        var result: FourCharCode = 0
        for char in string.utf8.prefix(4) {
            result = (result << 8) + FourCharCode(char)
        }
        return result
    }
}

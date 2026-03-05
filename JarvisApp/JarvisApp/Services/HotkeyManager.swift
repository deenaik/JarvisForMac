import Carbon
import Cocoa

/// Registers global hotkeys using the Carbon API.
final class HotkeyManager {
    private var hotkeyRef: EventHotKeyRef?
    private let handler: () -> Void
    private let keyCode: UInt32
    private let hotkeyId: UInt32
    private let signature: String

    // Store handlers indexed by hotkey ID so multiple instances work
    private static var handlers: [UInt32: () -> Void] = [:]
    private static var eventHandlerInstalled = false

    init(keyCode: UInt32 = UInt32(kVK_ANSI_J), hotkeyId: UInt32 = 1, signature: String = "JRVS", handler: @escaping () -> Void) {
        self.handler = handler
        self.keyCode = keyCode
        self.hotkeyId = hotkeyId
        self.signature = signature
    }

    deinit {
        unregister()
    }

    func register() {
        HotkeyManager.handlers[hotkeyId] = handler

        if !HotkeyManager.eventHandlerInstalled {
            var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
            InstallEventHandler(
                GetApplicationEventTarget(),
                { _, event, _ -> OSStatus in
                    var hotkeyID = EventHotKeyID()
                    GetEventParameter(event, EventParamName(kEventParamDirectObject), EventParamType(typeEventHotKeyID), nil, MemoryLayout<EventHotKeyID>.size, nil, &hotkeyID)
                    HotkeyManager.handlers[hotkeyID.id]?()
                    return noErr
                },
                1,
                &eventType,
                nil,
                nil
            )
            HotkeyManager.eventHandlerInstalled = true
        }

        let hotkeyID = EventHotKeyID(signature: fourCharCode(signature), id: hotkeyId)
        let modifiers: UInt32 = UInt32(cmdKey | shiftKey)

        let status = RegisterEventHotKey(
            keyCode,
            modifiers,
            hotkeyID,
            GetApplicationEventTarget(),
            0,
            &hotkeyRef
        )

        if status != noErr {
            NSLog("Failed to register hotkey (id=\(hotkeyId)): \(status)")
        }
    }

    func unregister() {
        if let ref = hotkeyRef {
            UnregisterEventHotKey(ref)
            hotkeyRef = nil
        }
        HotkeyManager.handlers.removeValue(forKey: hotkeyId)
    }

    private func fourCharCode(_ string: String) -> FourCharCode {
        var result: FourCharCode = 0
        for char in string.utf8.prefix(4) {
            result = (result << 8) + FourCharCode(char)
        }
        return result
    }
}

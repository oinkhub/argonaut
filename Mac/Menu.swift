import AppKit

final class Menu: NSMenu {
    func base() { items = [argonaut, maps, edit, window, help] }
    func new() { items = [argonaut, create, world, edit, window, help] }
    func navigate() { items = [] }
    
    private var argonaut: NSMenuItem {
        {
            $0.submenu = .init(title: .key("Menu.argonaut"))
            $0.submenu!.items = [
                .init(title: .key("Menu.about"), action: #selector(app.about), keyEquivalent: ""),
                .separator(),
                .init(title: .key("Menu.hide"), action: #selector(app.hide(_:)), keyEquivalent: "h"),
                { $0.keyEquivalentModifierMask = [.option, .command]
                    return $0
                } (NSMenuItem(title: .key("Menu.hideOthers"), action: #selector(app.hideOtherApplications(_:)), keyEquivalent: "h")),
                .init(title: .key("Menu.showAll"), action: #selector(app.unhideAllApplications(_:)), keyEquivalent: ""),
                .separator(),
                .init(title: .key("Menu.quit"), action: #selector(app.terminate(_:)), keyEquivalent: "q")]
            return $0
        } (NSMenuItem(title: "", action: nil, keyEquivalent: ""))
    }
    
    private var edit: NSMenuItem {
        {
            $0.submenu = .init(title: .key("Menu.edit"))
            $0.submenu!.items = [
                { $0.keyEquivalentModifierMask = [.option, .command]
                    $0.keyEquivalentModifierMask = [.command]
                    return $0
                } (NSMenuItem(title: .key("Menu.undo"), action: Selector(("undo:")), keyEquivalent: "z")),
                { $0.keyEquivalentModifierMask = [.command, .shift]
                    return $0
                } (NSMenuItem(title: .key("Menu.redo"), action: Selector(("redo:")), keyEquivalent: "z")),
                .separator(),
                { $0.keyEquivalentModifierMask = [.command]
                    return $0
                } (NSMenuItem(title: .key("Menu.cut"), action: #selector(NSText.cut(_:)), keyEquivalent: "x")),
                { $0.keyEquivalentModifierMask = [.command]
                    return $0
                } (NSMenuItem(title: .key("Menu.copy"), action: #selector(NSText.copy(_:)), keyEquivalent: "c")),
                { $0.keyEquivalentModifierMask = [.command]
                    return $0
                } (NSMenuItem(title: .key("Menu.paste"), action: #selector(NSText.paste(_:)), keyEquivalent: "v")),
                .init(title: .key("Menu.delete"), action: #selector(NSText.delete(_:)), keyEquivalent: ""),
                { $0.keyEquivalentModifierMask = [.command]
                    return $0
                } (NSMenuItem(title: .key("Menu.selectAll"), action: #selector(NSText.selectAll(_:)), keyEquivalent: "a"))]
            return $0
        } (NSMenuItem(title: "", action: nil, keyEquivalent: ""))
    }
    
    private var window: NSMenuItem {
        {
            $0.submenu = .init(title: .key("Menu.window"))
            $0.submenu!.items = [
                .init(title: .key("Menu.minimize"), action: #selector(NSWindow.miniaturize(_:)), keyEquivalent: "m"),
                .init(title: .key("Menu.zoom"), action: #selector(NSWindow.zoom(_:)), keyEquivalent: "p"),
                .separator(),
                .init(title: .key("Menu.bringAllToFront"), action: #selector(app.arrangeInFront(_:)), keyEquivalent: ""),
                .separator(),
                .init(title: .key("Menu.close"), action: #selector(NSWindow.close), keyEquivalent: "w")]
            return $0
        } (NSMenuItem(title: "", action: nil, keyEquivalent: ""))
    }
    
    private var help: NSMenuItem {
        {
            $0.submenu = .init(title: .key("Menu.help"))
            $0.submenu!.items = [.init(title: .key("Menu.showHelp"), action: #selector(app.help), keyEquivalent: "/")]
            return $0
        } (NSMenuItem(title: "", action: nil, keyEquivalent: ""))
    }
    
    private var maps: NSMenuItem {
        {
            $0.submenu = .init(title: .key("Menu.maps"))
            $0.submenu!.items = [
                .init(title: .key("Menu.new"), action: #selector(Bar.new), keyEquivalent: "n"),
                .separator(),
                .init(title: .key("Menu.edit"), action: #selector(Bar.edit), keyEquivalent: "e")]
            return $0
        } (NSMenuItem(title: "", action: nil, keyEquivalent: ""))
    }
    
    private var create: NSMenuItem {
        {
            $0.submenu = NSMenu(title: .key("Menu.create"))
            $0.submenu!.items = [
                { $0.keyEquivalentModifierMask = []
                    return $0
                } (NSMenuItem(title: .key("Menu.pin"), action: #selector(New.pin), keyEquivalent: "p")),
                { $0.keyEquivalentModifierMask = []
                    return $0
                } (NSMenuItem(title: .key("Menu.directions"), action: #selector(World.directions), keyEquivalent: "l")),
                .init(title: .key("Menu.search"), action: #selector(New.search), keyEquivalent: "f"),
                .separator(),
                .init(title: .key("Menu.save"), action: #selector(New.save), keyEquivalent: "s")]
            return $0
        } (NSMenuItem(title: "", action: nil, keyEquivalent: ""))
    }
    
    private var world: NSMenuItem {
        {
            $0.submenu = .init(title: .key("Menu.map"))
            $0.submenu!.items = [
                .init(title: .key("Menu.settings"), action: #selector(World.settings), keyEquivalent: ","),
                .separator(),
                { $0.keyEquivalentModifierMask = []
                    return $0
                } (NSMenuItem(title: .key("Menu.me"), action: #selector(World.me), keyEquivalent: "c")),
                .separator(),
                { $0.keyEquivalentModifierMask = []
                    return $0
                } (NSMenuItem(title: .key("Menu.in"), action: #selector(World.in), keyEquivalent: "+")),
                { $0.keyEquivalentModifierMask = []
                    return $0
                } (NSMenuItem(title: .key("Menu.out"), action: #selector(World.out), keyEquivalent: "-")),
                { $0.keyEquivalentModifierMask = []
                    return $0
                } (NSMenuItem(title: .key("Menu.up"), action: #selector(World.upwards), keyEquivalent: String(Character(UnicodeScalar(NSUpArrowFunctionKey)!)))),
                { $0.keyEquivalentModifierMask = []
                    return $0
                } (NSMenuItem(title: .key("Menu.down"), action: #selector(World.downwards), keyEquivalent: String(Character(UnicodeScalar(NSDownArrowFunctionKey)!)))),
                { $0.keyEquivalentModifierMask = []
                    return $0
                } (NSMenuItem(title: .key("Menu.left"), action: #selector(World.left), keyEquivalent: String(Character(UnicodeScalar(NSLeftArrowFunctionKey)!)))),
                { $0.keyEquivalentModifierMask = []
                    return $0
                } (NSMenuItem(title: .key("Menu.right"), action: #selector(World.right), keyEquivalent: String(Character(UnicodeScalar(NSRightArrowFunctionKey)!))))]
            return $0
        } (NSMenuItem(title: "", action: nil, keyEquivalent: ""))
    }
}

import AppKit

final class Menu: NSMenu {
    required init(coder: NSCoder) { super.init(title: "") }
    init() {
        super.init(title: "")
                
        
                /*
                menu.addItem({
                    $0.submenu = NSMenu(title: .key("Menu.map"))
                    $0.submenu!.items = [
                        { $0.keyEquivalentModifierMask = []
                            follow = $0
                            follow.state = .on
                            return $0
                        } (NSMenuItem(title: .key("Menu.follow"), action: #selector(World.follow), keyEquivalent: "f")),
                        { $0.keyEquivalentModifierMask = []
                            walking = $0
                            walking.state = .on
                            return $0
                        } (NSMenuItem(title: .key("Menu.walking"), action: #selector(World.walking), keyEquivalent: "w")),
                        { $0.keyEquivalentModifierMask = []
                            driving = $0
                            driving.state = .on
                            return $0
                        } (NSMenuItem(title: .key("Menu.driving"), action: #selector(World.driving), keyEquivalent: "d")),
                        NSMenuItem.separator(),
                        { $0.keyEquivalentModifierMask = []
                            return $0
                        } (NSMenuItem(title: .key("Menu.in"), action: #selector(World.in), keyEquivalent: "+")),
                        { $0.keyEquivalentModifierMask = []
                            return $0
                        } (NSMenuItem(title: .key("Menu.out"), action: #selector(World.out), keyEquivalent: "-")),
                        { $0.keyEquivalentModifierMask = []
                            return $0
                        } (NSMenuItem(title: .key("Menu.up"), action: #selector(World.up), keyEquivalent: String(Character(UnicodeScalar(NSUpArrowFunctionKey)!)))),
                        { $0.keyEquivalentModifierMask = []
                            return $0
                        } (NSMenuItem(title: .key("Menu.down"), action: #selector(World.down), keyEquivalent: String(Character(UnicodeScalar(NSDownArrowFunctionKey)!)))),
                        { $0.keyEquivalentModifierMask = []
                            return $0
                        } (NSMenuItem(title: .key("Menu.left"), action: #selector(World.left), keyEquivalent: String(Character(UnicodeScalar(NSLeftArrowFunctionKey)!)))),
                        { $0.keyEquivalentModifierMask = []
                            return $0
                        } (NSMenuItem(title: .key("Menu.right"), action: #selector(World.right), keyEquivalent: String(Character(UnicodeScalar(NSRightArrowFunctionKey)!))))]
                    return $0
                } (NSMenuItem(title: "", action: nil, keyEquivalent: "")))
                */
    }
    
    func base() { items = [argonaut, maps, edit, window, help] }
    func new() { items = [argonaut, create, edit, window, help] }
    func navigate() { items = [] }
    
    private var argonaut: NSMenuItem {
        {
            $0.submenu = NSMenu(title: .key("Menu.argonaut"))
            $0.submenu!.items = [
                NSMenuItem(title: .key("Menu.about"), action: #selector(app.about), keyEquivalent: ""),
                NSMenuItem.separator(),
                NSMenuItem(title: .key("Menu.privacy"), action: #selector(app.privacy), keyEquivalent: ","),
                NSMenuItem.separator(),
                NSMenuItem(title: .key("Menu.hide"), action: #selector(app.hide(_:)), keyEquivalent: "h"),
                { $0.keyEquivalentModifierMask = [.option, .command]
                    return $0
                } (NSMenuItem(title: .key("Menu.hideOthers"), action: #selector(app.hideOtherApplications(_:)), keyEquivalent: "h")),
                NSMenuItem(title: .key("Menu.showAll"), action: #selector(app.unhideAllApplications(_:)), keyEquivalent: ","),
                NSMenuItem.separator(),
                NSMenuItem(title: .key("Menu.quit"), action: #selector(app.terminate(_:)), keyEquivalent: "q")]
            return $0
        } (NSMenuItem(title: "", action: nil, keyEquivalent: ""))
    }
    
    private var edit: NSMenuItem {
        {
            $0.submenu = NSMenu(title: .key("Menu.edit"))
            $0.submenu!.items = [
                { $0.keyEquivalentModifierMask = [.option, .command]
                    $0.keyEquivalentModifierMask = [.command]
                    return $0
                } (NSMenuItem(title: .key("Menu.undo"), action: Selector(("undo:")), keyEquivalent: "z")),
                { $0.keyEquivalentModifierMask = [.command, .shift]
                    return $0
                } (NSMenuItem(title: .key("Menu.redo"), action: Selector(("redo:")), keyEquivalent: "z")),
                NSMenuItem.separator(),
                { $0.keyEquivalentModifierMask = [.command]
                    return $0
                } (NSMenuItem(title: .key("Menu.cut"), action: #selector(NSText.cut(_:)), keyEquivalent: "x")),
                { $0.keyEquivalentModifierMask = [.command]
                    return $0
                } (NSMenuItem(title: .key("Menu.copy"), action: #selector(NSText.copy(_:)), keyEquivalent: "c")),
                { $0.keyEquivalentModifierMask = [.command]
                    return $0
                } (NSMenuItem(title: .key("Menu.paste"), action: #selector(NSText.paste(_:)), keyEquivalent: "v")),
                NSMenuItem(title: .key("Menu.delete"), action: #selector(NSText.delete(_:)), keyEquivalent: ""),
                { $0.keyEquivalentModifierMask = [.command]
                    return $0
                } (NSMenuItem(title: .key("Menu.selectAll"), action: #selector(NSText.selectAll(_:)), keyEquivalent: "a"))]
            return $0
        } (NSMenuItem(title: "", action: nil, keyEquivalent: ""))
    }
    
    private var window: NSMenuItem {
        {
            $0.submenu = NSMenu(title: .key("Menu.window"))
            $0.submenu!.items = [
                NSMenuItem(title: .key("Menu.minimize"), action: #selector(NSWindow.performMiniaturize(_:)), keyEquivalent: "m"),
                NSMenuItem(title: .key("Menu.zoom"), action: #selector(Window.zoom(_:)), keyEquivalent: "p"),
                NSMenuItem.separator(),
                NSMenuItem(title: .key("Menu.bringAllToFront"), action: #selector(app.arrangeInFront(_:)), keyEquivalent: ""),
                NSMenuItem.separator(),
                NSMenuItem(title: .key("Menu.close"), action: #selector(NSWindow.close), keyEquivalent: "w")]
            return $0
        } (NSMenuItem(title: "", action: nil, keyEquivalent: ""))
    }
    
    private var help: NSMenuItem {
        {
            $0.submenu = NSMenu(title: .key("Menu.help"))
            $0.submenu!.items = [NSMenuItem(title: .key("Menu.showHelp"), action: #selector(app.help), keyEquivalent: "/")]
            return $0
        } (NSMenuItem(title: "", action: nil, keyEquivalent: ""))
    }
    
    private var maps: NSMenuItem {
        {
            $0.submenu = NSMenu(title: .key("Menu.maps"))
            $0.submenu!.items = [
                NSMenuItem(title: .key("Menu.new"), action: #selector(Window.new), keyEquivalent: "n"),
                NSMenuItem.separator(),
                NSMenuItem(title: .key("Menu.edit"), action: #selector(Bar.edit), keyEquivalent: "e")]
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
                } (NSMenuItem(title: .key("Menu.directions"), action: #selector(New.directions), keyEquivalent: "l")),
                NSMenuItem(title: .key("Menu.search"), action: #selector(New.search), keyEquivalent: "f"),
                NSMenuItem.separator(),
                NSMenuItem(title: .key("Menu.save"), action: #selector(New.save), keyEquivalent: "s"),
                NSMenuItem.separator(),
                { $0.keyEquivalentModifierMask = []
                    return $0
                } (NSMenuItem(title: .key("Menu.cancel"), action: #selector(New.close), keyEquivalent: "\u{1b}"))]
            return $0
        } (NSMenuItem(title: "", action: nil, keyEquivalent: ""))
    }
}

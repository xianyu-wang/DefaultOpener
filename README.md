# DefaultOpener

DefaultOpener is a modern macOS GUI application designed to simplify the management of default file associations. As a graphical frontend for the powerful command-line tool `duti`, it allows users to elegantly view, modify, backup, and restore system file association settings.

![App Icon](Assets.xcassets/AppIcon.appiconset/icon_128x128.png)

## ✨ Features

*   **Comprehensive Management**: Scan and list all file types on your system along with their current default applications.
*   **Smart Categorization**: Automatically categorizes file types (Text, Image, Code, Audio, Video, Archive, PDF, etc.) for easy filtering via the sidebar.
*   **Real-time Modification**: Change the default application for any file type instantly via a dropdown menu.
*   **Configuration Import/Export**:
    *   **Export (Cmd+S)**: Save your current associations to a `.duti` configuration file for backup or syncing across machines.
    *   **Import (Cmd+I)**: Load a `.duti` config file and batch apply settings.
*   **Custom Extensions**: Manually add custom file extensions or UTIs that strictly aren't detected by the system scan.
*   **Keyboard Shortcuts**:
    *   `Cmd+F`: Quick Search
    *   `Cmd+R`: Rescan Applications
    *   `Cmd+N`: Add New File Type
*   **Modern UI**: Built with SwiftUI, designed to look and feel native on macOS.

## 📥 Installation

You can install DefaultOpener using a pre-built release or by building it from source

### ⚠️ Important Notes

**DefaultOpener relies on the `duti` command-line tool.**
Before using this software, you must ensure `duti` is installed on your system. We recommend using Homebrew:

```bash
brew install duti
```

### Option 1: Pre-built Release (Recommended)

1.  Go to the [Releases](https://github.com/yourusername/DefaultOpener/releases) page.
2.  Download the latest `.dmg` or `.app` zip file.
3.  Drag **DefaultOpener.app** to your **Applications** folder.
4.  **Permissions**: On first launch, if the system requests permission for automation or controlling other apps (to access `duti`), please **allow** it.

> **Note**: If you receive a message saying **"DefaultOpener" is damaged and can't be opened**, run the following command in Terminal to fix it:
> ```bash
> xattr -cr /Applications/DefaultOpener.app
> ```
> (Replace `/Applications/DefaultOpener.app` with the actual path if different)
>
> **💡 Pro Tip**: Type `xattr -cr ` (with a space at the end) in Terminal, then drag and drop the **DefaultOpener** app from Finder into the Terminal window. The path will be filled in automatically, then just press Enter.

### Option 2: Build from Source

If you prefer to compile the code yourself:

1.  Clone the repository
2.  Create a new project in Xcode
3.  **Import Source Files**:
    *   Delete the default files created by Xcode to avoid conflicts
    *   Drag and drop the `Core` and `UI` folders, `DefaultOpenerApp.swift`, and `Assets.xcassets` from the cloned repository into your Xcode project navigator
    *   Ensure "Copy items if needed" is checked and the target "DefaultOpener" is selected
4.  **🔴 CRITICAL STEP: Disable App Sandbox**
    DefaultOpener needs to execute system-level commands to modify file associations, which the App Sandbox prevents
    *   Click on the project root in the left navigator
    *   Select the **DefaultOpener** target
    *   Go to the **Signing & Capabilities** tab
    *   **Remove** the "App Sandbox" capability (click the 'x' button)
5.  Build and Run (`Cmd+R`)

## License

This project is open source and available under the [MIT License](LICENSE).

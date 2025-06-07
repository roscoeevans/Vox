# Fix for Info.plist Font Registration

## The Problem
Xcode automatically generates an Info.plist file during the build process. Creating a manual Info.plist causes the error:
```
Multiple commands produce '.../Vox.app/Info.plist'
```

## The Solution

### Option 1: Use Xcode's Info Tab (Recommended)

1. **Open your project in Xcode**
2. **Select the Vox target** in the project navigator
3. **Go to the "Info" tab**
4. **Add a new entry**:
   - Click the "+" button to add a new row
   - Type `UIAppFonts` (or select "Fonts provided by application")
   - Set the type to `Array`
   - Add items for each font file:
     - `Montserrat-Regular.ttf`
     - `Montserrat-Medium.ttf`
     - `Montserrat-SemiBold.ttf`
     - `Montserrat-Bold.ttf`
     - `Montserrat-ExtraBold.ttf`
     - `Montserrat-Black.ttf`

### Option 2: Edit Info.plist in Build Settings

1. **Select the Vox target**
2. **Go to "Build Settings" tab**
3. **Search for "Info.plist"**
4. **Find "Info.plist File"** - it should show something like `Vox/Info.plist`
5. **Double-click to see the actual path**

If there's already an Info.plist being used:
1. **Right-click on it in Xcode** and select "Open As" > "Source Code"
2. **Add the following before the closing `</dict>` tag**:

```xml
<key>UIAppFonts</key>
<array>
    <string>Montserrat-Regular.ttf</string>
    <string>Montserrat-Medium.ttf</string>
    <string>Montserrat-SemiBold.ttf</string>
    <string>Montserrat-Bold.ttf</string>
    <string>Montserrat-ExtraBold.ttf</string>
    <string>Montserrat-Black.ttf</string>
</array>
```

### Option 3: Create Custom Build Phase Script

If you want to avoid manual Info.plist editing entirely:

1. **Select the Vox target**
2. **Go to "Build Phases" tab**
3. **Click "+" and select "New Run Script Phase"**
4. **Add this script**:

```bash
# This script adds font entries to the Info.plist automatically
INFO_PLIST="$BUILT_PRODUCTS_DIR/$INFOPLIST_PATH"

# Add UIAppFonts array if it doesn't exist
/usr/libexec/PlistBuddy -c "Add :UIAppFonts array" "$INFO_PLIST" 2>/dev/null || true

# Add font entries
/usr/libexec/PlistBuddy -c "Add :UIAppFonts:0 string 'Montserrat-Regular.ttf'" "$INFO_PLIST" 2>/dev/null || true
/usr/libexec/PlistBuddy -c "Add :UIAppFonts:1 string 'Montserrat-Medium.ttf'" "$INFO_PLIST" 2>/dev/null || true
/usr/libexec/PlistBuddy -c "Add :UIAppFonts:2 string 'Montserrat-SemiBold.ttf'" "$INFO_PLIST" 2>/dev/null || true
/usr/libexec/PlistBuddy -c "Add :UIAppFonts:3 string 'Montserrat-Bold.ttf'" "$INFO_PLIST" 2>/dev/null || true
/usr/libexec/PlistBuddy -c "Add :UIAppFonts:4 string 'Montserrat-ExtraBold.ttf'" "$INFO_PLIST" 2>/dev/null || true
/usr/libexec/PlistBuddy -c "Add :UIAppFonts:5 string 'Montserrat-Black.ttf'" "$INFO_PLIST" 2>/dev/null || true
```

## Important: Add Font Files to Build Phases

Regardless of which option you choose, make sure the font files are included in the build:

1. **Select the Vox target**
2. **Go to "Build Phases" tab**
3. **Expand "Copy Bundle Resources"**
4. **Ensure all Montserrat font files are listed**
5. **If not, click "+" and add them**

## Verification

After implementing one of these solutions:

1. **Clean the build folder** (Cmd+Shift+K)
2. **Build and run** (Cmd+R)
3. **Check the console** for font registration messages
4. **Test with FontTestView** to ensure fonts are loading

## Why This Happens

- Xcode automatically generates Info.plist from project settings
- Creating a manual Info.plist file conflicts with this auto-generation
- The build system doesn't know which Info.plist to use
- Using Xcode's built-in configuration avoids this conflict 
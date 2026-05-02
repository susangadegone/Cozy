# 🎬 Quick App Simulation Guide

## **3 Ways to Simulate Your App**

### 🎨 **Option 1: Xcode Canvas (Instant Preview)**

**Best for:** Quick UI testing, no build needed

```
1. Open AppFlowPreviews.swift
2. Press: ⌥⌘↩ (Option + Command + Return)
3. Select a preview to interact with
```

**Available Previews:**
- ✅ Onboarding Flow
- ✅ Dashboard with Sample Data
- ✅ Chores Screen
- ✅ Chore Library
- ✅ Profile

---

### 📱 **Option 2: Fresh Install (Full Onboarding)**

**Best for:** Testing first-time user experience

```
1. Delete app from simulator (long press → Delete)
2. Press ⌘R (Build & Run)
3. Flow: Splash → Welcome → Onboarding → Dashboard
```

**What to test:**
- Room selection auto-adds presets
- Chores distributed across days 1-8
- Profile created correctly

---

### 🔄 **Option 3: Existing User (Test Features)**

**Best for:** Testing specific functionality

```
1. Press ⌘R (app loads with saved data)
2. Navigate tabs normally
3. Test features without onboarding
```

**Key features to test:**
- Mood pills (Fine/Manageable/Too much)
- Browse chore library button
- Complete chores → confetti
- Snooze functionality
- Badge unlocks

---

## 🧪 **5-Minute Verification Test**

Run this quick test to verify everything works:

```
☐ 1. Delete app, reinstall (⌘R)
☐ 2. Complete onboarding → Select all 4 rooms
☐ 3. Dashboard loads with 8 auto-added chores
☐ 4. Tap "Too much" mood → See 1 chore only
☐ 5. Tap "Snooze" button → Chores move to tomorrow
☐ 6. Go to Chores tab → See "Browse chore library"
☐ 7. Tap button → Sheet opens with presets
☐ 8. Tap "Take out trash" → Toast shows "Added to Kitchen"
☐ 9. Row updates to "Added" with checkmark
☐ 10. Go back → New chore in list
☐ 11. Complete a chore → Confetti plays
☐ 12. Go to Profile → "First chore!" badge unlocked
☐ 13. Quit app (⌘Q) → Relaunch (⌘R)
☐ 14. All data persists ✅
```

**All checkboxes marked? Your app is working perfectly! 🎉**

---

## 🎯 **What Each Screen Should Show**

### **Home Tab (Dashboard)**
- Date header (Friday, May 01)
- Mood pills (Fine / Manageable / Too much)
- Week progress card with streak
- Today's chores section
- Upcoming chores (if any in next 3 days)

### **Chores Tab**
- Filter bar (Today / Upcoming / All)
- **"Browse chore library" button** ← NEW!
- Chores grouped by room
- Swipe left to delete

### **Calendar Tab**
- Month view with navigation
- Dots on dates with chores
- Selected date shows chore list

### **Profile Tab**
- User avatar/name
- Badge grid (7 badges)
- Stats (streak, total done)
- Settings

---

## 🔧 **Quick Fixes**

### **Canvas not showing?**
```
Press: ⌥⌘↩
Or: Editor → Canvas
```

### **Simulator not launching?**
```
Xcode → Window → Devices & Simulators
Check if iPhone 15 is available
```

### **Build errors?**
```
1. Press ⇧⌘K (Clean Build)
2. Press ⌘R (Build & Run)
```

### **Want fresh start?**
```
Delete app from simulator
OR
Device → Erase All Content & Settings
```

---

## 🎨 **Test All UI States**

### **Mood Pills:**
- None selected → Shows all chores
- "Fine" selected → All chores, count badge
- "Manageable" → Top 3 chores
- "Too much" → 1 chore + snooze button

### **Chore Library:**
- Rooms with presets shown
- "Add" state → Plus icon, tappable
- "Added" state → Checkmark, dimmed, not tappable
- All added → Empty state message

### **Chore Row:**
- Uncompleted → Empty circle
- Completed → Green checkmark, strikethrough
- Overdue → Red "Overdue" badge
- Upcoming → Date badge (MMM d)

---

## 📝 **Keyboard Shortcuts**

```
⌘R     → Build & Run
⌘.     → Stop Running
⇧⌘K    → Clean Build
⌘Q     → Quit App (Simulator)
⌘1     → Show Project Navigator
⌥⌘↩    → Show Canvas (Previews)
⌘<     → Edit Scheme
⌘0     → Toggle Navigator
⌘K     → Clean Build Folder
```

---

## 🎬 **Recommended Test Sequence**

**Day 1: Fresh Install**
```
1. Test onboarding flow
2. Verify preset auto-add
3. Check dashboard layout
4. Test mood pills
```

**Day 2: Core Features**
```
1. Test chore library browse
2. Add presets from library
3. Complete chores
4. Check confetti & badges
```

**Day 3: Edge Cases**
```
1. Delete all chores → Empty states
2. Add all presets → Library empty state
3. Test data persistence
4. Verify streak tracking
```

---

## ✅ **Checklist Before GitHub Upload**

```
☐ All tabs navigate correctly
☐ Onboarding completes successfully
☐ Presets auto-add (2 per room)
☐ Chore library shows & adds correctly
☐ Mood pills filter chores
☐ Snooze moves chores to tomorrow
☐ Confetti plays on completion
☐ Badges unlock and display
☐ Data persists after quit/relaunch
☐ Empty states show properly
☐ No crashes or console errors
```

---

## 🚀 **Ready to Simulate?**

**Fastest way to see your app:**

```bash
# In Xcode:
1. Press ⌘R
2. Wait for simulator to launch
3. App opens to Splash → Welcome → Onboarding
4. Complete setup → See your dashboard!
```

**Or use previews for instant feedback:**

```bash
# In Xcode:
1. Open AppFlowPreviews.swift
2. Press ⌥⌘↩
3. Click "Dashboard with Data"
4. Interact immediately!
```

---

**Enjoy testing your beautiful, mood-aware chore app! 🏡✨**

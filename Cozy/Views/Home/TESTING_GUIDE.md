# 🧪 App Testing & Simulation Guide

## ✅ **Quick Function Verification Checklist**

### Core Features Status:

- ✅ **DashboardView** - Mood-based filtering (Fine/Manageable/Too much)
- ✅ **ChoreLibraryView** - Browse and add preset chores
- ✅ **PresetChoreLibrary** - 29 curated presets across 4 rooms
- ✅ **AppState** - Central state management
- ✅ **LocalStore** - Persistence (auto-seeding on onboarding)
- ✅ **BadgeService** - 7 achievements
- ✅ **Onboarding** - 5-step flow with room selection
- ✅ **ChoresView** - List, filter, manage chores
- ✅ **HomeView** - Main dashboard with confetti
- ✅ **ProfileView** - User settings and badges
- ✅ **RootView** - Tab navigation

---

## 🚀 **How to Simulate the Full App**

### **Option 1: Use Xcode Previews (Fastest)**

1. Open `AppFlowPreviews.swift` in Xcode
2. Press **⌥⌘↩** (Option + Command + Return) to show Canvas
3. You'll see previews for:
   - Onboarding Flow
   - Dashboard with Sample Data
   - Chores Screen
   - Chore Library
   - Profile

4. **Click any preview** to interact with it live!

**Pro tip:** You can use the "Inspect" button (eye icon) in Canvas to test different device sizes.

---

### **Option 2: Run in Simulator (Full Experience)**

#### **A. First Time / Fresh Onboarding**

1. **Clean Build** (⇧⌘K)
2. **Build & Run** (⌘R)
3. **Delete app** from simulator if it exists:
   - Long press app icon → Delete App
   - Or: Reset content and settings (Device → Erase All Content and Settings)
4. **Run again** (⌘R)

**You'll see this flow:**
```
Splash → Welcome → Sign Up → Onboarding Q1-Q5 → Dashboard
```

**During onboarding:**
- Step 3: Select rooms (Kitchen, Bedroom, Bathroom, Living Room)
- **Preset chores will auto-add** (2 per room = 8 total)
- First chores spread across days 1-8
- Complete onboarding → Land on Dashboard

#### **B. Testing With Existing Data**

If you've already completed onboarding:

1. **Run app** (⌘R)
2. Opens directly to **RootView** (TabView)
3. Navigate tabs:
   - **Home** → See dashboard with mood controls
   - **Chores** → See "Browse chore library" button
   - **Calendar** → Week/month view
   - **Profile** → Settings and badges

---

### **Option 3: Reset App Data (Fresh Start)**

#### **Method 1: Delete and Reinstall**
```
1. Stop app (⌘.)
2. Delete app from simulator
3. Run again (⌘R)
```

#### **Method 2: Launch Arguments**
1. **Edit Scheme**: Product → Scheme → Edit Scheme (⌘<)
2. Run → Arguments
3. Add: `-reset YES`
4. Run (⌘R)

#### **Method 3: Clear UserDefaults Programmatically**

Add this to your main app file (temporary testing):

```swift
#if DEBUG
UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
#endif
```

---

## 🧪 **Feature-by-Feature Testing**

### **1. Mood-Based Dashboard**

**Test Steps:**
1. Run app → Go to Home tab
2. Tap **"Manageable"** pill
   - ✅ Should show top 3 undone chores
   - ✅ Banner says "Showing your top 3 of X remaining"
3. Tap **"Too much"** pill
   - ✅ Shows only 1 chore
   - ✅ "Push X to tomorrow" button appears
   - ✅ Tap button → chores moved, confirmation shows
4. Tap **"Fine"** pill
   - ✅ Shows all chores
   - ✅ Banner shows total count

**Expected Behavior:**
- Mood pills toggle on/off
- X button appears when mood is selected
- Chore list adapts instantly
- Animations are smooth

---

### **2. Browse Chore Library**

**Test Steps:**
1. Go to **Chores** tab
2. Tap **"Browse chore library"** button
3. Sheet opens with library

**Verify:**
- ✅ Only shows rooms you selected during onboarding
- ✅ Each room has auto-added chores marked "Added"
- ✅ Library-only chores show "+" icon
- ✅ Tap a non-added chore → Toast shows "Added to [Room]"
- ✅ Row updates to "Added" state instantly
- ✅ Toast auto-dismisses after 2 seconds

**Expected Behavior:**
- If all presets added → Shows empty state
- Added chores are not tappable (disabled)
- Smart scheduling puts chore on least-busy day

---

### **3. Chore Completion & Streaks**

**Test Steps:**
1. Go to **Home** tab
2. Tap circle next to a chore to complete it
   - ✅ Checkmark appears
   - ✅ Confetti animation plays
   - ✅ Week progress updates
   - ✅ Streak badge updates (if applicable)
3. Complete chores for multiple days
   - ✅ Streak counter increments
   - ✅ At 7 days: "7-day streak!" activity log

**Expected Behavior:**
- Bounce animation on checkmark
- Toast for badge unlocks
- Progress bar animates smoothly

---

### **4. Preset Auto-Add (Onboarding)**

**Test Steps:**
1. Reset app (delete and reinstall)
2. Complete onboarding
3. **At room selection step:**
   - Select Kitchen + Bedroom
   - ✅ Should auto-add 4 chores (2 per room)
   - Deselect Kitchen
   - ✅ Those 2 chores removed
   - Reselect Kitchen
   - ✅ 2 chores added back
4. Finish onboarding
5. Check Dashboard
   - ✅ 4 chores appear
   - ✅ Scheduled across days 1-4 (one per day)

**Expected Behavior:**
- Chores are real, editable instances
- First occurrence spread evenly
- Weekly recurrence after first

---

### **5. Snooze Functionality**

**Test Steps:**
1. Set mood to **"Too much"**
2. If you have 3+ undone chores:
   - ✅ "Push X to tomorrow" button appears
3. Tap button
   - ✅ Confirmation shows
   - ✅ Hidden chores moved to tomorrow
   - ✅ Check Calendar tab → See rescheduled chores

**Expected Behavior:**
- Button only shows when hiddenCount > 0
- Snooze confirmed state persists during session
- Chores actually moved (check `scheduledDate`)

---

### **6. Badges & Activity Log**

**Test Steps:**
1. Complete your first chore
   - ✅ Badge toast appears: "First chore! unlocked!"
   - ✅ Check Profile → Badge shows in grid
2. Complete 5 days in a row
   - ✅ "5-day streak" badge unlocks
3. Go to Profile
   - ✅ All earned badges visible
   - ✅ Locked badges grayed out
   - ✅ Descriptions shown

**Expected Behavior:**
- Badge check runs after each completion
- Only newly earned badges trigger toast
- Profile shows all 7 badge slots

---

### **7. Swipe Actions**

**Test Steps:**
1. Go to **Chores** tab
2. Swipe left on any chore
   - ✅ Red delete button appears
3. Tap delete
   - ✅ Chore removed from list
   - ✅ Persists after app restart

**Expected Behavior:**
- Smooth swipe animation
- Destructive role (red color)
- Confirmation not required (full swipe allowed)

---

### **8. Calendar Navigation**

**Test Steps:**
1. Go to **Calendar** tab
2. Tap different dates
   - ✅ Shows chores for that date
3. Swipe month view
   - ✅ Previous/next months load
4. Dots on dates indicate chores

**Expected Behavior:**
- Current date highlighted
- Selected date updates view
- Empty dates show no chores

---

### **9. Data Persistence**

**Test Steps:**
1. Add a chore
2. Toggle it complete
3. **Quit app** (⌘Q in simulator)
4. **Relaunch** (⌘R)
   - ✅ Chore still exists
   - ✅ Completion state preserved
   - ✅ Streak maintained

**Expected Behavior:**
- All changes saved to UserDefaults
- No data loss on restart
- Profile settings preserved

---

### **10. Empty States**

**Test Empty Library:**
1. Add every single preset chore
2. Go to Chore Library
   - ✅ Shows: "You've added everything from the library"
   - ✅ No room sections visible

**Test Empty Today:**
1. Delete all today's chores
2. Go to Home
   - ✅ Shows: "Nothing due today"
   - ✅ Helpful message displayed

---

## 🐛 **Known Edge Cases to Test**

### **Scenario 1: No Chores on Day 1**
- Complete onboarding
- Check Dashboard immediately
- **Expected:** Some chores scheduled for "tomorrow" (day 1 after onboarding)

### **Scenario 2: Re-adding Deleted Preset**
- Add "Clear the sink" from library
- Delete it from Chores list
- Go back to library
- **Expected:** Shows as "Add" again (can re-add)

### **Scenario 3: Load Balancing**
- Add 10 chores on same day
- Add new preset from library
- Check Calendar
- **Expected:** New chore scheduled on a lighter day

### **Scenario 4: Mood Pill Toggle**
- Select "Too much"
- Tap it again
- **Expected:** Deselects, returns to showing all chores

### **Scenario 5: Week Progress**
- Complete 3 out of 10 weekly chores
- **Expected:** Progress bar shows 30%
- Complete 7 more
- **Expected:** Shows 100%, gradient fills completely

---

## 📊 **Performance Checks**

### **Smooth Animations:**
- [ ] Mood pill selection
- [ ] Chore checkmark bounce
- [ ] Confetti overlay
- [ ] Toast slide-up
- [ ] Progress bar fill
- [ ] Sheet presentations

### **No Lag:**
- [ ] Chore list scrolling
- [ ] Tab switching
- [ ] Calendar swiping
- [ ] Library browsing

### **Memory:**
- [ ] No crashes after extensive use
- [ ] Confetti cleans up after 2 seconds
- [ ] Activity log caps at 20 entries

---

## 🎯 **Quick Verification Script**

**Run this test in 5 minutes:**

```
1. ✅ Delete app, reinstall
2. ✅ Complete onboarding (select all 4 rooms)
3. ✅ Land on Dashboard → See 8 chores
4. ✅ Tap "Too much" → See 1 chore
5. ✅ Tap "Snooze" → Chores moved
6. ✅ Go to Chores tab → Tap "Browse library"
7. ✅ Add "Take out trash" → Toast appears
8. ✅ Row updates to "Added"
9. ✅ Go back → See new chore in list
10. ✅ Complete a chore → Confetti plays
11. ✅ Check Profile → Badge unlocked
12. ✅ Quit and relaunch → Data persists
```

**If all ✅ pass → App is fully functional!**

---

## 🚨 **Troubleshooting Common Issues**

### **"Chores not showing"**
- Check if onboarding completed
- Verify `appState.todayChores` has data
- Check date formatting (yyyy-MM-dd)

### **"Library shows empty"**
- Verify user has rooms selected
- Check PresetChoreLibrary.all is populated
- Ensure profile.rooms array not empty

### **"Confetti not playing"**
- Check `pendingConfettiEvent` is set
- Verify ConfettiOverlay is in view hierarchy
- HomeView must observe appState

### **"Data not persisting"**
- LocalStore.shared.saveChores() called?
- Check UserDefaults keys match
- Verify JSON encoding succeeds

### **"Previews not working"**
- Press ⌥⌘↩ to show Canvas
- Check AppFlowPreviews.swift exists
- Ensure @StateObject wrappers correct

---

## ✅ **Final Checklist**

- [ ] All 4 tabs navigate correctly
- [ ] Onboarding completes and seeds data
- [ ] Dashboard mood pills work
- [ ] Chore library browse & add works
- [ ] Chores complete with confetti
- [ ] Badges unlock and display
- [ ] Data persists across launches
- [ ] Empty states show properly
- [ ] Swipe actions work
- [ ] Calendar displays correctly
- [ ] Profile shows user info
- [ ] Settings update and save

---

## 🎉 **You're Ready!**

If you've tested the above and everything works:
- Your app is **production-ready** for basic use
- All core features functional
- Data persistence working
- UI polished and responsive

**Next steps:**
- Upload to GitHub (see GITHUB_SETUP.md)
- Add more features from roadmap
- Test on physical device
- Consider TestFlight beta

---

**Questions?** Run through the Quick Verification Script first, then let me know which specific feature isn't working!

# Screen Update Roadmap

This document provides a checklist for updating all remaining screens to match the new UI design.

## ✅ Completed Screens

- [x] **Login Screen** - Fully redesigned with new components
- [x] **Owner Dashboard** - Updated with EnhancedCard and AlertCard

---

## 📋 Screens to Update

### Driver Dashboard
**File**: `lib/screens/driver/driver_dashboard.dart`

**Changes Needed**:
- [ ] Replace old cards with `EnhancedCard`
- [ ] Add theme color support (remove hardcoded colors)
- [ ] Use `StatusBadge` for trip status displays
- [ ] Apply `AppTheme` text styles
- [ ] Update AppBar to use theme surface color

**Example Pattern**:
```dart
// OLD
Card(
  color: Colors.blue,
  child: ListTile(title: Text('Trip')),
)

// NEW
EnhancedCard(
  title: 'Active Trips',
  value: '5',
  icon: Icons.map,
  onTap: () => Navigator.pushNamed(context, route),
)
```

---

### Employee Dashboard
**File**: `lib/screens/employee/employee_dashboard.dart`

**Changes Needed**:
- [ ] Replace old card layouts with `EnhancedCard`
- [ ] Use theme colors from `colorScheme`
- [ ] Update text styles to use `AppTheme`
- [ ] Add status badges where appropriate
- [ ] Test dark mode compatibility

---

### Car Management Screen
**File**: `lib/screens/car/car_*.dart`

**Changes Needed**:
- [ ] Update list tiles with theme colors
- [ ] Add `StatusBadge` for vehicle status
- [ ] Use `EnhancedCard` for summary stats
- [ ] Apply consistent spacing (16px padding)
- [ ] Update buttons to use theme colors
- [ ] Test in dark mode

---

### Trip Management Screen
**File**: `lib/screens/trip/trip_*.dart`

**Changes Needed**:
- [ ] Replace trip cards with enhanced design
- [ ] Add status indicators with `StatusBadge`
- [ ] Use `AlertCard` for trip alerts
- [ ] Apply theme colors consistently
- [ ] Update trip detail views
- [ ] Add gradient backgrounds where appropriate

---

### Payment/Billing Screens
**File**: `lib/screens/payment/*.dart` and `lib/screens/billing/*.dart`

**Changes Needed**:
- [ ] Update payment list cards
- [ ] Use `StatusBadge` for payment status
- [ ] Apply `EnhancedCard` for summaries
- [ ] Use theme colors for highlights
- [ ] Update typography to `AppTheme` styles
- [ ] Test both light and dark modes

---

### Leave Management Screen
**File**: `lib/screens/leave/leave_*.dart`

**Changes Needed**:
- [ ] Update leave request cards
- [ ] Add `StatusBadge` for approval status
- [ ] Use `EnhancedCard` for statistics
- [ ] Apply consistent theme colors
- [ ] Update form layouts
- [ ] Dark mode testing

---

### Driver Payroll Screen
**File**: `lib/screens/driver/payroll.dart`

**Changes Needed**:
- [ ] Update payroll tables/cards
- [ ] Use theme colors for amounts
- [ ] Add `StatusBadge` for payment status
- [ ] Apply `AppTheme` typography
- [ ] Update button styles
- [ ] Test responsiveness

---

## 🔄 Update Procedure for Each Screen

### Step 1: Update Imports
```dart
// Add these imports at the top
import '../../widgets/enhanced_card.dart';
import '../../widgets/alert_card.dart' as alert_widget;
import '../../widgets/status_badge.dart';
```

### Step 2: Replace Cards
```dart
// Instead of:
Card(
  color: Colors.white,
  child: ListTile(...)
)

// Use:
Container(
  decoration: BoxDecoration(
    color: Theme.of(context).colorScheme.surface,
    border: Border.all(color: Theme.of(context).colorScheme.outline),
    borderRadius: BorderRadius.circular(12),
  ),
  child: ListTile(...)
)

// Or better, use EnhancedCard for summary data:
EnhancedCard(
  title: 'Label',
  value: 'Value',
  icon: Icons.icon,
)
```

### Step 3: Update Colors
```dart
// Replace hardcoded colors
// OLD: color: Colors.blue
// NEW: color: Theme.of(context).colorScheme.primary

// OLD: color: Colors.red
// NEW: color: Theme.of(context).colorScheme.error

// OLD: color: Colors.green
// NEW: color: AppColors.success
```

### Step 4: Add Status Badges
```dart
// For any status displays
StatusBadge(status: item.status)

// Automatically handles coloring and icons
```

### Step 5: Update Typography
```dart
// OLD: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
// NEW: AppTheme.subHeading

// OLD: TextStyle(fontSize: 14)
// NEW: AppTheme.body

// See AppTheme class for all available styles
```

### Step 6: Test Dark Mode
1. Run app
2. Go to device settings → Display → Dark theme (enable)
3. Verify all colors are readable
4. Check contrast ratios (should be ≥4.5:1)

---

## 📊 Priority Order for Updates

### High Priority (User-facing dashboards)
1. Driver Dashboard
2. Employee Dashboard
3. Owner Dashboard ✅

### Medium Priority (Data management)
1. Car Management
2. Trip Management
3. Payment/Billing

### Low Priority (Utilities)
1. Leave Management
2. Payroll
3. Settings

---

## ✨ Pro Tips

1. **Copy-paste from Login Screen**
   - The login screen is fully updated
   - Copy patterns from there for new screens

2. **Use EnhancedCard for Metrics**
   - Perfect for "5 Active Trips", "24 Vehicles" displays
   - Automatically handles theming

3. **Always get ColorScheme**
   - `final colorScheme = Theme.of(context).colorScheme;`
   - Use this for ALL color references

4. **Use StatusBadge for Status**
   - Don't manually handle status colors
   - Just pass status string to `StatusBadge`

5. **Test Immediately**
   - After each screen update, test in both light & dark modes
   - No additional code needed for dark mode!

---

## 🧪 Testing Checklist for Each Screen

- [ ] Light mode: All colors visible and correct
- [ ] Dark mode: All colors visible and correct
- [ ] No hardcoded colors (all from theme)
- [ ] Text is readable on all backgrounds
- [ ] Buttons are clickable (48x48 minimum)
- [ ] Status badges show correct colors
- [ ] Cards have proper spacing
- [ ] Responsive on different screen sizes
- [ ] No console warnings about unused imports

---

## 📖 Documentation Files

Refer to these for detailed guidance:
- `QUICK_REFERENCE.md` - Component usage with examples
- `UI_UX_OPTIMIZATION.md` - Design principles and standards
- `IMPLEMENTATION_SUMMARY.md` - What was changed and why

---

## 🚀 Next Steps

1. **Pick the next screen** from High Priority list
2. **Follow the Update Procedure** step by step
3. **Reference QUICK_REFERENCE.md** for component usage
4. **Test in both light and dark modes**
5. **Commit and push to version control**

---

**Estimated time per screen**: 15-30 minutes (including testing)

**Total estimated time**: 3-4 hours for all remaining screens

---

Good luck! 🎉

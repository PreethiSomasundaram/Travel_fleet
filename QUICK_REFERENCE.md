# Quick Reference - UI Components & Usage

## 🎨 Available Components

### 1. EnhancedCard
**Purpose**: Display key metrics or data in an attractive card format

**Location**: `lib/widgets/enhanced_card.dart`

**Usage**:
```dart
import '../../widgets/enhanced_card.dart';

EnhancedCard(
  title: 'Active Vehicles',
  value: '24',
  icon: Icons.directions_car,
  backgroundColor: Colors.blue.withOpacity(0.1),
  onTap: () => Navigator.pushNamed(context, route),
)
```

**Props**:
- `title` (String, required): Label for the card
- `value` (String, required): Main value display
- `icon` (IconData, required): Icon to display
- `backgroundColor` (Color?): Custom background color
- `gradient` (Gradient?): Custom gradient
- `onTap` (VoidCallback?): Tap handler
- `trailing` (Widget?): Custom trailing widget
- `showBorder` (bool): Show/hide border

---

### 2. AlertCard
**Purpose**: Display alerts/notifications with severity levels

**Location**: `lib/widgets/alert_card.dart`

**Usage**:
```dart
import '../../widgets/alert_card.dart' as alert_widget;

alert_widget.AlertCard(
  title: 'Vehicle Maintenance',
  message: 'Vehicle TX-001 needs service',
  severity: alert_widget.AlertSeverity.warning,
  onDismiss: () => setState(() => alerts.removeWhere((a) => a.id == alert.id)),
  onTap: () => Navigator.pushNamed(context, detailRoute),
)
```

**Severity Levels**:
- `AlertSeverity.info` → Blue info icon
- `AlertSeverity.warning` → Amber warning icon
- `AlertSeverity.critical` → Red error icon

**Props**:
- `title` (String, required): Alert title
- `message` (String, required): Alert message
- `severity` (AlertSeverity, required): Severity level
- `onDismiss` (VoidCallback?): Dismiss handler
- `onTap` (VoidCallback?): Tap handler

---

### 3. StatusBadge
**Purpose**: Display status with auto-colored badge

**Location**: `lib/widgets/status_badge.dart`

**Usage**:
```dart
import '../../widgets/status_badge.dart';

StatusBadge(status: 'completed')  // Green ✓
StatusBadge(status: 'pending')    // Amber ⏱
StatusBadge(status: 'failed')     // Red ✕
```

**Supported Statuses**:
- `completed` / `paid` → ✓ Green
- `active` / `approved` → ✓ Green
- `pending` / `in_progress` → ⏱ Amber
- `cancelled` / `rejected` / `failed` → ✕ Red

**Props**:
- `status` (String, required): Status string
- `filled` (bool): Filled or outline variant

---

### 4. ModernAppBar
**Purpose**: Consistent header with optional back button

**Location**: `lib/widgets/modern_app_bar.dart`

**Usage**:
```dart
import '../../widgets/modern_app_bar.dart';

ModernAppBar(
  title: 'Fleet Management',
  showBackButton: true,
  actions: [
    IconButton(icon: Icon(Icons.menu), onPressed: () {}),
  ],
)
```

**Props**:
- `title` (String, required): App bar title
- `actions` (List<Widget>?): Right-side actions
- `showBackButton` (bool): Show back button
- `onBackPressed` (VoidCallback?): Back button handler
- `leading` (Widget?): Custom leading widget
- `elevation` (double): Shadow depth

---

### 5. InputField
**Purpose**: Enhanced text input with validation

**Location**: `lib/widgets/input_field.dart`

**Usage**:
```dart
import '../../widgets/input_field.dart';

InputField(
  label: 'Email',
  controller: emailCtrl,
  prefixIcon: Icons.email,
  validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
)

InputField(
  label: 'Password',
  controller: passwordCtrl,
  prefixIcon: Icons.lock,
  isPassword: true,
  validator: (v) => v?.length ?? 0 < 6 ? 'Min 6 chars' : null,
)
```

**Props**:
- `label` (String, required): Field label
- `controller` (TextEditingController, required): Input controller
- `prefixIcon` (IconData?): Left icon
- `isPassword` (bool): Show/hide toggle
- `validator` (Function?): Validation callback
- `readOnly` (bool): Disable editing
- `suffixIcon` (Widget?): Custom right widget
- `keyboardType` (TextInputType): Keyboard type
- `maxLines` (int): Max lines

---

## 🎨 Using Theme Colors

Always use theme colors for consistency across light/dark modes:

```dart
final colorScheme = Theme.of(context).colorScheme;

// Primary actions
backgroundColor: colorScheme.primary,

// Secondary actions
backgroundColor: colorScheme.secondary,

// Text colors
textColor: colorScheme.onSurface,
hintColor: colorScheme.onSurface.withOpacity(0.6),

// Backgrounds
backgroundColor: colorScheme.surface,

// Borders
borderColor: colorScheme.outline,
```

---

## 📝 Typography Styles

```dart
import '../../core/theme.dart';

Text('Page Title', style: AppTheme.heading)        // 26px Bold
Text('Section', style: AppTheme.subHeading)        // 18px Semi-bold
Text('Regular text', style: AppTheme.body)         // 14px Medium
Text('Secondary text', style: AppTheme.bodySmall)  // 13px Regular
Text('Helper text', style: AppTheme.caption)       // 12px Regular
```

---

## 🎯 Color Utilities

```dart
import '../../core/colors.dart';

// Get color by status
Color color = AppColors.getStatusColor('completed'); // Green

// Get icon by status
IconData icon = AppColors.getStatusIcon('pending'); // Schedule icon

// Gradients
decoration: BoxDecoration(
  gradient: AppColors.primaryGradient,
)

decoration: BoxDecoration(
  gradient: AppColors.successGradient,
)
```

---

## 📏 Spacing Constants

```dart
// Use these for consistent spacing
const SizedBox(height: 24) // Extra large gaps (section spacing)
const SizedBox(height: 16) // Large gaps (card padding)
const SizedBox(height: 12) // Medium gaps (component gaps)
const SizedBox(height: 8)  // Small gaps (element spacing)
```

---

## 🎪 Complete Example Screen

```dart
import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../widgets/enhanced_card.dart';
import '../../widgets/alert_card.dart' as alert_widget;
import '../../widgets/status_badge.dart';

class ExampleScreen extends StatefulWidget {
  @override
  State<ExampleScreen> createState() => _ExampleScreenState();
}

class _ExampleScreenState extends State<ExampleScreen> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Example Screen'),
        backgroundColor: colorScheme.surface,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header
          Text('Welcome', style: AppTheme.heading),
          const SizedBox(height: 24),
          
          // Data cards
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: [
              EnhancedCard(
                title: 'Metric 1',
                value: '42',
                icon: Icons.trending_up,
              ),
              EnhancedCard(
                title: 'Metric 2',
                value: '89',
                icon: Icons.trending_up,
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Status badges
          Text('Statuses', style: AppTheme.subHeading),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              StatusBadge(status: 'completed'),
              StatusBadge(status: 'pending'),
              StatusBadge(status: 'failed'),
            ],
          ),
          const SizedBox(height: 24),
          
          // Alerts
          Text('Alerts', style: AppTheme.subHeading),
          const SizedBox(height: 8),
          alert_widget.AlertCard(
            title: 'Important Update',
            message: 'This is a sample alert message',
            severity: alert_widget.AlertSeverity.info,
          ),
        ],
      ),
    );
  }
}
```

---

## 🌙 Dark Mode

The app automatically supports dark mode. Just test in:

**Android**: Settings → Display → Dark theme
**iOS**: Settings → Display & Brightness → Dark mode

No additional code needed! All components adapt automatically.

---

## 📚 Need More Help?

- See `UI_UX_OPTIMIZATION.md` for design documentation
- See `IMPLEMENTATION_SUMMARY.md` for what was changed
- Check component source files in `lib/widgets/`
- Review `lib/core/theme.dart` for theme definition

---

**Happy coding! 🎉**

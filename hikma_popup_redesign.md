# Hikma — Popup Redesign Guide
## Implementation Plan v2.0

---

## المشكلة الحالية

الـ `HadithPopupOverlay` شغال كـ dialog جوه نفس الـ Flutter window — يعني لو الـ app مخفي في الـ menu bar، الـ popup مش بيظهر. ده مش السلوك الصح.

---

## الهدف

نحول الـ popup من dialog لـ **native floating NSWindow منفصلة** تظهر فوق كل حاجة على الشاشة — بالظبط زي macOS system notifications.

---

## 1. Architecture Change — Separate Window

### المشكلة في الكود الحالي
```dart
// ❌ الطريقة القديمة — جوه نفس الـ window
void _showPopup(Hadith hadith) {
  Navigator.of(context).push(
    PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) {
        return HadithPopupOverlay(hadith: hadith);
      },
      opaque: false,
    ),
  );
}
```

### الحل — `popup_window_manager.dart`

إنشاء ملف جديد: `lib/core/utils/popup_window_manager.dart`

```dart
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';

class PopupWindowManager {
  static const double popupWidth = 420.0;
  static const double popupHeight = 280.0; // fixed height
  
  /// فتح نافذة الـ popup المنفصلة
  static Future<void> showHadithPopup({
    required Hadith hadith,
    required PopupPosition position,
  }) async {
    // إنشاء نافذة جديدة منفصلة
    // استخدام window_manager لإنشاء floating window
    await windowManager.setPosition(
      Offset(position.dx, position.dy),
    );
    await windowManager.setSize(
      const Size(popupWidth, popupHeight),
    );
    await windowManager.setAlwaysOnTop(true);
    await windowManager.setAsFrameless();
    await windowManager.setHasShadow(true);
    
    // تطبيق الـ frosted glass effect
    await Window.setEffect(
      effect: WindowEffect.acrylic,
      color: const Color(0x20000000),
    );
    
    await windowManager.show();
    await windowManager.focus();
  }
}
```

> **ملاحظة مهمة:** الـ `window_manager` package بيتحكم في نافذة واحدة بس. عشان نعمل نافذتين (الـ main app + الـ popup)، محتاجين نستخدم **platform channels** أو **`macos_window_utils`** لإنشاء `NSPanel` منفصل. الطريقة الأفضل موضحة في القسم 1.1.

---

### 1.1 الحل الصح — NSPanel via Platform Channel

إنشاء ملف: `macos/Runner/PopupWindowController.swift`

```swift
import Cocoa
import FlutterMacOS

class PopupWindowController: NSWindowController {
    
    static var shared: PopupWindowController?
    var flutterEngine: FlutterEngine?
    var methodChannel: FlutterMethodChannel?
    
    static func showPopup(
        hadithData: [String: Any],
        position: CGPoint,
        duration: TimeInterval
    ) {
        // إنشاء NSPanel — يظهر فوق كل حاجة حتى في fullscreen
        let panel = NSPanel(
            contentRect: NSRect(x: position.x, y: position.y, width: 420, height: 280),
            styleMask: [.nonactivatingPanel, .fullSizeContentView, .borderless],
            backing: .buffered,
            defer: false
        )
        
        panel.level = .floating          // يظهر فوق النوافذ العادية
        panel.isOpaque = false           // شفافية
        panel.backgroundColor = .clear  // خلفية شفافة
        panel.hasShadow = true          // ظل
        panel.isMovableByWindowBackground = true  // قابل للسحب
        panel.collectionBehavior = [
            .canJoinAllSpaces,           // يظهر في كل الـ spaces
            .fullScreenAuxiliary         // يظهر حتى في fullscreen
        ]
        
        // تطبيق الـ visual effect (frosted glass)
        let visualEffect = NSVisualEffectView()
        visualEffect.material = .hudWindow        // أو .underWindowBackground
        visualEffect.blendingMode = .behindWindow
        visualEffect.state = .active
        visualEffect.wantsLayer = true
        visualEffect.layer?.cornerRadius = 16
        
        panel.contentView = visualEffect
        
        // إضافة Flutter view جوا الـ panel
        let controller = PopupWindowController(window: panel)
        shared = controller
        panel.makeKeyAndOrderFront(nil)
        
        // Auto-dismiss بعد الـ duration المحدد
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            controller.closePopup()
        }
    }
    
    func closePopup() {
        window?.orderOut(nil)
        PopupWindowController.shared = nil
    }
    
    func moveToPosition(_ position: CGPoint) {
        window?.setFrameOrigin(position)
    }
}
```

---

## 2. الـ Popup UI — التصميم الجديد

### الملف: `lib/ui/popup/notification_popup.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

class NotificationPopup extends StatefulWidget {
  final Hadith hadith;
  final Duration displayDuration;
  final VoidCallback onDismiss;
  final VoidCallback onFavorite;
  final bool isFavorited;

  const NotificationPopup({
    super.key,
    required this.hadith,
    required this.displayDuration,
    required this.onDismiss,
    required this.onFavorite,
    this.isFavorited = false,
  });

  @override
  State<NotificationPopup> createState() => _NotificationPopupState();
}

class _NotificationPopupState extends State<NotificationPopup>
    with TickerProviderStateMixin {
  
  // Slide-in animation
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  
  // Progress circle animation
  late AnimationController _progressController;
  
  // Hover state
  bool _isHovered = false;
  bool _buttonsVisible = false;

  @override
  void initState() {
    super.initState();
    
    // Slide + Fade in
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.2, 0), // يجي من اليمين
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _slideController,
        curve: const Interval(0, 0.5),
      ),
    );
    
    // Progress circle
    _progressController = AnimationController(
      duration: widget.displayDuration,
      vsync: this,
    );
    
    // ابدأ الـ animations
    _slideController.forward();
    _progressController.forward().then((_) {
      if (!_isHovered) _dismiss();
    });
  }

  void _dismiss() async {
    // Slide out to the right
    await _slideController.reverse();
    widget.onDismiss();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: MouseRegion(
          onEnter: (_) {
            setState(() {
              _isHovered = true;
              _buttonsVisible = true;
            });
            _progressController.stop(); // وقف الـ timer لما الماوس فوقيه
          },
          onExit: (_) {
            setState(() {
              _isHovered = false;
              _buttonsVisible = false;
            });
            _progressController.forward(); // كمل الـ timer
          },
          child: Container(
            width: 420,
            constraints: const BoxConstraints(
              minHeight: 160,
              maxHeight: 280,
            ),
            decoration: BoxDecoration(
              // خلفية شفافة — الـ frosted glass بيجي من الـ NSVisualEffectView
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  // المحتوى الأساسي
                  _buildContent(),
                  
                  // Progress Circle في الكورنر
                  Positioned(
                    top: 12,
                    left: 12,
                    child: _buildProgressCircle(),
                  ),
                  
                  // زرار الإغلاق
                  Positioned(
                    top: 8,
                    right: 8,
                    child: _buildCloseButton(),
                  ),
                  
                  // Action Buttons تظهر عند الـ hover
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: _buildActionBar(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 56),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Arabic text — RTL
          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Text(
                  widget.hadith.arabicText,
                  style: GoogleFonts.notoNaskhArabic(
                    fontSize: 20,
                    height: 2.0,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.justify,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Citation — بخط صغير في الأسفل
          _buildCitation(),
        ],
      ),
    );
  }

  Widget _buildCitation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Collection badge
        _CitationBadge(
          icon: Icons.menu_book_rounded,
          label: widget.hadith.collection.displayName,
        ),
        const SizedBox(width: 6),
        // Hadith number badge
        _CitationBadge(
          icon: Icons.tag,
          label: '${widget.hadith.hadithNumber}',
        ),
      ],
    );
  }

  Widget _buildProgressCircle() {
    return AnimatedBuilder(
      animation: _progressController,
      builder: (context, child) {
        return SizedBox(
          width: 28,
          height: 28,
          child: CustomPaint(
            painter: _CircularProgressPainter(
              progress: 1 - _progressController.value,
              color: Colors.white.withValues(alpha: 0.9),
              strokeWidth: 2.5,
            ),
          ),
        );
      },
    );
  }

  Widget _buildCloseButton() {
    return AnimatedOpacity(
      opacity: _isHovered ? 1.0 : 0.5,
      duration: const Duration(milliseconds: 200),
      child: GestureDetector(
        onTap: _dismiss,
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.2),
          ),
          child: const Icon(
            Icons.close_rounded,
            size: 14,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildActionBar() {
    return AnimatedSlide(
      offset: _buttonsVisible ? Offset.zero : const Offset(0, 1),
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      child: AnimatedOpacity(
        opacity: _buttonsVisible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.25),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _HoverActionButton(
                icon: widget.isFavorited
                    ? Icons.star_rounded
                    : Icons.star_border_rounded,
                label: 'Save',
                onTap: widget.onFavorite,
                isActive: widget.isFavorited,
                activeColor: const Color(0xFFFFD700),
              ),
              _HoverActionButton(
                icon: Icons.copy_rounded,
                label: 'Copy',
                onTap: () => _copyHadith(),
              ),
              _HoverActionButton(
                icon: Icons.skip_next_rounded,
                label: 'Next',
                onTap: () {
                  // Fetch next hadith
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _copyHadith() {
    // Copy to clipboard
  }
}
```

---

## 3. الـ Circular Progress Painter

```dart
class _CircularProgressPainter extends CustomPainter {
  final double progress; // 0.0 → 1.0
  final Color color;
  final double strokeWidth;

  const _CircularProgressPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background circle (dim)
    final bgPaint = Paint()
      ..color = color.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,           // يبدأ من فوق
      2 * math.pi * progress, // يدور بالـ progress
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_CircularProgressPainter old) =>
      old.progress != progress;
}
```

---

## 4. الـ Hover Action Button

```dart
class _HoverActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;
  final Color? activeColor;

  const _HoverActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
    this.activeColor,
  });

  @override
  State<_HoverActionButton> createState() => _HoverActionButtonState();
}

class _HoverActionButtonState extends State<_HoverActionButton>
    with SingleTickerProviderStateMixin {
  
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _glowAnim;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _glowAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _controller.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _controller.reverse();
      },
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) {
          _controller.reverse();
          widget.onTap();
        },
        onTapCancel: () => _controller.reverse(),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return ScaleTransition(
              scale: _scaleAnim,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: _isHovered
                      ? Colors.white.withValues(alpha: 0.2)
                      : Colors.transparent,
                  // Glow effect عند الـ hover
                  boxShadow: _isHovered
                      ? [
                          BoxShadow(
                            color: (widget.activeColor ?? Colors.white)
                                .withValues(alpha: 0.3 * _glowAnim.value),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                  border: Border.all(
                    color: _isHovered
                        ? Colors.white.withValues(alpha: 0.3)
                        : Colors.transparent,
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      widget.icon,
                      size: 18,
                      color: widget.isActive
                          ? widget.activeColor ?? Colors.white
                          : Colors.white.withValues(alpha: _isHovered ? 1.0 : 0.8),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.label,
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.white.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
```

---

## 5. الـ Citation Badge Widget

```dart
class _CitationBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _CitationBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.15),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: Colors.white.withValues(alpha: 0.7)),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.white.withValues(alpha: 0.7),
              fontWeight: FontWeight.w400,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## 6. الـ Default Position Logic

### في `lib/core/utils/position_utils.dart` — إضافة:

```dart
/// الموقع الافتراضي — bottom-right مع margin من الحواف
static Future<PopupPosition> getDefaultNotificationPosition() async {
  final screenSize = await _getScreenSize();
  const popupWidth = 420.0;
  const popupHeight = 280.0;
  const margin = 24.0;
  
  // Bottom-right كـ default (زي macOS notifications)
  return PopupPosition(
    screenSize.width - popupWidth - margin,   // dx
    screenSize.height - popupHeight - margin, // dy
  );
}

/// التأكد إن الموقع جوه الشاشة
static Future<PopupPosition> clampToScreen(PopupPosition position) async {
  final screenSize = await _getScreenSize();
  const popupWidth = 420.0;
  const popupHeight = 280.0;
  const margin = 8.0;
  
  return PopupPosition(
    position.dx.clamp(margin, screenSize.width - popupWidth - margin),
    position.dy.clamp(margin, screenSize.height - popupHeight - margin),
  );
}
```

---

## 7. تعديل Settings Screen — إضافة Popup Position Picker

في `lib/ui/screens/settings_screen.dart` — إضافة setting جديد:

```dart
// في داخل الـ Hadith section
_buildPopupPositionTile(settings),
```

```dart
Widget _buildPopupPositionTile(UserSettings settings) {
  // خريطة صغيرة تبين الشاشة وإنت تختار الكورنر
  return ListTile(
    leading: const Icon(Icons.open_with_rounded),
    title: const Text('Popup Position'),
    subtitle: const Text('Choose where the popup appears'),
    trailing: const Icon(Icons.chevron_right),
    onTap: () => _showPositionPicker(context),
  );
}

void _showPositionPicker(BuildContext context) {
  showModalBottomSheet(
    context: context,
    builder: (context) => _PopupPositionPicker(),
  );
}
```

```dart
class _PopupPositionPicker extends StatelessWidget {
  // 4 corners + center — user يختار
  final _positions = [
    ('Top Left', Icons.north_west),
    ('Top Right', Icons.north_east),
    ('Bottom Left', Icons.south_west),
    ('Bottom Right', Icons.south_east), // الـ default
    ('Center', Icons.center_focus_strong),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Popup Position',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          // Screen preview مع الـ 4 corners
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Stack(
                children: [
                  // Top-left
                  Positioned(top: 8, left: 8,
                      child: _CornerButton(label: 'TL')),
                  // Top-right
                  Positioned(top: 8, right: 8,
                      child: _CornerButton(label: 'TR')),
                  // Bottom-left
                  Positioned(bottom: 8, left: 8,
                      child: _CornerButton(label: 'BL')),
                  // Bottom-right (selected by default)
                  Positioned(bottom: 8, right: 8,
                      child: _CornerButton(label: 'BR', isSelected: true)),
                  // Center
                  Center(
                      child: _CornerButton(label: 'C')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## 8. الـ Scheduler Fix

### المشكلة في `scheduler_bloc.dart`

الـ scheduler بيعمل `ShowPopup(hadithId: '')` بـ hadithId فاضي ومش بيحمل الـ hadith الحقيقي. الحل:

```dart
// ❌ المشكلة
_popupDelayTimer = Timer(const Duration(milliseconds: 500), () {
  final hadithState = _hadithBloc.state;
  if (hadithState is HadithLoaded) {
    _popupBloc.add(const ShowPopup(hadithId: ''));  // ← hadithId فاضي!
  }
});

// ✅ الحل
_popupDelayTimer = Timer(const Duration(milliseconds: 500), () {
  final hadithState = _hadithBloc.state;
  if (hadithState is HadithLoaded) {
    _popupBloc.add(ShowPopup(hadithId: hadithState.hadith.id)); // ← الـ id الصح
  }
});
```

---

## 9. الـ Sound

دلوقتي بتستخدم `audioplayers`. خليه زي ما هو بس غير الـ sound file:

```dart
// في audio_service.dart
Future<void> playNotificationSound() async {
  await init();
  try {
    // استخدم macOS system sound بدل custom file
    await _player.play(AssetSource('sounds/notification.mp3'));
    // لو مفيش ملف — silent fail
  } catch (_) {}
}
```

> لاحقاً ممكن تضيف صوت إسلامي خفيف أو تاخد الـ macOS default notification sound من `/System/Library/Sounds/`.

---

## 10. Additional UI Polish — لمسات جمالية إضافية

### 10.1 Entrance Animation Enhancement
```dart
// في _slideAnimation — استخدم spring physics
_slideAnimation = Tween<Offset>(
  begin: const Offset(1.2, 0),
  end: Offset.zero,
).animate(CurvedAnimation(
  parent: _slideController,
  curve: Curves.elasticOut, // spring effect خفيف
));
```

### 10.2 Subtle Background Gradient
```dart
// خلف الـ content — gradient خفيف يعطي عمق
decoration: BoxDecoration(
  gradient: LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Colors.white.withValues(alpha: 0.08),
      Colors.white.withValues(alpha: 0.03),
    ],
  ),
  borderRadius: BorderRadius.circular(16),
  border: Border.all(
    color: Colors.white.withValues(alpha: 0.1),
    width: 0.5,
  ),
),
```

### 10.3 Top Accent Line
```dart
// شريط رفيع جمالي في أعلى الـ popup
Container(
  height: 2,
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [
        Colors.transparent,
        const Color(0xFF1B4F72).withValues(alpha: 0.8),
        Colors.transparent,
      ],
    ),
    borderRadius: const BorderRadius.only(
      topLeft: Radius.circular(16),
      topRight: Radius.circular(16),
    ),
  ),
),
```

### 10.4 Hikma Logo في الـ Header
```dart
// أيقونة صغيرة + اسم التطبيق في أعلى يمين الـ popup
Positioned(
  top: 10,
  right: 40, // بجانب زرار الإغلاق
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(Icons.auto_stories_rounded,
          size: 12,
          color: Colors.white.withValues(alpha: 0.5)),
      const SizedBox(width: 4),
      Text(
        'hikma',
        style: TextStyle(
          fontSize: 10,
          color: Colors.white.withValues(alpha: 0.4),
          letterSpacing: 1.5,
          fontWeight: FontWeight.w300,
        ),
      ),
    ],
  ),
),
```

---

## ملخص الملفات اللي هتتعدل / تتضاف

| الملف | Action |
|-------|--------|
| `macos/Runner/PopupWindowController.swift` | **جديد** — NSPanel native window |
| `lib/core/utils/popup_window_manager.dart` | **جديد** — Flutter side للـ window |
| `lib/ui/popup/notification_popup.dart` | **جديد** — الـ UI الجديد كامل |
| `lib/core/utils/position_utils.dart` | **تعديل** — default + clamp position |
| `lib/bloc/scheduler/scheduler_bloc.dart` | **تعديل** — fix الـ hadithId الفاضي |
| `lib/ui/screens/settings_screen.dart` | **تعديل** — إضافة position picker |
| `lib/ui/popup/hadith_popup.dart` | **استبدال** بالـ notification_popup |
| `lib/main.dart` | **تعديل** — استخدام الـ popup manager الجديد |

---

## ترتيب التنفيذ المقترح

1. **أول حاجة:** إصلاح الـ `scheduler_bloc.dart` — الـ hadithId الفاضي (سهل وسريع)
2. **تاني حاجة:** إنشاء `PopupWindowController.swift` — الـ native NSPanel
3. **تالت حاجة:** إنشاء `notification_popup.dart` — الـ UI الجديد كامل
4. **رابع حاجة:** ربط الـ Swift مع Flutter عبر Platform Channel
5. **خامس حاجة:** تحديث الـ position logic + settings picker

---

*Hikma — حكمة | Built with intention. Guided by Sunnah.*

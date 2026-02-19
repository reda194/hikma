import 'package:equatable/equatable.dart';
import 'hadith_collection.dart';

/// UserSettings entity representing user configuration preferences
class UserSettings extends Equatable {
  final ReminderInterval reminderInterval;
  final PopupDuration popupDuration;
  final HadithCollection sourceCollection;
  final FontSize fontSize;
  final bool soundEnabled;
  final bool autoStartEnabled;
  final bool showInDock;
  final bool darkModeEnabled;
  final PopupPosition? popupPosition;
  final PopupPositionType popupPositionType;
  final int popupDisplayDuration;

  const UserSettings({
    this.reminderInterval = ReminderInterval.hour1,
    this.popupDuration = PopupDuration.minutes2,
    this.sourceCollection = HadithCollection.all,
    this.fontSize = FontSize.large,
    this.soundEnabled = false,
    this.autoStartEnabled = true,
    this.showInDock = false,
    this.darkModeEnabled = false,
    this.popupPosition,
    this.popupPositionType = PopupPositionType.bottomRight,
    this.popupDisplayDuration = 8,
  });

  UserSettings copyWith({
    ReminderInterval? reminderInterval,
    PopupDuration? popupDuration,
    HadithCollection? sourceCollection,
    FontSize? fontSize,
    bool? soundEnabled,
    bool? autoStartEnabled,
    bool? showInDock,
    bool? darkModeEnabled,
    PopupPosition? popupPosition,
    PopupPositionType? popupPositionType,
    int? popupDisplayDuration,
  }) {
    return UserSettings(
      reminderInterval: reminderInterval ?? this.reminderInterval,
      popupDuration: popupDuration ?? this.popupDuration,
      sourceCollection: sourceCollection ?? this.sourceCollection,
      fontSize: fontSize ?? this.fontSize,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      autoStartEnabled: autoStartEnabled ?? this.autoStartEnabled,
      showInDock: showInDock ?? this.showInDock,
      darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
      popupPosition: popupPosition ?? this.popupPosition,
      popupPositionType: popupPositionType ?? this.popupPositionType,
      popupDisplayDuration: popupDisplayDuration ?? this.popupDisplayDuration,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reminderInterval': reminderInterval.index,
      'popupDuration': popupDuration.index,
      'sourceCollection': sourceCollection.index,
      'fontSize': fontSize.index,
      'soundEnabled': soundEnabled,
      'autoStartEnabled': autoStartEnabled,
      'showInDock': showInDock,
      'darkModeEnabled': darkModeEnabled,
      if (popupPosition != null) 'popupPosition': popupPosition!.toJson(),
      'popupPositionType': popupPositionType.index,
      'popupDisplayDuration': popupDisplayDuration,
    };
  }

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      reminderInterval: ReminderInterval.fromIndex(
        json['reminderInterval'] as int? ?? 1,
      ),
      popupDuration: PopupDuration.fromIndex(
        json['popupDuration'] as int? ?? 2,
      ),
      sourceCollection: HadithCollection.fromIndex(
        json['sourceCollection'] as int? ?? 6,
      ),
      fontSize: FontSize.fromIndex(
        json['fontSize'] as int? ?? 2,
      ),
      soundEnabled: json['soundEnabled'] as bool? ?? false,
      autoStartEnabled: json['autoStartEnabled'] as bool? ?? true,
      showInDock: json['showInDock'] as bool? ?? false,
      darkModeEnabled: json['darkModeEnabled'] as bool? ?? false,
      popupPosition: json['popupPosition'] != null
          ? PopupPosition.fromJson(
              json['popupPosition'] as Map<String, dynamic>,
            )
          : null,
      popupPositionType: PopupPositionType.fromIndex(
        json['popupPositionType'] as int? ?? 3,
      ),
      popupDisplayDuration: json['popupDisplayDuration'] as int? ?? 8,
    );
  }

  @override
  List<Object?> get props => [
        reminderInterval,
        popupDuration,
        sourceCollection,
        fontSize,
        soundEnabled,
        autoStartEnabled,
        showInDock,
        darkModeEnabled,
        popupPosition,
        popupPositionType,
        popupDisplayDuration,
      ];
}

/// ReminderInterval enum for popup scheduling
enum ReminderInterval {
  minutes30,
  hour1,
  hours2,
  hours4,
  hours8,
  daily;

  Duration get duration {
    switch (this) {
      case ReminderInterval.minutes30:
        return const Duration(minutes: 30);
      case ReminderInterval.hour1:
        return const Duration(hours: 1);
      case ReminderInterval.hours2:
        return const Duration(hours: 2);
      case ReminderInterval.hours4:
        return const Duration(hours: 4);
      case ReminderInterval.hours8:
        return const Duration(hours: 8);
      case ReminderInterval.daily:
        return const Duration(days: 1);
    }
  }

  String get displayLabel {
    switch (this) {
      case ReminderInterval.minutes30:
        return '30 minutes';
      case ReminderInterval.hour1:
        return '1 hour';
      case ReminderInterval.hours2:
        return '2 hours';
      case ReminderInterval.hours4:
        return '4 hours';
      case ReminderInterval.hours8:
        return '8 hours';
      case ReminderInterval.daily:
        return 'Daily';
    }
  }

  static ReminderInterval fromIndex(int index) {
    if (index >= 0 && index < values.length) {
      return values[index];
    }
    return hour1;
  }
}

/// PopupDuration enum for auto-dismiss timing
enum PopupDuration {
  seconds30,
  minute1,
  minutes2,
  minutes5,
  manual;

  Duration? get duration {
    switch (this) {
      case PopupDuration.seconds30:
        return const Duration(seconds: 30);
      case PopupDuration.minute1:
        return const Duration(minutes: 1);
      case PopupDuration.minutes2:
        return const Duration(minutes: 2);
      case PopupDuration.minutes5:
        return const Duration(minutes: 5);
      case PopupDuration.manual:
        return null; // No auto-dismiss
    }
  }

  String get displayLabel {
    switch (this) {
      case PopupDuration.seconds30:
        return '30 seconds';
      case PopupDuration.minute1:
        return '1 minute';
      case PopupDuration.minutes2:
        return '2 minutes';
      case PopupDuration.minutes5:
        return '5 minutes';
      case PopupDuration.manual:
        return 'Manual';
    }
  }

  static PopupDuration fromIndex(int index) {
    if (index >= 0 && index < values.length) {
      return values[index];
    }
    return minutes2;
  }
}

/// FontSize enum for Arabic text
enum FontSize {
  small,
  medium,
  large,
  extraLarge;

  double get size {
    switch (this) {
      case FontSize.small:
        return 18.0;
      case FontSize.medium:
        return 22.0;
      case FontSize.large:
        return 26.0;
      case FontSize.extraLarge:
        return 32.0;
    }
  }

  String get displayLabel {
    switch (this) {
      case FontSize.small:
        return 'Small';
      case FontSize.medium:
        return 'Medium';
      case FontSize.large:
        return 'Large';
      case FontSize.extraLarge:
        return 'Extra Large';
    }
  }

  static FontSize fromIndex(int index) {
    if (index >= 0 && index < values.length) {
      return values[index];
    }
    return large;
  }
}

/// PopupPosition helper class
class PopupPosition extends Equatable {
  final double dx;
  final double dy;

  const PopupPosition(this.dx, this.dy);

  factory PopupPosition.fromJson(Map<String, dynamic> json) {
    return PopupPosition(
      (json['dx'] as num?)?.toDouble() ?? 100.0,
      (json['dy'] as num?)?.toDouble() ?? 100.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dx': dx,
      'dy': dy,
    };
  }

  @override
  List<Object?> get props => [dx, dy];
}

/// PopupPositionType enum for screen position selection
enum PopupPositionType {
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
  center;

  String get displayLabel {
    switch (this) {
      case PopupPositionType.topLeft:
        return 'Top Left';
      case PopupPositionType.topRight:
        return 'Top Right';
      case PopupPositionType.bottomLeft:
        return 'Bottom Left';
      case PopupPositionType.bottomRight:
        return 'Bottom Right';
      case PopupPositionType.center:
        return 'Center';
    }
  }

  static PopupPositionType fromIndex(int index) {
    if (index >= 0 && index < values.length) {
      return values[index];
    }
    return bottomRight;
  }
}

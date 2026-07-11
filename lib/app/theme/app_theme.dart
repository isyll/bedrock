import 'package:bedrock/app/theme/app_colors.dart';
import 'package:bedrock/app/theme/app_typography.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

abstract final class AppTheme {
  static ThemeData get light => _build(Brightness.light);

  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.seed,
      brightness: brightness,
    );
    final base = ThemeData(
      colorScheme: scheme,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
    final textTheme = AppTypography.refine(base.textTheme);

    return base.copyWith(
      textTheme: textTheme,
      splashFactory: InkSparkle.splashFactory,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      appBarTheme: _appBar(scheme, textTheme, brightness),
      inputDecorationTheme: _inputDecoration(scheme),
      filledButtonTheme: _filledButton(scheme),
      elevatedButtonTheme: _elevatedButton(scheme),
      outlinedButtonTheme: _outlinedButton(scheme),
      textButtonTheme: _textButton(scheme),
      iconButtonTheme: _iconButton(scheme),
      floatingActionButtonTheme: _fab(scheme),
      segmentedButtonTheme: _segmentedButton(scheme),
      checkboxTheme: _checkbox(scheme),
      radioTheme: _radio(scheme),
      switchTheme: _switch(scheme),
      sliderTheme: _slider(scheme),
      chipTheme: _chip(scheme, textTheme),
      cardTheme: _card(scheme),
      dialogTheme: _dialog(scheme, textTheme),
      bottomSheetTheme: _bottomSheet(scheme),
      snackBarTheme: _snackBar(scheme, textTheme),
      menuTheme: _menu(scheme),
      menuButtonTheme: _menuButton(scheme),
      popupMenuTheme: _popupMenu(scheme),
      navigationBarTheme: _navigationBar(scheme, textTheme),
      tabBarTheme: _tabBar(scheme),
      listTileTheme: _listTile(scheme),
      progressIndicatorTheme: _progressIndicator(scheme),
      scrollbarTheme: _scrollbar(scheme),
      textSelectionTheme: _textSelection(scheme),
      tooltipTheme: _tooltip(scheme, textTheme),
      badgeTheme: _badge(scheme),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      datePickerTheme: DatePickerThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      timePickerTheme: TimePickerThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      extensions: [
        if (brightness == Brightness.light)
          AppSemanticColors.light
        else
          AppSemanticColors.dark,
      ],
    );
  }

  static WidgetStateProperty<Color?> _stateOverlay(Color color) {
    return WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.pressed)) {
        return color.withValues(alpha: 0.10);
      }
      if (states.contains(WidgetState.hovered)) {
        return color.withValues(alpha: 0.08);
      }
      if (states.contains(WidgetState.focused)) {
        return color.withValues(alpha: 0.10);
      }
      return null;
    });
  }

  static Color _disabledForeground(ColorScheme scheme) =>
      scheme.onSurface.withValues(alpha: 0.38);

  static Color _disabledContainer(ColorScheme scheme) =>
      scheme.onSurface.withValues(alpha: 0.12);

  static AppBarTheme _appBar(
    ColorScheme scheme,
    TextTheme textTheme,
    Brightness brightness,
  ) {
    return AppBarTheme(
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 1,
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      surfaceTintColor: scheme.surfaceTint,
      titleTextStyle: textTheme.titleLarge?.copyWith(color: scheme.onSurface),
      systemOverlayStyle: brightness == Brightness.light
          ? SystemUiOverlayStyle.dark
          : SystemUiOverlayStyle.light,
    );
  }

  static InputDecorationTheme _inputDecoration(ColorScheme scheme) {
    final baseBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: scheme.outlineVariant),
    );

    return InputDecorationTheme(
      filled: true,
      fillColor: scheme.surfaceContainerLow,
      hoverColor: scheme.onSurface.withValues(alpha: 0.04),
      border: baseBorder,
      enabledBorder: baseBorder,
      focusedBorder: baseBorder.copyWith(
        borderSide: BorderSide(color: scheme.primary, width: 2),
      ),
      errorBorder: baseBorder.copyWith(
        borderSide: BorderSide(color: scheme.error),
      ),
      focusedErrorBorder: baseBorder.copyWith(
        borderSide: BorderSide(color: scheme.error, width: 2),
      ),
      disabledBorder: baseBorder.copyWith(
        borderSide: BorderSide(color: _disabledContainer(scheme)),
      ),
      labelStyle: WidgetStateTextStyle.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return TextStyle(color: _disabledForeground(scheme));
        }
        return TextStyle(color: scheme.onSurfaceVariant);
      }),
      floatingLabelStyle: WidgetStateTextStyle.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return TextStyle(color: _disabledForeground(scheme));
        }
        if (states.contains(WidgetState.error)) {
          return TextStyle(color: scheme.error);
        }
        if (states.contains(WidgetState.focused)) {
          return TextStyle(color: scheme.primary);
        }
        return TextStyle(color: scheme.onSurfaceVariant);
      }),
      hintStyle: TextStyle(color: scheme.onSurfaceVariant),
      prefixIconColor: _decorationIconColor(scheme),
      suffixIconColor: _decorationIconColor(scheme),
      errorStyle: TextStyle(color: scheme.error),
      errorMaxLines: 2,
      helperMaxLines: 2,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  static Color _decorationIconColor(ColorScheme scheme) {
    return WidgetStateColor.resolveWith((states) {
      if (states.contains(WidgetState.disabled)) {
        return _disabledForeground(scheme);
      }
      if (states.contains(WidgetState.error)) return scheme.error;
      if (states.contains(WidgetState.focused)) return scheme.primary;
      return scheme.onSurfaceVariant;
    });
  }

  static ButtonStyle _baseButtonStyle() {
    return ButtonStyle(
      minimumSize: const WidgetStatePropertyAll(Size(64, 48)),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      textStyle: const WidgetStatePropertyAll(
        TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }

  static FilledButtonThemeData _filledButton(ColorScheme scheme) {
    return FilledButtonThemeData(
      style: _baseButtonStyle().copyWith(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return _disabledContainer(scheme);
          }
          return scheme.primary;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return _disabledForeground(scheme);
          }
          return scheme.onPrimary;
        }),
        overlayColor: _stateOverlay(scheme.onPrimary),
      ),
    );
  }

  static ElevatedButtonThemeData _elevatedButton(ColorScheme scheme) {
    return ElevatedButtonThemeData(
      style: _baseButtonStyle().copyWith(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return _disabledContainer(scheme);
          }
          return scheme.surfaceContainerLow;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return _disabledForeground(scheme);
          }
          return scheme.primary;
        }),
        overlayColor: _stateOverlay(scheme.primary),
        elevation: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) return 0;
          if (states.contains(WidgetState.pressed)) return 1;
          if (states.contains(WidgetState.hovered)) return 3;
          return 1;
        }),
        shadowColor: WidgetStatePropertyAll(scheme.shadow),
      ),
    );
  }

  static OutlinedButtonThemeData _outlinedButton(ColorScheme scheme) {
    return OutlinedButtonThemeData(
      style: _baseButtonStyle().copyWith(
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return _disabledForeground(scheme);
          }
          return scheme.primary;
        }),
        side: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return BorderSide(color: _disabledContainer(scheme));
          }
          if (states.contains(WidgetState.focused)) {
            return BorderSide(color: scheme.primary, width: 1.5);
          }
          return BorderSide(color: scheme.outline);
        }),
        overlayColor: _stateOverlay(scheme.primary),
      ),
    );
  }

  static TextButtonThemeData _textButton(ColorScheme scheme) {
    return TextButtonThemeData(
      style: ButtonStyle(
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        textStyle: const WidgetStatePropertyAll(
          TextStyle(fontWeight: FontWeight.w600),
        ),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return _disabledForeground(scheme);
          }
          return scheme.primary;
        }),
        overlayColor: _stateOverlay(scheme.primary),
      ),
    );
  }

  static IconButtonThemeData _iconButton(ColorScheme scheme) {
    return IconButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return _disabledForeground(scheme);
          }
          return scheme.onSurfaceVariant;
        }),
        overlayColor: _stateOverlay(scheme.onSurfaceVariant),
      ),
    );
  }

  static FloatingActionButtonThemeData _fab(ColorScheme scheme) {
    return FloatingActionButtonThemeData(
      backgroundColor: scheme.primaryContainer,
      foregroundColor: scheme.onPrimaryContainer,
      elevation: 2,
      highlightElevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }

  static SegmentedButtonThemeData _segmentedButton(ColorScheme scheme) {
    return SegmentedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) return Colors.transparent;
          if (states.contains(WidgetState.selected)) {
            return scheme.secondaryContainer;
          }
          return Colors.transparent;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return _disabledForeground(scheme);
          }
          if (states.contains(WidgetState.selected)) {
            return scheme.onSecondaryContainer;
          }
          return scheme.onSurface;
        }),
        side: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return BorderSide(color: _disabledContainer(scheme));
          }
          return BorderSide(color: scheme.outline);
        }),
        overlayColor: _stateOverlay(scheme.onSurface),
      ),
    );
  }

  static CheckboxThemeData _checkbox(ColorScheme scheme) {
    return CheckboxThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      side: BorderSide(color: scheme.onSurfaceVariant, width: 2),
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return states.contains(WidgetState.selected)
              ? _disabledContainer(scheme)
              : Colors.transparent;
        }
        if (states.contains(WidgetState.selected)) return scheme.primary;
        return Colors.transparent;
      }),
      checkColor: WidgetStatePropertyAll(scheme.onPrimary),
      overlayColor: _stateOverlay(scheme.primary),
    );
  }

  static RadioThemeData _radio(ColorScheme scheme) {
    return RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return _disabledForeground(scheme);
        }
        if (states.contains(WidgetState.selected)) return scheme.primary;
        return scheme.onSurfaceVariant;
      }),
      overlayColor: _stateOverlay(scheme.primary),
    );
  }

  static SwitchThemeData _switch(ColorScheme scheme) {
    return SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return states.contains(WidgetState.selected)
              ? scheme.surface
              : _disabledForeground(scheme);
        }
        if (states.contains(WidgetState.selected)) return scheme.onPrimary;
        return scheme.outline;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return _disabledContainer(scheme);
        }
        if (states.contains(WidgetState.selected)) return scheme.primary;
        return scheme.surfaceContainerHighest;
      }),
      trackOutlineColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return Colors.transparent;
        if (states.contains(WidgetState.disabled)) {
          return _disabledContainer(scheme);
        }
        return scheme.outline;
      }),
      overlayColor: _stateOverlay(scheme.primary),
    );
  }

  static SliderThemeData _slider(ColorScheme scheme) {
    return SliderThemeData(
      activeTrackColor: scheme.primary,
      inactiveTrackColor: scheme.surfaceContainerHighest,
      thumbColor: scheme.primary,
      overlayColor: scheme.primary.withValues(alpha: 0.10),
      disabledActiveTrackColor: _disabledForeground(scheme),
      disabledInactiveTrackColor: _disabledContainer(scheme),
      disabledThumbColor: _disabledForeground(scheme),
      valueIndicatorColor: scheme.inverseSurface,
      valueIndicatorTextStyle: TextStyle(color: scheme.onInverseSurface),
    );
  }

  static ChipThemeData _chip(ColorScheme scheme, TextTheme textTheme) {
    return ChipThemeData(
      backgroundColor: scheme.surfaceContainerLow,
      selectedColor: scheme.secondaryContainer,
      disabledColor: _disabledContainer(scheme),
      deleteIconColor: scheme.onSurfaceVariant,
      labelStyle: textTheme.labelLarge?.copyWith(color: scheme.onSurface),
      side: BorderSide(color: scheme.outlineVariant),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }

  static CardThemeData _card(ColorScheme scheme) {
    return CardThemeData(
      elevation: 0,
      color: scheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
    );
  }

  static DialogThemeData _dialog(ColorScheme scheme, TextTheme textTheme) {
    return DialogThemeData(
      backgroundColor: scheme.surfaceContainerHigh,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titleTextStyle: textTheme.titleLarge?.copyWith(color: scheme.onSurface),
      contentTextStyle: textTheme.bodyMedium?.copyWith(
        color: scheme.onSurfaceVariant,
      ),
    );
  }

  static BottomSheetThemeData _bottomSheet(ColorScheme scheme) {
    return BottomSheetThemeData(
      backgroundColor: scheme.surfaceContainerLow,
      modalBackgroundColor: scheme.surfaceContainerLow,
      showDragHandle: true,
      dragHandleColor: scheme.onSurfaceVariant,
      clipBehavior: Clip.antiAlias,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    );
  }

  static SnackBarThemeData _snackBar(ColorScheme scheme, TextTheme textTheme) {
    return SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: scheme.inverseSurface,
      contentTextStyle: textTheme.bodyMedium?.copyWith(
        color: scheme.onInverseSurface,
      ),
      actionTextColor: scheme.inversePrimary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  static MenuThemeData _menu(ColorScheme scheme) {
    return MenuThemeData(
      style: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(scheme.surfaceContainer),
        surfaceTintColor: WidgetStatePropertyAll(scheme.surfaceTint),
        elevation: const WidgetStatePropertyAll(3),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  static MenuButtonThemeData _menuButton(ColorScheme scheme) {
    return MenuButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return _disabledForeground(scheme);
          }
          return scheme.onSurface;
        }),
        overlayColor: _stateOverlay(scheme.onSurface),
      ),
    );
  }

  static PopupMenuThemeData _popupMenu(ColorScheme scheme) {
    return PopupMenuThemeData(
      color: scheme.surfaceContainer,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  static NavigationBarThemeData _navigationBar(
    ColorScheme scheme,
    TextTheme textTheme,
  ) {
    return NavigationBarThemeData(
      height: 68,
      backgroundColor: scheme.surfaceContainer,
      indicatorColor: scheme.secondaryContainer,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return IconThemeData(color: _disabledForeground(scheme));
        }
        if (states.contains(WidgetState.selected)) {
          return IconThemeData(color: scheme.onSecondaryContainer);
        }
        return IconThemeData(color: scheme.onSurfaceVariant);
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final style = textTheme.labelMedium ?? const TextStyle(fontSize: 12);
        if (states.contains(WidgetState.disabled)) {
          return style.copyWith(color: _disabledForeground(scheme));
        }
        if (states.contains(WidgetState.selected)) {
          return style.copyWith(
            color: scheme.onSurface,
            fontWeight: FontWeight.w600,
          );
        }
        return style.copyWith(color: scheme.onSurfaceVariant);
      }),
    );
  }

  static TabBarThemeData _tabBar(ColorScheme scheme) {
    return TabBarThemeData(
      labelColor: scheme.primary,
      unselectedLabelColor: scheme.onSurfaceVariant,
      indicatorColor: scheme.primary,
      indicatorSize: TabBarIndicatorSize.label,
      dividerColor: scheme.outlineVariant,
      overlayColor: _stateOverlay(scheme.primary),
    );
  }

  static ListTileThemeData _listTile(ColorScheme scheme) {
    return ListTileThemeData(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      iconColor: scheme.onSurfaceVariant,
      selectedColor: scheme.onSecondaryContainer,
      selectedTileColor: scheme.secondaryContainer.withValues(alpha: 0.4),
    );
  }

  static ProgressIndicatorThemeData _progressIndicator(ColorScheme scheme) {
    return ProgressIndicatorThemeData(
      color: scheme.primary,
      linearTrackColor: scheme.surfaceContainerHighest,
      refreshBackgroundColor: scheme.surfaceContainer,
    );
  }

  static ScrollbarThemeData _scrollbar(ColorScheme scheme) {
    return ScrollbarThemeData(
      radius: const Radius.circular(4),
      thickness: const WidgetStatePropertyAll(6),
      thumbColor: WidgetStateProperty.resolveWith((states) {
        final active =
            states.contains(WidgetState.hovered) ||
            states.contains(WidgetState.dragged);
        return scheme.onSurface.withValues(alpha: active ? 0.5 : 0.3);
      }),
    );
  }

  static TextSelectionThemeData _textSelection(ColorScheme scheme) {
    return TextSelectionThemeData(
      cursorColor: scheme.primary,
      selectionColor: scheme.primary.withValues(alpha: 0.3),
      selectionHandleColor: scheme.primary,
    );
  }

  static TooltipThemeData _tooltip(ColorScheme scheme, TextTheme textTheme) {
    return TooltipThemeData(
      waitDuration: const Duration(milliseconds: 400),
      decoration: BoxDecoration(
        color: scheme.inverseSurface,
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: textTheme.bodySmall?.copyWith(color: scheme.onInverseSurface),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }

  static BadgeThemeData _badge(ColorScheme scheme) {
    return BadgeThemeData(
      backgroundColor: scheme.error,
      textColor: scheme.onError,
    );
  }
}

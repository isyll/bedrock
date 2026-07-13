import 'package:bedrock/app/theme/app_colors.dart';
import 'package:bedrock/app/theme/app_typography.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

abstract final class AppTheme {
  static ThemeData get dark => _build(.dark);

  static ThemeData get light => _build(.light);

  static AppBarTheme _appBar(
    ColorScheme scheme,
    TextTheme textTheme,
    Brightness brightness,
  ) => .new(
    centerTitle: false,
    elevation: 0,
    scrolledUnderElevation: 1,
    backgroundColor: scheme.surface,
    foregroundColor: scheme.onSurface,
    surfaceTintColor: scheme.surfaceTint,
    titleTextStyle: textTheme.titleLarge?.copyWith(color: scheme.onSurface),
    systemOverlayStyle: brightness == .light ? .dark : .light,
  );

  static BadgeThemeData _badge(ColorScheme scheme) => .new(
    backgroundColor: scheme.error,
    textColor: scheme.onError,
  );

  static ButtonStyle _baseButtonStyle() => .new(
    minimumSize: const WidgetStatePropertyAll(Size(64, 48)),
    shape: WidgetStatePropertyAll(
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    textStyle: const WidgetStatePropertyAll(
      TextStyle(fontSize: 16, fontWeight: .w600),
    ),
  );

  static BottomSheetThemeData _bottomSheet(ColorScheme scheme) => .new(
    backgroundColor: scheme.surfaceContainerLow,
    modalBackgroundColor: scheme.surfaceContainerLow,
    showDragHandle: true,
    dragHandleColor: scheme.onSurfaceVariant,
    clipBehavior: .antiAlias,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: .circular(24)),
    ),
  );

  static ThemeData _build(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.seed,
      brightness: brightness,
    );
    final base = ThemeData(
      colorScheme: scheme,
      visualDensity: .adaptivePlatformDensity,
    );
    final textTheme = AppTypography.refine(base.textTheme);

    return base.copyWith(
      textTheme: textTheme,
      splashFactory: InkSparkle.splashFactory,
      pageTransitionsTheme: const .new(
        builders: {
          .android: PredictiveBackPageTransitionsBuilder(),
          .iOS: CupertinoPageTransitionsBuilder(),
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
      dividerTheme: .new(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      datePickerTheme: .new(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      timePickerTheme: .new(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      extensions: [
        if (brightness == .light)
          AppSemanticColors.light
        else
          AppSemanticColors.dark,
      ],
    );
  }

  static CardThemeData _card(ColorScheme scheme) => .new(
    elevation: 0,
    color: scheme.surfaceContainerLow,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: .new(color: scheme.outlineVariant),
    ),
    clipBehavior: .antiAlias,
    margin: EdgeInsets.zero,
  );

  static CheckboxThemeData _checkbox(ColorScheme scheme) {
    return .new(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      side: .new(color: scheme.onSurfaceVariant, width: 2),
      fillColor: .resolveWith((states) {
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

  static ChipThemeData _chip(ColorScheme scheme, TextTheme textTheme) => .new(
    backgroundColor: scheme.surfaceContainerLow,
    selectedColor: scheme.secondaryContainer,
    disabledColor: _disabledContainer(scheme),
    deleteIconColor: scheme.onSurfaceVariant,
    labelStyle: textTheme.labelLarge?.copyWith(color: scheme.onSurface),
    side: .new(color: scheme.outlineVariant),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  );

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

  static DialogThemeData _dialog(ColorScheme scheme, TextTheme textTheme) =>
      .new(
        backgroundColor: scheme.surfaceContainerHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: textTheme.titleLarge?.copyWith(color: scheme.onSurface),
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
      );

  static Color _disabledContainer(ColorScheme scheme) =>
      scheme.onSurface.withValues(alpha: 0.12);

  static Color _disabledForeground(ColorScheme scheme) =>
      scheme.onSurface.withValues(alpha: 0.38);

  static ElevatedButtonThemeData _elevatedButton(ColorScheme scheme) {
    return .new(
      style: _baseButtonStyle().copyWith(
        backgroundColor: .resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return _disabledContainer(scheme);
          }
          return scheme.surfaceContainerLow;
        }),
        foregroundColor: .resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return _disabledForeground(scheme);
          }
          return scheme.primary;
        }),
        overlayColor: _stateOverlay(scheme.primary),
        elevation: .resolveWith((states) {
          if (states.contains(WidgetState.disabled)) return 0;
          if (states.contains(WidgetState.pressed)) return 1;
          if (states.contains(WidgetState.hovered)) return 3;
          return 1;
        }),
        shadowColor: WidgetStatePropertyAll(scheme.shadow),
      ),
    );
  }

  static FloatingActionButtonThemeData _fab(ColorScheme scheme) => .new(
    backgroundColor: scheme.primaryContainer,
    foregroundColor: scheme.onPrimaryContainer,
    elevation: 2,
    highlightElevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  );

  static FilledButtonThemeData _filledButton(ColorScheme scheme) {
    return .new(
      style: _baseButtonStyle().copyWith(
        backgroundColor: .resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return _disabledContainer(scheme);
          }
          return scheme.primary;
        }),
        foregroundColor: .resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return _disabledForeground(scheme);
          }
          return scheme.onPrimary;
        }),
        overlayColor: _stateOverlay(scheme.onPrimary),
      ),
    );
  }

  static IconButtonThemeData _iconButton(ColorScheme scheme) {
    return .new(
      style: .new(
        foregroundColor: .resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return _disabledForeground(scheme);
          }
          return scheme.onSurfaceVariant;
        }),
        overlayColor: _stateOverlay(scheme.onSurfaceVariant),
      ),
    );
  }

  static InputDecorationTheme _inputDecoration(ColorScheme scheme) {
    final baseBorder = OutlineInputBorder(
      borderRadius: .circular(12),
      borderSide: .new(color: scheme.outlineVariant),
    );

    return .new(
      filled: true,
      fillColor: scheme.surfaceContainerLow,
      hoverColor: scheme.onSurface.withValues(alpha: 0.04),
      border: baseBorder,
      enabledBorder: baseBorder,
      focusedBorder: baseBorder.copyWith(
        borderSide: .new(color: scheme.primary, width: 2),
      ),
      errorBorder: baseBorder.copyWith(
        borderSide: .new(color: scheme.error),
      ),
      focusedErrorBorder: baseBorder.copyWith(
        borderSide: .new(color: scheme.error, width: 2),
      ),
      disabledBorder: baseBorder.copyWith(
        borderSide: .new(color: _disabledContainer(scheme)),
      ),
      labelStyle: WidgetStateTextStyle.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return .new(color: _disabledForeground(scheme));
        }
        return .new(color: scheme.onSurfaceVariant);
      }),
      floatingLabelStyle: WidgetStateTextStyle.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return .new(color: _disabledForeground(scheme));
        }
        if (states.contains(WidgetState.error)) {
          return .new(color: scheme.error);
        }
        if (states.contains(WidgetState.focused)) {
          return .new(color: scheme.primary);
        }
        return .new(color: scheme.onSurfaceVariant);
      }),
      hintStyle: .new(color: scheme.onSurfaceVariant),
      prefixIconColor: _decorationIconColor(scheme),
      suffixIconColor: _decorationIconColor(scheme),
      errorStyle: .new(color: scheme.error),
      errorMaxLines: 2,
      helperMaxLines: 2,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  static ListTileThemeData _listTile(ColorScheme scheme) => .new(
    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    iconColor: scheme.onSurfaceVariant,
    selectedColor: scheme.onSecondaryContainer,
    selectedTileColor: scheme.secondaryContainer.withValues(alpha: 0.4),
  );

  static MenuThemeData _menu(ColorScheme scheme) => .new(
    style: .new(
      backgroundColor: WidgetStatePropertyAll(scheme.surfaceContainer),
      surfaceTintColor: WidgetStatePropertyAll(scheme.surfaceTint),
      elevation: const WidgetStatePropertyAll(3),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );

  static MenuButtonThemeData _menuButton(ColorScheme scheme) {
    return .new(
      style: .new(
        foregroundColor: .resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return _disabledForeground(scheme);
          }
          return scheme.onSurface;
        }),
        overlayColor: _stateOverlay(scheme.onSurface),
      ),
    );
  }

  static NavigationBarThemeData _navigationBar(
    ColorScheme scheme,
    TextTheme textTheme,
  ) {
    return .new(
      height: 68,
      backgroundColor: scheme.surfaceContainer,
      indicatorColor: scheme.secondaryContainer,
      labelBehavior: .alwaysShow,
      iconTheme: .resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return IconThemeData(color: _disabledForeground(scheme));
        }
        if (states.contains(WidgetState.selected)) {
          return IconThemeData(color: scheme.onSecondaryContainer);
        }
        return IconThemeData(color: scheme.onSurfaceVariant);
      }),
      labelTextStyle: .resolveWith((states) {
        final style = textTheme.labelMedium ?? const TextStyle(fontSize: 12);
        if (states.contains(WidgetState.disabled)) {
          return style.copyWith(color: _disabledForeground(scheme));
        }
        if (states.contains(WidgetState.selected)) {
          return style.copyWith(
            color: scheme.onSurface,
            fontWeight: .w600,
          );
        }
        return style.copyWith(color: scheme.onSurfaceVariant);
      }),
    );
  }

  static OutlinedButtonThemeData _outlinedButton(ColorScheme scheme) {
    return .new(
      style: _baseButtonStyle().copyWith(
        foregroundColor: .resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return _disabledForeground(scheme);
          }
          return scheme.primary;
        }),
        side: .resolveWith((states) {
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

  static PopupMenuThemeData _popupMenu(ColorScheme scheme) => .new(
    color: scheme.surfaceContainer,
    elevation: 3,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  );

  static ProgressIndicatorThemeData _progressIndicator(ColorScheme scheme) =>
      .new(
        color: scheme.primary,
        linearTrackColor: scheme.surfaceContainerHighest,
        refreshBackgroundColor: scheme.surfaceContainer,
      );

  static RadioThemeData _radio(ColorScheme scheme) {
    return .new(
      fillColor: .resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return _disabledForeground(scheme);
        }
        if (states.contains(WidgetState.selected)) return scheme.primary;
        return scheme.onSurfaceVariant;
      }),
      overlayColor: _stateOverlay(scheme.primary),
    );
  }

  static ScrollbarThemeData _scrollbar(ColorScheme scheme) {
    return .new(
      radius: const .circular(4),
      thickness: const WidgetStatePropertyAll(6),
      thumbColor: .resolveWith((states) {
        final active =
            states.contains(WidgetState.hovered) ||
            states.contains(WidgetState.dragged);
        return scheme.onSurface.withValues(alpha: active ? 0.5 : 0.3);
      }),
    );
  }

  static SegmentedButtonThemeData _segmentedButton(ColorScheme scheme) {
    return .new(
      style: .new(
        backgroundColor: .resolveWith((states) {
          if (states.contains(WidgetState.disabled)) return Colors.transparent;
          if (states.contains(WidgetState.selected)) {
            return scheme.secondaryContainer;
          }
          return Colors.transparent;
        }),
        foregroundColor: .resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return _disabledForeground(scheme);
          }
          if (states.contains(WidgetState.selected)) {
            return scheme.onSecondaryContainer;
          }
          return scheme.onSurface;
        }),
        side: .resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return BorderSide(color: _disabledContainer(scheme));
          }
          return BorderSide(color: scheme.outline);
        }),
        overlayColor: _stateOverlay(scheme.onSurface),
      ),
    );
  }

  static SliderThemeData _slider(ColorScheme scheme) => .new(
    activeTrackColor: scheme.primary,
    inactiveTrackColor: scheme.surfaceContainerHighest,
    thumbColor: scheme.primary,
    overlayColor: scheme.primary.withValues(alpha: 0.10),
    disabledActiveTrackColor: _disabledForeground(scheme),
    disabledInactiveTrackColor: _disabledContainer(scheme),
    disabledThumbColor: _disabledForeground(scheme),
    valueIndicatorColor: scheme.inverseSurface,
    valueIndicatorTextStyle: .new(color: scheme.onInverseSurface),
  );

  static SnackBarThemeData _snackBar(ColorScheme scheme, TextTheme textTheme) =>
      .new(
        behavior: .floating,
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: scheme.onInverseSurface,
        ),
        actionTextColor: scheme.inversePrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        insetPadding: const .symmetric(horizontal: 16, vertical: 12),
      );

  static WidgetStateProperty<Color?> _stateOverlay(Color color) {
    return .resolveWith((states) {
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

  static SwitchThemeData _switch(ColorScheme scheme) {
    return .new(
      thumbColor: .resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return states.contains(WidgetState.selected)
              ? scheme.surface
              : _disabledForeground(scheme);
        }
        if (states.contains(WidgetState.selected)) return scheme.onPrimary;
        return scheme.outline;
      }),
      trackColor: .resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return _disabledContainer(scheme);
        }
        if (states.contains(WidgetState.selected)) return scheme.primary;
        return scheme.surfaceContainerHighest;
      }),
      trackOutlineColor: .resolveWith((states) {
        if (states.contains(WidgetState.selected)) return Colors.transparent;
        if (states.contains(WidgetState.disabled)) {
          return _disabledContainer(scheme);
        }
        return scheme.outline;
      }),
      overlayColor: _stateOverlay(scheme.primary),
    );
  }

  static TabBarThemeData _tabBar(ColorScheme scheme) => .new(
    labelColor: scheme.primary,
    unselectedLabelColor: scheme.onSurfaceVariant,
    indicatorColor: scheme.primary,
    indicatorSize: .label,
    dividerColor: scheme.outlineVariant,
    overlayColor: _stateOverlay(scheme.primary),
  );

  static TextButtonThemeData _textButton(ColorScheme scheme) {
    return .new(
      style: .new(
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        textStyle: const WidgetStatePropertyAll(
          TextStyle(fontWeight: .w600),
        ),
        foregroundColor: .resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return _disabledForeground(scheme);
          }
          return scheme.primary;
        }),
        overlayColor: _stateOverlay(scheme.primary),
      ),
    );
  }

  static TextSelectionThemeData _textSelection(ColorScheme scheme) => .new(
    cursorColor: scheme.primary,
    selectionColor: scheme.primary.withValues(alpha: 0.3),
    selectionHandleColor: scheme.primary,
  );

  static TooltipThemeData _tooltip(ColorScheme scheme, TextTheme textTheme) =>
      .new(
        waitDuration: const .new(milliseconds: 400),
        decoration: BoxDecoration(
          color: scheme.inverseSurface,
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: textTheme.bodySmall?.copyWith(
          color: scheme.onInverseSurface,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      );
}

// lib/shared/widgets/drawer/zoom_drawer.dart
import 'dart:math' show min, pi;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mylife/shared/widgets/drawer/style_default.dart';
import 'dart:math';

/// Drawer states
enum DrawerState { opening, closing, open, closed }

enum DrawerLastAction { open, closed }

class MyDrawerController {
  TickerFuture? Function()? open;
  TickerFuture? Function()? close;
  TickerFuture? Function({bool forceToggle})? toggle;
  bool Function()? isOpen;
  ValueNotifier<DrawerState>? stateNotifier;
}

extension ZoomDrawerContext on BuildContext {
  ZoomDrawerState? get drawer => ZoomDrawer.of(this);
  DrawerLastAction? get drawerLastAction =>
      ZoomDrawer.of(this)?.drawerLastAction;
  DrawerState? get drawerState => ZoomDrawer.of(this)?.stateNotifier.value;
  ValueNotifier<DrawerState>? get drawerStateNotifier =>
      ZoomDrawer.of(this)?.stateNotifier;
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
}

typedef DrawerStyleBuilder = Widget Function(
  BuildContext context,
  double animationValue,
  double slideWidth,
  Widget menuScreen,
  Widget mainScreen,
);

class ZoomDrawer extends StatefulWidget {
  const ZoomDrawer({
    super.key,
    required this.menuScreen,
    required this.mainScreen,
    this.controller,
    this.mainScreenScale = 0.3,
    this.slideWidth = 275.0,
    this.slideHeight = 0,
    this.menuScreenWidth,
    this.borderRadius = 16.0,
    this.angle = -12.0,
    this.dragOffset = 60.0,
    this.openDragSensitivity = 425,
    this.closeDragSensitivity = 425,
    this.drawerShadowsBackgroundColor = const Color(0xffffffff),
    this.menuBackgroundColor = Colors.transparent,
    this.shadowLayer1Color,
    this.shadowLayer2Color,
    this.showShadow = true,
    this.openCurve = const Interval(0.0, 1.0, curve: Curves.easeOut),
    this.closeCurve = const Interval(0.0, 1.0, curve: Curves.easeOut),
    this.duration = const Duration(milliseconds: 250),
    this.reverseDuration = const Duration(milliseconds: 250),
    this.androidCloseOnBackTap = false,
    this.moveMenuScreen = true,
    this.disableDragGesture = false,
    this.mainScreenTapClose = true,
    this.mainScreenAbsorbPointer = true,
    this.boxShadow,
    this.drawerStyleBuilder,
    this.onAnimationValueChange,
    this.dragThreshold = 0.35, // nuevo: umbral configurable
  });

  final MyDrawerController? controller;
  final Widget menuScreen;
  final Widget mainScreen;
  final double mainScreenScale;
  final double slideWidth;
  final double slideHeight;
  final double? menuScreenWidth;
  final double borderRadius;
  final double angle;
  final Color menuBackgroundColor;
  final Color drawerShadowsBackgroundColor;
  final Color? shadowLayer1Color;
  final Color? shadowLayer2Color;
  final bool showShadow;
  final bool androidCloseOnBackTap;
  final bool moveMenuScreen;
  final Curve openCurve;
  final Curve closeCurve;
  final Duration duration;
  final Duration reverseDuration;
  final bool disableDragGesture;
  final double dragOffset;
  final double openDragSensitivity;
  final double closeDragSensitivity;
  final List<BoxShadow>? boxShadow;
  final bool mainScreenTapClose;
  final bool mainScreenAbsorbPointer;
  final DrawerStyleBuilder? drawerStyleBuilder;
  final void Function(double value)? onAnimationValueChange;

  // NUEVO: umbral (0..1), por defecto 0.35 (35%)
  final double dragThreshold;

  @override
  ZoomDrawerState createState() => ZoomDrawerState();

  static ZoomDrawerState? of(BuildContext context) =>
      context.findAncestorStateOfType<ZoomDrawerState>();
}

class ZoomDrawerState extends State<ZoomDrawer>
    with SingleTickerProviderStateMixin {
  bool _shouldDrag = false;
  late final ValueNotifier<bool> _absorbingMainScreen;
  final ValueNotifier<DrawerState> _stateNotifier =
      ValueNotifier(DrawerState.closed);
  ValueNotifier<DrawerState> get stateNotifier => _stateNotifier;

  late AnimationController _animationController;

  double get _animationValue => _animationController.value;

  DrawerLastAction _drawerLastAction = DrawerLastAction.closed;
  DrawerLastAction get drawerLastAction => _drawerLastAction;

  bool isOpen() => stateNotifier.value == DrawerState.open;

  // Constantes locales (puedes moverlas a campos o constructor si quieres expuestas)
  static const double _defaultFlingDivisor =
      50; // para normalizar la velocidad en fling
  static const double _minFlingVelocity = 350.0;

  @override
  void initState() {
    super.initState();

    // Inicializamos el AnimationController aquí (mejor práctica).
    _animationController = AnimationController(
      vsync: this,
      duration: widget.duration,
      reverseDuration:
          widget.reverseDuration, // usar reverseDuration correctamente
    )
      ..addStatusListener(_animationStatusListener)
      ..addListener(() => widget.onAnimationValueChange?.call(_animationValue));

    _absorbingMainScreen = ValueNotifier(widget.mainScreenAbsorbPointer);

    // Asignamos el controller externo (si existe)
    _assignToController();
  }

  @override
  void didUpdateWidget(covariant ZoomDrawer oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Si cambia el controller externo, reasignamos
    if (oldWidget.controller != widget.controller) {
      _assignToController();
    }

    // Si cambió la duración, recreamos el AnimationController para evitar inconsistencias.
    // (Opcional: podrías solo actualizar duration si supports)
    if (oldWidget.duration != widget.duration ||
        oldWidget.reverseDuration != widget.reverseDuration) {
      final oldValue = _animationController.value;
      _animationController.removeStatusListener(_animationStatusListener);
      _animationController.removeListener(
          () => widget.onAnimationValueChange?.call(_animationValue));
      _animationController.dispose();

      _animationController = AnimationController(
        vsync: this,
        duration: widget.duration,
        reverseDuration: widget.reverseDuration,
        value: oldValue, // reutilizamos el progreso actual
      )
        ..addStatusListener(_animationStatusListener)
        ..addListener(
            () => widget.onAnimationValueChange?.call(_animationValue));
    }

    // Si cambió mainScreenAbsorbPointer, actualizamos el notifier inicial
    if (oldWidget.mainScreenAbsorbPointer != widget.mainScreenAbsorbPointer) {
      _absorbingMainScreen.value = widget.mainScreenAbsorbPointer;
    }
  }

  @override
  void dispose() {
    _stateNotifier.dispose();
    _absorbingMainScreen.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onHorizontalDragStart(DragStartDetails startDetails) {
    final isDraggingFromLeft = _animationController.isDismissed &&
        startDetails.globalPosition.dx < widget.dragOffset;

    final isDraggingFromRight = !_animationController.isDismissed &&
        startDetails.globalPosition.dx > widget.dragOffset;

    _shouldDrag = isDraggingFromLeft || isDraggingFromRight;
  }

  void _onHorizontalDragUpdate(DragUpdateDetails updateDetails) {
    if (!_shouldDrag &&
        ![DrawerState.opening, DrawerState.closing]
            .contains(_stateNotifier.value)) {
      return;
    }

    final dragSensitivity = drawerLastAction == DrawerLastAction.open
        ? widget.closeDragSensitivity
        : widget.openDragSensitivity;

    final delta = updateDetails.primaryDelta ?? 0.0;

    // Calculamos nuevo valor y lo clamp (seguro)
    final newValue =
        (_animationController.value + delta / dragSensitivity).clamp(0.0, 1.0);
    _animationController.value = newValue;
  }

  void _onHorizontalDragEnd(DragEndDetails dragEndDetails) {
    if (_animationController.isDismissed || _animationController.isCompleted) {
      return;
    }

    final dragVelocity = dragEndDetails.velocity.pixelsPerSecond.dx.abs();
    final willFling = dragVelocity > _minFlingVelocity;

    if (willFling) {
      final visualVelocityInPx = dragEndDetails.velocity.pixelsPerSecond.dx /
          (context.screenWidth * _defaultFlingDivisor);
      _animationController.fling(
        velocity: visualVelocityInPx,
        animationBehavior: AnimationBehavior.preserve,
      );
      return;
    }

    // Umbral configurable y simétrico
    final threshold = widget.dragThreshold; // p.e. 0.35
    if (drawerLastAction == DrawerLastAction.open) {
      // Anim value va de 1 -> 0 cuando cerramos
      if (_animationController.value > (1 - threshold)) {
        open();
        return;
      }
      close();
    } else {
      // last action closed: anim value va de 0 -> 1
      if (_animationController.value < threshold) {
        close();
        return;
      }
      open();
    }
  }

  void _mainScreenTapHandler() {
    if (widget.mainScreenTapClose && stateNotifier.value == DrawerState.open) {
      close();
    }
  }

  TickerFuture? open() {
    if (!mounted) return null;
    return _animationController.forward();
  }

  TickerFuture? close() {
    if (!mounted) return null;
    return _animationController.reverse();
  }

  TickerFuture? toggle({bool forceToggle = false}) {
    if (stateNotifier.value == DrawerState.open ||
        (forceToggle && drawerLastAction == DrawerLastAction.open)) {
      return close();
    } else if (stateNotifier.value == DrawerState.closed ||
        (forceToggle && drawerLastAction == DrawerLastAction.closed)) {
      return open();
    }
    return null;
  }

  void _assignToController() {
    if (widget.controller == null) return;
    widget.controller!.open = open;
    widget.controller!.close = close;
    widget.controller!.toggle = toggle;
    widget.controller!.isOpen = isOpen;
    widget.controller!.stateNotifier = stateNotifier;
  }

  void _animationStatusListener(AnimationStatus status) {
    switch (status) {
      case AnimationStatus.forward:
        if (drawerLastAction == DrawerLastAction.open &&
            _animationController.value < 1) {
          _stateNotifier.value = DrawerState.closing;
        } else {
          _stateNotifier.value = DrawerState.opening;
        }
        break;
      case AnimationStatus.reverse:
        if (drawerLastAction == DrawerLastAction.closed &&
            _animationController.value > 0) {
          _stateNotifier.value = DrawerState.opening;
        } else {
          _stateNotifier.value = DrawerState.closing;
        }
        break;
      case AnimationStatus.completed:
        _stateNotifier.value = DrawerState.open;
        _drawerLastAction = DrawerLastAction.open;
        _absorbingMainScreen.value = widget.mainScreenAbsorbPointer;
        break;
      case AnimationStatus.dismissed:
        _stateNotifier.value = DrawerState.closed;
        _drawerLastAction = DrawerLastAction.closed;
        _absorbingMainScreen.value = false;
        break;
    }
  }

  // Aplicar transformaciones (igual lógica tuya pero usando controller inicializado en initState).
  Widget _applyDefaultStyle(
    Widget? child, {
    double? angle,
    double scale = 1,
    double slide = 0,
  }) {
    double slidePercent;
    double scalePercent;

    switch (stateNotifier.value) {
      case DrawerState.closed:
        slidePercent = 0.0;
        scalePercent = 0.0;
        break;
      case DrawerState.open:
        slidePercent = 1.0;
        scalePercent = 1.0;
        break;
      case DrawerState.opening:
        slidePercent = (widget.openCurve).transform(_animationValue);
        scalePercent = Interval(0.0, 0.3, curve: widget.openCurve)
            .transform(_animationValue);
        break;
      case DrawerState.closing:
        slidePercent = (widget.closeCurve).transform(_animationValue);
        scalePercent = Interval(0.0, 1.0, curve: widget.closeCurve)
            .transform(_animationValue);
        break;
    }

    final xPosition =
        ((widget.slideWidth - slide) * _animationValue) * slidePercent;
    final yPosition =
        ((widget.slideHeight - slide) * _animationValue) * slidePercent;
    final scalePercentage = scale - (widget.mainScreenScale * scalePercent);
    final radius = widget.borderRadius * _animationValue;
    final rotationAngle =
        (((angle ?? widget.angle) * pi) / 180) * _animationValue;

    return Transform(
      transform: Matrix4.translationValues(xPosition, yPosition, 0.0)
        ..rotateZ(rotationAngle)
        ..scale(scalePercentage, scalePercentage),
      alignment: Alignment.centerLeft,
      child: scale == 1
          ? child
          : ClipRRect(
              borderRadius: BorderRadius.circular(radius),
              child: child,
            ),
    );
  }

  Widget get menuScreenWidget {
    // Sugerencia: por defecto usar slideWidth como ancho del menú.
    final defaultMenuWidth = min(widget.slideWidth, context.screenWidth * 0.9);
    Widget menuScreen = SizedBox.expand(
      child: Align(
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: widget.menuScreenWidth ?? defaultMenuWidth,
          child: widget.menuScreen,
        ),
      ),
    );

    if (widget.moveMenuScreen) {
      final left = (1 - _animationValue) * widget.slideWidth;
      menuScreen =
          Transform.translate(offset: Offset(-left, 0), child: menuScreen);
    }

    return ColoredBox(color: widget.menuBackgroundColor, child: menuScreen);
  }

  Widget get mainScreenWidget {
    Widget mainScreen = widget.mainScreen;

    if (widget.borderRadius != 0) {
      final borderRadius = widget.borderRadius * _animationValue;
      mainScreen = ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius), child: mainScreen);
    }

    if (widget.boxShadow != null) {
      final radius = widget.borderRadius * _animationValue;
      mainScreen = Container(
        margin: EdgeInsets.all(8.0 * _animationValue),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            boxShadow: widget.boxShadow),
        child: mainScreen,
      );
    }

    if (widget.mainScreenAbsorbPointer) {
      mainScreen = Stack(children: [
        mainScreen,
        ValueListenableBuilder(
          valueListenable: _absorbingMainScreen,
          builder: (_, bool valueNotifier, __) {
            if (valueNotifier && stateNotifier.value == DrawerState.open) {
              return AbsorbPointer(
                child: Container(
                    color: Colors.transparent,
                    width: context.screenWidth,
                    height: context.screenHeight),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ]);
    }

    if (widget.mainScreenTapClose) {
      mainScreen = GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: _mainScreenTapHandler,
          child: mainScreen);
    }

    return mainScreen;
  }

  @override
  Widget build(BuildContext context) => _renderLayout();

  Widget _renderLayout() {
    Widget parentWidget;

    if (widget.drawerStyleBuilder != null) {
      parentWidget = AnimatedBuilder(
        animation: _animationController,
        builder: (context, _) => widget.drawerStyleBuilder!(
            context,
            _animationValue,
            widget.slideWidth,
            menuScreenWidget,
            mainScreenWidget),
      );
    } else {
      parentWidget = AnimatedBuilder(
        animation: _animationController,
        builder: (_, __) => StyleDefault(
          animationController: _animationController,
          mainScreenWidget: mainScreenWidget,
          menuScreenWidget: menuScreenWidget,
          angle: widget.angle,
          showShadow: widget.showShadow,
          shadowLayer1Color: widget.shadowLayer1Color,
          shadowLayer2Color: widget.shadowLayer2Color,
          drawerShadowsBackgroundColor: widget.drawerShadowsBackgroundColor,
          applyDefaultStyle: _applyDefaultStyle,
        ),
      );
    }

    if (!widget.disableDragGesture) {
      parentWidget = GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragStart: _onHorizontalDragStart,
        onHorizontalDragUpdate: _onHorizontalDragUpdate,
        onHorizontalDragEnd: _onHorizontalDragEnd,
        child: parentWidget,
      );
    }

    if (!kIsWeb &&
        defaultTargetPlatform == TargetPlatform.android &&
        widget.androidCloseOnBackTap) {
      // Uso WillPopScope para interceptar back; devuelve true si se puede popear.
      parentWidget =
          WillPopScope(onWillPop: () async => _canPop(), child: parentWidget);
    }

    return parentWidget;
  }

  bool _canPop() {
    if ([DrawerState.open, DrawerState.opening].contains(stateNotifier.value)) {
      close();
      return false;
    }
    return true;
  }
}

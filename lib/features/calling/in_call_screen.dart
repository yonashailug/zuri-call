import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/data/phone_country_lookup.dart';
import '../../core/theme/zuri_theme.dart';
import '../../core/ui/zuri_ui.dart';
import '../home/call_record.dart';
import 'application/call_session_controller.dart';
import 'call_service.dart';

class InCallScreen extends StatefulWidget {
  const InCallScreen({
    required this.request,
    required this.callService,
    required this.onCallEnded,
    this.onCallBackAfterEnded,
    super.key,
  });

  final OutgoingCallRequest request;
  final CallService callService;
  final ValueChanged<CallRecord> onCallEnded;
  final ValueChanged<CallRecord>? onCallBackAfterEnded;

  @override
  State<InCallScreen> createState() => _InCallScreenState();
}

class _InCallScreenState extends State<InCallScreen>
    with SingleTickerProviderStateMixin {
  Timer? returnTimer;
  late final AnimationController motionController;
  late final CallSessionController callSessionController;

  @override
  void initState() {
    super.initState();
    callSessionController = CallSessionController(
      request: widget.request,
      callService: widget.callService,
    )..start();
    motionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    returnTimer?.cancel();
    motionController.dispose();
    callSessionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: callSessionController,
      builder: (context, _) => _buildCallScreen(context),
    );
  }

  Widget _buildCallScreen(BuildContext context) {
    final displayName = widget.request.name?.trim();
    final title = displayName == null || displayName.isEmpty
        ? widget.request.phone
        : displayName;
    final state = callSessionController.state;
    _scheduleFailedCallReturn(state.failedCall);
    final endedCall = state.endedCall;
    if (endedCall != null) {
      return _EndedCallSummaryScreen(
        call: endedCall,
        onClose: () => _finishEndedCall(widget.onCallEnded),
        onCallBack: () => _finishEndedCall(
          widget.onCallBackAfterEnded ?? widget.onCallEnded,
        ),
      );
    }

    final mode = _CallUiMode.fromState(
      status: state.status,
      isMuted: state.isMuted,
      isOnHold: state.isHoldOn,
      isCompleting: state.isCompleting,
    );

    return Scaffold(
      backgroundColor: _InCallColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 22, 28, 28),
          child: Column(
            children: [
              const SizedBox(height: 22),
              _StatusPill(
                status: state.status,
                mode: mode,
                motion: motionController,
              ),
              const SizedBox(height: 32),
              _CallAvatar(
                label: _initials(title),
                motion: motionController,
                mode: mode,
              ),
              const SizedBox(height: 24),
              Text(
                title,
                textAlign: TextAlign.center,
                style: ZuriTextStyles.compactPageTitle.copyWith(
                  color: _InCallColors.text,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.request.phone,
                textAlign: TextAlign.center,
                style: ZuriTextStyles.rowSecondary.copyWith(
                  color: _InCallColors.muted,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                state.supportingStatusText,
                textAlign: TextAlign.center,
                style: ZuriTextStyles.pageSubtitle.copyWith(
                  color: mode == _CallUiMode.poorNetwork
                      ? _InCallColors.dangerText
                      : _InCallColors.muted,
                ),
              ),
              const SizedBox(height: 16),
              if (mode == _CallUiMode.poorNetwork)
                const _SignalQuality()
              else if (mode == _CallUiMode.onHold)
                _HoldStatusLine(seconds: state.holdElapsedSeconds)
              else
                _Waveform(
                  motion: motionController,
                  isLive: state.isConnected && !state.isMuted,
                ),
              const Spacer(),
              if (mode == _CallUiMode.onHold) ...[
                _CallNoticeBanner(
                  mode: mode,
                  text: '$title can hear hold music. Tap resume to reconnect.',
                ),
                const SizedBox(height: 24),
              ] else if (mode == _CallUiMode.poorNetwork) ...[
                _CallNoticeBanner(
                  mode: mode,
                  text: 'Audio may cut out.\nMove to better signal.',
                  actionLabel: 'Use 4G',
                  onAction: callSessionController.useCellularFallback,
                ),
                const SizedBox(height: 24),
              ],
              _CallControls(
                isMuted: state.isMuted,
                isSpeakerOn: state.isSpeakerOn,
                isHoldOn: state.isHoldOn,
                isKeypadOpen: state.isKeypadOpen,
                mode: mode,
                onMute: callSessionController.toggleMute,
                onSpeaker: callSessionController.toggleSpeaker,
                onHold: callSessionController.toggleHold,
                onKeypad: callSessionController.toggleKeypad,
              ),
              const SizedBox(height: 24),
              _BottomCallActions(
                onEndCall: callSessionController.endCall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _scheduleFailedCallReturn(CallRecord? failedCall) {
    if (failedCall == null || returnTimer != null) return;

    returnTimer = Timer(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      widget.onCallEnded(failedCall);
    });
  }

  void _finishEndedCall(ValueChanged<CallRecord> action) {
    final call = callSessionController.state.endedCall;
    if (call == null) return;
    action(call);
  }

  String _initials(String value) {
    final parts = value
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .toList();
    if (parts.isEmpty) return '?';

    return parts.map((part) => part[0].toUpperCase()).join();
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.status,
    required this.mode,
    required this.motion,
  });

  final ActiveCallStatus status;
  final _CallUiMode mode;
  final Animation<double> motion;

  @override
  Widget build(BuildContext context) {
    final isLive = mode == _CallUiMode.active;
    final label = switch (mode) {
      _CallUiMode.active => 'Active call',
      _CallUiMode.muted => 'Muted',
      _CallUiMode.onHold => 'On hold',
      _CallUiMode.poorNetwork => 'Poor network',
      _CallUiMode.ended => status.label,
      _CallUiMode.connecting => status.label,
    };
    final color = mode.softColor;
    final borderColor = mode.borderColor;
    final foreground = mode.foregroundColor;
    final icon = mode.badgeIcon;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(ZuriRadius.round),
        border: Border.all(color: borderColor, width: 1.4),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null)
              Icon(icon, size: 16, color: foreground)
            else
              AnimatedBuilder(
                animation: motion,
                builder: (context, child) {
                  final opacity = isLive
                      ? 0.35 + (math.sin(motion.value * math.pi * 2) + 1) * 0.3
                      : 1.0;
                  return Opacity(opacity: opacity, child: child);
                },
                child: Icon(ZuriIcons.check, size: 10, color: foreground),
              ),
            const SizedBox(width: 9),
            Text(
              label,
              style: ZuriTextStyles.chipLabel.copyWith(
                color: foreground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EndedCallSummaryScreen extends StatelessWidget {
  const _EndedCallSummaryScreen({
    required this.call,
    required this.onClose,
    required this.onCallBack,
  });

  final CallRecord call;
  final VoidCallback onClose;
  final VoidCallback onCallBack;

  @override
  Widget build(BuildContext context) {
    final cost = call.durationSeconds / 60 * 0.02;

    return Scaffold(
      backgroundColor: _EndedCallColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 22, 28, 28),
          child: Column(
            children: [
              Row(
                children: [
                  const SizedBox.square(dimension: 44),
                  const Expanded(child: Center(child: _EndedStatusPill())),
                  SizedBox.square(
                    dimension: 44,
                    child: IconButton(
                      onPressed: onClose,
                      icon: const Icon(ZuriIcons.close),
                      color: _EndedCallColors.muted,
                      tooltip: 'Close',
                      style: IconButton.styleFrom(
                        backgroundColor: _EndedCallColors.pill,
                        shape: const CircleBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              _EndedAvatar(label: _initialsFor(call.name)),
              const SizedBox(height: 24),
              Text(
                call.name,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: ZuriTextStyles.stateTitle.copyWith(
                  color: ZuriColors.ink,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                call.phone,
                textAlign: TextAlign.center,
                style: ZuriTextStyles.rowSecondary.copyWith(
                  color: _EndedCallColors.muted,
                ),
              ),
              const SizedBox(height: 28),
              _CostSummaryCard(call: call, cost: cost),
              const SizedBox(height: 22),
              Center(
                child: SizedBox(
                  width: 210,
                  height: 60,
                  child: FilledButton.icon(
                    onPressed: onCallBack,
                    icon: const Icon(ZuriIcons.phone),
                    label: const Text(
                      'Call back',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: ZuriColors.primary,
                      foregroundColor: Colors.white,
                      shape: const StadiumBorder(),
                      textStyle: ZuriTextStyles.primaryButtonLabel,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EndedStatusPill extends StatelessWidget {
  const _EndedStatusPill();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _EndedCallColors.pill,
        borderRadius: BorderRadius.circular(ZuriRadius.round),
        border: Border.all(color: _EndedCallColors.border, width: 1.2),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        child: Text(
          'Call ended',
          style: ZuriTextStyles.strongButtonLabel.copyWith(
            color: _EndedCallColors.muted,
          ),
        ),
      ),
    );
  }
}

class _EndedAvatar extends StatelessWidget {
  const _EndedAvatar({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 112,
      height: 112,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: ZuriColors.endedCallAvatar,
        borderRadius: BorderRadius.circular(ZuriRadius.avatar),
      ),
      child: Text(
        label,
        style: ZuriTextStyles.avatarDisplay.copyWith(
          color: Colors.white,
        ),
      ),
    );
  }
}

class _CostSummaryCard extends StatelessWidget {
  const _CostSummaryCard({
    required this.call,
    required this.cost,
  });

  final CallRecord call;
  final double cost;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
      decoration: BoxDecoration(
        color: ZuriColors.card,
        borderRadius: BorderRadius.circular(ZuriRadius.tile),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ZuriMetricTile(
                  label: 'DURATION',
                  value: _formatCallSummaryDuration(call.durationSeconds),
                  labelColor: _EndedCallColors.muted,
                ),
              ),
              Container(
                width: 1,
                height: 66,
                color: _EndedCallColors.divider,
              ),
              Expanded(
                child: ZuriMetricTile(
                  label: 'COST',
                  value: '\$${cost.toStringAsFixed(2)}',
                  labelColor: _EndedCallColors.muted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: _EndedCallColors.divider, height: 1),
          const SizedBox(height: 16),
          ZuriInfoRow(
            compact: true,
            label: 'Rate',
            value: '\$0.02 / min • ${_countryFlagFor(call.phone) ?? ''} '
                '${_countryLabelFor(call.phone) ?? ''}',
            padding: EdgeInsets.zero,
          ),
          const SizedBox(height: 12),
          const _QualitySummaryRow(),
          const SizedBox(height: 12),
          const ZuriInfoRow(
            compact: true,
            label: 'Wallet balance',
            value: '\$4.88 remaining',
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}

class _QualitySummaryRow extends StatelessWidget {
  const _QualitySummaryRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Call quality',
            style: ZuriTextStyles.meta.copyWith(
              color: _EndedCallColors.muted,
            ),
          ),
        ),
        Row(
          children: [
            for (var i = 0; i < 5; i += 1)
              Padding(
                padding: EdgeInsets.only(left: i == 0 ? 0 : 4),
                child: Icon(
                  ZuriIcons.check,
                  size: 12,
                  color: i < 4
                      ? _EndedCallColors.quality
                      : _EndedCallColors.divider,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _CallAvatar extends StatelessWidget {
  const _CallAvatar({
    required this.label,
    required this.motion,
    required this.mode,
  });

  final String label;
  final Animation<double> motion;
  final _CallUiMode mode;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: motion,
      builder: (context, child) {
        final wave = (math.sin(motion.value * math.pi * 2) + 1) / 2;
        final isLive = mode == _CallUiMode.active;
        final outerOpacity = isLive ? 0.18 + wave * 0.12 : 0.08;
        final innerOpacity = isLive ? 0.18 + (1 - wave) * 0.15 : 0.1;
        final showPulse = mode == _CallUiMode.active;
        final borderColor = mode == _CallUiMode.poorNetwork
            ? _InCallColors.dangerBorder
            : mode == _CallUiMode.onHold
                ? _InCallColors.holdBorder.withValues(alpha: 0.42)
                : _InCallColors.avatarRing;

        return SizedBox.square(
          dimension: 150,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (showPulse)
                Container(
                  width: 132 + wave * 10,
                  height: 132 + wave * 10,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(46),
                    border: Border.all(
                      color: borderColor.withValues(alpha: outerOpacity),
                      width: 2,
                    ),
                  ),
                ),
              Container(
                width: mode == _CallUiMode.poorNetwork ? 112 : 116,
                height: mode == _CallUiMode.poorNetwork ? 112 : 116,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(38),
                  border: Border.all(
                    color: borderColor.withValues(
                      alpha:
                          mode == _CallUiMode.poorNetwork ? 0.9 : innerOpacity,
                    ),
                    width: 2.2,
                  ),
                ),
              ),
              Container(
                width: 96,
                height: 96,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _InCallColors.avatarFill,
                  borderRadius: BorderRadius.circular(34),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Text(
                      label,
                      style: ZuriTextStyles.avatarDisplay.copyWith(
                        color: _InCallColors.text,
                      ),
                    ),
                    if (mode == _CallUiMode.muted)
                      const Icon(
                        ZuriIcons.microphoneOff,
                        size: 42,
                        color: _InCallColors.text,
                      ),
                    if (mode == _CallUiMode.onHold)
                      Icon(
                        ZuriIcons.pause,
                        size: 42,
                        color: _InCallColors.holdText.withValues(alpha: 0.75),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Waveform extends StatelessWidget {
  const _Waveform({
    required this.motion,
    required this.isLive,
  });

  final Animation<double> motion;
  final bool isLive;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: motion,
      builder: (context, child) {
        return CustomPaint(
          painter: _WaveformPainter(
            progress: motion.value,
            isLive: isLive,
          ),
          child: const SizedBox(width: 72, height: 34),
        );
      },
    );
  }
}

class _WaveformPainter extends CustomPainter {
  const _WaveformPainter({
    required this.progress,
    required this.isLive,
  });

  final double progress;
  final bool isLive;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _InCallColors.waveform.withValues(
        alpha: isLive ? 0.62 : 0.28,
      )
      ..strokeWidth = 3.4
      ..strokeCap = StrokeCap.round;
    const bars = 9;
    final spacing = size.width / (bars - 1);
    final centerY = size.height / 2;

    for (var i = 0; i < bars; i += 1) {
      final phase = progress * math.pi * 2 + i * 0.72;
      final breath = isLive ? (math.sin(phase) + 1) / 2 : 0.12;
      final height = isLive ? 8 + breath * 24 : 3.5;
      final x = i * spacing;
      canvas.drawLine(
        Offset(x, centerY - height / 2),
        Offset(x, centerY + height / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.isLive != isLive;
  }
}

class _HoldStatusLine extends StatelessWidget {
  const _HoldStatusLine({required this.seconds});

  final int seconds;

  @override
  Widget build(BuildContext context) {
    return Text(
      'Call paused • ${_formatShortDuration(seconds)} on hold',
      textAlign: TextAlign.center,
      style: ZuriTextStyles.emphasisText.copyWith(
        color: _InCallColors.muted,
      ),
    );
  }
}

class _SignalQuality extends StatelessWidget {
  const _SignalQuality();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const _SignalBars(),
        const SizedBox(width: 10),
        Text(
          'Weak signal',
          style: ZuriTextStyles.emphasisText.copyWith(
            color: _InCallColors.dangerText,
          ),
        ),
      ],
    );
  }
}

class _SignalBars extends StatelessWidget {
  const _SignalBars();

  @override
  Widget build(BuildContext context) {
    const heights = [9.0, 14.0, 20.0, 28.0];
    return SizedBox(
      width: 43,
      height: 30,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < heights.length; i += 1) ...[
            Container(
              width: 7,
              height: heights[i],
              decoration: BoxDecoration(
                color: i == 0
                    ? _InCallColors.dangerText
                    : _InCallColors.waveform.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(ZuriRadius.waveform),
              ),
            ),
            if (i != heights.length - 1) const SizedBox(width: 5),
          ],
        ],
      ),
    );
  }
}

class _CallNoticeBanner extends StatelessWidget {
  const _CallNoticeBanner({
    required this.mode,
    required this.text,
    this.actionLabel,
    this.onAction,
  });

  final _CallUiMode mode;
  final String text;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final foreground = mode == _CallUiMode.onHold
        ? _InCallColors.holdText
        : _InCallColors.dangerText;
    final border = mode == _CallUiMode.onHold
        ? _InCallColors.holdBorder
        : _InCallColors.dangerBorder;
    final background = mode == _CallUiMode.onHold
        ? _InCallColors.holdSoft
        : _InCallColors.dangerSoft;
    final icon =
        mode == _CallUiMode.onHold ? ZuriIcons.pause : ZuriIcons.warning;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(ZuriRadius.surface),
        border: Border.all(color: border, width: 1.2),
      ),
      child: Row(
        children: [
          Icon(icon, color: foreground, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: ZuriTextStyles.emphasisText.copyWith(
                color: foreground,
                height: 1.2,
              ),
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(width: 12),
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                backgroundColor: _InCallColors.control,
                foregroundColor: foreground,
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                textStyle: ZuriTextStyles.strongButtonLabel,
              ),
              child: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}

class _CallControls extends StatelessWidget {
  const _CallControls({
    required this.isMuted,
    required this.isSpeakerOn,
    required this.isHoldOn,
    required this.isKeypadOpen,
    required this.mode,
    required this.onMute,
    required this.onSpeaker,
    required this.onHold,
    required this.onKeypad,
  });

  final bool isMuted;
  final bool isSpeakerOn;
  final bool isHoldOn;
  final bool isKeypadOpen;
  final _CallUiMode mode;
  final VoidCallback onMute;
  final VoidCallback onSpeaker;
  final VoidCallback onHold;
  final VoidCallback onKeypad;

  @override
  Widget build(BuildContext context) {
    final controlsDisabled = mode == _CallUiMode.onHold;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _CallControlButton(
          icon: isMuted ? ZuriIcons.microphoneOff : ZuriIcons.microphone,
          label: isMuted ? 'Muted' : 'Mute',
          isActive: isMuted,
          isDanger: isMuted,
          onPressed: controlsDisabled ? null : onMute,
        ),
        _CallControlButton(
          icon: ZuriIcons.speaker,
          label: 'Speaker',
          isActive: isSpeakerOn,
          onPressed: controlsDisabled ? null : onSpeaker,
        ),
        _CallControlButton(
          icon: isHoldOn ? ZuriIcons.play : ZuriIcons.pause,
          label: isHoldOn ? 'Resume' : 'Hold',
          isActive: isHoldOn,
          isHold: isHoldOn,
          onPressed: onHold,
        ),
        _CallControlButton(
          icon: ZuriIcons.dialpad,
          label: 'Keypad',
          isActive: isKeypadOpen,
          onPressed: controlsDisabled ? null : onKeypad,
        ),
      ],
    );
  }
}

class _CallControlButton extends StatelessWidget {
  const _CallControlButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onPressed,
    this.isDanger = false,
    this.isHold = false,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback? onPressed;
  final bool isDanger;
  final bool isHold;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final foregroundColor = isHold
        ? _InCallColors.holdText
        : isDanger
            ? _InCallColors.dangerText
            : isActive
                ? _InCallColors.text
                : _InCallColors.controlIcon;
    final backgroundColor = isHold
        ? _InCallColors.holdSoft
        : isDanger
            ? _InCallColors.dangerSoft
            : isActive
                ? _InCallColors.controlActive
                : _InCallColors.control;
    final borderColor = isHold
        ? _InCallColors.holdBorder
        : isDanger
            ? _InCallColors.dangerBorder
            : Colors.transparent;

    return Expanded(
      child: Opacity(
        opacity: enabled ? 1 : 0.4,
        child: Column(
          children: [
            SizedBox(
              width: 58,
              height: 58,
              child: TextButton(
                onPressed: onPressed,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  backgroundColor: backgroundColor,
                  foregroundColor: foregroundColor,
                  disabledForegroundColor: foregroundColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(ZuriRadius.badge),
                  ),
                  side: BorderSide(color: borderColor, width: 1.2),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 22),
                    const SizedBox(height: 4),
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: ZuriTextStyles.navItemLabel.copyWith(
                        color: foregroundColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomCallActions extends StatelessWidget {
  const _BottomCallActions({
    required this.onEndCall,
  });

  final VoidCallback onEndCall;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox.square(
        dimension: 58,
        child: IconButton(
          onPressed: onEndCall,
          icon: const Icon(ZuriIcons.phoneOff, size: 22),
          color: Colors.white,
          style: IconButton.styleFrom(
            backgroundColor: _InCallColors.endCall,
            shape: const CircleBorder(),
          ),
        ),
      ),
    );
  }
}

enum _CallUiMode {
  active,
  muted,
  onHold,
  poorNetwork,
  connecting,
  ended;

  factory _CallUiMode.fromState({
    required ActiveCallStatus status,
    required bool isMuted,
    required bool isOnHold,
    required bool isCompleting,
  }) {
    if (status == ActiveCallStatus.failed ||
        status == ActiveCallStatus.ended ||
        isCompleting) {
      return _CallUiMode.ended;
    }
    if (isOnHold) return _CallUiMode.onHold;
    if (status == ActiveCallStatus.poorNetwork) return _CallUiMode.poorNetwork;
    if (isMuted && status == ActiveCallStatus.connected) {
      return _CallUiMode.muted;
    }
    if (status == ActiveCallStatus.connected) return _CallUiMode.active;
    return _CallUiMode.connecting;
  }

  Color get softColor {
    return switch (this) {
      _CallUiMode.onHold => _InCallColors.holdSoft,
      _CallUiMode.poorNetwork ||
      _CallUiMode.muted ||
      _CallUiMode.ended =>
        _InCallColors.dangerSoft,
      _ => _InCallColors.liveSoft,
    };
  }

  Color get borderColor {
    return switch (this) {
      _CallUiMode.onHold => _InCallColors.holdBorder,
      _CallUiMode.poorNetwork ||
      _CallUiMode.muted ||
      _CallUiMode.ended =>
        _InCallColors.dangerBorder,
      _ => _InCallColors.liveBorder,
    };
  }

  Color get foregroundColor {
    return switch (this) {
      _CallUiMode.onHold => _InCallColors.holdText,
      _CallUiMode.poorNetwork ||
      _CallUiMode.muted ||
      _CallUiMode.ended =>
        _InCallColors.dangerText,
      _ => _InCallColors.liveText,
    };
  }

  IconData? get badgeIcon {
    return switch (this) {
      _CallUiMode.muted => ZuriIcons.microphoneOff,
      _CallUiMode.onHold => ZuriIcons.pause,
      _CallUiMode.poorNetwork => ZuriIcons.wifiOff,
      _CallUiMode.ended => ZuriIcons.phoneOff,
      _ => null,
    };
  }
}

class _InCallColors {
  const _InCallColors._();

  static const background = ZuriColors.forest900;
  static const text = ZuriColors.surface;
  static const muted = ZuriColors.overlayOnForest;
  static const avatarFill = ZuriColors.inCallAvatarFill;
  static const avatarRing = ZuriColors.inCallAvatarRing;
  static const waveform = ZuriColors.inCallWaveform;
  static const control = ZuriColors.inCallControl;
  static const controlActive = ZuriColors.inCallControlActive;
  static const controlIcon = ZuriColors.inCallControlIcon;
  static const endCall = ZuriColors.danger;
  static const liveSoft = ZuriColors.inCallLiveSoft;
  static const liveBorder = ZuriColors.inCallLiveBorder;
  static const liveText = ZuriColors.inCallLiveText;
  static const dangerSoft = ZuriColors.inCallDangerSoft;
  static const dangerBorder = ZuriColors.inCallDangerBorder;
  static const dangerText = ZuriColors.inCallDangerText;
  static const holdSoft = ZuriColors.inCallHoldSoft;
  static const holdBorder = ZuriColors.inCallHoldBorder;
  static const holdText = ZuriColors.inCallHoldText;
}

class _EndedCallColors {
  const _EndedCallColors._();

  static const background = ZuriColors.surface;
  static const pill = ZuriColors.endedCallPill;
  static const border = ZuriColors.endedCallBorder;
  static const divider = ZuriColors.endedCallDivider;
  static const muted = ZuriColors.endedCallMuted;
  static const quality = ZuriColors.endedCallQuality;
}

String _formatShortDuration(int totalSeconds) {
  final minutes = totalSeconds ~/ 60;
  final seconds = totalSeconds % 60;
  final paddedSeconds = seconds.toString().padLeft(2, '0');
  return '$minutes:$paddedSeconds';
}

String _formatCallSummaryDuration(int totalSeconds) {
  final minutes = totalSeconds ~/ 60;
  final seconds = totalSeconds % 60;
  final paddedMinutes = minutes.toString().padLeft(2, '0');
  final paddedSeconds = seconds.toString().padLeft(2, '0');
  return '$paddedMinutes:$paddedSeconds';
}

String _initialsFor(String value) {
  final parts = value
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .take(2)
      .toList();
  if (parts.isEmpty) return '?';

  return parts.map((part) => part[0].toUpperCase()).join();
}

String? _countryFlagFor(String phone) => PhoneCountryLookup.flagFor(phone);

String? _countryLabelFor(String phone) => PhoneCountryLookup.codeFor(phone);

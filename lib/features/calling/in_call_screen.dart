import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/theme/zuri_theme.dart';
import '../../core/ui/zuri_ui.dart';
import '../home/call_record.dart';
import 'call_service.dart';

class InCallScreen extends StatefulWidget {
  const InCallScreen({
    required this.request,
    required this.callService,
    required this.onCallEnded,
    super.key,
  });

  final OutgoingCallRequest request;
  final CallService callService;
  final ValueChanged<CallRecord> onCallEnded;

  @override
  State<InCallScreen> createState() => _InCallScreenState();
}

class _InCallScreenState extends State<InCallScreen> {
  StreamSubscription<ActiveCallStatus>? callSubscription;
  Timer? callTimer;
  Timer? returnTimer;
  ActiveCallStatus status = ActiveCallStatus.connecting;
  DateTime? connectedAt;
  int elapsedSeconds = 0;
  bool isMuted = false;
  bool isSpeakerOn = false;
  bool isKeypadOpen = false;
  bool isCompleting = false;

  @override
  void initState() {
    super.initState();
    callSubscription = widget.callService
        .startOutgoingCall(widget.request)
        .listen(_handleStatusChanged);
  }

  @override
  void dispose() {
    callSubscription?.cancel();
    callTimer?.cancel();
    returnTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayName = widget.request.name?.trim();
    final title = displayName == null || displayName.isEmpty
        ? widget.request.phone
        : displayName;

    return Scaffold(
      backgroundColor: ZuriColors.surface,
      body: SafeArea(
        child: Padding(
          padding: ZuriSpacing.screen,
          child: Column(
            children: [
              const SizedBox(height: 18),
              ZuriAvatar(
                label: _initials(title),
                color: ZuriColors.primary,
                size: 88,
              ),
              const SizedBox(height: 22),
              Text(
                title,
                textAlign: TextAlign.center,
                style: ZuriTextStyles.compactTitle.copyWith(
                  color: ZuriColors.ink,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.request.phone,
                textAlign: TextAlign.center,
                style: ZuriTextStyles.bodyLarge.copyWith(
                  color: ZuriColors.muted,
                ),
              ),
              const SizedBox(height: 18),
              _StatusPill(status: status),
              const SizedBox(height: 10),
              Text(
                _supportingStatusText,
                textAlign: TextAlign.center,
                style: ZuriTextStyles.bodyLarge.copyWith(
                  color: ZuriColors.muted,
                ),
              ),
              const Spacer(),
              _CallControls(
                isMuted: isMuted,
                isSpeakerOn: isSpeakerOn,
                isKeypadOpen: isKeypadOpen,
                onMute: () => setState(() => isMuted = !isMuted),
                onSpeaker: () => setState(() => isSpeakerOn = !isSpeakerOn),
                onKeypad: () => setState(() => isKeypadOpen = !isKeypadOpen),
              ),
              const SizedBox(height: 28),
              SizedBox.square(
                dimension: 72,
                child: IconButton(
                  onPressed: _endCall,
                  icon: const Icon(Icons.call_end_rounded, size: 34),
                  color: Colors.white,
                  style: IconButton.styleFrom(
                    backgroundColor: ZuriColors.danger,
                    shape: const CircleBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 18),
            ],
          ),
        ),
      ),
    );
  }

  void _handleStatusChanged(ActiveCallStatus nextStatus) {
    if (!mounted) return;
    if (isCompleting) return;

    if (nextStatus == ActiveCallStatus.failed) {
      _completeCall(CallStatus.failed, terminalStatus: nextStatus);
      return;
    }

    setState(() {
      status = nextStatus;
      if (nextStatus == ActiveCallStatus.connected && connectedAt == null) {
        connectedAt = DateTime.now();
        elapsedSeconds = 0;
        _startCallTimer();
      }
    });
  }

  void _endCall() {
    final callStatus =
        connectedAt == null ? CallStatus.cancelled : CallStatus.completed;
    _completeCall(callStatus, terminalStatus: ActiveCallStatus.ended);
  }

  void _completeCall(
    CallStatus callStatus, {
    required ActiveCallStatus terminalStatus,
  }) {
    if (isCompleting) return;

    final durationSeconds = elapsedSeconds;
    callSubscription?.cancel();
    callTimer?.cancel();

    setState(() {
      isCompleting = true;
      status = terminalStatus;
      elapsedSeconds = durationSeconds;
    });

    returnTimer = Timer(const Duration(milliseconds: 900), () {
      if (!mounted) return;

      widget.onCallEnded(
        CallRecord.fromDialpad(
          number: widget.request.phone,
          name: widget.request.name,
          startedAt: widget.request.startedAt,
          status: callStatus,
          durationSeconds: durationSeconds,
        ),
      );
    });
  }

  void _startCallTimer() {
    callTimer?.cancel();
    callTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || connectedAt == null || isCompleting) return;

      setState(() {
        elapsedSeconds += 1;
      });
    });
  }

  String get _supportingStatusText {
    return switch (status) {
      ActiveCallStatus.connected => _formatDuration(elapsedSeconds),
      ActiveCallStatus.ended => 'Call ended',
      ActiveCallStatus.failed => 'Unable to connect',
      ActiveCallStatus.ringing => 'Waiting for answer',
      ActiveCallStatus.connecting => 'Setting up secure audio',
    };
  }

  String _formatDuration(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    final paddedSeconds = seconds.toString().padLeft(2, '0');
    return '$minutes:$paddedSeconds';
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
  const _StatusPill({required this.status});

  final ActiveCallStatus status;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: ZuriColors.callSurface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: ZuriColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        child: Text(
          status.label,
          style: ZuriTextStyles.label.copyWith(color: ZuriColors.ink),
        ),
      ),
    );
  }
}

class _CallControls extends StatelessWidget {
  const _CallControls({
    required this.isMuted,
    required this.isSpeakerOn,
    required this.isKeypadOpen,
    required this.onMute,
    required this.onSpeaker,
    required this.onKeypad,
  });

  final bool isMuted;
  final bool isSpeakerOn;
  final bool isKeypadOpen;
  final VoidCallback onMute;
  final VoidCallback onSpeaker;
  final VoidCallback onKeypad;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _CallControlButton(
          icon: isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
          label: 'Mute',
          isActive: isMuted,
          onPressed: onMute,
        ),
        _CallControlButton(
          icon: Icons.dialpad_rounded,
          label: 'Keypad',
          isActive: isKeypadOpen,
          onPressed: onKeypad,
        ),
        _CallControlButton(
          icon: Icons.volume_up_rounded,
          label: 'Speaker',
          isActive: isSpeakerOn,
          onPressed: onSpeaker,
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
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final foregroundColor = isActive ? Colors.white : ZuriColors.ink;
    final backgroundColor = isActive ? ZuriColors.primary : ZuriColors.card;

    return Column(
      children: [
        SizedBox.square(
          dimension: 62,
          child: IconButton(
            onPressed: onPressed,
            icon: Icon(icon),
            color: foregroundColor,
            style: IconButton.styleFrom(
              backgroundColor: backgroundColor,
              shape: const CircleBorder(),
              side: BorderSide(
                color: isActive ? ZuriColors.primary : ZuriColors.border,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: ZuriTextStyles.rowMeta.copyWith(color: ZuriColors.muted),
        ),
      ],
    );
  }
}

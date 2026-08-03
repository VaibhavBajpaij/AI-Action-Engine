import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme.dart';
import '../providers.dart';
import '../network/process_result.dart';
import '../widgets.dart';
import 'content_detail_screen.dart';

class ProcessingScreen extends ConsumerStatefulWidget {
  final String url;
  final String platform;
  final void Function(String contentItemId)? onSuccess;

  const ProcessingScreen({
    super.key,
    required this.url,
    required this.platform,
    this.onSuccess,
  });

  @override
  ConsumerState<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends ConsumerState<ProcessingScreen> {
  static const _labels = [
    "Fetching the video",
    "Reading the transcript",
    "Building your notes",
  ];

  int _labelIndex = 0;
  Timer? _timer;
  StreamSubscription<ProcessResult>? _subscription;
  ProcessResult? _result;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _submit();
  }

  void _startTimer() {
    _timer?.cancel();
    _labelIndex = 0;
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted) {
        setState(() {
          if (_labelIndex < _labels.length - 1) {
            _labelIndex++;
          }
        });
      }
    });
  }

  void _submit() {
    setState(() {
      _result = const ProcessResult.loading();
    });
    _startTimer();
    
    _subscription?.cancel();
    _subscription = ref
        .read(processServiceProvider)
        .submitUrl(widget.url)
        .listen((result) {
      setState(() {
        _result = result;
      });

      result.maybeWhen(
        success: (dto) {
          _subscription?.cancel();
          _timer?.cancel();
          if (mounted) {
            if (widget.onSuccess != null) {
              widget.onSuccess!(dto.id);
            } else {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => ContentDetailScreen(contentItemId: dto.id),
                ),
              );
            }
          }
        },
        error: (error) {
          _timer?.cancel();
        },
        orElse: () {},
      );
    });
  }

  ContentPlatform _getPlatformEnum(String platform) {
    switch (platform) {
      case 'instagram':
        return ContentPlatform.instagram;
      case 'youtube':
        return ContentPlatform.youtube;
      case 'linkedin':
        return ContentPlatform.linkedin;
      case 'facebook':
        return ContentPlatform.facebook;
      default:
        return ContentPlatform.general;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: AppCard(
            color: AppColors.slate,
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                PlatformIcon(
                  platform: _getPlatformEnum(widget.platform),
                ),
                const SizedBox(height: 32),
                if (_result == null || _result!.maybeMap(loading: (_) => true, orElse: () => false)) ...[
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(AppColors.saffron),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _labels[_labelIndex],
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.paper),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  SecondaryButton(
                    label: 'Cancel',
                    onTap: () {
                      _subscription?.cancel();
                      Navigator.of(context).pop();
                    },
                  ),
                ] else if (_result!.maybeMap(error: (_) => true, orElse: () => false)) ...[
                  const Icon(
                    Icons.error_outline,
                    color: AppColors.saffron,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _result!.maybeMap(error: (e) => e.error.userMessage(widget.platform), orElse: () => ''),
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.paper),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SecondaryButton(
                        label: 'Cancel',
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      const SizedBox(width: 16),
                      PrimaryButton(
                        label: 'Retry',
                        onTap: _submit,
                      ),
                    ],
                  ),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }
}

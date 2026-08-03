import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/app_database.dart';
import '../../providers.dart';
import '../../theme.dart';
import '../../widgets.dart';

class NotesTab extends ConsumerStatefulWidget {
  const NotesTab({super.key, required this.contentItemId});

  final String contentItemId;

  @override
  ConsumerState<NotesTab> createState() => _NotesTabState();
}

class _NotesTabState extends ConsumerState<NotesTab> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounceTimer;
  Timer? _savedTextTimer;
  bool _showSavedText = false;
  Note? _currentNote;
  bool _isInitialized = false;

  @override
  void dispose() {
    _controller.dispose();
    _debounceTimer?.cancel();
    _savedTextTimer?.cancel();
    super.dispose();
  }

  void _onTextChanged(String text) {
    setState(() {}); // Update character count
    
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(seconds: 1), () {
      _saveNote(text);
    });
  }

  Future<void> _saveNote(String text) async {
    final repo = ref.read(noteRepositoryProvider);
    if (_currentNote == null) {
      if (text.trim().isEmpty) return; // Don't create empty note
      final newNote = await repo.createNote(
        contentItemId: widget.contentItemId,
        text: text,
      );
      if (mounted) {
        setState(() {
          _currentNote = newNote;
        });
      }
    } else {
      await repo.updateNote(id: _currentNote!.id, text: text);
    }

    if (mounted) {
      setState(() {
        _showSavedText = true;
      });
      _savedTextTimer?.cancel();
      _savedTextTimer = Timer(const Duration(milliseconds: 1500), () {
        if (mounted) {
          setState(() {
            _showSavedText = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncNotes = ref.watch(notesByItemProvider(widget.contentItemId));

    return asyncNotes.when(
      data: (notes) {
        if (!_isInitialized) {
          if (notes.isNotEmpty) {
            _currentNote = notes.first;
            _controller.text = _currentNote!.text_;
          }
          _isInitialized = true;
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  onChanged: _onTextChanged,
                  maxLines: null,
                  expands: true,
                  style: AppTextStyles.bodyLarge.copyWith(color: AppColors.paper),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Write your own notes here',
                    hintStyle: AppTextStyles.bodyLarge.copyWith(color: AppColors.paperFaint),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AnimatedOpacity(
                    opacity: _showSavedText ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      'Saved',
                      style: AppTextStyles.caption.copyWith(color: AppColors.saffron),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${_controller.text.length} chars',
                    style: AppTextStyles.caption.copyWith(color: AppColors.paperFaint),
                  ),
                ],
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err', style: AppTextStyles.bodyMedium)),
    );
  }
}

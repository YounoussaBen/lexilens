import 'package:flutter/material.dart';
import '../../../core/services/tts_service.dart';

class WordFlashcard extends StatefulWidget {
  final String word;
  final String definition;
  final double confidence;
  final VoidCallback onSave;
  final VoidCallback onClose;
  final bool isAlreadySaved;

  const WordFlashcard({
    super.key,
    required this.word,
    required this.definition,
    required this.confidence,
    required this.onSave,
    required this.onClose,
    this.isAlreadySaved = false,
  });

  @override
  State<WordFlashcard> createState() => _WordFlashcardState();
}

class _WordFlashcardState extends State<WordFlashcard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  final TTSService _ttsService = TTSService();
  bool _isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _ttsService.initialize();
    _animationController.forward();

    // Auto-pronounce the word when flashcard appears
    Future.delayed(const Duration(milliseconds: 500), () {
      _speakWord();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _ttsService.stop();
    super.dispose();
  }

  Future<void> _speakWord() async {
    if (_isSpeaking) return;
    
    setState(() {
      _isSpeaking = true;
    });

    await _ttsService.speakSlowly(widget.word);
    
    // Wait a bit to ensure speech completes
    await Future.delayed(const Duration(seconds: 1));
    
    if (mounted) {
      setState(() {
        _isSpeaking = false;
      });
    }
  }

  void _closeFlashcard() async {
    await _animationController.reverse();
    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;
    
    return Material(
      color: Colors.black54,
      child: GestureDetector(
        onTap: _closeFlashcard,
        child: Center(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: screenSize.width * 0.85,
                    constraints: BoxConstraints(
                      maxWidth: 400,
                      maxHeight: screenSize.height * 0.6,
                    ),
                    margin: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: theme.colorScheme.outline.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildHeader(theme),
                        _buildContent(theme),
                        _buildActions(theme),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.school,
            color: theme.colorScheme.primary,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'New Word Detected!',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          IconButton(
            onPressed: _closeFlashcard,
            icon: const Icon(Icons.close),
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            iconSize: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Word display
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Text(
                widget.word.toUpperCase(),
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                  letterSpacing: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Definition
            Text(
              widget.definition,
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 1.5,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 20),
            
            // Confidence indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getConfidenceColor().withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.trending_up,
                    size: 16,
                    color: _getConfidenceColor(),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${(widget.confidence * 100).toInt()}% confident',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: _getConfidenceColor(),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActions(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Pronunciation button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isSpeaking ? null : _speakWord,
              icon: _isSpeaking
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: theme.colorScheme.onPrimary,
                      ),
                    )
                  : const Icon(Icons.volume_up),
              label: Text(_isSpeaking ? 'Speaking...' : 'Hear Pronunciation'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Action buttons row
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _closeFlashcard,
                  icon: const Icon(Icons.close),
                  label: const Text('Skip'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 12),
              
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: widget.isAlreadySaved ? null : () {
                    widget.onSave();
                    _closeFlashcard();
                  },
                  icon: Icon(
                    widget.isAlreadySaved ? Icons.bookmark : Icons.bookmark_add,
                  ),
                  label: Text(
                    widget.isAlreadySaved ? 'Saved' : 'Save Word',
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: widget.isAlreadySaved 
                        ? theme.colorScheme.surfaceContainerHighest
                        : theme.colorScheme.primary,
                    foregroundColor: widget.isAlreadySaved
                        ? theme.colorScheme.onSurface.withValues(alpha: 0.6)
                        : theme.colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getConfidenceColor() {
    if (widget.confidence >= 0.8) return Colors.green;
    if (widget.confidence >= 0.6) return Colors.orange;
    return Colors.red;
  }
}
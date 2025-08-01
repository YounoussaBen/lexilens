import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../../providers/chat_provider.dart';

/// Chat screen with AI tutor interface for vocabulary learning
class ChatScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? wordContext;

  const ChatScreen({super.key, this.wordContext});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Initialize chat with word context if provided
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.wordContext != null) {
        _initializeWithWordContext();
      }
    });
  }

  void _initializeWithWordContext() {
    final wordData =
        widget.wordContext!['wordContext'] as Map<String, dynamic>?;
    final contextType = widget.wordContext!['contextType'] as String?;

    if (wordData != null && contextType == 'word_of_the_day') {
      // Send the detailed message to AI but show simple word in UI
      final fullMessage =
          "Tell me everything interesting about today's word of the day: '${wordData['word']}'. "
          "I'd love to learn about its origins, etymology, different meanings, interesting examples, "
          "synonyms, antonyms, and any fun facts about this word!";

      final displayMessage = "**${wordData['word']}** (Word of the Day)";

      // Add the user message with custom display text
      ref
          .read(chatProvider.notifier)
          .addUserMessage(fullMessage, displayText: displayMessage);
    } else if (wordData != null && contextType == 'saved_word') {
      // Handle saved words
      final fullMessage =
          "I want to learn more about the word '${wordData['word']}'. "
          "Can you tell me everything interesting about it? Including its meaning, origins, "
          "pronunciation, different uses, examples, and any fascinating facts?";

      final displayMessage = "**${wordData['word']}**";

      ref
          .read(chatProvider.notifier)
          .addUserMessage(fullMessage, displayText: displayMessage);
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Column(
            children: [
              // Header
              _buildChatHeader(context),
              const SizedBox(height: 20),

              // Content
              Expanded(child: _buildChatContent(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Chat',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            Text(
              'Your vocabulary tutor',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.refresh_outlined),
              onPressed: () => ref.read(chatProvider.notifier).clearChat(),
              style: IconButton.styleFrom(
                backgroundColor: Colors.grey[100],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              onSelected: _handleMenuSelection,
              icon: Icon(Icons.more_vert),
              style: IconButton.styleFrom(
                backgroundColor: Colors.grey[100],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'practice',
                  child: ListTile(
                    leading: Icon(Icons.psychology_outlined),
                    title: Text('Practice Mode'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'help',
                  child: ListTile(
                    leading: Icon(Icons.help_outline),
                    title: Text('Help'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChatContent(BuildContext context) {
    final chatState = ref.watch(chatProvider);

    return Column(
      children: [
        // Messages list
        Expanded(
          child: chatState.messages.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16.0),
                  itemCount: chatState.messages.length,
                  itemBuilder: (context, index) {
                    return _buildMessageBubble(chatState.messages[index]);
                  },
                ),
        ),

        // Message input
        _buildMessageInput(),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.bolt,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[900],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildPremiumQuickActionChip(
                'Practice Words',
                Icons.psychology_outlined,
                Colors.purple[600]!,
                () => ref
                    .read(chatProvider.notifier)
                    .sendQuickMessage(
                      'Help me practice my recent vocabulary words',
                    ),
              ),
              _buildPremiumQuickActionChip(
                'Explain Word',
                Icons.lightbulb_outline,
                Colors.orange[600]!,
                () => ref
                    .read(chatProvider.notifier)
                    .sendQuickMessage(
                      'Can you explain the meaning of a word for me?',
                    ),
              ),
              _buildPremiumQuickActionChip(
                'Grammar Help',
                Icons.school_outlined,
                Colors.green[600]!,
                () => ref
                    .read(chatProvider.notifier)
                    .sendQuickMessage('I need help with English grammar'),
              ),
              _buildPremiumQuickActionChip(
                'Create Quiz',
                Icons.quiz_outlined,
                Colors.blue[600]!,
                () => ref
                    .read(chatProvider.notifier)
                    .sendQuickMessage('Create a vocabulary quiz for me'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumQuickActionChip(
    String label,
    IconData icon,
    Color iconColor,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, size: 16, color: iconColor),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.grey[900],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Icon(Icons.psychology_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Start a conversation',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Ask me anything about vocabulary or English!',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          _buildQuickActions(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: message.isUser
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: [
            if (!message.isUser) ...[
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.psychology,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: message.isUser
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                  border: message.isUser
                      ? null
                      : Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle streaming vs normal messages
                    if (message.isStreaming &&
                        message.displayText != null &&
                        message.displayText!.isNotEmpty)
                      // Show the streaming text for AI messages
                      _buildMarkdownContent(
                        message.displayText!,
                        isUserMessage: false,
                      )
                    else if (message.isStreaming)
                      // Show loading indicator when streaming but no text yet
                      _buildStreamingIndicator()
                    else if (message.isUser)
                      // Use displayText if available, otherwise use regular text
                      message.displayText != null
                          ? _buildMarkdownContent(
                              message.displayText!,
                              isUserMessage: true,
                            )
                          : Text(
                              message.text,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w400,
                              ),
                            )
                    else
                      _buildMarkdownContent(message.text, isUserMessage: false),
                    const SizedBox(height: 4),
                    Text(
                      _formatTime(message.timestamp),
                      style: TextStyle(
                        fontSize: 10,
                        color:
                            (message.isUser
                                    ? Theme.of(context).colorScheme.onPrimary
                                    : Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant)
                                .withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (message.isUser) ...[
              const SizedBox(width: 8),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.person_outline,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type your message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _sendMessage,
            icon: const Icon(Icons.send_outlined),
            style: IconButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    ref.read(chatProvider.notifier).addUserMessage(text);
    _messageController.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildMarkdownContent(String text, {bool isUserMessage = false}) {
    return SizedBox(
      width: double.infinity,
      child: MarkdownBody(
        data: text,
        selectable: true,
        styleSheet: MarkdownStyleSheet(
          p: TextStyle(
            color: isUserMessage ? Colors.white : Colors.grey[800],
            fontWeight: FontWeight.w400,
            fontSize: 14,
          ),
          strong: TextStyle(
            color: isUserMessage ? Colors.white : Colors.grey[900],
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          em: TextStyle(
            color: isUserMessage
                ? Colors.white.withValues(alpha: 0.9)
                : Colors.grey[800],
            fontStyle: FontStyle.italic,
            fontSize: 14,
          ),
          h1: TextStyle(
            color: isUserMessage ? Colors.white : Colors.grey[900],
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
          h2: TextStyle(
            color: isUserMessage ? Colors.white : Colors.grey[900],
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
          h3: TextStyle(
            color: isUserMessage ? Colors.white : Colors.grey[900],
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          code: TextStyle(
            backgroundColor: isUserMessage
                ? Colors.white.withValues(alpha: 0.2)
                : Colors.grey[100],
            color: isUserMessage
                ? Colors.white
                : Theme.of(context).colorScheme.primary,
            fontFamily: 'monospace',
          ),
          blockquote: TextStyle(
            color: isUserMessage
                ? Colors.white.withValues(alpha: 0.8)
                : Colors.grey[600],
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }

  Widget _buildStreamingIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(width: 8),
        AnimatedTextKit(
          animatedTexts: [
            TypewriterAnimatedText(
              'Thinking...',
              textStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
              speed: const Duration(
                milliseconds: 80,
              ), // Faster typing animation
            ),
          ],
          repeatForever: true,
          displayFullTextOnTap: false,
          pause: const Duration(
            milliseconds: 200,
          ), // Shorter pause between repetitions
        ),
      ],
    );
  }

  void _handleMenuSelection(String value) {
    switch (value) {
      case 'practice':
        ref
            .read(chatProvider.notifier)
            .sendQuickMessage('Start a practice session with my vocabulary');
        break;
      case 'help':
        ref
            .read(chatProvider.notifier)
            .sendQuickMessage('How can you help me learn vocabulary?');
        break;
    }
  }

  String _formatTime(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}

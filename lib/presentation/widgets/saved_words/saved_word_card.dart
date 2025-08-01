import 'package:flutter/material.dart';
import '../../../domain/entities/saved_word.dart';

class SavedWordCard extends StatelessWidget {
  final SavedWord word;
  final Function(SavedWord) onSpeak;
  final Function(String) onToggleFavorite;
  final Function(String) onDelete;
  final Function(SavedWord) onDiscuss;

  const SavedWordCard({
    super.key,
    required this.word,
    required this.onSpeak,
    required this.onToggleFavorite,
    required this.onDelete,
    required this.onDiscuss,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showWordDetails(context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          word.word.toUpperCase(),
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          word.definition,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      IconButton(
                        onPressed: () => onToggleFavorite(word.id),
                        icon: Icon(
                          word.isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: word.isFavorite ? Colors.red : Colors.grey,
                        ),
                      ),
                      IconButton(
                        onPressed: () => onSpeak(word),
                        icon: Icon(
                          Icons.volume_up,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildInfoChip(
                    context,
                    Icons.trending_up,
                    '${(word.confidence * 100).toInt()}%',
                    Colors.green,
                  ),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    context,
                    Icons.school,
                    '${word.practiceCount}x',
                    Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    context,
                    Icons.access_time,
                    _formatDate(word.detectedAt),
                    Colors.orange,
                  ),
                  const Spacer(),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'discuss':
                          onDiscuss(word);
                          break;
                        case 'delete':
                          onDelete(word.id);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'discuss',
                        child: Row(
                          children: [
                            Icon(Icons.chat),
                            SizedBox(width: 8),
                            Text('Discuss with AI'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return '${date.month}/${date.day}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  void _showWordDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _WordDetailsBottomSheet(
        word: word,
        onSpeak: onSpeak,
        onToggleFavorite: onToggleFavorite,
        onDiscuss: onDiscuss,
      ),
    );
  }
}

class _WordDetailsBottomSheet extends StatelessWidget {
  final SavedWord word;
  final Function(SavedWord) onSpeak;
  final Function(String) onToggleFavorite;
  final Function(SavedWord) onDiscuss;

  const _WordDetailsBottomSheet({
    required this.word,
    required this.onSpeak,
    required this.onToggleFavorite,
    required this.onDiscuss,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    word.word.toUpperCase(),
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => onToggleFavorite(word.id),
                  icon: Icon(
                    word.isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: word.isFavorite ? Colors.red : Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Definition',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              word.definition,
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                _buildStatItem(
                  context,
                  'Confidence',
                  '${(word.confidence * 100).toInt()}%',
                  Icons.trending_up,
                  Colors.green,
                ),
                const SizedBox(width: 24),
                _buildStatItem(
                  context,
                  'Practice Count',
                  '${word.practiceCount}',
                  Icons.school,
                  Colors.blue,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Detected on ${_formatFullDate(word.detectedAt)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            if (word.lastPracticed != null) ...[
              const SizedBox(height: 4),
              Text(
                'Last practiced on ${_formatFullDate(word.lastPracticed!)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => onSpeak(word),
                    icon: const Icon(Icons.volume_up),
                    label: const Text('Pronounce'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onDiscuss(word);
                    },
                    icon: const Icon(Icons.chat),
                    label: const Text('Discuss'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, IconData icon, Color color) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  String _formatFullDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/leaderboard_entry.dart';
import '../services/leaderboard_service.dart';
import '../utils/constants.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, List<LeaderboardEntry>> _leaderboards = {};
  bool _isLoading = true;
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadLeaderboards();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadLeaderboards() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final leaderboards = await LeaderboardService.getAllLeaderboards();
      setState(() {
        _leaderboards = leaderboards;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Leaderboards'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.text,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              child: Text(
                'Daily\nChallenge',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              ),
            ),
            Tab(
              child: Text(
                'Time\nAttack',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              ),
            ),
            Tab(
              child: Text(
                'Endless\n(1 Life)',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              ),
            ),
            Tab(
              child: Text(
                'Endless\n(3 Lives)',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              ),
            ),
          ],
          labelColor: AppColors.highlight1,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.highlight1,
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: GameConstants.maxContentWidth,
          ),
          child:
              _isLoading
                  ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                  : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildLeaderboardTab('daily'),
                      _buildLeaderboardTab('timeAttack'),
                      _buildLeaderboardTab('endless_1_life'),
                      _buildLeaderboardTab('endless_3_lives'),
                    ],
                  ),
        ),
      ),
    );
  }

  Widget _buildLeaderboardTab(String leaderboardKey) {
    final entries = _leaderboards[leaderboardKey] ?? [];
    final displayName = _getDisplayName(leaderboardKey);

    if (entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.leaderboard_outlined,
              size: 64,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: GameConstants.spacingLg),
            Text(
              'No scores yet',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: AppColors.textMuted),
            ),
            const SizedBox(height: GameConstants.spacingSm),
            Text(
              'Be the first to set a record!',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadLeaderboards,
      child: ListView.builder(
        padding: const EdgeInsets.all(GameConstants.spacingLg),
        itemCount: entries.length,
        itemBuilder: (context, index) {
          final entry = entries[index];
          final isCurrentUser = user?.uid != null && entry.userId == user!.uid;
          final rank = index + 1;

          return Container(
            margin: const EdgeInsets.only(bottom: GameConstants.spacingMd),
            decoration: BoxDecoration(
              color:
                  isCurrentUser
                      ? AppColors.highlight1.withOpacity(0.1)
                      : AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color:
                    isCurrentUser
                        ? AppColors.highlight1.withOpacity(0.3)
                        : AppColors.textMuted.withOpacity(0.1),
                width: isCurrentUser ? 2 : 1,
              ),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: GameConstants.spacingLg,
                vertical: GameConstants.spacingMd,
              ),
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getRankColor(rank),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    rank.toString(),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      entry.username,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color:
                            isCurrentUser
                                ? AppColors.highlight1
                                : AppColors.text,
                      ),
                    ),
                  ),
                  if (isCurrentUser)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: GameConstants.spacingSm,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.highlight1,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'YOU',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: GameConstants.spacingSm),
                  Row(
                    children: [
                      Icon(
                        Icons.star_rounded,
                        size: 16,
                        color: AppColors.highlight1,
                      ),
                      const SizedBox(width: GameConstants.spacingSm),
                      Text(
                        '${entry.score} ${_getScoreLabel(leaderboardKey)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (entry.timeInSeconds != null) ...[
                        const SizedBox(width: GameConstants.spacingLg),
                        Icon(
                          Icons.timer_outlined,
                          size: 16,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(width: GameConstants.spacingSm),
                        Text(
                          _formatTime(entry.timeInSeconds!),
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.textMuted),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              trailing: Text(
                _formatTimestamp(entry.timestamp),
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
              ),
            ),
          );
        },
      ),
    );
  }

  String _getDisplayName(String leaderboardKey) {
    switch (leaderboardKey) {
      case 'daily':
        return 'Daily Challenge';
      case 'timeAttack':
        return 'Time Attack';
      case 'endless_1_life':
        return 'Endless (1 Life)';
      case 'endless_3_lives':
        return 'Endless (3 Lives)';
      default:
        return leaderboardKey;
    }
  }

  String _getScoreLabel(String leaderboardKey) {
    switch (leaderboardKey) {
      case 'daily':
        return 'correct';
      case 'timeAttack':
        return 'words';
      case 'endless_1_life':
      case 'endless_3_lives':
        return 'words';
      default:
        return 'points';
    }
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700); // Gold
      case 2:
        return const Color(0xFFC0C0C0); // Silver
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return AppColors.highlight1;
    }
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

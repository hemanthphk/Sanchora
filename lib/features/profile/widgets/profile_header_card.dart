import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sanchora/features/profile/services/profile_service.dart';

class ProfileHeaderCard extends StatelessWidget {
  const ProfileHeaderCard({
    super.key,
    this.onTap,
  });

  final VoidCallback? onTap;

  String _formatJoinedDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return 'Joined • ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = isDark ? theme.colorScheme.outlineVariant.withValues(alpha: 0.15) : const Color(0xFFE8E8E8);

    return ValueListenableBuilder(
      valueListenable: ProfileService.currentUserNotifier,
      builder: (context, user, _) {
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderColor, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: theme.shadowColor.withValues(alpha: isDark ? 0.15 : 0.04),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Avatar
                  ValueListenableBuilder<String?>(
                    valueListenable: ProfileService.avatarPathNotifier,
                    builder: (context, avatarPath, _) {
                      if (avatarPath != null) {
                        if (File(avatarPath).existsSync()) {
                          return Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x240A84FF),
                                  blurRadius: 14,
                                  offset: Offset(0, 6),
                                ),
                              ],
                              image: DecorationImage(
                                image: FileImage(File(avatarPath)),
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        } else {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            ProfileService.removeAvatar();
                          });
                        }
                      }
                      
                      // Fallback initials
                      final initials = user.name.isNotEmpty 
                          ? user.name.trim().split(' ').take(2).map((e) => e.isNotEmpty ? e[0] : '').join('').toUpperCase()
                          : 'U';
                      
                      return Container(
                        width: 64,
                        height: 64,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF0A84FF), Color(0xFF4DA3FF)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x240A84FF),
                              blurRadius: 14,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          initials,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 16),
                  // Profile info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                user.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onSurface,
                                  letterSpacing: -0.3,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 14,
                              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatJoinedDate(user.createdAt),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    );
  }
}

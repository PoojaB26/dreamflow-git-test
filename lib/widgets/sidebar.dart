import 'package:flutter/material.dart';
import 'package:forui/forui.dart' hide FSidebar, FSidebarGroup, FSidebarItem;
import '../theme/sidebar_style.dart' as sidebar_style;
import 'package:dash/services/navigation_service.dart';
import 'package:dash/services/user_service.dart';
import 'patched_sidebar.dart';

/// Navigation sidebar with hierarchical menu structure.
/// Applies custom sidebar styling via `sidebar_style.dart` on top of Forui base.
class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return PatchedFSidebar(
      style: sidebar_style.sidebarStyle(
        colors: context.theme.colors,
        typography: context.theme.typography,
        style: context.theme.style,
      )(context.theme),
      header: _buildHeader(context),
      footer: _buildFooter(context),
      children: [
        // Main Navigation
        PatchedFSidebarGroup(
          children: NavigationService.getMainNavigation().map((item) {
            final hasChildren = item.children != null;
            if (hasChildren) {
              return PatchedFSidebarItem(
                icon: Icon(item.icon),
                label: Text(item.title),
                selected: item.isActive,
                initiallyExpanded: item.isActive,
                children: item.children!
                    .map(
                      (child) => PatchedFSidebarItem(
                        label: Text(child.title),
                        onPress: () {
                          // TODO: Navigate to ${child.url}
                        },
                      ),
                    )
                    .toList(),
                onPress: () {
                  // TODO: Navigate to ${item.url}
                },
              );
            } else {
              return PatchedFSidebarItem(
                icon: Icon(item.icon),
                label: Text(item.title),
                selected: item.isActive,
                onPress: () {
                  // TODO: Navigate to ${item.url}
                },
              );
            }
          }).toList(),
        ),

        // Documents Section
        PatchedFSidebarGroup(
          label: const Text('Documents'),
          children: NavigationService.getDocuments()
              .map(
                (item) => PatchedFSidebarItem(
                  icon: Icon(item.icon),
                  label: Text(item.name),
                  onPress: () {
                    // TODO: Navigate to ${item.url}
                  },
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 12, bottom: 12, top: 16),
      child: Row(
        spacing: 10,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: context.theme.colors.primary,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(
              FIcons.zap,
              color: context.theme.colors.background,
              size: 12,
            ),
          ),
          Text(
            'Acme Inc.',
            style: context.theme.typography.sm.copyWith(
              fontWeight: FontWeight.bold,
              color: context.theme.colors.foreground,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Column(
      children: [
        // Secondary Navigation (Settings, Help, etc.)
        PatchedFSidebarGroup(
          children: NavigationService.getSecondaryNavigation()
              .map(
                (item) => PatchedFSidebarItem(
                  icon: Icon(item.icon),
                  label: Text(item.title),
                  onPress: () {
                    // TODO: Navigate to ${item.url}
                  },
                ),
              )
              .toList(),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: FCard.raw(
            style: FCardStyle(
              decoration: BoxDecoration(),
              contentStyle: FCardContentStyle(
                titleTextStyle: context.theme.typography.sm.copyWith(
                  fontWeight: FontWeight.w500,
                  color: context.theme.colors.mutedForeground,
                ),
                subtitleTextStyle: context.theme.typography.sm.copyWith(
                  fontWeight: FontWeight.w500,
                  color: context.theme.colors.mutedForeground,
                ),
              ),
            ).call,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
              child: Row(
                spacing: 10,
                children: [
                  FAvatar(
                    image: NetworkImage(UserService.getCurrentUser().avatar),
                    size: 36,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 2,
                      children: [
                        Text(
                          UserService.getCurrentUser().name,
                          style: context.theme.typography.sm.copyWith(
                            fontWeight: FontWeight.bold,
                            color: context.theme.colors.foreground,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          UserService.getCurrentUser().email,
                          style: context.theme.typography.xs.copyWith(
                            color: context.theme.colors.mutedForeground,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    FIcons.ellipsis,
                    size: 16,
                    color: context.theme.colors.mutedForeground,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

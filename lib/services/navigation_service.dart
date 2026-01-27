import 'package:forui/forui.dart';
import 'package:dash/models/navigation_item.dart';
import 'package:dash/models/document_item.dart';

/// Service for managing navigation data and operations.
///
/// Provides navigation hierarchy and document links for the dashboard sidebar.
/// Currently uses sample data for demonstration purposes.
class NavigationService {
  
  /// Get primary navigation items
  static List<NavigationItem> getMainNavigation() {
    return [
      NavigationItem(
        title: 'Dashboard',
        icon: FIcons.layoutDashboard,
        url: '#',
        isActive: true,
      ),
      NavigationItem(
        title: 'Lifecycle',
        icon: FIcons.heart,
        url: '#',
      ),
      NavigationItem(
        title: 'Analytics',
        icon: FIcons.chartBar,
        url: '#',
      ),
      NavigationItem(
        title: 'Projects',
        icon: FIcons.folder,
        url: '#',
        children: [
          NavigationItem(
            title: 'Active Projects',
            icon: FIcons.circle,
            url: '#/projects/active',
          ),
          NavigationItem(
            title: 'Templates',
            icon: FIcons.circle,
            url: '#/projects/templates',
          ),
          NavigationItem(
            title: 'Archived',
            icon: FIcons.circle,
            url: '#/projects/archived',
          ),
        ],
      ),
      NavigationItem(
        title: 'Team',
        icon: FIcons.users,
        url: '#',
      ),
    ];
  }

  /// Get secondary navigation items
  static List<NavigationItem> getSecondaryNavigation() {
    return [
      NavigationItem(
        title: 'Settings',
        icon: FIcons.settings,
        url: '#',
      ),
      NavigationItem(
        title: 'Get Help',
        icon: FIcons.info,
        url: '#',
      ),
      NavigationItem(
        title: 'Search',
        icon: FIcons.search,
        url: '#',
      ),
    ];
  }

  /// Get document items
  static List<DocumentItem> getDocuments() {
    return [
      DocumentItem(
        name: 'Data Library',
        icon: FIcons.database,
        url: '#',
      ),
      DocumentItem(
        name: 'Reports',
        icon: FIcons.fileText,
        url: '#',
      ),
      DocumentItem(
        name: 'Word Assistant',
        icon: FIcons.messageSquare,
        url: '#',
      ),
    ];
  }
}
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:provider/provider.dart';
import '../widgets/sidebar.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/metric_card.dart';
import '../widgets/chart_card.dart';
import '../widgets/simple_progress_card.dart';
import '../widgets/simple_performers_list.dart';
import '../widgets/simple_activity_feed.dart';
import '../core/constants.dart';
import '../theme/theme_provider.dart';
import 'package:dash/models/chart_data_set.dart';
import 'package:dash/services/chart_service.dart';

/// Main dashboard layout with responsive grid system.
///
/// Coordinates the overall dashboard layout with sidebar navigation,
/// header controls, and adaptive content grid for different screen sizes.
///
/// **Layout Structure:**
/// ```
/// [Sidebar] | [Header            ]
///          | [Metrics Grid      ]
///          | [Chart Card        ]
///          | [Progress Cards    ]
///          | [Lists & Activity  ]
/// ```
///
/// **Responsive Breakpoints:**
/// - **Mobile** (< md): Drawer sidebar, 1-column metrics
/// - **Tablet** (md-lg): Collapsible sidebar, 2-column metrics
/// - **Desktop** (lg+): Fixed sidebar, 4-column metrics
///
/// **Data Sources:**
/// - All displayed data is currently mock/hardcoded sample data
/// - Chart data generated via `_generateChartDatasets()` with 3 months of sample points
/// - Metric cards use static demo values
/// - Replace these with real API calls for production use
///
/// **State Management:**
/// - Uses `ThemeProvider` for theme switching
/// - Local state for sidebar collapse animation
/// - No external data state - currently demonstration only
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with TickerProviderStateMixin {
  bool _isSidebarCollapsed = false;
  late AnimationController _sidebarAnimationController;
  late Animation<double> _sidebarAnimation;

  @override
  void initState() {
    super.initState();
    _sidebarAnimationController = AnimationController(
      duration: DashboardConstants.sidebarAnimationDuration,
      vsync: this,
    );
    _sidebarAnimation = CurvedAnimation(
      parent: _sidebarAnimationController,
      curve: Curves.easeInOut,
    );

    // Start with sidebar open
    _sidebarAnimationController.forward();
  }

  @override
  void dispose() {
    _sidebarAnimationController.dispose();
    super.dispose();
  }

  void _toggleSidebar() {
    setState(() {
      _isSidebarCollapsed = !_isSidebarCollapsed;
    });

    if (_isSidebarCollapsed) {
      _sidebarAnimationController.reverse();
    } else {
      _sidebarAnimationController.forward();
    }
  }

  Map<String, ChartDataSet> _generateChartDatasets() {
    return ChartService.generateChartDatasets();
  }


  @override
  Widget build(BuildContext context) {
    final isMobile =
        context.theme.breakpoints.md > MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: context.theme.colors.primaryForeground,
      drawer: isMobile
          ? Container(
              color: context.theme.colors.background,
              child: Sidebar(),
            )
          : null,
      body: Row(
        children: [
          // Desktop sidebar (hidden on mobile)
          if (!isMobile)
            AnimatedBuilder(
              animation: _sidebarAnimation,
              builder: (context, child) {
                return ClipRect(
                  child: SizeTransition(
                    sizeFactor: _sidebarAnimation,
                    axis: Axis.horizontal,
                    axisAlignment: -1,
                    child: const Sidebar(),
                  ),
                );
              },
            ),

          // Main content area
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: context.theme.colors.background,
                          borderRadius: BorderRadius.circular(
                            DashboardConstants.containerBorderRadius,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: context.theme.colors.primary.withValues(
                                alpha: 0.13,
                              ),
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Header inside the container
                            DashboardHeader(
                              pageTitle: 'Dashboard',
                              onSidebarToggle: isMobile ? null : _toggleSidebar,
                              sidebarAnimation: isMobile
                                  ? null
                                  : _sidebarAnimation,
                              onThemeToggle: () => context
                                  .read<ThemeProvider>()
                                  .toggleThemeMode(),
                              themeMode: context
                                  .watch<ThemeProvider>()
                                  .themeMode,
                            ),

                            // Content area
                            Padding(
                              padding: const EdgeInsets.all(
                                DashboardConstants.contentPadding,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Metrics grid
                                  GridView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount:
                                              context.theme.breakpoints.xl2 <=
                                                  MediaQuery.of(
                                                    context,
                                                  ).size.width
                                              ? 4
                                              : context.theme.breakpoints.xl <=
                                                    MediaQuery.of(
                                                      context,
                                                    ).size.width
                                              ? 2
                                              : context.theme.breakpoints.lg <=
                                                    MediaQuery.of(
                                                      context,
                                                    ).size.width
                                              ? 2
                                              : context.theme.breakpoints.md <=
                                                    MediaQuery.of(
                                                      context,
                                                    ).size.width
                                              ? 1
                                              : context.theme.breakpoints.sm <=
                                                    MediaQuery.of(
                                                      context,
                                                    ).size.width
                                              ? 2
                                              : 1,
                                          crossAxisSpacing: 16,
                                          mainAxisSpacing: 16,
                                          mainAxisExtent:
                                              192, // Fixed height for all cards
                                        ),
                                    itemCount: 4,
                                    itemBuilder: (context, index) {
                                      // MOCK DATA: Sample metric cards with hardcoded values
                                      // Replace with real KPI data from your API
                                      final cards = [
                                        const MetricCard(
                                          title: 'Total Revenue',
                                          value: '\$1,250.00',
                                          percentage: '+12.5%',
                                          trend: 'Trending up this month',
                                          description:
                                              'Visitors for the last 6 months',
                                          isPositive: true,
                                        ),
                                        const MetricCard(
                                          title: 'Subscriptions',
                                          value: '+2,350',
                                          percentage: '+180.1%',
                                          trend: 'Trending up this month',
                                          description:
                                              'New subscriptions this period',
                                          isPositive: true,
                                        ),
                                        const MetricCard(
                                          title: 'Sales',
                                          value: '+12,234',
                                          percentage: '+19%',
                                          trend: 'Trending up this month',
                                          description: 'Sales from last month',
                                          isPositive: true,
                                        ),
                                        const MetricCard(
                                          title: 'Active Now',
                                          value: '+573',
                                          percentage: '+201%',
                                          trend: 'Trending up this month',
                                          description: 'Active users right now',
                                          isPositive: true,
                                        ),
                                      ];
                                      return cards[index];
                                    },
                                  ),

                                  const SizedBox(height: 24),

                                  // Chart section
                                  ChartCard(
                                    title: 'Total Visitors',
                                    subtitle: 'Total for the last 3 months',
                                    timePeriods: const [
                                      'Last 3 months',
                                      'Last 30 days',
                                      'Last 7 days',
                                    ],
                                    datasets: _generateChartDatasets(),
                                  ),

                                  const SizedBox(height: 24),

                                  // Progress cards
                                  GridView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount:
                                              context.theme.breakpoints.lg <=
                                                  MediaQuery.of(
                                                    context,
                                                  ).size.width
                                              ? 3
                                              : 1,
                                          crossAxisSpacing: 16,
                                          mainAxisSpacing: 16,
                                          mainAxisExtent: 150,
                                        ),
                                    itemCount: 3,
                                    itemBuilder: (context, index) {
                                      // MOCK DATA: Sample progress indicators
                                      // Replace with real progress tracking data
                                      final cards = [
                                        const SimpleProgressCard(
                                          title: 'Sales Goal',
                                          value: '\$45,231 / \$60,000',
                                          progress: 0.75,
                                          label: '75% Complete',
                                        ),
                                        const SimpleProgressCard(
                                          title: 'New Users',
                                          value: '1,284 / 2,000',
                                          progress: 0.64,
                                          label: '64% Complete',
                                        ),
                                        const SimpleProgressCard(
                                          title: 'Satisfaction',
                                          value: '4.6 / 5.0',
                                          progress: 0.92,
                                          label: '92% Complete',
                                        ),
                                      ];
                                      return cards[index];
                                    },
                                  ),

                                  const SizedBox(height: 24),

                                  // Bottom section - responsive layout
                                  LayoutBuilder(
                                    builder: (context, constraints) {
                                      final isLargeScreen =
                                          context.theme.breakpoints.lg <=
                                          MediaQuery.of(context).size.width;

                                      if (isLargeScreen) {
                                        // Large screens: Side by side
                                        return Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child:
                                                  const SimplePerformersList(),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: const SimpleActivityFeed(),
                                            ),
                                          ],
                                        );
                                      } else {
                                        // Smaller screens: Vertical (stacked)
                                        return Column(
                                          children: [
                                            const SimplePerformersList(),
                                            const SizedBox(height: 16),
                                            const SimpleActivityFeed(),
                                          ],
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

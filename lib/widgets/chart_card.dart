import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:dash/models/chart_data_set.dart';

/// Interactive line chart widget with time period switching.
enum ChartType { line, bar }

class ChartCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final List<String> timePeriods;
  final Map<String, ChartDataSet> datasets;

  const ChartCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.timePeriods,
    required this.datasets,
  });

  @override
  State<ChartCard> createState() => _ChartCardState();
}

class _ChartCardState extends State<ChartCard> {
  int _selectedIndex = 0;
  ChartType _chartType = ChartType.line;

  ChartDataSet get _currentDataSet {
    final periodKey = widget.timePeriods[_selectedIndex];
    return widget.datasets[periodKey] ?? widget.datasets.values.first;
  }

  double _getMaxValue() {
    final currentData = _currentDataSet;
    final primaryMax = currentData.primaryData
        .map((e) => e.value)
        .reduce((a, b) => a > b ? a : b);
    final secondaryMax = currentData.secondaryData
        .map((e) => e.value)
        .reduce((a, b) => a > b ? a : b);
    return primaryMax > secondaryMax ? primaryMax : secondaryMax;
  }

  @override
  Widget build(BuildContext context) {
    return FCard.raw(
      style: FCardStyle(
        decoration: BoxDecoration(
          color: context.theme.colors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: context.theme.colors.border,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: context.theme.colors.foreground.withValues(alpha: 0.12),
              blurRadius: 1,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        contentStyle: FCardContentStyle(
          padding: const EdgeInsets.all(24),
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
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title and controls (fully responsive)
            LayoutBuilder(
              builder: (context, constraints) {
                final screenWidth = MediaQuery.of(context).size.width;
                final isNarrowHeader = constraints.maxWidth < 520; // stack controls under title
                final isLargeScreen = context.theme.breakpoints.lg <= screenWidth;

                Widget titleBlock = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                      style: context.theme.typography.lg.copyWith(
                        fontWeight: FontWeight.w600,
                        color: context.theme.colors.foreground,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.subtitle,
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                      style: context.theme.typography.sm.copyWith(
                        color: context.theme.colors.mutedForeground,
                      ),
                    ),
                  ],
                );

                Widget largeControls() => Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: context.theme.colors.muted,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: widget.timePeriods.asMap().entries.map((entry) {
                              final index = entry.key;
                              final period = entry.value;
                              final isSelected = index == _selectedIndex;
                              return GestureDetector(
                                onTap: () => setState(() => _selectedIndex = index),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isSelected ? context.theme.colors.background : Colors.transparent,
                                    borderRadius: BorderRadius.circular(6),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: context.theme.colors.foreground.withValues(alpha: 0.1),
                                              blurRadius: 2,
                                              offset: const Offset(0, 1),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Text(
                                    period,
                                    style: context.theme.typography.sm.copyWith(
                                      fontWeight: FontWeight.w500,
                                      color: isSelected
                                          ? context.theme.colors.foreground
                                          : context.theme.colors.mutedForeground,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ChartTypeToggle(
                          value: _chartType,
                          onChanged: (value) => setState(() => _chartType = value),
                        ),
                      ],
                    );

                Widget compactControls() => Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 160,
                          child: FSelect<String>(
                            format: (value) => value,
                            initialValue: widget.timePeriods[_selectedIndex],
                            onChange: (value) {
                              if (value != null) {
                                final index = widget.timePeriods.indexOf(value);
                                if (index != -1) setState(() => _selectedIndex = index);
                              }
                            },
                            children: widget.timePeriods.map((period) => FSelectItem(period, period)).toList(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ChartTypeToggle(
                          value: _chartType,
                          onChanged: (value) => setState(() => _chartType = value),
                        ),
                      ],
                    );

                if (isNarrowHeader) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      titleBlock,
                      const SizedBox(height: 12),
                      compactControls(),
                    ],
                  );
                }

                // Wide header: keep title on the left and controls on the right
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: titleBlock),
                    isLargeScreen ? largeControls() : compactControls(),
                  ],
                );
              },
            ),

            const SizedBox(height: 32),

            // Chart area using fl_chart
            SizedBox(
              height: 200,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                child: _chartType == ChartType.line
                    ? LineChart(
                        key: const ValueKey('line'),
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                        LineChartData(
                  lineTouchData: LineTouchData(
                    enabled: true,
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (touchedSpot) =>
                          context.theme.colors.background,
                      tooltipBorder: BorderSide(
                        color: context.theme.colors.border,
                        width: 1,
                      ),
                      tooltipRoundedRadius: 6,
                      tooltipPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      tooltipMargin: 8,
                      maxContentWidth: 120,
                      getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                        return touchedBarSpots.asMap().entries.map((entry) {
                          final index = entry.key;
                          final barSpot = entry.value;
                          final dataIndex = barSpot.x.toInt();
                          final currentData = _currentDataSet;

                          // Only show tooltip for the first line (primary data)
                          // to avoid duplicates, but return null for secondary
                          if (index == 0 &&
                              dataIndex >= 0 &&
                              dataIndex < currentData.primaryData.length) {
                            final date =
                                currentData.primaryData[dataIndex].label;
                            final mobileValue = currentData
                                .primaryData[dataIndex]
                                .value
                                .toInt();
                            final desktopValue = currentData
                                .secondaryData[dataIndex]
                                .value
                                .toInt();

                            return LineTooltipItem(
                              textAlign: TextAlign.left,
                              '$date\n\n',
                              context.theme.typography.xs.copyWith(
                                fontWeight: FontWeight.w600,
                                color: context.theme.colors.foreground,
                              ),
                              children: [
                                TextSpan(
                                  text: '■ ',
                                  style: context.theme.typography.xs.copyWith(
                                    color: context.theme.colors.primary,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 11,
                                    height: 1.5,
                                  ),
                                ),
                                TextSpan(
                                  text: 'Mobile      ',
                                  style: context.theme.typography.xs.copyWith(
                                    color: context.theme.colors.foreground,
                                    fontWeight: FontWeight.w500,
                                    height: 1.5,
                                  ),
                                ),
                                TextSpan(
                                  text: '$mobileValue\n',
                                  style: context.theme.typography.xs.copyWith(
                                    color: context.theme.colors.foreground,
                                    fontWeight: FontWeight.w700,
                                    height: 1.5,
                                  ),
                                ),
                                TextSpan(
                                  text: '■ ',
                                  style: context.theme.typography.xs.copyWith(
                                    color: context.theme.colors.mutedForeground,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 11,
                                    height: 1.5,
                                  ),
                                ),
                                TextSpan(
                                  text: 'Desktop   ',
                                  style: context.theme.typography.xs.copyWith(
                                    color: context.theme.colors.foreground,
                                    fontWeight: FontWeight.w500,
                                    height: 1.5,
                                  ),
                                ),
                                TextSpan(
                                  text: '$desktopValue',
                                  style: context.theme.typography.xs.copyWith(
                                    color: context.theme.colors.foreground,
                                    fontWeight: FontWeight.w700,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            );
                          }
                          // Return null for other lines to hide their individual tooltips
                          return null;
                        }).toList();
                      },
                    ),
                  ),
                  gridData: FlGridData(
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: context.theme.colors.border.withValues(
                          alpha: 0.3,
                        ),
                        strokeWidth: 1,
                      );
                    },
                    drawVerticalLine: false,
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: (_currentDataSet.primaryData.length / 10)
                            .ceilToDouble(),
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          final currentData = _currentDataSet;
                          final dataLength = currentData.primaryData.length;

                          // Skip first and last labels to prevent overflow
                          if (index <= 0 || index >= dataLength - 1) {
                            return const SizedBox.shrink();
                          }

                          if (index < dataLength) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                currentData.primaryData[index].label,
                                style: context.theme.typography.xs.copyWith(
                                  color: context.theme.colors.mutedForeground,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    // Secondary line (mobile - behind primary)
                    LineChartBarData(
                      spots: _currentDataSet.secondaryData
                          .asMap()
                          .entries
                          .map(
                            (entry) => FlSpot(
                              entry.key.toDouble(),
                              entry.value.value,
                            ),
                          )
                          .toList(),
                      isCurved: true,
                      color: context.theme.colors.mutedForeground,
                      barWidth: 2,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            context.theme.colors.mutedForeground.withValues(
                              alpha: 0.3,
                            ),
                            context.theme.colors.mutedForeground.withValues(
                              alpha: 0.1,
                            ),
                            context.theme.colors.mutedForeground.withValues(
                              alpha: 0.05,
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Primary line (desktop - on top)
                    LineChartBarData(
                      spots: _currentDataSet.primaryData
                          .asMap()
                          .entries
                          .map(
                            (entry) => FlSpot(
                              entry.key.toDouble(),
                              entry.value.value,
                            ),
                          )
                          .toList(),
                      isCurved: true,
                      color: context.theme.colors.primary,
                      barWidth: 2,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            context.theme.colors.primary.withValues(alpha: 0.4),
                            context.theme.colors.primary.withValues(alpha: 0.2),
                            context.theme.colors.primary.withValues(alpha: 0.1),
                          ],
                        ),
                      ),
                    ),
                  ],
                          minY: 50,
                          maxY: _getMaxValue(),
                        ),
                      )
                    : BarChart(
                        key: const ValueKey('bar'),
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                        BarChartData(
                          barTouchData: BarTouchData(enabled: true),
                          gridData: FlGridData(
                            getDrawingHorizontalLine: (value) => FlLine(
                              color: context.theme.colors.border.withValues(alpha: 0.3),
                              strokeWidth: 1,
                            ),
                            drawVerticalLine: false,
                          ),
                          borderData: FlBorderData(show: false),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 30,
                                interval: (_currentDataSet.primaryData.length / 10).ceilToDouble(),
                                getTitlesWidget: (value, meta) {
                                  final index = value.toInt();
                                  final currentData = _currentDataSet;
                                  final dataLength = currentData.primaryData.length;
                                  if (index <= 0 || index >= dataLength - 1) {
                                    return const SizedBox.shrink();
                                  }
                                  if (index < dataLength) {
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(
                                        currentData.primaryData[index].label,
                                        style: context.theme.typography.xs.copyWith(
                                          color: context.theme.colors.mutedForeground,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),
                            ),
                          ),
                          groupsSpace: 8,
                          barGroups: _buildBarGroups(context),
                          minY: 50,
                          maxY: _getMaxValue(),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups(BuildContext context) {
    final current = _currentDataSet;
    final length = current.primaryData.length;
    return List.generate(length, (index) {
      final primary = current.primaryData[index].value;
      final secondary = current.secondaryData[index].value;
      return BarChartGroupData(
        x: index,
        barsSpace: 4,
        barRods: [
          BarChartRodData(
            toY: primary,
            color: context.theme.colors.primary,
            width: 6,
            borderRadius: BorderRadius.circular(3),
          ),
          BarChartRodData(
            toY: secondary,
            color: context.theme.colors.mutedForeground,
            width: 6,
            borderRadius: BorderRadius.circular(3),
          ),
        ],
      );
    });
  }
}

/// Small, theme-aware toggle to switch between line and bar charts.
class ChartTypeToggle extends StatelessWidget {
  final ChartType value;
  final ValueChanged<ChartType> onChanged;

  const ChartTypeToggle({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: context.theme.colors.muted,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ToggleIcon(
            icon: Icons.show_chart,
            label: 'Line',
            selected: value == ChartType.line,
            onTap: () => onChanged(ChartType.line),
          ),
          _ToggleIcon(
            icon: Icons.bar_chart,
            label: 'Bar',
            selected: value == ChartType.bar,
            onTap: () => onChanged(ChartType.bar),
          ),
        ],
      ),
    );
  }
}

class _ToggleIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ToggleIcon({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fg = selected ? context.theme.colors.foreground : context.theme.colors.mutedForeground;
    final bg = selected ? context.theme.colors.background : Colors.transparent;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(6),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: context.theme.colors.foreground.withValues(alpha: 0.08),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: fg),
            const SizedBox(width: 6),
            Text(
              label,
              style: context.theme.typography.sm.copyWith(
                color: fg,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../utils/colors.dart';
import '../../../utils/styles.dart';
import 'product_report_screen.dart';

/// Report Card Metadata
class ReportCardInfo {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;

  const ReportCardInfo({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.onTap,
  });
}

/// Screen matching Figma "Reports" screen with pixel-exact cards
class ReportsListScreen extends StatelessWidget {
  static const String routeName = '/reports-list';

  const ReportsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final reports = [
      ReportCardInfo(
        title: 'Product Report',
        subtitle: 'Production metrics, pieces and weights',
        icon: Icons.bar_chart_rounded,
        onTap: () {
          Navigator.pushNamed(context, ProductReportScreen.routeName);
        },
      ),
      ReportCardInfo(
        title: 'Worker Report',
        subtitle: 'Craftsman daily output and efficiency',
        icon: Icons.group_outlined,
        onTap: () {
          Navigator.pushNamed(context, ProductReportScreen.routeName);
        },
      ),
      ReportCardInfo(
        title: 'Machine Report',
        subtitle: 'Machine uptime and allocations',
        icon: Icons.precision_manufacturing_outlined,
        onTap: () {
          Navigator.pushNamed(context, ProductReportScreen.routeName);
        },
      ),
      ReportCardInfo(
        title: 'Reject Report',
        subtitle: 'Defects and scrap analysis',
        icon: Icons.warning_amber_rounded,
        onTap: () {
          Navigator.pushNamed(context, ProductReportScreen.routeName);
        },
      ),
      ReportCardInfo(
        title: 'Product Report',
        subtitle: 'Department-wise product distributions',
        icon: Icons.bar_chart_rounded,
        onTap: () {
          Navigator.pushNamed(context, ProductReportScreen.routeName);
        },
      ),
      ReportCardInfo(
        title: 'Worker Report',
        subtitle: 'Individual shift hours and log history',
        icon: Icons.group_outlined,
        onTap: () {
          Navigator.pushNamed(context, ProductReportScreen.routeName);
        },
      ),
    ];

    return Scaffold(
      backgroundColor: FactoryColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.white,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: FactoryColors.textPrimary,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Reports',
          style: tsS17W700.copyWith(
            color: FactoryColors.textPrimary,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: FactoryColors.border,
          ),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        itemCount: reports.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final report = reports[index];
          return _buildReportCard(context, report);
        },
      ),
    );
  }

  Widget _buildReportCard(BuildContext context, ReportCardInfo report) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: FactoryColors.border),
        boxShadow: const [
          BoxShadow(
            color: FactoryColors.shadowColor,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: report.onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top row: Title + Subtitle on Left, Action Icon Box on Right
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            report.title,
                            style: tsS15W700.copyWith(
                              color: FactoryColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            report.subtitle,
                            style: tsS12W400.copyWith(
                              color: FactoryColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: FactoryColors.border),
                      ),
                      child: Icon(
                        report.icon,
                        size: 18,
                        color: FactoryColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Bottom Link: View Details >
                Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View Details',
                        style: tsS13W600.copyWith(
                          color: FactoryColors.primary,
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(
                        Icons.chevron_right_rounded,
                        size: 18,
                        color: FactoryColors.primary,
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
  }
}

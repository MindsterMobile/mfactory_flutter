import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../models/report_models.dart';
import '../../../repositories/report_repository.dart';
import '../../../utils/app_build_methods.dart';
import '../../../utils/colors.dart';
import '../../../utils/styles.dart';
import 'weekly_detail_report_screen.dart';

/// Screen displaying reports strictly from API, matching Figma design:
/// - List of report cards with Title, Date Range (DD/MM/YYYY - DD/MM/YYYY), Download button, and "View Details >".
class ReportsListScreen extends StatefulWidget {
  static const String routeName = '/reports-list';

  final ReportRepository? reportRepository;

  const ReportsListScreen({
    super.key,
    this.reportRepository,
  });

  @override
  State<ReportsListScreen> createState() => _ReportsListScreenState();
}

class _ReportsListScreenState extends State<ReportsListScreen> {
  late final ReportRepository _repository;
  late Future<List<WeeklyReportItem>> _weeklyReportsFuture;
  final Set<String> _downloadingReports = {};

  @override
  void initState() {
    super.initState();
    _repository = widget.reportRepository ?? ReportRepositoryImpl();
    _loadWeeklyReports();
  }

  void _loadWeeklyReports() {
    _weeklyReportsFuture = _repository.getWeeklyReports();
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _loadWeeklyReports();
    });
    try {
      await _weeklyReportsFuture;
    } catch (_) {}
  }

  Future<void> _downloadReport(WeeklyReportItem report) async {
    if (_downloadingReports.contains(report.reportName)) return;

    setState(() {
      _downloadingReports.add(report.reportName);
    });

    try {
      final res = await _repository.downloadDetailReport(
        fromDate: report.startDate,
        toDate: report.endDate,
      );

      if (res.fileUrl.isNotEmpty) {
        final uri = Uri.parse(res.fileUrl);
        final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (launched) {
          showToast('Downloading ${res.fileName ?? 'report.csv'}...');
        } else {
          showToast('Opened download link in browser');
        }
      } else {
        showToast('Download URL is not available');
      }
    } catch (e) {
      showToast('Error downloading report: $e');
    } finally {
      if (mounted) {
        setState(() {
          _downloadingReports.remove(report.reportName);
        });
      }
    }
  }

  void _openDetail(WeeklyReportItem report) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WeeklyDetailReportScreen(
          reportItem: report,
          reportRepository: _repository,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.white,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Color(0xFF1E293B),
            size: 22,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Reports',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B),
            fontFamily: 'OpenSans',
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: const Color(0xFFE2E8F0),
          ),
        ),
      ),
      body: RefreshIndicator(
        color: FactoryColors.primary,
        onRefresh: _handleRefresh,
        child: FutureBuilder<List<WeeklyReportItem>>(
          future: _weeklyReportsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(color: FactoryColors.primary),
                ),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: Color(0xFFFEE2E2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.error_outline_rounded,
                          size: 36,
                          color: FactoryColors.buttonRed,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Unable to load reports',
                        style: tsS16W600.copyWith(color: FactoryColors.textPrimary),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Please verify your connection or try again.',
                        textAlign: TextAlign.center,
                        style: tsS13W400.copyWith(color: FactoryColors.textSecondary),
                      ),
                      const SizedBox(height: 18),
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _loadWeeklyReports();
                          });
                        },
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: const Text('Try Again'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: FactoryColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            final items = snapshot.data ?? [];
            if (items.isEmpty) {
              return Center(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: const BoxDecoration(
                          color: FactoryColors.surfaceWarmBeige,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.calendar_today_rounded,
                          size: 40,
                          color: FactoryColors.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No Reports Available',
                        style: tsS16W600.copyWith(color: FactoryColors.textPrimary),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Weekly reports generated for your cluster will appear here.',
                        textAlign: TextAlign.center,
                        style: tsS13W400.copyWith(color: FactoryColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 14,
                bottom: MediaQuery.of(context).padding.bottom + 16,
              ),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = items[index];
                final isDownloadingThis =
                    _downloadingReports.contains(item.reportName);

                return _buildReportCard(item, isDownloadingThis);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildReportCard(WeeklyReportItem report, bool isDownloading) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top section: Title & Date Range on Left, Download Icon Box on Right
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 14, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        report.reportName.isNotEmpty
                            ? report.reportName
                            : 'Production Report',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E293B),
                          fontFamily: 'OpenSans',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        report.slashRange,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF64748B),
                          fontFamily: 'OpenSans',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: isDownloading ? null : () => _downloadReport(report),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Center(
                      child: isDownloading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF1E293B),
                              ),
                            )
                          : const Icon(
                              Icons.file_download_outlined,
                              size: 19,
                              color: Color(0xFF1E293B),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Thin Divider
          const Divider(
            height: 1,
            thickness: 1,
            color: Color(0xFFF1F5F9),
          ),

          // Bottom section: View Details >
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(10)),
              onTap: () => _openDetail(report),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: const [
                    Text(
                      'View Details',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF334155),
                        fontFamily: 'OpenSans',
                      ),
                    ),
                    SizedBox(width: 3),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 16,
                      color: Color(0xFF334155),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../models/report_models.dart';
import '../../../repositories/report_repository.dart';
import '../../../utils/app_build_methods.dart';
import '../../../utils/colors.dart';
import '../../../utils/styles.dart';
import '../../../utils/time_zone_helper.dart';

/// Screen displaying the detail report matching the Figma design:
/// - AppBar with title "Production Report" (or report name)
/// - Table Card with Tan Header: "Date", "Worker in Number", "Total Time Taken (mins)"
/// - Rows displaying the date, worker code/number, and total minutes taken
/// - Bottom Total row with bold sum of minutes
class WeeklyDetailReportScreen extends StatefulWidget {
  static const String routeName = '/weekly-detail-report';

  final WeeklyReportItem reportItem;
  final ReportRepository? reportRepository;

  const WeeklyDetailReportScreen({
    super.key,
    required this.reportItem,
    this.reportRepository,
  });

  @override
  State<WeeklyDetailReportScreen> createState() =>
      _WeeklyDetailReportScreenState();
}

class _WeeklyDetailReportScreenState extends State<WeeklyDetailReportScreen> {
  late final ReportRepository _repository;
  late Future<ClusterHeadDetailReportResponse> _reportFuture;
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    _repository = widget.reportRepository ?? ReportRepositoryImpl();
    _loadReport();
  }

  void _loadReport() {
    _reportFuture = _repository.getDetailReport(
      fromDate: widget.reportItem.startDate,
      toDate: widget.reportItem.endDate,
    );
  }

  Future<void> _downloadReport() async {
    if (_isDownloading) return;
    setState(() => _isDownloading = true);
    try {
      final res = await _repository.downloadDetailReport(
        fromDate: widget.reportItem.startDate,
        toDate: widget.reportItem.endDate,
      );
      if (res.fileUrl.isNotEmpty) {
        final uri = Uri.parse(res.fileUrl);
        final launched =
            await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (launched) {
          showToast('Downloading ${res.fileName ?? 'report.csv'}...');
        } else {
          showToast('Opened download link in browser');
        }
      } else {
        showToast('Download URL is empty');
      }
    } catch (e) {
      showToast('Error downloading report: $e');
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final titleText = widget.reportItem.reportName.isNotEmpty
        ? widget.reportItem.reportName
        : 'Production Report';

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
        title: Text(
          titleText,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B),
            fontFamily: 'OpenSans',
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Download CSV',
            icon: _isDownloading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF1E293B),
                    ),
                  )
                : const Icon(
                    Icons.file_download_outlined,
                    color: Color(0xFF1E293B),
                    size: 22,
                  ),
            onPressed: _isDownloading ? null : _downloadReport,
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: const Color(0xFFE2E8F0),
          ),
        ),
      ),
      body: FutureBuilder<ClusterHeadDetailReportResponse>(
        future: _reportFuture,
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
                    const Icon(
                      Icons.error_outline_rounded,
                      size: 44,
                      color: FactoryColors.buttonRed,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Failed to load report',
                      style:
                          tsS15W600.copyWith(color: FactoryColors.textPrimary),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      snapshot.error
                          .toString()
                          .replaceAll('Exception:', '')
                          .trim(),
                      textAlign: TextAlign.center,
                      style: tsS12W400.copyWith(color: FactoryColors.textMuted),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => setState(_loadReport),
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: const Text('Try Again'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: FactoryColors.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final report =
              snapshot.data ?? ClusterHeadDetailReportResponse.empty();
          final vouchers = report.vouchers;

          if (vouchers.isEmpty) {
            return Center(
              child: Padding(
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
                        Icons.table_chart_outlined,
                        size: 38,
                        color: FactoryColors.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No Records Found',
                      style:
                          tsS16W600.copyWith(color: FactoryColors.textPrimary),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'There are no production entries for this period.',
                      style: tsS13W400.copyWith(
                          color: FactoryColors.textSecondary),
                    ),
                  ],
                ),
              ),
            );
          }

          // Calculate total minutes across all entries
          final totalMinutes = vouchers.fold<int>(
            0,
            (sum, item) => sum + item.totalMinutes,
          );
          final totalEmployees = vouchers.fold<int>(
            0,
            (sum, item) => sum + item.totalEmployeesWorked,
          );
          final totalTimeText = report.totalTimeWorkedAllVouchers.isNotEmpty &&
                  report.totalTimeWorkedAllVouchers != '0' &&
                  report.totalTimeWorkedAllVouchers != '00:00:00'
              ? report.totalTimeWorkedAllVouchers
              : (totalMinutes > 0 ? '$totalMinutes mins' : '00:00:00');

          return SingleChildScrollView(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: MediaQuery.of(context).padding.bottom + 24,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x06000000),
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Tan / Beige Table Header
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF5ECE4),
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(9)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: const [
                        Expanded(
                          flex: 4,
                          child: Text(
                            'Voucher',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF475569),
                              fontFamily: 'OpenSans',
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            'No. of Workers',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF475569),
                              fontFamily: 'OpenSans',
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            'Time Taken',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF475569),
                              fontFamily: 'OpenSans',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Table Rows
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: vouchers.length,
                    separatorBuilder: (_, __) => const Divider(
                      height: 1,
                      thickness: 1,
                      color: Color(0xFFF1F5F9),
                    ),
                    itemBuilder: (context, index) {
                      final item = vouchers[index];
                      final voucherText = item.voucherName.isNotEmpty
                          ? item.voucherName
                          : (item.voucherId > 0
                              ? item.voucherId.toString()
                              : '-');
                      final workersText = '${item.totalEmployeesWorked}';
                      final timeTakenText = item.totalTimeWorked.isNotEmpty &&
                              item.totalTimeWorked != '0' &&
                              item.totalTimeWorked != '00:00:00'
                          ? item.totalTimeWorked
                          : (item.totalMinutes > 0
                              ? '${item.totalMinutes} mins'
                              : '00:00:00');

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 4,
                              child: Text(
                                voucherText,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF1E293B),
                                  fontFamily: 'OpenSans',
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(
                                workersText,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF1E293B),
                                  fontFamily: 'OpenSans',
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(
                                timeTakenText,
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF1E293B),
                                  fontFamily: 'OpenSans',
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  // Total Row at the bottom
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: Color(0xFFE2E8F0),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        const Expanded(
                          flex: 4,
                          child: Text(
                            'Total',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1E293B),
                              fontFamily: 'OpenSans',
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            '$totalEmployees',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1E293B),
                              fontFamily: 'OpenSans',
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            totalTimeText,
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1E293B),
                              fontFamily: 'OpenSans',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

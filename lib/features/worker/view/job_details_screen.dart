import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../models/job_card_model.dart';
import '../../../models/job_status.dart';
import '../../../services/api_service.dart';
import '../../../utils/app_build_methods.dart';
import '../../../utils/colors.dart';
import '../../../utils/time_zone_helper.dart';
import '../../../widgets/circular_gauge_timer_widget.dart';
import '../../../widgets/status_badge.dart';
import '../view_model/worker_dashboard_view_model.dart';
import '../widgets/job_completion_dialogs.dart';

/// Job Details Screen (Exact 1:1 match to Figma Flow & Prototype)
/// Supports:
/// - Initial Job Details state with Start Job (Image 1)
/// - Active / Expanded Timer state with Stop Job (Image 2)
/// - Job Completed Bottom Sheet modal on "Complete Job" (Image 3)
class JobDetailsScreen extends StatefulWidget {
  static const String routeName = '/job-details';

  final JobCardModel job;

  const JobDetailsScreen({
    super.key,
    required this.job,
  });

  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  bool _isStarted = false;
  bool _isExpanded = false;
  bool _isLoadingApi = false;
  bool _isActionLoading = false;
  Timer? _timer;
  int _seconds = 0;
  DateTime? _sessionStartTime;
  DateTime? _localStopTime;

  bool get _isCompleted => widget.job.status == JobStatus.completed;

  @override
  void initState() {
    super.initState();
    // Do NOT auto-expand to fullscreen and do NOT auto-start timer on screen open.
    // Fullscreen should only be triggered by the fullscreen button.
    _isStarted = false;
    _isExpanded = false;

    // Showing Time & Details: Fetch job card details, total time, and sessions with progress indication
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData();
    });
  }

  Future<void> _refreshData() async {
    final dbId = widget.job.dbId ?? int.tryParse(widget.job.id);
    if (dbId == null || !mounted) return;

    setState(() => _isLoadingApi = true);
    try {
      final vm = context.read<WorkerDashboardViewModel>();
      await Future.wait([
        vm.fetchJobCardDetails(dbId),
        vm.fetchJobTotalTime(dbId),
        vm.fetchJobSessions(dbId),
      ]);
      if (!mounted) return;

      // Check if there is an active running session (endTime == null)
      final sessions = vm.getSessions(widget.job.id);
      final runningSession =
          sessions.where((s) => s.endTime == null).firstOrNull;
      if (runningSession != null && !_isCompleted) {
        final startDt = DateTime.tryParse(runningSession.startTime ?? '');
        if (startDt != null) {
          _sessionStartTime = startDt;
          _seconds =
              DateTime.now().difference(startDt).inSeconds.clamp(0, 86400);
        }
        _isStarted = true;
        _startTimer();
      }
    } catch (e) {
      debugPrint('Error refreshing job data: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingApi = false);
      }
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() => _seconds++);
        context.read<WorkerDashboardViewModel>().incrementTimer();
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }

  String _formatSessionTime(String? raw) {
    return TimezoneHelper.formatTimeOnly(raw);
  }

  String _formatSessionDate(String? raw) {
    return TimezoneHelper.formatDateOnly(raw);
  }

  int _parseTimeStringToSeconds(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty || timeStr == '-') return 0;
    try {
      if (timeStr.contains(':')) {
        final parts = timeStr.split(':');
        if (parts.length == 3) {
          return (int.parse(parts[0]) * 3600) +
              (int.parse(parts[1]) * 60) +
              int.parse(parts[2]);
        } else if (parts.length == 2) {
          return (int.parse(parts[0]) * 60) + int.parse(parts[1]);
        }
      }
      int seconds = 0;
      final hoursMatch = RegExp(r'(\d+)\s*(?:hrs?|h)').firstMatch(timeStr);
      if (hoursMatch != null) {
        seconds += (int.tryParse(hoursMatch.group(1) ?? '0') ?? 0) * 3600;
      }
      final minsMatch = RegExp(r'(\d+)\s*(?:mins?|m)').firstMatch(timeStr);
      if (minsMatch != null) {
        seconds += (int.tryParse(minsMatch.group(1) ?? '0') ?? 0) * 60;
      }
      final secsMatch = RegExp(r'(\d+)\s*(?:secs?|s)').firstMatch(timeStr);
      if (secsMatch != null) {
        seconds += int.tryParse(secsMatch.group(1) ?? '0') ?? 0;
      }
      return seconds;
    } catch (_) {
      return 0;
    }
  }

  int _getTotalElapsedSeconds(WorkerDashboardViewModel vm) {
    final timeData = vm.getTotalTimeData(widget.job.id);
    final sessions = vm.getSessions(widget.job.id);

    int baseSeconds = 0;
    if (timeData?.totalSeconds != null && timeData!.totalSeconds > 0) {
      baseSeconds = timeData.totalSeconds;
    } else if (sessions.isNotEmpty) {
      baseSeconds = sessions
          .where((s) => s.endTime != null)
          .fold<double>(0.0, (acc, s) => acc + s.durationSeconds)
          .toInt();
      if (baseSeconds == 0) {
        baseSeconds = sessions
            .fold<double>(0.0, (acc, s) => acc + s.durationSeconds)
            .toInt();
      }
    } else if (widget.job.timeSpentText != null) {
      baseSeconds = _parseTimeStringToSeconds(widget.job.timeSpentText);
    }

    if (_isStarted) {
      final currentElapsed = _seconds;
      return baseSeconds + currentElapsed;
    }

    return baseSeconds;
  }

  void _handleStartJob() async {
    if (_isActionLoading) return;
    _sessionStartTime = DateTime.now();
    _seconds = 0;
    _localStopTime = null;
    setState(() {
      _isStarted = true;
      _isActionLoading = true;
      // Do NOT set _isExpanded = true here; keep current view unless user taps fullscreen button
    });
    _startTimer();
    try {
      // Start Job: Calls status API (PATCH /api/v1/job-cards/{id}/status -> STARTED: 3)
      await context.read<WorkerDashboardViewModel>().startJob(widget.job.id);
    } catch (e) {
      debugPrint('Error starting job: $e');
    } finally {
      if (mounted) {
        setState(() => _isActionLoading = false);
      }
    }
  }

  void _handleStopJob() async {
    if (_isActionLoading) return;
    final now = DateTime.now();
    final sessionDuration = _sessionStartTime != null
        ? now.difference(_sessionStartTime!).inSeconds
        : _seconds;

    _stopTimer();
    setState(() {
      _isStarted = false;
      _isActionLoading = true;
      _localStopTime = now;
      _seconds = 0;
      _sessionStartTime = null;
    });

    try {
      // Stop Job: Uses Swagger time tracking section (POST /api/v1/time-tracking/log)
      await context.read<WorkerDashboardViewModel>().pauseJob(
            widget.job.id,
            durationSeconds: sessionDuration > 0 ? sessionDuration : 1,
            endTime: now.toUtc(),
          );
      if (mounted) {
        final apiMsg = context.read<WorkerDashboardViewModel>().lastSuccessMessage;
        if (apiMsg != null && apiMsg.isNotEmpty) {
          showToast(apiMsg);
        }
      }
    } catch (e) {
      debugPrint('Error pausing job: $e');
    } finally {
      if (mounted) {
        setState(() => _isActionLoading = false);
      }
    }
  }

  void _openCompleteJobBottomSheet() {
    final sessionDuration = _sessionStartTime != null
        ? DateTime.now().difference(_sessionStartTime!).inSeconds
        : _seconds;
    JobCompletedModal.show(
      context,
      job: widget.job,
      onConfirmed: () async {
        final vm = context.read<WorkerDashboardViewModel>();
        try {
          final success = await vm.markJobCompleted(
            widget.job.id,
            finalDurationSeconds: sessionDuration,
          );
          if (success && context.mounted) {
            final apiMsg = vm.lastSuccessMessage;
            if (apiMsg != null && apiMsg.isNotEmpty) {
              showToast(apiMsg);
            }
            JobCompletedSuccessDialog.show(
              context,
              jobCardId: widget.job.id,
              onDismiss: () {
                Navigator.pop(context);
              },
            );
          } else {
            final err = vm.errorMessage ?? 'Failed to complete job';
            showToast(err);
          }
        } catch (e) {
          debugPrint('Error completing job: $e');
          showToast(ApiService.extractErrorMessage(e));
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F8FA),
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Color(0xFFF7F8FA),
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Color(0xFF1E293B),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: _isExpanded
            ? null
            : const Text(
                'Job Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
        centerTitle: false,
      ),
      body: _isLoadingApi
          ? const Center(
              child: CircularProgressIndicator(
                color: FactoryColors.primary,
              ),
            )
          : RefreshIndicator(
              onRefresh: _refreshData,
              color: FactoryColors.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_isActionLoading)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 10),
                        child: ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                          child: LinearProgressIndicator(
                            minHeight: 3,
                            backgroundColor: Color(0xFFE2E8F0),
                            valueColor:
                                AlwaysStoppedAnimation<Color>(FactoryColors.primary),
                          ),
                        ),
                      ),

                    // 1. Top Job Overview Card (Visible when not expanded)
                    if (!_isExpanded) ...[
                      _buildJobOverviewCard(),
                      const SizedBox(height: 16),
                    ],

                    // 2. Log Time Card (Collapsible/Expandable matching Image 1 & Image 2)
                    _buildLogTimeCard(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: (_isCompleted || _isLoadingApi) ? null : _buildBottomBar(),
    );
  }

  /// 1. Top Overview Card (Exact match to Figma Image 1)
  Widget _buildJobOverviewCard() {
    final voucherId = widget.job.voucherId;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Voucher ID (left) and Dual Ring Thumbnails (right)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Voucher ID:',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      voucherId,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
              ),
              // Real Job Images (hidden if no images)
              _buildJobImages(),
            ],
          ),
          const SizedBox(height: 14),

          // Row 2: Design No, Pieces, Weight (3 columns matching Figma)
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Design No',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.job.designNo,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pieces',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${widget.job.pieces}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Weight',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${widget.job.grossWeightGm.toStringAsFixed(0)} gm',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Row 3: Time Taken & Assigned Time on left/center & Status badge on right
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Time Taken',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Consumer<WorkerDashboardViewModel>(
                      builder: (context, vm, _) {
                        final timeData = vm.getTotalTimeData(widget.job.id);
                        final displayTime = timeData?.totalDurationFormatted ??
                            widget.job.timeSpentText ??
                            '-';
                        return Text(
                          displayTime,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: FactoryColors.primary,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Assigned Time',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Consumer<WorkerDashboardViewModel>(
                      builder: (context, vm, _) {
                        final currentJob = vm.getJob(widget.job.id) ?? widget.job;
                        final assignedStr = currentJob.displayAssignedTime != '-'
                            ? currentJob.displayAssignedTime
                            : (widget.job.displayAssignedTime != '-'
                                ? widget.job.displayAssignedTime
                                : (currentJob.timeAssigned ?? widget.job.timeAssigned ?? '-'));
                        return Text(
                          assignedStr.isNotEmpty && assignedStr != 'null' ? assignedStr : '-',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E293B),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              StatusBadge(
                status: widget.job.status,
                customLabel: widget.job.statusName,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildJobImages() {
    if (widget.job.images.isEmpty) {
      return const SizedBox.shrink();
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: widget.job.images.take(2).map((imgUrl) {
        final fullUrl = imgUrl.startsWith('http')
            ? imgUrl
            : 'https://mi-factory.aufy.net${imgUrl.startsWith('/') ? '' : '/'}$imgUrl';
        return Padding(
          padding: const EdgeInsets.only(left: 8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 48,
              height: 48,
              child: Image.network(
                fullUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  /// 2. Log Time Card (Matches Figma Image 1 when collapsed & Image 2 when expanded)
  Widget _buildLogTimeCard() {
    final double gaugeSize = _isExpanded ? 220 : 170;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header Row: "Log Time" on left and Expand/Collapse icon on right
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Log Time',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
              InkWell(
                onTap: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    _isExpanded
                        ? Icons.fullscreen_exit_rounded
                        : Icons.fullscreen_rounded,
                    size: 24,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: _isExpanded ? 24 : 16),

          // Large Circular Gauge Arc Timer
          Consumer<WorkerDashboardViewModel>(
            builder: (context, vm, _) {
              final totalSeconds = _getTotalElapsedSeconds(vm);

              final hours = (totalSeconds ~/ 3600).toString().padLeft(2, '0');
              final minutes =
                  ((totalSeconds % 3600) ~/ 60).toString().padLeft(2, '0');
              final secs = (totalSeconds % 60).toString().padLeft(2, '0');
              final displayTime = '$hours:$minutes:$secs';

              final isPaused = !_isStarted &&
                  !_isCompleted &&
                  totalSeconds > 0;

              final statusText = _isCompleted
                  ? 'COMPLETED'
                  : (_isStarted ? 'RUNNING' : (isPaused ? 'PAUSED' : null));

              final detailedJob = vm.getJob(widget.job.id);
              final currentJob = detailedJob ??
                  vm.filteredJobs
                      .where((j) =>
                          j.id == widget.job.id || j.dbId == widget.job.dbId)
                      .firstOrNull ??
                  widget.job;
              final assignedSeconds = currentJob.assignedSeconds > 0
                  ? currentJob.assignedSeconds
                  : widget.job.assignedSeconds;

              // Arc progress calculated from 00:00:00 to max time_assigned.
              // If time_assigned is null or 0, do not show progress (0.0).
              // Shows actual elapsed consumption of time_assigned even when completed.
              final double timerProgress = assignedSeconds > 0
                  ? (totalSeconds / assignedSeconds).clamp(0.0, 1.0)
                  : 0.0;

              return Center(
                child: CircularGaugeTimerWidget(
                  formattedTime: displayTime,
                  progress: timerProgress,
                  size: gaugeSize,
                  isPaused: isPaused,
                  statusText: statusText,
                ),
              );
            },
          ),
          if (!_isCompleted) ...[
            SizedBox(height: _isExpanded ? 24 : 16),
            // Outlined "Complete Job" Button
            OutlinedButton(
              onPressed: _openCompleteJobBottomSheet,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 44),
                side:
                    const BorderSide(color: FactoryColors.primary, width: 1.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Complete Job',
                style: TextStyle(
                  color: FactoryColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),

          // Beige Timeline Box: Shows Time Tracked and Sessions List from Swagger Time Tracking
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFAF5F0),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Consumer<WorkerDashboardViewModel>(
              builder: (context, vm, _) {
                final timeData = vm.getTotalTimeData(widget.job.id);
                final sessions = vm.getSessions(widget.job.id);
                String displayTime = timeData?.totalDurationFormatted ??
                    widget.job.timeSpentText ??
                    '-';
                if (displayTime == '-' && sessions.isNotEmpty) {
                  final totalSecs = sessions
                      .fold<double>(0.0, (acc, s) => acc + (s.durationSeconds))
                      .toInt();
                  if (totalSecs > 0) {
                    final h = (totalSecs ~/ 3600).toString().padLeft(2, '0');
                    final m =
                        ((totalSecs % 3600) ~/ 60).toString().padLeft(2, '0');
                    final s = (totalSecs % 60).toString().padLeft(2, '0');
                    displayTime = '$h:$m:$s';
                  }
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Time Taken : $displayTime',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        Consumer<WorkerDashboardViewModel>(
                          builder: (context, vm, _) {
                            final currentJob = vm.getJob(widget.job.id) ?? widget.job;
                            final assignedStr = currentJob.displayAssignedTime != '-'
                                ? currentJob.displayAssignedTime
                                : (currentJob.timeAssigned ?? widget.job.timeAssigned ?? '');
                            if (assignedStr.isEmpty || assignedStr == '-' || assignedStr == 'null') {
                              return const SizedBox.shrink();
                            }
                            return Text(
                              'Assigned: $assignedStr',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF64748B),
                              ),
                            );
                          },
                        ),
                        if (_isLoadingApi)
                          const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  FactoryColors.primary),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (sessions.isNotEmpty) ...[
                      ...() {
                        final sortedSessions = List.of(sessions)
                          ..sort((a, b) {
                            final aTime = a.startTime ?? '';
                            final bTime = b.startTime ?? '';
                            return aTime.compareTo(bTime);
                          });

                        return [
                          for (int i = 0; i < sortedSessions.length; i++) ...[
                            if (sortedSessions.length > 1)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Text(
                                  'Session ${i + 1}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ),
                            // Start Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Start',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF16A34A),
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      _formatSessionTime(
                                          sortedSessions[i].startTime),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF1E293B),
                                      ),
                                    ),
                                    Text(
                                      _formatSessionDate(
                                          sortedSessions[i].startTime ??
                                              sortedSessions[i].createdAt),
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF64748B),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            // Stop or Ongoing Status Row (never show Stop against Running)
                            () {
                              final isSessionOngoing =
                                  sortedSessions[i].endTime == null;
                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isSessionOngoing ? 'Status' : 'Stop',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: isSessionOngoing
                                          ? const Color(0xFF16A34A)
                                          : const Color(0xFFDC2626),
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        isSessionOngoing
                                            ? 'Running...'
                                            : _formatSessionTime(
                                                sortedSessions[i].endTime),
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: isSessionOngoing
                                              ? const Color(0xFF16A34A)
                                              : const Color(0xFF1E293B),
                                        ),
                                      ),
                                      if (!isSessionOngoing)
                                        Text(
                                          _formatSessionDate(
                                              sortedSessions[i].endTime),
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Color(0xFF64748B),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              );
                            }(),
                            if (i < sortedSessions.length - 1)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 10),
                                child: Divider(
                                    color: Color(0xFFE2E8F0), thickness: 1),
                              ),
                          ],
                        ];
                      }(),
                    ] else ...[
                      // Initial fallback single session or active status
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Start',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF16A34A),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                _formatSessionTime(widget.job.startTimeText),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              Text(
                                _formatSessionDate(
                                    widget.job.dateText.isNotEmpty
                                        ? widget.job.dateText
                                        : widget.job.startTimeText),
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF64748B),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      if (_isExpanded ||
                          _isStarted ||
                          _localStopTime != null) ...[
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isStarted ? 'Status' : 'Stop',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: _isStarted
                                    ? const Color(0xFF16A34A)
                                    : const Color(0xFFDC2626),
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  _isStarted
                                      ? 'Running...'
                                      : (_localStopTime != null
                                          ? _formatSessionTime(
                                              _localStopTime!.toIso8601String())
                                          : _formatSessionTime(
                                              widget.job.stopTimeText)),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: _isStarted
                                        ? const Color(0xFF16A34A)
                                        : const Color(0xFF1E293B),
                                  ),
                                ),
                                if (!_isStarted &&
                                    (_localStopTime != null ||
                                        widget.job.stopTimeText != null))
                                  Text(
                                    _formatSessionDate(_localStopTime != null
                                        ? _localStopTime!.toIso8601String()
                                        : widget.job.stopTimeText),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF64748B),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 3. Bottom Button Bar (Green "Start Job"/"Resume Job", Red "Stop Job")
  Widget _buildBottomBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Consumer<WorkerDashboardViewModel>(
          builder: (context, vm, _) {
            return ElevatedButton(
              onPressed: _isActionLoading
                  ? null
                  : (_isStarted ? _handleStopJob : _handleStartJob),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isStarted
                    ? const Color(0xFFDC2626)
                    : const Color(0xFF48BB78),
                disabledBackgroundColor: (_isStarted
                        ? const Color(0xFFDC2626)
                        : const Color(0xFF48BB78))
                    .withValues(alpha: 0.7),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: _isActionLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      _isStarted ? 'Stop Job' : 'Start Job',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            );
          },
        ),
      ),
    ),
  );
}
}

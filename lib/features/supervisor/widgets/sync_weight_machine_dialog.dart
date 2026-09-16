import 'package:flutter/material.dart';

import '../../../utils/colors.dart';
import '../../../utils/styles.dart';

/// Modal bottom sheet matching Figma: "Enter Weight from Machine"
class SyncWeightMachineBottomSheet extends StatefulWidget {
  final String jobCardId;
  final double initialWeight;
  final String buttonTitle;
  final Function(double) onSubmit;

  const SyncWeightMachineBottomSheet({
    super.key,
    required this.jobCardId,
    this.initialWeight = 0.0,
    this.buttonTitle = 'Submit and Complete',
    required this.onSubmit,
  });

  /// Helper method to display this bottom sheet
  static Future<T?> show<T>({
    required BuildContext context,
    required String jobCardId,
    double initialWeight = 0.0,
    String buttonTitle = 'Submit and Complete',
    required Function(double) onSubmit,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SyncWeightMachineBottomSheet(
        jobCardId: jobCardId,
        initialWeight: initialWeight,
        buttonTitle: buttonTitle,
        onSubmit: onSubmit,
      ),
    );
  }

  @override
  State<SyncWeightMachineBottomSheet> createState() =>
      _SyncWeightMachineBottomSheetState();
}

class _SyncWeightMachineBottomSheetState
    extends State<SyncWeightMachineBottomSheet> {
  late TextEditingController _weightController;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController(
      text: widget.initialWeight > 0
          ? widget.initialWeight.toStringAsFixed(2)
          : '0.00',
    );
  }

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  void _simulateMachineSync() async {
    setState(() => _isSyncing = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      setState(() {
        _isSyncing = false;
        _weightController.text = '30.00';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Weight synced from Machine: 30.00 gm'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Title & Close Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Enter Weight from Machine',
                style: tsS18W700.copyWith(
                  color: FactoryColors.textPrimary,
                ),
              ),
              InkWell(
                onTap: () => Navigator.of(context).pop(),
                borderRadius: BorderRadius.circular(20),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    Icons.close_rounded,
                    size: 22,
                    color: FactoryColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Subtitle
          Text(
            'Type the weight or sync directly from the machine',
            style: tsS12W400.copyWith(
              color: FactoryColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),

          // Enter the Weight: label
          Text(
            'Enter the Weight:',
            style: tsS13W600.copyWith(
              color: FactoryColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),

          // Text field with gm suffix
          TextField(
            controller: _weightController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: tsS15W600.copyWith(
              color: FactoryColors.textPrimary,
            ),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              suffixText: 'gm',
              suffixStyle: tsS13W500.copyWith(
                color: FactoryColors.textSecondary,
              ),
              filled: true,
              fillColor: Colors.white,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: FactoryColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: FactoryColors.primary,
                  width: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // "or" Divider
          Row(
            children: [
              const Expanded(child: Divider(color: FactoryColors.border)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  'or',
                  style: tsS12W400.copyWith(
                    color: FactoryColors.textMuted,
                  ),
                ),
              ),
              const Expanded(child: Divider(color: FactoryColors.border)),
            ],
          ),
          const SizedBox(height: 16),

          // Sync from machine button
          OutlinedButton.icon(
            onPressed: _isSyncing ? null : _simulateMachineSync,
            icon: _isSyncing
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: FactoryColors.primary,
                    ),
                  )
                : const Icon(
                    Icons.sync_rounded,
                    size: 18,
                    color: FactoryColors.primary,
                  ),
            label: Text(
              _isSyncing ? 'Syncing...' : 'Sync from machine',
              style: tsS13W600.copyWith(
                color: FactoryColors.primary,
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: const BorderSide(color: FactoryColors.primary, width: 1.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              backgroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 20),

          // Submit and Complete button
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                final val = double.tryParse(_weightController.text) ?? 30.0;
                Navigator.of(context).pop();
                widget.onSubmit(val);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: FactoryColors.primary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                widget.buttonTitle,
                style: tsS15W700.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Backwards compatibility alias
typedef SyncWeightMachineDialog = SyncWeightMachineBottomSheet;

import 'package:flutter/material.dart';

import '../../../services/api_service.dart';
import '../../../utils/app_build_methods.dart';
import '../../../utils/colors.dart';
import '../../../utils/styles.dart';

/// Modal bottom sheet matching Figma: "Enter Weight from Machine"
class SyncWeightMachineBottomSheet extends StatefulWidget {
  final String jobCardId;
  final double initialWeight;
  final String buttonTitle;
  final dynamic Function(double) onSubmit;

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
    required dynamic Function(double) onSubmit,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
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
  bool _isLoading = false;
  String? _errorMessage;

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
        bottom: MediaQuery.of(context).viewInsets.bottom +
            MediaQuery.of(context).padding.bottom +
            24,
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
                'Enter Weight',
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
            'Type the weight to proceed',
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
          const SizedBox(height: 20),

          // Inline error message if any
          if (_errorMessage != null && _errorMessage!.isNotEmpty) ...[
            Text(
              _errorMessage!,
              style: tsS12W400.copyWith(color: FactoryColors.buttonRed),
            ),
            const SizedBox(height: 12),
          ],

          // Submit button
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : () async {
                      final text = _weightController.text.trim();
                      final val = double.tryParse(text);
                      if (val == null || val <= 0) {
                        setState(() {
                          _errorMessage = 'Please enter a valid weight';
                        });
                        return;
                      }

                      setState(() {
                        _isLoading = true;
                        _errorMessage = null;
                      });

                      try {
                        final result = await widget.onSubmit(val);
                        // If onSubmit returns false, it indicates failure
                        if (result == false) {
                          if (mounted) {
                            setState(() => _isLoading = false);
                          }
                          return;
                        }
                        // Only close sheet when API succeeds!
                        if (mounted) {
                          Navigator.of(context).pop(val);
                        }
                      } catch (e) {
                        final errorStr = ApiService.extractErrorMessage(e);
                        if (mounted) {
                          setState(() {
                            _isLoading = false;
                            _errorMessage = errorStr;
                          });
                          showToast(errorStr);
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: FactoryColors.primary,
                disabledBackgroundColor:
                    FactoryColors.primary.withValues(alpha: 0.6),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
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

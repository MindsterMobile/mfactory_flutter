import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../utils/colors.dart';
import '../../../utils/styles.dart';

/// Item model for Product Report Table
class ProductReportItem {
  final String date;
  final String productionWeight;
  final String totalPcs;

  const ProductReportItem({
    required this.date,
    required this.productionWeight,
    required this.totalPcs,
  });
}

/// Screen matching Figma "Product Report"
class ProductReportScreen extends StatelessWidget {
  static const String routeName = '/product-report';

  const ProductReportScreen({super.key});

  final List<ProductReportItem> _reportItems = const [
    ProductReportItem(date: '01-Jan-2025', productionWeight: '43.200', totalPcs: '12'),
    ProductReportItem(date: '01-Jan-2025', productionWeight: '43.200', totalPcs: '10'),
    ProductReportItem(date: '01-Jan-2025', productionWeight: '43.200', totalPcs: '11'),
    ProductReportItem(date: '01-Jan-2025', productionWeight: '43.200', totalPcs: '12'),
    ProductReportItem(date: '01-Jan-2025', productionWeight: '43.200', totalPcs: '10'),
    ProductReportItem(date: '01-Jan-2025', productionWeight: '43.200', totalPcs: '11'),
  ];

  @override
  Widget build(BuildContext context) {
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
          'Product Report',
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
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).padding.bottom + 16,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: FactoryColors.border),
            boxShadow: const [
              BoxShadow(
                color: FactoryColors.shadowColor,
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Cream Table Header Bar (#FBF4E9)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  color: FactoryColors.surfaceWarmBeige,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(11)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Text(
                        'Date',
                        style: tsS12W700.copyWith(
                          color: FactoryColors.textSlate,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Center(
                        child: Text(
                          'Production Weight',
                          style: tsS12W700.copyWith(
                            color: FactoryColors.textSlate,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Total Pcs',
                            style: tsS12W700.copyWith(
                              color: FactoryColors.textSlate,
                            ),
                          ),
                          Text(
                            '(Rejected)',
                            style: tsS10W500.copyWith(
                              color: FactoryColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Rows
              ..._reportItems.asMap().entries.map((entry) {
                final item = entry.value;
                final isLast = entry.key == _reportItems.length - 1;

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 4,
                            child: Text(
                              item.date,
                              style: tsS13W600.copyWith(
                                color: FactoryColors.textPrimary,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 4,
                            child: Center(
                              child: Text(
                                item.productionWeight,
                                style: tsS13W600.copyWith(
                                  color: FactoryColors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                item.totalPcs,
                                style: tsS13W700.copyWith(
                                  color: FactoryColors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!isLast)
                      const Divider(
                        height: 1,
                        thickness: 1,
                        color: FactoryColors.dividerLight,
                      ),
                  ],
                );
              }),

              // Pagination Footer matching "10 >"
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '10',
                      style: tsS13W600.copyWith(
                        color: FactoryColors.textSecondary.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: FactoryColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

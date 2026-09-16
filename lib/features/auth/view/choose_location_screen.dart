import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../utils/colors.dart';
import '../../worker/view/worker_dashboard_screen.dart';

class FactoryLocation {
  final String code;
  final String address;

  const FactoryLocation({
    required this.code,
    required this.address,
  });
}

/// Choose Location Screen (Figma Screen 2 in Login Row)
class ChooseLocationScreen extends StatefulWidget {
  static const String routeName = '/choose-location';

  const ChooseLocationScreen({super.key});

  @override
  State<ChooseLocationScreen> createState() => _ChooseLocationScreenState();
}

class _ChooseLocationScreenState extends State<ChooseLocationScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<FactoryLocation> _allLocations = const [
    FactoryLocation(
      code: 'V',
      address: 'UAE Dubai Freezone Supply Chain',
    ),
    FactoryLocation(
      code: 'AIC',
      address: 'Bahrain Own Stock Holding in UAE',
    ),
    FactoryLocation(
      code: 'UMDGS',
      address: 'UAE Dubai Freezone Supply Chain',
    ),
    FactoryLocation(
      code: 'UDFSCM',
      address: 'UAE Dubai Freezone Supply Chain',
    ),
    FactoryLocation(
      code: 'UDFSCM',
      address: 'UAE Dubai Freezone Supply Chain',
    ),
    FactoryLocation(
      code: 'UDFSCM',
      address: 'UAE Dubai Freezone Supply Chain',
    ),
    FactoryLocation(
      code: 'UDFSCM',
      address: 'UAE Dubai Freezone Supply Chain',
    ),
    FactoryLocation(
      code: 'UDFSCM',
      address: 'UAE Dubai Freezone Supply Chain',
    ),
    FactoryLocation(
      code: 'UDFSCM',
      address: 'UAE Dubai Freezone Supply Chain',
    ),
    FactoryLocation(
      code: 'UDFSCM',
      address: 'UAE Dubai Freezone Supply Chain',
    ),
  ];

  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<FactoryLocation> get _filteredLocations {
    if (_searchQuery.trim().isEmpty) return _allLocations;
    final q = _searchQuery.toLowerCase();
    return _allLocations.where((loc) {
      return loc.code.toLowerCase().contains(q) ||
          loc.address.toLowerCase().contains(q);
    }).toList();
  }

  void _onLocationSelected(FactoryLocation loc) {
    Navigator.pushReplacementNamed(context, WorkerDashboardScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
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
              Icons.arrow_back,
              color: FactoryColors.textPrimary,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          titleSpacing: 0,
          title: const Text(
            'Choose Location',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: FactoryColors.textPrimary,
            ),
          ),
          centerTitle: false,
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Search Input Field matching screenshot
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFD0D5DD)),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() => _searchQuery = val),
                    style: const TextStyle(
                      fontSize: 15,
                      color: FactoryColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search Location',
                      hintStyle: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF98A2B3),
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Color(0xFF667085),
                        size: 22,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 13,
                        horizontal: 8,
                      ),
                    ),
                  ),
                ),
              ),

              // Locations List without radio buttons matching screenshot
              Expanded(
                child: ListView.separated(
                  itemCount: _filteredLocations.length,
                  separatorBuilder: (context, index) => const Divider(
                    height: 1,
                    thickness: 1,
                    color: Color(0xFFF2F4F7),
                    indent: 16,
                    endIndent: 16,
                  ),
                  itemBuilder: (context, index) {
                    final loc = _filteredLocations[index];

                    return InkWell(
                      onTap: () => _onLocationSelected(loc),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              loc.code,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1D2939),
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              loc.address,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF667085),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

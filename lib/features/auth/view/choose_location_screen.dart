import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../helpers/sp_helper.dart';
import '../../../utils/colors.dart';
import '../../../utils/sp_keys.dart' as sp_keys;
import '../../../widgets/app_progress_widget.dart';
import '../../supervisor/view/supervisor_dashboard_screen.dart';
import '../../worker/view/worker_dashboard_screen.dart';
import '../view_model/choose_location_view_model.dart';
import 'login_screen.dart';

export '../view_model/choose_location_view_model.dart' show FactoryLocation;

/// Choose Location Screen (Figma Screen 2 in Login Row)
class ChooseLocationScreen extends StatelessWidget {
  static const String routeName = '/choose-location';
  final ChooseLocationViewModel? viewModel;

  const ChooseLocationScreen({super.key, this.viewModel});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ChooseLocationViewModel>(
      create: (_) => viewModel ?? (ChooseLocationViewModel()..loadLocations()),
      child: const _ChooseLocationView(),
    );
  }
}

class _ChooseLocationView extends StatefulWidget {
  const _ChooseLocationView();

  @override
  State<_ChooseLocationView> createState() => _ChooseLocationViewState();
}

class _ChooseLocationViewState extends State<_ChooseLocationView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _onLocationSelected(
    ChooseLocationViewModel vm,
    FactoryLocation loc,
  ) async {
    await vm.selectLocation(loc);

    if (!mounted) return;

    final args = ModalRoute.of(context)?.settings.arguments;
    final isPicker = args is Map && args['isPicker'] == true;
    if (isPicker && Navigator.canPop(context)) {
      Navigator.pop(context, loc);
      return;
    }

    final role = await SpHelper.getString(sp_keys.keyRole);
    final roleId = await SpHelper.getString(sp_keys.keyRoleId);
    if (!mounted) return;

    if (role == 'worker' || roleId == '1') {
      Navigator.pushReplacementNamed(context, WorkerDashboardScreen.routeName);
    } else {
      Navigator.pushReplacementNamed(context, SupervisorDashboardScreen.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChooseLocationViewModel>(
      builder: (context, vm, _) {
        final locations = vm.filteredLocations;

        if (vm.isLoaded && vm.allLocations.isEmpty) {
          final args = ModalRoute.of(context)?.settings.arguments;
          final isPicker = args is Map && args['isPicker'] == true;
          if (!isPicker) {
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              if (!mounted) return;
              final role = await SpHelper.getString(sp_keys.keyRole);
              final roleId = await SpHelper.getString(sp_keys.keyRoleId);
              if (!mounted) return;

              if (role == 'worker' || roleId == '1') {
                Navigator.pushReplacementNamed(
                  context,
                  WorkerDashboardScreen.routeName,
                );
              } else {
                Navigator.pushReplacementNamed(
                  context,
                  SupervisorDashboardScreen.routeName,
                );
              }
            });
          }
        }

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
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  } else {
                    Navigator.pushReplacementNamed(
                      context,
                      LoginScreen.routeName,
                    );
                  }
                },
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
              child: Stack(
                children: [
                  Column(
                    children: [
                      // Search Input Field matching design
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
                            onChanged: vm.setSearchQuery,
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
                                        vm.setSearchQuery('');
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

                      // Locations List
                      Expanded(
                        child: locations.isEmpty && !vm.isLoading
                            ? const Center(
                                child: Text(
                                  'No locations found',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF667085),
                                  ),
                                ),
                              )
                            : ListView.separated(
                          padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).padding.bottom + 16,
                          ),
                          itemCount: locations.length,
                          separatorBuilder: (context, index) => const Divider(
                            height: 1,
                            thickness: 1,
                            color: Color(0xFFF2F4F7),
                            indent: 16,
                            endIndent: 16,
                          ),
                          itemBuilder: (context, index) {
                            final loc = locations[index];

                            return InkWell(
                              onTap: () => _onLocationSelected(vm, loc),
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
                  if (vm.isLoading)
                    Positioned.fill(
                      child: Container(
                        color: Colors.white.withValues(alpha: 0.6),
                        alignment: Alignment.center,
                        child: const AppProgressWidget(),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

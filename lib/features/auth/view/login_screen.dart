import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../models/user_role.dart';
import '../../../utils/colors.dart';
import '../../../utils/dimensions.dart';
import '../../../utils/styles.dart';
import '../../../widgets/mgd_button.dart';
import '../../supervisor/view/supervisor_dashboard_screen.dart';
import '../view_model/login_view_model.dart';

/// Shared Login Screen for Factory Worker and Factory Supervisor.
class LoginScreen extends StatefulWidget {
  static const String routeName = '/login';

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _employeeIdController = TextEditingController(text: 'UM001');
  final _passwordController = TextEditingController(text: '••••••••');
  final _focusNodeEmployee = FocusNode();
  final _focusNodePassword = FocusNode();

  @override
  void dispose() {
    _employeeIdController.dispose();
    _passwordController.dispose();
    _focusNodeEmployee.dispose();
    _focusNodePassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LoginViewModel>(
      create: (_) => LoginViewModel(),
      child: Scaffold(
        backgroundColor: FactoryColors.surface,
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: FactoryDimens.p24,
                    vertical: FactoryDimens.p20,
                  ),
                  child: Consumer<LoginViewModel>(
                    builder: (context, vm, child) {
                      return Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: FactoryDimens.p16),
                            _buildBrandHeader(),
                            const SizedBox(height: FactoryDimens.p28),
                            _buildBranchDropdown(vm),
                            const SizedBox(height: FactoryDimens.p16),
                            _buildEmployeeIdField(),
                            const SizedBox(height: FactoryDimens.p16),
                            _buildPasswordField(vm),
                            const SizedBox(height: FactoryDimens.p8),
                            _buildRememberForgotRow(vm),
                            const SizedBox(height: FactoryDimens.p24),
                            _buildLoginButton(vm),
                            const SizedBox(height: FactoryDimens.p32),
                            _buildFooter(),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Top Brand Logo & App Identity
  Widget _buildBrandHeader() {
    return Column(
      children: [
        Container(
          width: 76,
          height: 76,
          padding: const EdgeInsets.all(FactoryDimens.p12),
          decoration: BoxDecoration(
            color: FactoryColors.primary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: FactoryColors.primary.withValues(alpha: 0.25),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: SvgPicture.asset(
            'assets/svgs/mgd_logo.svg',
            colorFilter: const ColorFilter.mode(
              FactoryColors.accentGold,
              BlendMode.srcIn,
            ),
          ),
        ),
        const SizedBox(height: FactoryDimens.p16),
        Text(
          'JEWELCRAFT MANUFACTURING',
          textAlign: TextAlign.center,
          style: FactoryTypography.caption.copyWith(
            color: FactoryColors.primary,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.0,
          ),
        ),
        const SizedBox(height: FactoryDimens.p4),
        Text(
          'Jewelry Factory ERP',
          textAlign: TextAlign.center,
          style: FactoryTypography.display.copyWith(
            color: FactoryColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: FactoryDimens.p4),
        Text(
          'Sign in to access your floor dashboard',
          textAlign: TextAlign.center,
          style: FactoryTypography.bodyMedium.copyWith(
            color: FactoryColors.textSecondary,
          ),
        ),
      ],
    );
  }

  /// Branch / Unit Selection
  Widget _buildBranchDropdown(LoginViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Factory Location',
          style: FactoryTypography.bodySmall.copyWith(
            color: FactoryColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: FactoryDimens.p6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: FactoryDimens.p12),
          decoration: BoxDecoration(
            color: FactoryColors.background,
            borderRadius: FactoryDimens.br10,
            border: Border.all(color: FactoryColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              dropdownColor: Colors.white,
              borderRadius: BorderRadius.circular(12),
              value: vm.selectedBranch,
              isExpanded: true,
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: FactoryColors.textSecondary,
              ),
              items: vm.availableBranches.map((branch) {
                return DropdownMenuItem<String>(
                  value: branch,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.factory_outlined,
                        size: 18,
                        color: FactoryColors.primary,
                      ),
                      const SizedBox(width: FactoryDimens.p8),
                      Expanded(
                        child: Text(
                          branch,
                          style: FactoryTypography.bodyMedium.copyWith(
                            color: FactoryColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: vm.setSelectedBranch,
            ),
          ),
        ),
      ],
    );
  }

  /// Employee ID Field
  Widget _buildEmployeeIdField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Employee ID',
          style: FactoryTypography.bodySmall.copyWith(
            color: FactoryColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: FactoryDimens.p6),
        TextFormField(
          controller: _employeeIdController,
          focusNode: _focusNodeEmployee,
          textInputAction: TextInputAction.next,
          style: FactoryTypography.bodyLarge.copyWith(
            color: FactoryColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            hintText: 'e.g. MG3126',
            hintStyle: FactoryTypography.bodyMedium.copyWith(
              color: FactoryColors.textMuted,
            ),
            filled: true,
            fillColor: FactoryColors.background,
            prefixIcon: const Icon(
              Icons.badge_outlined,
              color: FactoryColors.textSecondary,
              size: 20,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: FactoryDimens.p16,
              vertical: FactoryDimens.p14,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: FactoryDimens.br10,
              borderSide: const BorderSide(color: FactoryColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: FactoryDimens.br10,
              borderSide: const BorderSide(color: FactoryColors.primary, width: 1.5),
            ),
          ),
          validator: (val) =>
              (val == null || val.trim().isEmpty) ? 'Please enter your Employee ID' : null,
        ),
      ],
    );
  }

  /// Password Field
  Widget _buildPasswordField(LoginViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Password',
          style: FactoryTypography.bodySmall.copyWith(
            color: FactoryColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: FactoryDimens.p6),
        TextFormField(
          controller: _passwordController,
          focusNode: _focusNodePassword,
          obscureText: vm.obscurePassword,
          textInputAction: TextInputAction.done,
          style: FactoryTypography.bodyLarge.copyWith(
            color: FactoryColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            hintText: 'Enter your password',
            hintStyle: FactoryTypography.bodyMedium.copyWith(
              color: FactoryColors.textMuted,
            ),
            filled: true,
            fillColor: FactoryColors.background,
            prefixIcon: const Icon(
              Icons.lock_outline_rounded,
              color: FactoryColors.textSecondary,
              size: 20,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                vm.obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: FactoryColors.textSecondary,
                size: 20,
              ),
              onPressed: vm.togglePasswordVisibility,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: FactoryDimens.p16,
              vertical: FactoryDimens.p14,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: FactoryDimens.br10,
              borderSide: const BorderSide(color: FactoryColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: FactoryDimens.br10,
              borderSide: const BorderSide(color: FactoryColors.primary, width: 1.5),
            ),
          ),
          validator: (val) =>
              (val == null || val.trim().isEmpty) ? 'Please enter your password' : null,
          onFieldSubmitted: (_) => _handleLogin(vm),
        ),
      ],
    );
  }

  /// Remember Me Checkbox & Forgot Password Link
  Widget _buildRememberForgotRow(LoginViewModel vm) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: vm.rememberMe,
                onChanged: (val) => vm.setRememberMe(val ?? true),
                activeColor: FactoryColors.primary,
                shape: RoundedRectangleBorder(borderRadius: FactoryDimens.br6),
              ),
            ),
            const SizedBox(width: FactoryDimens.p8),
            GestureDetector(
              onTap: () => vm.setRememberMe(!vm.rememberMe),
              child: Text(
                'Remember me',
                style: FactoryTypography.bodySmall.copyWith(
                  color: FactoryColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        TextButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please contact Factory Admin to reset credentials.'),
                duration: Duration(seconds: 2),
              ),
            );
          },
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: const Size(50, 30),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'Forgot Password?',
            style: FactoryTypography.bodySmall.copyWith(
              color: FactoryColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  /// Submit Button
  Widget _buildLoginButton(LoginViewModel vm) {
    return MGDButton(
      text: 'Sign In',
      isLoading: vm.isLoading,
      height: FactoryDimens.buttonHeight,
      width: double.infinity,
      onPressed: () => _handleLogin(vm),
    );
  }

  Future<void> _handleLogin(LoginViewModel vm) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();

    final success = await vm.mockLogin(
      employeeId: _employeeIdController.text,
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: FactoryColors.statusCompletedText,
          content: Text(
            'Authenticated as ${vm.selectedRole.label} (${_employeeIdController.text.trim()})',
          ),
          duration: const Duration(seconds: 1),
        ),
      );

      Navigator.pushReplacementNamed(
        context,
        SupervisorDashboardScreen.routeName,
      );
    } else {
      final error = vm.errorMessage ?? 'Authentication failed. Please check credentials.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: FactoryColors.buttonRed,
          content: Text(error),
        ),
      );
    }
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Text(
          'Protected by Factory Access Control',
          style: FactoryTypography.caption.copyWith(
            color: FactoryColors.textMuted,
          ),
        ),
        const SizedBox(height: FactoryDimens.p4),
        Text(
          'Factory App v1.0.0',
          style: FactoryTypography.caption.copyWith(
            color: FactoryColors.textMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

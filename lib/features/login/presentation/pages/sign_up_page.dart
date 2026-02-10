import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../providers/sign_up_provider.dart';

class SignUpPage extends ConsumerStatefulWidget {
  const SignUpPage({super.key});

  @override
  ConsumerState<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  final Color _primaryRed = const Color(0xFFB91C1C);

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSignUp() async {
    if (_formKey.currentState!.validate()) {
      final success = await ref
          .read(signUpControllerProvider.notifier)
          .signUp(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
            username: _usernameController.text.trim(),
            fullName: _nameController.text.trim(),
          );

      if (success && mounted) {
        // Success SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: _primaryRed,
            content: const Text(
              'Đăng ký tài khoản thành công! Đang thiết lập âm nhạc cho bạn...',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
        // Navigate to Home
        context.go('/home');
      } else if (mounted) {
        // Error SnackBar
        final error = ref.read(signUpControllerProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text(
              error?.toString() ?? 'Đăng ký thất bại, vui lòng thử lại',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final signUpState = ref.watch(signUpControllerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFB91C1C),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF400503), Colors.black],
            stops: [0.0, 0.3],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10.h),
                  // Logo Sonus
                  Center(
                    child: SvgPicture.asset(
                      'assets/logo/logo_sonus_no_background_red_text.svg',
                      height: 100.h,
                    ),
                  ),
                  SizedBox(height: 32.h),
                  Text(
                    "Tạo tài khoản",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32.sp,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    "Gia nhập gia đình Sonus Music ngay hôm nay!",
                    style: TextStyle(color: Colors.white70, fontSize: 14.sp),
                  ),
                  SizedBox(height: 32.h),

                  // Display Name field
                  _buildFieldTitle("Tên hiển thị"),
                  _buildTextField(
                    controller: _nameController,
                    hintText: "VD: Nguyễn Văn A",
                    icon: Icons.person_outline,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập tên hiển thị';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20.h),

                  // Username field
                  _buildFieldTitle("Username"),
                  _buildTextField(
                    controller: _usernameController,
                    hintText: "VD: sonus_user01",
                    icon: Icons.alternate_email,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập username';
                      }
                      if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
                        return 'Chỉ chứa chữ cái, số và dấu gạch dưới';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20.h),

                  // Email field
                  _buildFieldTitle("Email"),
                  _buildTextField(
                    controller: _emailController,
                    hintText: "example@gmail.com",
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập email';
                      }
                      if (!RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,10}$',
                      ).hasMatch(value)) {
                        return 'Định dạng email không hợp lệ';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20.h),

                  // Password field
                  _buildFieldTitle("Mật khẩu"),
                  _buildTextField(
                    controller: _passwordController,
                    hintText: "••••••••",
                    icon: Icons.lock_outline,
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.white70,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập mật khẩu';
                      }
                      if (value.length < 8) {
                        return 'Mật khẩu phải có ít nhất 8 ký tự';
                      }
                      if (!RegExp(
                        r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$',
                      ).hasMatch(value)) {
                        return 'Phải bao gồm cả chữ và số';
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: 48.h),

                  // Sign Up Button
                  SizedBox(
                    width: double.infinity,
                    height: 56.h,
                    child: ElevatedButton(
                      onPressed: signUpState.isLoading ? null : _handleSignUp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB91C1C),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28.r),
                        ),
                        elevation: 8,
                        shadowColor: const Color(0xFFB91C1C).withOpacity(0.5),
                      ),
                      child: signUpState.isLoading
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            )
                          : Text(
                              "ĐĂNG KÝ",
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                    ),
                  ),

                  // Error display
                  if (signUpState.hasError)
                    Padding(
                      padding: EdgeInsets.only(top: 16.h),
                      child: Center(
                        child: Text(
                          signUpState.error.toString(),
                          style: const TextStyle(color: Colors.redAccent),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),

                  SizedBox(height: 32.h),
                  // Footer
                  Center(
                    child: GestureDetector(
                      onTap: () => context.go('/login'),
                      child: RichText(
                        text: TextSpan(
                          text: 'Đã có tài khoản? ',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14.sp,
                          ),
                          children: [
                            TextSpan(
                              text: 'Đăng nhập ngay',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h, left: 4.w),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white.withOpacity(0.9),
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    String? Function(String?)? validator,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
  }) {
    return Focus(
      onFocusChange: (hasFocus) => setState(() {}),
      child: Builder(
        builder: (context) {
          final hasFocus = Focus.of(context).hasFocus;
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.r),
              boxShadow: hasFocus
                  ? [
                      BoxShadow(
                        color: const Color(0xFFB91C1C).withOpacity(0.2),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: TextFormField(
              controller: controller,
              validator: validator,
              obscureText: obscureText,
              keyboardType: keyboardType,
              style: const TextStyle(color: Colors.white),
              cursorColor: const Color(0xFFB91C1C),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(color: Colors.white30, fontSize: 14.sp),
                prefixIcon: Icon(icon, color: Colors.white70, size: 22.r),
                suffixIcon: suffixIcon,
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                contentPadding: EdgeInsets.symmetric(
                  vertical: 20.h,
                  horizontal: 20.w,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.r),
                  borderSide: BorderSide(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.r),
                  borderSide: const BorderSide(
                    color: Color(0xFFB91C1C),
                    width: 1.5,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.r),
                  borderSide: const BorderSide(
                    color: Colors.redAccent,
                    width: 1,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.r),
                  borderSide: const BorderSide(
                    color: Colors.redAccent,
                    width: 2,
                  ),
                ),
                errorStyle: const TextStyle(color: Colors.redAccent),
              ),
            ),
          );
        },
      ),
    );
  }
}

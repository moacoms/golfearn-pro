import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_controller.dart';
import '../widgets/auth_form_field.dart';
import '../widgets/auth_button.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLessonPro = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        title: Text(
          '회원가입',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 20.h),
                
                // 회원 유형 선택
                _buildUserTypeSelector(),
                SizedBox(height: 30.h),
                
                // 이름 입력
                AuthFormField(
                  controller: _fullNameController,
                  label: '이름',
                  hintText: '실명을 입력하세요',
                  validator: _validateName,
                ),
                SizedBox(height: 20.h),
                
                // 이메일 입력
                AuthFormField(
                  controller: _emailController,
                  label: '이메일',
                  hintText: 'example@golfearn.com',
                  keyboardType: TextInputType.emailAddress,
                  validator: _validateEmail,
                ),
                SizedBox(height: 20.h),
                
                // 전화번호 입력
                AuthFormField(
                  controller: _phoneController,
                  label: '전화번호',
                  hintText: '010-1234-5678',
                  keyboardType: TextInputType.phone,
                  validator: _validatePhone,
                ),
                SizedBox(height: 20.h),
                
                // 비밀번호 입력
                AuthFormField(
                  controller: _passwordController,
                  label: '비밀번호',
                  hintText: '6자 이상 입력하세요',
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                    icon: Icon(
                      _obscurePassword ? Icons.visibility : Icons.visibility_off,
                      color: Colors.grey[600],
                    ),
                  ),
                  validator: _validatePassword,
                ),
                SizedBox(height: 20.h),
                
                // 비밀번호 확인 입력
                AuthFormField(
                  controller: _confirmPasswordController,
                  label: '비밀번호 확인',
                  hintText: '비밀번호를 다시 입력하세요',
                  obscureText: _obscureConfirmPassword,
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                    icon: Icon(
                      _obscureConfirmPassword 
                          ? Icons.visibility 
                          : Icons.visibility_off,
                      color: Colors.grey[600],
                    ),
                  ),
                  validator: _validateConfirmPassword,
                ),
                SizedBox(height: 40.h),
                
                // 회원가입 버튼
                AuthButton(
                  onPressed: authState.isLoading ? null : _handleRegister,
                  isLoading: authState.isLoading,
                  text: '회원가입',
                ),
                SizedBox(height: 20.h),
                
                // 로그인 링크
                _buildLoginLink(),
                SizedBox(height: 40.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '회원 유형',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 12.h),
        
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _isLessonPro = false),
                child: Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: !_isLessonPro 
                        ? const Color(0xFF10B981).withOpacity(0.1)
                        : Colors.grey[50],
                    border: Border.all(
                      color: !_isLessonPro 
                          ? const Color(0xFF10B981)
                          : Colors.grey[300]!,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.school,
                        size: 32.w,
                        color: !_isLessonPro 
                            ? const Color(0xFF10B981)
                            : Colors.grey[600],
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        '학생',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: !_isLessonPro 
                              ? const Color(0xFF10B981)
                              : Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '레슨을 받는 학생',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _isLessonPro = true),
                child: Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: _isLessonPro 
                        ? const Color(0xFF10B981).withOpacity(0.1)
                        : Colors.grey[50],
                    border: Border.all(
                      color: _isLessonPro 
                          ? const Color(0xFF10B981)
                          : Colors.grey[300]!,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.golf_course,
                        size: 32.w,
                        color: _isLessonPro 
                            ? const Color(0xFF10B981)
                            : Colors.grey[600],
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        '레슨프로',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: _isLessonPro 
                              ? const Color(0xFF10B981)
                              : Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '레슨을 제공하는 프로',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '이미 계정이 있으신가요? ',
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey[600],
          ),
        ),
        GestureDetector(
          onTap: () => context.pop(),
          child: Text(
            '로그인',
            style: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xFF10B981),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return '이름을 입력해주세요';
    }
    if (value.length < 2) {
      return '이름은 2자 이상이어야 합니다';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return '이메일을 입력해주세요';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return '올바른 이메일 형식을 입력해주세요';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return '전화번호를 입력해주세요';
    }
    if (!RegExp(r'^01[016789]-?\d{3,4}-?\d{4}$').hasMatch(value)) {
      return '올바른 전화번호 형식을 입력해주세요';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return '비밀번호를 입력해주세요';
    }
    if (value.length < 6) {
      return '비밀번호는 6자 이상이어야 합니다';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return '비밀번호 확인을 입력해주세요';
    }
    if (value != _passwordController.text) {
      return '비밀번호가 일치하지 않습니다';
    }
    return null;
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      // 기본 회원가입
      await ref.read(authControllerProvider.notifier).signUp(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            fullName: _fullNameController.text.trim(),
            phoneNumber: _phoneController.text.trim(),
          );

      // 레슨프로로 선택했다면 추가 등록
      if (_isLessonPro) {
        await ref.read(authControllerProvider.notifier).registerAsLessonPro(
              fullName: _fullNameController.text.trim(),
              phoneNumber: _phoneController.text.trim(),
            );
      }
      
      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      // 에러는 이미 ref.listen에서 처리됨
    }
  }
}
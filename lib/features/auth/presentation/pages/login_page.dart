import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_controller.dart';
import '../widgets/auth_form_field.dart';
import '../widgets/auth_button.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      if (next.error != null && 
          !next.error!.contains('missing or invalid authentication code')) {
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.disabled,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 60.h),
                
                // 로고 및 타이틀
                _buildHeader(),
                SizedBox(height: 60.h),
                
                // 이메일 입력
                AuthFormField(
                  controller: _emailController,
                  label: '이메일',
                  hintText: 'example@golfearn.com',
                  keyboardType: TextInputType.emailAddress,
                  validator: _validateEmail,
                ),
                SizedBox(height: 20.h),
                
                // 비밀번호 입력
                AuthFormField(
                  controller: _passwordController,
                  label: '비밀번호',
                  hintText: '비밀번호를 입력하세요',
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
                SizedBox(height: 32.h),
                
                // 로그인 버튼
                AuthButton(
                  onPressed: authState.isLoading ? null : _handleLogin,
                  isLoading: authState.isLoading,
                  text: '로그인',
                ),
                SizedBox(height: 16.h),
                
                // 비밀번호 찾기 링크
                TextButton(
                  onPressed: () => _showResetPasswordDialog(),
                  child: Text(
                    '비밀번호를 잊으셨나요?',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                SizedBox(height: 40.h),
                
                // 회원가입 링크
                _buildSignUpLink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // 로고 (추후 실제 로고로 교체)
        Container(
          width: 80.w,
          height: 80.w,
          decoration: BoxDecoration(
            color: const Color(0xFF10B981),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Icon(
            Icons.sports,
            size: 40.w,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 24.h),

        Text(
          'Golfearn',
          style: TextStyle(
            fontSize: 28.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 8.h),

        Text(
          '레슨프로를 위한 스마트 CRM',
          style: TextStyle(
            fontSize: 16.sp,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '계정이 없으신가요? ',
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey[600],
          ),
        ),
        GestureDetector(
          onTap: () => context.push('/register'),
          child: Text(
            '회원가입',
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

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return '이메일을 입력해주세요';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return '올바른 이메일 형식을 입력해주세요';
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

  void _showResetPasswordDialog() {
    final resetEmailController = TextEditingController();
    final resetFormKey = GlobalKey<FormState>();
    bool isSending = false;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
              title: Text(
                '비밀번호 재설정',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Form(
                key: resetFormKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '가입하신 이메일 주소를 입력하시면\n비밀번호 재설정 링크를 보내드립니다.',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 16.h),
                    AuthFormField(
                      controller: resetEmailController,
                      label: '이메일',
                      hintText: 'example@golfearn.com',
                      keyboardType: TextInputType.emailAddress,
                      enabled: !isSending,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '이메일을 입력해주세요';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                            .hasMatch(value)) {
                          return '올바른 이메일 형식을 입력해주세요';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSending
                      ? null
                      : () => Navigator.of(dialogContext).pop(),
                  child: Text(
                    '취소',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                TextButton(
                  onPressed: isSending
                      ? null
                      : () async {
                          if (!resetFormKey.currentState!.validate()) return;

                          setDialogState(() => isSending = true);

                          try {
                            await ref
                                .read(authControllerProvider.notifier)
                                .resetPassword(
                                  email: resetEmailController.text.trim(),
                                );

                            if (mounted) {
                              Navigator.of(dialogContext).pop();
                              ScaffoldMessenger.of(this.context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '비밀번호 재설정 링크가 이메일로 발송되었습니다.',
                                  ),
                                  backgroundColor: const Color(0xFF10B981),
                                ),
                              );
                            }
                          } catch (e) {
                            setDialogState(() => isSending = false);
                            if (mounted) {
                              ScaffoldMessenger.of(this.context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    e.toString().replaceAll('Exception: ', ''),
                                  ),
                                  backgroundColor: Colors.red,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          }
                        },
                  child: isSending
                      ? SizedBox(
                          width: 16.w,
                          height: 16.w,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF10B981),
                          ),
                        )
                      : Text(
                          '발송',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: const Color(0xFF10B981),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await ref.read(authControllerProvider.notifier).signIn(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
      
      // 로그인 성공 시 자동으로 라우터가 홈으로 리다이렉트
      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        final msg = e.toString().replaceAll('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }
}
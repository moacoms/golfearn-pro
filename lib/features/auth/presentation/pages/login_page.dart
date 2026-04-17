import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_controller.dart';
import '../widgets/auth_form_field.dart';
import '../widgets/auth_button.dart';
import '../../../../core/theme/app_theme.dart';

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
                  maxLength: 254,
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
                  maxLength: 72,
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
                SizedBox(height: 24.h),

                // 구분선 ("또는")
                _buildDivider(),
                SizedBox(height: 20.h),

                // 카카오 로그인 버튼
                _KakaoLoginButton(
                  onPressed:
                      authState.isLoading ? null : _handleKakaoLogin,
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
        ClipRRect(
          borderRadius: BorderRadius.circular(20.r),
          child: Image.asset(
            'assets/icons/app_icon.png',
            width: 80.w,
            height: 80.w,
            fit: BoxFit.cover,
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
              color: AppTheme.primaryColor,
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
    if (value.length < 8) {
      return '비밀번호는 8자 이상이어야 합니다';
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
                      maxLength: 254,
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
                                  backgroundColor: AppTheme.primaryColor,
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
                            color: AppTheme.primaryColor,
                          ),
                        )
                      : Text(
                          '발송',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppTheme.primaryColor,
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

  Future<void> _handleKakaoLogin() async {
    try {
      await ref.read(authControllerProvider.notifier).signInWithKakao();
      // 성공 시 브라우저/Custom Tab이 열리고, 돌아오면 authStateChanges가
      // 세션을 방출함 → app_router 의 redirect 가 /home 으로 보냄.
      // 여기서는 특별히 할 일 없음.
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

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Text(
            '또는',
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.grey[500],
            ),
          ),
        ),
        Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
      ],
    );
  }
}

class _KakaoLoginButton extends StatelessWidget {
  const _KakaoLoginButton({required this.onPressed});

  final VoidCallback? onPressed;

  static const Color _kakaoYellow = Color(0xFFFEE500);
  static const Color _kakaoText = Color(0xFF191919);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52.h,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _kakaoYellow,
          foregroundColor: _kakaoText,
          disabledBackgroundColor: _kakaoYellow.withValues(alpha: 0.5),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble, size: 20.w, color: _kakaoText),
            SizedBox(width: 10.w),
            Text(
              '카카오로 시작하기',
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: _kakaoText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
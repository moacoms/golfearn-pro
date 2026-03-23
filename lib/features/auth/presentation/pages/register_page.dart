import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
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

  // FocusNode로 탭 순서 제어
  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();

  String? _emailError;
  bool _checkingEmail = false;

  @override
  void initState() {
    super.initState();
    // 이메일 포커스 해제 시 중복 체크
    _emailFocus.addListener(() {
      if (!_emailFocus.hasFocus && _emailController.text.trim().isNotEmpty) {
        _checkEmailExists(_emailController.text.trim());
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    super.dispose();
  }

  Future<void> _checkEmailExists(String email) async {
    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email)) {
      return; // 형식이 틀리면 체크하지 않음
    }

    setState(() {
      _checkingEmail = true;
      _emailError = null;
    });

    try {
      // 잘못된 비밀번호로 로그인 시도하여 이메일 존재 여부 확인
      // 존재하는 이메일: "Invalid login credentials" 에러
      // 존재하지 않는 이메일: "Invalid login credentials" 에러 (동일하게 반환)
      // 대안: profiles 테이블에서 직접 확인은 email 컬럼이 없으므로 불가
      // 가입 시 자연스럽게 처리되도록 여기서는 기본 검증만 수행
      setState(() => _emailError = null);
    } catch (e) {
      // 에러 발생 시 무시
    } finally {
      setState(() => _checkingEmail = false);
    }
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
                ExcludeFocus(
                  child: _buildUserTypeSelector(),
                ),
                SizedBox(height: 30.h),

                // 이름 입력
                AuthFormField(
                  controller: _fullNameController,
                  label: '이름',
                  hintText: '실명을 입력하세요',
                  validator: _validateName,
                  focusNode: _nameFocus,
                ),
                SizedBox(height: 20.h),

                // 이메일 입력
                AuthFormField(
                  controller: _emailController,
                  label: '이메일',
                  hintText: 'example@golfearn.com',
                  keyboardType: TextInputType.emailAddress,
                  validator: _validateEmail,
                  focusNode: _emailFocus,
                  errorText: _emailError,
                  suffixIcon: _checkingEmail
                      ? ExcludeFocus(
                          child: Padding(
                            padding: EdgeInsets.all(12.w),
                            child: SizedBox(
                              width: 20.w,
                              height: 20.w,
                              child: const CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        )
                      : _emailError != null
                          ? ExcludeFocus(child: Icon(Icons.error, color: Colors.red, size: 20.w))
                          : null,
                ),
                SizedBox(height: 20.h),

                // 전화번호 입력
                AuthFormField(
                  controller: _phoneController,
                  label: '전화번호',
                  hintText: '010-1234-5678',
                  keyboardType: TextInputType.phone,
                  validator: _validatePhone,
                  focusNode: _phoneFocus,
                ),
                SizedBox(height: 20.h),

                // 비밀번호 입력
                AuthFormField(
                  controller: _passwordController,
                  label: '비밀번호',
                  hintText: '6자 이상 입력하세요',
                  obscureText: _obscurePassword,
                  focusNode: _passwordFocus,
                  suffixIcon: ExcludeFocus(
                    child: IconButton(
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
                  focusNode: _confirmPasswordFocus,
                  textInputAction: TextInputAction.done,
                  suffixIcon: ExcludeFocus(
                    child: IconButton(
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
                        Icons.sports,
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
    final trimmed = value.trim();
    if (!trimmed.contains('@')) {
      return '@ 기호를 포함해야 합니다';
    }
    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(trimmed)) {
      return '올바른 이메일 형식을 입력해주세요 (예: example@gmail.com)';
    }
    final domain = trimmed.split('@').last.toLowerCase();
    final validDomains = ['gmail.com', 'naver.com', 'daum.net', 'hanmail.net', 'kakao.com', 'nate.com', 'yahoo.com', 'hotmail.com', 'outlook.com', 'icloud.com', 'moacoms.com'];
    if (!domain.contains('.')) {
      return '올바른 도메인을 입력해주세요';
    }
    // 도메인이 유효한 형식인지 추가 확인
    if (domain.length < 4) {
      return '올바른 이메일 도메인을 입력해주세요';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return '전화번호를 입력해주세요';
    }
    // 숫자와 하이픈만 남기기
    final digitsOnly = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.length < 10 || digitsOnly.length > 11) {
      return '전화번호는 10~11자리여야 합니다';
    }
    if (!digitsOnly.startsWith('01')) {
      return '휴대폰 번호는 01로 시작해야 합니다';
    }
    if (!RegExp(r'^01[016789]\d{7,8}$').hasMatch(digitsOnly)) {
      return '올바른 전화번호 형식을 입력해주세요 (예: 010-1234-5678)';
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

    // 이메일 중복 에러가 있으면 가입 차단
    if (_emailError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_emailError!),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final email = _emailController.text.trim();
    final phone = _phoneController.text.replaceAll(RegExp(r'[^0-9]'), '');

    // 이메일 중복 체크
    try {
      // Supabase에 동일 이메일로 로그인 시도하여 존재 여부 확인
      // signInWithPassword는 실패하지만 에러 메시지로 구분 가능
      // 대신 profiles 테이블에서 전화번호 중복 확인
      final phoneCheck = await Supabase.instance.client
          .from('profiles')
          .select('id')
          .eq('pro_phone', phone)
          .maybeSingle();

      if (phoneCheck != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('이미 등록된 전화번호입니다.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
    } catch (e) {
      // 체크 실패 시 무시하고 진행
      print('중복 체크 실패: $e');
    }

    try {
      // 기본 회원가입
      await ref.read(authControllerProvider.notifier).signUp(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            fullName: _fullNameController.text.trim(),
            phoneNumber: phone,
          );

      // 세션이 있는지 확인 (이메일 인증이 필요한 경우 세션이 없을 수 있음)
      final currentAuthState = ref.read(authControllerProvider);
      if (currentAuthState.user == null) {
        // 이메일 인증 필요
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('회원가입이 완료되었습니다. 이메일을 확인해주세요.'),
              backgroundColor: Color(0xFF10B981),
              duration: Duration(seconds: 3),
            ),
          );
          context.go('/login');
        }
        return;
      }

      // 레슨프로로 선택했다면 추가 등록
      if (_isLessonPro) {
        try {
          await ref.read(authControllerProvider.notifier).registerAsLessonPro(
                fullName: _fullNameController.text.trim(),
                phoneNumber: phone,
              );
        } catch (e) {
          print('레슨프로 등록 실패 (나중에 재시도 가능): $e');
        }
      }

      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      // 에러 메시지 사용자 친화적으로 표시
      if (mounted) {
        final errorMsg = e.toString();
        String displayMsg;
        if (errorMsg.contains('Database error saving new user')) {
          displayMsg = '이미 가입된 이메일이거나 서버 오류입니다. 다시 시도해주세요.';
        } else if (errorMsg.contains('already registered') || errorMsg.contains('이미 가입된')) {
          displayMsg = '이미 가입된 이메일입니다. 로그인 해주세요.';
        } else {
          displayMsg = errorMsg.replaceAll('Exception: ', '');
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(displayMsg),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
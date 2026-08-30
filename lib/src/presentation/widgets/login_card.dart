import 'package:dinari/src/core/utils/constants/app_images.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AuthCard extends StatefulWidget {
  const AuthCard({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.emailFocusNode,
    required this.passwordFocusNode,
    required this.isRegister,
    this.nameController,
    this.phoneController,
    this.nameFocusNode,
    this.phoneFocusNode,
  });

  final TextEditingController? nameController;
  final TextEditingController? phoneController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final FocusNode emailFocusNode;
  final FocusNode passwordFocusNode;
  final FocusNode? nameFocusNode;
  final FocusNode? phoneFocusNode;
  final bool isRegister;

  @override
  State<AuthCard> createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.white,
      child: Padding(
        padding: REdgeInsets.all(6.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            if (widget.isRegister) ...[
              // Name Field
              Padding(
                padding: REdgeInsets.symmetric(horizontal: 8),
                child: TextFormField(
                  controller: widget.nameController,
                  focusNode: widget.nameFocusNode,
                  decoration: InputDecoration(
                    icon: Icon(
                      Icons.person,
                      color: const Color(0xFF0052B4),
                      size: 24.r,
                    ),
                    hintText: 'nom et prénom',
                    hintMaxLines: 1,
                    hintStyle: const TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 15.0),
                  ),
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'name_required';
                    }
                    final RegExp nameRegExp = RegExp(
                      r'^[\u0621-\u064A\u0660-\u0669a-zA-Z\s]+$',
                    );
                    if (!nameRegExp.hasMatch(value)) {
                      return 'invalid_full_name';
                    }
                    return null;
                  },
                ),
              ),
              4.verticalSpace,
              const Divider(height: 1.0, color: Colors.grey),
              4.verticalSpace,
            ],
            // Email Field
            Padding(
              padding: REdgeInsets.symmetric(horizontal: 8),
              child: TextFormField(
                controller: widget.emailController,
                focusNode: widget.emailFocusNode,
                decoration: InputDecoration(
                  icon: Icon(
                    Icons.email_outlined,
                    color: const Color(0xFF0052B4),
                    size: 24.r,
                  ),
                  hintText: 'e-mail',
                  hintMaxLines: 1,
                  hintStyle: const TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15.0),
                ),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'please_enter_email';
                  }
                  if (!RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  ).hasMatch(value)) {
                    return 'enter_valid_email';
                  }
                  return null;
                },
              ),
            ),
            4.verticalSpace,
            const Divider(height: 1.0, color: Colors.grey),
            4.verticalSpace,

            // Phone Field (Modified)
            if (widget.isRegister) ...[
              Padding(
                padding: REdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    // Flag image
                    Image.asset(
                      AppImages.instance.algeriaFlag,
                      width: 24.r,
                      height: 24.r,
                    ),
                    SizedBox(width: 8.w),
                    // Country code
                    Text(
                      '+(213)',
                      style: TextStyle(
                        color: const Color.fromRGBO(0, 0, 0, 1),
                        fontSize: 14.sp,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    // Phone number text field
                    Expanded(
                      child: TextFormField(
                        controller: widget.phoneController,
                        focusNode: widget.phoneFocusNode,
                        decoration: InputDecoration(
                          hintText: '777-77-77-77',
                          hintMaxLines: 1,
                          hintStyle: const TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                          contentPadding: REdgeInsets.symmetric(vertical: 15.0),
                        ),
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'phone_required';
                          }
                          final regex = RegExp(r'^(?:\+213|0)(5|6|7)[0-9]{8}$');
                          if (!regex.hasMatch(value)) {
                            return 'invalid_phone_number';
                          }

                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ),
              4.verticalSpace,
              const Divider(height: 1.0, color: Colors.grey),
              4.verticalSpace,
            ],

            // Password Field
            Padding(
              padding: REdgeInsets.symmetric(horizontal: 8),
              child: TextFormField(
                controller: widget.passwordController,
                focusNode: widget.passwordFocusNode,
                decoration: InputDecoration(
                  icon: Icon(
                    Icons.lock_outlined,
                    color: const Color(0xFF0052B4),
                    size: 24.r,
                  ),
                  hintText: '*******',
                  hintMaxLines: 1,
                  hintStyle: const TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15.0),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.black26,
                      size: 24.r,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                keyboardType: TextInputType.visiblePassword,
                textInputAction: TextInputAction.done,
                obscureText: _obscurePassword,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'please_enter_password';
                  }
                  if (value.length < 6) {
                    return 'minimum_6_characters';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:country_picker/country_picker.dart';

// class AuthCard extends StatefulWidget {
//   const AuthCard({
//     super.key,
//     required this.emailController,
//     required this.passwordController,
//     required this.emailFocusNode,
//     required this.passwordFocusNode,
//     required this.isRegister,
//     this.nameController,
//     this.phoneController,
//     this.nameFocusNode,
//     this.phoneFocusNode,
//   });
//   final TextEditingController? nameController;
//   final TextEditingController? phoneController;
//   final TextEditingController emailController;
//   final TextEditingController passwordController;
//   final FocusNode emailFocusNode;
//   final FocusNode passwordFocusNode;
//   final FocusNode? nameFocusNode;
//   final FocusNode? phoneFocusNode;
//   final bool isRegister;

//   @override
//   State<AuthCard> createState() => _AuthCardState();
// }

// class _AuthCardState extends State<AuthCard> {
//   bool _obscurePassword = true;
//   Country _selectedCountry = Country(
//     phoneCode: "213",
//     countryCode: "DZ",
//     e164Sc: 0,
//     geographic: true,
//     level: 1,
//     name: "Algeria",
//     example: "123456789",
//     displayName: "Algeria (DZ) [+213]",
//     displayNameNoCountryCode: "Algeria (DZ)",
//     e164Key: "",
//   );

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: const EdgeInsets.all(16),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//       color: Colors.white,
//       child: Padding(
//         padding: REdgeInsets.all(6.0),
//         child: Column(
//           mainAxisSize: MainAxisSize.max,
//           children: [
//             if (widget.isRegister) ...[
//               Padding(
//                 padding: REdgeInsets.symmetric(horizontal: 8),
//                 child: TextFormField(
//                   controller: widget.nameController,
//                   focusNode: widget.nameFocusNode,
//                   decoration: InputDecoration(
//                     icon: Icon(
//                       Icons.person,
//                       color: const Color(0xFF0052B4),
//                       size: 24.r,
//                     ),
//                     hintText: 'habib hamouti',
//                     hintMaxLines: 1,
//                     hintStyle: const TextStyle(color: Colors.grey),
//                     border: InputBorder.none,
//                     contentPadding: const EdgeInsets.symmetric(vertical: 15.0),
//                   ),
//                   keyboardType: TextInputType.text,
//                   textInputAction: TextInputAction.next,
//                   validator: (value) {
//                     if (value!.isEmpty) {
//                       return 'name_required';
//                     }
//                     final RegExp nameRegExp = RegExp(
//                       r'^[\u0621-\u064A\u0660-\u0669a-zA-Z\s]+$',
//                     );
//                     if (!nameRegExp.hasMatch(value)) {
//                       return 'invalid_full_name';
//                     }
//                     return null;
//                   },
//                 ),
//               ),
//               4.verticalSpace,
//               const Divider(height: 1.0, color: Colors.grey),
//               4.verticalSpace,
//             ],
//             Padding(
//               padding: REdgeInsets.symmetric(horizontal: 8),
//               child: TextFormField(
//                 controller: widget.emailController,
//                 focusNode: widget.emailFocusNode,
//                 decoration: InputDecoration(
//                   icon: Icon(
//                     Icons.email_outlined,
//                     color: const Color(0xFF0052B4),
//                     size: 24.r,
//                   ),
//                   hintText: 'habib@gmail.com',
//                   hintMaxLines: 1,
//                   hintStyle: const TextStyle(color: Colors.grey),
//                   border: InputBorder.none,
//                   contentPadding: const EdgeInsets.symmetric(vertical: 15.0),
//                 ),
//                 keyboardType: TextInputType.emailAddress,
//                 textInputAction: TextInputAction.next,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'please_enter_email';
//                   }
//                   if (!RegExp(
//                     r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
//                   ).hasMatch(value)) {
//                     return 'enter_valid_email';
//                   }
//                   return null;
//                 },
//               ),
//             ),
//             4.verticalSpace,
//             const Divider(height: 1.0, color: Colors.grey),
//             4.verticalSpace,
//             if (widget.isRegister) ...[
//               Padding(
//                 padding: REdgeInsets.symmetric(horizontal: 8),
//                 child: TextFormField(
//                   controller: widget.phoneController,
//                   focusNode: widget.phoneFocusNode,
//                   decoration: InputDecoration(
//                     // icon: const Icon(
//                     //   Icons.phone,
//                     //   color: Color(0xFF0052B4),
//                     // ),
//                     prefixIcon: Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
//                       margin: const EdgeInsets.only(right: 8.0),
//                       child: InkWell(
//                         onTap: () {
//                           showCountryPicker(
//                             context: context,
//                             showPhoneCode: true,
//                             onSelect: (Country country) {
//                               setState(() {
//                                 _selectedCountry = country;
//                               });
//                             },
//                           );
//                         },
//                         child: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Text(
//                               _selectedCountry.flagEmoji,
//                               style: TextStyle(fontSize: 20.sp),
//                             ),
//                             Icon(
//                               Icons.arrow_drop_down,
//                               color: Colors.grey,
//                               size: 24.r,
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     hintText: '777-95-13-64',
//                     hintMaxLines: 1,
//                     hintStyle: const TextStyle(color: Colors.grey),
//                     border: InputBorder.none,
//                     contentPadding: const EdgeInsets.symmetric(vertical: 15.0),
//                   ),
//                   keyboardType: TextInputType.phone,
//                   textInputAction: TextInputAction.next,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'please_enter_phone';
//                     }
//                     // Add your phone validation logic here
//                     return null;
//                   },
//                 ),
//               ),
//               4.verticalSpace,
//               const Divider(height: 1.0, color: Colors.grey),
//               4.verticalSpace,
//             ],
//             Padding(
//               padding: REdgeInsets.symmetric(horizontal: 8),
//               child: TextFormField(
//                 controller: widget.passwordController,
//                 focusNode: widget.passwordFocusNode,
//                 decoration: InputDecoration(
//                   icon: Icon(
//                     Icons.lock_outlined,
//                     color: const Color(0xFF0052B4),
//                     size: 24.r,
//                   ),
//                   hintText: '*******',
//                   hintMaxLines: 1,
//                   hintStyle: const TextStyle(color: Colors.grey),
//                   border: InputBorder.none,
//                   contentPadding: const EdgeInsets.symmetric(vertical: 15.0),
//                   suffixIcon: IconButton(
//                     icon: Icon(
//                       _obscurePassword ? Icons.visibility_off : Icons.visibility,
//                       color: Colors.black26,
//                       size: 24.r,
//                     ),
//                     onPressed: () {
//                       setState(() {
//                         _obscurePassword = !_obscurePassword;
//                       });
//                     },
//                   ),
//                 ),
//                 keyboardType: TextInputType.visiblePassword,
//                 textInputAction: TextInputAction.done,
//                 obscureText: _obscurePassword,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'please_enter_password';
//                   }
//                   if (value.length < 6) return 'minimum_6_characters';
//                   return null;
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

// class AuthCard extends StatefulWidget {
//   const AuthCard({
//     super.key,
//     required this.emailController,
//     required this.passwordController,
//     required this.emailFocusNode,
//     required this.passwordFocusNode,
//     required this.isRegister,
//     this.nameController,
//     this.phoneController,
//     this.nameFocusNode,
//     this.phoneFocusNode,
//   });
//   final TextEditingController? nameController;
//   final TextEditingController? phoneController;
//   final TextEditingController emailController;
//   final TextEditingController passwordController;
//   final FocusNode emailFocusNode;
//   final FocusNode passwordFocusNode;
//   final FocusNode? nameFocusNode;
//   final FocusNode? phoneFocusNode;
//   final bool isRegister;

//   @override
//   State<AuthCard> createState() => _AuthCardState();
// }

// class _AuthCardState extends State<AuthCard> {
//   bool _obscurePassword = true;

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: const EdgeInsets.all(16),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),

//       color: Colors.white,
//       child: Padding(
//         padding: REdgeInsets.all(6.0),
//         child: Column(
//           mainAxisSize: MainAxisSize.max,
//           children: [
//             if (widget.isRegister) ...[
//               Padding(
//                 padding: REdgeInsets.symmetric(horizontal: 8),
//                 child: TextFormField(
//                   controller: widget.nameController,
//                   focusNode: widget.nameFocusNode,
//                   decoration: InputDecoration(
//                     icon: Icon(
//                       Icons.person,
//                       color: Color(0xFF0052B4),
//                       size: 24.r,
//                     ),
//                     hintText: 'habib hamouti',
//                     hintMaxLines: 1,
//                     hintStyle: TextStyle(color: Colors.grey),
//                     border: InputBorder.none,

//                     contentPadding: EdgeInsets.symmetric(vertical: 15.0),
//                   ),
//                   keyboardType: TextInputType.text,
//                   textInputAction: TextInputAction.next,
//                   validator: (value) {
//                     if (value!.isEmpty) {
//                       return 'name_required';
//                     }
//                     final RegExp nameRegExp = RegExp(
//                       r'^[\u0621-\u064A\u0660-\u0669a-zA-Z\s]+$',
//                     );
//                     if (!nameRegExp.hasMatch(value)) {
//                       return 'invalid_full_name';
//                     }
//                     return null;
//                   },
//                 ),
//               ),

//               4.verticalSpace,
//               const Divider(height: 1.0, color: Colors.grey),
//               4.verticalSpace,
//             ],
//             Padding(
//               padding: REdgeInsets.symmetric(horizontal: 8),
//               child: TextFormField(
//                 controller: widget.emailController,
//                 focusNode: widget.emailFocusNode,
//                 decoration: InputDecoration(
//                   icon: Icon(
//                     Icons.email_outlined,
//                     color: Color(0xFF0052B4),
//                     size: 24.r,
//                   ),
//                   hintText: 'habib@gmail.com',
//                   hintMaxLines: 1,
//                   hintStyle: TextStyle(color: Colors.grey),
//                   border: InputBorder.none,

//                   contentPadding: EdgeInsets.symmetric(vertical: 15.0),
//                 ),
//                 keyboardType: TextInputType.emailAddress,
//                 textInputAction: TextInputAction.next,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'please_enter_email';
//                   }
//                   if (!RegExp(
//                     r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
//                   ).hasMatch(value)) {
//                     return 'enter_valid_email';
//                   }
//                   return null;
//                 },
//               ),
//             ),

//             4.verticalSpace,
//             const Divider(height: 1.0, color: Colors.grey),
//             4.verticalSpace,
//             if (widget.isRegister) ...[
//               Padding(
//                 padding: REdgeInsets.symmetric(horizontal: 8),
//                 child: TextFormField(
//                   controller: widget.phoneController,
//                   focusNode: widget.phoneFocusNode,
//                   decoration: InputDecoration(
//                     icon: Icon(
//                       Icons.phone,
//                       color: Color(0xFF0052B4),
//                       size: 24.r,
//                     ),
//                     hintText: '+(213) 777-95-13-64',
//                     hintMaxLines: 1,
//                     hintStyle: TextStyle(color: Colors.grey),
//                     border: InputBorder.none,

//                     contentPadding: EdgeInsets.symmetric(vertical: 15.0),
//                   ),
//                   keyboardType: TextInputType.phone,
//                   textInputAction: TextInputAction.next,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'please_enter_email';
//                     }
//                     if (!RegExp(
//                       r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
//                     ).hasMatch(value)) {
//                       return 'enter_valid_email';
//                     }
//                     return null;
//                   },
//                 ),
//               ),

//               4.verticalSpace,
//               const Divider(height: 1.0, color: Colors.grey),
//               4.verticalSpace,
//             ],

//             // Password text field
//             Padding(
//               padding: REdgeInsets.symmetric(horizontal: 8),
//               child: TextFormField(
//                 controller: widget.passwordController,
//                 focusNode: widget.passwordFocusNode,
//                 decoration: InputDecoration(
//                   icon: Icon(
//                     Icons.lock_outlined,
//                     color: Color(0xFF0052B4),
//                     size: 24.r,
//                   ),
//                   hintText: '*******',
//                   hintMaxLines: 1,
//                   hintStyle: TextStyle(
//                     color: Colors.grey,
//                   ), // Optional: for better hint styling
//                   border: InputBorder.none,
//                   contentPadding: EdgeInsets.symmetric(
//                     vertical: 15.0,
//                   ), // Adjust vertical padding
//                   suffixIcon: IconButton(
//                     icon: Icon(
//                       _obscurePassword
//                           ? Icons.visibility_off
//                           : Icons.visibility,
//                       color: Colors.black26,
//                       size: 24.r,
//                     ),
//                     onPressed: () {
//                       setState(() {
//                         _obscurePassword = !_obscurePassword;
//                       });
//                     },
//                   ),
//                 ),
//                 keyboardType: TextInputType.visiblePassword,
//                 textInputAction: TextInputAction.done,
//                 obscureText: _obscurePassword,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'please_enter_password';
//                   }
//                   if (value.length < 6) return 'minimum_6_characters';
//                   return null;
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

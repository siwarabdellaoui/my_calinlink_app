import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/providers/user_provider.dart';

export 'profile_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;
  late TextEditingController _babyNameController;
  late TextEditingController _babyDobController;

  int _selectedGender = 0; // 0 = Fille, 1 = Garçon
  String? _base64Image;

  @override
  void initState() {
    super.initState();

    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _phoneController = TextEditingController();
    _babyNameController = TextEditingController();
    _babyDobController = TextEditingController(text: '04/10/2024');

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(userProfileProvider.notifier).fetchProfile();
      _syncControllersWithProfile(ref.read(userProfileProvider));
    });

    ref.listenManual<UserProfile>(
      userProfileProvider,
      (previous, next) {
        _syncControllersWithProfile(next);
      },
    );
  }

  void _syncControllersWithProfile(UserProfile profile) {
    _firstNameController.text = profile.firstName;
    _lastNameController.text = profile.lastName;
    _phoneController.text = profile.phone;
    _babyNameController.text = profile.babyName;
    if (profile.babyBirthDate.isNotEmpty) {
      if (profile.babyBirthDate.length > 10) {
        // Simple formatDate if it's an ISO String from MongoDB
        final parts = profile.babyBirthDate.substring(0, 10).split('-');
        if (parts.length == 3) {
          _babyDobController.text = '${parts[2]}/${parts[1]}/${parts[0]}';
        } else {
          _babyDobController.text = profile.babyBirthDate.substring(0, 10);
        }
      } else {
        _babyDobController.text = profile.babyBirthDate;
      }
    }
    _selectedGender = profile.babyGender == 'M' ? 1 : 0;
    _base64Image = profile.avatar.isNotEmpty ? profile.avatar : null;

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _babyNameController.dispose();
    _babyDobController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(
          source: source, imageQuality: 50, maxWidth: 500);
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _base64Image = 'data:image/jpeg;base64,${base64Encode(bytes)}';
        });
      }
    } catch (e) {
      print("Erreur image picker: $e");
    }
  }

  void _showImagePicker() {
    showModalBottomSheet(
        context: context,
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (context) {
          return SafeArea(
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title:  Text('Galerie'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: Text('Appareil photo'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.05),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Mon profil',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: context.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: _showImagePicker,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  AppColors.primary.withValues(alpha: 0.2),
                                  AppColors.primary.withValues(alpha: 0.05),
                                ],
                              ),
                              image: _base64Image != null &&
                                      _base64Image!.contains(',')
                                  ? DecorationImage(
                                      image: MemoryImage(base64Decode(
                                          _base64Image!.split(',').last)),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: _base64Image == null
                                ? Center(
                                    child: Text(
                                      '${_firstNameController.text.isNotEmpty ? _firstNameController.text[0] : ''}${_lastNameController.text.isNotEmpty ? _lastNameController.text[0] : ''}'
                                          .toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: AppColors.secondary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt_rounded,
                                color: Colors.white,
                                size: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Modifier la photo',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: context.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildInputLabel('PRÉNOM'),
                    _buildTextField(
                        _firstNameController, 'Entrez votre prénom'),
                    const SizedBox(height: 20),
                    _buildInputLabel('NOM DE FAMILLE'),
                    _buildTextField(
                        _lastNameController, 'Entrez votre nom de famille'),
                    const SizedBox(height: 20),
                    _buildInputLabel('NUMÉRO DE TÉLÉPHONE'),
                    _buildTextField(
                      _phoneController,
                      'Entrez votre numéro',
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.child_care_rounded,
                            color: AppColors.primary,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Mon bébé',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: context.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildInputLabel('PRÉNOM DU BÉBÉ'),
                    _buildTextField(_babyNameController, 'Entrez le prénom'),
                    const SizedBox(height: 20),
                    _buildInputLabel('DATE DE NAISSANCE'),
                    _buildTextField(
                      _babyDobController,
                      'dd/mm/yyyy',
                      readOnly: true,
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (pickedDate != null) {
                          String formattedDate =
                              "${pickedDate.day.toString().padLeft(2, '0')}/${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.year}";
                          _babyDobController.text = formattedDate;
                        }
                      },
                      suffixIcon: Icon(
                        Icons.calendar_month_rounded,
                        color: context.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildInputLabel('SEXE'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildGenderButton(
                              0, 'Fille', Icons.female_rounded),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildGenderButton(
                              1, 'Garçon', Icons.male_rounded),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          // Format simple envoi de date 'yyyy-MM-dd' pour que MongoDB le parse bien
                          String formattedDate = _babyDobController.text;
                          if (formattedDate.contains('/')) {
                            final p = formattedDate.split('/');
                            if (p.length == 3) {
                              formattedDate = '${p[2]}-${p[1]}-${p[0]}';
                            }
                          }

                          final currentProfile = ref.read(userProfileProvider);
                          final updatedProfile = currentProfile.copyWith(
                            firstName: _firstNameController.text,
                            lastName: _lastNameController.text,
                            phone: _phoneController.text,
                            babyName: _babyNameController.text,
                            babyBirthDate: formattedDate,
                            avatar: _base64Image ?? '',
                            babyGender: _selectedGender == 1 ? 'M' : 'F',
                          );

                          try {
                            await ref
                                .read(userProfileProvider.notifier)
                                .updateProfile(updatedProfile);
                            
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Profil mis à jour avec succès')),
                              );
                              context.pop();
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Erreur lors de la mise à jour du profil')),
                              );
                            }
                          }
                        },
                        child: Text('Enregistrer les modifications'),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: context.textSecondary,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    TextInputType? keyboardType,
    Widget? suffixIcon,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      onTap: onTap,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.color
                  ?.withValues(alpha: 0.5) ??
              context.textSecondary,
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      style: TextStyle(
        color: Theme.of(context).textTheme.bodyMedium?.color ??
            context.textPrimary,
      ),
    );
  }

  Widget _buildGenderButton(int index, String label, IconData icon) {
    final isSelected = _selectedGender == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGender = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? null
              : Border.all(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  width: 1,
                ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : context.textSecondary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? Colors.white : context.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


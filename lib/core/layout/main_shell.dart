import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../router/app_router.dart';

class MainShell extends StatelessWidget {
  final Widget child; //contenu de l'ecran actif
  const MainShell({super.key, required this.child});
  // détecter sur quel écran on est
  int _getIndex(String location) {
    if (location.startsWith(AppRoutes.surveillance)) return 1;
    if (location.startsWith(AppRoutes.control)) return 2;
    if (location.startsWith(AppRoutes.alerts)) return 3;
    if (location.startsWith(AppRoutes.settings)) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location =
        GoRouterState.of(context).matchedLocation; // lit l'adresse actuelle
    final index = _getIndex(location); // convertit l'adresse en numéro

    return Scaffold(
      body: child, // affiche le contenu de l'ecran actif
      bottomNavigationBar: _CalinBottomNav(
        currentIndex: index, // dit a la barre quel bouton
        onTap: (i) {
          //quand tu cliques un bouton, navigue vers l'écran correspondant
          switch (i) {
            case 0:
              context.go(AppRoutes.home);
              break;
            case 1:
              context.go(AppRoutes.surveillance);
              break;
            case 2:
              context.go(AppRoutes.control);
              break;
            case 3:
              context.go(AppRoutes.alerts);
              break;
            case 4:
              context.go(AppRoutes.settings);
              break;
          }
        },
      ),
    );
  }
}

class _CalinBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>
      onTap; //reçoit le numéro du bouton cliqué et fait la navigation
  const _CalinBottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.home_rounded, 'Accueil'),
      (Icons.videocam_rounded, 'Surveill.'),
      (Icons.tune_rounded, 'Contrôle'),
      (Icons.notifications_rounded, 'Alertes'),
      (Icons.settings_rounded, 'Paramètres'),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: Row(
            //place les boutons côte à côte horizontalement
            children: List.generate(items.length, (i) {
              //crée 5 boutons automatiquement avec une boucle
              final selected = i == currentIndex;
              return Expanded(
                // chaque bouton prend la même largeur
                child: GestureDetector(
                  onTap: () => onTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icône
                      selected && i == 1
                          ? Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                items[i].$1,
                                color: Colors.white,
                                size: 18,
                              ),
                            )
                          : Icon(
                              items[i].$1,
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                              size: 22,
                            ),

                      const SizedBox(height: 2),

                      // Label
                      SizedBox(
                        width: 56,
                        child: Text(
                          items[i].$2,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight:
                                selected ? FontWeight.w600 : FontWeight.normal,
                            color: selected
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

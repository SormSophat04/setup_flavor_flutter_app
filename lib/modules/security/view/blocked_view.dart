import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:setup_flavor/modules/security/controller/security_controller.dart';
import 'package:setup_flavor/routes/app_route.dart';

class BlockedView extends StatelessWidget {
  const BlockedView({super.key});

  List<String> _buildIssues(SecurityController controller) {
    final rawIssues = <String>[
      if (controller.isJailBroken.value) 'Root or jailbreak detected',
      if (controller.isDevMode.value) 'Developer mode is enabled',
      if (controller.isNotTrust.value) 'Device integrity is not trusted',
      if (!controller.isRealDevice.value) 'Running on an emulator or simulator',
      if (controller.isOnExternalStorage.value)
        'Application is installed on external storage',
      ...controller.securityIssues.map(_formatIssue),
    ];

    return rawIssues.toSet().toList();
  }

  static String _formatIssue(String issue) {
    if (issue.trim().isEmpty) {
      return 'Unknown security issue detected';
    }

    final camelCaseFixed = issue.replaceAllMapped(
      RegExp(r'([a-z0-9])([A-Z])'),
      (match) => '${match.group(1)} ${match.group(2)}',
    );
    final normalized = camelCaseFixed.replaceAll('_', ' ').trim();
    return normalized[0].toUpperCase() + normalized.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SecurityController>();

    return Obx(() {
      final issues = _buildIssues(controller);

      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0F172A), Color(0xFF1E1B2E), Color(0xFF3A1020)],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF10172A).withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: const Color(0xFFEF4444).withValues(alpha: 0.28),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Container(
                              width: 76,
                              height: 76,
                              decoration: BoxDecoration(
                                color: const Color(0xFF7F1D1D).withValues(
                                  alpha: 0.28,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.shield_outlined,
                                color: Color(0xFFF87171),
                                size: 42,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Center(
                            child: Text(
                              'Access blocked',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Center(
                            child: Text(
                              'This device does not meet security requirements. '
                              'To protect your account and data, this app cannot continue.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFFCBD5E1),
                                fontSize: 14,
                                height: 1.45,
                              ),
                            ),
                          ),
                          const SizedBox(height: 22),
                          const Text(
                            'Detected issues',
                            style: TextStyle(
                              color: Color(0xFFE2E8F0),
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 10),
                          if (issues.isEmpty)
                            const _IssueTile(
                              label:
                                  'Security policy violation was detected on this device.',
                            )
                          else
                            ...issues.map((issue) => _IssueTile(label: issue)),
                          const SizedBox(height: 22),
                          const Text(
                            'If this is unexpected, disable developer tools, remove root or jailbreak access, then try again.',
                            style: TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 12,
                              height: 1.45,
                            ),
                          ),
                          const SizedBox(height: 18),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: () async {
                                await controller.checkSecurityStatus();
                                if (_buildIssues(controller).isEmpty) {
                                  Get.offAllNamed(AppRoute.mainLayout);
                                }
                              },
                              icon: const Icon(Icons.refresh),
                              label: const Text('Check again'),
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFFEF4444),
                                foregroundColor: Colors.white,
                                minimumSize: const Size.fromHeight(48),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}

class _IssueTile extends StatelessWidget {
  const _IssueTile({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF7F1D1D).withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFFCA5A5).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFFCA5A5), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFFFDE2E2),
                fontSize: 13,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

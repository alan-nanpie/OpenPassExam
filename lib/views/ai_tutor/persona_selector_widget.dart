import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../services/ai_service.dart';

class PersonaSelectorWidget extends StatelessWidget {
  final AiPersona currentPersona;
  final Function(AiPersona) onPersonaSelected;

  const PersonaSelectorWidget({
    super.key,
    required this.currentPersona,
    required this.onPersonaSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          _buildChip(
            context,
            persona: AiPersona.friendlyTutor,
            icon: Icons.psychology,
            label: context.tr('life_metaphor_tab'),
          ),
          const SizedBox(width: 8),
          _buildChip(
            context,
            persona: AiPersona.cliEngineer,
            icon: Icons.terminal,
            label: context.tr('cisco_cli_tab'),
          ),
          const SizedBox(width: 8),
          _buildChip(
            context,
            persona: AiPersona.ccieArchitect,
            icon: Icons.architecture,
            label: context.tr('expert_architecture_tab'),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(
    BuildContext context, {
    required AiPersona persona,
    required IconData icon,
    required String label,
  }) {
    final isSelected = currentPersona == persona;
    return ChoiceChip(
      avatar: Icon(
        icon,
        size: 16,
        color: isSelected ? Colors.white : AppColors.primary,
      ),
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : null,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12.5,
      ),
      onSelected: (_) => onPersonaSelected(persona),
    );
  }
}

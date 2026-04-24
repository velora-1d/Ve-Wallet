import 'package:flutter/material.dart';
import 'package:ve_wallet/core/constants/app_colors.dart';

class AppPreferencesScreen extends StatefulWidget {
  final String title;
  final String currentValue;
  final List<String> options;

  const AppPreferencesScreen({
    super.key,
    required this.title,
    required this.currentValue,
    required this.options,
  });

  @override
  State<AppPreferencesScreen> createState() => _AppPreferencesScreenState();
}

class _AppPreferencesScreenState extends State<AppPreferencesScreen> {
  late String _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.currentValue;
  }

  void _save() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${widget.title} disimpan: $_selected')),
    );
    Navigator.pop(context, _selected);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          RadioGroup<String>(
            groupValue: _selected,
            onChanged: (value) {
              if (value == null) return;
              setState(() => _selected = value);
            },
            child: Column(
              children: widget.options
                  .map(
                    (option) => Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: _selected == option
                              ? AppColors.primary
                              : AppColors.outlineVariant,
                        ),
                      ),
                      child: RadioListTile<String>(
                        value: option,
                        activeColor: AppColors.primary,
                        title: Text(option),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('Simpan Preferensi'),
            ),
          ),
        ],
      ),
    );
  }
}

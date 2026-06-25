import 'package:flutter/material.dart';

class CommandInput extends StatefulWidget {
  final String statusMessage;
  final void Function(String text) onCommandSubmitted;

  const CommandInput({
    required this.statusMessage,
    required this.onCommandSubmitted,
    super.key,
  });

  @override
  State<CommandInput> createState() => _CommandInputState();
}

class _CommandInputState extends State<CommandInput> {
  final TextEditingController _codeController = TextEditingController();

  void _submit() {
    if (_codeController.text.isNotEmpty) {
      widget.onCommandSubmitted(_codeController.text);
      _codeController.clear();
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF1E202C),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            widget.statusMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, height: 1.4),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _codeController,
          decoration: InputDecoration(
            hintText: 'Команда: ARM / DISARM / SOS або Число',
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
            filled: true,
            fillColor: const Color(0xFF1A1B23),
            suffixIcon: IconButton(
              icon: const Icon(Icons.send, color: Color(0xFF00E676)),
              onPressed: _submit,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          onSubmitted: (_) => _submit(),
        ),
        const SizedBox(height: 8),
        const Text(
          '💡 Введіть число для імітації сили удару (G) по рамі.',
          style: TextStyle(color: Colors.grey, fontSize: 10),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildQuickButton('🔒 ARM', const Color(0xFF2196F3), 'ARM'),
            _buildQuickButton('🔓 DISARM', const Color(0xFF4CAF50), 'DISARM'),
            _buildQuickButton('🚨 SOS', const Color(0xFFF44336), 'SOS'),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickButton(String label, Color color, String command) {
    return ElevatedButton(
      onPressed: () => widget.onCommandSubmitted(command),
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withValues(alpha: 0.2),
        foregroundColor: color,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';

class InteractiveBankCard extends StatelessWidget {
  final String bankName;
  final String lastFourDigits;
  final bool isConfirmed;
  final VoidCallback? onDelete;

  const InteractiveBankCard({
    super.key,
    required this.bankName,
    required this.lastFourDigits,
    required this.isConfirmed,
    this.onDelete,
  });

  LinearGradient _getBankGradient(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('city') || lower.contains('ebl')) {
      return const LinearGradient(
        colors: [Color(0xFF1E1B4B), Color(0xFF312E81), Color(0xFF4338CA)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (lower.contains('brac') || lower.contains('dutch')) {
      return const LinearGradient(
        colors: [Color(0xFF065F46), Color(0xFF047857), Color(0xFF10B981)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (lower.contains('standard') || lower.contains('hsbc')) {
      return const LinearGradient(
        colors: [Color(0xFF991B1B), Color(0xFFB91C1C), Color(0xFFEF4444)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
    return const LinearGradient(
      colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF334155)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FlipCard(
      direction: FlipDirection.HORIZONTAL,
      speed: 500,
      front: Container(
        height: 200,
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: _getBankGradient(bankName),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  bankName.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    letterSpacing: 1.2,
                  ),
                ),
                const Icon(Icons.nfc_rounded, color: Colors.white70, size: 28),
              ],
            ),
            Row(
              children: [
                // EMV Chip Representation
                Container(
                  width: 42,
                  height: 30,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFCD34D),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.amber.shade700, width: 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      VerticalDivider(color: Colors.amber.shade900, thickness: 1, width: 2),
                      VerticalDivider(color: Colors.amber.shade900, thickness: 1, width: 2),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.contactless_rounded, color: Colors.white54, size: 24),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '•••• •••• •••• $lastFourDigits',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2,
                    fontFamily: 'monospace',
                  ),
                ),
                const Text(
                  'VISA',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.italic,
                    fontSize: 22,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      back: Container(
        height: 200,
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Magnetic Strip
            Container(
              height: 40,
              width: double.infinity,
              color: Colors.black87,
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 36,
                      color: Colors.white24,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 12),
                      child: const Text(
                        'CVV ***',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'AES-256 GCM',
                      style: TextStyle(color: Color(0xFF34D399), fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Tap card again to flip',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                  if (onDelete != null)
                    GestureDetector(
                      onTap: onDelete,
                      child: const Text(
                        'Remove Card',
                        style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

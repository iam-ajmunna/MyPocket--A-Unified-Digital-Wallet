import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../providers/transit_provider.dart';
import '../../domain/entities/transit_pass_entity.dart';

class TransitVaultScreen extends ConsumerStatefulWidget {
  const TransitVaultScreen({super.key});

  @override
  ConsumerState<TransitVaultScreen> createState() => _TransitVaultScreenState();
}

class _TransitVaultScreenState extends ConsumerState<TransitVaultScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(transitNotifierProvider.notifier).load();
    });
  }

  void _showAddSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddTransitSheet(
        onAdd: (data) async {
          final ok = await ref.read(transitNotifierProvider.notifier).add(
            name: data['name']!,
            cardNumber: data['cardNumber']!,
            transitType: data['transitType']!,
            expiryDate: data['expiryDate']!,
          );
          if (mounted) {
            Navigator.pop(context);
            _snack(ok ? 'Transit pass added' : 'Failed to add transit pass', error: !ok);
          }
        },
      ),
    );
  }

  void _snack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: error ? Colors.red[700] : const Color(0xFF10B981),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(transitNotifierProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Transit Passes',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.4)),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.directions_transit_rounded, color: Color(0xFF10B981), size: 14),
              const SizedBox(width: 4),
              Text('${state.passes.length} Cards',
                  style: const TextStyle(color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.bold)),
            ]),
          ),
        ],
      ),
      body: state.isLoading && state.passes.isEmpty
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1)))
          : state.passes.isEmpty
              ? _emptyState()
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  itemCount: state.passes.length,
                  itemBuilder: (_, i) => _TransitCard(
                    pass: state.passes[i],
                    onRecharge: () => _showRechargeDialog(state.passes[i]),
                    onQr: () => _showQrSheet(state.passes[i]),
                    onDelete: () => _confirmDelete(state.passes[i].id),
                    onRefreshQr: () => ref.read(transitNotifierProvider.notifier).refreshQr(state.passes[i].id),
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddSheet,
        backgroundColor: const Color(0xFF6366F1),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Add Pass', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _emptyState() => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.directions_transit_outlined, size: 72, color: Colors.white12),
      const SizedBox(height: 16),
      const Text('No transit passes yet', style: TextStyle(color: Colors.white38, fontSize: 16)),
      const SizedBox(height: 8),
      const Text('Tap + Add Pass to store your metro or bus card',
          style: TextStyle(color: Colors.white24, fontSize: 13)),
    ]),
  );

  Future<void> _showRechargeDialog(TransitPassEntity pass) async {
    final ctrl = TextEditingController();
    final result = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Recharge ${pass.name}', style: const TextStyle(color: Colors.white)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Current Balance: ${pass.formattedBalance}',
              style: const TextStyle(color: Colors.white60)),
          const SizedBox(height: 16),
          TextFormField(
            controller: ctrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Amount (Tk)',
              labelStyle: const TextStyle(color: Colors.white54),
              prefixText: 'Tk ',
              prefixStyle: const TextStyle(color: Colors.white60),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.06),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF6366F1), width: 1.5)),
            ),
          ),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: Colors.white54))),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(ctrl.text);
              if (amount != null && amount > 0) Navigator.pop(ctx, amount);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366F1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('Recharge', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (result != null) {
      await ref.read(transitNotifierProvider.notifier).recharge(pass.id, result);
      if (mounted) _snack('Tk ${result.toStringAsFixed(0)} added successfully');
    }
  }

  void _showQrSheet(TransitPassEntity pass) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _QrSheet(pass: pass,
          onRefresh: () => ref.read(transitNotifierProvider.notifier).refreshQr(pass.id)),
    );
  }

  Future<void> _confirmDelete(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Remove Transit Pass', style: TextStyle(color: Colors.white)),
        content: const Text('This will permanently remove this transit pass from your vault.',
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel', style: TextStyle(color: Colors.white54))),
          TextButton(onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Remove', style: TextStyle(color: Colors.redAccent))),
        ],
      ),
    );
    if (confirm == true) {
      await ref.read(transitNotifierProvider.notifier).delete(id);
    }
  }
}

// ─── Transit Card Widget ───────────────────────────────────────────────────────
class _TransitCard extends StatelessWidget {
  final TransitPassEntity pass;
  final VoidCallback onRecharge;
  final VoidCallback onQr;
  final VoidCallback onDelete;
  final VoidCallback onRefreshQr;

  const _TransitCard({
    required this.pass,
    required this.onRecharge,
    required this.onQr,
    required this.onDelete,
    required this.onRefreshQr,
  });

  IconData get _typeIcon {
    switch (pass.transitType) {
      case 'Metro': return Icons.directions_subway_rounded;
      case 'Bus': return Icons.directions_bus_rounded;
      case 'Train': return Icons.train_rounded;
      case 'Ferry': return Icons.directions_boat_rounded;
      case 'Tram': return Icons.tram_rounded;
      case 'Subway': return Icons.subway_rounded;
      case 'Bike Share': return Icons.pedal_bike_rounded;
      default: return Icons.directions_transit_rounded;
    }
  }

  List<Color> get _gradient {
    switch (pass.transitType) {
      case 'Metro': return [const Color(0xFF1A2980), const Color(0xFF26D0CE)];
      case 'Bus': return [const Color(0xFF1D976C), const Color(0xFF93F9B9)];
      case 'Train': return [const Color(0xFF673AB7), const Color(0xFF9C27B0)];
      case 'Ferry': return [const Color(0xFF0891B2), const Color(0xFF0369A1)];
      default: return [const Color(0xFF6366F1), const Color(0xFF4F46E5)];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: _gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: _gradient[0].withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 8))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Header
          Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)),
              child: Icon(_typeIcon, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(pass.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                Text(pass.transitType, style: const TextStyle(color: Colors.white60, fontSize: 12)),
              ]),
            ),
            if (pass.isExpired)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(10)),
                child: const Text('EXPIRED', style: TextStyle(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
          ]),
          const SizedBox(height: 20),
          // Card Number
          Text(pass.maskedNumber,
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold,
                  letterSpacing: 2, fontFamily: 'monospace')),
          const SizedBox(height: 4),
          Text('Expires ${pass.expiryDate}', style: const TextStyle(color: Colors.white60, fontSize: 12)),
          const SizedBox(height: 16),
          // Balance
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(children: [
              const Icon(Icons.account_balance_wallet_rounded, color: Colors.white70, size: 18),
              const SizedBox(width: 8),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Balance', style: TextStyle(color: Colors.white54, fontSize: 11)),
                Text(pass.formattedBalance,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              ]),
            ]),
          ),
          const SizedBox(height: 14),
          // Action Buttons
          Row(children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onRecharge,
                icon: const Icon(Icons.add_card_rounded, size: 16),
                label: const Text('Recharge'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white38),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: pass.qrToken != null ? onQr : null,
                icon: const Icon(Icons.qr_code_rounded, size: 16),
                label: const Text('Board QR'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white38),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline_rounded, color: Colors.white54),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ]),
        ]),
      ),
    );
  }
}

// ─── QR Sheet ──────────────────────────────────────────────────────────────────
class _QrSheet extends StatelessWidget {
  final TransitPassEntity pass;
  final VoidCallback onRefresh;

  const _QrSheet({required this.pass, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1E293B),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 40, height: 4,
            decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 20),
        Text('${pass.name} — Boarding QR',
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('Show this QR code to the gate scanner',
            style: TextStyle(color: Colors.white54, fontSize: 13)),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: QrImageView(
            data: pass.qrToken ?? '',
            size: 220,
            version: QrVersions.auto,
            eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: Color(0xFF1E293B)),
            dataModuleStyle: const QrDataModuleStyle(
              dataModuleShape: QrDataModuleShape.square,
              color: Color(0xFF1E293B),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text('Token: ...${pass.qrToken?.substring(pass.qrToken!.length - 8) ?? ''}',
            style: const TextStyle(color: Colors.white38, fontSize: 11, fontFamily: 'monospace')),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () { onRefresh(); Navigator.pop(context); },
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Invalidate & Refresh Token'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.orangeAccent,
                side: const BorderSide(color: Colors.orangeAccent),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close_rounded, color: Colors.white54),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ]),
        SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 16),
      ]),
    );
  }
}

// ─── Add Transit Sheet ─────────────────────────────────────────────────────────
class _AddTransitSheet extends StatefulWidget {
  final Future<void> Function(Map<String, String> data) onAdd;
  const _AddTransitSheet({required this.onAdd});

  @override
  State<_AddTransitSheet> createState() => _AddTransitSheetState();
}

class _AddTransitSheetState extends State<_AddTransitSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _numberCtrl = TextEditingController();
  final _expiryCtrl = TextEditingController();
  String _transitType = 'Metro';
  bool _loading = false;

  final _types = ['Metro', 'Bus', 'Train', 'Ferry', 'Tram', 'Subway', 'Light Rail', 'Bike Share'];

  @override
  void dispose() {
    _nameCtrl.dispose(); _numberCtrl.dispose(); _expiryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.9,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1E293B),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(children: [
              const Text('Add Transit Pass',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const Spacer(),
              IconButton(onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: Colors.white54)),
            ]),
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: ctrl,
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Form(
                key: _formKey,
                child: Column(children: [
                  _field(_nameCtrl, 'Card Name', hint: 'e.g. My Metro Card'),
                  _field(_numberCtrl, 'Card Number', hint: 'Min 8 digits',
                      keyboardType: TextInputType.number,
                      validator: (v) => (v == null || v.length < 8) ? 'Minimum 8 digits' : null),
                  _field(_expiryCtrl, 'Expiry Date', hint: 'YYYY-MM-DD'),
                  const SizedBox(height: 4),
                  DropdownButtonFormField<String>(
                    value: _transitType,
                    items: _types.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                    onChanged: (v) => setState(() => _transitType = v!),
                    dropdownColor: const Color(0xFF1E293B),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Transit Type',
                      labelStyle: const TextStyle(color: Colors.white54),
                      filled: true, fillColor: Colors.white.withValues(alpha: 0.06),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF6366F1), width: 1.5)),
                    ),
                  ),
                ]),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20, 8, 20, MediaQuery.of(context).viewInsets.bottom + 20),
            child: SizedBox(
              width: double.infinity, height: 52,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _loading
                    ? const SizedBox(width: 22, height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation(Colors.white)))
                    : const Text('Add to Vault',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label,
      {String? hint, TextInputType? keyboardType, String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label, hintText: hint,
          labelStyle: const TextStyle(color: Colors.white54),
          hintStyle: const TextStyle(color: Colors.white24),
          filled: true, fillColor: Colors.white.withValues(alpha: 0.06),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF6366F1), width: 1.5)),
        ),
        validator: validator ?? (v) => (v == null || v.trim().isEmpty) ? '$label is required' : null,
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    await widget.onAdd({
      'name': _nameCtrl.text.trim(),
      'cardNumber': _numberCtrl.text.trim(),
      'transitType': _transitType,
      'expiryDate': _expiryCtrl.text.trim(),
    });
    if (mounted) setState(() => _loading = false);
  }
}

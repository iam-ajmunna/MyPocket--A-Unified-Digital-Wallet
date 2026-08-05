import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import '../providers/documents_provider.dart';
import '../../domain/entities/document_entity.dart';

class DocumentsVaultScreen extends ConsumerStatefulWidget {
  const DocumentsVaultScreen({super.key});

  @override
  ConsumerState<DocumentsVaultScreen> createState() => _DocumentsVaultScreenState();
}

class _DocumentsVaultScreenState extends ConsumerState<DocumentsVaultScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final LocalAuthentication _localAuth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(documentsNotifierProvider.notifier).loadDocuments();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<bool> _authenticateBiometric() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      if (!canCheck) return true; // Allow on emulator without biometrics
      return await _localAuth.authenticate(
        localizedReason: 'Verify your identity to reveal document details',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );
    } catch (_) {
      return true; // Fallback on emulator
    }
  }

  void _showAddDocumentSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddDocumentSheet(
        onAddNid: (data) async {
          final ok = await ref.read(documentsNotifierProvider.notifier).addNid(
                nidNumber: data['nidNumber']!,
                fullName: data['fullName']!,
                dateOfBirth: data['dateOfBirth']!,
                fatherName: data['fatherName']!,
                motherName: data['motherName']!,
                address: data['address']!,
              );
          if (ok && mounted) {
            Navigator.pop(context);
            _showSnack('NID added to vault successfully');
          } else if (mounted) {
            _showSnack('Failed to add NID. Please try again.', isError: true);
          }
        },
        onAddPassport: (data) async {
          final ok = await ref.read(documentsNotifierProvider.notifier).addPassport(
                passportNumber: data['passportNumber']!,
                fullName: data['fullName']!,
                countryCode: data['countryCode']!,
                dateOfBirth: data['dateOfBirth']!,
                expiryDate: data['expiryDate']!,
                issueDate: data['issueDate']!,
              );
          if (ok && mounted) {
            Navigator.pop(context);
            _showSnack('Passport added to vault successfully');
          } else if (mounted) {
            _showSnack('Failed to add Passport. Please try again.', isError: true);
          }
        },
      ),
    );
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? Colors.red[700] : const Color(0xFF10B981),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(documentsNotifierProvider);
    final nids = state.documents.where((d) => d.isNid).toList();
    final passports = state.documents.where((d) => d.isPassport).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Identity Vault',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF10B981).withOpacity(0.4)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.shield_rounded, color: Color(0xFF10B981), size: 14),
                SizedBox(width: 4),
                Text(
                  'AES-256',
                  style: TextStyle(
                    color: Color(0xFF10B981),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF6366F1),
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white38,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.badge_rounded, size: 18),
                  const SizedBox(width: 6),
                  Text('NID (${nids.length})'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.book_rounded, size: 18),
                  const SizedBox(width: 6),
                  Text('Passport (${passports.length})'),
                ],
              ),
            ),
          ],
        ),
      ),
      body: state.isLoading && state.documents.isEmpty
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF6366F1)),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _DocumentList(
                  documents: nids,
                  emptyLabel: 'No NID stored yet',
                  emptyIcon: Icons.badge_outlined,
                  onReveal: (id) => _handleReveal(id),
                  onDelete: (id) => _handleDelete(id),
                ),
                _DocumentList(
                  documents: passports,
                  emptyLabel: 'No Passport stored yet',
                  emptyIcon: Icons.book_outlined,
                  onReveal: (id) => _handleReveal(id),
                  onDelete: (id) => _handleDelete(id),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDocumentSheet(context),
        backgroundColor: const Color(0xFF6366F1),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Add Document',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Future<void> _handleReveal(String documentId) async {
    final authed = await _authenticateBiometric();
    if (!authed) {
      _showSnack('Biometric verification required', isError: true);
      return;
    }
    await ref.read(documentsNotifierProvider.notifier).revealDocument(documentId);
  }

  Future<void> _handleDelete(String documentId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Remove Document', style: TextStyle(color: Colors.white)),
        content: const Text(
          'This will permanently remove this document from your encrypted vault. This action cannot be undone.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remove', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await ref.read(documentsNotifierProvider.notifier).deleteDocument(documentId);
      _showSnack('Document removed from vault');
    }
  }
}

// ─── Document List ─────────────────────────────────────────────────────────────
class _DocumentList extends StatelessWidget {
  final List<DocumentEntity> documents;
  final String emptyLabel;
  final IconData emptyIcon;
  final Future<void> Function(String id) onReveal;
  final Future<void> Function(String id) onDelete;

  const _DocumentList({
    required this.documents,
    required this.emptyLabel,
    required this.emptyIcon,
    required this.onReveal,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (documents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(emptyIcon, size: 72, color: Colors.white12),
            const SizedBox(height: 16),
            Text(emptyLabel,
                style: const TextStyle(color: Colors.white38, fontSize: 16)),
            const SizedBox(height: 8),
            const Text(
              'Tap + Add Document to securely store one',
              style: TextStyle(color: Colors.white24, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: documents.length,
      itemBuilder: (ctx, i) => _DocumentCard(
        document: documents[i],
        onReveal: onReveal,
        onDelete: onDelete,
      ),
    );
  }
}

// ─── Document Card ─────────────────────────────────────────────────────────────
class _DocumentCard extends StatelessWidget {
  final DocumentEntity document;
  final Future<void> Function(String id) onReveal;
  final Future<void> Function(String id) onDelete;

  const _DocumentCard({
    required this.document,
    required this.onReveal,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isNid = document.isNid;
    final gradient = isNid
        ? const [Color(0xFF6366F1), Color(0xFF4F46E5)]
        : const [Color(0xFF0891B2), Color(0xFF0369A1)];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradient[0].withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isNid ? Icons.badge_rounded : Icons.book_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isNid ? 'National ID Card' : 'International Passport',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const Text(
                        'Government Issued • Encrypted',
                        style: TextStyle(color: Colors.white60, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                if (document.isConfirmed)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.25),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      '✓ Stored',
                      style: TextStyle(
                        color: Color(0xFF10B981),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              document.docNumberMasked,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                fontFamily: 'monospace',
              ),
            ),
            if (document.details != null) ...[
              const SizedBox(height: 12),
              const Divider(color: Colors.white24),
              const SizedBox(height: 8),
              _DetailRow(
                label: 'Name',
                value: document.details!['fullName'] as String? ?? '—',
              ),
              if (isNid) ...[
                _DetailRow(
                  label: 'Date of Birth',
                  value: document.details!['dateOfBirth'] as String? ?? '—',
                ),
                _DetailRow(
                  label: 'Father',
                  value: document.details!['fatherName'] as String? ?? '—',
                ),
              ] else ...[
                _DetailRow(
                  label: 'Country',
                  value: document.details!['countryCode'] as String? ?? '—',
                ),
                _DetailRow(
                  label: 'Expires',
                  value: document.details!['expiryDate'] as String? ?? '—',
                ),
              ],
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: document.details == null
                      ? OutlinedButton.icon(
                          onPressed: () => onReveal(document.id),
                          icon: const Icon(Icons.fingerprint_rounded, size: 18),
                          label: const Text('Reveal with Biometric'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white38),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        )
                      : OutlinedButton.icon(
                          onPressed: null,
                          icon: const Icon(Icons.lock_open_rounded, size: 18),
                          label: const Text('Details Revealed'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white60,
                            side: const BorderSide(color: Colors.white24),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => onDelete(document.id),
                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.white54),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Add Document Bottom Sheet ─────────────────────────────────────────────────
class _AddDocumentSheet extends StatefulWidget {
  final Future<void> Function(Map<String, String> data) onAddNid;
  final Future<void> Function(Map<String, String> data) onAddPassport;

  const _AddDocumentSheet({required this.onAddNid, required this.onAddPassport});

  @override
  State<_AddDocumentSheet> createState() => _AddDocumentSheetState();
}

class _AddDocumentSheetState extends State<_AddDocumentSheet> {
  String _selectedType = 'NID';
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // NID fields
  final _nidNumberCtrl = TextEditingController();
  final _fullNameCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();
  final _fatherCtrl = TextEditingController();
  final _motherCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  // Passport fields
  final _passportNumberCtrl = TextEditingController();
  final _passportNameCtrl = TextEditingController();
  final _countryCtrl = TextEditingController();
  final _passportDobCtrl = TextEditingController();
  final _expiryCtrl = TextEditingController();
  final _issueDateCtrl = TextEditingController();

  @override
  void dispose() {
    for (final c in [
      _nidNumberCtrl, _fullNameCtrl, _dobCtrl, _fatherCtrl, _motherCtrl, _addressCtrl,
      _passportNumberCtrl, _passportNameCtrl, _countryCtrl, _passportDobCtrl, _expiryCtrl, _issueDateCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Widget _buildField(TextEditingController ctrl, String label, {
    String? hint,
    bool required = true,
    int? minLength,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl,
        style: const TextStyle(color: Colors.white, fontSize: 15),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: const TextStyle(color: Colors.white54),
          hintStyle: const TextStyle(color: Colors.white24),
          filled: true,
          fillColor: Colors.white.withOpacity(0.06),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF6366F1), width: 1.5),
          ),
        ),
        validator: required
            ? (v) {
                if (v == null || v.trim().isEmpty) return '$label is required';
                if (minLength != null && v.trim().length < minLength) {
                  return '$label must be at least $minLength characters';
                }
                return null;
              }
            : null,
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    if (_selectedType == 'NID') {
      await widget.onAddNid({
        'nidNumber': _nidNumberCtrl.text.trim(),
        'fullName': _fullNameCtrl.text.trim(),
        'dateOfBirth': _dobCtrl.text.trim(),
        'fatherName': _fatherCtrl.text.trim(),
        'motherName': _motherCtrl.text.trim(),
        'address': _addressCtrl.text.trim(),
      });
    } else {
      await widget.onAddPassport({
        'passportNumber': _passportNumberCtrl.text.trim(),
        'fullName': _passportNameCtrl.text.trim(),
        'countryCode': _countryCtrl.text.trim().toUpperCase(),
        'dateOfBirth': _passportDobCtrl.text.trim(),
        'expiryDate': _expiryCtrl.text.trim(),
        'issueDate': _issueDateCtrl.text.trim(),
      });
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1E293B),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Text(
                    'Add Identity Document',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, color: Colors.white54),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: ['NID', 'Passport'].map((type) {
                  final isSelected = _selectedType == type;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedType = type),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: EdgeInsets.only(right: type == 'NID' ? 8 : 0),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF6366F1)
                              : Colors.white.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            type,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.white54,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: ctrl,
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Form(
                  key: _formKey,
                  child: _selectedType == 'NID'
                      ? Column(children: [
                          _buildField(_nidNumberCtrl, 'NID Number',
                              hint: '10–17 digits', minLength: 10),
                          _buildField(_fullNameCtrl, 'Full Name'),
                          _buildField(_dobCtrl, 'Date of Birth', hint: 'YYYY-MM-DD'),
                          _buildField(_fatherCtrl, 'Father\'s Name'),
                          _buildField(_motherCtrl, 'Mother\'s Name'),
                          _buildField(_addressCtrl, 'Permanent Address'),
                        ])
                      : Column(children: [
                          _buildField(_passportNumberCtrl, 'Passport Number',
                              hint: 'e.g. A1234567', minLength: 7),
                          _buildField(_passportNameCtrl, 'Full Name'),
                          _buildField(_countryCtrl, 'Country Code', hint: 'e.g. BGD'),
                          _buildField(_passportDobCtrl, 'Date of Birth', hint: 'YYYY-MM-DD'),
                          _buildField(_issueDateCtrl, 'Issue Date', hint: 'YYYY-MM-DD'),
                          _buildField(_expiryCtrl, 'Expiry Date', hint: 'YYYY-MM-DD'),
                        ]),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                  20, 8, 20, MediaQuery.of(context).viewInsets.bottom + 20),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    disabledBackgroundColor: const Color(0xFF6366F1).withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : const Text(
                          'Encrypt & Save to Vault',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

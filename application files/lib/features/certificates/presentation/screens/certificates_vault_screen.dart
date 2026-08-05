import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/certificates_provider.dart';
import '../../domain/entities/certificate_entity.dart';

class CertificatesVaultScreen extends ConsumerStatefulWidget {
  const CertificatesVaultScreen({super.key});

  @override
  ConsumerState<CertificatesVaultScreen> createState() => _CertificatesVaultScreenState();
}

class _CertificatesVaultScreenState extends ConsumerState<CertificatesVaultScreen> {
  String _selectedCategory = 'ALL';

  final List<Map<String, dynamic>> _categories = [
    {'key': 'ALL', 'label': 'All', 'icon': Icons.grid_view_rounded, 'color': Color(0xFF6366F1)},
    {'key': 'ACADEMIC', 'label': 'Academic', 'icon': Icons.school_rounded, 'color': Color(0xFF3B82F6)},
    {'key': 'OLYMPIAD', 'label': 'Olympiad', 'icon': Icons.lightbulb_rounded, 'color': Color(0xFFF59E0B)},
    {'key': 'QUIZCOMP', 'label': 'Quiz', 'icon': Icons.quiz_rounded, 'color': Color(0xFF10B981)},
    {'key': 'BIZCOMP', 'label': 'Business', 'icon': Icons.business_rounded, 'color': Color(0xFFF97316)},
    {'key': 'SPORTS', 'label': 'Sports', 'icon': Icons.sports_rounded, 'color': Color(0xFFEF4444)},
    {'key': 'SKILLS', 'label': 'Skills', 'icon': Icons.build_rounded, 'color': Color(0xFF8B5CF6)},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(certificatesNotifierProvider.notifier).load();
    });
  }

  void _showAddSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddCertificateSheet(
        onAdd: (data) async {
          final ok = await ref.read(certificatesNotifierProvider.notifier).add(
            name: data['name']!,
            issuer: data['issuer']!,
            issueDate: data['issueDate']!,
            category: data['category']!,
            subCategory: data['subCategory'],
          );
          if (mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(ok ? 'Certificate added to vault' : 'Failed to add certificate'),
              backgroundColor: ok ? const Color(0xFF10B981) : Colors.red[700],
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ));
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(certificatesNotifierProvider);
    final filtered = _selectedCategory == 'ALL'
        ? state.certificates
        : state.certificates.where((c) => c.category == _selectedCategory).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Certificate Vault',
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
              const Icon(Icons.shield_rounded, color: Color(0xFF10B981), size: 14),
              const SizedBox(width: 4),
              Text('${state.certificates.length} Stored',
                  style: const TextStyle(color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.bold)),
            ]),
          ),
        ],
      ),
      body: Column(
        children: [
          // Category Filter
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: _categories.length,
              itemBuilder: (_, i) {
                final cat = _categories[i];
                final isSelected = _selectedCategory == cat['key'];
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat['key'] as String),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (cat['color'] as Color).withValues(alpha: 0.2)
                          : Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isSelected ? cat['color'] as Color : Colors.white12,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(cat['icon'] as IconData,
                            color: isSelected ? cat['color'] as Color : Colors.white38, size: 16),
                        const SizedBox(width: 6),
                        Text(cat['label'] as String,
                            style: TextStyle(
                              color: isSelected ? cat['color'] as Color : Colors.white38,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 13,
                            )),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Certificate List
          Expanded(
            child: state.isLoading && state.certificates.isEmpty
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1)))
                : filtered.isEmpty
                    ? _EmptyState(category: _selectedCategory)
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                        itemCount: filtered.length,
                        itemBuilder: (_, i) => _CertificateCard(
                          certificate: filtered[i],
                          onDelete: () => _confirmDelete(filtered[i].id),
                          categories: _categories,
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddSheet,
        backgroundColor: const Color(0xFF6366F1),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Add Certificate',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Future<void> _confirmDelete(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Remove Certificate', style: TextStyle(color: Colors.white)),
        content: const Text('This will permanently remove this certificate from your vault.',
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
      await ref.read(certificatesNotifierProvider.notifier).delete(id);
    }
  }
}

class _CertificateCard extends StatelessWidget {
  final CertificateEntity certificate;
  final VoidCallback onDelete;
  final List<Map<String, dynamic>> categories;

  const _CertificateCard({required this.certificate, required this.onDelete, required this.categories});

  Color get _catColor {
    final cat = categories.firstWhere(
      (c) => c['key'] == certificate.category,
      orElse: () => {'color': const Color(0xFF6366F1)},
    );
    return cat['color'] as Color;
  }

  IconData get _catIcon {
    final cat = categories.firstWhere(
      (c) => c['key'] == certificate.category,
      orElse: () => {'icon': Icons.workspace_premium_rounded},
    );
    return cat['icon'] as IconData;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _catColor.withValues(alpha: 0.25)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _catColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_catIcon, color: _catColor, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(certificate.name,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(certificate.issuer,
                      style: const TextStyle(color: Colors.white60, fontSize: 12),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _catColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(certificate.displayCategory,
                          style: TextStyle(color: _catColor, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                    if (certificate.subCategory?.isNotEmpty == true) ...[
                      const SizedBox(width: 6),
                      Text('• ${certificate.displaySubCategory}',
                          style: const TextStyle(color: Colors.white38, fontSize: 11)),
                    ],
                    const Spacer(),
                    Text(certificate.issueDate,
                        style: const TextStyle(color: Colors.white38, fontSize: 11)),
                  ]),
                ],
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline_rounded, color: Colors.white38, size: 20),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.06),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String category;
  const _EmptyState({required this.category});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.workspace_premium_outlined, size: 72, color: Colors.white12),
        const SizedBox(height: 16),
        const Text('No certificates here yet', style: TextStyle(color: Colors.white38, fontSize: 16)),
        const SizedBox(height: 8),
        const Text('Tap + Add Certificate to store one',
            style: TextStyle(color: Colors.white24, fontSize: 13)),
      ]),
    );
  }
}

// ─── Add Certificate Bottom Sheet ──────────────────────────────────────────────
class _AddCertificateSheet extends StatefulWidget {
  final Future<void> Function(Map<String, String?> data) onAdd;
  const _AddCertificateSheet({required this.onAdd});

  @override
  State<_AddCertificateSheet> createState() => _AddCertificateSheetState();
}

class _AddCertificateSheetState extends State<_AddCertificateSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _issuerCtrl = TextEditingController();
  final _dateCtrl = TextEditingController();
  String _category = 'ACADEMIC';
  String? _subCategory;
  bool _loading = false;

  final _categoryOptions = [
    {'key': 'ACADEMIC', 'label': 'Academic'},
    {'key': 'OLYMPIAD', 'label': 'Olympiad'},
    {'key': 'QUIZCOMP', 'label': 'Quiz Competition'},
    {'key': 'BIZCOMP', 'label': 'Business Competition'},
    {'key': 'SPORTS', 'label': 'Sports'},
    {'key': 'SKILLS', 'label': 'General Skills'},
  ];

  final _subCategoryOptions = [
    {'key': 'SSC', 'label': 'SSC'},
    {'key': 'HSC', 'label': 'HSC'},
    {'key': 'UNDERGRAD', 'label': 'Under Graduate'},
    {'key': 'GRAD', 'label': 'Graduate'},
    {'key': 'PHD', 'label': 'PhD'},
    {'key': 'POSTDOC', 'label': 'Post Doctorate'},
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _issuerCtrl.dispose();
    _dateCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
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
              const Text('Add Certificate',
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
                  _field(_nameCtrl, 'Certificate Name'),
                  _field(_issuerCtrl, 'Issuing Organisation'),
                  _field(_dateCtrl, 'Issue Date (YYYY-MM-DD)', hint: 'e.g. 2024-06-15'),
                  const SizedBox(height: 4),
                  _dropdown('Category', _category,
                    _categoryOptions.map((e) => DropdownMenuItem(value: e['key'], child: Text(e['label']!))).toList(),
                    (v) => setState(() { _category = v!; _subCategory = null; }),
                  ),
                  if (_category == 'ACADEMIC') ...[
                    const SizedBox(height: 12),
                    _dropdown('Sub Category', _subCategory,
                      [const DropdownMenuItem(value: null, child: Text('— Select —')),
                       ..._subCategoryOptions.map((e) => DropdownMenuItem(value: e['key'], child: Text(e['label']!)))],
                      (v) => setState(() => _subCategory = v),
                    ),
                  ],
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
                    : const Text('Save to Vault',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label, {String? hint}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl,
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
        validator: (v) => v == null || v.trim().isEmpty ? '$label is required' : null,
      ),
    );
  }

  Widget _dropdown(String label, dynamic value, List<DropdownMenuItem> items, ValueChanged onChanged) {
    return DropdownButtonFormField(
      value: value,
      items: items,
      onChanged: onChanged,
      dropdownColor: const Color(0xFF1E293B),
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        filled: true, fillColor: Colors.white.withValues(alpha: 0.06),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF6366F1), width: 1.5)),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    await widget.onAdd({
      'name': _nameCtrl.text.trim(),
      'issuer': _issuerCtrl.text.trim(),
      'issueDate': _dateCtrl.text.trim(),
      'category': _category,
      'subCategory': _subCategory,
    });
    if (mounted) setState(() => _loading = false);
  }
}

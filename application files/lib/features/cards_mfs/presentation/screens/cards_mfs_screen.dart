import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/cards_mfs_provider.dart';

class CardsMfsScreen extends ConsumerStatefulWidget {
  const CardsMfsScreen({super.key});

  @override
  ConsumerState<CardsMfsScreen> createState() => _CardsMfsScreenState();
}

class _CardsMfsScreenState extends ConsumerState<CardsMfsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cardsMfsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cards & MFS Vault'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF4776E6),
          labelColor: const Color(0xFF4776E6),
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(icon: Icon(Icons.credit_card), text: 'Bank Cards'),
            Tab(icon: Icon(Icons.account_balance_wallet), text: 'MFS Accounts'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Bank Cards Tab
          _buildBankCardsTab(context, state),
          // MFS Accounts Tab
          _buildMfsAccountsTab(context, state),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_tabController.index == 0) {
            _showAddCardDialog(context);
          } else {
            _showAddMfsDialog(context);
          }
        },
        backgroundColor: const Color(0xFF4776E6),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          _tabController.index == 0 ? 'Add Card' : 'Add MFS',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildBankCardsTab(BuildContext context, CardsMfsState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.cards.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.credit_card_off_rounded, size: 72, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text(
              'No Bank Cards Saved Yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap "+ Add Card" below to add an AES-256 encrypted card.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.cards.length,
      itemBuilder: (context, index) {
        final card = state.cards[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2C3E50), Color(0xFF3498DB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      card.bankName,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const Icon(Icons.contactless, color: Colors.white70),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  '•••• •••• •••• ${card.last4Digits}',
                  style: const TextStyle(color: Colors.white, fontSize: 20, letterSpacing: 2, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('CARD HOLDER', style: TextStyle(color: Colors.white60, fontSize: 10)),
                        Text(card.cardHolderName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('EXPIRES', style: TextStyle(color: Colors.white60, fontSize: 10)),
                        Text(card.expiryMonthYear, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMfsAccountsTab(BuildContext context, CardsMfsState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.mfsAccounts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_balance_wallet_outlined, size: 72, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text(
              'No Mobile Financial Services Linked',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Link your bKash, Nagad, or Upay account safely.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.mfsAccounts.length,
      itemBuilder: (context, index) {
        final mfs = state.mfsAccounts[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF4776E6).withOpacity(0.1),
              child: const Icon(Icons.phone_android, color: Color(0xFF4776E6)),
            ),
            title: Text(
              mfs.providerName.toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('Account: ${mfs.accountNumber}'),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: mfs.isVerified ? Colors.green.shade50 : Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                mfs.isVerified ? 'VERIFIED' : 'PENDING',
                style: TextStyle(
                  color: mfs.isVerified ? Colors.green : Colors.orange,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showAddCardDialog(BuildContext context) {
    final bankNameCtrl = TextEditingController(text: 'BRAC Bank');
    final cardHolderCtrl = TextEditingController();
    final cardNumberCtrl = TextEditingController();
    final expiryCtrl = TextEditingController(text: '12/28');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Bank Card'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: bankNameCtrl,
                decoration: const InputDecoration(labelText: 'Bank Name'),
              ),
              TextField(
                controller: cardHolderCtrl,
                decoration: const InputDecoration(labelText: 'Cardholder Name'),
              ),
              TextField(
                controller: cardNumberCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: '16-Digit Card Number'),
              ),
              TextField(
                controller: expiryCtrl,
                decoration: const InputDecoration(labelText: 'Expiry (MM/YY)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (cardNumberCtrl.text.isNotEmpty && cardHolderCtrl.text.isNotEmpty) {
                ref.read(cardsMfsNotifierProvider.notifier).addCard(
                      bankName: bankNameCtrl.text,
                      cardHolderName: cardHolderCtrl.text,
                      cardNumber: cardNumberCtrl.text,
                      expiryMonthYear: expiryCtrl.text,
                    );
                Navigator.pop(context);
              }
            },
            child: const Text('Add Card'),
          ),
        ],
      ),
    );
  }

  void _showAddMfsDialog(BuildContext context) {
    String selectedProvider = 'bKash';
    final accountCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add MFS Account'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: selectedProvider,
              items: ['bKash', 'Nagad', 'Upay']
                  .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                  .toList(),
              onChanged: (val) => selectedProvider = val!,
              decoration: const InputDecoration(labelText: 'Provider'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: accountCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Mobile Account Number'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (accountCtrl.text.isNotEmpty) {
                ref.read(cardsMfsNotifierProvider.notifier).addMfsAccount(
                      providerName: selectedProvider,
                      accountNumber: accountCtrl.text,
                    );
                Navigator.pop(context);
              }
            },
            child: const Text('Add MFS'),
          ),
        ],
      ),
    );
  }
}

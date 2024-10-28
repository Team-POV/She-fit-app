import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';

class Reward {
  final String id;
  final String title;
  final String description;
  final int pointsCost;
  final String brandName;
  final String imageUrl;
  final String category;
  final double discountPercent;
  final bool isActive;
  
  Reward({
    required this.id,
    required this.title,
    required this.description,
    required this.pointsCost,
    required this.brandName,
    required this.imageUrl,
    required this.category,
    required this.discountPercent,
    this.isActive = true,
  });
}

// rewards_page.dart

class RewardsPage extends StatefulWidget {
  const RewardsPage({Key? key}) : super(key: key);

  @override
  State<RewardsPage> createState() => _RewardsPageState();
}

class _RewardsPageState extends State<RewardsPage> {
  final String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
  int userFitPoints = 0;
  List<Reward> rewards = [];
  String selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _loadUserFitPoints();
    _initializeRewards();
  }

  Future<void> _loadUserFitPoints() async {
    if (userId.isEmpty) return;
    
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();
    
    if (userDoc.exists) {
      setState(() {
        userFitPoints = userDoc.data()?['fitPoints'] ?? 0;
      });
    }
  }

  void _initializeRewards() {
    rewards = [
      Reward(
        id: 'nike_discount',
        title: '20% off Nike',
        description: 'Get 20% off on any Nike product',
        pointsCost: 1,
        brandName: 'Nike',
        imageUrl: '/api/placeholder/200/200',
        category: 'Sports',
        discountPercent: 20,
      ),
      Reward(
        id: 'lululemon_discount',
        title: '15% off Lululemon',
        description: 'Get 15% off on Lululemon activewear',
        pointsCost: 800,
        brandName: 'Lululemon',
        imageUrl: '/api/placeholder/200/200',
        category: 'Fashion',
        discountPercent: 15,
      ),
      Reward(
        id: 'sephora_discount',
        title: '25% off Sephora',
        description: 'Get 25% off on Sephora products',
        pointsCost: 1200,
        brandName: 'Sephora',
        imageUrl: '/api/placeholder/200/200',
        category: 'Beauty',
        discountPercent: 25,
      ),
      Reward(
        id: 'adidas_discount',
        title: '30% off Adidas',
        description: 'Get 30% off on Adidas products',
        pointsCost: 1500,
        brandName: 'Adidas',
        imageUrl: '/api/placeholder/200/200',
        category: 'Sports',
        discountPercent: 30,
      ),
      Reward(
        id: 'fabletics_discount',
        title: '40% off Fabletics',
        description: 'Get 40% off on Fabletics activewear',
        pointsCost: 2000,
        brandName: 'Fabletics',
        imageUrl: '/api/placeholder/200/200',
        category: 'Fashion',
        discountPercent: 40,
      ),
      Reward(
        id: 'ulta_discount',
        title: '20% off Ulta',
        description: 'Get 20% off on Ulta beauty products',
        pointsCost: 1000,
        brandName: 'Ulta',
        imageUrl: '/api/placeholder/200/200',
        category: 'Beauty',
        discountPercent: 20,
      ),
      Reward(
        id: 'gymshark_discount',
        title: '25% off Gymshark',
        description: 'Get 25% off on Gymshark products',
        pointsCost: 1200,
        brandName: 'Gymshark',
        imageUrl: '/api/placeholder/200/200',
        category: 'Sports',
        discountPercent: 25,
      ),
      Reward(
        id: 'forever21_discount',
        title: '30% off Forever 21',
        description: 'Get 30% off on Forever 21 activewear',
        pointsCost: 1500,
        brandName: 'Forever 21',
        imageUrl: '/api/placeholder/200/200',
        category: 'Fashion',
        discountPercent: 30,
      ),
      Reward(
        id: 'mac_discount',
        title: '20% off MAC',
        description: 'Get 20% off on MAC cosmetics',
        pointsCost: 1000,
        brandName: 'MAC',
        imageUrl: '/api/placeholder/200/200',
        category: 'Beauty',
        discountPercent: 20,
      ),
      Reward(
        id: 'underarmour_discount',
        title: '35% off Under Armour',
        description: 'Get 35% off on Under Armour products',
        pointsCost: 1800,
        brandName: 'Under Armour',
        imageUrl: '/api/placeholder/200/200',
        category: 'Sports',
        discountPercent: 35,
      ),
    ];
  }

  String _generateRedemptionCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return List.generate(8, (index) => chars[random.nextInt(chars.length)]).join();
  }

  Future<void> _redeemReward(Reward reward) async {
    if (userId.isEmpty) return;
    
    if (userFitPoints < reward.pointsCost) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Not enough Fit Points!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Generate redemption code
    final redemptionCode = _generateRedemptionCode();

    // Update user's fit points
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .update({
          'fitPoints': FieldValue.increment(-reward.pointsCost),
        });

    // Record redemption
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('redemptions')
        .add({
          'rewardId': reward.id,
          'rewardTitle': reward.title,
          'pointsCost': reward.pointsCost,
          'redemptionCode': redemptionCode,
          'redeemedAt': FieldValue.serverTimestamp(),
          'expiresAt': Timestamp.fromDate(
            DateTime.now().add(const Duration(days: 30)),
          ),
          'isUsed': false,
        });

    // Update local state
    setState(() {
      userFitPoints -= reward.pointsCost;
    });

    // Show success dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reward Redeemed!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Your redemption code is:'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                redemptionCode,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Valid for 30 days. Screenshot this code!',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredRewards = selectedCategory == 'All'
        ? rewards
        : rewards.where((r) => r.category == selectedCategory).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rewards'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                const Icon(Icons.stars, color: Colors.amber),
                const SizedBox(width: 4),
                Text(
                  '$userFitPoints FP',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildCategoryFilter(),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.8,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: filteredRewards.length,
              itemBuilder: (context, index) => _buildRewardCard(filteredRewards[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    final categories = ['All', 'Sports', 'Fashion', 'Beauty'];
    
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedCategory == category;
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  selectedCategory = category;
                });
              },
              backgroundColor: Colors.grey[200],
              selectedColor: Colors.blue[100],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRewardCard(Reward reward) {
    final canRedeem = userFitPoints >= reward.pointsCost;
    
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showRewardDetails(reward),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1.5,
              child: Image.network(
                reward.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reward.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      reward.brandName,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        const Icon(Icons.stars, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${reward.pointsCost} FP',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRewardDetails(Reward reward) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.network(
                  reward.imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reward.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        reward.brandName,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              reward.description,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.stars, color: Colors.amber),
                const SizedBox(width: 8),
                Text(
                  '${reward.pointsCost} Fit Points',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: userFitPoints >= reward.pointsCost
                    ? () {
                        Navigator.pop(context);
                        _redeemReward(reward);
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  userFitPoints >= reward.pointsCost
                      ? 'Redeem Reward'
                      : 'Not Enough Points',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
     ),
);}
}
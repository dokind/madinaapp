import 'package:flutter/material.dart';
import 'payment_page.dart';

class SubscriptionPlansPage extends StatefulWidget {
  const SubscriptionPlansPage({super.key});

  @override
  State<SubscriptionPlansPage> createState() => _SubscriptionPlansPageState();
}

class _SubscriptionPlansPageState extends State<SubscriptionPlansPage> {
  int _selectedPlanIndex = 0;

  final List<SubscriptionPlan> _plans = [
    SubscriptionPlan(
      title: 'Ежегодно',
      subtitle: '-66% скидка',
      price: '€ 94.80',
      period: 'каждый год',
      isRecommended: true,
    ),
    SubscriptionPlan(
      title: 'Ежемесячно',
      subtitle: '-53% скидка',
      price: '€ 10.90',
      period: 'каждый месяц',
      isRecommended: false,
    ),
    SubscriptionPlan(
      title: 'Еженедельно',
      subtitle: '',
      price: '€ 5.90',
      period: 'каждую неделю',
      isRecommended: false,
    ),
  ];

  final List<String> _benefits = [
    'Более высокая ставка клиентов',
    'Проверенный значок',
    'Показанный доступ',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Status bar
          const SizedBox(height: 44),
          // Navigation bar
          _buildNavigationBar(context),
          // Content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title section
                  _buildTitleSection(),
                  const SizedBox(height: 32),
                  // Plans section
                  _buildPlansSection(),
                  const SizedBox(height: 32),
                  // Benefits section
                  _buildBenefitsSection(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
          // Bottom action
          _buildBottomAction(),
        ],
      ),
    );
  }

  Widget _buildNavigationBar(BuildContext context) {
    return Container(
      height: 56,
      color: Colors.white,
      child: Row(
        children: [
          const SizedBox(width: 24),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 20,
              height: 20,
              child: const Icon(
                Icons.arrow_back_ios,
                size: 14,
                color: Color(0xFF006FFD),
              ),
            ),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Показанная подписка',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2024),
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ),
          const SizedBox(width: 44),
        ],
      ),
    );
  }

  Widget _buildTitleSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Выберите план подписки',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1F2024),
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'И получить 7-дневную бесплатную пробную версию',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF71727A),
              fontFamily: 'Inter',
              height: 1.43,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlansSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            children: _plans.asMap().entries.map((entry) {
              int index = entry.key;
              SubscriptionPlan plan = entry.value;
              bool isSelected = index == _selectedPlanIndex;

              return Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedPlanIndex = index;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color:
                            isSelected ? const Color(0xFFEAF2FF) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? Colors.transparent
                              : const Color(0xFFD4D6DD),
                          width: 0.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Radio button
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF006FFD)
                                    : const Color(0xFFC5C6CC),
                                width: isSelected ? 2 : 1.5,
                              ),
                              color: isSelected
                                  ? const Color(0xFF006FFD)
                                  : Colors.transparent,
                            ),
                            child: isSelected
                                ? const Center(
                                    child: Icon(
                                      Icons.circle,
                                      size: 6,
                                      color: Colors.white,
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 12),
                          // Plan details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  plan.title,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1F2024),
                                    fontFamily: 'Inter',
                                  ),
                                ),
                                if (plan.subtitle.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    plan.subtitle,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xFF006FFD),
                                      fontFamily: 'Inter',
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          // Price
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                plan.price,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF1F2024),
                                  fontFamily: 'Inter',
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                plan.period,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF1F2024),
                                  fontFamily: 'Inter',
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
          // Recommended badge
          if (_plans[0].isRecommended)
            Positioned(
              top: -6,
              right: -6,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: const Color(0xFF006FFD),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: const Icon(
                  Icons.star,
                  size: 10,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBenefitsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FE),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Вы получите:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1F2024),
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 16),
            ..._benefits.map((benefit) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    const Icon(
                      Icons.star,
                      size: 10,
                      color: Color(0xFF006FFD),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        benefit,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF71727A),
                          fontFamily: 'Inter',
                          height: 1.33,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomAction() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: () {
            final selectedPlan = _plans[_selectedPlanIndex];
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) => PaymentPage(
                  selectedPlan: selectedPlan.title,
                  planPrice: selectedPlan.price,
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF006FFD),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.bolt,
                size: 12,
                color: Colors.white,
              ),
              SizedBox(width: 8),
              Text(
                'Подписаться',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SubscriptionPlan {
  final String title;
  final String subtitle;
  final String price;
  final String period;
  final bool isRecommended;

  SubscriptionPlan({
    required this.title,
    required this.subtitle,
    required this.price,
    required this.period,
    required this.isRecommended,
  });
}

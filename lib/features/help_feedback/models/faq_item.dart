class FaqItem {
  final String question;
  final String answer;

  const FaqItem({
    required this.question,
    required this.answer,
  });
}

class FaqCategory {
  final String name;
  final List<FaqItem> items;

  const FaqCategory({
    required this.name,
    required this.items,
  });
}

final List<FaqCategory> faqData = [
  const FaqCategory(
    name: '🚀 Getting Started',
    items: [
      FaqItem(
        question: 'How do I add a subscription?',
        answer: 'Tap the "+" icon in the bottom navigation bar to add a new subscription. You can choose from popular presets or create a custom one.',
      ),
      FaqItem(
        question: 'How do I edit a subscription?',
        answer: 'Tap on any subscription from the Home or Subscriptions tab, then tap the "Edit" button in the top right corner.',
      ),
      FaqItem(
        question: 'How do I delete a subscription?',
        answer: 'Open the subscription details and scroll to the bottom to find the "Delete Subscription" button, or swipe left on the subscription in the list.',
      ),
    ],
  ),
  const FaqCategory(
    name: '💳 Payments & Spending',
    items: [
      FaqItem(
        question: 'How is Total Spent calculated?',
        answer: 'Total Spent is the sum of all your subscription payments for the current month. It resets at the beginning of each calendar month.',
      ),
      FaqItem(
        question: 'What is Average Monthly Cost?',
        answer: 'It calculates the normalized monthly equivalent for all your active, paid subscriptions divided by the number of those subscriptions. This gives you a clear view of your ongoing portfolio cost.',
      ),
      FaqItem(
        question: 'Why are yearly subscriptions converted to monthly cost?',
        answer: 'Normalizing all billing cycles to a monthly equivalent provides a clearer, standardized view of your ongoing financial commitments.',
      ),
    ],
  ),
  const FaqCategory(
    name: '🔔 Notifications & Reminders',
    items: [
      FaqItem(
        question: 'How do renewal reminders work?',
        answer: 'If you enable reminders for a subscription, Sanchora will send a push notification 3 days before the renewal date, and on the day of renewal.',
      ),
      FaqItem(
        question: 'Can I change reminder timing?',
        answer: 'Currently, reminders are set to 3 days before and on the day of renewal. Custom reminder timing will be available in a future update.',
      ),
    ],
  ),
  const FaqCategory(
    name: '👤 Account',
    items: [
      FaqItem(
        question: 'How do I update my profile picture?',
        answer: 'Go to the Profile tab and tap the pencil icon next to your current profile picture to select a new one or take a photo.',
      ),
      FaqItem(
        question: 'Can I change my email?',
        answer: 'Yes, you can edit your personal details including your email address from the Profile tab by tapping "Personal Information".',
      ),
    ],
  ),
  const FaqCategory(
    name: '🔒 Privacy & Security',
    items: [
      FaqItem(
        question: 'Is my subscription data secure?',
        answer: 'Yes. All your data is stored locally on your device in a secure database.',
      ),
      FaqItem(
        question: 'Does Sanchora share my data?',
        answer: 'No. Sanchora does not share, sell, or transmit your personal financial data to any third parties.',
      ),
    ],
  ),
];

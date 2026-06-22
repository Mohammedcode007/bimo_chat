class RoomGiftItem {
  final String id;
  final String name;
  final String emoji;
  final int price;
  final String videoUrl;

  const RoomGiftItem({
    required this.id,
    required this.name,
    required this.emoji,
    required this.price,
    required this.videoUrl,
  });
}

const List<RoomGiftItem> roomGiftItems = [
  RoomGiftItem(
    id: 'blue_car',
    name: 'Blue Car',
    emoji: '🚙',
    price: 100,
    videoUrl: 'https://a.top4top.io/m_3819525l40.mp4',
  ),
  RoomGiftItem(
    id: 'super_man',
    name: 'Super Man',
    emoji: '🦸‍♂️',
    price: 200,
    videoUrl: 'https://te-bot.site/uploads/gifts/super-man.mp4',
  ),
  RoomGiftItem(
    id: 'black_tiger',
    name: 'Black Tiger',
    emoji: '🐅',
    price: 250,
    videoUrl: 'https://te-bot.site/uploads/gifts/black-tiger.mp4',
  ),
];
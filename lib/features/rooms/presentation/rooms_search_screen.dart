import 'package:flutter/material.dart';
import '../../../core/utils/responsive.dart';

class RoomsSearchScreen extends StatefulWidget {
  const RoomsSearchScreen({super.key});

  @override
  State<RoomsSearchScreen> createState() => _RoomsSearchScreenState();
}

class _RoomsSearchScreenState extends State<RoomsSearchScreen> {
  final searchController = TextEditingController();
  final focusNode = FocusNode();

  String query = '';

  final List<String> rooms = const [
    'كوكاتو',
    'ملتقى العرب',
    'ورق الورد',
    'strangers',
    'سورياالحب',
    'عشق',
    'عراقي بغدادي',
    'أتكيت',
    'Night Room',
    'Friends',
  ];

  List<String> get filteredRooms {
    final text = query.trim().toLowerCase();

    if (text.isEmpty) {
      return [];
    }

    return rooms.where((room) {
      return room.toLowerCase().contains(text);
    }).toList();
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  void updateSearch(String value) {
    setState(() {
      query = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final items = filteredRooms;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: R.size(context, 66),
              padding: EdgeInsets.symmetric(horizontal: R.size(context, 24)),
              alignment: Alignment.center,
              child: Container(
                height: R.size(context, 50),
                padding: EdgeInsetsDirectional.only(
                  start: R.size(context, 4),
                  end: R.size(context, 14),
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(R.size(context, 40)),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.arrow_back_rounded,
                        color: const Color(0xFF087282),
                        size: R.size(context, 28),
                      ),
                    ),

                    SizedBox(width: R.size(context, 8)),

                    Icon(
                      Icons.search_rounded,
                      size: R.size(context, 28),
                      color: colorScheme.onSurface,
                    ),

                    SizedBox(width: R.size(context, 10)),

                    Expanded(
                      child: TextField(
                        controller: searchController,
                        focusNode: focusNode,
                        autofocus: true,
                        onChanged: updateSearch,
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: R.sp(context, 22),
                          fontWeight: FontWeight.w400,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search',
                          hintStyle: TextStyle(
                            color: colorScheme.onSurface.withValues(
                              alpha: 0.35,
                            ),
                            fontSize: R.sp(context, 22),
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Divider(height: 1, color: colorScheme.outlineVariant),

            Expanded(
              child: query.trim().isEmpty
                  ? Center(
                      child: Text(
                        'Search for rooms',
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: R.sp(context, 16),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  : items.isEmpty
                  ? Center(
                      child: Text(
                        'No rooms found',
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: R.sp(context, 16),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(
                        vertical: R.size(context, 8),
                      ),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final room = items[index];

                        return ListTile(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Open room: $room'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          leading: CircleAvatar(
                            radius: R.size(context, 22),
                            backgroundColor: colorScheme.primary.withValues(
                              alpha: 0.12,
                            ),
                            child: Text(
                              room.characters.first,
                              style: TextStyle(
                                color: colorScheme.primary,
                                fontSize: R.sp(context, 17),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          title: Text(
                            room,
                            style: TextStyle(
                              color: colorScheme.onSurface,
                              fontSize: R.sp(context, 17),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: R.size(context, 16),
                            color: colorScheme.onSurfaceVariant,
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../core/utils/responsive.dart';

class CreateRoomScreen extends StatefulWidget {
  const CreateRoomScreen({super.key});

  @override
  State<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> {
  final roomNameController = TextEditingController();
  bool isPrivate = false;

  @override
  void dispose() {
    roomNameController.dispose();
    super.dispose();
  }

  void createRoom() {
    final roomName = roomNameController.text.trim();

    if (roomName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Room name is required'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            R.size(context, 42),
            R.size(context, 36),
            R.size(context, 42),
            R.size(context, 16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: roomNameController,
                style: TextStyle(
                  fontSize: R.sp(context, 24),
                  color: colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: 'Room name',
                  hintStyle: TextStyle(
                    color: colorScheme.onSurface.withValues(alpha: 0.35),
                    fontSize: R.sp(context, 24),
                    fontWeight: FontWeight.w400,
                  ),
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(color: colorScheme.onSurface),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: colorScheme.onSurface),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: colorScheme.onSurface,
                      width: R.size(context, 1.4),
                    ),
                  ),
                ),
              ),

              SizedBox(height: R.size(context, 28)),

              Row(
                children: [
                  SizedBox(
                    width: R.size(context, 28),
                    height: R.size(context, 28),
                    child: Checkbox(
                      value: isPrivate,
                      onChanged: (value) {
                        setState(() {
                          isPrivate = value ?? false;
                        });
                      },
                      side: BorderSide(
                        color: colorScheme.onSurface.withValues(alpha: 0.8),
                        width: R.size(context, 2.4),
                      ),
                    ),
                  ),
                  SizedBox(width: R.size(context, 12)),
                  Text(
                    'Private rooms',
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: R.sp(context, 21),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              SizedBox(height: R.size(context, 34)),

              Center(
                child: SizedBox(
                  width: R.size(context, 210),
                  height: R.size(context, 58),
                  child: ElevatedButton(
                    onPressed: createRoom,
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: const Color(0xFF087887),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          R.size(context, 40),
                        ),
                      ),
                    ),
                    child: Text(
                      'Create Room',
                      style: TextStyle(
                        fontSize: R.sp(context, 21),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: R.size(context, 18)),

              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    'Please read the following terms and conditions\n'
                    'carefully before creating a room:\n'
                    '  1.  Creating a public room costs 50, 000 TCoins.\n'
                    'This fee helps prevent spam and ensures a quality\n'
                    'experience for all users.\n'
                    '  2.  Each public room must be boosted at least\n'
                    '30 times per month to remain active for the next\n'
                    'month.\n'
                    '  3.  Rooms with offensive or inappropriate names,\n'
                    'or those that violate community guidelines, will be\n'
                    'removed. TCoins will not be refunded in such cases.\n\n'
                    'By confirming your room creation, you agree to\n'
                    'these terms and conditions.',
                    style: TextStyle(
                      color: colorScheme.onSurface.withValues(alpha: 0.76),
                      fontSize: R.sp(context, 20),
                      height: 1.22,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/responsive.dart';
import '../logic/rooms_provider.dart';

class CreateRoomScreen extends ConsumerStatefulWidget {
  const CreateRoomScreen({super.key});

  @override
  ConsumerState<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends ConsumerState<CreateRoomScreen> {
  final roomNameController = TextEditingController();
  final passwordController = TextEditingController();

  bool isPrivate = false;
  bool voiceEnabled = false;
  bool loading = false;

  @override
  void dispose() {
    roomNameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> createRoom() async {
    final roomName = roomNameController.text.trim();
    final password = passwordController.text.trim();

    if (roomName.isEmpty) {
      showMessage('Room name is required');
      return;
    }

    if (roomName.length > 50) {
      showMessage('Room name must be 50 characters or less');
      return;
    }

    if (isPrivate && password.length < 4) {
      showMessage('Password must be at least 4 characters');
      return;
    }

    setState(() {
      loading = true;
    });

    ref.read(roomsProvider.notifier).createRoom(
          name: roomName,
          description: '',
          password: isPrivate ? password : '',
          voiceEnabled: voiceEnabled,
        );

    await Future.delayed(const Duration(milliseconds: 300));

    if (!mounted) return;

    setState(() {
      loading = false;
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    ref.listen(roomsProvider, (previous, next) {
      if (next.error != null && next.error!.isNotEmpty) {
        if (!mounted) return;

        setState(() {
          loading = false;
        });

        showMessage(next.error!);
      }
    });

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
                maxLength: 50,
                style: TextStyle(
                  fontSize: R.sp(context, 24),
                  color: colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  counterText: '',
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

              SizedBox(height: R.size(context, 24)),

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

                          if (!isPrivate) {
                            passwordController.clear();
                          }
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
                    'Private room',
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: R.sp(context, 21),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              if (isPrivate) ...[
                SizedBox(height: R.size(context, 18)),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  maxLength: 50,
                  style: TextStyle(
                    fontSize: R.sp(context, 22),
                    color: colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: 'Room password',
                    hintStyle: TextStyle(
                      color: colorScheme.onSurface.withValues(alpha: 0.35),
                      fontSize: R.sp(context, 22),
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
              ],

              SizedBox(height: R.size(context, 22)),

              Row(
                children: [
                  SizedBox(
                    width: R.size(context, 28),
                    height: R.size(context, 28),
                    child: Checkbox(
                      value: voiceEnabled,
                      onChanged: (value) {
                        setState(() {
                          voiceEnabled = value ?? false;
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
                    'Voice room',
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
                    onPressed: loading ? null : createRoom,
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: const Color(0xFF087887),
                      disabledBackgroundColor:
                          const Color(0xFF087887).withValues(alpha: 0.45),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          R.size(context, 40),
                        ),
                      ),
                    ),
                    child: loading
                        ? SizedBox(
                            width: R.size(context, 22),
                            height: R.size(context, 22),
                            child: const CircularProgressIndicator(
                              strokeWidth: 2.4,
                              color: Colors.white,
                            ),
                          )
                        : Text(
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
                    '  1. Room name must not contain offensive words.\n'
                    '  2. The creator is responsible for managing owners, admins, members and bans.\n'
                    '  3. Private rooms require a password.\n'
                    '  4. Voice room option makes the room appear in the Voice tab.\n'
                    '  5. Rooms that violate community guidelines may be removed.\n\n'
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
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sonus/core/network/backend_service.dart';
import 'package:sonus/features/create/presentation/widgets/create_widgets.dart';

class CreatePage extends ConsumerStatefulWidget {
  const CreatePage({super.key});

  @override
  ConsumerState<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends ConsumerState<CreatePage> {
  final _nameController = TextEditingController();
  bool _isCreating = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _createPlaylist() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a playlist name'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isCreating = true);

    final backend = ref.read(backendServiceProvider);
    final result = await backend.createPlaylist(title: name);

    setState(() => _isCreating = false);

    if (result != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Playlist "$name" created!'), backgroundColor: Colors.green),
      );
      _nameController.clear();
      context.pushNamed('playlist-detail', pathParameters: {'id': result['id'] ?? ''}, extra: result);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create playlist'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF400503), Colors.black],
            stops: [0.0, 0.3],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.h),
                    child: const CreateHeader(),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 16.h),
                    child: CreateInputSection(controller: _nameController),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 24.h),
                    child: SizedBox(
                      width: double.infinity,
                      height: 48.h,
                      child: ElevatedButton(
                        onPressed: _isCreating ? null : _createPlaylist,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        ),
                        child: _isCreating
                            ? SizedBox(width: 20.r, height: 20.r, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : Text('Create Playlist', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ),
                SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16.h,
                    crossAxisSpacing: 16.w,
                    childAspectRatio: 0.7,
                  ),
                  delegate: SliverChildListDelegate([
                    CreateOptionCard(
                      icon: Icons.playlist_add,
                      title: 'Playlist',
                      subtitle: 'Build a playlist with songs, or episodes',
                      gradient: const LinearGradient(
                        colors: [Color(0xFF450af5), Color(0xFFc4efd9)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      onTap: () {},
                    ),
                    const CreateOptionCard(
                      icon: Icons.group_add,
                      title: 'Blend',
                      subtitle: 'Combine tastes in a shared playlist',
                      gradient: LinearGradient(
                        colors: [Color(0xFFff6b6b), Color(0xFF556270)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    const CreateOptionCard(
                      icon: Icons.speaker_group,
                      title: 'Jam',
                      subtitle: 'Listen together with your group',
                      gradient: LinearGradient(
                        colors: [Color(0xFFf093fb), Color(0xFFf5576c)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    const CreateOptionCard(
                      icon: Icons.folder,
                      title: 'Folder',
                      subtitle: 'Organize your library',
                      gradient: LinearGradient(
                        colors: [Color(0xFF4ca1af), Color(0xFFc4e0e5)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ]),
                ),
                SliverToBoxAdapter(child: SizedBox(height: 32.h)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 16.h),
                    child: Text(
                      'Start with a template',
                      style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 180.h,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: const [
                        TemplateCard(title: 'Running', imageUrl: 'https://images.unsplash.com/photo-1552674605-46f538355272?auto=format&fit=crop&w=300&q=80'),
                        TemplateCard(title: 'Party', imageUrl: 'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?auto=format&fit=crop&w=300&q=80'),
                        TemplateCard(title: 'Relax', imageUrl: 'https://images.unsplash.com/photo-1516280440614-6697288d5d38?auto=format&fit=crop&w=300&q=80'),
                        TemplateCard(title: 'Focus', imageUrl: 'https://images.unsplash.com/photo-1456324504439-367cee10d6b1?auto=format&fit=crop&w=300&q=80'),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(child: SizedBox(height: 180.h)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

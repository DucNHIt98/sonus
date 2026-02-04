import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sonus/features/create/presentation/widgets/create_widgets.dart';

class CreatePage extends StatelessWidget {
  const CreatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            // Consistent Gradient
            colors: [Color(0xFF400503), Colors.black],
            stops: [0.0, 0.3],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: CustomScrollView(
              slivers: [
                // 1. Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.h),
                    child: const CreateHeader(),
                  ),
                ),

                // 2. Input Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 40.h),
                    child: const CreateInputSection(),
                  ),
                ),

                // 3. Create Options Grid
                SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16.h,
                    crossAxisSpacing: 16.w,
                    childAspectRatio: 0.7, // Taller cards to prevent overflow
                  ),
                  delegate: SliverChildListDelegate([
                    const CreateOptionCard(
                      icon: Icons.playlist_add,
                      title: 'Playlist',
                      subtitle: 'Build a playlist with songs, or episodes',
                      gradient: LinearGradient(
                        colors: [Color(0xFF450af5), Color(0xFFc4efd9)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
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

                // 4. Templates Section Title
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 16.h),
                    child: Text(
                      'Start with a template',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                // 5. Templates List
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 180.h,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: const [
                        TemplateCard(
                          title: 'Running',
                          imageUrl:
                              'https://images.unsplash.com/photo-1552674605-46f538355272?auto=format&fit=crop&w=300&q=80',
                        ),
                        TemplateCard(
                          title: 'Party',
                          imageUrl:
                              'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?auto=format&fit=crop&w=300&q=80',
                        ),
                        TemplateCard(
                          title: 'Relax',
                          imageUrl:
                              'https://images.unsplash.com/photo-1516280440614-6697288d5d38?auto=format&fit=crop&w=300&q=80',
                        ),
                        TemplateCard(
                          title: 'Focus',
                          imageUrl:
                              'https://images.unsplash.com/photo-1456324504439-367cee10d6b1?auto=format&fit=crop&w=300&q=80',
                        ),
                      ],
                    ),
                  ),
                ),

                // Extra space
                SliverToBoxAdapter(child: SizedBox(height: 180.h)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

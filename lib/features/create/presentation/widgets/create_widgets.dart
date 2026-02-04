import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CreateHeader extends StatelessWidget {
  const CreateHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Start something new',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Create a playlist, a blend, or a jam.',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 14.sp,
          ),
        ),
      ],
    );
  }
}

class CreateInputSection extends StatelessWidget {
  const CreateInputSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 20.h),
        Container(
          height: 180.h,
          width: 180.w,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 15.r,
                offset: Offset(0, 8.h),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              Icons.music_note,
              size: 80.r,
              color: Colors.white.withOpacity(0.3),
            ),
          ),
        ),
        SizedBox(height: 30.h),
        TextField(
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
          ),
          decoration: InputDecoration(
            hintText: 'Give your playlist a name',
            hintStyle: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
            ),
            border: InputBorder.none,
          ),
        ),
        SizedBox(height: 10.h),
        Container(
          width: 60.w,
          height: 4.h,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
      ],
    );
  }
}

class CreateOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Gradient gradient;

  const CreateOptionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(12.r),
      ),
      padding: EdgeInsets.all(20.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 28.r),
          ),
          SizedBox(height: 20.h),
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 8.h),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class TemplateCard extends StatelessWidget {
  final String title;
  final String imageUrl;

  const TemplateCard({super.key, required this.title, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140.w,
      margin: EdgeInsets.only(right: 16.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
          ),
        ),
        alignment: Alignment.bottomCenter,
        padding: EdgeInsets.all(12.r),
        child: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

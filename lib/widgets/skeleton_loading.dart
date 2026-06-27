import 'package:flutter/material.dart';

class SkeletonLoading extends StatefulWidget {
  final int itemCount;
  final bool isGrid;

  const SkeletonLoading({
    super.key,
    this.itemCount = 6,
    this.isGrid = true,
  });

  @override
  State<SkeletonLoading> createState() => _SkeletonLoadingState();
}

class _SkeletonLoadingState extends State<SkeletonLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _shimmer;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _shimmer = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isGrid) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.itemCount,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 0.68,
          ),
          itemBuilder: (_, i) => _buildCardSkeleton(),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: List.generate(
          widget.itemCount > 4 ? 4 : widget.itemCount,
          (_) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildListSkeleton(),
          ),
        ),
      ),
    );
  }

  Widget _buildCardSkeleton() {
    return AnimatedBuilder(
      animation: _shimmer,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image placeholder
              Container(
                height: 115,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: _shimmerColor(),
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _skeletonLine(width: double.infinity, height: 12),
                    const SizedBox(height: 8),
                    _skeletonLine(width: 80, height: 14),
                    const SizedBox(height: 8),
                    _skeletonLine(width: 60, height: 10),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildListSkeleton() {
    return AnimatedBuilder(
      animation: _shimmer,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: _shimmerColor(),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _skeletonLine(width: double.infinity, height: 14),
                    const SizedBox(height: 6),
                    _skeletonLine(width: 100, height: 14),
                    const SizedBox(height: 6),
                    _skeletonLine(width: 60, height: 10),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _skeletonLine({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: _shimmerColor(),
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }

  Color _shimmerColor() {
    final value = (_shimmer.value + 2) / 4; // normalize to 0-1
    return Color.lerp(
      const Color(0xFFEEEEEE),
      const Color(0xFFF5F5F5),
      value,
    )!;
  }
}

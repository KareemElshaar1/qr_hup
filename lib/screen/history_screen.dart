import 'package:barcode_app/l10n/app_strings.dart';
import 'package:barcode_app/models/qr_record.dart';
import 'package:barcode_app/screen/scan_result_screen.dart';
import 'package:barcode_app/services/history_service.dart';
import 'package:barcode_app/services/qr_content_detector.dart';
import 'package:barcode_app/theme/app_theme.dart';
import 'package:barcode_app/utils/app_responsive.dart';
import 'package:barcode_app/widgets/responsive_layout.dart';
import 'package:barcode_app/widgets/ui_components.dart';
import 'package:flutter/material.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key, this.favoritesOnly = false});

  final bool favoritesOnly;

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _search = TextEditingController();
  QrRecordCategory? _filter;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<QrRecord> get _items {
    final source = widget.favoritesOnly
        ? HistoryService.instance.favorites
        : HistoryService.instance.records;
    final q = _search.text.trim().toLowerCase();
    return source.where((record) {
      if (_filter != null && record.category != _filter) return false;
      if (q.isEmpty) return true;
      return record.title.toLowerCase().contains(q) ||
          record.content.toLowerCase().contains(q);
    }).toList();
  }

  String _categoryLabel(BuildContext context, QrRecordCategory c) {
    return AppStrings.categoryLabel(context, c);
  }

  @override
  Widget build(BuildContext context) {
    final colors = colorsOf(context);
    final items = _items;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          widget.favoritesOnly ? context.tr('favorites') : context.tr('history'),
        ),
        actions: [
          if (!widget.favoritesOnly)
            IconButton(
              onPressed: () async {
                await HistoryService.instance.clearAll();
                if (mounted) setState(() {});
              },
              icon: const Icon(Icons.delete_sweep_rounded),
            ),
        ],
      ),
      body: GradientBackground(
        child: SafeArea(
          child: ResponsiveLayout(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 12.h),
                  child: TextField(
                    controller: _search,
                    onChanged: (_) => setState(() {}),
                    style: TextStyle(color: colors.textPrimary, fontSize: 14.sp),
                    decoration: InputDecoration(
                      hintText: context.tr('search_hint'),
                      prefixIcon: Icon(Icons.search_rounded, color: colors.accent),
                    ),
                  ),
                ),
                SizedBox(
                  height: 44.h,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    children: [
                      FilterChip(
                        label: Text(context.tr('filter_all')),
                        selected: _filter == null,
                        onSelected: (_) => setState(() => _filter = null),
                      ),
                      ...QrRecordCategory.values.map(
                        (c) => Padding(
                          padding: EdgeInsetsDirectional.only(start: 8.w),
                          child: FilterChip(
                            label: Text(_categoryLabel(context, c)),
                            selected: _filter == c,
                            onSelected: (_) => setState(() => _filter = c),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: items.isEmpty
                      ? Center(
                          child: Text(
                            widget.favoritesOnly
                                ? context.tr('empty_favorites')
                                : context.tr('empty_history'),
                            style: TextStyle(color: colors.textMuted, fontSize: 14.sp),
                          ),
                        )
                      : ListView.separated(
                          padding: EdgeInsets.all(20.w),
                        itemCount: items.length,
                        separatorBuilder: (_, index) => SizedBox(height: 10.h),
                        itemBuilder: (context, index) {
                          final record = items[index];
                          return _RecordTile(
                            record: record,
                            onTap: () {
                              final content = QrContentDetector.analyze(record.content);
                              Navigator.push(
                                context,
                                fadeSlideRoute(
                                  ScanResultScreen(
                                    content: content,
                                    recordId: record.id,
                                    autoOpenLink: false,
                                  ),
                                ),
                              );
                            },
                            onDelete: () async {
                              await HistoryService.instance.delete(record.id);
                              if (mounted) setState(() {});
                            },
                            onFavorite: () async {
                              await HistoryService.instance.toggleFavorite(record.id);
                              if (mounted) setState(() {});
                            },
                          );
                        },
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RecordTile extends StatelessWidget {
  const _RecordTile({
    required this.record,
    required this.onTap,
    required this.onDelete,
    required this.onFavorite,
  });

  final QrRecord record;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onFavorite;

  @override
  Widget build(BuildContext context) {
    final colors = colorsOf(context);
    return Material(
      color: colors.surface.withValues(alpha: 0.85),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Icon(
                record.kind == QrRecordKind.scanned
                    ? Icons.qr_code_scanner_rounded
                    : Icons.qr_code_2_rounded,
                color: colors.accent,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.title,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      record.content.length > 60
                          ? '${record.content.substring(0, 60)}...'
                          : record.content,
                      style: TextStyle(color: colors.textMuted, fontSize: 12),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onFavorite,
                icon: Icon(
                  record.isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: record.isFavorite ? Colors.amber : colors.textMuted,
                ),
              ),
              IconButton(
                onPressed: onDelete,
                icon: Icon(Icons.delete_outline_rounded, color: colors.danger),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

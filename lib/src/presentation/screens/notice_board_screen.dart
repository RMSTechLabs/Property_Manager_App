// Notice Board Screen - Responsive with Search, Filter, and Local State Management
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:property_manager_app/src/core/constants/app_constants.dart';
import 'package:property_manager_app/src/core/utils/app_helper.dart';
import 'package:property_manager_app/src/core/utils/app_snackbar.dart';
import 'package:property_manager_app/src/data/models/notice_model.dart';
import 'package:property_manager_app/src/presentation/notifiers/notice_notifier.dart';
import 'package:redacted/redacted.dart';
import 'package:share_plus/share_plus.dart';

class NoticeBoardScreen extends ConsumerStatefulWidget {
  const NoticeBoardScreen({super.key});

  @override
  ConsumerState<NoticeBoardScreen> createState() => _NoticeBoardScreenState();
}

class _NoticeBoardScreenState extends ConsumerState<NoticeBoardScreen>
    with RouteAware {
  bool _isSearchActive = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  // Local state for features without API
  Set<String> _unreadNoticeIds = {};
  Set<String> _savedNoticeIds = {};
  Set<String> _selectedCategories = {};

  // Filter states
  bool _showUnreadOnly = false;
  bool _showSavedOnly = false;

  final List<String> _categoryOptions = [
    "Minutes of Meetings",
    "Association Bye-Laws",
    "General Notice",
    "Admin Notice",
    "Event Notice",
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    // Initialize some sample unread notices for demo
    _initializeSampleData();
  }

  void _initializeSampleData() {
    // 🔥 DEMO: Initially empty - notices are marked as unread when user clicks
    // 🔥 PRODUCTION: This will be replaced with API call to get unread notice IDs
    // Example: _unreadNoticeIds = await getUnreadNoticeIds();
    _unreadNoticeIds = {};

    // 🔥 To test unread functionality, you can temporarily add some IDs:
    // _unreadNoticeIds = {'1', '2'}; // Uncomment to test unread notices
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final ModalRoute? route = ModalRoute.of(context);
    if (route is PageRoute) {
      // routeObserver.subscribe(this, route); // Uncomment if you have routeObserver
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    // routeObserver.unsubscribe(this); // Uncomment if you have routeObserver
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
  }

  Future<void> _onRefresh() async {
    await ref.read(noticeProvider.notifier).refreshNotices();
    // Reset local state on refresh if needed
  }

  @override
  void didPopNext() {
    ref.read(noticeProvider.notifier).refreshNotices();
  }

  void _toggleSearch() {
    setState(() {
      _isSearchActive = !_isSearchActive;
      if (!_isSearchActive) {
        _searchController.clear();
        _searchQuery = "";
      }
    });
  }

  void _markAsRead(String noticeId) {
    setState(() {
      _unreadNoticeIds.remove(noticeId);
    });

    // 🔥 REPLACE WITH API CALL WHEN READY:
    // ref.read(noticeProvider.notifier).markNoticeAsRead(noticeId);
    // ref.invalidate(unreadNoticeIdsProvider);
  }

  void _toggleSaved(String noticeId) {
    setState(() {
      if (_savedNoticeIds.contains(noticeId)) {
        _savedNoticeIds.remove(noticeId);
      } else {
        _savedNoticeIds.add(noticeId);
      }
    });

    // 🔥 REPLACE WITH API CALL WHEN READY:
    // ref.read(noticeProvider.notifier).toggleNoticeSaved(noticeId);
    // ref.invalidate(savedNoticeIdsProvider);
  }

  void _toggleUnreadFilter() {
    setState(() {
      _showUnreadOnly = !_showUnreadOnly;
      if (_showUnreadOnly) _showSavedOnly = false;
    });
  }

  void _toggleSavedFilter() {
    setState(() {
      _showSavedOnly = !_showSavedOnly;
      if (_showSavedOnly) _showUnreadOnly = false;
    });
  }

  void _showCategoryFilter() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildCategoryFilterSheet(),
    );
  }

  List<NoticeModel> _getFilteredNotices(List<NoticeModel> notices) {
    var filtered = notices;

    // Search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (notice) =>
                notice.title.toLowerCase().contains(_searchQuery) ||
                // notice.description.toLowerCase().contains(_searchQuery) ||
                notice.content.toLowerCase().contains(_searchQuery),
          )
          .toList();
    }

    // 🔥 CURRENT: Unread filter using local state
    if (_showUnreadOnly) {
      filtered = filtered
          .where((notice) => _unreadNoticeIds.contains(notice.id))
          .toList();
    }
    // 🔥 FUTURE: When API is ready, replace above with:
    // if (_showUnreadOnly) {
    //   final unreadIds = ref.watch(unreadNoticeIdsProvider).value ?? [];
    //   filtered = filtered.where((notice) => unreadIds.contains(notice.id)).toList();
    // }

    // 🔥 CURRENT: Saved filter using local state
    if (_showSavedOnly) {
      filtered = filtered
          .where((notice) => _savedNoticeIds.contains(notice.id))
          .toList();
    }
    // 🔥 FUTURE: When API is ready, replace above with:
    // if (_showSavedOnly) {
    //   final savedIds = ref.watch(savedNoticeIdsProvider).value ?? [];
    //   filtered = filtered.where((notice) => savedIds.contains(notice.id)).toList();
    // }

    // Category filter (this stays the same)
    if (_selectedCategories.isNotEmpty) {
      filtered = filtered
          .where((notice) => _selectedCategories.contains(notice.category))
          .toList();
    }

    return filtered;
  }

  // 🔥 COUNTS - Currently using local state
  // When API is ready, replace with:
  // final unreadCount = ref.watch(unreadNoticesCountProvider).value ?? 0;
  // final savedIds = ref.watch(savedNoticeIdsProvider).value ?? [];
  // final savedCount = savedIds.length;
  int get _unreadCount => _unreadNoticeIds.length;
  int get _savedCount => _savedNoticeIds.length;

  void _onNoticeTap(NoticeModel notice) {
    // Mark notice as read when user taps on it
    _markAsRead(notice.id);
    // Navigate to notice detail
    // Safe navigation
    Future.microtask(() {
      if (!mounted) return;
      context.pushNamed(
        'noticeDetail',
        pathParameters: {'id': notice.noticeId},
      );
    });
  }

  // 🔥 Method to mark a notice as unread (for demo purposes)
  // This would typically be managed by the API based on user read status
  void _markAsUnread(String noticeId) {
    setState(() {
      _unreadNoticeIds.add(noticeId);
    });
  }

  Future<void> _shareNotice(NoticeModel notice) async {
    try {
      await Share.share(
        'Check out this notice: ${AppHelper.stripHtmlTagsNew(notice.title)}\n\n${AppHelper.stripHtmlTagsNew(notice.description)}',
        subject: AppHelper.stripHtmlTagsNew(notice.title),
      );
    } catch (e) {
      if (!mounted) return;
      AppSnackBar.showError(
        context: context,
        message: 'Could not share notice',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final notices = ref.watch(noticeProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppConstants.secondartGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(screenWidth),

              // Content Area
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(top: screenHeight * 0.02),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Filter Bar
                      _buildFilterBar(screenWidth),

                      // Notices List
                      Expanded(
                        child: notices.when(
                          loading: () => _buildSkeletonLoader(screenWidth),
                          error: (e, _) =>
                              Center(child: Text('Error: ${e.toString()}')),
                          data: (noticesList) {
                            final filtered = _getFilteredNotices(noticesList);
                            return RefreshIndicator(
                              onRefresh: _onRefresh,
                              child: filtered.isEmpty
                                  ? _buildEmptyState(screenWidth)
                                  : _buildNoticesList(filtered, screenWidth),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(double screenWidth) {
    final isSmallScreen = screenWidth < 360;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.all(screenWidth * 0.05),
      child: Row(
        children: [
          if (!_isSearchActive) ...[
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: screenWidth * 0.12,
                height: screenWidth * 0.12,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha:0.2),
                  borderRadius: BorderRadius.circular(screenWidth * 0.06),
                ),
                child: Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                  size: screenWidth * 0.05,
                ),
              ),
            ),
            SizedBox(width: screenWidth * 0.04),
            Expanded(
              child: Text(
                "Notice Board",
                style: GoogleFonts.lato(
                  color: Colors.white,
                  fontSize: isSmallScreen
                      ? screenWidth * 0.045
                      : screenWidth * 0.05,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ] else ...[
            GestureDetector(
              onTap: _toggleSearch,
              child: Container(
                width: screenWidth * 0.12,
                height: screenWidth * 0.12,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha:0.2),
                  borderRadius: BorderRadius.circular(screenWidth * 0.06),
                ),
                child: Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                  size: screenWidth * 0.05,
                ),
              ),
            ),
            SizedBox(width: screenWidth * 0.04),
            Expanded(
              child: Container(
                height: screenWidth * 0.12,
                decoration: BoxDecoration(
                  color: AppConstants.whiteColor,
                  borderRadius: BorderRadius.circular(screenWidth * 0.06),
                ),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  style: GoogleFonts.lato(
                    color: AppConstants.black50,
                    fontSize: isSmallScreen
                        ? screenWidth * 0.035
                        : screenWidth * 0.04,
                  ),
                  decoration: InputDecoration(
                    hintText: "Search by title",
                    hintStyle: GoogleFonts.lato(
                      color: Colors.black.withValues(alpha:0.7),
                      fontSize: isSmallScreen
                          ? screenWidth * 0.035
                          : screenWidth * 0.04,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.black.withValues(alpha:0.7),
                      size: screenWidth * 0.05,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.04,
                      vertical: screenWidth * 0.03,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: screenWidth * 0.04),
            GestureDetector(
              onTap: () {
                _searchController.clear();
                _toggleSearch();
              },
              child: Container(
                width: screenWidth * 0.12,
                height: screenWidth * 0.12,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha:0.2),
                  borderRadius: BorderRadius.circular(screenWidth * 0.06),
                ),
                child: Icon(
                  Icons.close,
                  color: Colors.white,
                  size: screenWidth * 0.05,
                ),
              ),
            ),
          ],
          if (!_isSearchActive) ...[
            IconButton(
              onPressed: _toggleSearch,
              icon: Icon(
                Icons.search,
                color: Colors.white,
                size: screenWidth * 0.06,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterBar(double screenWidth) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.05,
        vertical: screenWidth * 0.04,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // Unread Filter
            // _buildFilterChip(
            //   label: "Unread",
            //   count: _unreadCount,
            //   isSelected: _showUnreadOnly,
            //   onTap: _toggleUnreadFilter,
            //   screenWidth: screenWidth,
            // ),
            // SizedBox(width: screenWidth * 0.03),

            // // Saved Filter
            // _buildFilterChip(
            //   label: "Saved",
            //   count: _savedCount,
            //   isSelected: _showSavedOnly,
            //   onTap: _toggleSavedFilter,
            //   screenWidth: screenWidth,
            //   icon: Icons.bookmark_outline,
            //   selectedIcon: Icons.bookmark,
            // ),

            // SizedBox(width: screenWidth * 0.03),

            // Category Filter
            GestureDetector(
              onTap: _showCategoryFilter,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.035,
                  vertical: screenWidth * 0.025,
                ),
                decoration: BoxDecoration(
                  color: _selectedCategories.isNotEmpty
                      ? const Color(0xFF6366F1)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _selectedCategories.isNotEmpty
                        ? const Color(0xFF6366F1)
                        : Colors.grey.shade300,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      screenWidth < 360 ? "Category" : "Notice Category",
                      style: GoogleFonts.lato(
                        fontSize: screenWidth < 360
                            ? screenWidth * 0.032
                            : screenWidth * 0.035,
                        color: _selectedCategories.isNotEmpty
                            ? Colors.white
                            : AppConstants.black50,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.015),
                    Icon(
                      Icons.keyboard_arrow_down,
                      size: screenWidth * 0.04,
                      color: _selectedCategories.isNotEmpty
                          ? Colors.white
                          : AppConstants.black50,
                    ),
                  ],
                ),
              ),
            ),

            // Add some padding at the end for better scrolling
            SizedBox(width: screenWidth * 0.05),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required int count,
    required bool isSelected,
    required VoidCallback onTap,
    required double screenWidth,
    IconData? icon,
    IconData? selectedIcon,
  }) {
    // Responsive sizing based on screen width
    final isSmallScreen = screenWidth < 360;
    final isMediumScreen = screenWidth < 400;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? screenWidth * 0.03 : screenWidth * 0.035,
          vertical: screenWidth * 0.02,
        ),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6366F1) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF6366F1) : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                isSelected ? (selectedIcon ?? icon) : icon,
                size: isSmallScreen ? screenWidth * 0.035 : screenWidth * 0.04,
                color: isSelected ? Colors.white : AppConstants.black50,
              ),
              SizedBox(width: screenWidth * 0.015),
            ],
            Text(
              label,
              style: GoogleFonts.lato(
                fontSize: isSmallScreen
                    ? screenWidth * 0.032
                    : isMediumScreen
                    ? screenWidth * 0.033
                    : screenWidth * 0.035,
                color: isSelected ? Colors.white : AppConstants.black50,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(width: screenWidth * 0.01),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen
                    ? screenWidth * 0.015
                    : screenWidth * 0.02,
                vertical: screenWidth * 0.003,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha:0.3)
                    : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count.toString(),
                style: GoogleFonts.lato(
                  fontSize: isSmallScreen
                      ? screenWidth * 0.028
                      : screenWidth * 0.03,
                  color: isSelected ? Colors.white : AppConstants.black50,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilterSheet() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return StatefulBuilder(
      builder: (context, setSheetState) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                margin: EdgeInsets.only(top: screenWidth * 0.02),
                height: 4,
                width: screenWidth * 0.12,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Container(
                padding: EdgeInsets.all(screenWidth * 0.05),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Notice Category",
                      style: GoogleFonts.lato(
                        fontSize: screenWidth * 0.05,
                        fontWeight: FontWeight.w600,
                        color: AppConstants.black,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setSheetState(() {
                          _selectedCategories.clear();
                        });
                        setState(() {});
                      },
                      child: Text(
                        "Clear All",
                        style: GoogleFonts.lato(
                          fontSize: screenWidth * 0.035,
                          color: const Color(0xFF6366F1),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Category Options
              Container(
                constraints: BoxConstraints(maxHeight: screenHeight * 0.4),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _categoryOptions.length,
                  itemBuilder: (context, index) {
                    final category = _categoryOptions[index];
                    final isSelected = _selectedCategories.contains(category);

                    return Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.05,
                        vertical: screenWidth * 0.01,
                      ),
                      child: CheckboxListTile(
                        value: isSelected,
                        onChanged: (value) {
                          setSheetState(() {
                            if (value == true) {
                              _selectedCategories.add(category);
                            } else {
                              _selectedCategories.remove(category);
                            }
                          });
                        },
                        title: Text(
                          category,
                          style: GoogleFonts.lato(
                            fontSize: screenWidth * 0.04,
                            color: AppConstants.black,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        activeColor: const Color(0xFF6366F1),
                        checkColor: Colors.white,
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                      ),
                    );
                  },
                ),
              ),

              // Apply Button
              Container(
                padding: EdgeInsets.all(screenWidth * 0.05),
                child: SizedBox(
                  width: double.infinity,
                  height: screenWidth * 0.12,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {});
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      "Apply",
                      style: GoogleFonts.lato(
                        fontSize: screenWidth * 0.04,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),

              // Bottom padding for safe area
              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNoticesList(List<NoticeModel> notices, double screenWidth) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
      itemCount: notices.length,
      itemBuilder: (context, index) {
        return _buildNoticeCard(notices[index], screenWidth);
      },
    );
  }

  Widget _buildNoticeCard(NoticeModel notice, double screenWidth) {
    // 🔥 CURRENT: Using local state
    final isUnread = _unreadNoticeIds.contains(notice.id);
    final isSaved = _savedNoticeIds.contains(notice.id);

    // 🔥 FUTURE: When API is ready, replace above lines with:
    // final unreadIds = ref.watch(unreadNoticeIdsProvider).value ?? [];
    // final savedIds = ref.watch(savedNoticeIdsProvider).value ?? [];
    // final isUnread = unreadIds.contains(notice.id);
    // final isSaved = savedIds.contains(notice.id);

    return Container(
      margin: EdgeInsets.only(bottom: screenWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _onNoticeTap(notice),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border(
              left: BorderSide(color: const Color(0xFF6366F1), width: 4),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(screenWidth * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        notice.title,
                        style: GoogleFonts.lato(
                          fontSize: screenWidth * 0.045,
                          fontWeight: FontWeight.bold,
                          color: AppConstants.black,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            // Share functionality
                            _shareNotice(notice);
                          },
                          icon: Icon(
                            Icons.share_outlined,
                            size: screenWidth * 0.05,
                            color: const Color(0xFF6366F1),
                          ),
                        ),
                        IconButton(
                          onPressed: () => _toggleSaved(notice.id),
                          icon: Icon(
                            isSaved ? Icons.bookmark : Icons.bookmark_outline,
                            size: screenWidth * 0.05,
                            color: const Color(0xFF6366F1),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                if (isUnread) ...[
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.02,
                      vertical: screenWidth * 0.005,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      "NEW",
                      style: GoogleFonts.lato(
                        fontSize: screenWidth * 0.025,
                        fontWeight: FontWeight.w600,
                        color: Colors.red.shade700,
                      ),
                    ),
                  ),
                  SizedBox(height: screenWidth * 0.02),
                ],

                // Category
                if (notice.category.isNotEmpty) ...[
                  Text(
                    notice.category,
                    style: GoogleFonts.lato(
                      fontSize: screenWidth * 0.035,
                      color: const Color(0xFF6366F1),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: screenWidth * 0.02),
                ],

                // Description/Content Preview
                if (notice.description.isNotEmpty) ...[
                  Text(
                    AppHelper.getPreviewText(notice.description),
                    // notice.description,
                    style: GoogleFonts.lato(
                      fontSize: screenWidth * 0.035,
                      color: AppConstants.black,
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: screenWidth * 0.02),
                ],

                // Ellipsis for more content
                Text(
                  "...",
                  style: GoogleFonts.lato(
                    fontSize: screenWidth * 0.04,
                    color: AppConstants.black50,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: screenWidth * 0.03),

                // Footer Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      notice.timestamp,
                      style: GoogleFonts.lato(
                        fontSize: screenWidth * 0.032,
                        color: AppConstants.black50,
                      ),
                    ),
                    if (notice.hasAttachment) ...[
                      Row(
                        children: [
                          Icon(
                            Icons.attach_file,
                            size: screenWidth * 0.04,
                            color: AppConstants.black50,
                          ),
                          SizedBox(width: screenWidth * 0.01),
                          Text(
                            "${notice.attachmentCount} Attachment${notice.attachmentCount > 1 ? 's' : ''}",
                            style: GoogleFonts.lato(
                              fontSize: screenWidth * 0.032,
                              color: AppConstants.black50,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(double screenWidth) {
    final isSmallScreen = screenWidth < 360;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.1),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_outlined,
              size: isSmallScreen ? screenWidth * 0.15 : screenWidth * 0.2,
              color: Colors.grey.shade400,
            ),
            SizedBox(height: screenWidth * 0.05),
            Text(
              "No notices found",
              style: GoogleFonts.lato(
                fontSize: isSmallScreen
                    ? screenWidth * 0.045
                    : screenWidth * 0.05,
                fontWeight: FontWeight.bold,
                color: AppConstants.black,
              ),
            ),
            SizedBox(height: screenWidth * 0.03),
            Text(
              _searchQuery.isNotEmpty
                  ? "No notices match your search criteria"
                  : "There are no notices to display at the moment",
              style: GoogleFonts.lato(
                fontSize: isSmallScreen
                    ? screenWidth * 0.035
                    : screenWidth * 0.04,
                color: AppConstants.black50,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonLoader(double screenWidth) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.only(bottom: screenWidth * 0.04),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha:0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border(
              left: BorderSide(color: Colors.grey.shade300, width: 4),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(screenWidth * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      height: 18,
                      width: screenWidth * 0.6,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ).redacted(context: context, redact: true),
                    Row(
                      children: [
                        Container(
                          height: 20,
                          width: 20,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ).redacted(context: context, redact: true),
                        SizedBox(width: screenWidth * 0.02),
                        Container(
                          height: 20,
                          width: 20,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ).redacted(context: context, redact: true),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: screenWidth * 0.03),
                Container(
                  height: 14,
                  width: screenWidth * 0.3,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ).redacted(context: context, redact: true),
                SizedBox(height: screenWidth * 0.02),
                Container(
                  height: 14,
                  width: screenWidth * 0.8,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ).redacted(context: context, redact: true),
                SizedBox(height: screenWidth * 0.02),
                Container(
                  height: 14,
                  width: screenWidth * 0.6,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ).redacted(context: context, redact: true),
                SizedBox(height: screenWidth * 0.03),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      height: 12,
                      width: screenWidth * 0.25,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ).redacted(context: context, redact: true),
                    Container(
                      height: 12,
                      width: screenWidth * 0.3,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ).redacted(context: context, redact: true),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

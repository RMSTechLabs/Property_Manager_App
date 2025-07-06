import 'dart:io';
import 'package:dio/dio.dart';
import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:media_scanner/media_scanner.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:property_manager_app/src/core/constants/app_constants.dart';
import 'package:property_manager_app/src/core/utils/app_helper.dart';
import 'package:property_manager_app/src/core/utils/app_snackbar.dart';
import 'package:property_manager_app/src/data/models/notice_model.dart';
import 'package:property_manager_app/src/presentation/providers/notice_detail_provider.dart';
import 'package:redacted/redacted.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class NoticeDetailScreen extends ConsumerStatefulWidget {
  final String noticeId;

  const NoticeDetailScreen({super.key, required this.noticeId});

  @override
  ConsumerState<NoticeDetailScreen> createState() => _NoticeDetailScreenState();
}

class _NoticeDetailScreenState extends ConsumerState<NoticeDetailScreen> {
  bool _isSaved = false;
  bool _isDownloading = false;
  Map<String, double> _downloadProgress = {};
  String get noticeId => widget.noticeId;



  @override
  void initState() {
    super.initState();

    // Safe initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // TODO: Check if notice is saved when API is ready
      // _checkSavedStatus();
    });
  }

  Future<void> _toggleSaved() async {
    // Use addPostFrameCallback to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _isSaved = !_isSaved;
        });
      }
    });

    // TODO: Add API call when available
    // await ref.read(noticeProvider.notifier).toggleNoticeSaved(widget.noticeId);
  }

  Future<void> _shareNotice(NoticeModel notice) async {
    try {
      await Share.share(
        'Check out this notice: ${AppHelper.stripHtmlTagsNew(notice.title)}\n\n${AppHelper.stripHtmlTagsNew(notice.description)}',
        subject: AppHelper.stripHtmlTagsNew(notice.title),
      );
    } catch (e) {
      if (!mounted) return; // Ensure widget is still mounted
      AppSnackBar.showError(
        context: context,
        message: 'Could not share notice',
      );
    }
  }

  Future<void> _downloadAttachment({
    required String url,
    required String fileName,
  }) async {
    try {
      if (url.isEmpty) {
        if (!mounted) return;
        AppSnackBar.showError(
          context: context,
          message: 'Download URL not available',
        );
        return;
      }

      bool hasPermission = false;

      if (await AppHelper.isAndroid13OrAbove()) {
        hasPermission = true;
      } else {
        final status = await Permission.storage.status;
        if (status.isGranted) {
          hasPermission = true;
        } else {
          final requestResult = await Permission.storage.request();
          hasPermission = requestResult.isGranted;

          if (!hasPermission && await AppHelper.isAndroid11OrAbove()) {
            final manageStatus = await Permission.manageExternalStorage
                .request();
            hasPermission = manageStatus.isGranted;
          }
        }
      }

      if (!hasPermission) {
        if (!mounted) return;
        AppSnackBar.showError(
          context: context,
          message: 'Storage permission is required to download files',
        );
        return;
      }

      // Step 1: Get Downloads directory
      final String downloadsPath =
          await ExternalPath.getExternalStoragePublicDirectory(
            ExternalPath.DIRECTORY_DOWNLOAD,
          );

      final String savePath = '$downloadsPath/$fileName';
      final File file = File(savePath);

      // Step 2: Delete old file if exists
      if (await file.exists()) {
        await file.delete();
      }

      // Step 3: Start download and show progress
      setState(() {
        _isDownloading = true;
        _downloadProgress[fileName] = 0.0;
      });

      final dio = Dio();
      final response = await dio.download(
        url,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1 && mounted) {
            setState(() {
              _downloadProgress[fileName] = received / total;
            });
          }
        },
      );

      // Step 4: Handle result
      if (response.statusCode == 200) {
        await MediaScanner.loadMedia(path: savePath);

        if (mounted) {
          setState(() {
            _isDownloading = false;
            _downloadProgress.remove(fileName);
          });

          AppSnackBar.showSuccess(
            context: context,
            message: 'Downloaded to: $savePath',
          );
        }
      } else {
        throw Exception("Download failed");
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isDownloading = false;
          _downloadProgress.remove(fileName);
        });

        AppSnackBar.showError(
          context: context,
          message: 'Download failed: ${e.toString()}',
        );
      }
    }
  }

  Future<void> _downloadAllAttachments(NoticeModel notice) async {
    if (notice.noticeFiles.isEmpty) {
      // _showSnackBar('No attachments to download');
      if (!mounted) return; // Ensure widget is still mounted
      AppSnackBar.showError(
        context: context,
        message: 'No attachments to download',
      );
      return;
    }

    // _showSnackBar('Starting download of ${notice.noticeFiles.length} file(s)...');
    if (!mounted) return; // Ensure widget is still mounted
    AppSnackBar.showSuccess(
      context: context,
      message: 'Starting download of ${notice.noticeFiles.length} file(s)...',
    );

    // Download all files sequentially
    for (final noticeFile in notice.noticeFiles) {
      try {
        await _downloadAttachment(
          fileName: noticeFile.displayFileName,
          url: noticeFile.fileUrl,
        );

        // Add small delay between downloads
        await Future.delayed(const Duration(milliseconds: 500));
      } catch (e) {
        // _showSnackBar('Failed to download ${noticeFile.displayFileName}');
        if (!mounted) return; // Ensure widget is still mounted
        AppSnackBar.showError(
          context: context,
          message: 'Failed to download ${noticeFile.displayFileName}',
        );
      }
    }
    if (!mounted) return; // Ensure widget is still mounted
    AppSnackBar.showSuccess(
      context: context,
      message: 'All downloads completed!',
    );
  }

  void _showSnackBar(String message) {
    if (!mounted) return; // Ensure widget is still mounted
    AppSnackBar.showInfo(context: context, message: message);
  }

  @override
  Widget build(BuildContext context) {
    final noticeAsync = ref.watch(noticeDetailProvider(noticeId));
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
              // Header - Fixed to handle async state properly
              _buildHeader(screenWidth, noticeAsync),

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
                  child: noticeAsync.when(
                    loading: () => _buildSkeletonLoader(screenWidth),
                    error: (error, stackTrace) =>
                        _buildErrorState(screenWidth, error.toString()),
                    data: (notice) =>
                        _buildNoticeContent(notice, screenWidth, screenHeight),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(double screenWidth, AsyncValue<NoticeModel> noticeAsync) {
    final isSmallScreen = screenWidth < 360;

    return Padding(
      padding: EdgeInsets.all(screenWidth * 0.05),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: screenWidth * 0.12,
              height: screenWidth * 0.12,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
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
              // Handle async state properly
              noticeAsync.when(
                data: (notice) => AppHelper.stripHtmlTagsNew(notice.title),
                loading: () => "Loading...",
                error: (_, __) => "Notice Details",
              ),
              style: GoogleFonts.lato(
                color: Colors.white,
                fontSize: isSmallScreen
                    ? screenWidth * 0.04
                    : screenWidth * 0.045,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Share and Save buttons - only show when data is loaded
          noticeAsync.when(
            data: (notice) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () => _shareNotice(notice),
                  icon: Icon(
                    Icons.share_outlined,
                    color: Colors.white,
                    size: screenWidth * 0.06,
                  ),
                ),
                IconButton(
                  onPressed: _toggleSaved,
                  icon: Icon(
                    _isSaved ? Icons.bookmark : Icons.bookmark_outline,
                    color: Colors.white,
                    size: screenWidth * 0.06,
                  ),
                ),
              ],
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildNoticeContent(
    NoticeModel notice,
    double screenWidth,
    double screenHeight,
  ) {
    final isSmallScreen = screenWidth < 360;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.05),
        child: Column(
          children: [
            // Notice Card
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(screenWidth * 0.05),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      AppHelper.stripHtmlTagsNew(notice.title),
                      style: GoogleFonts.lato(
                        fontSize: isSmallScreen
                            ? screenWidth * 0.05
                            : screenWidth * 0.055,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.black,
                      ),
                    ),

                    SizedBox(height: screenWidth * 0.03),

                    // Timestamp
                    Text(
                      notice.timestamp,
                      style: GoogleFonts.lato(
                        fontSize: isSmallScreen
                            ? screenWidth * 0.032
                            : screenWidth * 0.035,
                        color: AppConstants.black50,
                      ),
                    ),

                    SizedBox(height: screenWidth * 0.05),

                    // Category (if available)
                    if (notice.category.isNotEmpty) ...[
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.03,
                          vertical: screenWidth * 0.015,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366F1).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF6366F1),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          notice.category,
                          style: GoogleFonts.lato(
                            fontSize: isSmallScreen
                                ? screenWidth * 0.03
                                : screenWidth * 0.032,
                            color: const Color(0xFF6366F1),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      SizedBox(height: screenWidth * 0.05),
                    ],

                    // HTML Content - Fixed and Safe
                    if (notice.description.isNotEmpty) ...[
                      Html(
                        data: notice.description,
                        style: {
                          "body": Style(
                            fontSize: FontSize(isSmallScreen ? 14 : 16),
                            fontFamily: 'Lato',
                            color: AppConstants.black,
                            lineHeight: const LineHeight(1.5),
                            margin: Margins.zero,
                            padding: HtmlPaddings.zero,
                          ),
                          "p": Style(margin: Margins.only(bottom: 12)),
                          "h1, h2, h3, h4, h5, h6": Style(
                            fontWeight: FontWeight.bold,
                            margin: Margins.only(top: 16, bottom: 8),
                          ),
                          "strong, b": Style(fontWeight: FontWeight.bold),
                          "em, i": Style(fontStyle: FontStyle.italic),
                          "ul, ol": Style(
                            margin: Margins.only(left: 20, bottom: 12),
                          ),
                          "img": Style(
                            width: Width(screenWidth * 0.8),
                            height: Height.auto(),
                          ),
                        },
                        onLinkTap: (url, attributes, element) {
                          if (url != null) {
                            // Safe URL launching
                            Future.microtask(() async {
                              try {
                                final uri = Uri.parse(url);
                                if (await canLaunchUrl(uri)) {
                                  await launchUrl(uri);
                                }
                              } catch (e) {
                                _showSnackBar('Could not launch URL');
                              }
                            });
                          }
                        },
                      ),
                    ] else if (notice.content.isNotEmpty) ...[
                      Html(
                        data: notice.content,
                        style: {
                          "body": Style(
                            fontSize: FontSize(isSmallScreen ? 14 : 16),
                            fontFamily: 'Lato',
                            color: AppConstants.black,
                            lineHeight: const LineHeight(1.5),
                            margin: Margins.zero,
                            padding: HtmlPaddings.zero,
                          ),
                        },
                        onLinkTap: (url, attributes, element) {
                          if (url != null) {
                            // Safe URL launching
                            Future.microtask(() async {
                              try {
                                final uri = Uri.parse(url);
                                if (await canLaunchUrl(uri)) {
                                  await launchUrl(uri);
                                }
                              } catch (e) {
                                _showSnackBar('Could not launch URL');
                              }
                            });
                          }
                        },
                      ),
                    ] else ...[
                      // Fallback for when no HTML content is available
                      Text(
                        'No content available',
                        style: GoogleFonts.lato(
                          fontSize: isSmallScreen ? 14 : 16,
                          color: AppConstants.black50,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],

                    SizedBox(height: screenWidth * 0.05),

                    // End divider
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: Colors.grey.shade300,
                            thickness: 1,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.03,
                          ),
                          child: Text(
                            "END",
                            style: GoogleFonts.lato(
                              fontSize: isSmallScreen
                                  ? screenWidth * 0.03
                                  : screenWidth * 0.032,
                              color: AppConstants.black50,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: Colors.grey.shade300,
                            thickness: 1,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: screenWidth * 0.05),

                    // Attachments Section - Now uses real file data
                    if (notice.hasAttachment &&
                        notice.noticeFiles.isNotEmpty) ...[
                      _buildAttachmentsSection(notice, screenWidth),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentsSection(NoticeModel notice, double screenWidth) {
    final isSmallScreen = screenWidth < 360;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Attachments Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "${notice.attachmentCount} Attachment${notice.attachmentCount > 1 ? 's' : ''}",
              style: GoogleFonts.lato(
                fontSize: isSmallScreen
                    ? screenWidth * 0.035
                    : screenWidth * 0.04,
                fontWeight: FontWeight.w600,
                color: AppConstants.black,
              ),
            ),
            if (notice.attachmentCount > 1) ...[
              GestureDetector(
                onTap: () => _downloadAllAttachments(notice),
                child: Row(
                  children: [
                    Icon(
                      Icons.download,
                      size: screenWidth * 0.04,
                      color: const Color(0xFF6366F1),
                    ),
                    SizedBox(width: screenWidth * 0.01),
                    Text(
                      "Download all",
                      style: GoogleFonts.lato(
                        fontSize: isSmallScreen
                            ? screenWidth * 0.032
                            : screenWidth * 0.035,
                        color: const Color(0xFF6366F1),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),

        SizedBox(height: screenWidth * 0.04),

        // Real Attachment Items from API - Updated to use actual notice files
        ...notice.noticeFiles.map(
          (noticeFile) => _buildAttachmentItem(
            fileName: noticeFile.displayFileName,
            fileType: noticeFile.displayFileType,
            fileSize: noticeFile.displayFileSize,
            thumbnailUrl: "", // Add thumbnail URL if available in API
            downloadUrl: noticeFile.fileUrl,
            screenWidth: screenWidth,
          ),
        ),
      ],
    );
  }

  Widget _buildAttachmentItem({
    required String fileName,
    required String fileType,
    required String fileSize,
    required String thumbnailUrl,
    required String downloadUrl,
    required double screenWidth,
  }) {
    final isSmallScreen = screenWidth < 360;
    final isDownloadingThis = _downloadProgress.containsKey(fileName);
    final progress = _downloadProgress[fileName] ?? 0.0;

    return Container(
      margin: EdgeInsets.only(bottom: screenWidth * 0.03),
      padding: EdgeInsets.all(screenWidth * 0.03),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          // File Thumbnail/Icon
          Container(
            width: screenWidth * 0.12,
            height: screenWidth * 0.12,
            decoration: BoxDecoration(
              color: _getFileTypeColor(fileType),
              borderRadius: BorderRadius.circular(6),
            ),
            child: thumbnailUrl.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.network(
                      thumbnailUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildFileIcon(fileType, screenWidth),
                    ),
                  )
                : _buildFileIcon(fileType, screenWidth),
          ),

          SizedBox(width: screenWidth * 0.03),

          // File Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  style: GoogleFonts.lato(
                    fontSize: isSmallScreen
                        ? screenWidth * 0.032
                        : screenWidth * 0.035,
                    fontWeight: FontWeight.w500,
                    color: AppConstants.black,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: screenWidth * 0.01),
                Text(
                  "$fileType • $fileSize",
                  style: GoogleFonts.lato(
                    fontSize: isSmallScreen
                        ? screenWidth * 0.028
                        : screenWidth * 0.03,
                    color: AppConstants.black50,
                  ),
                ),
                if (isDownloadingThis) ...[
                  SizedBox(height: screenWidth * 0.02),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF6366F1),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Download Button
          if (!isDownloadingThis) ...[
            IconButton(
              onPressed: () =>
                  _downloadAttachment(fileName: fileName, url: downloadUrl),
              icon: Icon(
                Icons.download_outlined,
                size: screenWidth * 0.05,
                color: const Color(0xFF6366F1),
              ),
            ),
          ] else ...[
            SizedBox(
              width: screenWidth * 0.05,
              height: screenWidth * 0.05,
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFileIcon(String fileType, double screenWidth) {
    IconData iconData;

    switch (fileType.toUpperCase()) {
      case 'PDF':
        iconData = Icons.picture_as_pdf;
        break;
      case 'DOC':
      case 'DOCX':
        iconData = Icons.description;
        break;
      case 'XLS':
      case 'XLSX':
        iconData = Icons.table_chart;
        break;
      case 'JPG':
      case 'JPEG':
      case 'PNG':
      case 'GIF':
        iconData = Icons.image;
        break;
      default:
        iconData = Icons.insert_drive_file;
    }

    return Icon(iconData, size: screenWidth * 0.06, color: Colors.white);
  }

  Color _getFileTypeColor(String fileType) {
    switch (fileType.toUpperCase()) {
      case 'PDF':
        return Colors.red.shade400;
      case 'DOC':
      case 'DOCX':
        return Colors.blue.shade400;
      case 'XLS':
      case 'XLSX':
        return Colors.green.shade400;
      case 'JPG':
      case 'JPEG':
      case 'PNG':
      case 'GIF':
        return Colors.purple.shade400;
      default:
        return Colors.grey.shade400;
    }
  }

  Widget _buildSkeletonLoader(double screenWidth) {
    return Padding(
      padding: EdgeInsets.all(screenWidth * 0.05),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 24,
                width: screenWidth * 0.7,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ).redacted(context: context, redact: true),
              SizedBox(height: screenWidth * 0.03),
              Container(
                height: 16,
                width: screenWidth * 0.4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ).redacted(context: context, redact: true),
              SizedBox(height: screenWidth * 0.05),
              for (int i = 0; i < 5; i++) ...[
                Container(
                  height: 16,
                  width: i == 4 ? screenWidth * 0.6 : screenWidth * 0.9,
                  margin: EdgeInsets.only(bottom: screenWidth * 0.02),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ).redacted(context: context, redact: true),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(double screenWidth, String error) {
    final isSmallScreen = screenWidth < 360;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.1),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: isSmallScreen ? screenWidth * 0.15 : screenWidth * 0.2,
              color: Colors.red.shade400,
            ),
            SizedBox(height: screenWidth * 0.05),
            Text(
              "Failed to load notice",
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
              error,
              style: GoogleFonts.lato(
                fontSize: isSmallScreen
                    ? screenWidth * 0.035
                    : screenWidth * 0.04,
                color: AppConstants.black50,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: screenWidth * 0.05),
            ElevatedButton(
              onPressed: () {
                // Use addPostFrameCallback to avoid setState during build
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ref.invalidate(noticeDetailProvider(widget.noticeId));
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                "Retry",
                style: GoogleFonts.lato(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

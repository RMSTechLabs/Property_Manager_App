// Ticket Detail Screen - Responsive with Comments and Reply
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:property_manager_app/src/presentation/providers/ticket_detail_provider.dart';
import 'package:redacted/redacted.dart';
import 'package:property_manager_app/src/core/constants/app_constants.dart';
import 'package:property_manager_app/src/data/models/ticket_detail_model.dart';

class TicketDetailScreen extends ConsumerStatefulWidget {
  final String ticketId;
  const TicketDetailScreen({super.key, required this.ticketId});

  @override
  ConsumerState<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends ConsumerState<TicketDetailScreen> {
  final TextEditingController _replyController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String get ticketId => widget.ticketId;
  bool _isLoading = true;
  TicketDetailModel? _ticketDetail;
  String _selectedVisibility = "Personal ( Only Me )";

  final List<String> _visibilityOptions = [
    "Personal ( Only Me )",
    "Community Members",
    "Admin Only",
  ];

  @override
  void initState() {
    super.initState();
    _loadTicketDetail();
  }

  Future<void> _loadTicketDetail() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      // Sample ticket detail data - replace with actual API call
      _ticketDetail = TicketDetailModel(
        id: "BT-2",
        title: "Need a maintenance",
        category: "Electrical",
        status: "Cancelled",
        timestamp: "01:50 PM | 16 Apr'25",
        description: "test",
        location: "Community-C01",
        assignee: "NA",
        responseCount: 1,
        createdBy: "Gopal prasad",
        community: "Community-C01",
        imageUrls: ["assets/images/electrical_issue.jpg"], // Sample image
        comments: [
          CommentModel(
            id: "1",
            authorName: "Muhammed safuwan",
            authorRole: "Admin",
            timestamp: "11:58 AM | 13 May'25",
            content:
                "Ticket's State has been changed from Open to Cancelled\n\nComment : Just Test",
            isSystemMessage: true,
          ),
        ],
      );
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final ticketDetail = ref.watch(ticketDetailProvider(ticketId));
    final notifier = ref.read(ticketDetailProvider(ticketId).notifier);

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
                  child: ticketDetail.when(
                    loading: () => _buildSkeletonLoader(screenWidth),
                    error: (error, _) => Center(
                      child: Text(
                        "Failed to load ticket: $error",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                    data: (ticket) => Column(
                      children: [
                        // Ticket Details
                        Expanded(
                          // child: _isLoading
                          //     ? _buildSkeletonLoader(screenWidth)
                          //     : _buildTicketContent(screenWidth),
                          child: _buildTicketContent(screenWidth, ticket),
                        ),

                        // Reply Input
                        _buildReplyInput(
                          screenWidth,
                          onSend: (text) {
                            // notifier.sendComment(text, _selectedVisibility);
                          },
                        ),
                      ],
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

  Widget _buildHeader(double screenWidth) {
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
              "Ticket Details",
              style: GoogleFonts.lato(
                color: Colors.white,
                fontSize: screenWidth * 0.05,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketContent(
    double screenWidth,
    TicketDetailModel? ticketDetail,
  ) {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: EdgeInsets.all(screenWidth * 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ticket Header
          _buildTicketHeader(screenWidth, ticketDetail),

          SizedBox(height: screenWidth * 0.04),

          // Ticket Body
          _buildTicketBody(screenWidth, ticketDetail),

          SizedBox(height: screenWidth * 0.04),

          // Image Attachment (if exists)
          // if (_ticketDetail!.imageUrl.isNotEmpty)
          //   _buildImageAttachment(screenWidth),
          if ((ticketDetail?.imageUrls ?? []).isNotEmpty)
            _buildImageAttachments(screenWidth, ticketDetail),

          SizedBox(height: screenWidth * 0.04),

          // Location and Visibility
          _buildLocationAndVisibility(screenWidth, ticketDetail),

          SizedBox(height: screenWidth * 0.04),

          // Response Info
          _buildResponseInfo(screenWidth, ticketDetail),

          SizedBox(height: screenWidth * 0.04),

          // Comments Section
          _buildCommentsSection(screenWidth, ticketDetail),
        ],
      ),
    );
  }

  Widget _buildTicketHeader(
    double screenWidth,
    TicketDetailModel? ticketDetail,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              "Ticket ID: ",
              style: GoogleFonts.lato(
                fontSize: screenWidth * 0.035,
                color: AppConstants.black50,
              ),
            ),
            Text(
              ticketDetail!.id,
              style: GoogleFonts.lato(
                fontSize: screenWidth * 0.035,
                fontWeight: FontWeight.w600,
                color: AppConstants.black,
              ),
            ),
          ],
        ),
        _buildStatusBadge(ticketDetail.status, screenWidth),
      ],
    );
  }

  Widget _buildTicketBody(double screenWidth, TicketDetailModel? ticketDetail) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title with Category
        Row(
          children: [
            Expanded(
              child: Text(
                ticketDetail!.title,
                style: GoogleFonts.lato(
                  fontSize: screenWidth * 0.05,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.black,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppConstants.black50,
              size: screenWidth * 0.04,
            ),
            SizedBox(width: screenWidth * 0.02),
            Text(
              ticketDetail.category,
              style: GoogleFonts.lato(
                fontSize: screenWidth * 0.04,
                color: AppConstants.black50,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),

        SizedBox(height: screenWidth * 0.03),

        // Timestamp
        Text(
          ticketDetail.timestamp,
          style: GoogleFonts.lato(
            fontSize: screenWidth * 0.032,
            color: AppConstants.black50,
          ),
        ),

        SizedBox(height: screenWidth * 0.03),

        // Description
        if (ticketDetail.description.isNotEmpty)
          Text(
            ticketDetail.description,
            style: GoogleFonts.lato(
              fontSize: screenWidth * 0.035,
              color: AppConstants.black,
            ),
          ),
      ],
    );
  }

  // Widget _buildImageAttachment(double screenWidth) {
  //   return Container(
  //     width: screenWidth * 0.3,
  //     height: screenWidth * 0.25,
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(8),
  //       border: Border.all(color: Colors.grey.shade300),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withOpacity(0.1),
  //           blurRadius: 4,
  //           offset: const Offset(0, 2),
  //         ),
  //       ],
  //     ),
  //     child: ClipRRect(
  //       borderRadius: BorderRadius.circular(8),
  //       child: Image.asset(
  //         _ticketDetail!.imageUrl,
  //         fit: BoxFit.cover,
  //         errorBuilder: (context, error, stackTrace) {
  //           return Container(
  //             color: Colors.grey.shade100,
  //             child: Icon(
  //               Icons.image_outlined,
  //               size: screenWidth * 0.08,
  //               color: Colors.grey.shade400,
  //             ),
  //           );
  //         },
  //       ),
  //     ),
  //   );
  // }

  Widget _buildImageAttachments(
    double screenWidth,
    TicketDetailModel? ticketDetail,
  ) {
    final images = ticketDetail?.imageUrls ?? [];
    if (images.isEmpty) return SizedBox.shrink();

    return SizedBox(
      height: screenWidth * 0.20,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
        itemCount: images.length,
        separatorBuilder: (_, __) => SizedBox(width: screenWidth * 0.03),
        itemBuilder: (context, index) {
          return Container(
            width: screenWidth * 0.20,
            height: screenWidth * 0.20,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                images[index],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey.shade100,
                    child: Icon(
                      Icons.image_outlined,
                      size: screenWidth * 0.08,
                      color: Colors.grey.shade400,
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLocationAndVisibility(
    double screenWidth,
    TicketDetailModel? ticketDetail,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Location
        Text(
          "Location : ${ticketDetail!.location}",
          style: GoogleFonts.lato(
            fontSize: screenWidth * 0.035,
            color: AppConstants.black50,
          ),
        ),

        SizedBox(height: screenWidth * 0.03),

        //added
        Text(
          "Community : ${ticketDetail.community}",
          style: GoogleFonts.lato(
            fontSize: screenWidth * 0.035,
            color: AppConstants.black50,
          ),
        ),

        SizedBox(height: screenWidth * 0.03),

        // Visibility and Assignee Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Visibility Dropdown
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.03,
                vertical: screenWidth * 0.01,
              ),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedVisibility,
                  icon: Icon(
                    Icons.keyboard_arrow_down,
                    color: AppConstants.black50,
                    size: screenWidth * 0.04,
                  ),
                  style: GoogleFonts.lato(
                    color: AppConstants.black,
                    fontSize: screenWidth * 0.032,
                  ),
                  items: _visibilityOptions.map((String option) {
                    return DropdownMenuItem<String>(
                      value: option,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.visibility_outlined,
                            size: screenWidth * 0.035,
                            color: AppConstants.black50,
                          ),
                          SizedBox(width: screenWidth * 0.02),
                          Text(option),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedVisibility = newValue;
                      });
                    }
                  },
                ),
              ),
            ),

            // Assignee
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "Assignee",
                  style: GoogleFonts.lato(
                    fontSize: screenWidth * 0.03,
                    color: AppConstants.black50,
                  ),
                ),
                Text(
                  ticketDetail.assignee,
                  style: GoogleFonts.lato(
                    fontSize: screenWidth * 0.035,
                    fontWeight: FontWeight.w500,
                    color: AppConstants.black,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildResponseInfo(
    double screenWidth,
    TicketDetailModel? ticketDetail,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: screenWidth * 0.03),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey.shade300),
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.comment_outlined,
                size: screenWidth * 0.04,
                color: AppConstants.black50,
              ),
              SizedBox(width: screenWidth * 0.02),
              Text(
                "${ticketDetail!.responseCount} Responses",
                style: GoogleFonts.lato(
                  fontSize: screenWidth * 0.035,
                  color: AppConstants.black50,
                ),
              ),
            ],
          ),
          Text(
            "Created By : ${ticketDetail.createdBy}",
            style: GoogleFonts.lato(
              fontSize: screenWidth * 0.03,
              color: AppConstants.black50,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsSection(
    double screenWidth,
    TicketDetailModel? ticketDetail,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Comments Header
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.04,
            vertical: screenWidth * 0.03,
          ),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            "COMMENTS & ACTIVITY",
            style: GoogleFonts.lato(
              fontSize: screenWidth * 0.035,
              fontWeight: FontWeight.w600,
              color: AppConstants.black50,
            ),
          ),
        ),

        SizedBox(height: screenWidth * 0.04),

        // Comments List
        ...ticketDetail!.comments.map(
          (comment) => _buildCommentItem(comment, screenWidth),
        ),

        SizedBox(height: screenWidth * 0.1), // Space for fixed input
      ],
    );
  }

  // Widget _buildCommentItem(CommentModel comment, double screenWidth) {
  //   return Container(
  //     margin: EdgeInsets.only(bottom: screenWidth * 0.04),
  //     child: Row(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         // Avatar
  //         Container(
  //           width: screenWidth * 0.1,
  //           height: screenWidth * 0.1,
  //           decoration: BoxDecoration(
  //             color: Colors.grey.shade300,
  //             borderRadius: BorderRadius.circular(screenWidth * 0.05),
  //           ),
  //           child: Icon(
  //             Icons.person,
  //             color: Colors.grey.shade600,
  //             size: screenWidth * 0.05,
  //           ),
  //         ),

  //         SizedBox(width: screenWidth * 0.03),

  //         // Comment Content
  //         Expanded(
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               // Author and timestamp
  //               Row(
  //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                 children: [
  //                   Column(
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     children: [
  //                       Text(
  //                         comment.authorName,
  //                         style: GoogleFonts.lato(
  //                           fontSize: screenWidth * 0.035,
  //                           fontWeight: FontWeight.w600,
  //                           color: AppConstants.black,
  //                         ),
  //                       ),
  //                       Text(
  //                         "(${comment.authorRole})",
  //                         style: GoogleFonts.lato(
  //                           fontSize: screenWidth * 0.03,
  //                           color: const Color(0xFF10B981),
  //                           fontWeight: FontWeight.w500,
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                   Text(
  //                     comment.timestamp,
  //                     style: GoogleFonts.lato(
  //                       fontSize: screenWidth * 0.028,
  //                       color: AppConstants.black50,
  //                     ),
  //                   ),
  //                 ],
  //               ),

  //               SizedBox(height: screenWidth * 0.02),

  //               // Comment text
  //               Text(
  //                 comment.content,
  //                 style: GoogleFonts.lato(
  //                   fontSize: screenWidth * 0.035,
  //                   color: AppConstants.black,
  //                   height: 1.4,
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
  Widget _buildCommentItem(CommentModel comment, double screenWidth) {
  return Container(
    margin: EdgeInsets.only(bottom: screenWidth * 0.04),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Avatar
        Container(
          width: screenWidth * 0.1,
          height: screenWidth * 0.1,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(screenWidth * 0.05),
          ),
          child: Icon(
            Icons.person,
            color: Colors.grey.shade600,
            size: screenWidth * 0.05,
          ),
        ),

        SizedBox(width: screenWidth * 0.03),

        // Comment Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Author and timestamp
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        comment.authorName,
                        style: GoogleFonts.lato(
                          fontSize: screenWidth * 0.035,
                          fontWeight: FontWeight.w600,
                          color: AppConstants.black,
                        ),
                      ),
                      Text(
                        "(${comment.authorRole})",
                        style: GoogleFonts.lato(
                          fontSize: screenWidth * 0.03,
                          color: const Color(0xFF10B981),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    comment.timestamp,
                    style: GoogleFonts.lato(
                      fontSize: screenWidth * 0.028,
                      color: AppConstants.black50,
                    ),
                  ),
                ],
              ),

              SizedBox(height: screenWidth * 0.02),

              // Comment text
              if (comment.content.isNotEmpty)
                Text(
                  comment.content,
                  style: GoogleFonts.lato(
                    fontSize: screenWidth * 0.035,
                    color: AppConstants.black,
                    height: 1.4,
                  ),
                ),

              // Images (if any)
              if (comment.images != null && comment.images.isNotEmpty) ...[
                SizedBox(height: screenWidth * 0.02),
                SizedBox(
                  height: screenWidth * 0.25, // Height for image row
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: comment.images.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: EdgeInsets.only(
                          right: index < comment.images.length - 1 
                            ? screenWidth * 0.02 
                            : 0,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(screenWidth * 0.02),
                          child: Image.network(
                            comment.images[index],
                            width: screenWidth * 0.25,
                            height: screenWidth * 0.25,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: screenWidth * 0.25,
                                height: screenWidth * 0.25,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(screenWidth * 0.02),
                                ),
                                child: Icon(
                                  Icons.error_outline,
                                  color: Colors.grey.shade600,
                                  size: screenWidth * 0.06,
                                ),
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                width: screenWidth * 0.25,
                                height: screenWidth * 0.25,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(screenWidth * 0.02),
                                ),
                                child: Center(
                                  child: SizedBox(
                                    width: screenWidth * 0.05,
                                    height: screenWidth * 0.05,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.grey.shade600,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    ),
  );
}

  Widget _buildReplyInput(
    double screenWidth, {
    required void Function(String) onSend,
  }) {
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: TextField(
                controller: _replyController,
                style: GoogleFonts.lato(
                  fontSize: screenWidth * 0.035,
                  color: AppConstants.black,
                ),
                decoration: InputDecoration(
                  hintText: "Reply to this issue...",
                  hintStyle: GoogleFonts.lato(
                    fontSize: screenWidth * 0.035,
                    color: AppConstants.black50,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: screenWidth * 0.03,
                  ),
                ),
                maxLines: null,
                textInputAction: TextInputAction.newline,
              ),
            ),
          ),

          SizedBox(width: screenWidth * 0.02),

          // Attachment button
          GestureDetector(
            onTap: () => _attachFile(),
            child: Container(
              width: screenWidth * 0.1,
              height: screenWidth * 0.1,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(screenWidth * 0.05),
              ),
              child: Icon(
                Icons.attach_file,
                color: AppConstants.black50,
                size: screenWidth * 0.05,
              ),
            ),
          ),

          SizedBox(width: screenWidth * 0.02),

          // Voice button
          GestureDetector(
            onTap: () => _recordVoice(),
            child: Container(
              width: screenWidth * 0.1,
              height: screenWidth * 0.1,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(screenWidth * 0.05),
              ),
              child: Icon(
                Icons.mic,
                color: AppConstants.black50,
                size: screenWidth * 0.05,
              ),
            ),
          ),

          SizedBox(width: screenWidth * 0.02),

          // Send button
          GestureDetector(
            onTap: () => _sendReply(onSend),
            child: Container(
              width: screenWidth * 0.12,
              height: screenWidth * 0.12,
              decoration: BoxDecoration(
                color: const Color(0xFF10B981),
                borderRadius: BorderRadius.circular(screenWidth * 0.06),
              ),
              child: Icon(
                Icons.send,
                color: Colors.white,
                size: screenWidth * 0.05,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status, double screenWidth) {
    Color backgroundColor;
    Color textColor;

    switch (status.toLowerCase()) {
      case 'open':
        backgroundColor = Colors.orange.shade100;
        textColor = Colors.orange.shade700;
        break;
      case 'in progress':
        backgroundColor = Colors.blue.shade100;
        textColor = Colors.blue.shade700;
        break;
      case 'resolved':
        backgroundColor = Colors.green.shade100;
        textColor = Colors.green.shade700;
        break;
      case 'closed':
        backgroundColor = Colors.grey.shade100;
        textColor = Colors.grey.shade700;
        break;
      case 'cancelled':
        backgroundColor = Colors.orange.shade100;
        textColor = Colors.orange.shade700;
        break;
      default:
        backgroundColor = Colors.grey.shade100;
        textColor = Colors.grey.shade700;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.03,
        vertical: screenWidth * 0.015,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status,
        style: GoogleFonts.lato(
          fontSize: screenWidth * 0.03,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildSkeletonLoader(double screenWidth) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(screenWidth * 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ticket Header Skeleton
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: 16,
                width: screenWidth * 0.25,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ).redacted(context: context, redact: true),
              Container(
                height: 24,
                width: screenWidth * 0.2,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(6),
                ),
              ).redacted(context: context, redact: true),
            ],
          ),

          SizedBox(height: screenWidth * 0.04),

          // Title and Category Skeleton
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 22,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ).redacted(context: context, redact: true),
              ),
              SizedBox(width: screenWidth * 0.02),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey.shade300,
                size: screenWidth * 0.04,
              ),
              SizedBox(width: screenWidth * 0.02),
              Container(
                height: 18,
                width: screenWidth * 0.2,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ).redacted(context: context, redact: true),
            ],
          ),

          SizedBox(height: screenWidth * 0.03),

          // Timestamp Skeleton
          Container(
            height: 14,
            width: screenWidth * 0.4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4),
            ),
          ).redacted(context: context, redact: true),

          SizedBox(height: screenWidth * 0.03),

          // Description Skeleton
          Container(
            height: 16,
            width: screenWidth * 0.15,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4),
            ),
          ).redacted(context: context, redact: true),

          SizedBox(height: screenWidth * 0.04),

          // Image Attachment Skeleton
          Container(
            width: screenWidth * 0.3,
            height: screenWidth * 0.25,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(8),
            ),
          ).redacted(context: context, redact: true),

          SizedBox(height: screenWidth * 0.04),

          // Location Skeleton
          Container(
            height: 16,
            width: screenWidth * 0.5,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4),
            ),
          ).redacted(context: context, redact: true),

          SizedBox(height: screenWidth * 0.03),

          // Visibility and Assignee Row Skeleton
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: 36,
                width: screenWidth * 0.45,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(8),
                ),
              ).redacted(context: context, redact: true),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    height: 12,
                    width: screenWidth * 0.15,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ).redacted(context: context, redact: true),
                  SizedBox(height: screenWidth * 0.01),
                  Container(
                    height: 16,
                    width: screenWidth * 0.08,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ).redacted(context: context, redact: true),
                ],
              ),
            ],
          ),

          SizedBox(height: screenWidth * 0.04),

          // Response Info Skeleton
          Container(
            padding: EdgeInsets.symmetric(vertical: screenWidth * 0.03),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey.shade300),
                bottom: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.comment_outlined,
                      size: screenWidth * 0.04,
                      color: Colors.grey.shade300,
                    ),
                    SizedBox(width: screenWidth * 0.02),
                    Container(
                      height: 14,
                      width: screenWidth * 0.25,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ).redacted(context: context, redact: true),
                  ],
                ),
                Container(
                  height: 12,
                  width: screenWidth * 0.4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ).redacted(context: context, redact: true),
              ],
            ),
          ),

          SizedBox(height: screenWidth * 0.04),

          // Comments Header Skeleton
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.04,
              vertical: screenWidth * 0.03,
            ),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(8),
            ),
          ).redacted(context: context, redact: true),

          SizedBox(height: screenWidth * 0.04),

          // Comment Items Skeleton
          ...List.generate(2, (index) => _buildSkeletonComment(screenWidth)),

          SizedBox(height: screenWidth * 0.1),
        ],
      ),
    );
  }

  Widget _buildSkeletonComment(double screenWidth) {
    return Container(
      margin: EdgeInsets.only(bottom: screenWidth * 0.04),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar Skeleton
          Container(
            width: screenWidth * 0.1,
            height: screenWidth * 0.1,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(screenWidth * 0.05),
            ),
          ).redacted(context: context, redact: true),

          SizedBox(width: screenWidth * 0.03),

          // Comment Content Skeleton
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Author and timestamp row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 16,
                          width: screenWidth * 0.35,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ).redacted(context: context, redact: true),
                        SizedBox(height: screenWidth * 0.01),
                        Container(
                          height: 12,
                          width: screenWidth * 0.15,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ).redacted(context: context, redact: true),
                      ],
                    ),
                    Container(
                      height: 12,
                      width: screenWidth * 0.25,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ).redacted(context: context, redact: true),
                  ],
                ),

                SizedBox(height: screenWidth * 0.02),

                // Comment text skeleton (multiple lines)
                Container(
                  height: 16,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ).redacted(context: context, redact: true),
                SizedBox(height: screenWidth * 0.01),
                Container(
                  height: 16,
                  width: screenWidth * 0.8,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ).redacted(context: context, redact: true),
                SizedBox(height: screenWidth * 0.01),
                Container(
                  height: 16,
                  width: screenWidth * 0.6,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ).redacted(context: context, redact: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Action methods
  void _attachFile() {
    print('Attach file');
    // TODO: Implement file attachment
  }

  void _recordVoice() {
    print('Record voice message');
    // TODO: Implement voice recording
  }

  void _sendReply(onSend) {
    final text = _replyController.text.trim();
    if (text.isNotEmpty) {
      onSend(text);
      _replyController.clear();
    }
  }

  @override
  void dispose() {
    _replyController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

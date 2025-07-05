// // Ticket Detail Screen - Responsive with Comments and Reply
// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:property_manager_app/src/core/utils/app_snackbar.dart';
// import 'package:property_manager_app/src/presentation/providers/ticket_detail_provider.dart';
// import 'package:property_manager_app/src/presentation/widgets/image_viewer.dart';
// import 'package:redacted/redacted.dart';
// import 'package:property_manager_app/src/core/constants/app_constants.dart';
// import 'package:property_manager_app/src/data/models/ticket_detail_model.dart';

// import 'package:http/http.dart' as http;
// import 'package:path_provider/path_provider.dart';
// import 'package:path/path.dart' as p;

// class TicketDetailScreen extends ConsumerStatefulWidget {
//   final String ticketId;
//   const TicketDetailScreen({super.key, required this.ticketId});

//   @override
//   ConsumerState<TicketDetailScreen> createState() => _TicketDetailScreenState();
// }

// class _TicketDetailScreenState extends ConsumerState<TicketDetailScreen> {
//   final TextEditingController _replyController = TextEditingController();
//   final ScrollController _scrollController = ScrollController();
//   String get ticketId => widget.ticketId;
//   bool _isLoading = true;
//   TicketDetailModel? _ticketDetail;
//   String _selectedVisibility = "Personal ( Only Me )";

//   final List<String> _visibilityOptions = [
//     "Personal ( Only Me )",
//     "Community Members",
//     "Admin Only",
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _loadTicketDetail();
//   }

//   Future<void> _loadTicketDetail() async {
//     setState(() {
//       _isLoading = true;
//     });

//     // Simulate API call
//     await Future.delayed(const Duration(seconds: 1));

//     setState(() {
//       // Sample ticket detail data - replace with actual API call
//       _ticketDetail = TicketDetailModel(
//         id: "BT-2",
//         title: "Need a maintenance",
//         category: "Electrical",
//         status: "Cancelled",
//         timestamp: "01:50 PM | 16 Apr'25",
//         description: "test",
//         location: "Community-C01",
//         assignee: "NA",
//         responseCount: 1,
//         createdBy: "Gopal prasad",
//         community: "Community-C01",
//         imageUrls: ["assets/images/electrical_issue.jpg"], // Sample image
//         comments: [
//           CommentModel(
//             id: "1",
//             authorName: "Muhammed safuwan",
//             authorRole: "Admin",
//             timestamp: "11:58 AM | 13 May'25",
//             content:
//                 "Ticket's State has been changed from Open to Cancelled\n\nComment : Just Test",
//             isSystemMessage: true,
//           ),
//         ],
//       );
//       _isLoading = false;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;

//     final ticketDetail = ref.watch(ticketDetailProvider(ticketId));
//     final notifier = ref.read(ticketDetailProvider(ticketId).notifier);

//     return Scaffold(
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: AppConstants.secondartGradient,
//         ),
//         child: SafeArea(
//           child: Column(
//             children: [
//               // Header
//               _buildHeader(screenWidth),

//               // Content Area
//               Expanded(
//                 child: Container(
//                   margin: EdgeInsets.only(top: screenHeight * 0.02),
//                   decoration: const BoxDecoration(
//                     color: Color(0xFFF5F5F5),
//                     borderRadius: BorderRadius.only(
//                       topLeft: Radius.circular(30),
//                       topRight: Radius.circular(30),
//                     ),
//                   ),
//                   child: ticketDetail.when(
//                     loading: () => _buildSkeletonLoader(screenWidth),
//                     error: (error, _) => Center(
//                       child: Text(
//                         "Failed to load ticket: $error",
//                         style: TextStyle(color: Colors.red),
//                       ),
//                     ),
//                     data: (ticket) => Column(
//                       children: [
//                         // Ticket Details
//                         Expanded(
//                           // child: _isLoading
//                           //     ? _buildSkeletonLoader(screenWidth)
//                           //     : _buildTicketContent(screenWidth),
//                           child: _buildTicketContent(screenWidth, ticket),
//                         ),

//                         // Reply Input
//                         _buildReplyInput(
//                           screenWidth,
//                           onSend: (text) {
//                             // notifier.sendComment(text, _selectedVisibility);
//                           },
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildHeader(double screenWidth) {
//     return Padding(
//       padding: EdgeInsets.all(screenWidth * 0.05),
//       child: Row(
//         children: [
//           GestureDetector(
//             onTap: () => Navigator.pop(context),
//             child: Container(
//               width: screenWidth * 0.12,
//               height: screenWidth * 0.12,
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.2),
//                 borderRadius: BorderRadius.circular(screenWidth * 0.06),
//               ),
//               child: Icon(
//                 Icons.arrow_back_ios_new,
//                 color: Colors.white,
//                 size: screenWidth * 0.05,
//               ),
//             ),
//           ),
//           SizedBox(width: screenWidth * 0.04),
//           Expanded(
//             child: Text(
//               "Ticket Details",
//               style: GoogleFonts.lato(
//                 color: Colors.white,
//                 fontSize: screenWidth * 0.05,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTicketContent(
//     double screenWidth,
//     TicketDetailModel? ticketDetail,
//   ) {
//     return SingleChildScrollView(
//       controller: _scrollController,
//       padding: EdgeInsets.all(screenWidth * 0.05),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Ticket Header
//           _buildTicketHeader(screenWidth, ticketDetail),

//           SizedBox(height: screenWidth * 0.04),

//           // Ticket Body
//           _buildTicketBody(screenWidth, ticketDetail),

//           SizedBox(height: screenWidth * 0.04),

//           // Image Attachment (if exists)
//           // if (_ticketDetail!.imageUrl.isNotEmpty)
//           //   _buildImageAttachment(screenWidth),
//           if ((ticketDetail?.imageUrls ?? []).isNotEmpty)
//             _buildImageAttachments(screenWidth, ticketDetail),

//           SizedBox(height: screenWidth * 0.04),

//           // Location and Visibility
//           _buildLocationAndVisibility(screenWidth, ticketDetail),

//           SizedBox(height: screenWidth * 0.04),

//           // Response Info
//           _buildResponseInfo(screenWidth, ticketDetail),

//           SizedBox(height: screenWidth * 0.04),

//           // Comments Section
//           _buildCommentsSection(screenWidth, ticketDetail),
//         ],
//       ),
//     );
//   }

//   Widget _buildTicketHeader(
//     double screenWidth,
//     TicketDetailModel? ticketDetail,
//   ) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Row(
//           children: [
//             Text(
//               "Ticket ID: ",
//               style: GoogleFonts.lato(
//                 fontSize: screenWidth * 0.035,
//                 color: AppConstants.black50,
//               ),
//             ),
//             Text(
//               ticketDetail!.id,
//               style: GoogleFonts.lato(
//                 fontSize: screenWidth * 0.035,
//                 fontWeight: FontWeight.w600,
//                 color: AppConstants.black,
//               ),
//             ),
//           ],
//         ),
//         _buildStatusBadge(ticketDetail.status, screenWidth),
//       ],
//     );
//   }

//   Widget _buildTicketBody(double screenWidth, TicketDetailModel? ticketDetail) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Title with Category
//         Row(
//           children: [
//             Expanded(
//               child: Text(
//                 ticketDetail!.title,
//                 style: GoogleFonts.lato(
//                   fontSize: screenWidth * 0.05,
//                   fontWeight: FontWeight.bold,
//                   color: AppConstants.black,
//                 ),
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ),
//             Icon(
//               Icons.arrow_forward_ios,
//               color: AppConstants.black50,
//               size: screenWidth * 0.04,
//             ),
//             SizedBox(width: screenWidth * 0.02),
//             Text(
//               ticketDetail.category,
//               style: GoogleFonts.lato(
//                 fontSize: screenWidth * 0.04,
//                 color: AppConstants.black50,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ],
//         ),

//         SizedBox(height: screenWidth * 0.03),

//         // Timestamp
//         Text(
//           ticketDetail.timestamp,
//           style: GoogleFonts.lato(
//             fontSize: screenWidth * 0.032,
//             color: AppConstants.black50,
//           ),
//         ),

//         SizedBox(height: screenWidth * 0.03),

//         // Description
//         if (ticketDetail.description.isNotEmpty)
//           Text(
//             ticketDetail.description,
//             style: GoogleFonts.lato(
//               fontSize: screenWidth * 0.035,
//               color: AppConstants.black,
//             ),
//           ),
//       ],
//     );
//   }

//   // Widget _buildImageAttachment(double screenWidth) {
//   //   return Container(
//   //     width: screenWidth * 0.3,
//   //     height: screenWidth * 0.25,
//   //     decoration: BoxDecoration(
//   //       color: Colors.white,
//   //       borderRadius: BorderRadius.circular(8),
//   //       border: Border.all(color: Colors.grey.shade300),
//   //       boxShadow: [
//   //         BoxShadow(
//   //           color: Colors.black.withOpacity(0.1),
//   //           blurRadius: 4,
//   //           offset: const Offset(0, 2),
//   //         ),
//   //       ],
//   //     ),
//   //     child: ClipRRect(
//   //       borderRadius: BorderRadius.circular(8),
//   //       child: Image.asset(
//   //         _ticketDetail!.imageUrl,
//   //         fit: BoxFit.cover,
//   //         errorBuilder: (context, error, stackTrace) {
//   //           return Container(
//   //             color: Colors.grey.shade100,
//   //             child: Icon(
//   //               Icons.image_outlined,
//   //               size: screenWidth * 0.08,
//   //               color: Colors.grey.shade400,
//   //             ),
//   //           );
//   //         },
//   //       ),
//   //     ),
//   //   );
//   // }

//   // Widget _buildImageAttachments(
//   //   double screenWidth,
//   //   TicketDetailModel? ticketDetail,
//   // ) {
//   //   final images = ticketDetail?.imageUrls ?? [];
//   //   if (images.isEmpty) return SizedBox.shrink();

//   //   return SizedBox(
//   //     height: screenWidth * 0.20,
//   //     child: ListView.separated(
//   //       scrollDirection: Axis.horizontal,
//   //       padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
//   //       itemCount: images.length,
//   //       separatorBuilder: (_, __) => SizedBox(width: screenWidth * 0.03),
//   //       itemBuilder: (context, index) {
//   //         return Container(
//   //           // width: screenWidth * 0.20,
//   //           // height: screenWidth * 0.20,
//   //           decoration: BoxDecoration(
//   //             color: Colors.white.withOpacity(0.2),
//   //             borderRadius: BorderRadius.circular(8),
//   //             border: Border.all(color: Colors.grey.shade300),
//   //             boxShadow: [
//   //               BoxShadow(
//   //                 color: Colors.black.withOpacity(0.1),
//   //                 blurRadius: 4,
//   //                 offset: const Offset(0, 2),
//   //               ),
//   //             ],
//   //           ),
//   //           child: ClipRRect(
//   //             borderRadius: BorderRadius.circular(8),
//   //             child: Image.network(
//   //               images[index],
//   //               fit: BoxFit.cover,
//   //               errorBuilder: (context, error, stackTrace) {
//   //                 return Container(
//   //                   color: Colors.grey.shade100,
//   //                   child: Icon(
//   //                     Icons.image_outlined,
//   //                     size: screenWidth * 0.08,
//   //                     color: Colors.grey.shade400,
//   //                   ),
//   //                 );
//   //               },
//   //             ),
//   //           ),
//   //         );
//   //       },
//   //     ),
//   //   );
//   // }

//   Widget _buildImageAttachments(
//     double screenWidth,
//     TicketDetailModel? ticketDetail,
//   ) {
//     final images = ticketDetail?.imageUrls ?? [];
//     if (images.isEmpty) return const SizedBox.shrink();

//     return SizedBox(
//       height: screenWidth * 0.20,
//       child: ListView.separated(
//         scrollDirection: Axis.horizontal,
//         padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
//         itemCount: images.length,
//         separatorBuilder: (_, __) => SizedBox(width: screenWidth * 0.03),
//         itemBuilder: (context, index) {
//           final imageUrl = images[index];
//           final fileName = imageUrl.split('/').last;

//           return GestureDetector(
//             onTap: () => _openImageViewerFromUrl(
//               context: context,
//               imageUrl: images[index],
//             ),
//             child: Container(
//               width: screenWidth * 0.20,
//               height: screenWidth * 0.20,
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(8),
//                 border: Border.all(color: Colors.grey.shade300),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.1),
//                     blurRadius: 4,
//                     offset: const Offset(0, 2),
//                   ),
//                 ],
//               ),
//               child: Hero(
//                 tag: 'image_$index',
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(8),
//                   child: Image.network(
//                     imageUrl,
//                     fit: BoxFit.cover,
//                     errorBuilder: (context, error, stackTrace) {
//                       return Container(
//                         color: Colors.grey.shade100,
//                         child: Icon(
//                           Icons.image_outlined,
//                           size: screenWidth * 0.08,
//                           color: Colors.grey.shade400,
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Future<void> _openImageViewerFromUrl({
//     required BuildContext context,
//     required String imageUrl,
//   }) async {
//     final fileName = imageUrl.split('/').last;

//     try {
//       final response = await http.get(Uri.parse(imageUrl));
//       if (response.statusCode == 200) {
//         final tempDir = await getTemporaryDirectory();
//         final file = File(p.join(tempDir.path, fileName));
//         await file.writeAsBytes(response.bodyBytes);

//         if (!context.mounted) return;
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (_) => ImageViewerScreen(
//               imageFile: file,
//               heroTag: imageUrl,
//               fileName: fileName,
//             ),
//           ),
//         );
//       } else {
//         _showError(context, 'Failed to load image');
//       }
//     } catch (e) {
//       _showError(context, 'Error opening image');
//     }
//   }

//   void _showError(BuildContext context, String message) {
//     if (!context.mounted) return;
//     AppSnackBar.showError(context: context, message: message);
//   }

//   Widget _buildLocationAndVisibility(
//     double screenWidth,
//     TicketDetailModel? ticketDetail,
//   ) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Location
//         Text(
//           "Location : ${ticketDetail!.location}",
//           style: GoogleFonts.lato(
//             fontSize: screenWidth * 0.035,
//             color: AppConstants.black50,
//           ),
//         ),

//         SizedBox(height: screenWidth * 0.03),

//         //added
//         Text(
//           "Community : ${ticketDetail.community}",
//           style: GoogleFonts.lato(
//             fontSize: screenWidth * 0.035,
//             color: AppConstants.black50,
//           ),
//         ),

//         SizedBox(height: screenWidth * 0.03),

//         // Visibility and Assignee Row
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             // Visibility Dropdown
//             Container(
//               padding: EdgeInsets.symmetric(
//                 horizontal: screenWidth * 0.03,
//                 vertical: screenWidth * 0.01,
//               ),
//               decoration: BoxDecoration(
//                 color: Colors.grey.shade200,
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: DropdownButtonHideUnderline(
//                 child: DropdownButton<String>(
//                   value: _selectedVisibility,
//                   icon: Icon(
//                     Icons.keyboard_arrow_down,
//                     color: AppConstants.black50,
//                     size: screenWidth * 0.04,
//                   ),
//                   style: GoogleFonts.lato(
//                     color: AppConstants.black,
//                     fontSize: screenWidth * 0.032,
//                   ),
//                   items: _visibilityOptions.map((String option) {
//                     return DropdownMenuItem<String>(
//                       value: option,
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Icon(
//                             Icons.visibility_outlined,
//                             size: screenWidth * 0.035,
//                             color: AppConstants.black50,
//                           ),
//                           SizedBox(width: screenWidth * 0.02),
//                           Text(option),
//                         ],
//                       ),
//                     );
//                   }).toList(),
//                   onChanged: (String? newValue) {
//                     if (newValue != null) {
//                       setState(() {
//                         _selectedVisibility = newValue;
//                       });
//                     }
//                   },
//                 ),
//               ),
//             ),

//             // Assignee
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.end,
//               children: [
//                 Text(
//                   "Assignee",
//                   style: GoogleFonts.lato(
//                     fontSize: screenWidth * 0.03,
//                     color: AppConstants.black50,
//                   ),
//                 ),
//                 Text(
//                   ticketDetail.assignee,
//                   style: GoogleFonts.lato(
//                     fontSize: screenWidth * 0.035,
//                     fontWeight: FontWeight.w500,
//                     color: AppConstants.black,
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildResponseInfo(
//     double screenWidth,
//     TicketDetailModel? ticketDetail,
//   ) {
//     return Container(
//       padding: EdgeInsets.symmetric(vertical: screenWidth * 0.03),
//       decoration: BoxDecoration(
//         border: Border(
//           top: BorderSide(color: Colors.grey.shade300),
//           bottom: BorderSide(color: Colors.grey.shade300),
//         ),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Row(
//             children: [
//               Icon(
//                 Icons.comment_outlined,
//                 size: screenWidth * 0.04,
//                 color: AppConstants.black50,
//               ),
//               SizedBox(width: screenWidth * 0.02),
//               Text(
//                 "${ticketDetail!.responseCount} Responses",
//                 style: GoogleFonts.lato(
//                   fontSize: screenWidth * 0.035,
//                   color: AppConstants.black50,
//                 ),
//               ),
//             ],
//           ),
//           Text(
//             "Created By : ${ticketDetail.createdBy}",
//             style: GoogleFonts.lato(
//               fontSize: screenWidth * 0.03,
//               color: AppConstants.black50,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCommentsSection(
//     double screenWidth,
//     TicketDetailModel? ticketDetail,
//   ) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Comments Header
//         Container(
//           width: double.infinity,
//           padding: EdgeInsets.symmetric(
//             horizontal: screenWidth * 0.04,
//             vertical: screenWidth * 0.03,
//           ),
//           decoration: BoxDecoration(
//             color: Colors.grey.shade200,
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Text(
//             "COMMENTS & ACTIVITY",
//             style: GoogleFonts.lato(
//               fontSize: screenWidth * 0.035,
//               fontWeight: FontWeight.w600,
//               color: AppConstants.black50,
//             ),
//           ),
//         ),

//         SizedBox(height: screenWidth * 0.04),

//         // Comments Section
//         ...(ticketDetail!.comments.isNotEmpty
//             ? ticketDetail!.comments.map(
//                 (comment) => _buildCommentItem(comment, screenWidth),
//               )
//             : [
//                 Center(
//                   child: Text(
//                     "No comments yet.",
//                     style: TextStyle(
//                       fontSize: screenWidth * 0.04,
//                       color: Colors.grey,
//                       fontStyle: FontStyle.italic,
//                     ),
//                   ),
//                 ),
//               ]),

//         SizedBox(height: screenWidth * 0.1), // Space for fixed input
//       ],
//     );
//   }

//   // Widget _buildCommentItem(CommentModel comment, double screenWidth) {
//   //   return Container(
//   //     margin: EdgeInsets.only(bottom: screenWidth * 0.04),
//   //     child: Row(
//   //       crossAxisAlignment: CrossAxisAlignment.start,
//   //       children: [
//   //         // Avatar
//   //         Container(
//   //           width: screenWidth * 0.1,
//   //           height: screenWidth * 0.1,
//   //           decoration: BoxDecoration(
//   //             color: Colors.grey.shade300,
//   //             borderRadius: BorderRadius.circular(screenWidth * 0.05),
//   //           ),
//   //           child: Icon(
//   //             Icons.person,
//   //             color: Colors.grey.shade600,
//   //             size: screenWidth * 0.05,
//   //           ),
//   //         ),

//   //         SizedBox(width: screenWidth * 0.03),

//   //         // Comment Content
//   //         Expanded(
//   //           child: Column(
//   //             crossAxisAlignment: CrossAxisAlignment.start,
//   //             children: [
//   //               // Author and timestamp
//   //               Row(
//   //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//   //                 children: [
//   //                   Column(
//   //                     crossAxisAlignment: CrossAxisAlignment.start,
//   //                     children: [
//   //                       Text(
//   //                         comment.authorName,
//   //                         style: GoogleFonts.lato(
//   //                           fontSize: screenWidth * 0.035,
//   //                           fontWeight: FontWeight.w600,
//   //                           color: AppConstants.black,
//   //                         ),
//   //                       ),
//   //                       Text(
//   //                         "(${comment.authorRole})",
//   //                         style: GoogleFonts.lato(
//   //                           fontSize: screenWidth * 0.03,
//   //                           color: const Color(0xFF10B981),
//   //                           fontWeight: FontWeight.w500,
//   //                         ),
//   //                       ),
//   //                     ],
//   //                   ),
//   //                   Text(
//   //                     comment.timestamp,
//   //                     style: GoogleFonts.lato(
//   //                       fontSize: screenWidth * 0.028,
//   //                       color: AppConstants.black50,
//   //                     ),
//   //                   ),
//   //                 ],
//   //               ),

//   //               SizedBox(height: screenWidth * 0.02),

//   //               // Comment text
//   //               Text(
//   //                 comment.content,
//   //                 style: GoogleFonts.lato(
//   //                   fontSize: screenWidth * 0.035,
//   //                   color: AppConstants.black,
//   //                   height: 1.4,
//   //                 ),
//   //               ),
//   //             ],
//   //           ),
//   //         ),
//   //       ],
//   //     ),
//   //   );
//   // }
//   Widget _buildCommentItem(CommentModel comment, double screenWidth) {
//     return Container(
//       margin: EdgeInsets.only(bottom: screenWidth * 0.04),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Avatar
//           Container(
//             width: screenWidth * 0.1,
//             height: screenWidth * 0.1,
//             decoration: BoxDecoration(
//               color: Colors.grey.shade300,
//               borderRadius: BorderRadius.circular(screenWidth * 0.05),
//             ),
//             child: Icon(
//               Icons.person,
//               color: Colors.grey.shade600,
//               size: screenWidth * 0.05,
//             ),
//           ),

//           SizedBox(width: screenWidth * 0.03),

//           // Comment Content
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Author and timestamp
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           comment.authorName,
//                           style: GoogleFonts.lato(
//                             fontSize: screenWidth * 0.035,
//                             fontWeight: FontWeight.w600,
//                             color: AppConstants.black,
//                           ),
//                         ),
//                         Text(
//                           "(${comment.authorRole})",
//                           style: GoogleFonts.lato(
//                             fontSize: screenWidth * 0.03,
//                             color: const Color(0xFF10B981),
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ],
//                     ),
//                     Text(
//                       comment.timestamp,
//                       style: GoogleFonts.lato(
//                         fontSize: screenWidth * 0.028,
//                         color: AppConstants.black50,
//                       ),
//                     ),
//                   ],
//                 ),

//                 SizedBox(height: screenWidth * 0.02),

//                 // Comment text
//                 if (comment.content.isNotEmpty)
//                   Text(
//                     comment.content,
//                     style: GoogleFonts.lato(
//                       fontSize: screenWidth * 0.035,
//                       color: AppConstants.black,
//                       height: 1.4,
//                     ),
//                   ),

//                 // Images (if any)
//                 if (comment.images.isNotEmpty) ...[
//                   SizedBox(height: screenWidth * 0.02),
//                   SizedBox(
//                     height: screenWidth * 0.20, // Height for image row
//                     child: ListView.builder(
//                       scrollDirection: Axis.horizontal,
//                       itemCount: comment.images.length,
//                       itemBuilder: (context, index) {
//                         return Container(
//                           margin: EdgeInsets.only(
//                             right: index < comment.images.length - 1
//                                 ? screenWidth * 0.02
//                                 : 0,
//                           ),
//                           width: screenWidth * 0.20,
//                           height: screenWidth * 0.20,
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(8),
//                             border: Border.all(color: Colors.grey.shade300),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.black.withOpacity(0.1),
//                                 blurRadius: 4,
//                                 offset: const Offset(0, 2),
//                               ),
//                             ],
//                           ),
//                           child: GestureDetector(
//                             onTap: () => _openImageViewerFromUrl(
//                               context: context,
//                               imageUrl: comment.images[index],
//                             ),
//                             child: Hero(
//                               tag: 'comment_image_${comment.id}_$index',
//                               child: ClipRRect(
//                                 borderRadius: BorderRadius.circular(8),
//                                 child: Image.network(
//                                   comment.images[index],
//                                   width: screenWidth * 0.20,
//                                   height: screenWidth * 0.20,
//                                   fit: BoxFit.cover,
//                                   errorBuilder: (context, error, stackTrace) {
//                                     return Container(
//                                       width: screenWidth * 0.20,
//                                       height: screenWidth * 0.20,
//                                       decoration: BoxDecoration(
//                                         color: Colors.grey.shade300,
//                                         borderRadius: BorderRadius.circular(
//                                           screenWidth * 0.02,
//                                         ),
//                                       ),
//                                       child: Icon(
//                                         Icons.error_outline,
//                                         color: Colors.grey.shade600,
//                                         size: screenWidth * 0.06,
//                                       ),
//                                     );
//                                   },
//                                   loadingBuilder:
//                                       (context, child, loadingProgress) {
//                                         if (loadingProgress == null)
//                                           return child;
//                                         return Container(
//                                           width: screenWidth * 0.25,
//                                           height: screenWidth * 0.25,
//                                           decoration: BoxDecoration(
//                                             color: Colors.grey.shade200,
//                                             borderRadius: BorderRadius.circular(
//                                               screenWidth * 0.02,
//                                             ),
//                                           ),
//                                           child: Center(
//                                             child: SizedBox(
//                                               width: screenWidth * 0.05,
//                                               height: screenWidth * 0.05,
//                                               child: CircularProgressIndicator(
//                                                 strokeWidth: 2,
//                                                 valueColor:
//                                                     AlwaysStoppedAnimation<
//                                                       Color
//                                                     >(Colors.grey.shade600),
//                                               ),
//                                             ),
//                                           ),
//                                         );
//                                       },
//                                 ),
//                               ),
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                 ],
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildReplyInput(
//     double screenWidth, {
//     required void Function(String) onSend,
//   }) {
//     return Container(
//       padding: EdgeInsets.all(screenWidth * 0.04),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 10,
//             offset: const Offset(0, -2),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             child: Container(
//               padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
//               decoration: BoxDecoration(
//                 color: Colors.grey.shade100,
//                 borderRadius: BorderRadius.circular(25),
//                 border: Border.all(color: Colors.grey.shade300),
//               ),
//               child: TextField(
//                 controller: _replyController,
//                 style: GoogleFonts.lato(
//                   fontSize: screenWidth * 0.035,
//                   color: AppConstants.black,
//                 ),
//                 decoration: InputDecoration(
//                   hintText: "Reply to this issue...",
//                   hintStyle: GoogleFonts.lato(
//                     fontSize: screenWidth * 0.035,
//                     color: AppConstants.black50,
//                   ),
//                   border: InputBorder.none,
//                   //add
//                   enabledBorder: InputBorder.none,
//                   focusedBorder: InputBorder.none,
//                   disabledBorder: InputBorder.none,
//                   errorBorder: InputBorder.none,
//                   focusedErrorBorder: InputBorder.none,
//                   //add
//                   fillColor: Colors.grey.shade100,
//                   contentPadding: EdgeInsets.symmetric(
//                     vertical: screenWidth * 0.03,
//                   ),
//                 ),
//                 maxLines: null,
//                 textInputAction: TextInputAction.newline,
//               ),
//             ),
//           ),

//           SizedBox(width: screenWidth * 0.02),

//           // Attachment button
//           GestureDetector(
//             onTap: () => _attachFile(),
//             child: Container(
//               width: screenWidth * 0.1,
//               height: screenWidth * 0.1,
//               decoration: BoxDecoration(
//                 color: Colors.grey.shade200,
//                 borderRadius: BorderRadius.circular(screenWidth * 0.05),
//               ),
//               child: Icon(
//                 Icons.attach_file,
//                 color: AppConstants.black50,
//                 size: screenWidth * 0.05,
//               ),
//             ),
//           ),

//           SizedBox(width: screenWidth * 0.02),

//           // Voice button
//           GestureDetector(
//             onTap: () => _recordVoice(),
//             child: Container(
//               width: screenWidth * 0.1,
//               height: screenWidth * 0.1,
//               decoration: BoxDecoration(
//                 color: Colors.grey.shade200,
//                 borderRadius: BorderRadius.circular(screenWidth * 0.05),
//               ),
//               child: Icon(
//                 Icons.mic,
//                 color: AppConstants.black50,
//                 size: screenWidth * 0.05,
//               ),
//             ),
//           ),

//           SizedBox(width: screenWidth * 0.02),

//           // Send button
//           GestureDetector(
//             onTap: () => _sendReply(onSend),
//             child: Container(
//               width: screenWidth * 0.12,
//               height: screenWidth * 0.12,
//               decoration: BoxDecoration(
//                 color: const Color(0xFF5A5FFF),
//                 borderRadius: BorderRadius.circular(screenWidth * 0.06),
//               ),
//               child: Icon(
//                 Icons.send,
//                 color: Colors.white,
//                 size: screenWidth * 0.05,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatusBadge(String status, double screenWidth) {
//     Color backgroundColor;
//     Color textColor;

//     switch (status.toLowerCase()) {
//       case 'open':
//         backgroundColor = Colors.orange.shade100;
//         textColor = Colors.orange.shade700;
//         break;
//       case 'in progress':
//         backgroundColor = Colors.blue.shade100;
//         textColor = Colors.blue.shade700;
//         break;
//       case 'resolved':
//         backgroundColor = Colors.green.shade100;
//         textColor = Colors.green.shade700;
//         break;
//       case 'closed':
//         backgroundColor = Colors.grey.shade100;
//         textColor = Colors.grey.shade700;
//         break;
//       case 'cancelled':
//         backgroundColor = Colors.orange.shade100;
//         textColor = Colors.orange.shade700;
//         break;
//       default:
//         backgroundColor = Colors.grey.shade100;
//         textColor = Colors.grey.shade700;
//     }

//     return Container(
//       padding: EdgeInsets.symmetric(
//         horizontal: screenWidth * 0.03,
//         vertical: screenWidth * 0.015,
//       ),
//       decoration: BoxDecoration(
//         color: backgroundColor,
//         borderRadius: BorderRadius.circular(6),
//       ),
//       child: Text(
//         status,
//         style: GoogleFonts.lato(
//           fontSize: screenWidth * 0.03,
//           fontWeight: FontWeight.w600,
//           color: textColor,
//         ),
//       ),
//     );
//   }

//   Widget _buildSkeletonLoader(double screenWidth) {
//     return SingleChildScrollView(
//       padding: EdgeInsets.all(screenWidth * 0.05),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Ticket Header Skeleton
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Container(
//                 height: 16,
//                 width: screenWidth * 0.25,
//                 decoration: BoxDecoration(
//                   color: Colors.grey.shade300,
//                   borderRadius: BorderRadius.circular(4),
//                 ),
//               ).redacted(context: context, redact: true),
//               Container(
//                 height: 24,
//                 width: screenWidth * 0.2,
//                 decoration: BoxDecoration(
//                   color: Colors.grey.shade300,
//                   borderRadius: BorderRadius.circular(6),
//                 ),
//               ).redacted(context: context, redact: true),
//             ],
//           ),

//           SizedBox(height: screenWidth * 0.04),

//           // Title and Category Skeleton
//           Row(
//             children: [
//               Expanded(
//                 child: Container(
//                   height: 22,
//                   decoration: BoxDecoration(
//                     color: Colors.grey.shade300,
//                     borderRadius: BorderRadius.circular(4),
//                   ),
//                 ).redacted(context: context, redact: true),
//               ),
//               SizedBox(width: screenWidth * 0.02),
//               Icon(
//                 Icons.arrow_forward_ios,
//                 color: Colors.grey.shade300,
//                 size: screenWidth * 0.04,
//               ),
//               SizedBox(width: screenWidth * 0.02),
//               Container(
//                 height: 18,
//                 width: screenWidth * 0.2,
//                 decoration: BoxDecoration(
//                   color: Colors.grey.shade300,
//                   borderRadius: BorderRadius.circular(4),
//                 ),
//               ).redacted(context: context, redact: true),
//             ],
//           ),

//           SizedBox(height: screenWidth * 0.03),

//           // Timestamp Skeleton
//           Container(
//             height: 14,
//             width: screenWidth * 0.4,
//             decoration: BoxDecoration(
//               color: Colors.grey.shade300,
//               borderRadius: BorderRadius.circular(4),
//             ),
//           ).redacted(context: context, redact: true),

//           SizedBox(height: screenWidth * 0.03),

//           // Description Skeleton
//           Container(
//             height: 16,
//             width: screenWidth * 0.15,
//             decoration: BoxDecoration(
//               color: Colors.grey.shade300,
//               borderRadius: BorderRadius.circular(4),
//             ),
//           ).redacted(context: context, redact: true),

//           SizedBox(height: screenWidth * 0.04),

//           // Image Attachment Skeleton
//           Container(
//             width: screenWidth * 0.3,
//             height: screenWidth * 0.25,
//             decoration: BoxDecoration(
//               color: Colors.grey.shade300,
//               borderRadius: BorderRadius.circular(8),
//             ),
//           ).redacted(context: context, redact: true),

//           SizedBox(height: screenWidth * 0.04),

//           // Location Skeleton
//           Container(
//             height: 16,
//             width: screenWidth * 0.5,
//             decoration: BoxDecoration(
//               color: Colors.grey.shade300,
//               borderRadius: BorderRadius.circular(4),
//             ),
//           ).redacted(context: context, redact: true),

//           SizedBox(height: screenWidth * 0.03),

//           // Visibility and Assignee Row Skeleton
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Container(
//                 height: 36,
//                 width: screenWidth * 0.45,
//                 decoration: BoxDecoration(
//                   color: Colors.grey.shade300,
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//               ).redacted(context: context, redact: true),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.end,
//                 children: [
//                   Container(
//                     height: 12,
//                     width: screenWidth * 0.15,
//                     decoration: BoxDecoration(
//                       color: Colors.grey.shade300,
//                       borderRadius: BorderRadius.circular(4),
//                     ),
//                   ).redacted(context: context, redact: true),
//                   SizedBox(height: screenWidth * 0.01),
//                   Container(
//                     height: 16,
//                     width: screenWidth * 0.08,
//                     decoration: BoxDecoration(
//                       color: Colors.grey.shade300,
//                       borderRadius: BorderRadius.circular(4),
//                     ),
//                   ).redacted(context: context, redact: true),
//                 ],
//               ),
//             ],
//           ),

//           SizedBox(height: screenWidth * 0.04),

//           // Response Info Skeleton
//           Container(
//             padding: EdgeInsets.symmetric(vertical: screenWidth * 0.03),
//             decoration: BoxDecoration(
//               border: Border(
//                 top: BorderSide(color: Colors.grey.shade300),
//                 bottom: BorderSide(color: Colors.grey.shade300),
//               ),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Row(
//                   children: [
//                     Icon(
//                       Icons.comment_outlined,
//                       size: screenWidth * 0.04,
//                       color: Colors.grey.shade300,
//                     ),
//                     SizedBox(width: screenWidth * 0.02),
//                     Container(
//                       height: 14,
//                       width: screenWidth * 0.25,
//                       decoration: BoxDecoration(
//                         color: Colors.grey.shade300,
//                         borderRadius: BorderRadius.circular(4),
//                       ),
//                     ).redacted(context: context, redact: true),
//                   ],
//                 ),
//                 Container(
//                   height: 12,
//                   width: screenWidth * 0.4,
//                   decoration: BoxDecoration(
//                     color: Colors.grey.shade300,
//                     borderRadius: BorderRadius.circular(4),
//                   ),
//                 ).redacted(context: context, redact: true),
//               ],
//             ),
//           ),

//           SizedBox(height: screenWidth * 0.04),

//           // Comments Header Skeleton
//           Container(
//             width: double.infinity,
//             padding: EdgeInsets.symmetric(
//               horizontal: screenWidth * 0.04,
//               vertical: screenWidth * 0.03,
//             ),
//             decoration: BoxDecoration(
//               color: Colors.grey.shade300,
//               borderRadius: BorderRadius.circular(8),
//             ),
//           ).redacted(context: context, redact: true),

//           SizedBox(height: screenWidth * 0.04),

//           // Comment Items Skeleton
//           ...List.generate(2, (index) => _buildSkeletonComment(screenWidth)),

//           SizedBox(height: screenWidth * 0.1),
//         ],
//       ),
//     );
//   }

//   Widget _buildSkeletonComment(double screenWidth) {
//     return Container(
//       margin: EdgeInsets.only(bottom: screenWidth * 0.04),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Avatar Skeleton
//           Container(
//             width: screenWidth * 0.1,
//             height: screenWidth * 0.1,
//             decoration: BoxDecoration(
//               color: Colors.grey.shade300,
//               borderRadius: BorderRadius.circular(screenWidth * 0.05),
//             ),
//           ).redacted(context: context, redact: true),

//           SizedBox(width: screenWidth * 0.03),

//           // Comment Content Skeleton
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Author and timestamp row
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Container(
//                           height: 16,
//                           width: screenWidth * 0.35,
//                           decoration: BoxDecoration(
//                             color: Colors.grey.shade300,
//                             borderRadius: BorderRadius.circular(4),
//                           ),
//                         ).redacted(context: context, redact: true),
//                         SizedBox(height: screenWidth * 0.01),
//                         Container(
//                           height: 12,
//                           width: screenWidth * 0.15,
//                           decoration: BoxDecoration(
//                             color: Colors.grey.shade300,
//                             borderRadius: BorderRadius.circular(4),
//                           ),
//                         ).redacted(context: context, redact: true),
//                       ],
//                     ),
//                     Container(
//                       height: 12,
//                       width: screenWidth * 0.25,
//                       decoration: BoxDecoration(
//                         color: Colors.grey.shade300,
//                         borderRadius: BorderRadius.circular(4),
//                       ),
//                     ).redacted(context: context, redact: true),
//                   ],
//                 ),

//                 SizedBox(height: screenWidth * 0.02),

//                 // Comment text skeleton (multiple lines)
//                 Container(
//                   height: 16,
//                   width: double.infinity,
//                   decoration: BoxDecoration(
//                     color: Colors.grey.shade300,
//                     borderRadius: BorderRadius.circular(4),
//                   ),
//                 ).redacted(context: context, redact: true),
//                 SizedBox(height: screenWidth * 0.01),
//                 Container(
//                   height: 16,
//                   width: screenWidth * 0.8,
//                   decoration: BoxDecoration(
//                     color: Colors.grey.shade300,
//                     borderRadius: BorderRadius.circular(4),
//                   ),
//                 ).redacted(context: context, redact: true),
//                 SizedBox(height: screenWidth * 0.01),
//                 Container(
//                   height: 16,
//                   width: screenWidth * 0.6,
//                   decoration: BoxDecoration(
//                     color: Colors.grey.shade300,
//                     borderRadius: BorderRadius.circular(4),
//                   ),
//                 ).redacted(context: context, redact: true),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // Action methods
//   void _attachFile() {
//     print('Attach file');
//     // TODO: Implement file attachment
//   }

//   void _recordVoice() {
//     print('Record voice message');
//     // TODO: Implement voice recording
//   }

//   void _sendReply(onSend) {
//     final text = _replyController.text.trim();
//     if (text.isNotEmpty) {
//       onSend(text);
//       _replyController.clear();
//     }
//   }

//   @override
//   void dispose() {
//     _replyController.dispose();
//     _scrollController.dispose();
//     super.dispose();
//   }
// }

// Enhanced Ticket Detail Screen with Comment File Attachments
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import 'package:property_manager_app/src/core/utils/app_snackbar.dart';
import 'package:property_manager_app/src/data/models/comment_model.dart';
import 'package:property_manager_app/src/data/services/comment/comment_service_impl.dart';
import 'package:property_manager_app/src/presentation/providers/society_provider.dart';
import 'package:property_manager_app/src/presentation/providers/ticket_detail_provider.dart';
import 'package:property_manager_app/src/presentation/widgets/image_viewer.dart';
import 'package:redacted/redacted.dart';
import 'package:property_manager_app/src/core/constants/app_constants.dart';
import 'package:property_manager_app/src/data/models/ticket_detail_model.dart';
import 'package:property_manager_app/src/data/services/comment/comment_service.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class TicketDetailScreen extends ConsumerStatefulWidget {
  final String ticketId;
  const TicketDetailScreen({super.key, required this.ticketId});

  @override
  ConsumerState<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends ConsumerState<TicketDetailScreen> {
  final TextEditingController _replyController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();

  String get ticketId => widget.ticketId;
  String _selectedVisibility = "Personal ( Only Me )";
  bool _isSendingComment = false;
  List<File> _selectedFiles = [];

  final List<String> _visibilityOptions = [
    "Personal ( Only Me )",
    "Community Members",
    "Admin Only",
  ];

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
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: screenWidth * 0.15,
                            color: Colors.red,
                          ),
                          SizedBox(height: screenWidth * 0.04),
                          Text(
                            "Failed to load ticket: $error",
                            style: GoogleFonts.lato(
                              color: Colors.red,
                              fontSize: screenWidth * 0.04,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: screenWidth * 0.04),
                          ElevatedButton(
                            onPressed: () {
                              // Retry loading
                              ref.invalidate(ticketDetailProvider(ticketId));
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF5A5FFF),
                            ),
                            child: Text(
                              "Retry",
                              style: GoogleFonts.lato(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                    data: (ticket) => Column(
                      children: [
                        // Ticket Details
                        Expanded(
                          child: _buildTicketContent(screenWidth, ticket),
                        ),

                        // Reply Input with File Attachments
                        _buildReplyInput(
                          screenWidth,
                          notifier,
                          ticket.societyId,
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
              ticketDetail?.id ?? '',
              style: GoogleFonts.lato(
                fontSize: screenWidth * 0.035,
                fontWeight: FontWeight.w600,
                color: AppConstants.black,
              ),
            ),
          ],
        ),
        _buildStatusBadge(ticketDetail?.status ?? '', screenWidth),
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
                ticketDetail?.title ?? '',
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
              ticketDetail?.category ?? '',
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
          ticketDetail?.timestamp ?? '',
          style: GoogleFonts.lato(
            fontSize: screenWidth * 0.032,
            color: AppConstants.black50,
          ),
        ),

        SizedBox(height: screenWidth * 0.03),

        // Description
        if ((ticketDetail?.description ?? '').isNotEmpty)
          Text(
            ticketDetail!.description,
            style: GoogleFonts.lato(
              fontSize: screenWidth * 0.035,
              color: AppConstants.black,
            ),
          ),
      ],
    );
  }

  Widget _buildImageAttachments(
    double screenWidth,
    TicketDetailModel? ticketDetail,
  ) {
    final images = ticketDetail?.imageUrls ?? [];
    if (images.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: screenWidth * 0.20,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
        itemCount: images.length,
        separatorBuilder: (_, __) => SizedBox(width: screenWidth * 0.03),
        itemBuilder: (context, index) {
          final imageUrl = images[index];

          return GestureDetector(
            onTap: () => _openImageViewerFromUrl(
              context: context,
              imageUrl: images[index],
            ),
            child: Container(
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
              child: Hero(
                tag: 'ticket_image_$index',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: Colors.grey.shade200,
                        child: Center(
                          child: SizedBox(
                            width: screenWidth * 0.05,
                            height: screenWidth * 0.05,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: const Color(0xFF5A5FFF),
                            ),
                          ),
                        ),
                      );
                    },
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
          "Location : ${ticketDetail?.location ?? 'N/A'}",
          style: GoogleFonts.lato(
            fontSize: screenWidth * 0.035,
            color: AppConstants.black50,
          ),
        ),

        SizedBox(height: screenWidth * 0.03),

        // Community
        Text(
          "Community : ${ticketDetail?.community ?? 'N/A'}",
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
                  ticketDetail?.assignee ?? 'N/A',
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
                "${ticketDetail?.responseCount ?? 0} Responses",
                style: GoogleFonts.lato(
                  fontSize: screenWidth * 0.035,
                  color: AppConstants.black50,
                ),
              ),
            ],
          ),
          Text(
            "Created By : ${ticketDetail?.createdBy ?? 'N/A'}",
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

        // Comments Section
        ...((ticketDetail?.comments ?? []).isNotEmpty
            ? (ticketDetail!.comments).map(
                (comment) => _buildCommentItem(comment, screenWidth),
              )
            : [
                Center(
                  child: Text(
                    "No comments yet.",
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ]),

        SizedBox(height: screenWidth * 0.1), // Space for fixed input
      ],
    );
  }

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
                            color: const Color(0xFF5A5FFF),
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
                if (comment.images.isNotEmpty) ...[
                  SizedBox(height: screenWidth * 0.02),
                  SizedBox(
                    height: screenWidth * 0.20, // Height for image row
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
                          child: GestureDetector(
                            onTap: () => _openImageViewerFromUrl(
                              context: context,
                              imageUrl: comment.images[index],
                            ),
                            child: Hero(
                              tag: 'comment_image_${comment.id}_$index',
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  comment.images[index],
                                  width: screenWidth * 0.20,
                                  height: screenWidth * 0.20,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: screenWidth * 0.20,
                                      height: screenWidth * 0.20,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade300,
                                        borderRadius: BorderRadius.circular(
                                          screenWidth * 0.02,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.error_outline,
                                        color: Colors.grey.shade600,
                                        size: screenWidth * 0.06,
                                      ),
                                    );
                                  },
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return Container(
                                          width: screenWidth * 0.25,
                                          height: screenWidth * 0.25,
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade200,
                                            borderRadius: BorderRadius.circular(
                                              screenWidth * 0.02,
                                            ),
                                          ),
                                          child: Center(
                                            child: SizedBox(
                                              width: screenWidth * 0.05,
                                              height: screenWidth * 0.05,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                      Color
                                                    >(Colors.grey.shade600),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                ),
                              ),
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
    double screenWidth,
    dynamic notifier,
    String societyId,
  ) {
    return Container(
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
      child: Column(
        children: [
          // File Preview Section
          if (_selectedFiles.isNotEmpty) _buildFilePreview(screenWidth),

          // Input Row
          Padding(
            padding: EdgeInsets.all(screenWidth * 0.04),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.04,
                    ),
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
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        fillColor: Colors.grey.shade100,
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
                  onTap: () => _showAttachmentOptions(context, screenWidth),
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
                  onTap: _isSendingComment
                      ? null
                      : () => _sendComment(notifier, societyId),
                  child: Container(
                    width: screenWidth * 0.12,
                    height: screenWidth * 0.12,
                    decoration: BoxDecoration(
                      color: _isSendingComment
                          ? Colors.grey.shade400
                          : const Color(0xFF5A5FFF),
                      borderRadius: BorderRadius.circular(screenWidth * 0.06),
                    ),
                    child: _isSendingComment
                        ? SizedBox(
                            width: screenWidth * 0.04,
                            height: screenWidth * 0.04,
                            child: const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Icon(
                            Icons.send,
                            color: Colors.white,
                            size: screenWidth * 0.05,
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilePreview(double screenWidth) {
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Attachments",
            style: GoogleFonts.lato(
              fontSize: screenWidth * 0.035,
              color: AppConstants.black,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: screenWidth * 0.02),
          SizedBox(
            height: screenWidth * 0.20,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedFiles.length,
              itemBuilder: (context, index) {
                final file = _selectedFiles[index];
                return Container(
                  width: screenWidth * 0.20,
                  margin: EdgeInsets.only(right: screenWidth * 0.02),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Stack(
                    children: [
                      GestureDetector(
                        onTap: () => _isImageFile(file.path)
                            ? _openImageViewer(context, file, index)
                            : null,
                        child: Hero(
                          tag: 'comment_image_$index',
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: _isImageFile(file.path)
                                ? Image.file(
                                    file,
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    width: double.infinity,
                                    height: double.infinity,
                                    color: Colors.grey.shade200,
                                    child: Icon(
                                      Icons.insert_drive_file,
                                      size: screenWidth * 0.06,
                                      color: AppConstants.black50,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _removeFile(index),
                          child: Container(
                            padding: EdgeInsets.all(screenWidth * 0.012),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close,
                              color: Colors.white,
                              size: screenWidth * 0.025,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Attachment Options Bottom Sheet
  void _showAttachmentOptions(BuildContext context, double screenWidth) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.05,
          vertical: screenWidth * 0.04,
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: screenWidth * 0.12,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: screenWidth * 0.04),
              Text(
                "Add Attachments!",
                style: GoogleFonts.lato(
                  fontSize: screenWidth * 0.045,
                  fontWeight: FontWeight.w600,
                  color: AppConstants.black,
                ),
              ),
              SizedBox(height: screenWidth * 0.035),
              _buildAttachmentOption(
                "Take Photo",
                Icons.camera_alt,
                () => _handleImageSelection(ImageSource.camera),
                screenWidth,
              ),
              _buildAttachmentOption(
                "Take Video",
                Icons.videocam,
                () => _handleVideoSelection(ImageSource.camera),
                screenWidth,
              ),
              _buildAttachmentOption(
                "Add Documents",
                Icons.folder,
                () => _handleDocumentSelection(),
                screenWidth,
              ),
              _buildAttachmentOption(
                "Choose from Library",
                Icons.photo_library,
                () => _handleImageSelection(ImageSource.gallery),
                screenWidth,
              ),
              SizedBox(height: screenWidth * 0.03),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "Cancel",
                  style: GoogleFonts.lato(
                    fontSize: screenWidth * 0.038,
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(height: screenWidth * 0.02),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttachmentOption(
    String title,
    IconData icon,
    VoidCallback onTap,
    double screenWidth,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: screenWidth * 0.02),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
        leading: Icon(
          icon,
          color: const Color(0xFF5A5FFF),
          size: screenWidth * 0.055,
        ),
        title: Text(
          title,
          style: GoogleFonts.lato(
            fontSize: screenWidth * 0.038,
            color: AppConstants.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        onTap: () {
          Navigator.pop(context);
          onTap();
        },
      ),
    );
  }

  // File Handling Methods
  Future<void> _handleImageSelection(ImageSource source) async {
    if (await _requestPermission(
      source == ImageSource.camera ? Permission.camera : Permission.photos,
    )) {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _selectedFiles.add(File(image.path));
        });
      }
    }
  }

  Future<void> _handleVideoSelection(ImageSource source) async {
    if (await _requestPermission(Permission.camera)) {
      final XFile? video = await _picker.pickVideo(source: source);
      if (video != null) {
        setState(() {
          _selectedFiles.add(File(video.path));
        });
      }
    }
  }

  Future<void> _handleDocumentSelection() async {
    if (await _requestPermission(Permission.storage)) {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.any,
      );

      if (result != null) {
        setState(() {
          _selectedFiles.addAll(
            result.paths.map((path) => File(path!)).toList(),
          );
        });
      }
    }
  }

  Future<bool> _requestPermission(Permission permission) async {
    final status = await permission.request();
    if (status.isDenied) {
      _showPermissionDialog(permission);
      return false;
    }
    return status.isGranted;
  }

  void _showPermissionDialog(Permission permission) {
    final screenWidth = MediaQuery.of(context).size.width;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          "Permission Required",
          style: GoogleFonts.lato(
            fontSize: screenWidth * 0.045,
            fontWeight: FontWeight.w600,
            color: AppConstants.black,
          ),
        ),
        content: Text(
          "This app needs ${permission.toString().split('.').last} permission to function properly.",
          style: GoogleFonts.lato(
            fontSize: screenWidth * 0.035,
            color: AppConstants.black50,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: GoogleFonts.lato(
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5A5FFF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              "Settings",
              style: GoogleFonts.lato(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Utility Methods
  bool _isImageFile(String path) {
    final ext = path.toLowerCase().split('.').last;
    return ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(ext);
  }

  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });
  }

  void _openImageViewer(BuildContext context, File imageFile, int index) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImageViewerScreen(
          imageFile: imageFile,
          heroTag: 'comment_image_$index',
          fileName: imageFile.path.split('/').last,
        ),
      ),
    );

    if (result == 'remove') {
      _removeFile(index);
      if (!context.mounted) return;
      AppSnackBar.showSuccess(
        context: context,
        message: 'Image removed successfully',
      );
    }
  }

  Future<void> _openImageViewerFromUrl({
    required BuildContext context,
    required String imageUrl,
  }) async {
    final fileName = imageUrl.split('/').last;

    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        final tempDir = await getTemporaryDirectory();
        final file = File(p.join(tempDir.path, fileName));
        await file.writeAsBytes(response.bodyBytes);

        if (!context.mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ImageViewerScreen(
              imageFile: file,
              heroTag: imageUrl,
              fileName: fileName,
            ),
          ),
        );
      } else {
        _showError(context, 'Failed to load image');
      }
    } catch (e) {
      _showError(context, 'Error opening image');
    }
  }

  void _showError(BuildContext context, String message) {
    if (!context.mounted) return;
    AppSnackBar.showError(context: context, message: message);
  }

  // Comment Submission with Database Refresh

  Future<void> _sendComment(dynamic notifier, String societyId) async {
    final text = _replyController.text.trim();

    if (text.isEmpty && _selectedFiles.isEmpty) {
      AppSnackBar.showError(
        context: context,
        message: 'Please enter a comment or attach files',
      );
      return;
    }

    setState(() {
      _isSendingComment = true;
    });

    try {
      final commentService = ref.read(commentServiceProvider);
      List<String> filePaths = _selectedFiles.map((file) => file.path).toList();

      final response = await commentService.sendCommentWithImage(
        ticketId: ticketId,
        comment: text,
        societyId: societyId,
        filePaths: filePaths,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Clear input and files
        _replyController.clear();
        setState(() {
          _selectedFiles.clear();
        });

        AppSnackBar.showSuccess(
          context: context,
          message: 'Comment sent successfully!',
        );

        // Refresh ticket detail from database
        ref.invalidate(ticketDetailProvider(ticketId));

        // Scroll to bottom to show new comment
        Future.delayed(const Duration(milliseconds: 500), () {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }
    } catch (e) {
      AppSnackBar.showError(
        context: context,
        message: 'Failed to send comment: $e',
      );
    } finally {
      setState(() {
        _isSendingComment = false;
      });
    }
  }

  // Action methods
  void _recordVoice() {
    print('Record voice message');
    // TODO: Implement voice recording
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

          // Community Skeleton
          Container(
            height: 16,
            width: screenWidth * 0.6,
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

  @override
  void dispose() {
    _replyController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

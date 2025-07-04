// Help Desk Tickets Screen - Responsive with Loading States
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:property_manager_app/src/data/models/ticket_model.dart';
import 'package:property_manager_app/src/presentation/providers/complaint_provider.dart';
import 'package:property_manager_app/src/presentation/screens/create_complaint_screen.dart';
import 'package:redacted/redacted.dart';
import 'package:property_manager_app/src/core/constants/app_constants.dart';
import 'package:property_manager_app/src/core/router/app_router.dart';
class HelpDeskScreen extends ConsumerStatefulWidget {
  const HelpDeskScreen({super.key});

  @override
  ConsumerState<HelpDeskScreen> createState() => _HelpDeskScreenState();
}

class _HelpDeskScreenState extends ConsumerState<HelpDeskScreen>
    with RouteAware {
  bool _isLoading = true;
  String _selectedStatus = "All";
  List<TicketModel> _tickets = [];
  List<TicketModel> _filteredTickets = [];

  final List<String> _statusOptions = [
    "All",
    "Open",
    "In Progress",
    "Resolved",
    "Closed",
    "On Hold",
  ];

  @override
  void initState() {
    super.initState();
    // _loadTickets();
  }

   @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final ModalRoute? route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await ref.read(complaintProvider.notifier).refreshComplaints();
  }

  @override
  void didPopNext() {
    // Called when coming back to this screen
    ref.read(complaintProvider.notifier).refreshComplaints();
  }

  Future<void> _loadTickets() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      // Sample ticket data - replace with actual API call
      _tickets = [
        TicketModel(
          id: "BT-2",
          title: "Need a maintenance",
          description: "test",
          status: "Open",
          timestamp: "01:50 PM | 16 Apr'25",
          location: "Community-C01",
          responseCount: 2,
          createdBy: "Mr. Shabbir",
          assignee: "NA",
        ),
        TicketModel(
          id: "BT-1",
          title: "Inquiry",
          description: "test",
          status: "In Progress",
          timestamp: "01:47 PM | 16 Apr'25",
          location: "Community-C01",
          responseCount: 2,
          createdBy: "Mr. Shabbir",
          assignee: "NA",
        ),
        TicketModel(
          id: "BT-3",
          title: "Work permit",
          description: "Major work permit",
          status: "Open",
          timestamp: "03:30 PM | 22 Apr'25",
          location: "Community-C01",
          responseCount: 0,
          createdBy: "Society ADMIN",
          assignee: "NA",
        ),
      ];

      _filterTickets();
      _isLoading = false;
    });
  }

  void _filterTickets() {
    if (_selectedStatus == "All") {
      _filteredTickets = List.from(_tickets);
    } else {
      _filteredTickets = _tickets
          .where((ticket) => ticket.status == _selectedStatus)
          .toList();
    }
  }

  List<TicketModel> _getFilteredTickets(List<TicketModel> tickets) {
    if (_selectedStatus == "All") return tickets;
    return tickets.where((t) => t.status == _selectedStatus).toList();
  }

  void _createNewTicket() {
    // Navigate from Help Desk or FAB
    context.pushNamed('createComplaint');
  }

  void _onStatusChanged(String? newStatus) {
    if (newStatus != null) {
      setState(() {
        _selectedStatus = newStatus;
        _filterTickets();
      });
    }
  }

  void _onTicketTap(String ticketId) {
    ticketId = ticketId.split('-')[1]; // Extract ID from "BT-2" format
    context.pushNamed('ticketDetail', pathParameters: {'id': ticketId});
  }

  @override
  Widget build(BuildContext context) {
    final complaints = ref.watch(complaintProvider);
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
                      // Status Filter
                      _buildStatusFilter(screenWidth),

                      // Tickets List or Empty State
                      // Expanded(
                      //   child: _isLoading
                      //       ? _buildSkeletonLoader(screenWidth)
                      //       : _filteredTickets.isEmpty
                      //       ? _buildEmptyState(screenWidth)
                      //       : _buildTicketsList(screenWidth),
                      // ),
                      Expanded(
                        child: complaints.when(
                          loading: () => _buildSkeletonLoader(screenWidth),
                          error: (e, _) =>
                              Center(child: Text('"Error:${e.toString()}')),
                          data: (tickets) {
                            final filtered = _getFilteredTickets(tickets);
                            return RefreshIndicator(
                              onRefresh: _onRefresh,
                              child: filtered.isEmpty
                                  ? _buildEmptyState(screenWidth)
                                  : _buildTicketsList(filtered, screenWidth),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createNewTicket(),
        backgroundColor: const Color(0xFF5A5FFF),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
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
              "Personal Complaints and Tickets",
              style: GoogleFonts.lato(
                color: Colors.white,
                fontSize: screenWidth * 0.045,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            onPressed: _onRefresh,
            icon: Icon(
              Icons.refresh,
              color: Colors.white,
              size: screenWidth * 0.06,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFilter(double screenWidth) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.05,
        vertical: screenWidth * 0.04,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            "Status : ",
            style: GoogleFonts.lato(
              fontSize: screenWidth * 0.04,
              color: AppConstants.black50,
              fontWeight: FontWeight.w500,
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedStatus,
                icon: Icon(
                  Icons.keyboard_arrow_down,
                  color: AppConstants.black50,
                  size: screenWidth * 0.05,
                ),
                style: GoogleFonts.lato(
                  color: AppConstants.black,
                  fontSize: screenWidth * 0.035,
                  fontWeight: FontWeight.w500,
                ),
                items: _statusOptions.map((String status) {
                  return DropdownMenuItem<String>(
                    value: status,
                    child: Text(status),
                  );
                }).toList(),
                onChanged: _onStatusChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildTicketsList(double screenWidth) {
  //   return ListView.builder(
  //     padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
  //     itemCount: _filteredTickets.length,
  //     itemBuilder: (context, index) {
  //       return _buildTicketCard(_filteredTickets[index], screenWidth);
  //     },
  //   );
  // }

  Widget _buildTicketsList(List<TicketModel> tickets, double screenWidth) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
      itemCount: tickets.length,
      itemBuilder: (context, index) {
        return _buildTicketCard(tickets[index], screenWidth);
      },
    );
  }

  Widget _buildTicketCard(TicketModel ticket, double screenWidth) {
    return Container(
      margin: EdgeInsets.only(bottom: screenWidth * 0.04),
      padding: EdgeInsets.all(screenWidth * 0.04),
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
      child: InkWell(
        onTap: () => _onTicketTap(ticket.id),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      "Ticket ID: ",
                      style: GoogleFonts.lato(
                        fontSize: screenWidth * 0.032,
                        color: AppConstants.black50,
                      ),
                    ),
                    Text(
                      ticket.id,
                      style: GoogleFonts.lato(
                        fontSize: screenWidth * 0.032,
                        fontWeight: FontWeight.w600,
                        color: AppConstants.black,
                      ),
                    ),
                  ],
                ),
                _buildStatusBadge(ticket.status, screenWidth),
              ],
            ),

            SizedBox(height: screenWidth * 0.03),

            // Title
            Text(
              ticket.title,
              style: GoogleFonts.lato(
                fontSize: screenWidth * 0.045,
                fontWeight: FontWeight.bold,
                color: AppConstants.black,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            SizedBox(height: screenWidth * 0.02),

            // Timestamp
            Text(
              ticket.timestamp,
              style: GoogleFonts.lato(
                fontSize: screenWidth * 0.032,
                color: AppConstants.black50,
              ),
            ),

            SizedBox(height: screenWidth * 0.02),

            // Description
            if (ticket.description.isNotEmpty) ...[
              Text(
                ticket.description,
                style: GoogleFonts.lato(
                  fontSize: screenWidth * 0.035,
                  color: AppConstants.black,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: screenWidth * 0.03),
            ],

            // Location
            Text(
              "Location : ${ticket.location}",
              style: GoogleFonts.lato(
                fontSize: screenWidth * 0.032,
                color: AppConstants.black50,
              ),
            ),

            SizedBox(height: screenWidth * 0.03),

            // Footer Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.comment_outlined,
                      size: screenWidth * 0.04,
                      color: AppConstants.black50,
                    ),
                    SizedBox(width: screenWidth * 0.01),
                    Text(
                      "${ticket.responseCount} Responses",
                      style: GoogleFonts.lato(
                        fontSize: screenWidth * 0.032,
                        color: AppConstants.black50,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "Created By : ${ticket.createdBy}",
                      style: GoogleFonts.lato(
                        fontSize: screenWidth * 0.028,
                        color: AppConstants.black50,
                      ),
                    ),
                    if (ticket.assignee != "NA") ...[
                      SizedBox(height: screenWidth * 0.01),
                      Text(
                        "Assignee: ${ticket.assignee}",
                        style: GoogleFonts.lato(
                          fontSize: screenWidth * 0.028,
                          color: AppConstants.black50,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ],
        ),
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
      case 'on hold':
        backgroundColor = Colors.yellow.shade100;
        textColor = Colors.yellow.shade700;
        break;
      default:
        backgroundColor = Colors.grey.shade100;
        textColor = Colors.grey.shade700;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.025,
        vertical: screenWidth * 0.01,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status,
        style: GoogleFonts.lato(
          fontSize: screenWidth * 0.028,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildEmptyState(double screenWidth) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.1),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Illustration Icons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: screenWidth * 0.25,
                  height: screenWidth * 0.15,
                  margin: EdgeInsets.only(right: screenWidth * 0.04),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      Icons.sentiment_dissatisfied_outlined,
                      size: screenWidth * 0.08,
                      color: Colors.orange.shade400,
                    ),
                  ),
                ),
                Container(
                  width: screenWidth * 0.25,
                  height: screenWidth * 0.15,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      Icons.thumb_up_outlined,
                      size: screenWidth * 0.08,
                      color: const Color(0xFF10B981),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: screenWidth * 0.08),

            // Title
            Text(
              "You've not raised any Tickets!",
              style: GoogleFonts.lato(
                fontSize: screenWidth * 0.05,
                fontWeight: FontWeight.bold,
                color: AppConstants.black,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: screenWidth * 0.03),

            // Subtitle
            Text(
              "Looks like you didn't raise a complaint yet.\nAwesome sauce!",
              style: GoogleFonts.lato(
                fontSize: screenWidth * 0.04,
                color: AppConstants.black50,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: screenWidth * 0.08),

            // Create Ticket Button
            SizedBox(
              width: double.infinity,
              height: screenWidth * 0.12,
              // child: ElevatedButton(
              //   onPressed: () => _createNewTicket(),
              //   style: ElevatedButton.styleFrom(
              //     backgroundColor: const Color(0xFF10B981),
              //     shape: RoundedRectangleBorder(
              //       borderRadius: BorderRadius.circular(8),
              //     ),
              //     elevation: 0,
              //   ),

              //   child: Text(
              //     "CREATE TICKET",
              //     style: GoogleFonts.lato(
              //       fontSize: screenWidth * 0.04,
              //       fontWeight: FontWeight.w600,
              //       color: Colors.white,
              //     ),
              //   ),
              // ),
              child: GradientButton(
                onPressed: () => _createNewTicket(),
                label: "CREATE TICKET",
              ),
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
          padding: EdgeInsets.all(screenWidth * 0.04),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: 14,
                    width: screenWidth * 0.25,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ).redacted(context: context, redact: true),
                  Container(
                    height: 20,
                    width: screenWidth * 0.15,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ).redacted(context: context, redact: true),
                ],
              ),
              SizedBox(height: screenWidth * 0.03),
              Container(
                height: 18,
                width: screenWidth * 0.6,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ).redacted(context: context, redact: true),
              SizedBox(height: screenWidth * 0.02),
              Container(
                height: 14,
                width: screenWidth * 0.4,
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
                    width: screenWidth * 0.3,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ).redacted(context: context, redact: true),
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
            ],
          ),
        );
      },
    );
  }
}


/*
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:property_manager_app/src/data/models/ticket_model.dart';
import 'package:property_manager_app/src/presentation/screens/faq_screen/complaint_provider.dart';

class HelpDeskScreen extends ConsumerStatefulWidget {
  const HelpDeskScreen({super.key});

  @override
  ConsumerState<HelpDeskScreen> createState() => _HelpDeskScreenState();
}

class _HelpDeskScreenState extends ConsumerState<HelpDeskScreen> {
  String _selectedStatus = "All";
  final List<String> _statusOptions = [
    "All",
    "Open",
    "In Progress",
    "Resolved",
    "Closed",
    "On Hold",
  ];

  Future<void> _onRefresh() async {
    await ref.read(complaintProvider.notifier).refreshComplaints();
  }

  List<TicketModel> _filterTickets(List<TicketModel> tickets) {
    if (_selectedStatus == "All") return tickets;
    return tickets.where((t) => t.status == _selectedStatus).toList();
  }

  @override
  Widget build(BuildContext context) {
    final complaintsAsync = ref.watch(complaintProvider);
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Help Desk Tickets"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _onRefresh,
          ),
        ],
      ),
      body: complaintsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text("Error: ${error.toString()}")),
        data: (tickets) {
          final filteredTickets = _filterTickets(tickets);

          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: filteredTickets.isEmpty
                ? const Center(child: Text("No tickets found."))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredTickets.length,
                    itemBuilder: (context, index) {
                      final ticket = filteredTickets[index];
                      return ListTile(
                        title: Text(ticket.title),
                        subtitle: Text(ticket.status),
                        onTap: () {
                          // Handle navigation to ticket detail
                        },
                      );
                    },
                  ),
          );
        },
      ),
    );
  }
}

*/
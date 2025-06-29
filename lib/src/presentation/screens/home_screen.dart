// Dashboard Screen (Image 1) - Responsive with TypeAhead and Skeleton Loading
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:redacted/redacted.dart';
import 'package:property_manager_app/src/core/constants/app_constants.dart';
import './profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _communityController = TextEditingController();
  bool _isLoading = true;

  static const tabs = ['/home', '/settings', '/profile'];
  int _locationToTabIndex(String location) {
    final index = tabs.indexWhere((path) => location.startsWith(path));
    return index < 0 ? 0 : index;
  }

  // Dynamic community data
  List<CommunityItem> communities = [];
  CommunityItem? selectedCommunity;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _navigateToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfileScreen()),
    );
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      communities = [
        CommunityItem(id: "com1", name: "Com-1", description: "Community 1"),
        CommunityItem(id: "com2", name: "Com-2", description: "Community 2"),
        CommunityItem(id: "com3", name: "Com-3", description: "Community 3"),
        CommunityItem(
          id: "com4",
          name: "Marina Bay",
          description: "Marina Bay Community",
        ),
        CommunityItem(
          id: "com5",
          name: "Palm Jumeirah",
          description: "Palm Jumeirah Towers",
        ),
        CommunityItem(
          id: "com6",
          name: "Downtown Dubai",
          description: "Downtown Complex",
        ),
        CommunityItem(id: "com1", name: "Com-1", description: "Community 1"),
        CommunityItem(id: "com2", name: "Com-2", description: "Community 2"),
        CommunityItem(id: "com3", name: "Com-3", description: "Community 3"),
        CommunityItem(
          id: "com4",
          name: "Marina Bay",
          description: "Marina Bay Community",
        ),
        CommunityItem(
          id: "com5",
          name: "Palm Jumeirah",
          description: "Palm Jumeirah Towers",
        ),
        CommunityItem(
          id: "com6",
          name: "Downtown Dubai",
          description: "Downtown Complex",
        ),
        CommunityItem(id: "com1", name: "Com-1", description: "Community 1"),
        CommunityItem(id: "com2", name: "Com-2", description: "Community 2"),
        CommunityItem(id: "com3", name: "Com-3", description: "Community 3"),
        CommunityItem(
          id: "com4",
          name: "Marina Bay",
          description: "Marina Bay Community",
        ),
        CommunityItem(
          id: "com5",
          name: "Palm Jumeirah",
          description: "Palm Jumeirah Towers",
        ),
        CommunityItem(
          id: "com6",
          name: "Downtown Dubai",
          description: "Downtown Complex",
        ),
      ];
      selectedCommunity = communities.first;
      _communityController.text = selectedCommunity!.name;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
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
              // Header with Community TypeAhead
              Padding(
                padding: EdgeInsets.all(screenWidth * 0.05),
                child: Row(
                  children: [
                    SizedBox(width: screenWidth * 0.03),
                    Expanded(
                      child: _isLoading
                          ? _buildSkeletonTypeAhead()
                          : _buildCommunityTypeAhead(),
                    ),
                  ],
                ),
              ),

              // Main Content Area
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(top: screenHeight * 0.025),
                  decoration: const BoxDecoration(
                    color: AppConstants.whiteColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Grid Cards
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(screenWidth * 0.05),
                          child: _isLoading
                              ? _buildSkeletonGrid(screenWidth)
                              : _buildDashboardGrid(screenWidth),
                        ),
                      ),

                      // Amenities Section
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          screenWidth * 0.05,
                          0,
                          screenWidth * 0.05,
                          screenWidth * 0.05,
                        ),
                        child: _isLoading
                            ? _buildSkeletonAmenities(screenWidth)
                            : _buildAmenitiesCard(screenWidth),
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

  Widget _buildCommunityTypeAhead() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Community",
          style: GoogleFonts.lato(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppConstants.black,
          ),
        ),
        const SizedBox(height: 4), // Space between title and input
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.52),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.52)),
          ),
          child: TypeAheadField<CommunityItem>(
            controller: _communityController,
            builder: (context, controller, focusNode) {
              return TextField(
                controller: controller,
                focusNode: focusNode,
                style: GoogleFonts.lato(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  fillColor: Colors.transparent,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  suffixIcon: const Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.black,
                  ),
                ),
              );
            },
            suggestionsCallback: (pattern) {
              return communities
                  .where(
                    (community) => community.name.toLowerCase().contains(
                      pattern.toLowerCase(),
                    ),
                  )
                  .toList();
            },
            itemBuilder: (context, community) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F4F5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      community.name,
                      style: GoogleFonts.lato(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppConstants.black,
                      ),
                    ),
                    if (community.description.isNotEmpty)
                      Text(
                        community.description,
                        style: GoogleFonts.lato(
                          fontSize: 12,
                          color: AppConstants.black50,
                        ),
                      ),
                  ],
                ),
              );
            },
            onSelected: (community) {
              setState(() {
                selectedCommunity = community;
                _communityController.text = community.name;
              });
            },
            decorationBuilder: (context, child) {
              return Material(
                type: MaterialType.card,
                elevation: 4,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F4F5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: child,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSkeletonTypeAhead() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 20,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(4),
              ),
            ).redacted(context: context, redact: true),
          ),
          const SizedBox(width: 8),
          Icon(Icons.keyboard_arrow_down, color: Colors.white.withOpacity(0.5)),
        ],
      ),
    );
  }

  Widget _buildDashboardGrid(double screenWidth) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth < 600 ? 2 : 3;
        final childAspectRatio = constraints.maxWidth < 600 ? 1.0 : 1.1;

        return GridView.count(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: screenWidth * 0.04,
          mainAxisSpacing: screenWidth * 0.04,
          childAspectRatio: childAspectRatio,
          children: [
            _buildDashboardCard(
              icon: Icons.people_outline,
              title: "Visitors",
              subtitle: "Expected & past visitors",
              onTap: () => _navigateToVisitors(),
              screenWidth: screenWidth,
            ),
            _buildDashboardCard(
              icon: Icons.notifications_outlined,
              title: "Notify Gate",
              subtitle: "Expected cab, delivery etc",
              onTap: () => _navigateToNotifyGate(),
              screenWidth: screenWidth,
            ),
            _buildDashboardCard(
              icon: Icons.help_outline,
              title: "Help Desk",
              subtitle: "Personal issues",
              onTap: () => _navigateToHelpDesk(),
              screenWidth: screenWidth,
            ),
            _buildDashboardCard(
              icon: Icons.campaign_outlined,
              title: "Notice Board",
              subtitle: "Society announcements",
              onTap: () => _navigateToNoticeBoard(),
              screenWidth: screenWidth,
            ),
          ],
        );
      },
    );
  }

  Widget _buildSkeletonGrid(double screenWidth) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth < 600 ? 2 : 3;

        return GridView.count(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: screenWidth * 0.04,
          mainAxisSpacing: screenWidth * 0.04,
          childAspectRatio: 1.0,
          children: List.generate(
            4,
            (index) => _buildSkeletonCard(screenWidth),
          ),
        );
      },
    );
  }

  Widget _buildSkeletonCard(double screenWidth) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.05),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: screenWidth * 0.12,
              height: screenWidth * 0.12,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(12),
              ),
            ).redacted(context: context, redact: true),
            SizedBox(height: screenWidth * 0.03),
            Container(
              height: 16,
              width: screenWidth * 0.2,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            ).redacted(context: context, redact: true),
            SizedBox(height: screenWidth * 0.02),
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
      ),
    );
  }

  Widget _buildDashboardCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required double screenWidth,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
        ),
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.04),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: screenWidth * 0.12,
                height: screenWidth * 0.12,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: screenWidth * 0.06,
                ),
              ),
              SizedBox(height: screenWidth * 0.03),
              Flexible(
                child: Text(
                  title,
                  style: GoogleFonts.lato(
                    fontSize: screenWidth * 0.04,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.black,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(height: screenWidth * 0.01),
              Flexible(
                child: Text(
                  subtitle,
                  style: GoogleFonts.lato(
                    fontSize: screenWidth * 0.03,
                    color: AppConstants.black50,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAmenitiesCard(double screenWidth) {
    return GestureDetector(
      onTap: () => _navigateToAmenities(),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(screenWidth * 0.05),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Container(
              width: screenWidth * 0.15,
              height: screenWidth * 0.15,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                Icons.location_city_outlined,
                color: Colors.white,
                size: screenWidth * 0.07,
              ),
            ),
            SizedBox(width: screenWidth * 0.04),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Amenities and Classes",
                    style: GoogleFonts.lato(
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: screenWidth * 0.01),
                  Text(
                    "Browse and book amenities",
                    style: GoogleFonts.lato(
                      fontSize: screenWidth * 0.035,
                      color: AppConstants.black50,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppConstants.black50,
              size: screenWidth * 0.04,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonAmenities(double screenWidth) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(screenWidth * 0.05),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: screenWidth * 0.15,
            height: screenWidth * 0.15,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(15),
            ),
          ).redacted(context: context, redact: true),
          SizedBox(width: screenWidth * 0.04),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 18,
                  width: screenWidth * 0.4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ).redacted(context: context, redact: true),
                SizedBox(height: screenWidth * 0.02),
                Container(
                  height: 14,
                  width: screenWidth * 0.3,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ).redacted(context: context, redact: true),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            color: Colors.grey.shade300,
            size: screenWidth * 0.04,
          ),
        ],
      ),
    );
  }

  // Navigation methods
  void _navigateToVisitors() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PropertySelectionScreen()),
    );
  }

  void _navigateToNotifyGate() {
    print('Navigate to Notify Gate');
  }

  void _navigateToHelpDesk() {
    print('Navigate to Help Desk');
  }

  void _navigateToNoticeBoard() {
    print('Navigate to Notice Board');
  }

  void _navigateToAmenities() {
    print('Navigate to Amenities');
  }

  @override
  void dispose() {
    _communityController.dispose();
    super.dispose();
  }
}

// Property Selection Screen (Image 2) - Responsive with TypeAhead and Skeleton Loading
class PropertySelectionScreen extends StatefulWidget {
  const PropertySelectionScreen({super.key});

  @override
  State<PropertySelectionScreen> createState() =>
      _PropertySelectionScreenState();
}

class _PropertySelectionScreenState extends State<PropertySelectionScreen> {
  final TextEditingController _communityController = TextEditingController();
  bool _isLoading = true;

  List<CommunityItem> communities = [];
  List<PropertyItem> properties = [];
  CommunityItem? selectedCommunity;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      communities = [
        CommunityItem(id: "com1", name: "Com-1", description: "Community 1"),
        CommunityItem(id: "com2", name: "Com-2", description: "Community 2"),
        CommunityItem(id: "com3", name: "Com-3", description: "Community 3"),
        CommunityItem(
          id: "com4",
          name: "Marina Bay",
          description: "Marina Bay Community",
        ),
        CommunityItem(
          id: "com5",
          name: "Palm Jumeirah",
          description: "Palm Jumeirah Towers",
        ),
      ];

      properties = [
        PropertyItem(
          id: "SO4-SO4-Office",
          name: "SO4, Afnan Building",
          tenant: "Gopal prasad",
          type: "Tenant",
        ),
        PropertyItem(
          id: "Community-CO1",
          name: "Community Offices, BNH Tower",
          tenant: "Gopal prasad",
          type: "Tenant",
        ),
        PropertyItem(
          id: "Unit-Admin Office 3",
          name: "Unit, Blue Wave Tower",
          tenant: "Gopal prasad",
          type: "Tenant",
        ),
        PropertyItem(
          id: "Community-CO1",
          name: "Community Offices, EQUITY",
          tenant: "Gopal prasad",
          type: "Tenant",
        ),
        PropertyItem(
          id: "Unit-SO-1",
          name: "Unit, Joya Blanca Residence",
          tenant: "Gopal prasad",
          type: "Tenant",
        ),
        PropertyItem(
          id: "A-101, A Block",
          name: "Maple Wood Residency",
          tenant: "Gopal prasad",
          type: "Tenant",
        ),
        PropertyItem(
          id: "Ops-2001, Ops",
          name: "Maple Wood Residency",
          tenant: "Gopal prasad",
          type: "Tenant",
        ),
        PropertyItem(
          id: "Unit-Admin Office 2",
          name: "Unit, Marina Pinnacle",
          tenant: "Gopal prasad",
          type: "Tenant",
        ),
        PropertyItem(
          id: "i-Oakley Square_FM, i",
          name: "Oakley Square JVC - Block A",
          tenant: "Gopal prasad",
          type: "Tenant",
        ),
      ];

      selectedCommunity = communities.first;
      _communityController.text = selectedCommunity!.name;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
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
              // Header with Community TypeAhead
              Padding(
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
                          borderRadius: BorderRadius.circular(
                            screenWidth * 0.06,
                          ),
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: screenWidth * 0.05,
                        ),
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.03),
                    Expanded(
                      child: _isLoading
                          ? _buildSkeletonTypeAhead(screenWidth)
                          : _buildCommunityTypeAhead(),
                    ),
                  ],
                ),
              ),

              // Properties List
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(top: screenHeight * 0.025),
                  decoration: const BoxDecoration(
                    color: AppConstants.whiteColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: _isLoading
                      ? _buildSkeletonList(screenWidth)
                      : _buildPropertiesList(screenWidth),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildCommunityTypeAhead() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: TypeAheadField<CommunityItem>(
        controller: _communityController,
        builder: (context, controller, focusNode) {
          return TextField(
            controller: controller,
            focusNode: focusNode,
            style: GoogleFonts.lato(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              suffixIcon: Icon(Icons.keyboard_arrow_down, color: Colors.white),
            ),
          );
        },
        suggestionsCallback: (pattern) {
          return communities
              .where(
                (community) => community.name.toLowerCase().contains(
                  pattern.toLowerCase(),
                ),
              )
              .toList();
        },
        itemBuilder: (context, community) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(color: Color(0xFFF2F4F5)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  community.name,
                  style: GoogleFonts.lato(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppConstants.black,
                  ),
                ),
                if (community.description.isNotEmpty)
                  Text(
                    community.description,
                    style: GoogleFonts.lato(
                      fontSize: 12,
                      color: AppConstants.black50,
                    ),
                  ),
              ],
            ),
          );
        },
        onSelected: (community) {
          setState(() {
            selectedCommunity = community;
            _communityController.text = community.name;
            // Reload properties for selected community
            _loadPropertiesForCommunity(community.id);
          });
        },
        decorationBuilder: (context, child) {
          return Material(
            type: MaterialType.card,
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF2F4F5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: child,
            ),
          );
        },
      ),
    );
  }

  Widget _buildSkeletonTypeAhead(double screenWidth) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 20,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(4),
              ),
            ).redacted(context: context, redact: true),
          ),
          const SizedBox(width: 8),
          Icon(Icons.keyboard_arrow_down, color: Colors.white.withOpacity(0.5)),
        ],
      ),
    );
  }

  Widget _buildPropertiesList(double screenWidth) {
    return ListView.builder(
      padding: EdgeInsets.all(screenWidth * 0.05),
      itemCount: properties.length,
      itemBuilder: (context, index) {
        return _buildPropertyCard(properties[index], screenWidth);
      },
    );
  }

  Widget _buildSkeletonList(double screenWidth) {
    return ListView.builder(
      padding: EdgeInsets.all(screenWidth * 0.05),
      itemCount: 8,
      itemBuilder: (context, index) {
        return _buildSkeletonPropertyCard(screenWidth);
      },
    );
  }

  Widget _buildPropertyCard(PropertyItem property, double screenWidth) {
    return Container(
      margin: EdgeInsets.only(bottom: screenWidth * 0.03),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(screenWidth * 0.04),
        leading: Container(
          width: screenWidth * 0.12,
          height: screenWidth * 0.12,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF10B981), Color(0xFF059669)],
            ),
            borderRadius: BorderRadius.circular(screenWidth * 0.06),
          ),
          child: Icon(
            Icons.apartment,
            color: Colors.white,
            size: screenWidth * 0.06,
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              property.id,
              style: GoogleFonts.lato(
                fontSize: screenWidth * 0.04,
                fontWeight: FontWeight.bold,
                color: AppConstants.black,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              property.name,
              style: GoogleFonts.lato(
                fontSize: screenWidth * 0.035,
                color: AppConstants.black,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        subtitle: Padding(
          padding: EdgeInsets.only(top: screenWidth * 0.02),
          child: Row(
            children: [
              Flexible(
                child: Text(
                  property.tenant,
                  style: GoogleFonts.lato(
                    fontSize: screenWidth * 0.032,
                    color: AppConstants.black50,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: screenWidth * 0.02),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.02,
                  vertical: screenWidth * 0.005,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  property.type,
                  style: GoogleFonts.lato(
                    fontSize: screenWidth * 0.028,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF6366F1),
                  ),
                ),
              ),
            ],
          ),
        ),
        onTap: () => _selectProperty(property),
      ),
    );
  }

  Widget _buildSkeletonPropertyCard(double screenWidth) {
    return Container(
      margin: EdgeInsets.only(bottom: screenWidth * 0.03),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(screenWidth * 0.04),
        leading: Container(
          width: screenWidth * 0.12,
          height: screenWidth * 0.12,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(screenWidth * 0.06),
          ),
        ).redacted(context: context, redact: true),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 16,
              width: screenWidth * 0.4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            ).redacted(context: context, redact: true),
            SizedBox(height: screenWidth * 0.01),
            Container(
              height: 14,
              width: screenWidth * 0.5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            ).redacted(context: context, redact: true),
          ],
        ),
        subtitle: Padding(
          padding: EdgeInsets.only(top: screenWidth * 0.02),
          child: Row(
            children: [
              Container(
                height: 12,
                width: screenWidth * 0.25,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ).redacted(context: context, redact: true),
              SizedBox(width: screenWidth * 0.02),
              Container(
                height: 20,
                width: screenWidth * 0.15,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(12),
                ),
              ).redacted(context: context, redact: true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
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
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF6366F1),
        unselectedItemColor: AppConstants.black50,
        selectedLabelStyle: GoogleFonts.lato(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.lato(fontSize: 12),
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  void _selectProperty(PropertyItem property) {
    print('Selected property: ${property.id}');
    // Handle property selection
  }

  void _loadPropertiesForCommunity(String communityId) {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call for community-specific properties
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _isLoading = false;
        // You can filter properties based on community here
      });
    });
  }

  @override
  void dispose() {
    _communityController.dispose();
    super.dispose();
  }
}

// Data models
class CommunityItem {
  final String id;
  final String name;
  final String description;

  CommunityItem({
    required this.id,
    required this.name,
    required this.description,
  });
}

class PropertyItem {
  final String id;
  final String name;
  final String tenant;
  final String type;

  PropertyItem({
    required this.id,
    required this.name,
    required this.tenant,
    required this.type,
  });
}

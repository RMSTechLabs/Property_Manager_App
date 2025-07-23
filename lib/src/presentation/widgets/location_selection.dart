import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:property_manager_app/src/core/constants/app_constants.dart';
import 'package:property_manager_app/src/core/utils/app_snackbar.dart';
import 'package:property_manager_app/src/data/models/location_model.dart';
import 'package:property_manager_app/src/presentation/providers/society_provider.dart';

// Location Selection Screen
class LocationSelectionScreen extends ConsumerStatefulWidget {
  const LocationSelectionScreen({super.key});

  @override
  ConsumerState<LocationSelectionScreen> createState() =>
      _LocationSelectionScreenState();
}

class _LocationSelectionScreenState
    extends ConsumerState<LocationSelectionScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<LocationModel> _filteredLocations = [];
  List<LocationModel> _allLocations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterLocations);
    _loadLocations();
  }

  void _loadLocations() async {
    try {
      final societyState = ref.read(societyStateProvider);

      // Extract locations from society data
      if (societyState.societies.isNotEmpty) {
        setState(() {
          _allLocations = societyState.societies
              .map(
                (society) => LocationModel(
                  id: society.id ?? "1",
                  locationName: "${society.block}-${society.flat}",
                  apartmentId: society.apartmentId ?? "1",
                  areaId: society.areaId ?? "1",
                  societyId: society.societyId ?? "1",
                ),
              )
              .toList();
          _filteredLocations = List.from(_allLocations);
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text('Error loading locations: $e')),
        // );
        AppSnackBar.showError(
          context: context,
          message: 'Error loading locations: $e',
        );
      }
    }
  }

  void _filterLocations() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredLocations = _allLocations
          .where(
            (location) => location.locationName.toLowerCase().contains(query),
          )
          .toList();
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
              // Header
              _buildHeader(screenWidth),

              // Locations List
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
                      // Search Bar
                      _buildSearchBar(screenWidth),

                      // Locations List
                      Expanded(
                        child: _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : _buildLocationsList(screenWidth),
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
              "Select Location",
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

  Widget _buildSearchBar(double screenWidth) {
    return Container(
      margin: EdgeInsets.all(screenWidth * 0.05),
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        style: GoogleFonts.lato(
          fontSize: screenWidth * 0.04,
          color: AppConstants.black,
        ),
        decoration:
            InputDecoration(
              hintText: "Search locations...",
              hintStyle: GoogleFonts.lato(
                fontSize: screenWidth * 0.04,
                color: AppConstants.black50,
              ),
              border: InputBorder.none,
              //add
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              isDense: true,
              //add
              suffixIcon: Icon(
                Icons.search,
                color: AppConstants.black50,
                size: screenWidth * 0.05,
              ),
            ).copyWith(
              hintStyle: GoogleFonts.lato(
                fontSize: screenWidth * 0.04,
                color: AppConstants.black50,
              ),
              suffixIcon: Icon(
                Icons.search,
                color: AppConstants.black50,
                size: screenWidth * 0.05,
              ),
            ),
      ),
    );
  }

  Widget _buildLocationsList(double screenWidth) {
    if (_filteredLocations.isEmpty) {
      return Center(
        child: Text(
          "No locations found",
          style: GoogleFonts.lato(
            fontSize: screenWidth * 0.04,
            color: AppConstants.black50,
          ),
        ),
      );
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.separated(
        padding: EdgeInsets.zero,
        itemCount: _filteredLocations.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          color: Colors.grey.shade200,
          indent: screenWidth * 0.04,
          endIndent: screenWidth * 0.04,
        ),
        itemBuilder: (context, index) {
          final location = _filteredLocations[index];
          return ListTile(
            title: Text(
              location.locationName,
              style: GoogleFonts.lato(
                fontSize: screenWidth * 0.04,
                color: AppConstants.black,
                fontWeight: FontWeight.w500,
              ),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.04,
              vertical: screenWidth * 0.01,
            ),
            onTap: () => Navigator.pop(context, location),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/city.dart';
import 'city_card.dart';
import 'cityDetails.dart';

class CityListingPage extends StatefulWidget {
  const CityListingPage({Key? key}) : super(key: key);

  @override
  State<CityListingPage> createState() => _CityListingPageState();
}

class _CityListingPageState extends State<CityListingPage> {
  int selectedIndex = 0;
  int selectedCityIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore Cities'),
        backgroundColor: Colors.black87,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('cities').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No cities available'));
          }

          final cities = snapshot.data!.docs
              .map((doc) => City.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
              .toList();

          final topCities = cities.length > 10 ? cities.sublist(0, 10) : cities;

          List<City> visibleCities = List.generate(4, (i) {
            int idx = (selectedIndex + i) % topCities.length;
            return topCities[idx];
          });

          final selectedCity = visibleCities[0];

          return LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Image + Cards
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: selectedCity.imageUrl.isNotEmpty
                                ? Image.network(
                              selectedCity.imageUrl,
                              fit: BoxFit.cover,
                              color: Colors.black.withOpacity(0.6),
                              colorBlendMode: BlendMode.darken,
                            )
                                : Container(color: Colors.grey.shade300),
                          ),
                          SafeArea(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: Row(
                                children: [
                                  // Big Card
                                  Expanded(
                                    flex: 6,
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => CityDetailsPage(city: selectedCity),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.only(right: 8),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(30),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.4),
                                              blurRadius: 15,
                                              offset: const Offset(0, 8),
                                            )
                                          ],
                                          image: DecorationImage(
                                            image: NetworkImage(selectedCity.imageUrl),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(30),
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors.transparent,
                                                Colors.black.withOpacity(0.7),
                                              ],
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                            ),
                                          ),
                                          alignment: Alignment.bottomLeft,
                                          padding: const EdgeInsets.only(
                                              left: 16, right: 16, bottom: 40),
                                          child: Text(
                                            selectedCity.name,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 28,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Small Cards
                                  Expanded(
                                    flex: 3,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: List.generate(3, (i) {
                                        final city = visibleCities[i + 1];
                                        return Expanded(
                                          child: GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                selectedIndex =
                                                    (selectedIndex + i + 1) % topCities.length;
                                              });
                                            },
                                            child: Container(
                                              margin: const EdgeInsets.only(bottom: 8),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(20),
                                                image: DecorationImage(
                                                  image: NetworkImage(city.imageUrl),
                                                  fit: BoxFit.cover,
                                                  colorFilter: ColorFilter.mode(
                                                    Colors.black.withOpacity(0.3),
                                                    BlendMode.darken,
                                                  ),
                                                ),
                                              ),
                                              alignment: Alignment.bottomLeft,
                                              padding: const EdgeInsets.all(10),
                                              child: Text(
                                                city.name,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 0),
                        child: Text(
                          selectedCity.description,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    // Title
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      color: Colors.black,
                      width: double.infinity,
                      child: const Text(
                        'Top Destinations',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 24,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    // Horizontal City List
                    Container(
                      height: 240,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: cities.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 16),
                        itemBuilder: (context, index) {
                          final city = cities[index];
                          final isSelected = index == selectedCityIndex;

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CityDetailsPage(city: city),
                                ),
                              );
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: 180,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected ? Colors.blue : Colors.grey.shade300,
                                  width: 3,
                                ),
                                image: DecorationImage(
                                  image: NetworkImage(city.imageUrl),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.vertical(
                                      bottom: Radius.circular(18)),
                                  color: Colors.black.withOpacity(0.6),
                                ),
                                child: Text(
                                  city.name,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

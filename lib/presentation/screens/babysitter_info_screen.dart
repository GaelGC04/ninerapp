import 'package:flutter/material.dart';
import 'package:ninerapp/domain/entities/babysitter.dart';
import 'package:ninerapp/domain/entities/parent.dart';
import 'package:ninerapp/presentation/subscreens/request_babysitter.dart';

class BabysitterInfoScreen extends StatelessWidget {
  final Babysitter babysitter;
  final Parent parent;

  const BabysitterInfoScreen({
    super.key,
    required this.babysitter,
    required this.parent,
  });

  @override
  Widget build(BuildContext context) {
    final experienceYears = babysitter.getExperienceYears();
    final distance = babysitter.distanceMeters ?? 0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF9EE5FF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Info niñero",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 45,
                      backgroundImage: AssetImage("assets/images/profile.png"),
                      // TODO: Aquí puedes reemplazar con NetworkImage si tienes foto real
                    ),
                    const SizedBox(height: 15),
                    Text(
                      "${babysitter.name} ${babysitter.lastName}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                    ),
                    Text(
                      "${babysitter.getAge()} años",
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    const SizedBox(height: 25),

                    _infoSection("Sexo:", babysitter.isFemale ? "Mujer" : "Hombre"),

                    _infoSection("Experiencia:", "$experienceYears años de experiencia"),

                    _infoSection("Distancia:", "A menos de ${distance.toStringAsFixed(0)} metros"),

                    _infoSection("Cobro por hora:", "\$${babysitter.pricePerHour.toStringAsFixed(2)} mxn por hora"),

                    _multipleInfoSection(
                      "Experiencia en las siguientes discapacidades:",
                      [
                        if (babysitter.expHearingDisability) "Auditiva",
                        if (babysitter.expPhysicalDisability) "Motriz",
                        if (babysitter.expVisualDisability) "Visual",
                      ],
                    ),

                    _multipleInfoSection(
                      "Otras:",
                      babysitter.expOtherDisabilities != null &&
                              babysitter.expOtherDisabilities!.isNotEmpty
                          ? [babysitter.expOtherDisabilities!]
                          : [],
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),

            // BUTTONS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5C6BC0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RequestBabysitterScreen(
                            babysitter: babysitter,
                            parent: parent,
                            onRequest: () {
                              Navigator.pop(context);
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      );
                    },
                    child: const Text("Solicitar", style: TextStyle(color: Colors.white),),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 228, 226, 226),
                      side: const BorderSide(color: Color(0xFF5C6BC0)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Volver", style: TextStyle(color: Color(0xFF5C6BC0))),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoSection(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("\n$title", style: const TextStyle(fontWeight: FontWeight.bold)),
        Text("• $value"),
      ],
    );
  }

  Widget _multipleInfoSection(String title, List<String> items) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("\n$title", style: const TextStyle(fontWeight: FontWeight.bold)),
        ...items.map((item) => Text("• $item")).toList(),
      ],
    );
  }
}

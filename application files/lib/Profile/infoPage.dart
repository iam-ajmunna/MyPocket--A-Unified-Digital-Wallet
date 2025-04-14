import 'package:flutter/material.dart';
import 'package:mypocket/Home/WalletScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class InfoPage extends StatefulWidget {
  @override
  _InfoPage createState() => _InfoPage();
}

class _InfoPage extends State<InfoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // Consistent background
      appBar: AppBar(
        backgroundColor: Colors.indigoAccent,
        // A typical vlog app bar color
        title: Text(
          'MyWallet - A Unified Digital Wallet', // More vlog-like title
          style: TextStyle(color: Colors.white), // White text for visibility
        ),
        centerTitle: true,
        // Center the title, common in vlogs
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.home, color: Colors.white), // Home icon
            onPressed: () {
              // Navigate to WalletScreen
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => WalletScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Add padding for text readability
        child: SingleChildScrollView(
          // Make the body scrollable
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start, // Align text to the start
            children: <Widget>[
              Text(
                'Executive Summary 🚀', // Vlog-style heading
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue, // Highlight important sections
                ),
              ),
              const SizedBox(height: 8),
              Text(
                """The rapid digitalization of everyday life has only created the need for secure and effective ways to place cards, documents, passes, amongst others. Today, a lot of people are carrying around multiple cards physically, and maintaining digital stuff needs handling apps separately. This fragmentation is causing a lot of efficiency problems and also causing a high level of risk of loss of important documents or data.  With the Unified Digital Wallet, a single platform is being created that can save and organize various personal documents that you possess - bank cards, loyalty cards, identity cards, transport passes, event tickets, and so on. The goal is to ensure that the most advanced methods of encryption work in combination with a simple user experience to reduce perceived riddles and provide the comfort and security that these data were customized for. 

This one also streamlines document management, makes up for security, and liberates people from using multiple apps. Project Impact is mainly expected to freeze the efficient and secure management of cards and documents being personalized within the marketplace, thereby proffering a good solution.""", // Conversational intro
                style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 20),
              Text(
                'Project Background 💻', // Vlog-style heading
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                """Managing personal documents efficiently and securely is necessary in an increasingly digital world. The normal person has to maintain track of many crucial papers, including payment cards, passes and tickets, Transit cards, driver’s licenses, national IDs, e-passports, insurance cards, medical records, certificates of schooling, etc. While current digital storage solutions frequently lack adaptability, user-friendliness, or strong security, physical storage solutions are vulnerable to damage, theft, or misplacement. This challenge calls for an innovative, all-in-one solution that simplifies document management while ensuring the highest level of security and accessibility. MyPocket is an innovative initiative created to address this demand by developing a safe and intuitive digital platform for organizing and keeping all important papers in one location. MyPocket will enable users to digitize, organize, and access their documents anytime, anywhere, while incorporating advanced encryption techniques to ensure the safety and privacy of sensitive information. """,
                style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 12),
              // Code Snippet (Styled for better presentation in a vlog)

              Text(
                'Conclusion 👨‍🏫', // Vlog-style heading
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                """The Unified Digital Wallet is a comprehensive solution that simplifies and secures the management of payment cards, IDs, loyalty programs, tickets, and more within a single platform. It eliminates the need for physical cards and multiple apps by offering seamless cross-platform accessibility and a user-friendly interface. Powered by a modular microservices architecture and blockchain technology, the wallet ensures data integrity, scalability, and advanced security with biometric authentication and end-to-end encryption features. 

Offline functionality and compliance with global standards ensure reliability and usability, while potential partnerships with financial institutions and governments could significantly expand its capabilities in the future. Positioned to integrate emerging technologies such as IoT, augmented reality, and cryptocurrency management, the wallet offers immense possibilities for bridging physical and digital systems. Although these partnerships are yet to be established, the Unified Digital Wallet remains an innovative solution that redefines document management, delivering unmatched convenience, security, and versatility in a rapidly digitizing world. """,
                style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                textAlign: TextAlign.justify,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
